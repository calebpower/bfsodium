#!/bin/sh
# tests/run.sh — the whole bfsodium suite. This is what `reaper test` gates on.
#
# Tiers exercised here (CONVENTIONS section 8):
#   1 interpreter self-test      the oracle of record must itself be sound
#   2 idiom boundary KATs        edges: carry cascade, top bit wrap, identities
#   4 golden vector, dual oracle  brainfuck == pinned vector == Cryptol spec
#   9 legibility and portability  bflint, itself self-tested first
#   9 declared interfaces true    bffoot proves each INTERFACE line against the
#                                 instruction stream, itself self-tested first
set -eu

here=$(cd "$(dirname "$0")" && pwd)
repo=$(cd "$here/.." && pwd)
cd "$repo"

pass=0; fail=0
run() {  # run LABEL CMD...
    label="$1"; shift
    if "$@" >/dev/null 2>&1; then echo "PASS $label"; pass=$((pass+1))
    else echo "FAIL $label"; fail=$((fail+1)); fi
}
dk() {   # dk PROG IN WANT EXPR LABEL
    if timeout 900 ./tools/dkat.sh "$1" "$2" "$3" "$4" "$5" >/dev/null 2>&1
    then echo "PASS $5"; pass=$((pass+1)); else echo "FAIL $5"; fail=$((fail+1)); fi
}

echo "== build =="
cc -O2 -std=c99 -o tools/bfi tools/bfi.c
cc -O2 -std=c99 -o tools/hx  tools/hx.c
cc -O2 -std=c99 -o tools/bflint tools/bflint.c
cc -O2 -std=c99 -o tools/bfstyle tools/bfstyle.c
cc -O2 -std=c99 -o tools/bffoot tools/bffoot.c
chmod +x tools/kat.sh tools/dkat.sh
echo "built"

echo
echo "== the oracle of record compiles =="
# A PRECONDITION, not a tier: if spec/bfsodium.cry or spec/perm.cry does not
# compile then every dual oracle test and every design proof is meaningless,
# and each will report a mismatched value rather than a broken spec. That
# happened once -- 149 failures, not one of which said what was wrong, after a
# forty minute run. So this aborts the suite the way a failed build does,
# instead of burning the rest of the run to say nothing.
for cry in bfsodium perm; do
    out=$(cd spec && printf ":l $cry.cry\n" | CRYPTOLPATH=. cryptol -b /dev/stdin 2>&1) || true
    case "$out" in
        *rror*) echo "FAIL spec/$cry.cry does not compile; every oracle rests on it"
                printf '%s\n' "$out"
                echo "passed 0, failed 1"
                exit 1 ;;
    esac
    echo "PASS spec/$cry.cry compiles"; pass=$((pass+1))
done

echo
echo "== tier 1: interpreter self-test =="
tmp=$(mktemp -d)
printf '++++++++[>++++[>++>+++>+++>+<<<<-]>+>+>->>+[<]<-]>>.>---.+++++++..+++.>>.<-.<.+++.------.--------.>>+.>++.' > "$tmp/hello.bf"
run "hello world"        sh -c "./tools/bfi $tmp/hello.bf | grep -q 'Hello World'"
printf ',.,.,.' > "$tmp/echo3.bf"
run "binary echo (NUL and high byte)" ./tools/kat.sh "$tmp/echo3.bf" 00ff41 00ff41 echo3
printf '+,.' > "$tmp/eof.bf"
run "comma at EOF leaves cell unchanged" ./tools/kat.sh "$tmp/eof.bf" "" 01 eof
printf '<' > "$tmp/left.bf"
run "left of cell 0 is an error" sh -c "./tools/bfi $tmp/left.bf </dev/null; test \$? -eq 3"
printf -- '-.' > "$tmp/wrap.bf"
run "cell wraps 0 to 255"  ./tools/kat.sh "$tmp/wrap.bf" "" ff wrap
printf '; prose, with punctuation. inert\n,.\n' > "$tmp/cmt.bf"
run "semicolon comments are inert" ./tools/kat.sh "$tmp/cmt.bf" 41 41 cmt
rm -rf "$tmp"

echo
echo "== tier 9: legibility and portability =="
run "bfstyle self-test" ./tools/bfstyle --selftest
run "bflint self-test" ./tools/bflint --selftest
run "bffoot self-test" ./tools/bffoot --selftest
run "bftable self-test" perl tools/bftable.pl --selftest
# Every committed .bf, not a named list of directories. index/ sat outside the
# old "chacha20 poly1305" globs and so was linted, styled and footprint-checked
# by nothing at all -- it passes when run by hand, which is exactly the state in
# which a regression goes unseen. A new directory is covered by construction.
for f in */*.bf; do run "lint $f" ./tools/bflint "$f"; done
for f in */*.bf; do run "style $f" ./tools/bfstyle "$f"; done
# A routine is pasted into its callers on the strength of its INTERFACE line, so
# that line has to be a fact and not a promise. stagger understated its footprint
# by four cells, quietly borrowed them from the block function's saved copy of
# the original state, and put one wrong word in every block; the arithmetic was
# perfect and every other tier passed. This is the check that saw it.
for f in */*.bf; do run "footprint $f" ./tools/bffoot "$f"; done

# bffoot returns success on a file with no INTERFACE line -- it declines to
# judge what does not claim to be pasteable, which is right, but it means
# "footprint" above is a pass that asserts nothing on those files. So the set of
# them is pinned. chacha20/stream.bf is a whole program rather than a routine,
# and index/ is the unpasted escape hatch; a NEW routine that forgets its
# INTERFACE line joins this list and fails here, instead of collecting a
# vacuous PASS from the loop above.
run "the files declaring no INTERFACE are exactly the known ones" sh -c '
    got=$(for f in */*.bf; do grep -q "^; INTERFACE" "$f" || echo "$f"; done)
    want="aead/chacha20poly1305.bf
chacha20/stream.bf
index/fetch8.bf
index/fetchword.bf
index/store8.bf
sha256/hkdf.bf
sha256/sha256.bf"
    test "$got" = "$want"'

# The committed brainfuck must be exactly what its skeleton expands to. Nothing
# is hand-edited downstream of bfexpand, and this is the check that says so --
# it is also what caught bfexpand dropping all but the first line of a
# multi-line read prologue, which pasted 47 stray reads into a caller.
for s in */*.skel; do
    run "regenerates ${s%.skel}.bf" \
        sh -c "sh tools/bfexpand.sh '$s' | cmp -s - '${s%.skel}.bf'"
done
# A routine's contracts are written relative to its own base, so a paste site
# that does not say where the routine's zero lands cannot have them rewritten.
# Guessing zero is how a wrong contract passes quietly, so it is a hard error.
tmpb=$(mktemp -d)
printf '@@ADD32@@\n' > "$tmpb/nobase.skel"
run "a paste site with no base is refused" \
    sh -c "! sh tools/bfexpand.sh $tmpb/nobase.skel >/dev/null 2>&1"
printf '@@ADD32@@ 0\n' > "$tmpb/base.skel"
run "a paste site with a base is accepted" \
    sh -c "sh tools/bfexpand.sh $tmpb/base.skel >/dev/null 2>&1"
# An unknown paste name used to fall through to the plain code path, carry no
# command bytes, and expand to nothing at all: the routine silently did not
# appear. That cost real time during the AEAD, so it is an error now, and this
# is the check that says so.
printf '@@NOSUCHROUTINE@@ 0\n' > "$tmpb/unknown.skel"
run "a paste site naming no known routine is refused" \
    sh -c "! sh tools/bfexpand.sh $tmpb/unknown.skel >/dev/null 2>&1"
rm -rf "$tmpb"

# HANDOFF's routine table gives a line count per artifact, and it is the only
# place a reader can see what a routine costs to read before opening it.
# Nothing regenerated it and nothing checked it, so eighteen of its thirty rows
# were wrong: chacha20/qrloop was recorded at 464 lines against an actual 1520,
# because the row was written when the transpiler was deleted and the .bf has
# since grown the three routines it pastes. This also fails when a NEW routine
# has a skeleton and no row, which is the drift that matters, since an absent
# row reads as nothing rather than as a wrong number.
run "HANDOFF's routine table describes the tree" perl tools/bftable.pl

# There is ONE definition of the toolchain, in tools/guest-setup.sh, and both
# lanes run it: reaper's [build] calls it with no argument, the Containerfile
# calls it with --toolchain. The moment the Containerfile grows its own apt
# line or its own Cryptol version there are two definitions, and the fallback
# lane starts passing what the gate would fail -- silently, because a container
# that installs a different z3 still runs every test and still says PASS. That
# is the failure this check exists to make loud.
run "the container lane installs nothing of its own" sh -c '
    grep -q "guest-setup.sh --toolchain" Containerfile || exit 1
    ! grep -Eq "apt-get|CRYPTOL_VERSION|cryptol/releases" Containerfile'

echo
echo "== tiers 2 and 4: primitives, dual oracle =="
# ADD8 is the kernel every wide adder is built from and was the slowest thing
# in the library: the old one tested for the carry once per unit of the addend,
# and that test cost a copy of the accumulator, so the kernel cost the PRODUCT
# of the two bytes -- three quarters of a million instructions at 255 plus 255.
# idiom/add8 computes the carry instead, from bit 7 of the two halves added.
# The edges are the ones a carry can turn on: the wrap itself, either operand
# nought, and the pairs either side of 256.
dk idiom/add8.bf 0000 0000 add8Run "add8 nothing plus nothing"
dk idiom/add8.bf ff01 0001 add8Run "add8 the wrap at 255 plus 1"
dk idiom/add8.bf ff00 ff00 add8Run "add8 255 plus nothing does not carry"
dk idiom/add8.bf 00ff ff00 add8Run "add8 nothing plus 255 does not carry"
dk idiom/add8.bf 8080 0001 add8Run "add8 128 plus 128 is exactly 256"
dk idiom/add8.bf 807f ff00 add8Run "add8 one short of the wrap"
dk idiom/add8.bf ffff fe01 add8Run "add8 255 plus 255"
dk idiom/add8.bf 01ff 0001 add8Run "add8 1 plus 255  the low bits both set"
dk idiom/add8.bf 0101 0200 add8Run "add8 both low bits set with no carry"
dk idiom/add8.bf 7f7f fe00 add8Run "add8 127 plus 127 is one short of the wrap"

# Ten vectors are not 65536, and this kernel is the one place in the library
# where every input can actually be tried. Four full sweeps: nought, either
# side of the halfway point, and the top. Each is 256 runs of a 166 line file.
run "add8 swept over every addend at 0, 127, 128 and 255" sh -c '
  for x in 00 7f 80 ff; do
    for y in $(seq 0 255); do
      yh=$(printf %02x "$y")
      got=$(printf "%s%s" "$x" "$yh" | ./tools/hx -r | ./tools/bfi idiom/add8.bf | ./tools/hx)
      want=$(printf "%02x%02x" $(( (0x$x + y) % 256 )) $(( (0x$x + y) / 256 )))
      [ "$got" = "$want" ] || { echo "add8 $x + $yh gave $got not $want"; exit 1; }
    done
  done'

dk chacha20/add32.bf 1200000034000000 46000000 add32Run "add32 18+52"
dk chacha20/add32.bf ffffffff01000000 00000000 add32Run "add32 carry cascade"
dk chacha20/add32.bf ff00000001000000 00010000 add32Run "add32 cross byte carry"
dk chacha20/add32.bf 7856341211111111 89674523 add32Run "add32 mixed"
dk chacha20/add32.bf 0000000000000000 00000000 add32Run "add32 zero"
dk chacha20/add32.bf ffffffffffffffff feffffff add32Run "add32 max plus max"

# The three routines SHA_256 needs and ChaCha20 did not. and32 is xor32 with
# a different combining step; rotr32 and shr32 are chacha20/rotl32 turned
# around, and turning it around is what makes them cheap: rotl32 shifts left
# by DOUBLING, which is an addition, where shifting right is HALVE and costs
# about a fifth as much per bit. rotr32 by 16 is 320,371 instructions against
# rotl32 by 16 at 1,433,049.
dk idiom/and32.bf ffffffff00000000 00000000 and32Run "and32 ffffffff00000000"
dk idiom/and32.bf ffffffffffffffff ffffffff and32Run "and32 ffffffffffffffff"
dk idiom/and32.bf 0f0f0f0ff0f0f0f0 00000000 and32Run "and32 0f0f0f0ff0f0f0f0"
dk idiom/and32.bf 78563412efbeadde 68162412 and32Run "and32 78563412efbeadde"
dk idiom/and32.bf aa55aa5555aa55aa 00000000 and32Run "and32 aa55aa5555aa55aa"
dk idiom/and32.bf ffffffff78563412 78563412 and32Run "and32 ffffffff78563412"
dk idiom/and32.bf 0000000000000000 00000000 and32Run "and32 0000000000000000"
dk idiom/and32.bf 01020408ffffffff 01020408 and32Run "and32 01020408ffffffff"
# Rotations at the counts SHA_256 actually asks for, plus the edges: by one,
# by a whole byte, and by 31, where every bit crosses a byte boundary.
dk idiom/rotr32.bf 0100000001 00000080 rotr32nRun "rotr32 by 1"
dk idiom/rotr32.bf 0100000008 00000001 rotr32nRun "rotr32 by 8"
dk idiom/rotr32.bf 7856341210 34127856 rotr32nRun "rotr32 by 16"
dk idiom/rotr32.bf 010000001f 02000000 rotr32nRun "rotr32 by 31"
dk idiom/rotr32.bf 7856341207 ac6824f0 rotr32nRun "rotr32 by 7"
dk idiom/rotr32.bf 7856341202 9e158d04 rotr32nRun "rotr32 by 2"
dk idiom/rotr32.bf ffffffff0d ffffffff rotr32nRun "rotr32 by 13"
dk idiom/rotr32.bf 0000008001 00000040 rotr32nRun "rotr32 by 1"
dk idiom/rotr32.bf 7856341219 093c2b1a rotr32nRun "rotr32 by 25"
# The shift differs from the rotation only in what happens to the bit that
# falls out of the bottom, so the cases that matter are the ones where a bit
# would have wrapped: by 31 from a word with only the top bit set must give
# one, and from a word with only the bottom bit set must give nought.
dk idiom/shr32.bf 0100000001 00000000 shr32nRun "shr32 by 1"
dk idiom/shr32.bf 7856341203 cf8a4602 shr32nRun "shr32 by 3"
dk idiom/shr32.bf 785634120a 158d0400 shr32nRun "shr32 by 10"
dk idiom/shr32.bf ffffffff1f 01000000 shr32nRun "shr32 by 31"
dk idiom/shr32.bf 000000801f 01000000 shr32nRun "shr32 by 31"
dk idiom/shr32.bf 7856341210 34120000 shr32nRun "shr32 by 16"
dk idiom/shr32.bf ffffffff01 ffffff7f shr32nRun "shr32 by 1"
dk idiom/shr32.bf 0100000001 00000000 shr32nRun "shr32 by 1"

dk chacha20/rotl32.bf 0100000001 02000000 rotl32nRun "rotl32 by 1"
dk chacha20/rotl32.bf 0100000008 00010000 rotl32nRun "rotl32 by 8"
dk chacha20/rotl32.bf 7856341210 34127856 rotl32nRun "rotl32 by 16"
dk chacha20/rotl32.bf 0000008001 01000000 rotl32nRun "rotl32 top bit wraps"
dk chacha20/rotl32.bf 785634120c 23816745 rotl32nRun "rotl32 by 12"
dk chacha20/rotl32.bf 7856341207 093c2b1a rotl32nRun "rotl32 by 7"

dk chacha20/xor32.bf 0f0f0f0ff0f0f0f0 ffffffff xor32Run "xor32 all ones"
dk chacha20/xor32.bf ffffffff00000000 ffffffff xor32Run "xor32 identity"
dk chacha20/xor32.bf 1234567812345678 00000000 xor32Run "xor32 self is zero"
dk chacha20/xor32.bf 78563412efbeadde 97e899cc xor32Run "xor32 mixed"
dk chacha20/xor32.bf aa55aa5555aa55aa ffffffff xor32Run "xor32 alternating"

dk chacha20/stream.bf 000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f01000000000000000000004a0000000072004c616469657320616e642047656e746c656d656e206f662074686520636c617373206f66202739393a204966204920636f756c64206f6666657220796f75206f6e6c79206f6e652074697020666f7220746865206675747572652c2073756e73637265656e20776f756c642062652069742e 6e2e359a2568f98041ba0728dd0d6981e97e7aec1d4360c20a27afccfd9fae0bf91b65c5524733ab8f593dabcd62b3571639d624e65152ab8f530c359f0861d807ca0dbf500d6a6156a38e088a22b65e52bc514d16ccf806818ce91ab77937365af90bbf74a35be6b40b8eedf2785e42874d streamRun "stream cipher RFC 8439 section 2.4.2"

# The block edge is where a stream cipher goes wrong: exactly one block exercises
# no counter step at all, and one byte more is the first that needs one. The two
# outputs must also agree on their first 64 bytes, so the second is a second
# oracle on the first rather than another arbitrary number.
dk chacha20/stream.bf 000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f01000000000000000000004a000000004000030a11181f262d343b424950575e656c737a81888f969da4abb2b9c0c7ced5dce3eaf1f8ff060d141b222930373e454c535a61686f767d848b9299a0a7aeb5bc 214540eb5f3df4d5149c6e3fef3d7881ff699e0ab2ba9b46d5fd732c593d1aa469d1fb5b8d660786ae5b5dfdda15d6782a16db28a948494961b3b5ec57d3f40b streamRun "stream cipher exactly one block"
dk chacha20/stream.bf 000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f01000000000000000000004a000000004100030a11181f262d343b424950575e656c737a81888f969da4abb2b9c0c7ced5dce3eaf1f8ff060d141b222930373e454c535a61686f767d848b9299a0a7aeb5bcc3 214540eb5f3df4d5149c6e3fef3d7881ff699e0ab2ba9b46d5fd732c593d1aa469d1fb5b8d660786ae5b5dfdda15d6782a16db28a948494961b3b5ec57d3f40baa streamRun "stream cipher one byte into the second block"

dk chacha20/blockloop.bf 000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f01000000000000090000004a00000000 10f1e7e4d13b5915500fdd1fa32071c4c7d1f4c733c068030422aa9ac3d46c4ed2826446079faa0914c2d705d98b02a2b5129cd1de164eb9cbd083e8a2503c4e blockRun "block function RFC 8439 section 2.3.2"

# BLOCKKEEP is blockloop with the key and nonce surviving the call, which is
# what lets a stream make a second block. Its own arithmetic is blockloop's and
# is tested there; what only this can show is the preservation, so the expected
# output is the keystream FOLLOWED BY the input bytes. A copy that leaked, or
# temps left dirty inside the block frame, changes the second half.
dk chacha20/blockkeep.bf 000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f01000000000000090000004a00000000 10f1e7e4d13b5915500fdd1fa32071c4c7d1f4c733c068030422aa9ac3d46c4ed2826446079faa0914c2d705d98b02a2b5129cd1de164eb9cbd083e8a2503c4e000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f01000000000000090000004a00000000 blockkeepRun "blockkeep RFC 8439 section 2.3.2 with its input intact"
dk chacha20/blockkeep.bf 000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 76b8e0ada0f13d90405d6ae55386bd28bdd219b8a08ded1aa836efcc8b770dc7da41597c5157488d7724e03fb8d84a376a43b8f41518a11cc387b669b2ee6586000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 blockkeepRun "blockkeep an all nought input"

dk chacha20/rowrot.bf 000000000100000002000000030000000400000005000000060000000700000008000000090000000a0000000b0000000c0000000d0000000e0000000f000000 0100000002000000030000000000000005000000060000000700000004000000090000000a0000000b000000080000000d0000000e0000000f0000000c000000 rowrotRun "row rotation  each row left by one word"

dk chacha20/stagger.bf 000000000100000002000000030000000400000005000000060000000700000008000000090000000a0000000b0000000c0000000d0000000e0000000f000000 00000000010000000200000003000000050000000600000007000000040000000a0000000b00000008000000090000000f0000000c0000000d0000000e000000 staggerRun "stagger  row r rotated left by r"

dk chacha20/qrloop.bf 1111111104030201436f8d9b67452301 f4922aeacef81ccb2e478145bbc48158 qrRun "quarter round as a loop  RFC 8439 section 2.2.1"

# KEYGEN is the block function with the counter pinned at nought and the second
# half of its answer discarded, so its own edges are blockloop's and are tested
# there. What these add is the published one time key itself, quoted rather
# than derived: section 2.6.2, and the two section A.4 generation vectors.
# A.4 test vector 3 is deliberately absent -- it could not be quoted with
# confidence, and a pin nobody can source is worse than no pin.
dk aead/keygen.bf 808182838485868788898a8b8c8d8e8f909192939495969798999a9b9c9d9e9f000000000001020304050607 8ad5a08b905f81cc815040274ab29471a833b637e3fd0da508dbb8e2fdd1a646 keygenRun "keygen RFC 8439 section 2.6.2"
dk aead/keygen.bf 0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 76b8e0ada0f13d90405d6ae55386bd28bdd219b8a08ded1aa836efcc8b770dc7 keygenRun "keygen RFC 8439 A.4 vector 1  an all nought key"
dk aead/keygen.bf 0000000000000000000000000000000000000000000000000000000000000001000000000000000000000002 ecfa254f845f647473d3cb140da9e87606cb33066c447b87bc2666dde3fbb739 keygenRun "keygen RFC 8439 A.4 vector 2"

dk poly1305/add136.bf 01000000000000000000000000000000000100000000000000000000000000000000 0200000000000000000000000000000000 add136Run "add136 one plus one"
dk poly1305/add136.bf ffffffffffffffffffffffffffffffffff0100000000000000000000000000000000 0000000000000000000000000000000000 add136Run "add136 full carry cascade"
dk poly1305/add136.bf ff000000000000000000000000000000000100000000000000000000000000000000 0001000000000000000000000000000000 add136Run "add136 cross byte carry"
dk poly1305/add136.bf 0000000000000000000000000000000000ffffffffffffffffffffffffffffffffff ffffffffffffffffffffffffffffffffff add136Run "add136 zero plus max"
# Every case above leaves the top byte either untouched or saturated, so none of
# them would notice an adder that stopped at sixteen bytes AND was fed matching
# top bytes; this one carries a distinct value in byte 16 either side.
dk poly1305/add136.bf deadbeefcafebabe01020304050607080f1122334455667788990011223344556601 efcff133206532479b021426384a5c6e10 add136Run "add136 mixed with a distinct top byte"

dk poly1305/halve136.bf 0200000000000000000000000000000000 0100000000000000000000000000000000 halve136Run "halve136 two"
dk poly1305/halve136.bf 0100000000000000000000000000000000 0000000000000000000000000000000000 halve136Run "halve136 one"
dk poly1305/halve136.bf ffffffffffffffffffffffffffffffffff ffffffffffffffffffffffffffffffff7f halve136Run "halve136 all ones"
dk poly1305/halve136.bf 0001000000000000000000000000000000 8000000000000000000000000000000000 halve136Run "halve136 bit crosses a byte"

dk poly1305/fold136.bf 0700000000000000000000000000000000 0700000000000000000000000000000000 fold136Run "fold small value unchanged"
dk poly1305/fold136.bf 0000000000000000000000000000000004 0500000000000000000000000000000000 fold136Run "fold two to the 130 becomes five"
dk poly1305/fold136.bf 0100000000000000000000000000000004 0600000000000000000000000000000000 fold136Run "fold two to the 130 plus one"
dk poly1305/fold136.bf 0000000000000000000000000000000003 0000000000000000000000000000000003 fold136Run "fold keeps bits 128 and 129"
dk poly1305/fold136.bf ffffffffffffffffffffffffffffffffff 3a01000000000000000000000000000004 fold136Run "fold maximum value"

dk poly1305/reducep136.bf faffffffffffffffffffffffffffffff03 faffffffffffffffffffffffffffffff03 reducep136Run "reducep p minus one unchanged"
dk poly1305/reducep136.bf fbffffffffffffffffffffffffffffff03 0000000000000000000000000000000000 reducep136Run "reducep p becomes zero"
dk poly1305/reducep136.bf fcffffffffffffffffffffffffffffff03 0100000000000000000000000000000000 reducep136Run "reducep p plus one becomes one"
dk poly1305/reducep136.bf ffffffffffffffffffffffffffffffff03 0400000000000000000000000000000000 reducep136Run "reducep two to the 130 minus one"
dk poly1305/reducep136.bf 0000000000000000000000000000000000 0000000000000000000000000000000000 reducep136Run "reducep zero"
dk poly1305/reducep136.bf ffffffffffffffffffffffffffffffffff 3f01000000000000000000000000000000 reducep136Run "reducep maximum value"

dk poly1305/mulmod136.bf 01000000000000000000000000000000000100000000000000000000000000000000 0100000000000000000000000000000000 mulmod136Run "mulmod one times one"
dk poly1305/mulmod136.bf 00000000000000000000000000000000000100000000000000000000000000000000 0000000000000000000000000000000000 mulmod136Run "mulmod zero times one"
dk poly1305/mulmod136.bf 07000000000000000000000000000000000300000000000000000000000000000000 1500000000000000000000000000000000 mulmod136Run "mulmod seven times three"
dk poly1305/mulmod136.bf 00000000000000000000000000000000020200000000000000000000000000000000 0500000000000000000000000000000000 mulmod136Run "mulmod two to the 129 times two"
dk poly1305/mulmod136.bf deadbeefcafebabe0102030405060708030123456789abcdef112233445566778800 d110911895f76b5381bdfca82c1c7a8b01 mulmod136Run "mulmod large with a 16 byte r"
dk poly1305/mulmod136.bf deadbeefcafebabe0102030405060708030123456789abcdef112233445566778802 86c3ed6f90743fb08542043339ab8b1f01 mulmod136Run "mulmod large with a 17 byte r"
# Every case above has its highest set bit in b at 129, so a loop that stopped at
# 135 turns instead of 136 survived all of them -- which is the shape of the bug
# this routine had once before. This one sets every bit of b's top byte.
dk poly1305/mulmod136.bf deadbeefcafebabe01020304050607080300000000000000000000000000000000ff e200ab022ebf543bacbfbebebebebe3e00 mulmod136Run "mulmod with every bit of b's top byte set"
# a is folded before the loop because it arrives as any 17 byte value and
# doubling one of those would lose its top bit. Nothing above has an a big
# enough to notice that, so deleting the fold survived them all.
dk poly1305/mulmod136.bf deadbeefcafebabe01020304050607ffff0300000000000000000000000000000000 550d3ccf60fc303c0506090c0f1215fd03 mulmod136Run "mulmod with a above two to the 130"
# The closing reduction is almost never load bearing: folding leaves the answer
# under 2^130 plus fifteen, and only the twenty values from p upward need it, so
# no random vector reaches them. p times one lands on exactly p and must come out
# nought, which is the one input that proves the reduction happens at all.
dk poly1305/mulmod136.bf fbffffffffffffffffffffffffffffff030100000000000000000000000000000000 0000000000000000000000000000000000 mulmod136Run "mulmod p times one is nought"

dk poly1305/dbl136.bf 0100000000000000000000000000000000 0200000000000000000000000000000000 dbl136Run "dbl136 one becomes two"
dk poly1305/dbl136.bf 8000000000000000000000000000000000 0001000000000000000000000000000000 dbl136Run "dbl136 a bit crosses a byte"
dk poly1305/dbl136.bf ffffffffffffffffffffffffffffffffff feffffffffffffffffffffffffffffffff dbl136Run "dbl136 all ones"
dk poly1305/dbl136.bf 0000000000000000000000000000000080 0000000000000000000000000000000000 dbl136Run "dbl136 the top bit falls off"
dk poly1305/dbl136.bf deadbeefcafebabe0102030405060708fe bc5b7ddf95fd757d030406080a0c0e10fc dbl136Run "dbl136 mixed"

# ABSORB is the step every Poly1305 block takes, and now the only place the
# multiply lives -- poly1305 pastes it rather than carrying its own copy. Its
# edges are the two that a block can actually reach: an accumulator that comes
# out exactly p, which must reduce to nought, and one that wraps the seventeen
# byte adder at 2^136.
# CLAMP is where r is masked, and poly1305 and the AEAD both need it, so it is
# a routine rather than two copies. The mask is pinned from BOTH sides: a value
# of only the bits the clamp removes must come out nought, and a value of only
# the bits it keeps must come out untouched. Either alone would pass a clamp
# that masked too much or too little.
dk poly1305/clamp.bf 85d6be7857556d337f4452fe42d506a8 85d6be0854556d037c44520e40d5060800 clampRun "clamp the RFC section 2.5.2 key half"
dk poly1305/clamp.bf ffffffffffffffffffffffffffffffff ffffff0ffcffff0ffcffff0ffcffff0f00 clampRun "clamp every bit set"
dk poly1305/clamp.bf 00000000000000000000000000000000 0000000000000000000000000000000000 clampRun "clamp nothing set"
dk poly1305/clamp.bf 000000f0030000f0030000f0030000f0 0000000000000000000000000000000000 clampRun "clamp only the bits the clamp removes"
dk poly1305/clamp.bf ffffff0ffcffff0ffcffff0ffcffff0f ffffff0ffcffff0ffcffff0ffcffff0f00 clampRun "clamp only the bits the clamp keeps"
dk poly1305/clamp.bf 8ad5a08b905f81cc815040274ab29471 8ad5a00b905f810c8050400748b2940100 clampRun "clamp the A.4 one time key half"

dk poly1305/absorb.bf 010000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000 0100000000000000000000000000000000 absorbRun "absorb one plus nothing times one"
dk poly1305/absorb.bf 393000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 0000000000000000000000000000000000 absorbRun "absorb nothing at all"
dk poly1305/absorb.bf 0100000000000000000000000000000000faffffffffffffffffffffffffffffff030100000000000000000000000000000000 0000000000000000000000000000000000 absorbRun "absorb a sum of exactly p reduces to nought"
dk poly1305/absorb.bf 0100000000000000000000000000000000ffffffffffffffffffffffffffffffffff0100000000000000000000000000000000 0000000000000000000000000000000000 absorbRun "absorb the accumulator wraps at 2^136"
dk poly1305/absorb.bf 85d6be0854556d037c44520e40d5060800000000000000000000000000000000000043727970746f6772617068696320466f01 fc839ce688ebdd4791ae649d84778cc802 absorbRun "absorb the first block of the RFC message"
dk poly1305/absorb.bf 0123456789abcdef112233445566778802deadbeefcafebabe01020304050607ff01fedcba9876543210ffeeddccbbaa998801 3e15723c32f0108b274b7bce595c431803 absorbRun "absorb a full width r and every operand top bit set"

dk poly1305/poly1305.bf 85d6be7857556d337f4452fe42d506a80103808afb0db2fd4abff6af4149f51b220043727970746f6772617068696320466f72756d2052657365617263682047726f7570 a8061dc1305136c6c22b8baf0c0127a9 poly1305Run34 "poly1305 RFC 8439 section 2.5.2"

# Where the appended ONE goes is the classic Poly1305 defect, so the lengths
# below straddle the block edge: one byte, exactly one block, one byte past it,
# and two full blocks. The oracles for these are built the general way in
# spec/bfsodium.cry and are cross-checked against the longhand poly1305Run34.
dk poly1305/poly1305.bf 85d6be7857556d337f4452fe42d506a80103808afb0db2fd4abff6af4149f51b010041 d0ffca815a0cca49cb9e1ea593ae862c poly1305Run1 "poly1305 one byte"
dk poly1305/poly1305.bf 85d6be7857556d337f4452fe42d506a80103808afb0db2fd4abff6af4149f51b1000414c57626d78838e99a4afbac5d0dbe6 31fac2d1f5457273ffbf25f9aaef8f01 poly1305Run16 "poly1305 exactly one block"
dk poly1305/poly1305.bf 85d6be7857556d337f4452fe42d506a80103808afb0db2fd4abff6af4149f51b1100414c57626d78838e99a4afbac5d0dbe6f1 8f21e6c721b96021a8b06f67a139a7c7 poly1305Run17 "poly1305 one byte past a block"
dk poly1305/poly1305.bf 85d6be7857556d337f4452fe42d506a80103808afb0db2fd4abff6af4149f51b2000414c57626d78838e99a4afbac5d0dbe6f1fc07121d28333e49545f6a75808b96 f95a1a6d12a410808813eddc733aa92a poly1305Run32 "poly1305 two full blocks"

# The AEAD, RFC 8439 section 2.8. The published vector is the 2.8.2 one; the
# rest straddle the two block edges this construction has, which are not the
# same edge: sixteen bytes is a Poly1305 block and sixty four is a ChaCha one.
# An empty AAD and an empty plaintext still authenticate the length block, so
# that case is not a no-op and is the one a short circuit would break.
# The oracles are written out per length in spec/bfsodium.cry, as the
# Poly1305 ones are, because the padding and the block count are type level.
dk aead/chacha20poly1305.bf 808182838485868788898a8b8c8d8e8f909192939495969798999a9b9c9d9e9f07000000404142434445464700000000 a0784d7a4716f3feb4f64e7f4b39bf04 aeadRun_0_0 "aead nothing at all  the tag is over the lengths alone"
dk aead/chacha20poly1305.bf 808182838485868788898a8b8c8d8e8f909192939495969798999a9b9c9d9e9f0700000040414243444546470000010041 de347688a05e3b9aeba6705004e548832e aeadRun_0_1 "aead one byte of plaintext and no AAD"
dk aead/chacha20poly1305.bf 808182838485868788898a8b8c8d8e8f909192939495969798999a9b9c9d9e9f0700000040414243444546471000404142434445464748494a4b4c4d4e4f1000505152535455565758595a5b5c5d5e5f cf2abb0e55a816ed4dbbd5a06adc54f1eccc7d3f135062d404e19c140bfaa259 aeadRun_16_16 "aead AAD and plaintext each exactly one block"
dk aead/chacha20poly1305.bf 808182838485868788898a8b8c8d8e8f909192939495969798999a9b9c9d9e9f07000000404142434445464700004000404142434445464748494a4b4c4d4e4f505152535455565758595a5b5c5d5e5f606162636465666768696a6b6c6d6e6f707172737475767778797a7b7c7d7e7f df3aab1e45b806fd5dabc5b07acc44e19191da6c5d54388985d38adc09df5dfa2effa95bc8eb384cd0b3d86496b63c870575c01dca1c1b3818ddffb46dc56526a3bc51ff51fe458434760962ba0d690d aeadRun_0_64 "aead plaintext exactly one ChaCha block"
dk aead/chacha20poly1305.bf 808182838485868788898a8b8c8d8e8f909192939495969798999a9b9c9d9e9f07000000404142434445464700004100404142434445464748494a4b4c4d4e4f505152535455565758595a5b5c5d5e5f606162636465666768696a6b6c6d6e6f707172737475767778797a7b7c7d7e7f80 df3aab1e45b806fd5dabc5b07acc44e19191da6c5d54388985d38adc09df5dfa2effa95bc8eb384cd0b3d86496b63c870575c01dca1c1b3818ddffb46dc565267cf71ef96ef8d3409d16f805340d14ccde aeadRun_0_65 "aead one byte into the second ChaCha block"
dk aead/chacha20poly1305.bf 808182838485868788898a8b8c8d8e8f909192939495969798999a9b9c9d9e9f0700000040414243444546470c0050515253c0c1c2c3c4c5c6c772004c616469657320616e642047656e746c656d656e206f662074686520636c617373206f66202739393a204966204920636f756c64206f6666657220796f75206f6e6c79206f6e652074697020666f7220746865206675747572652c2073756e73637265656e20776f756c642062652069742e d31a8d34648e60db7b86afbc53ef7ec2a4aded51296e08fea9e2b5a736ee62d63dbea45e8ca9671282fafb69da92728b1a71de0a9e060b2905d6a5b67ecd3b3692ddbd7f2d778b8c9803aee328091b58fab324e4fad675945585808b4831d7bc3ff4def08e4b7a9de576d26586cec64b61161ae10b594f09e26a7e902ecbd0600691 aeadRun_12_114 "aead RFC 8439 section 2.8.2"

# HASHCORE is the whole of the hash, and sha256 is now a wrapper round it.
# What only this can show is the two byte sources agreeing: the SAME message
# hashed entirely from memory, entirely from the wire, and split across both
# must give one digest. HMAC needs the memory side and sha256 the wire side.
dk sha256/hashcore.bf 0000030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000616263 ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad hashcoreRun_0_3 "hashcore 0 from memory and 3 from the wire"
dk sha256/hashcore.bf 0300000061626300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad hashcoreRun_3_0 "hashcore 3 from memory and 0 from the wire"
dk sha256/hashcore.bf 01000200610000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006263 ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad hashcoreRun_1_2 "hashcore 1 from memory and 2 from the wire"
dk sha256/hashcore.bf 0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855 hashcoreRun_0_0 "hashcore 0 from memory and 0 from the wire"
dk sha256/hashcore.bf 40000000000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 fdeab9acf3710362bd2658cdc9a29e8f9c757fcf9811603a8c447cd1d9151108 hashcoreRun_64_0 "hashcore 64 from memory and 0 from the wire"
dk sha256/hashcore.bf 1e002200000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001e1f202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f fdeab9acf3710362bd2658cdc9a29e8f9c757fcf9811603a8c447cd1d9151108 hashcoreRun_30_34 "hashcore 30 from memory and 34 from the wire"

# HMAC, RFC 4231. Case 6's key is 131 bytes, longer than a block, which is
# the path that hashes the key first; without it the other cases would all
# pass and that branch would never run.
dk sha256/hmac.bf 1400000008000b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004869205468657265 b0344c61d8db38535ca8afceaf0bf12b881dc200c9833da726e9376c2e32cff7 hmacRun_20_0_8 "hmac RFC 4231 case 1"
dk sha256/hmac.bf 1400080000000b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000048692054686572650000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 b0344c61d8db38535ca8afceaf0bf12b881dc200c9833da726e9376c2e32cff7 hmacRun_20_8_0 "hmac RFC 4231 case 1  message in memory"
dk sha256/hmac.bf 040000001c004a656665000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007768617420646f2079612077616e7420666f72206e6f7468696e673f 5bdcc146bf60754e6a042426089575c75a003f089d2739839dec58b964ec3843 hmacRun_4_0_28 "hmac RFC 4231 case 2"
dk sha256/hmac.bf 140000003200aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd 773ea91e36800e46854db8ebd09181a72959098b3ef8c122d9635514ced565fe hmacRun_20_0_50 "hmac RFC 4231 case 3"
dk sha256/hmac.bf 0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 b613679a0814d9ec772f95d778c35fc5ff1697c493715653c6c712144292c5ad hmacRun_0_0_0 "hmac an empty key and an empty message"
dk sha256/hmac.bf 2000030003000b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000061626300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000646566 612e2a39480bb7ddd90d9ac2d96b00e0745628c5336d781d0e9650525f4692ca hmacRun_32_3_3 "hmac split across both sources"

# SHA_256, FIPS 180_4. The published vectors are the empty message and abc;
# the rest straddle the padding boundary, which is where this construction
# goes wrong: fifty five bytes is the last message whose length still fits
# in its own block, fifty six is the first that needs a second one, and a
# whole block of message needs a second block that is padding alone.
dk sha256/sha256.bf 0000 e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855 sha256Run_0 "sha256 the empty message  FIPS"
dk sha256/sha256.bf 010061 ca978112ca1bbdcafac231b39a23dc4da786eff8147c4e72b9807785afee48bb sha256Run_1 "sha256 one byte"
dk sha256/sha256.bf 0300616263 ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad sha256Run_3 "sha256 abc  FIPS 180_4"
dk sha256/sha256.bf 3700000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f202122232425262728292a2b2c2d2e2f30313233343536 463eb28e72f82e0a96c0a4cc53690c571281131f672aa229e0d45ae59b598b59 sha256Run_55 "sha256 fifty five bytes  the last to fit one block"
dk sha256/sha256.bf 3800000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f202122232425262728292a2b2c2d2e2f3031323334353637 da2ae4d6b36748f2a318f23e7ab1dfdf45acdc9d049bd80e59de82a60895f562 sha256Run_56 "sha256 fifty six  the length no longer fits  two blocks"
dk sha256/sha256.bf 4000000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f fdeab9acf3710362bd2658cdc9a29e8f9c757fcf9811603a8c447cd1d9151108 sha256Run_64 "sha256 a whole block of message  two blocks in all"

# One round, and one schedule word. Both are pasted into sha256 sixty four
# and forty eight times over, so a fault in either is a fault in every
# digest; they are checked on their own where the failure is legible.
dk sha256/round.bf 67e6096a85ae67bb72f36e3c3af54fa57f520e518c68059babd9831f19cde05b80636261982f8a42 cdeb6a5d67e6096a85ae67bb72f36e3c22462afa7f520e518c68059babd9831f sha256RoundRun "sha256 round: the first round of the abc block"
dk sha256/round.bf 00000000000000000000000000000000000000000000000000000000000000000000000000000000 0000000000000000000000000000000000000000000000000000000000000000 sha256RoundRun "sha256 round: everything nought"
dk sha256/round.bf ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff f9fffffffffffffffffffffffffffffffaffffffffffffffffffffffffffffff sha256RoundRun "sha256 round: everything set"
dk sha256/round.bf 982f8a42982f8a42982f8a42982f8a42982f8a42982f8a42982f8a42982f8a4278563412f27871c6 c91239bc982f8a42982f8a42982f8a420c145a77982f8a42982f8a42982f8a42 sha256RoundRun "sha256 round: a repeated word with the last constant"
dk sha256/round.bf 38b4e652e44da7f2370d9e260e27136550a4a3a6d07f5c0c332f8b1224083fd22b902f8911e81818 2d0b3ec338b4e652e44da7f2370d9e269749ff8550a4a3a6d07f5c0c332f8b12 sha256RoundRun "sha256 round: a random round"
dk sha256/round.bf f8c99d5d5d9831957504d90e945de2e8f54ee781cc75f636d85099095aa300165a67036f9b540d6b 90973c41f8c99d5d5d9831957504d90ec1ec02ddf54ee781cc75f636d8509909 sha256RoundRun "sha256 round: a random round"
dk sha256/round.bf 8f0be21124179c3dd9f73817ce6e118d264aad6cb6dd210faf94acd3cf92c190237cb11f5d108cf2 f678e1f38f0be21124179c3dd9f73817839e0c5b264aad6cb6dd210faf94acd3 sha256RoundRun "sha256 round: a random round"
dk sha256/expand.bf 00000000000000000000000000000000 00000000 sha256ExpandRun "sha256 expand: all nought"
dk sha256/expand.bf ffffffffffffffffffffffffffffffff fcff3f20 sha256ExpandRun "sha256 expand: all set"
dk sha256/expand.bf 80636261000000000000000018000000 80637161 sha256ExpandRun "sha256 expand: the abc block's first expansion"
dk sha256/expand.bf 01000000010000000100000001000000 02e00002 sha256ExpandRun "sha256 expand: all one"
dk sha256/expand.bf 6d25cf734c49a1dd273e4d8fab5f5bdb 78008f97 sha256ExpandRun "sha256 expand: random"
dk sha256/expand.bf 8d1099ec05e8fdc7c1d734777648ab73 ef3c689a sha256ExpandRun "sha256 expand: random"
dk sha256/expand.bf bde201825045e4da32da5e96796b9d30 8fccfddc sha256ExpandRun "sha256 expand: random"


# HKDF, RFC 5869, all three published vectors. Each demands something the
# others do not: A.1 is the ordinary case with two turns of expand and the
# second truncated; A.3 has no salt, which the standard says means thirty
# two nought bytes and NOT a key of length nought; A.2 has an eighty byte
# salt, longer than a block, so HMAC hashes it first, and needs three turns.
dk sha256/hkdf.bf 0d0016000a002a00000102030405060708090a0b0c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f0f1f2f3f4f5f6f7f8f9000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 3cb25f25faacd57a90434f64d0362f2a2d2d0a90cf1a5a4c5db02d56ecc4c5bf34007208d5b887185865 hkdfRun_13_22_10_42 "hkdf RFC 5869 A.1"
dk sha256/hkdf.bf 0000160000002a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 8da4e775a563c18f715f802a063c5a31b8a11f5c5ee1879ec3454e5f3c738d2d9d201395faa4b61a96c8 hkdfRun_0_22_0_42 "hkdf RFC 5869 A.3  no salt and no info"
dk sha256/hkdf.bf 5000500050005200606162636465666768696a6b6c6d6e6f707172737475767778797a7b7c7d7e7f808182838485868788898a8b8c8d8e8f909192939495969798999a9b9c9d9e9fa0a1a2a3a4a5a6a7a8a9aaabacadaeaf0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f404142434445464748494a4b4c4d4e4f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b0b1b2b3b4b5b6b7b8b9babbbcbdbebfc0c1c2c3c4c5c6c7c8c9cacbcccdcecfd0d1d2d3d4d5d6d7d8d9dadbdcdddedfe0e1e2e3e4e5e6e7e8e9eaebecedeeeff0f1f2f3f4f5f6f7f8f9fafbfcfdfeff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 b11e398dc80327a1c8e7f78c596a49344f012eda2d4efad8a050cc4c19afa97c59045a99cac7827271cb41c65e590e09da3275600c2f09b8367793a9aca3db71cc30c58179ec3e87c14c01d5c1f3434f1d87 hkdfRun_80_80_80_82 "hkdf RFC 5869 A.2  an eighty byte salt  longer than a block"


echo
echo "== tier 5: declared contracts enforced =="
tmpc=$(mktemp -d)
printf "; IO none\n; TAPE MAP @0x00\n; three right\n  >>>\n; ASSERT ptr=5\n  +\n" > "$tmpc/bad.bf"
printf "; IO none\n; TAPE MAP @0x00\n; dirty a cell\n  >>>+<<<\n; ASSERT zero 0:5\n  +\n" > "$tmpc/dirty.bf"
run "contract checker catches a wrong pointer" sh -c "BFI_CONTRACTS=1 ./tools/bfi $tmpc/bad.bf </dev/null 2>/dev/null; test \$? -eq 4"
run "contract checker catches dirty scratch" sh -c "BFI_CONTRACTS=1 ./tools/bfi $tmpc/dirty.bf </dev/null 2>/dev/null; test \$? -eq 4"
run "contracts are inert without the flag" sh -c "./tools/bfi $tmpc/bad.bf </dev/null >/dev/null 2>&1"
rm -rf "$tmpc"
run "blockloop honours its declared contracts" sh -c "printf 000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f01000000000000090000004a00000000 | ./tools/hx -r | BFI_CONTRACTS=1 ./tools/bfi chacha20/blockloop.bf >/dev/null"
run "qrloop honours its declared contracts" sh -c "printf 1111111104030201436f8d9b67452301 | ./tools/hx -r | BFI_CONTRACTS=1 ./tools/bfi chacha20/qrloop.bf >/dev/null"
# The counter cells are stepped over by the read prologue rather than written,
# so "the counter is still nought" is a claim about the prologue that only the
# contract checker can test. Pinning the wrong counter would still produce a
# perfectly valid looking 32 bytes.
# The AEAD's own contracts are what caught its worst defect: it parked the two
# lengths at cells 48 and 50, which are INSIDE blockkeep's declared footprint,
# and blockkeep asserts that region clear on entry. The arithmetic was fine on
# the first block and would have gone wrong on the second. No output test saw it.
run "the AEAD honours its declared contracts" sh -c "printf 808182838485868788898a8b8c8d8e8f909192939495969798999a9b9c9d9e9f0700000040414243444546471000404142434445464748494a4b4c4d4e4f1000505152535455565758595a5b5c5d5e5f | ./tools/hx -r | BFI_CONTRACTS=1 ./tools/bfi aead/chacha20poly1305.bf >/dev/null"
run "add8 honours its declared contracts" sh -c "printf ffff | ./tools/hx -r | BFI_CONTRACTS=1 ./tools/bfi idiom/add8.bf >/dev/null"
run "hkdf honours its declared contracts" sh -c "printf 0d0016000a002a00000102030405060708090a0b0c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f0f1f2f3f4f5f6f7f8f9000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 | ./tools/hx -r | BFI_CONTRACTS=1 ./tools/bfi sha256/hkdf.bf >/dev/null"
run "hmac honours its declared contracts" sh -c "printf 1400000008000b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004869205468657265 | ./tools/hx -r | BFI_CONTRACTS=1 ./tools/bfi sha256/hmac.bf >/dev/null"
run "hashcore honours its declared contracts" sh -c "printf 000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000616263 | ./tools/hx -r | BFI_CONTRACTS=1 ./tools/bfi sha256/hashcore.bf >/dev/null"
run "sha256 honours its declared contracts" sh -c "printf 0300616263 | ./tools/hx -r | BFI_CONTRACTS=1 ./tools/bfi sha256/sha256.bf >/dev/null"
run "sha256 round honours its declared contracts" sh -c "printf 6a09e667bb67ae853c6ef372a54ff53a510e527f9b05688c1f83d9ab5be0cd1980636261982f8a42 | ./tools/hx -r | BFI_CONTRACTS=1 ./tools/bfi sha256/round.bf >/dev/null"
run "sha256 expand honours its declared contracts" sh -c "printf ffffffffffffffffffffffffffffffff | ./tools/hx -r | BFI_CONTRACTS=1 ./tools/bfi sha256/expand.bf >/dev/null"
run "and32 honours its declared contracts" sh -c "printf ffffffffffffffff | ./tools/hx -r | BFI_CONTRACTS=1 ./tools/bfi idiom/and32.bf >/dev/null"
run "rotr32 honours its declared contracts" sh -c "printf 7856341219 | ./tools/hx -r | BFI_CONTRACTS=1 ./tools/bfi idiom/rotr32.bf >/dev/null"
run "shr32 honours its declared contracts" sh -c "printf 7856341203 | ./tools/hx -r | BFI_CONTRACTS=1 ./tools/bfi idiom/shr32.bf >/dev/null"
run "rotl32 honours its declared contracts" sh -c "printf 7856341210 | ./tools/hx -r | BFI_CONTRACTS=1 ./tools/bfi chacha20/rotl32.bf >/dev/null"
run "blockkeep honours its declared contracts" sh -c "printf 000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f01000000000000090000004a00000000 | ./tools/hx -r | BFI_CONTRACTS=1 ./tools/bfi chacha20/blockkeep.bf >/dev/null"
run "keygen honours its declared contracts" sh -c "printf 808182838485868788898a8b8c8d8e8f909192939495969798999a9b9c9d9e9f000000000001020304050607 | ./tools/hx -r | BFI_CONTRACTS=1 ./tools/bfi aead/keygen.bf >/dev/null"
run "clamp honours its declared contracts" sh -c "printf ffffffffffffffffffffffffffffffff | ./tools/hx -r | BFI_CONTRACTS=1 ./tools/bfi poly1305/clamp.bf >/dev/null"
run "absorb honours its declared contracts" sh -c "printf 0123456789abcdef112233445566778802deadbeefcafebabe01020304050607ff01fedcba9876543210ffeeddccbbaa998801 | ./tools/hx -r | BFI_CONTRACTS=1 ./tools/bfi poly1305/absorb.bf >/dev/null"
# Two full blocks, not one: poly1305's glue hands absorb its operands and takes
# the accumulator back, and "absorb's frame is empty again" can only be false
# on the SECOND block. A single block vector runs the same code with an
# accumulator of nought and notices nothing.
run "poly1305 honours its declared contracts" sh -c "printf 85d6be7857556d337f4452fe42d506a80103808afb0db2fd4abff6af4149f51b2000414c57626d78838e99a4afbac5d0dbe6f1fc07121d28333e49545f6a75808b96 | ./tools/hx -r | BFI_CONTRACTS=1 ./tools/bfi poly1305/poly1305.bf >/dev/null"

echo
echo "== tier 7: metamorphic, which needs no oracle at all =="
# CONVENTIONS section 8 has declared this tier since the beginning and the suite
# has never had it. It earns its place here because the AEAD makes it cheap: the
# checks below pin NOTHING. They compare two separately written programs against
# each other, and a construction against its own inverse, so they stay true even
# if the vectors and the Cryptol spec are both wrong in the same way -- which is
# the one failure a dual oracle cannot see.
m7key=000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f
m7non=000000090000004a00000000
m7pt=4c616469657320616e642047656e746c
# With no AAD, the AEAD's ciphertext must be exactly what the stream cipher
# produces for the same key and nonce starting at counter one. Two programs
# written at different times from the same RFC; neither is the other's oracle
# by construction, so agreement is evidence.
run "the AEAD ciphertext is the stream cipher at counter one" sh -c '
  a=$(printf %s "$1$2""0000""1000""$3" | ./tools/hx -r \
      | ./tools/bfi aead/chacha20poly1305.bf | ./tools/hx | cut -c1-32)
  b=$(printf %s "$1""01000000""$2""1000""$3" | ./tools/hx -r \
      | ./tools/bfi chacha20/stream.bf | ./tools/hx)
  test "$a" = "$b"' _ "$m7key" "$m7non" "$m7pt"
# ChaCha20 is a stream cipher, so encrypting the ciphertext again with the same
# key and nonce returns the plaintext. The tag differs -- it is taken over a
# different message -- so only the ciphertext half is compared.
run "encrypting the ciphertext again returns the plaintext" sh -c '
  a=$(printf %s "$1$2""0000""1000""$3" | ./tools/hx -r \
      | ./tools/bfi aead/chacha20poly1305.bf | ./tools/hx | cut -c1-32)
  c=$(printf %s "$1$2""0000""1000""$a" | ./tools/hx -r \
      | ./tools/bfi aead/chacha20poly1305.bf | ./tools/hx | cut -c1-32)
  test "$c" = "$3"' _ "$m7key" "$m7non" "$m7pt"

echo
echo "== design proofs (Cryptol) =="
if (cd spec && CRYPTOLPATH=. cryptol -b /dev/stdin <<'ICRY' 2>&1 | grep -q "Q.E.D."
:l perm.cry
:prove looped_matches
ICRY
); then echo "PASS looped quarter round proved equal to the quarter round"; pass=$((pass+1)); else echo "FAIL looped quarter round proof"; fail=$((fail+1)); fi
if (cd spec && CRYPTOLPATH=. cryptol -b /dev/stdin <<'ICRY' 2>&1 | grep -q "Passed 2000 tests"
:l perm.cry
:set tests=2000
:check rotated_matches
ICRY
); then echo "PASS row rotated double round checked against the double round"; pass=$((pass+1)); else echo "FAIL row rotated double round check"; fail=$((fail+1)); fi

# reducep136 folded twice until a mutation showed the second fold changed no
# answer any vector could see. This is why: after one fold a 17 byte value is
# under 2p, and the tail reduces anything under 2p.
if (cd spec && CRYPTOLPATH=. cryptol -b /dev/stdin <<'ICRY' 2>&1 | grep -q "Q.E.D."
:l perm.cry
:prove one_fold_suffices
ICRY
); then echo "PASS one fold proved sufficient for reducep136"; pass=$((pass+1)); else echo "FAIL one fold proof"; fail=$((fail+1)); fi

# and the companion, which must be REFUTED: without it, one_fold_suffices could
# be a claim that would hold whatever we deleted. A property that cannot fail is
# not evidence, so this asks for the counterexample and fails if none is found.
if (cd spec && CRYPTOLPATH=. cryptol -b /dev/stdin <<'ICRY' 2>&1 | grep -q "Counterexample"
:l perm.cry
:prove tail_alone_is_not_enough
ICRY
); then echo "PASS dropping the fold as well is refuted by counterexample"; pass=$((pass+1)); else echo "FAIL the refutation did not come"; fail=$((fail+1)); fi

# The general Poly1305 oracle and the longhand one are two formulations of the
# same thing. An oracle only ever compared against itself proves nothing, so
# they are compared against each other.
if (cd spec && CRYPTOLPATH=. cryptol -b /dev/stdin <<'ICRY' 2>&1 | grep -q "Passed 2000 tests"
:l bfsodium.cry
:set tests=2000
:check longhand_agrees_with_general
ICRY
); then echo "PASS the two Poly1305 oracles agree with each other"; pass=$((pass+1)); else echo "FAIL the Poly1305 oracles disagree"; fail=$((fail+1)); fi

# absorbRun could be wrong in exactly the way the brainfuck is wrong and the
# two would still agree, so it is also required to reach the published section
# 2.5.2 tag by another route: folded over that message's three blocks, with the
# tag finished as the RFC finishes it. poly1305Run34 spells the same
# computation out longhand and neither is built from the other.
if (cd spec && CRYPTOLPATH=. cryptol -b /dev/stdin <<'ICRY' 2>&1 | grep -q "Passed 2000 tests"
:l bfsodium.cry
:set tests=2000
:check absorb_folds_to_the_rfc_tag
ICRY
); then echo "PASS absorb folded over the blocks reaches the RFC tag"; pass=$((pass+1)); else echo "FAIL absorb does not fold to the RFC tag"; fail=$((fail+1)); fi
# The adder's two identities, proved over every one of the 65536 pairs rather
# than sampled: the carry is bit 7 of the halves added, and the sum comes back
# from those same halves. The brainfuck rests on both.
if (cd spec && CRYPTOLPATH=. cryptol -b /dev/stdin <<'ICRY' 2>&1 | grep -c "Q.E.D." | grep -q 2
:l perm.cry
:prove add8_carry_is_bit7
:prove add8_sum_from_halves
ICRY
); then echo "PASS the adder's carry and sum identities proved"; pass=$((pass+1)); else echo "FAIL the adder's identities"; fail=$((fail+1)); fi

# and the companion that must be REFUTED, so the first is not a claim that
# would hold whatever was deleted: drop the term for both low bits set and the
# carry is wrong for 128 of the pairs.
if (cd spec && CRYPTOLPATH=. cryptol -b /dev/stdin <<'ICRY' 2>&1 | grep -q "Counterexample"
:l perm.cry
:prove add8_low_bit_term_is_needed
ICRY
); then echo "PASS dropping the low bit term is refuted by counterexample"; pass=$((pass+1)); else echo "FAIL the refutation did not come"; fail=$((fail+1)); fi

echo
echo "== summary =="
echo "passed $pass, failed $fail"
[ "$fail" -eq 0 ] || exit 1
