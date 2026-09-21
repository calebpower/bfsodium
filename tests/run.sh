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
# TIER 1
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
# A byte written by '.' must reach the far end before the program blocks or
# ends, and every other check here is blind to whether it does: they all read
# the output AFTER the program has exited, by which time stdio has flushed
# either way.
#
# It was not true. bfi used stdio with no setvbuf, so with stdout to a pipe it
# buffered 4 KiB and nothing left the process until the final fflush. A
# one-shot primitive never noticed. Anything holding a CONVERSATION with a bf
# program over a pipe deadlocks instantly and silently: the request sits in
# the buffer, the far end blocks reading a request that was never sent, the
# program blocks on ',' for a reply that cannot come, and there is no output
# and no core to look at.
#
# The program below writes one byte and then spins forever, so the byte can
# only be observed if it was flushed when it was written. timeout kills it
# with SIGTERM, which does not flush -- which is exactly the point.
printf '%s' '++++++++[>++++++++<-]>+.[]' > "$tmp/spin.bf"
run "a written byte reaches a pipe before the program ends" sh -c "
    got=\$(timeout 2 ./tools/bfi $tmp/spin.bf </dev/null | ./tools/hx)
    test \"\$got\" = 41"
rm -rf "$tmp"

echo
# TIER 9
echo "== tier 9: legibility and portability =="
run "bfstyle self-test" ./tools/bfstyle --selftest
run "bflint self-test" ./tools/bflint --selftest
run "bffoot self-test" ./tools/bffoot --selftest
run "bftable self-test" perl tools/bftable.pl --selftest
run "bftier self-test" perl tools/bftier.pl --selftest
# Every committed ROUTINE, not a named list of directories. index/ sat outside
# the old "chacha20 poly1305" globs and so was linted, styled and
# footprint-checked by nothing at all -- it passes when run by hand, which is
# exactly the state in which a regression goes unseen. A new routine directory
# is covered by construction.
#
# programs/ IS THE ONE EXCLUSION AND IT IS NOT AN EXEMPTION. A program is bare
# brainfuck -- nothing but the eight instructions -- because it must run under
# ANY conforming interpreter, and ";" comments are an extension of the pinned
# one. A routine is COMMENTED brainfuck, because its legibility floor is this
# project's central promise. Two portability claims, two legibility rules, and
# applying the routine rule to a program would demand comments that would break
# the program's own claim.
#
# So programs/ is covered by tier 11 instead, with brainstem's bsbf proving the
# bare-brainfuck property that its skeleton and its own README stand behind.
# Nothing is uncovered; the coverage is by a different rule.
bf_routines() { for f in */*.bf; do case "$f" in programs/*) ;; *) echo "$f" ;; esac; done; }

for f in $(bf_routines); do run "lint $f" ./tools/bflint "$f"; done
# TIER 9a 9b
for f in $(bf_routines); do run "style $f" ./tools/bfstyle "$f"; done
# A routine is pasted into its callers on the strength of its INTERFACE line, so
# that line has to be a fact and not a promise. stagger understated its footprint
# by four cells, quietly borrowed them from the block function's saved copy of
# the original state, and put one wrong word in every block; the arithmetic was
# perfect and every other tier passed. This is the check that saw it.
# TIER 9d
for f in $(bf_routines); do run "footprint $f" ./tools/bffoot "$f"; done

# bffoot returns success on a file with no INTERFACE line -- it declines to
# judge what does not claim to be pasteable, which is right, but it means
# "footprint" above is a pass that asserts nothing on those files. So the set of
# them is pinned. chacha20/stream.bf is a whole program rather than a routine,
# and index/ is the unpasted escape hatch; a NEW routine that forgets its
# INTERFACE line joins this list and fails here, instead of collecting a
# vacuous PASS from the loop above.
# TIER 9d
run "the files declaring no INTERFACE are exactly the known ones" sh -c '
    # The exclusion is inlined rather than calling bf_routines, because this
    # check runs under sh -c and a CHILD SHELL DOES NOT INHERIT FUNCTIONS. The
    # loops above are at top level and may call it; this one may not, and the
    # failure it produced was the quiet kind -- an empty list comparing unequal
    # to the pinned one, which reads as "a routine lost its INTERFACE line".
    got=$(for f in */*.bf; do
              case "$f" in programs/*) continue ;; esac
              grep -q "^; INTERFACE" "$f" || echo "$f"
          done)
    want="aead/chacha20poly1305.bf
chacha20/stream.bf
index/fetch8.bf
index/fetchword.bf
index/store8.bf
sha256/hkdf.bf
sha256/kdfctr.bf
sha256/kdffb.bf
sha256/sha256.bf
sha512/hkdf.bf
sha512/sha384.bf
sha512/sha512.bf
sha512/sha512_224.bf
sha512/sha512_256.bf"
    test "$got" = "$want"'

# The committed brainfuck must be exactly what its skeleton expands to. Nothing
# is hand-edited downstream of bfexpand, and this is the check that says so --
# it is also what caught bfexpand dropping all but the first line of a
# multi-line read prologue, which pasted 47 stray reads into a caller.
# TIER 9c
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
# TIER 9e
run "HANDOFF's routine table describes the tree" perl tools/bftable.pl
# The tier table is the other half, and the reason it exists is that tier 6
# sat in the old combined table in the same voice as the tiers that ran. A
# table saying what you want and what you have in one column drifts the
# moment those differ, and they almost always differ.
run "HANDOFF's tier table describes the suite" perl tools/bftier.pl

# There is ONE definition of the toolchain, in tools/guest-setup.sh, and both
# lanes run it: reaper's [build] calls it with no argument, the Containerfile
# calls it with --toolchain. The moment the Containerfile grows its own apt
# line or its own Cryptol version there are two definitions, and the fallback
# lane starts passing what the gate would fail -- silently, because a container
# that installs a different z3 still runs every test and still says PASS. That
# is the failure this check exists to make loud.
# TIER 10
run "no lane defines a toolchain of its own" sh -c '
    rc=0
    for f in Containerfile .reaper.toml tools/container-test.sh .github/workflows/*.yml; do
        [ -e "$f" ] || continue
        # Whole-line comments are stripped first, so the ban does not trip
        # over the prose explaining the ban. The sibling project learned that
        # the hard way: its version of this check read a Containerfile whole
        # and failed on a comment saying there was deliberately no apt-get
        # line. A check that punishes its own documentation teaches the next
        # person to delete the documentation.
        body=$(sed -e "s/^[[:space:]]*#.*//" "$f")
        printf "%s" "$body" | grep -q "guest-setup.sh" || {
            echo "$f runs no guest-setup.sh"; rc=1; }
        printf "%s" "$body" | grep -Eq "apt-get|apt install|CRYPTOL_VERSION|cryptol/releases" && {
            echo "$f defines a toolchain of its own"; rc=1; }
    done
    exit $rc'

# THE GUESTS AND THE BRANCHES MUST BE THE SAME SET, and this check is why the
# "# GUEST" markers in guest-setup.sh are not decoration. reaper names guests
# ("freebsd-15.1"); the script branches on uname ("FreeBSD"); nothing in
# either file relates the two, so the correspondence is DECLARED in a marker
# and compared here.
#
# It matters now in a way it did not with one guest. Adding a guest to the
# tenant without a branch here means reaper provisions it with whatever arm
# happens to match -- and a FreeBSD guest falling into the apt arm fails in
# the package manager, which reads as a broken image rather than a missing
# branch. The sibling project has carried this check since M0 for the same
# reason.
run "the declared guests are exactly the ones guest-setup knows" sh -c '
    declared=$(sed -n "s/^# GUEST \([^ ]*\) .*/\1/p" tools/guest-setup.sh | sort)
    tenant=$(sed -n "s/^guests *= *\[\(.*\)\].*/\1/p" .reaper.toml \
             | tr -d "\" " | tr "," "\n" | grep . | sort)
    if [ "$declared" != "$tenant" ]; then
        echo "guest-setup declares: $declared"
        echo ".reaper.toml wants:   $tenant"
        exit 1
    fi
    exit 0'

echo
# TIER 2 4
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
# ROTR64, the 64 bit widening, and the piece that unlocks a tier rather than
# a primitive: SHA_384, SHA_512 and both SHA_512/t work on 64 bit words, and
# so does Keccak, whose rho step is nothing but 64 bit rotations. The counts
# are the edges at one and sixty three, a whole byte, and 28, 34 and 39 --
# which are the three rotations SHA_512 Sigma1 asks for, so the routine is
# exercised at the widths its first consumer actually needs.
dk idiom/rotr64.bf 010000000000000001 0000000000000080 rotr64nRun "rotr64 by 1  the edge at one"
dk idiom/rotr64.bf 010000000000000008 0000000000000001 rotr64nRun "rotr64 by 8  a whole byte"
dk idiom/rotr64.bf 01000000000000003f 0200000000000000 rotr64nRun "rotr64 by 63  the other edge"
dk idiom/rotr64.bf efcdab896745230107 9b5713cf8a4602de rotr64nRun "rotr64 by 7  seven, every bit crossing"
dk idiom/rotr64.bf efcdab89674523011c 78563412f0debc9a rotr64nRun "rotr64 by 28  SHA_512 Sigma1"
dk idiom/rotr64.bf efcdab896745230122 59d148c07bf36ae2 rotr64nRun "rotr64 by 34  SHA_512 Sigma1"
dk idiom/rotr64.bf efcdab896745230127 8a4602de9b5713cf rotr64nRun "rotr64 by 39  SHA_512 Sigma1"
dk idiom/rotr64.bf ffffffffffffffff0d ffffffffffffffff rotr64nRun "rotr64 by 13  every bit set is unchanged"
dk idiom/rotr64.bf 000000000000008001 0000000000000040 rotr64nRun "rotr64 by 1  the top bit alone"

# ROTL64 is the direction Keccak's rho step needs and the direction brainfuck
# is bad at, so it is built out of the one it is good at: whole byte turns,
# then rotr64 for the one to eight bits left over. The counts below pin both
# ends of that split -- n = 0 and n = 56 take eight bit steps and are the
# dearest, n = 7 takes one and is the cheapest -- plus two of the twenty five
# offsets FIPS 202 gives rho.
dk idiom/rotl64.bf efcdab896745230100 efcdab8967452301 rotl64nRun "rotl64 by nought  the identity"
dk idiom/rotl64.bf efcdab896745230101 de9b5713cf8a4602 rotl64nRun "rotl64 by 1  the edge at one"
dk idiom/rotl64.bf efcdab896745230107 80f7e6d5c4b3a291 rotl64nRun "rotl64 by 7  one bit step  the cheapest path"
dk idiom/rotl64.bf efcdab896745230108 01efcdab89674523 rotl64nRun "rotl64 by 8  a whole byte and no bit left over"
dk idiom/rotl64.bf efcdab896745230138 cdab8967452301ef rotl64nRun "rotl64 by 56  eight byte turns  the dearest path"
dk idiom/rotl64.bf efcdab89674523013f f7e6d5c4b3a29180 rotl64nRun "rotl64 by 63  the other edge"
dk idiom/rotl64.bf efcdab89674523013e 7bf36ae259d148c0 rotl64nRun "rotl64 by 62  Keccak rho at x two y nought"
dk idiom/rotl64.bf efcdab896745230124 78563412f0debc9a rotl64nRun "rotl64 by 36  Keccak rho at x nought y one"
dk idiom/rotl64.bf ffffffffffffffff0d ffffffffffffffff rotl64nRun "rotl64 by 13  every bit set is unchanged"
dk idiom/rotl64.bf 000000000000008001 0100000000000000 rotl64nRun "rotl64 by 1  the top bit alone wraps to the bottom"
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
# SHR64, which is idiom/rotr64 with exactly one line changed -- the bit that
# falls out of the bottom is discarded instead of wrapped -- and which
# SHA_512 needs alongside the rotation, since its sigma functions are two
# rotations and one shift exclusive-ored together. Every vector here starts
# from a word whose low bits are set, so a routine that forgot to throw c0
# away answers differently rather than passing by symmetry.
dk idiom/shr64.bf 000000000000008001 0000000000000040 shr64nRun "shr64 by 1  the edge at one"
dk idiom/shr64.bf 000000000000008008 0000000000008000 shr64nRun "shr64 by 8  a whole byte"
dk idiom/shr64.bf 00000000000000803f 0100000000000000 shr64nRun "shr64 by 63  the other edge  the top bit to the bottom"
dk idiom/shr64.bf efcdab896745230107 9b5713cf8a460200 shr64nRun "shr64 by 7  SHA_512 sigma0  and every bit crossing"
dk idiom/shr64.bf efcdab896745230106 37af269e158d0400 shr64nRun "shr64 by 6  SHA_512 sigma1"
dk idiom/shr64.bf 010000000000000001 0000000000000000 shr64nRun "shr64 by 1  the lone low bit is DISCARDED not wrapped"
dk idiom/shr64.bf ffffffffffffffff0d ffffffffffff0700 shr64nRun "shr64 by 13  every bit set grows zeros at the top"
dk idiom/shr64.bf efcdab89674523013f 0000000000000000 shr64nRun "shr64 by 63  all but the top bit falls out"
dk idiom/shr64.bf efcdab896745230108 cdab896745230100 shr64nRun "shr64 by 8  a whole byte of a real word"
# XOR64, the 64 bit widening of chacha20/xor32. The XOR8 frame keeps its
# shape, so every arrow inside the bit step is the same arrow and only the
# three journeys that leave the frame differ. The pairs below are the ones
# that separate exclusive or from and: a word against its complement is all
# ones here and nought there, and a word against itself is the reverse.
dk idiom/xor64.bf ffffffffffffffff0000000000000000 ffffffffffffffff xor64Run "xor64 all ones against nought"
dk idiom/xor64.bf ffffffffffffffffffffffffffffffff 0000000000000000 xor64Run "xor64 all ones against all ones"
dk idiom/xor64.bf 0f0f0f0f0f0f0f0ff0f0f0f0f0f0f0f0 ffffffffffffffff xor64Run "xor64 nibbles that share no bit"
dk idiom/xor64.bf efcdab89674523011032547698badcfe ffffffffffffffff xor64Run "xor64 a word against its complement"
dk idiom/xor64.bf 55aa55aa55aa55aaaa55aa55aa55aa55 ffffffffffffffff xor64Run "xor64 alternating bits"
dk idiom/xor64.bf efcdab8967452301efcdab8967452301 0000000000000000 xor64Run "xor64 a real word against itself"
dk idiom/xor64.bf 00000000000000000000000000000000 0000000000000000 xor64Run "xor64 nought against nought"
dk idiom/xor64.bf 8040201008040201ffffffffffffffff 7fbfdfeff7fbfdfe xor64Run "xor64 one bit per byte against all ones"
# AND64, the same widening again. The AND8 frame is unchanged down to the
# character and so is every arrow inside the bit step; only the ASSERT
# numbers move, because those are absolute. The pairs are xor64's, so the
# two answer sets can be read against each other.
dk idiom/and64.bf ffffffffffffffff0000000000000000 0000000000000000 and64Run "and64 all ones against nought"
dk idiom/and64.bf ffffffffffffffffffffffffffffffff ffffffffffffffff and64Run "and64 all ones against all ones"
dk idiom/and64.bf 0f0f0f0f0f0f0f0ff0f0f0f0f0f0f0f0 0000000000000000 and64Run "and64 nibbles that share no bit"
dk idiom/and64.bf efcdab89674523011032547698badcfe 0000000000000000 and64Run "and64 a word against its complement"
dk idiom/and64.bf 55aa55aa55aa55aaaa55aa55aa55aa55 0000000000000000 and64Run "and64 alternating bits"
dk idiom/and64.bf efcdab8967452301efcdab8967452301 efcdab8967452301 and64Run "and64 a real word against itself"
dk idiom/and64.bf 00000000000000000000000000000000 0000000000000000 and64Run "and64 nought against nought"
dk idiom/and64.bf 8040201008040201ffffffffffffffff 8040201008040201 and64Run "and64 one bit per byte against all ones"
# ADD64, the last of the set and the easy one: a ripple carry does not care
# how long the chain is, so this is chacha20/add32 with eight byte blocks
# instead of four, the same idiom/add8 paste and the same carry cell walking
# along. It gets four vectors the bitwise pair do not need, because it is
# the only one of the three that can be wrong in a way that depends on the
# byte to its right.
dk idiom/add64.bf ffffffffffffffff0000000000000000 ffffffffffffffff add64Run "add64 all ones against nought"
dk idiom/add64.bf ffffffffffffffffffffffffffffffff feffffffffffffff add64Run "add64 all ones against all ones"
dk idiom/add64.bf 0f0f0f0f0f0f0f0ff0f0f0f0f0f0f0f0 ffffffffffffffff add64Run "add64 nibbles that share no bit"
dk idiom/add64.bf efcdab89674523011032547698badcfe ffffffffffffffff add64Run "add64 a word against its complement"
dk idiom/add64.bf 55aa55aa55aa55aaaa55aa55aa55aa55 ffffffffffffffff add64Run "add64 alternating bits"
dk idiom/add64.bf efcdab8967452301efcdab8967452301 de9b5713cf8a4602 add64Run "add64 a real word against itself"
dk idiom/add64.bf 00000000000000000000000000000000 0000000000000000 add64Run "add64 nought against nought"
dk idiom/add64.bf 8040201008040201ffffffffffffffff 7f40201008040201 add64Run "add64 one bit per byte against all ones"
dk idiom/add64.bf ff000000000000000100000000000000 0001000000000000 add64Run "add64 one carry across one boundary"
dk idiom/add64.bf ffffffffffffffff0100000000000000 0000000000000000 add64Run "add64 the carry cascades the whole way and is dropped"
dk idiom/add64.bf 12000000000000003400000000000000 4600000000000000 add64Run "add64 18 plus 52"
dk idiom/add64.bf efcdab89674523011111111111111111 00dfbc9a78563412 add64Run "add64 mixed"

dk chacha20/rotl32.bf 0100000001 02000000 rotl32nRun "rotl32 by 1"
dk chacha20/rotl32.bf 0100000008 00010000 rotl32nRun "rotl32 by 8"
dk chacha20/rotl32.bf 7856341210 34127856 rotl32nRun "rotl32 by 16"
dk chacha20/rotl32.bf 0000008001 01000000 rotl32nRun "rotl32 top bit wraps"
dk chacha20/rotl32.bf 785634120c 23816745 rotl32nRun "rotl32 by 12"
dk chacha20/rotl32.bf 7856341207 093c2b1a rotl32nRun "rotl32 by 7"

# ROTL32 no longer rotates left at all: whole BYTE turns, which are only moves,
# and then one right rotation of fewer than eight bits. These three cover the
# paths the four ChaCha counts do not. 0 is the identity and takes the branch
# for a bit part of nought with no byte turn either; 24 takes that branch with
# three turns; 31 is the far end of the bit part, and both it and 0 are counts
# nothing in this library ever asks for, which is the reason to pin them.
dk chacha20/rotl32.bf 1234567800 12345678 rotl32nRun "rotl32 by 0  the identity"
dk chacha20/rotl32.bf 1234567818 34567812 rotl32nRun "rotl32 by 24  three whole byte turns and no bits"
dk chacha20/rotl32.bf 123456781f 091a2b3c rotl32nRun "rotl32 by 31  the far end of the bit part"

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
# Five times the part above the split is a TWO byte addend, and these two pin
# the boundary between its bytes: 51 times five is 255 and 52 times five is 260,
# so a top byte of 0xcf must leave the high byte of the addend clear and 0xd0
# must set it. Every vector above is either far from that boundary or lands on
# the carrying side of it, so a carry that fired one step early or late would
# pass all five.
dk poly1305/fold136.bf ffffffffffffffffffffffffffffffffcf fe00000000000000000000000000000004 fold136Run "fold the largest part that does not carry"
dk poly1305/fold136.bf ffffffffffffffffffffffffffffffffd0 0301000000000000000000000000000001 fold136Run "fold the smallest part that carries"

# The ripple the fold now uses instead of a seventeen byte add: the first draft
# of it was a loop that set its own condition, so it carried into the same byte
# twice and then stopped. These two walk a carry a known distance and stop it
# at a known byte, which is what that draft could not do; the all-ones vector
# above catches it too, but only by accident of every byte being 255.
dk poly1305/fold136.bf fbff000000000000000000000000000004 0000010000000000000000000000000000 fold136Run "fold a carry that stops in the third byte"
dk poly1305/fold136.bf fbffffffffffffffff0000000000000008 0500000000000000000100000000000000 fold136Run "fold a carry that walks nine bytes and stops"

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
# The turns are nested now, seventeen bytes of eight bits, and the answer is
# folded once per byte rather than once per set bit. These two pin that shape.
# p minus one is almost all 0xff, so every byte of the multiplier has all eight
# bits set and the fold is asked to absorb eight adds of a near maximal value;
# and a full byte in the MIDDLE of the multiplier fails if the byte slide is
# off, where a low or a top byte would not.
dk poly1305/mulmod136.bf faffffffffffffffffffffffffffffff03faffffffffffffffffffffffffffffff03 0100000000000000000000000000000000 mulmod136Run "mulmod p minus one squared is one"
dk poly1305/mulmod136.bf faffffffffffffffffffffffffffffff030000000000000000ff0000000000000000 fbffffffffffffff00ffffffffffffff03 mulmod136Run "mulmod a full byte in the middle of b"

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
# SHA-512 expand, the same recurrence as sha256/expand with six different
# counts and eight byte words. The taps are chosen the way the 32 bit ones
# were, plus one the smaller routine did not need: the top bit alone in
# every tap, which is where a rotation that forgot to wrap and a shift that
# forgot to discard would answer the same thing.
dk sha512/expand.bf 0000000000000000000000000000000000000000000000000000000000000000 0000000000000000 sha512ExpandRun "sha512 expand: all nought"
dk sha512/expand.bf ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff fcffffffffffff05 sha512ExpandRun "sha512 expand: all set"
dk sha512/expand.bf 0100000000000000010000000000000001000000000000000100000000000000 0a00000000200081 sha512ExpandRun "sha512 expand: all one"
dk sha512/expand.bf 0000000080636261000000000000000000000000000000001800000000000000 c000000080636561 sha512ExpandRun "sha512 expand: the abc block's first expansion"
dk sha512/expand.bf 0000000000000080000000000000008000000000000000800000000000000080 0400000000108043 sha512ExpandRun "sha512 expand: the top bit alone in each tap"
dk sha512/expand.bf 3454dc047afd91d0982073702e56532427a199542ca2bce381ff786935bda15c 63ade34d5f43233a sha512ExpandRun "sha512 expand: random"
dk sha512/expand.bf bdcf6eedb9cda49fb2bcd167b11052c829846b2bd9885c38bdeac63d849da53d 7dca8bc6df3201e0 sha512ExpandRun "sha512 expand: random"
dk sha512/expand.bf 75372a013b3272d3a20cc1bfe1ea6e199bc9c17f75dca78f3cae186901e4a81f cf04eecf6ed5b4fa sha512ExpandRun "sha512 expand: random"
# SHA-512 round, the same wiring as sha256/round with six different big
# sigma counts and eight byte words. The first vector is the first round
# of the abc block  so the routine is checked against the standard's own
# worked example before it is checked against anything generated.
dk sha512/round.bf 08c9bcf367e6096a3ba7ca8485ae67bb2bf894fe72f36e3cf1361d5f3af54fa5d182e6ad7f520e511f6c3e2b8c68059b6bbd41fbabd9831f79217e1319cde05b000000008063626122ae28d7982f8a42 f5ddfcbcb8ceaff608c9bcf367e6096a3ba7ca8485ae67bb2bf894fe72f36e3c911fb57a3402cb58d182e6ad7f520e511f6c3e2b8c68059b6bbd41fbabd9831f sha512RoundRun "sha512 round: the first round of the abc block"
dk sha512/round.bf 0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 sha512RoundRun "sha512 round: everything nought"
dk sha512/round.bf ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff f9fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffaffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff sha512RoundRun "sha512 round: everything set"
dk sha512/round.bf efcdab8967452301efcdab8967452301efcdab8967452301efcdab8967452301efcdab8967452301efcdab8967452301efcdab8967452301efcdab896745230100000000000000800100000000000000 e080c9dc695b32b2efcdab8967452301efcdab8967452301efcdab896745230135bf4ad059e16cfaefcdab8967452301efcdab8967452301efcdab8967452301 sha512RoundRun "sha512 round: a repeated word"
dk sha512/round.bf 38b4e652e44da7f2370d9e260e27136550a4a3a6d07f5c0c332f8b1224083fd22b902f8911e81818f8c99d5d5d9831957504d90e945de2e8f54ee781cc75f636d85099095aa300165a67036f9b540d6b fbbd0e28b2d0e7ab38b4e652e44da7f2370d9e260e27136550a4a3a6d07f5c0c5705bbac284598272b902f8911e81818f8c99d5d5d9831957504d90e945de2e8 sha512RoundRun "sha512 round: a random round"
dk sha512/round.bf 8f0be21124179c3dd9f73817ce6e118d264aad6cb6dd210faf94acd3cf92c190237cb11f5d108cf25930263938b370a1b5769fa0f1483f95a90d9df2f130d60fcf04bd93f50ae69514da8c659ce2b10c 7739351817c337388f0be21124179c3dd9f73817ce6e118d264aad6cb6dd210ff1325ccd39f86b69237cb11f5d108cf25930263938b370a1b5769fa0f1483f95 sha512RoundRun "sha512 round: a random round"
dk sha512/round.bf ccdaebf990d19838b0d7ec0b3e97818ecb96c4dbadbe172296d5234a42b24c6ba4e6ed24ec636a8ac0a1271e5866279238aaf84e58056d8f2fa8edd094ba97ae8b15442ee2db611a91bfe39469733a92 30c920237b134ba3ccdaebf990d19838b0d7ec0b3e97818ecb96c4dbadbe172236ab7d713ba0d162a4e6ed24ec636a8ac0a1271e5866279238aaf84e58056d8f sha512RoundRun "sha512 round: a random round"
# SHA-512 over the wire. The lengths are the ones that matter: nought,
# one, the standard's own abc and 448 bit examples, and the three around
# the padding boundary -- 111 is the last message that leaves room for a
# sixteen byte length, 112 is the first that does not, and 128 is a whole
# block. SHA-256's boundary is at 55/56 for an eight byte length; this is
# the same test moved to where SHA-512 puts it.
dk sha512/sha512.bf 0000 cf83e1357eefb8bdf1542850d66d8007d620e4050b5715dc83f4a921d36ce9ce47d0d13c5d85f2b0ff8318d2877eec2f63b931bd47417a81a538327af927da3e sha512Run_0 "sha512 the empty message  FIPS"
dk sha512/sha512.bf 010061 1f40fc92da241694750979ee6cf582f2d5d7d28e18335de05abc54d0560e0f5302860c652bf08d560252aa5e74210546f369fbbbce8c12cfc7957b2652fe9a75 sha512Run_1 "sha512 one byte"
dk sha512/sha512.bf 0300616263 ddaf35a193617abacc417349ae20413112e6fa4e89a97ea20a9eeee64b55d39a2192992a274fc1a836ba3c23a3feebbd454d4423643ce80e2a9ac94fa54ca49f sha512Run_3 "sha512 abc  FIPS 180_4"
dk sha512/sha512.bf 38006162636462636465636465666465666765666768666768696768696a68696a6b696a6b6c6a6b6c6d6b6c6d6e6c6d6e6f6d6e6f706e6f7071 204a8fc6dda82f0a0ced7beb8e08a41657c16ef468b228a8279be331a703c33596fd15c13b1b07f9aa1d3bea57789ca031ad85c7a71dd70354ec631238ca3445 sha512Run_56 "sha512 the FIPS 180_4 four hundred and forty eight bit example"
dk sha512/sha512.bf 6f00000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f404142434445464748494a4b4c4d4e4f505152535455565758595a5b5c5d5e5f606162636465666768696a6b6c6d6e a1a111449b198d9b1f538bad7f3fc1022b3a5b1a5e90a0bc860de8512746cbc31599e6c834de3a3235327af0b51ff57bf7acf1974a73014d9c3953812edc7c8d sha512Run_111 "sha512 a hundred and eleven bytes  the last to fit one block"
dk sha512/sha512.bf 7000000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f404142434445464748494a4b4c4d4e4f505152535455565758595a5b5c5d5e5f606162636465666768696a6b6c6d6e6f c5fbd731d19d2ae1180f001be72c2c1aaba1d7b094b3748880e24593b8e117a750e11c1bd867cc2f96dace8c8b74abd2d5c4f236be444e77d30d1916174070b9 sha512Run_112 "sha512 a hundred and twelve  the length no longer fits  two blocks"
dk sha512/sha512.bf 8000000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f404142434445464748494a4b4c4d4e4f505152535455565758595a5b5c5d5e5f606162636465666768696a6b6c6d6e6f707172737475767778797a7b7c7d7e7f 1dffd5e3adb71d45d2245939665521ae001a317a03720a45732ba1900ca3b8351fc5c9b4ca513eba6f80bc7b1d1fdad4abd13491cb824d61b08d8c0e1561b3f7 sha512Run_128 "sha512 a whole block of message  two blocks in all"
# SHA-384 and both SHA-512/t are sha512/hashcore with eight other initial
# words and a shorter answer: the head writes H itself and raises the flag at
# @0x21a, and the core leaves it alone. Four lengths each, the same four
# SHA-512 itself is pinned at -- nothing, FIPS 180-4's "abc", the last length
# that fits one block, and the first that does not. The SHA-512/t words are
# DERIVED in the spec rather than transcribed, because the first attempt at
# SHA-512/256's H4 had one bit wrong and only the third party saw it.


dk sha512/sha384.bf 0000 38b060a751ac96384cd9327eb1b1e36a21fdb71114be07434c0cc7bf63f6e1da274edebfe76f65fbd51ad2f14898b95b sha384Run_0 "sha384 of nothing"
dk sha512/sha384.bf 0300616263 cb00753f45a35e8bb5a03d699ac65007272c32ab0eded1631a8b605a43ff5bed8086072ba1e7cc2358baeca134c825a7 sha384Run_3 "sha384 of abc  FIPS 180_4's own vector"
dk sha512/sha384.bf 6f000724415e7b98b5d2ef0c294663809dbad7f4112e4b6885a2bfdcf91633506d8aa7c4e1fe1b3855728facc9e603203d5a7794b1ceeb0825425f7c99b6d3f00d2a4764819ebbd8f5122f4c6986a3c0ddfa1734516e8ba8c5e2ff1c39567390adcae704213e5b7895b2cfec092643607d 423af157fd18d3385835d24a52e6f51e4b3823b36d37efdbf249c31a99e43dbd86bba18df0e32ab747573bde1c896795 sha384Run_111 "sha384 of 111 bytes  the last to fit one block"
dk sha512/sha384.bf 70000724415e7b98b5d2ef0c294663809dbad7f4112e4b6885a2bfdcf91633506d8aa7c4e1fe1b3855728facc9e603203d5a7794b1ceeb0825425f7c99b6d3f00d2a4764819ebbd8f5122f4c6986a3c0ddfa1734516e8ba8c5e2ff1c39567390adcae704213e5b7895b2cfec092643607d9a 8b407172a52d78c3aaf6a88bf4b4053b01e1a38b9374295f4edf5ea9b967d6b721533fd21a6887da1484979b449ee0d8 sha384Run_112 "sha384 of 112 bytes  the length no longer fits  two blocks"

dk sha512/sha512_224.bf 0000 6ed0dd02806fa89e25de060c19d3ac86cabb87d6a0ddd05c333b84f4 sha512_224Run_0 "sha512_224 of nothing"
dk sha512/sha512_224.bf 0300616263 4634270f707b6a54daae7530460842e20e37ed265ceee9a43e8924aa sha512_224Run_3 "sha512_224 of abc  FIPS 180_4's own vector"
dk sha512/sha512_224.bf 6f000724415e7b98b5d2ef0c294663809dbad7f4112e4b6885a2bfdcf91633506d8aa7c4e1fe1b3855728facc9e603203d5a7794b1ceeb0825425f7c99b6d3f00d2a4764819ebbd8f5122f4c6986a3c0ddfa1734516e8ba8c5e2ff1c39567390adcae704213e5b7895b2cfec092643607d b7e69382a533924e8836c583987f435c4580bfed27b8147562e56077 sha512_224Run_111 "sha512_224 of 111 bytes  the last to fit one block"
dk sha512/sha512_224.bf 70000724415e7b98b5d2ef0c294663809dbad7f4112e4b6885a2bfdcf91633506d8aa7c4e1fe1b3855728facc9e603203d5a7794b1ceeb0825425f7c99b6d3f00d2a4764819ebbd8f5122f4c6986a3c0ddfa1734516e8ba8c5e2ff1c39567390adcae704213e5b7895b2cfec092643607d9a f2ade807528b0ab4c8dac0fe5704a3720823bea692d56aa8bdec2bc5 sha512_224Run_112 "sha512_224 of 112 bytes  the length no longer fits  two blocks"

dk sha512/sha512_256.bf 0000 c672b8d1ef56ed28ab87c3622c5114069bdd3ad7b8f9737498d0c01ecef0967a sha512_256Run_0 "sha512_256 of nothing"
dk sha512/sha512_256.bf 0300616263 53048e2681941ef99b2e29b76b4c7dabe4c2d0c634fc6d46e0e2f13107e7af23 sha512_256Run_3 "sha512_256 of abc  FIPS 180_4's own vector"
dk sha512/sha512_256.bf 6f000724415e7b98b5d2ef0c294663809dbad7f4112e4b6885a2bfdcf91633506d8aa7c4e1fe1b3855728facc9e603203d5a7794b1ceeb0825425f7c99b6d3f00d2a4764819ebbd8f5122f4c6986a3c0ddfa1734516e8ba8c5e2ff1c39567390adcae704213e5b7895b2cfec092643607d d5e084c480130e687c42fd4d47c360edfb873082ca3de73c0a295f829666752f sha512_256Run_111 "sha512_256 of 111 bytes  the last to fit one block"
dk sha512/sha512_256.bf 70000724415e7b98b5d2ef0c294663809dbad7f4112e4b6885a2bfdcf91633506d8aa7c4e1fe1b3855728facc9e603203d5a7794b1ceeb0825425f7c99b6d3f00d2a4764819ebbd8f5122f4c6986a3c0ddfa1734516e8ba8c5e2ff1c39567390adcae704213e5b7895b2cfec092643607d9a 2d8ea3d1eb3344c4386faf729c431e60d485a87a0a23a66b53cda098017be9f7 sha512_256Run_112 "sha512_256 of 112 bytes  the length no longer fits  two blocks"
# And hashcore itself, which takes a prefix from memory and then a count
# from the wire: the same message split every way, so neither source can
# be silently ignored.
dk sha512/hashcore.bf 000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005101b 0f0023501baa227d0f8ef190775aad9287f6c3db51bfb36eef64cc469baf992f30888e80ac397d3372abc86471ab00319d1b341f9905767482d81cfd46fd67d6 hashcore512Run_0_3 "hashcore512 0 from memory and 3 from the wire"
dk sha512/hashcore.bf 0300000005101b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 0f0023501baa227d0f8ef190775aad9287f6c3db51bfb36eef64cc469baf992f30888e80ac397d3372abc86471ab00319d1b341f9905767482d81cfd46fd67d6 hashcore512Run_3_0 "hashcore512 3 from memory and 0 from the wire"
dk sha512/hashcore.bf 0100020005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000101b 0f0023501baa227d0f8ef190775aad9287f6c3db51bfb36eef64cc469baf992f30888e80ac397d3372abc86471ab00319d1b341f9905767482d81cfd46fd67d6 hashcore512Run_1_2 "hashcore512 1 from memory and 2 from the wire"
dk sha512/hashcore.bf 0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 cf83e1357eefb8bdf1542850d66d8007d620e4050b5715dc83f4a921d36ce9ce47d0d13c5d85f2b0ff8318d2877eec2f63b931bd47417a81a538327af927da3e hashcore512Run_0_0 "hashcore512 0 from memory and 0 from the wire"
dk sha512/hashcore.bf 8000000005101b26313c47525d68737e89949faab5c0cbd6e1ecf7020d18232e39444f5a65707b86919ca7b2bdc8d3dee9f4ff0a15202b36414c57626d78838e99a4afbac5d0dbe6f1fc07121d28333e49545f6a75808b96a1acb7c2cdd8e3eef9040f1a25303b46515c67727d88939ea9b4bfcad5e0ebf6010c17222d38434e59646f7a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 3db70bb2718d58869d2963bdb43ad33024836f9530505486c55a761340d6dcb197da6d43d4d997efc290b116166034b609ec4e9d4632fa6426dc320cb95f1788 hashcore512Run_128_0 "hashcore512 128 from memory and 0 from the wire"
dk sha512/hashcore.bf 3c00440005101b26313c47525d68737e89949faab5c0cbd6e1ecf7020d18232e39444f5a65707b86919ca7b2bdc8d3dee9f4ff0a15202b36414c57626d78838e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000099a4afbac5d0dbe6f1fc07121d28333e49545f6a75808b96a1acb7c2cdd8e3eef9040f1a25303b46515c67727d88939ea9b4bfcad5e0ebf6010c17222d38434e59646f7a 3db70bb2718d58869d2963bdb43ad33024836f9530505486c55a761340d6dcb197da6d43d4d997efc290b116166034b609ec4e9d4632fa6426dc320cb95f1788 hashcore512Run_60_68 "hashcore512 60 from memory and 68 from the wire"
# HMAC-SHA-512, RFC 4231's four SHA-512 cases plus three edges the RFC
# does not cover: an empty key with an empty message, a key of exactly
# one block, and case 1 taken from memory instead of the wire -- because
# hmac passes hashcore's two source shape straight through and a routine
# that quietly ignored one of them would still pass every RFC vector.
dk sha512/hmac.bf 1400000008000b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004869205468657265 87aa7cdea5ef619d4ff0b4241a1d6cb02379f4e2ce4ec2787ad0b30545e17cdedaa833b7d6b8a702038b274eaea3f4e4be9d914eeb61f1702e696c203a126854 hmac512Run_20_0_8 "hmac512 RFC 4231 case 1  the message on the wire"
dk sha512/hmac.bf 1400080000000b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000048692054686572650000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 87aa7cdea5ef619d4ff0b4241a1d6cb02379f4e2ce4ec2787ad0b30545e17cdedaa833b7d6b8a702038b274eaea3f4e4be9d914eeb61f1702e696c203a126854 hmac512Run_20_8_0 "hmac512 RFC 4231 case 1  the message from memory"
dk sha512/hmac.bf 040000001c004a656665000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007768617420646f2079612077616e7420666f72206e6f7468696e673f 164b7a7bfcf819e2e395fbe73b56e0a387bd64222e831fd610270cd7ea2505549758bf75c05a994a6d034f65f8f0e6fdcaeab1a34d4a6b4b636e070a38bce737 hmac512Run_4_0_28 "hmac512 RFC 4231 case 2"
dk sha512/hmac.bf 140000003200aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd fa73b0089d56a284efb0f0756c890be9b1b5dbdd8ee81a3655f83e33b2279d39bf3e848279a722c806b485a47e67c807b946a337bee8942674278859e13292fb hmac512Run_20_0_50 "hmac512 RFC 4231 case 3"
dk sha512/hmac.bf 0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 b936cee86c9f87aa5d3c6f2e84cb5a4239a5fe50480a6ec66b70ab5b1f4ac6730c6c515421b327ec1d69402e53dfb49ad7381eb067b338fd7b0cb22247225d47 hmac512Run_0_0_0 "hmac512 an empty key and an empty message"
dk sha512/hmac.bf 830000003600aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000054657374205573696e67204c6172676572205468616e20426c6f636b2d53697a65204b6579202d2048617368204b6579204669727374 80b24263c7c1a3ebb71493c1dd7be8b49b46d1f41b4aeec1121b013783f8f3526b56d037e05f2598bd0fd2215d6a1e5295e64f73f63f0aec8b915a985d786598 hmac512Run_131_0_54 "hmac512 RFC 4231 case 6  a key longer than a block"
dk sha512/hmac.bf 800000001a00aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000061206b6579206f662065786163746c79206f6e6520626c6f636b 94f63f65459e0653f2c2541b4467a21aa07e87e46f370b33f3a8bf5179320b02f6d59c0ac0b34e373520aa9f1b78ca99b6e77ffa554cbf194e6c0624b460b2f0 hmac512Run_128_0_26 "hmac512 a key of exactly one block  the edge the long key test sits on"
dk sha512/hmac.bf 140081000000000102030405060708090a0b0c0d0e0f101112130000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000404142434445464748494a4b4c4d4e4f505152535455565758595a5b5c5d5e5f606162636465666768696a6b6c6d6e6f707172737475767778797a7b7c7d7e7f808182838485868788898a8b8c8d8e8f909192939495969798999a9b9c9d9e9fa0a1a2a3a4a5a6a7a8a9aaabacadaeafb0b1b2b3b4b5b6b7b8b9babbbcbdbebfc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 53654cbe36d21e80ced835cfa0caccb3972a2de962f5bca5ae8e716aa3263ef5ed0785c2fadec383b7a9daf7b64d9088d5be949892d8230b31b1bf465f65b513 hmac512Run_20_129_0 "hmac512 a prefix of 129 in memory  one past the old prefix slide's reach"
dk sha512/hmac.bf 140000010000000102030405060708090a0b0c0d0e0f101112130000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000404142434445464748494a4b4c4d4e4f505152535455565758595a5b5c5d5e5f606162636465666768696a6b6c6d6e6f707172737475767778797a7b7c7d7e7f808182838485868788898a8b8c8d8e8f909192939495969798999a9b9c9d9e9fa0a1a2a3a4a5a6a7a8a9aaabacadaeafb0b1b2b3b4b5b6b7b8b9babbbcbdbebfc0c1c2c3c4c5c6c7c8c9cacbcccdcecfd0d1d2d3d4d5d6d7d8d9dadbdcdddedfe0e1e2e3e4e5e6e7e8e9eaebecedeeeff0f1f2f3f4f5f6f7f8f9fafbfcfdfeff000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f 413a5c0024dfe12c5a6580f52db884646cf2ed9433af9e8633db05e6470f9f47ff6ee3c77f943ff0e7d55c076ff024079ee23a18ce0384dcd1d92fd6bf768493 hmac512Run_20_256_0 "hmac512 the whole of mbuf in memory  the inner hash at four blocks"
# HKDF-SHA-512, RFC 5869. The RFC's own vectors are SHA-256 only, so
# these are its three shapes carried over -- an ordinary case with two
# turns and the second truncated, the no-salt case that distinguishes an
# absent salt from a key of length nought, and a salt longer than a block
# so HMAC hashes it first -- plus one byte of output, which is the cut
# short path with nothing left over to hide a mistake. The last vector's
# info is sixty three, the longest this routine allows, and that is what
# pushes its second turn's inner hash to three blocks.
dk sha512/hkdf.bf 0d0016000a002a00000102030405060708090a0b0c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f0f1f2f3f4f5f6f7f8f9000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 832390086cda71fb47625bb5ceb168e4c8e26a1a16ed34d9fc7fe92c1481579338da362cb8d9f925d7cb hkdf512Run_13_22_10_42 "hkdf512 RFC 5869 A.1's shape at SHA_512"
dk sha512/hkdf.bf 0000160000002a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 f5fa02b18298a72a8c23898a8703472c6eb179dc204c03425c970e3b164bf90fff22d04836d0e2343bac hkdf512Run_0_22_0_42 "hkdf512 A.3's shape  no salt and no info"
dk sha512/hkdf.bf 0000160000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 f5 hkdf512Run_0_22_0_1 "hkdf512 one byte out  the cut short path with nothing left to hide a mistake"
dk sha512/hkdf.bf 8c0016003f008000aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 d44fe58f63001bbfca10049e4ee8b63f35e18045b020fc035a16846d715cbc05bc09613d6bfe72ace50e3db1b2ced5a49d08c229d5725fc81ad14d2be7d15ce614d926123a608168342748dfad462bd1460fb4a702241fb3efb0b3ef96aec8ef068136937a0f7d26f3278df062b8a6c1756a27de7cacae5847b42ccea2be6ae0 hkdf512Run_140_22_63_128 "hkdf512 a salt longer than a block and the longest info allowed  three block inner hash"
dk sha512/hkdf.bf 0d00160040002a00000102030405060708090a0b0c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b0b1b2b3b4b5b6b7b8b9babbbcbdbebfc0c1c2c3c4c5c6c7c8c9cacbcccdcecfd0d1d2d3d4d5d6d7d8d9dadbdcdddedfe0e1e2e3e4e5e6e7e8e9eaebecedeeef000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 db31c65a686728ba1e7f065f5b5c1204ade9897866abe3dbdbcf39bed826e8f3611da123e90e52bff8f1 hkdf512Run_13_22_64_42 "hkdf512 sixty four bytes of info  one past the limit the old prefix buffer set"
dk sha512/hkdf.bf 0d00160080002a00000102030405060708090a0b0c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b0b1b2b3b4b5b6b7b8b9babbbcbdbebfc0c1c2c3c4c5c6c7c8c9cacbcccdcecfd0d1d2d3d4d5d6d7d8d9dadbdcdddedfe0e1e2e3e4e5e6e7e8e9eaebecedeeeff0f1f2f3f4f5f6f7f8f9fafbfcfdfeff000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f202122232425262728292a2b2c2d2e2f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 e83ee557f680bec19243733cc67bdd2022684980633b972e21f797e806d7832d6fb4b27477171db98d85 hkdf512Run_13_22_128_42 "hkdf512 a hundred and twenty eight of info  both turns at three blocks"
dk sha512/hkdf.bf 0d001600be008000000102030405060708090a0b0c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b0b1b2b3b4b5b6b7b8b9babbbcbdbebfc0c1c2c3c4c5c6c7c8c9cacbcccdcecfd0d1d2d3d4d5d6d7d8d9dadbdcdddedfe0e1e2e3e4e5e6e7e8e9eaebecedeeeff0f1f2f3f4f5f6f7f8f9fafbfcfdfeff000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f404142434445464748494a4b4c4d4e4f505152535455565758595a5b5c5d5e5f606162636465666768696a6b6c6d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 d521c596331926a877ab7f0ab6b152656d488b0e95391ea3695f2bfae614bdd453f369d4ba86d8fb7705f4d99b4f83983f93c1792c51e62bf3dcc20a9c62fb214c8e2b91e8c1aed3e9ab71f871c206077ef5954750c100403224451fb586a653ac2c4b43c92ac1a5bfffc1e1e4c8f2a424bdb2b6b5a4878aaee1d67a0cf181a2 hkdf512Run_13_22_190_128 "hkdf512 the longest info this routine allows  the second turn at four blocks"


# HKDF, RFC 5869, all three published vectors. Each demands something the
# others do not: A.1 is the ordinary case with two turns of expand and the
# second truncated; A.3 has no salt, which the standard says means thirty
# two nought bytes and NOT a key of length nought; A.2 has an eighty byte
# salt, longer than a block, so HMAC hashes it first, and needs three turns.
dk sha256/hkdf.bf 0d0016000a002a00000102030405060708090a0b0c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f0f1f2f3f4f5f6f7f8f9000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 3cb25f25faacd57a90434f64d0362f2a2d2d0a90cf1a5a4c5db02d56ecc4c5bf34007208d5b887185865 hkdfRun_13_22_10_42 "hkdf RFC 5869 A.1"
dk sha256/hkdf.bf 0000160000002a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 8da4e775a563c18f715f802a063c5a31b8a11f5c5ee1879ec3454e5f3c738d2d9d201395faa4b61a96c8 hkdfRun_0_22_0_42 "hkdf RFC 5869 A.3  no salt and no info"
dk sha256/hkdf.bf 5000500050005200606162636465666768696a6b6c6d6e6f707172737475767778797a7b7c7d7e7f808182838485868788898a8b8c8d8e8f909192939495969798999a9b9c9d9e9fa0a1a2a3a4a5a6a7a8a9aaabacadaeaf0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f404142434445464748494a4b4c4d4e4f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b0b1b2b3b4b5b6b7b8b9babbbcbdbebfc0c1c2c3c4c5c6c7c8c9cacbcccdcecfd0d1d2d3d4d5d6d7d8d9dadbdcdddedfe0e1e2e3e4e5e6e7e8e9eaebecedeeeff0f1f2f3f4f5f6f7f8f9fafbfcfdfeff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 b11e398dc80327a1c8e7f78c596a49344f012eda2d4efad8a050cc4c19afa97c59045a99cac7827271cb41c65e590e09da3275600c2f09b8367793a9aca3db71cc30c58179ec3e87c14c01d5c1f3434f1d87 hkdfRun_80_80_80_82 "hkdf RFC 5869 A.2  an eighty byte salt  longer than a block"
dk sha256/kdfctr.bf 20003c002000404142434445464748494a4b4c4d4e4f505152535455565758595a5b5c5d5e5f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000808182838485868788898a8b8c8d8e8f909192939495969798999a9b9c9d9e9fa0a1a2a3a4a5a6a7a8a9aaabacadaeafb0b1b2b3b4b5b6b7b8b9babb00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 373411d87f5451fe6927e1930c6ad3c3ced5e4d79b0d01c46549ac15aa06d81a kdfCtrRun_32_60_32 "kdf108 counter mode  one turn exactly  the inner hash at three blocks"
dk sha256/kdfctr.bf 20003c001000404142434445464748494a4b4c4d4e4f505152535455565758595a5b5c5d5e5f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000808182838485868788898a8b8c8d8e8f909192939495969798999a9b9c9d9e9fa0a1a2a3a4a5a6a7a8a9aaabacadaeafb0b1b2b3b4b5b6b7b8b9babb00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 373411d87f5451fe6927e1930c6ad3c3 kdfCtrRun_32_60_16 "kdf108 counter mode  half of one turn thrown away"
dk sha256/kdfctr.bf 20003c004000404142434445464748494a4b4c4d4e4f505152535455565758595a5b5c5d5e5f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000808182838485868788898a8b8c8d8e8f909192939495969798999a9b9c9d9e9fa0a1a2a3a4a5a6a7a8a9aaabacadaeafb0b1b2b3b4b5b6b7b8b9babb00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 373411d87f5451fe6927e1930c6ad3c3ced5e4d79b0d01c46549ac15aa06d81a50a15eeace8d178a942462362c08b3723a8586d90af1597f3d2cbee7e9bd0280 kdfCtrRun_32_60_64 "kdf108 counter mode  two whole turns  so the counter is seen to step"
dk sha256/kdfctr.bf 200033002000404142434445464748494a4b4c4d4e4f505152535455565758595a5b5c5d5e5f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000808182838485868788898a8b8c8d8e8f909192939495969798999a9b9c9d9e9fa0a1a2a3a4a5a6a7a8a9aaabacadaeafb0b1b200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 c1a8f54718d985db4da29c66606114ab638ffedb9b6d3a9a0ba0aebd864e7ba8 kdfCtrRun_32_51_32 "kdf108 counter mode  the last message whose inner hash is two blocks"
dk sha256/kdfctr.bf 100000002800101112131415161718191a1b1c1d1e1f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 3e7b2dcaab2064c6d7d35bd7035333076a650ece387177891bfb503c7f33bafd4ebc8dfb23615cc4 kdfCtrRun_16_0_40 "kdf108 counter mode  no fixed input at all  and a turn cut short"
dk sha256/kdffb.bf 200014002000404142434445464748494a4b4c4d4e4f505152535455565758595a5b5c5d5e5f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000808182838485868788898a8b8c8d8e8f909192930000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c0c1c2c3c4c5c6c7c8c9cacbcccdcecfd0d1d2d3d4d5d6d7d8d9dadbdcdddedf 12b62fb74b59da3252b4e8a899db5ec65ff1b23ce253245e17ebdab75b657eda kdfFbRun_32_20_32 "kdf108 feedback mode  one turn exactly"
dk sha256/kdffb.bf 200014004000404142434445464748494a4b4c4d4e4f505152535455565758595a5b5c5d5e5f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000808182838485868788898a8b8c8d8e8f909192930000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c0c1c2c3c4c5c6c7c8c9cacbcccdcecfd0d1d2d3d4d5d6d7d8d9dadbdcdddedf 12b62fb74b59da3252b4e8a899db5ec65ff1b23ce253245e17ebdab75b657eda326ecdb4f3b3cc2dab763325d651d0bfff20b1474e34672ad35effc14ada6708 kdfFbRun_32_20_64 "kdf108 feedback mode  two turns  so the chain is seen to feed back"
dk sha256/kdffb.bf 200014003000404142434445464748494a4b4c4d4e4f505152535455565758595a5b5c5d5e5f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000808182838485868788898a8b8c8d8e8f909192930000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c0c1c2c3c4c5c6c7c8c9cacbcccdcecfd0d1d2d3d4d5d6d7d8d9dadbdcdddedf 12b62fb74b59da3252b4e8a899db5ec65ff1b23ce253245e17ebdab75b657eda326ecdb4f3b3cc2dab763325d651d0bf kdfFbRun_32_20_48 "kdf108 feedback mode  the second turn cut short"
dk sha256/kdffb.bf 200000004000404142434445464748494a4b4c4d4e4f505152535455565758595a5b5c5d5e5f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c0c1c2c3c4c5c6c7c8c9cacbcccdcecfd0d1d2d3d4d5d6d7d8d9dadbdcdddedf 17cc59102f7671b017a13240c97bfc1dd67defc95a9603375d8e99486311ea69cdaae03bbee5108da20b828cfd0921184585aabee06e2e49393adcf2828c8f26 kdfFbRun_32_0_64 "kdf108 feedback mode  no fixed input  the inner hash at two blocks"
dk sha256/kdffb.bf 20009c002000404142434445464748494a4b4c4d4e4f505152535455565758595a5b5c5d5e5f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000808182838485868788898a8b8c8d8e8f909192939495969798999a9b9c9d9e9fa0a1a2a3a4a5a6a7a8a9aaabacadaeafb0b1b2b3b4b5b6b7b8b9babbbcbdbebfc0c1c2c3c4c5c6c7c8c9cacbcccdcecfd0d1d2d3d4d5d6d7d8d9dadbdcdddedfe0e1e2e3e4e5e6e7e8e9eaebecedeeeff0f1f2f3f4f5f6f7f8f9fafbfcfdfeff000102030405060708090a0b0c0d0e0f101112131415161718191a1b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c0c1c2c3c4c5c6c7c8c9cacbcccdcecfd0d1d2d3d4d5d6d7d8d9dadbdcdddedf 2f2480af06eb774e1bc694e680dd518ab890732f0a63da17ff59fc1569cc31ac kdfFbRun_32_156_32 "kdf108 feedback mode  the longest fixed input allowed  five blocks"

# ==== Keccak-f[1600], FIPS 202 ====
#
# THETA is the only step that mixes the columns, and a column is five lanes
# FORTY cells apart, where xor64 wants its operands eight apart -- so this is
# the step whose cost is carrying operands to a frame. The vectors are the two
# states where the answer is checkable by eye (all zero, all ones), the two
# single bits at opposite corners of the state, which catch a column or a row
# indexed the wrong way round, the byte ladder, and one random state.

dk keccak/theta.bf 0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 keccakThetaRun "theta all zero  which theta leaves alone"
dk keccak/theta.bf ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff keccakThetaRun "theta all ones  where every halving costs the most"
dk keccak/theta.bf 0100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 0100000000000000010000000000000000000000000000000000000000000000020000000000000000000000000000000100000000000000000000000000000000000000000000000200000000000000000000000000000001000000000000000000000000000000000000000000000002000000000000000000000000000000010000000000000000000000000000000000000000000000020000000000000000000000000000000100000000000000000000000000000000000000000000000200000000000000 keccakThetaRun "theta one bit in lane nought"
dk keccak/theta.bf 0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000080 0000000000000080000000000000000000000000000000000100000000000000000000000000000000000000000000800000000000000000000000000000000001000000000000000000000000000000000000000000008000000000000000000000000000000000010000000000000000000000000000000000000000000080000000000000000000000000000000000100000000000000000000000000000000000000000000800000000000000000000000000000000001000000000000000000000000000080 keccakThetaRun "theta one bit in lane 24  the far corner"
dk keccak/theta.bf 000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f404142434445464748494a4b4c4d4e4f505152535455565758595a5b5c5d5e5f606162636465666768696a6b6c6d6e6f707172737475767778797a7b7c7d7e7f808182838485868788898a8b8c8d8e8f909192939495969798999a9b9c9d9e9fa0a1a2a3a4a5a6a7a8a9aaabacadaeafb0b1b2b3b4b5b6b7b8b9babbbcbdbebfc0c1c2c3c4c5c6c7 d0d2d4d6d8dadcde484a4c4e40424446686a6c6e60626466e8eaeceee0e2e4e6797b7d7f71737577f8fafcfef0f2f4f670727476787a7c7e40424446484a4c4eb0b2b4b6b8babcbe11131517191b1d1f80828486888a8c8e181a1c1e10121416181a1c1e10121416989a9c9e90929496292b2d2f21232527a8aaacaea0a2a4a6c0c2c4c6c8cacccef0f2f4f6f8fafcfe60626466686a6c6ec1c3c5c7c9cbcdcf70727476787a7c7ee8eaeceee0e2e4e6c8cacccec0c2c4c6484a4c4e40424446999b9d9f91939597 keccakThetaRun "theta the byte ladder"
dk keccak/theta.bf e7eee7615ef35f30e49b482e15cae75007201e12617b0feda7e1647796ff022bea8ed02a82a175930f2337cd3794c52208006d6b1af0c0cbd625658aac2c9faa07d13c447e33051eeef95a60e56143d6c43bcad76c008a9b0a6b5fc933154a6de28404a897c525262e6a7c07bcbee841f745c55d4e9f747f615164c6f728d718353713827ac883d7fb9659234074f5258f6c68082389d2e47f1e175a90bc432fb946e6a9471109f3b79f110a26f6229fa3452526e7bc1642aeb42bf227d50fff07c3c20624292e3b a5b18d22031be863c6ded6505a21853e3d7da98aa036a78dda6c52d551300b71adcf86cdb832db394d7c5d8e6a7c72712a45f315551ba2a5ec78d2126d6137ca7a5c0ae6b9fc0c44a9b80c87dff2ed7c8664a09431e83dc8282ec1b77cfe2803d8d9b33056888d4653e74aa57b71e11bb00493ba740cdad5230e0e85aac0604b17728dfc3523e1b9c1cbeebb81395d45f2e15eaae446dbbe385f41bdaa2fed85fb198cea1af9bea095da8f74691d40f1991892be26f1be22d3391d50e01a06a5408294e11eba8091 keccakThetaRun "theta a random state"

# RHO and PI are one pass, because a turn and a move are the same journey. The
# vectors are the two states checkable by eye, the two single bits at opposite
# corners -- which catch a lane sent to the wrong place or turned the wrong way
# -- the byte ladder, and one random state.

dk keccak/rhopi.bf 0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 keccakRhoPiRun "rho and pi all zero"
dk keccak/rhopi.bf ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff keccakRhoPiRun "rho and pi all ones"
dk keccak/rhopi.bf 0100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 0100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 keccakRhoPiRun "rho and pi one bit in lane nought"
dk keccak/rhopi.bf 0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000080 0000000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 keccakRhoPiRun "rho and pi one bit in lane 24  the far corner"
dk keccak/rhopi.bf 000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f404142434445464748494a4b4c4d4e4f505152535455565758595a5b5c5d5e5f606162636465666768696a6b6c6d6e6f707172737475767778797a7b7c7d7e7f808182838485868788898a8b8c8d8e8f909192939495969798999a9b9c9d9e9fa0a1a2a3a4a5a6a7a8a9aaabacadaeafb0b1b2b3b4b5b6b7b8b9babbbcbdbebfc0c1c2c3c4c5c6c7 000102030405060733435363730313231b232b333b030b13d2f21232527292b2f13170b0f03071b1d1e1f18191a1b1c1e4f48494a4b4c4d4828a929aa2aab2ba7090b0d0f010305036567696b6d6f61610121416181a1c1e0f4e8ece0e4f8fcfdadcded0d2d4d6d89f98999a9b9c9d9e9a9e82868a8e92962931390109111921c2d2e2f28292a2b27d6165696d717579c747c444c545c646b9babbbcbdbebfb84484c4044585c50520a121a222a323a039ba3abb3bb838b9f6f8fafcfef0f2f4a2a6aaaeb2b6babe keccakRhoPiRun "rho and pi the byte ladder"
dk keccak/rhopi.bf e7eee7615ef35f30e49b482e15cae75007201e12617b0feda7e1647796ff022bea8ed02a82a175930f2337cd3794c52208006d6b1af0c0cbd625658aac2c9faa07d13c447e33051eeef95a60e56143d6c43bcad76c008a9b0a6b5fc933154a6de28404a897c525262e6a7c07bcbee841f745c55d4e9f747f615164c6f728d718353713827ac883d7fb9659234074f5258f6c68082389d2e47f1e175a90bc432fb946e6a9471109f3b79f110a26f6229fa3452526e7bc1642aeb42bf227d50fff07c3c20624292e3b e7eee7615ef35f30b6a6010fbc8c00d040bd2c2e31112724519afc910d0d6124cbcec1b0b001498af92fb0721a4e76673664ed9eaf05561e24de51be660350dc42500f79f0bae666b4a8c4e49cd74268c837915c2a94cfa1aa754999222bcba77dd1835cd4f80e782f7f1e175a90bc4324cce71a99a71e450cad9b54778456117c43592cf23072d3b529ac7d25cf5428fa927dcbac1120bab42bf227d50fffae01888744d8de43fb681e22bf99028f832ea74fbabffba2e28cef51ae31c2a2c8de7e462898d88b7c keccakRhoPiRun "rho and pi a random state"

# And the same six states through rho, pi AND chi, which is what a round
# actually pastes. chi is the only non-linear step, so the all-ones state is
# the one worth staring at: not v and v is nought, so every lane comes back
# unchanged, which no amount of wrong indexing would reproduce.

dk keccak/rhopichi.bf 0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 keccakRhoPiChiRun "rho pi and chi all zero"
dk keccak/rhopichi.bf ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff keccakRhoPiChiRun "rho pi and chi all ones"
dk keccak/rhopichi.bf 0100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 0100000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 keccakRhoPiChiRun "rho pi and chi one bit in lane nought"
dk keccak/rhopichi.bf 0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000080 0000000000000000000000000000000000200000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 keccakRhoPiChiRun "rho pi and chi one bit in lane 24  the far corner"
dk keccak/rhopichi.bf 000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f404142434445464748494a4b4c4d4e4f505152535455565758595a5b5c5d5e5f606162636465666768696a6b6c6d6e6f707172737475767778797a7b7c7d7e7f808182838485868788898a8b8c8d8e8f909192939495969798999a9b9c9d9e9fa0a1a2a3a4a5a6a7a8a9aaabacadaeafb0b1b2b3b4b5b6b7b8b9babbbcbdbebfc0c1c2c3c4c5c6c7 08212a130c050e17f3934363337383833a224bb39b036a12d2f21031567794b4c27321d083326091d3ebe38b93ab83eb94e4a4d4f4a4c49484ccd49ca46c74bcb13131d1f13131911242728292c2b202c0824406c88a4c0e0a4e8fc4074786c9dadadcd4d2d6d4d89f988d8a8b8c919695d2084e8ccb115714103c0864704c6840d462f6029620b445d95ed155cb4cc1c746c445c544c6477b78794e3f3c1d2a5d9ede1d5c9ddd1ce6e1e1e6e6e3e1e439bc3ab93bbe30b3b2f8befcbbf1b7f582878b0c9094981e keccakRhoPiChiRun "rho pi and chi the byte ladder"
dk keccak/rhopichi.bf e7eee7615ef35f30e49b482e15cae75007201e12617b0feda7e1647796ff022bea8ed02a82a175930f2337cd3794c52208006d6b1af0c0cbd625658aac2c9faa07d13c447e33051eeef95a60e56143d6c43bcad76c008a9b0a6b5fc933154a6de28404a897c525262e6a7c07bcbee841f745c55d4e9f747f615164c6f728d718353713827ac883d7fb9659234074f5258f6c68082389d2e47f1e175a90bc432fb946e6a9471109f3b79f110a26f6229fa3452526e7bc1642aeb42bf227d50fff07c3c20624292e3b a7f7cb415fe27814a7a4d19eb08040d0caf92d0e81112fae75badad043ff7714dbcec1be100d494af9b5a0525a4c76a77464e3df3fbdf03c9076913a6a4650d40b573f6bf2b2d261b2e8896839d642709db71318fe44cbf9a85b559a282b7ba47d51625455df0c7ce74c0e5378807de3068caf9b998c1e438d853f05724b523936d108ae7a205241b1002e5974c18b2cf216749b8e9120abc469b20f553fdf6c0729ca44fe27639be85632bb99028f8b7cb749ba37e3abd68d6fd0ea71c4e24bb668669399d8077c keccakRhoPiChiRun "rho pi and chi a random state"

# And the whole permutation: twenty four rounds, theta and rho pi chi pasted
# and iota inline. The all-zero state is the vector everyone has -- it is the
# one in Keccak's own test suite and the first thing a sponge computes when it
# absorbs nothing -- and the random state is there so that a permutation which
# only happened to be right on a sparse input would not pass. Each of these is
# about four billion instructions, eight seconds, which is why there are two.

dk keccak/permute1600.bf 0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 e7dde140798f25f18a47c033f9ccd584eea95aa61e2698d54d49806f304715bd57d05362054e288bd46f8e7f2da497ffc44746a4a0e5fe90762e19d60cda5b8c9c05191bf7a630ad64fc8fd0b75a933035d617233fa95aeb0321710d26e6a6a95f55cfdb167ca58126c84703cd31b8439f56a5111a2ff20161aed9215a63e505f270c98cf2febe641166c47b95703661cb0ed04f555a7cb8c832cf1c8ae83e8c14263aae22790c94e409c5a224f94118c26504e72635f5163ba1307fe944f67549a2ec5c7bfff1ea keccakPermuteRun "permute the all zero state  which is the published vector"
dk keccak/permute1600.bf e7eee7615ef35f30e49b482e15cae75007201e12617b0feda7e1647796ff022bea8ed02a82a175930f2337cd3794c52208006d6b1af0c0cbd625658aac2c9faa07d13c447e33051eeef95a60e56143d6c43bcad76c008a9b0a6b5fc933154a6de28404a897c525262e6a7c07bcbee841f745c55d4e9f747f615164c6f728d718353713827ac883d7fb9659234074f5258f6c68082389d2e47f1e175a90bc432fb946e6a9471109f3b79f110a26f6229fa3452526e7bc1642aeb42bf227d50fff07c3c20624292e3b b3633c43f4aa8bfbde66e7729b5b2e36b10cd60b4ffa5303c9a4a6bff6ffec77704f29a29611b70d7304ae85750adecb45e627c8a00f5ccd3666c63aa8606957b280c078f9a439d51ca02573810a14688e34dd57d0787080de585ec27cbb1f27158644ff91854ebd6eee4ac4b6ef35e2238466dea646dce400dc0e8a55f4f4b37fe26bac2ce2c8d72ea3839b19e8dee0a5ea4876b8b6dfce4460fab8f62816e455054ce86f65a6f3b71a21de990c44b4909964e9021cab2691e5bc963b992921a181555e8428a754 keccakPermuteRun "permute a random state"

# SHA3-256 is the sponge: one rate of the state takes the block, the
# permutation stirs it, and the answer is the front of the state. Each block is
# about four billion instructions, so these four are chosen to be the cheapest
# set that covers the padding: nothing, FIPS 202's own "abc", the length where
# the pad byte and the top bit are the SAME byte, and the length where the
# padding needs a whole block to itself. That last one is not decoration -- the
# first version of the file put the top bit on every block instead of the last,
# which no single-block vector can see.

dk keccak/sha3_256.bf 0000 a7ffc6f8bf1ed76651c14756a061d662f580ff4de43b49fa82d80a4b80f8434a sha3_256Run_0 "sha3_256 of nothing"
dk keccak/sha3_256.bf 0300616263 3a985da74fe225b2045c172d6bd390bd855f086e3e9d525b46bfe24511431532 sha3_256Run_3 "sha3_256 of abc  FIPS 202's own vector"
dk keccak/sha3_256.bf 8700000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f404142434445464748494a4b4c4d4e4f505152535455565758595a5b5c5d5e5f606162636465666768696a6b6c6d6e6f707172737475767778797a7b7c7d7e7f80818283848586 fded8fd9d6551c601eeb3b7c6bc5e5cfd8aad1d015b7e9aaa9c9b9475231d5e2 sha3_256Run_135 "sha3_256 of 135 bytes  the pad byte and the top bit are one byte"
dk keccak/sha3_256.bf 8800000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f404142434445464748494a4b4c4d4e4f505152535455565758595a5b5c5d5e5f606162636465666768696a6b6c6d6e6f707172737475767778797a7b7c7d7e7f8081828384858687 cf3ccff92480a29160c2d38317c430e14749bfee1788106957dfe73f8c4930e5 sha3_256Run_136 "sha3_256 of 136 bytes  the padding takes a block of its own"

# ROTSTATE is the conveyor the squeeze runs on: the byte about to go out is
# always the BOTTOM cell of the state, so the state turns over one cell at a
# time and two hundred turns put it back. The all-zero state proves nothing
# about the wrap, so the other two have a byte at the bottom to watch travel to
# the top -- and the ladder makes a single cell out of place visible by eye.

dk keccak/rotstate.bf 0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 keccakRotStateRun "rotstate all zero"
dk keccak/rotstate.bf 000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f404142434445464748494a4b4c4d4e4f505152535455565758595a5b5c5d5e5f606162636465666768696a6b6c6d6e6f707172737475767778797a7b7c7d7e7f808182838485868788898a8b8c8d8e8f909192939495969798999a9b9c9d9e9fa0a1a2a3a4a5a6a7a8a9aaabacadaeafb0b1b2b3b4b5b6b7b8b9babbbcbdbebfc0c1c2c3c4c5c6c7 0102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f404142434445464748494a4b4c4d4e4f505152535455565758595a5b5c5d5e5f606162636465666768696a6b6c6d6e6f707172737475767778797a7b7c7d7e7f808182838485868788898a8b8c8d8e8f909192939495969798999a9b9c9d9e9fa0a1a2a3a4a5a6a7a8a9aaabacadaeafb0b1b2b3b4b5b6b7b8b9babbbcbdbebfc0c1c2c3c4c5c6c700 keccakRotStateRun "rotstate the byte ladder  where one cell out of place shows"
dk keccak/rotstate.bf e7eee7615ef35f30e49b482e15cae75007201e12617b0feda7e1647796ff022bea8ed02a82a175930f2337cd3794c52208006d6b1af0c0cbd625658aac2c9faa07d13c447e33051eeef95a60e56143d6c43bcad76c008a9b0a6b5fc933154a6de28404a897c525262e6a7c07bcbee841f745c55d4e9f747f615164c6f728d718353713827ac883d7fb9659234074f5258f6c68082389d2e47f1e175a90bc432fb946e6a9471109f3b79f110a26f6229fa3452526e7bc1642aeb42bf227d50fff07c3c20624292e3b eee7615ef35f30e49b482e15cae75007201e12617b0feda7e1647796ff022bea8ed02a82a175930f2337cd3794c52208006d6b1af0c0cbd625658aac2c9faa07d13c447e33051eeef95a60e56143d6c43bcad76c008a9b0a6b5fc933154a6de28404a897c525262e6a7c07bcbee841f745c55d4e9f747f615164c6f728d718353713827ac883d7fb9659234074f5258f6c68082389d2e47f1e175a90bc432fb946e6a9471109f3b79f110a26f6229fa3452526e7bc1642aeb42bf227d50fff07c3c20624292e3be7 keccakRotStateRun "rotstate a random state  whose bottom byte travels to the top"

# SPONGE136 is the sponge itself, with the padding byte read off the wire. A
# rate cannot be a parameter in brainfuck -- every journey the absorb makes
# would be of a computed length, and there is no index to compute one from --
# but a padding byte can be, and that is the whole reason this file exists. So
# the first two vectors are the SAME program handed 6 and handed 31, and their
# answers are SHA3-256 of nothing and SHAKE256 of nothing: the parameter is
# proved to be real by two functions coming out of one .bf. The third crosses a
# rate, which is the thing SHA3-256's own vectors could never reach.

dk keccak/sponge136.bf 0600002000 a7ffc6f8bf1ed76651c14756a061d662f580ff4de43b49fa82d80a4b80f8434a sponge136Run_0_32 "sponge136 handed a 6  which is SHA3 256 of nothing"
dk keccak/sponge136.bf 1f00002000 46b9dd2b0ba88d13233b3feb743eeb243fcd52ea62b81b82b50c27646ed5762f sponge136Run_0_32 "sponge136 handed a 31  which is SHAKE256 of nothing"
dk keccak/sponge136.bf 1f00008900 46b9dd2b0ba88d13233b3feb743eeb243fcd52ea62b81b82b50c27646ed5762fd75dc4ddd8c0f200cb05019d67b592f6fc821c49479ab48640292eacb3b7c4be141e96616fb13957692cc7edd0b45ae3dc07223c8e92937bef84bc0eab862853349ec75546f58fb7c2775c38462c5010d846c185c15111e595522a6bcd16cf86f3d122109e3b1fdd94 sponge136Run_0_137 "sponge136 squeezed 137 bytes  one byte into a second rate"

# SHAKE256 is sponge136 handed FIPS 202's 31 and the caller's own length. The
# squeeze LOOP is the one thing here that SHA3 never exercises, so these cover
# its boundary from both sides: one short of a rate, exactly a rate, and one
# byte past it -- the last of which is the only vector in the file that stirs
# the state a second time for OUTPUT rather than for input. The 136 byte
# message is there because an absorb of two blocks and a squeeze of one rate
# are independent, and a file that got the flags crossed would pass every
# single-block vector.

dk keccak/shake256.bf 00002000 46b9dd2b0ba88d13233b3feb743eeb243fcd52ea62b81b82b50c27646ed5762f shake256Run_0_32 "shake256 of nothing  32 bytes"
dk keccak/shake256.bf 03002000616263 483366601360a8771c6863080cc4114d8db44530f8f1e1ee4f94ea37e78b5739 shake256Run_3_32 "shake256 of abc  32 bytes"
dk keccak/shake256.bf 00008800 46b9dd2b0ba88d13233b3feb743eeb243fcd52ea62b81b82b50c27646ed5762fd75dc4ddd8c0f200cb05019d67b592f6fc821c49479ab48640292eacb3b7c4be141e96616fb13957692cc7edd0b45ae3dc07223c8e92937bef84bc0eab862853349ec75546f58fb7c2775c38462c5010d846c185c15111e595522a6bcd16cf86f3d122109e3b1fdd shake256Run_0_136 "shake256 of nothing  136 bytes  exactly one rate"
dk keccak/shake256.bf 00008900 46b9dd2b0ba88d13233b3feb743eeb243fcd52ea62b81b82b50c27646ed5762fd75dc4ddd8c0f200cb05019d67b592f6fc821c49479ab48640292eacb3b7c4be141e96616fb13957692cc7edd0b45ae3dc07223c8e92937bef84bc0eab862853349ec75546f58fb7c2775c38462c5010d846c185c15111e595522a6bcd16cf86f3d122109e3b1fdd94 shake256Run_0_137 "shake256 of nothing  137 bytes  one byte past a rate"
dk keccak/shake256.bf 88002000000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f404142434445464748494a4b4c4d4e4f505152535455565758595a5b5c5d5e5f606162636465666768696a6b6c6d6e6f707172737475767778797a7b7c7d7e7f8081828384858687 b7ff4073b3f5a8eabd6e17705ca7f6761a31058f9df781a6a47e3a3063b9d67a shake256Run_136_32 "shake256 of 136 bytes  two blocks in and one rate out"

# SPONGE168 is the same sponge at SHAKE128's rate, and a rate is the one thing
# that cannot be shared: it sets how many lanes the absorb touches and how far
# every one of its twenty one journeys runs, so every distance in the file was
# worked out again. Two vectors, because the whole of the reasoning is already
# under sponge136's -- one inside the first rate and one past it.

dk keccak/sponge168.bf 1f00002000 7f9c2ba4e88f827d616045507605853ed73b8093f6efbc88eb1a6eacfa66ef26 sponge168Run_0_32 "sponge168 handed a 31  which is SHAKE128 of nothing"
dk keccak/sponge168.bf 1f0000a900 7f9c2ba4e88f827d616045507605853ed73b8093f6efbc88eb1a6eacfa66ef263cb1eea988004b93103cfb0aeefd2a686e01fa4a58e8a3639ca8a1e3f9ae57e235b8cc873c23dc62b8d260169afa2f75ab916a58d974918835d25e6a435085b2badfd6dfaac359a5efbb7bcc4b59d538df9a04302e10c8bc1cbf1a0b3a5120ea17cda7cfad765f5623474d368ccca8af0007cd9f5e4c849f167a580b14aabdefaee7eef47cb0fca976 sponge168Run_0_169 "sponge168 squeezed 169 bytes  one byte into a second rate"

# SHAKE128 is sponge168 handed FIPS 202's 31. It is the function ML-KEM
# actually calls -- its matrix sampling is a SHAKE128 squeeze of a few hundred
# bytes per entry -- so its boundaries get the same treatment SHAKE256's did:
# exactly a rate, one byte past it, and a message of exactly a rate so that the
# absorb needs two blocks while the squeeze needs one.

dk keccak/shake128.bf 00002000 7f9c2ba4e88f827d616045507605853ed73b8093f6efbc88eb1a6eacfa66ef26 shake128Run_0_32 "shake128 of nothing  32 bytes"
dk keccak/shake128.bf 03002000616263 5881092dd818bf5cf8a3ddb793fbcba74097d5c526a6d35f97b83351940f2cc8 shake128Run_3_32 "shake128 of abc  32 bytes"
dk keccak/shake128.bf 0000a800 7f9c2ba4e88f827d616045507605853ed73b8093f6efbc88eb1a6eacfa66ef263cb1eea988004b93103cfb0aeefd2a686e01fa4a58e8a3639ca8a1e3f9ae57e235b8cc873c23dc62b8d260169afa2f75ab916a58d974918835d25e6a435085b2badfd6dfaac359a5efbb7bcc4b59d538df9a04302e10c8bc1cbf1a0b3a5120ea17cda7cfad765f5623474d368ccca8af0007cd9f5e4c849f167a580b14aabdefaee7eef47cb0fca9 shake128Run_0_168 "shake128 of nothing  168 bytes  exactly one rate"
dk keccak/shake128.bf 0000a900 7f9c2ba4e88f827d616045507605853ed73b8093f6efbc88eb1a6eacfa66ef263cb1eea988004b93103cfb0aeefd2a686e01fa4a58e8a3639ca8a1e3f9ae57e235b8cc873c23dc62b8d260169afa2f75ab916a58d974918835d25e6a435085b2badfd6dfaac359a5efbb7bcc4b59d538df9a04302e10c8bc1cbf1a0b3a5120ea17cda7cfad765f5623474d368ccca8af0007cd9f5e4c849f167a580b14aabdefaee7eef47cb0fca976 shake128Run_0_169 "shake128 of nothing  169 bytes  one byte past a rate"
dk keccak/shake128.bf a8002000000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f404142434445464748494a4b4c4d4e4f505152535455565758595a5b5c5d5e5f606162636465666768696a6b6c6d6e6f707172737475767778797a7b7c7d7e7f808182838485868788898a8b8c8d8e8f909192939495969798999a9b9c9d9e9fa0a1a2a3a4a5a6a7 f15277eb61c4908d44a2853f3cde071ae2ed7a23461fbe162a1a98cf6875059c shake128Run_168_32 "shake128 of 168 bytes  two blocks in and one rate out"

# SHA3-224, SHA3-384 and SHA3-512 are one shape at three more rates: pad 6, a
# digest shorter than the rate, and so no squeeze loop at all. Four vectors
# each and the same four every time -- nothing, FIPS 202's own "abc", the
# length where the pad byte and the top bit are the SAME byte, and the length
# where the padding needs a whole block to itself. That last one is the case
# the rate 136 sponge got wrong first time, and no single-block vector can see
# it, so it is not optional at any rate.


dk keccak/sha3_224.bf 0000 6b4e03423667dbb73b6e15454f0eb1abd4597f9a1b078e3f5b5a6bc7 sha3_224Run_0 "sha3_224 of nothing"
dk keccak/sha3_224.bf 0300616263 e642824c3f8cf24ad09234ee7d3c766fc9a3a5168d0c94ad73b46fdf sha3_224Run_3 "sha3_224 of abc  FIPS 202's own vector"
dk keccak/sha3_224.bf 8f00000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f404142434445464748494a4b4c4d4e4f505152535455565758595a5b5c5d5e5f606162636465666768696a6b6c6d6e6f707172737475767778797a7b7c7d7e7f808182838485868788898a8b8c8d8e 64d0e8a1be3cf30ef6727b30a6e428f7f068d44634c943d277ad8e7f sha3_224Run_143 "sha3_224 of 143 bytes  the pad byte and the top bit are one byte"
dk keccak/sha3_224.bf 9000000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f404142434445464748494a4b4c4d4e4f505152535455565758595a5b5c5d5e5f606162636465666768696a6b6c6d6e6f707172737475767778797a7b7c7d7e7f808182838485868788898a8b8c8d8e8f 5be75e6a08f19913a1d8036c056cc4556b98dc90aeca3f2a0664dedc sha3_224Run_144 "sha3_224 of 144 bytes  the padding takes a block of its own"

dk keccak/sha3_384.bf 0000 0c63a75b845e4f7d01107d852e4c2485c51a50aaaa94fc61995e71bbee983a2ac3713831264adb47fb6bd1e058d5f004 sha3_384Run_0 "sha3_384 of nothing"
dk keccak/sha3_384.bf 0300616263 ec01498288516fc926459f58e2c6ad8df9b473cb0fc08c2596da7cf0e49be4b298d88cea927ac7f539f1edf228376d25 sha3_384Run_3 "sha3_384 of abc  FIPS 202's own vector"
dk keccak/sha3_384.bf 6700000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f404142434445464748494a4b4c4d4e4f505152535455565758595a5b5c5d5e5f60616263646566 1f91ee551ad18f268876d1fc262f137fe196580216c5193819a95ec5222537d2a658dd129c3d8080e65ec7460f1f4704 sha3_384Run_103 "sha3_384 of 103 bytes  the pad byte and the top bit are one byte"
dk keccak/sha3_384.bf 6800000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f404142434445464748494a4b4c4d4e4f505152535455565758595a5b5c5d5e5f6061626364656667 5b8d0d5cf8b41be507be8fcbfcbdbac3a28eb368d430fed6780aaa78a93a8da4a6c50485949ca344f228be91a96005a3 sha3_384Run_104 "sha3_384 of 104 bytes  the padding takes a block of its own"

dk keccak/sha3_512.bf 0000 a69f73cca23a9ac5c8b567dc185a756e97c982164fe25859e0d1dcc1475c80a615b2123af1f5f94c11e3e9402c3ac558f500199d95b6d3e301758586281dcd26 sha3_512Run_0 "sha3_512 of nothing"
dk keccak/sha3_512.bf 0300616263 b751850b1a57168a5693cd924b6b096e08f621827444f70d884f5d0240d2712e10e116e9192af3c91a7ec57647e3934057340b4cf408d5a56592f8274eec53f0 sha3_512Run_3 "sha3_512 of abc  FIPS 202's own vector"
dk keccak/sha3_512.bf 4700000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f40414243444546 3ccc850d53a1287af7b4560b2ef0d43eb5d9a80d62a0e9cf1dbc040135921104d4395168e90bfc871773ebb34bca1bd67056e1cc7dc7a48ff7c3167d389f117c sha3_512Run_71 "sha3_512 of 71 bytes  the pad byte and the top bit are one byte"
dk keccak/sha3_512.bf 4800000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f4041424344454647 5d63f2bbe971a983ac6847480106e4e1264ee3a0befd79954914e1d86e795b2e18238f12fc5e46cb9cc78efdec610a93647cc04e1c23d8caaa6a58c21dd26c07 sha3_512Run_72 "sha3_512 of 72 bytes  the padding takes a block of its own"


echo
# TIER 5
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
run "sha512 expand honours its declared contracts" sh -c "printf ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff | ./tools/hx -r | BFI_CONTRACTS=1 ./tools/bfi sha512/expand.bf >/dev/null"
run "sha512 round honours its declared contracts" sh -c "printf 08c9bcf367e6096a3ba7ca8485ae67bb2bf894fe72f36e3cf1361d5f3af54fa5d182e6ad7f520e511f6c3e2b8c68059b6bbd41fbabd9831f79217e1319cde05b000000008063626122ae28d7982f8a42 | ./tools/hx -r | BFI_CONTRACTS=1 ./tools/bfi sha512/round.bf >/dev/null"
run "sha512 hashcore honours its declared contracts" sh -c "printf 0000030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000616263 | ./tools/hx -r | BFI_CONTRACTS=1 ./tools/bfi sha512/hashcore.bf >/dev/null"
run "sha512 honours its declared contracts" sh -c "printf 0300616263 | ./tools/hx -r | BFI_CONTRACTS=1 ./tools/bfi sha512/sha512.bf >/dev/null"
run "sha512 hmac honours its declared contracts" sh -c "printf 1400080000000b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000048692054686572650000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 | ./tools/hx -r | BFI_CONTRACTS=1 ./tools/bfi sha512/hmac.bf >/dev/null"
run "sha384 honours its declared contracts" sh -c "printf 0300616263 | ./tools/hx -r | BFI_CONTRACTS=1 ./tools/bfi sha512/sha384.bf >/dev/null"
run "sha512_224 honours its declared contracts" sh -c "printf 0300616263 | ./tools/hx -r | BFI_CONTRACTS=1 ./tools/bfi sha512/sha512_224.bf >/dev/null"
run "sha512_256 honours its declared contracts" sh -c "printf 0300616263 | ./tools/hx -r | BFI_CONTRACTS=1 ./tools/bfi sha512/sha512_256.bf >/dev/null"
run "sha512 hkdf honours its declared contracts" sh -c "printf 0d0016000a002a00000102030405060708090a0b0c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f0f1f2f3f4f5f6f7f8f9000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 | ./tools/hx -r | BFI_CONTRACTS=1 ./tools/bfi sha512/hkdf.bf >/dev/null"
run "and32 honours its declared contracts" sh -c "printf ffffffffffffffff | ./tools/hx -r | BFI_CONTRACTS=1 ./tools/bfi idiom/and32.bf >/dev/null"
run "rotr32 honours its declared contracts" sh -c "printf 7856341219 | ./tools/hx -r | BFI_CONTRACTS=1 ./tools/bfi idiom/rotr32.bf >/dev/null"
run "shr32 honours its declared contracts" sh -c "printf 7856341203 | ./tools/hx -r | BFI_CONTRACTS=1 ./tools/bfi idiom/shr32.bf >/dev/null"
run "rotr64 honours its declared contracts" sh -c "printf efcdab896745230107 | ./tools/hx -r | BFI_CONTRACTS=1 ./tools/bfi idiom/rotr64.bf >/dev/null"
run "rotl64 honours its declared contracts" sh -c "printf efcdab896745230138 | ./tools/hx -r | BFI_CONTRACTS=1 ./tools/bfi idiom/rotl64.bf >/dev/null"
run "keccak theta honours its declared contracts" sh -c "printf %0400d 0 | tr 0 f | ./tools/hx -r | BFI_CONTRACTS=1 ./tools/bfi keccak/theta.bf >/dev/null"
run "keccak rho and pi honour their declared contracts" sh -c "printf %0400d 0 | tr 0 f | ./tools/hx -r | BFI_CONTRACTS=1 ./tools/bfi keccak/rhopi.bf >/dev/null"
run "keccak rho pi and chi honour their declared contracts" sh -c "printf %0400d 0 | tr 0 f | ./tools/hx -r | BFI_CONTRACTS=1 ./tools/bfi keccak/rhopichi.bf >/dev/null"
run "keccak permute honours its declared contracts" sh -c "printf %0400d 0 | ./tools/hx -r | BFI_CONTRACTS=1 ./tools/bfi keccak/permute1600.bf >/dev/null"
run "sha3_256 honours its declared contracts" sh -c "printf 0300616263 | ./tools/hx -r | BFI_CONTRACTS=1 ./tools/bfi keccak/sha3_256.bf >/dev/null"
run "rotstate honours its declared contracts" sh -c "printf %0400d 0 | tr 0 f | ./tools/hx -r | BFI_CONTRACTS=1 ./tools/bfi keccak/rotstate.bf >/dev/null"
run "sponge136 honours its declared contracts" sh -c "printf 1f00008900 | ./tools/hx -r | BFI_CONTRACTS=1 ./tools/bfi keccak/sponge136.bf >/dev/null"
run "shake256 honours its declared contracts" sh -c "printf 03008900616263 | ./tools/hx -r | BFI_CONTRACTS=1 ./tools/bfi keccak/shake256.bf >/dev/null"
run "sponge168 honours its declared contracts" sh -c "printf 1f0000a900 | ./tools/hx -r | BFI_CONTRACTS=1 ./tools/bfi keccak/sponge168.bf >/dev/null"
run "shake128 honours its declared contracts" sh -c "printf 0300a900616263 | ./tools/hx -r | BFI_CONTRACTS=1 ./tools/bfi keccak/shake128.bf >/dev/null"
run "sha3_224 honours its declared contracts" sh -c "printf 0300616263 | ./tools/hx -r | BFI_CONTRACTS=1 ./tools/bfi keccak/sha3_224.bf >/dev/null"
run "sha3_384 honours its declared contracts" sh -c "printf 0300616263 | ./tools/hx -r | BFI_CONTRACTS=1 ./tools/bfi keccak/sha3_384.bf >/dev/null"
run "sha3_512 honours its declared contracts" sh -c "printf 0300616263 | ./tools/hx -r | BFI_CONTRACTS=1 ./tools/bfi keccak/sha3_512.bf >/dev/null"
run "shr64 honours its declared contracts" sh -c "printf efcdab896745230107 | ./tools/hx -r | BFI_CONTRACTS=1 ./tools/bfi idiom/shr64.bf >/dev/null"
run "xor64 honours its declared contracts" sh -c "printf efcdab89674523011032547698badcfe | ./tools/hx -r | BFI_CONTRACTS=1 ./tools/bfi idiom/xor64.bf >/dev/null"
run "and64 honours its declared contracts" sh -c "printf efcdab89674523011032547698badcfe | ./tools/hx -r | BFI_CONTRACTS=1 ./tools/bfi idiom/and64.bf >/dev/null"
run "add64 honours its declared contracts" sh -c "printf ffffffffffffffff0100000000000000 | ./tools/hx -r | BFI_CONTRACTS=1 ./tools/bfi idiom/add64.bf >/dev/null"
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
# TIER 7
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
# TIER 12
echo "== tier 12: composition, a program chaining routines =="
# THE SEAM, AND UNTIL THIS TIER NOTHING TESTED IT. Every routine here is
# checked against Cryptol and a vector. brainstem is gated across two kernels.
# What neither of them could see is whether a brainfuck PROGRAM can take one
# routine's output and make it the next one's input -- the capability the whole
# three-phase scheme was designed around, and the reason this library claims
# its primitives COMPOSE rather than merely that each one is right.
#
# The broker and the expander both come from the brainstem checkout that
# tools/guest-setup.sh pinned and built. There is no copy of either here: two
# copies of an expander are two things that can disagree about what a .poke
# means. If /opt/brainstem is missing this tier FAILS rather than skipping,
# which is the house rule -- "run it when present" is a skip and this project
# does not skip.
BS=/opt/brainstem
run "the pinned broker and expander are present" sh -c '
    test -x "$1/build/brainstem" || { echo "no broker at $1"; exit 1; }
    test -r "$1/tools/bfgen.sh"  || { echo "no expander at $1"; exit 1; }
    test "$(cat "$1/PINNED" 2>/dev/null)" = "$2" || {
        echo "the built broker is not the pinned commit"; exit 1; }' \
    _ "$BS" "$(sed -n "s/^BRAINSTEM_COMMIT=//p" tools/guest-setup.sh)"

# The committed .bf is the expansion of its .poke, byte for byte. Same claim
# tier 9c makes for every routine, and the same reason: a .bf carries no
# comments, so the skeleton is the only artifact review can happen on.
run "every program is what its skeleton says" sh -c '
    BRAINSTEM_DIR=$1 sh tools/progbuild.sh --check' _ "$BS"

# A PROGRAM CARRIES ITS PROSE, AND THE PROSE IS INERT -- which is a stronger
# claim than the one this tier used to make and the reason it changed.
#
# It used to run brainstem's bsbf, which requires a committed file to hold
# nothing but the eight instructions and whitespace. That rule is right for
# brainstem's own fixtures, whose whole purpose is to prove bareness, and it
# was adopted here without noticing that THIS repository had already answered
# the question differently and better. Thirty routines carry their annotations
# in the committed .bf. Two programs beside them were a wall of "+" with no
# way in, and the stated reason -- that a program must run under any
# conforming interpreter and comments are an extension of the pinned one --
# was simply wrong: a comment is only an extension if its PROSE would execute,
# and tools/bflint exists to prove that it does not.
#
# So the check is now the same one the routines get. bflint extracts the
# instruction stream twice, once treating ";" as a comment to end of line and
# once not, and requires the two to be IDENTICAL. A full stop is an
# instruction and so is a comma, so that is a real property and not a
# formality -- it is why the prose in these files says "non_zero" and ends its
# sentences with a semicolon.
run "every program is portable brainfuck, prose and all" sh -c '
    ./tools/bflint programs/*.bf'
# AND THE PROSE DID NOT CHANGE THE PROGRAM. bflint proves the comments are
# inert; this proves they were not paid for by moving an instruction. Strip
# everything but the eight bytes from the committed file and from a BARE
# expansion of the same skeleton, and the two must match.
run "and adding it moved no instruction" sh -c '
    d=$(mktemp -d); rc=0
    for p in programs/*.poke; do
        sh "$1/tools/bfgen.sh" "$p" | tr -cd "><+-.,[]" > "$d/bare"
        tr -cd "><+-.,[]" < "${p%.poke}.bf" > "$d/laid"
        cmp -s "$d/bare" "$d/laid" || { echo "$p: the prose moved an instruction"; rc=1; }
    done
    rm -rf "$d"
    exit $rc' _ "$BS"

# AND THE DIGESTS ARE RIGHT, end to end. The program reads the bytes the shell
# handed the broker, spawns an interpreter on sha256/sha256.bf through that
# broker, relays them across a pipe and writes the digest back out.
#
# Three messages, each here for a reason. The EMPTY one is the boundary where
# the relay loop never runs its body at all. "abc" is FIPS 180-4. The hundred
# byte one spans TWO compression blocks, so it catches a length prefix that is
# wrong in a way a short message would hide -- and the prefix is the
# interesting part of this program, taken byte for byte out of a stat record.
# tools/bfprog.sh is the one place that knows how to RUN a program: a scratch
# directory, the routines it may spawn copied in by name, and the pinned broker
# on the other end of its stdin and stdout. A routine is run by bfi alone; a
# program cannot be, which is most of what makes it a program.
#
# It is a script and not a shell function here for a reason that has now bitten
# this file twice: these checks run under sh -c, and A CHILD SHELL DOES NOT
# INHERIT FUNCTIONS. The first version was a function, and it would have failed
# by producing an empty digest that compared unequal -- which reads as "the
# program is wrong" rather than "the harness is".
# The middle one is fed by a PIPE rather than a redirect, and that is the
# point of it being written differently from its neighbours. A program reads
# the broker's stdin sequentially and must never seek it; a regular file would
# let a seek succeed and hide the defect, where a pipe fails it outright. It
# is also the shape a reader will actually type -- something | hash -- so the
# suite ought to run it at least once.
bf_msg=$(mktemp -d)
: > "$bf_msg/empty"
printf 'a%.0s' $(seq 1 100) > "$bf_msg/a100"

run "a program hashes nothing at all, through the broker" sh -c '
    test "$(sh tools/bfprog.sh programs/sha256.bf < "$1" | ./tools/hx)" = "$2"' \
    _ "$bf_msg/empty" \
    e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855
run "a program hashes abc off a pipe, through the broker" sh -c '
    test "$(printf abc | sh tools/bfprog.sh programs/sha256.bf | ./tools/hx)" = "$1"' \
    _ ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad
run "a program hashes across two blocks, through the broker" sh -c '
    test "$(sh tools/bfprog.sh programs/sha256.bf < "$1" | ./tools/hx)" = "$2"' \
    _ "$bf_msg/a100" \
    2816597888e4a0d3a36b82b83316ab32680eb8f00f8cd3b904d681246d285a0e

# FROM OUTSIDE THE CHECKOUT, BY A RELATIVE PATH -- the one shape every other
# check here misses, because they all run from the repository root and so
# never notice that bfprog.sh cds to that root before it resolves anything.
# It did, and `bfsodium/tools/bfprog.sh bfsodium/programs/sha256.bf` typed one
# directory up therefore looked for bfsodium/bfsodium/programs/sha256.bf and
# reported a file that was plainly there as missing.
#
# An absolute path would NOT catch this and is the tempting way to write it.
# The bug is precisely the reinterpretation of a relative one, so the check
# has to leave the root and stay relative to be worth having.
run "a program runs from outside the checkout, by relative path" sh -c '
    repo=$(pwd); base=$(basename "$repo")
    cd .. || exit 1
    test "$(printf abc | sh "$base/tools/bfprog.sh" "$base/programs/sha256.bf" \
            | "$repo/tools/hx")" = "$1"' \
    _ ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad

# THE OVERSIZE REFUSAL, AND IT IS HERE FOR THE SECOND REASON RATHER THAN THE
# FIRST. It checks that 65536 bytes are refused instead of hashed modulo 65536
# into a plausible wrong digest -- but what it really guards is that the
# program STOPS. A brainfuck program cannot halt: brainstem answers the exit
# frame, closes the program stdin and waits for the interpreter, which runs on
# into whatever bytes follow. Everything after the refusal is inside a flag for
# that reason, and without it the replay emitted one write frame per buffered
# byte into a pipe nobody was reading, filled it, and deadlocked against
# waitpid.
#
# So a FAILURE HERE MAY PRESENT AS A HANG, and that is the point: this is the
# only check in the suite whose subject is a program that will not stop. It
# costs about twenty three seconds, nearly all of it the buffer walk, and it
# never reaches the hash -- the accepting side of the same boundary is 1862
# seconds and is recorded in programs/README.md rather than run here.
# THE GENERIC RUNNER, which is the other half of programs/. sha256's program
# hides sha256's calling convention behind an ordinary Unix interface and
# therefore cannot be generic about which convention it hides. run.bf takes
# the routine's NAME at run time and relays bytes both ways, so the caller
# does the framing and the same program drives every routine in the tree --
# including ones not written yet.
#
# Two routines with nothing in common are run through it deliberately. One
# would show that it works; two show that it is not secretly about sha256.
run "the runner drives sha256 by name, with the caller framing it" sh -c '
    test "$(printf "\\003\\000abc" | sh tools/bfrun.sh sha256.bf | ./tools/hx)" = "$1"' \
    _ ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad
run "and add8, which shares nothing with it" sh -c '
    test "$(printf "\\007\\005" | sh tools/bfrun.sh add8.bf | ./tools/hx)" = "0c00"'
run "and xor32, whose answer is four bytes rather than two" sh -c '
    test "$(printf "\\377\\000\\377\\000\\017\\017\\017\\017" | sh tools/bfrun.sh xor32.bf \
        | ./tools/hx)" = "f00ff00f"'
# A ROUTINE THAT IS NOT THERE MUST FAIL, NOT HANG, and this check is here
# because it did hang -- for two separate reasons, both of which were latent
# in programs/sha256 as well.
#
# The first: spawn SUCCEEDS for a name that does not exist, the child dies at
# exec, and the next write to its stdin returns PIPE with no payload. A reply
# read at an assumed length then swallows the next reply's first bytes and
# every frame after it is shifted. The second: a read of the child's stdout
# returns END with no payload, and a loop that took a data byte anyway waited
# for one that was never coming.
#
# The timeout is part of the check rather than a safety net. Without it a
# regression here stalls the suite for an hour inside bfprog.sh, which reads
# as the suite being broken rather than this program being wrong.
run "a routine that is not there fails instead of hanging" sh -c '
    rc=0; out=$(printf "x" | timeout 60 sh tools/bfrun.sh nosuch.bf) || rc=$?
    test "$rc" -ne 0 || { echo "exited 0 with no routine to run"; exit 1; }
    test "$rc" -ne 124 || { echo "timed out: it is hanging again"; exit 1; }
    test -z "$out" || { echo "produced output: $out"; exit 1; }
    exit 0'
# The same failure through the sha256 program, because the fix was needed in
# both and a check on only one would let the other regress quietly.
run "and neither does the sha256 program, with its routine missing" sh -c '
    d=$(mktemp -d); cp tools/bfi "$d/bfi"; cp programs/sha256.bf "$d/hash.bf"
    rc=0
    out=$( (cd "$d" && printf abc | timeout 60 "$1/build/brainstem" \
        --op-timeout 20000 -- ./bfi ./hash.bf) 2>/dev/null ) || rc=$?
    rm -rf "$d"
    test "$rc" -ne 124 || { echo "timed out: it is hanging again"; exit 1; }
    test "$rc" -ne 0 || { echo "exited 0 having hashed nothing"; exit 1; }
    test -z "$out" || { echo "produced output: $out"; exit 1; }
    exit 0' _ "$BS"

head -c 65536 /dev/urandom > "$bf_msg/over"
run "a program refuses an input too large for the length prefix, and stops" sh -c '
    rc=0; out=$(sh tools/bfprog.sh programs/sha256.bf < "$1") || rc=$?
    test "$rc" -eq 1 && test -z "$out"' \
    _ "$bf_msg/over"
rm -rf "$bf_msg"

echo
# TIER 8
echo "== design proofs (Cryptol) =="
# THIS TIER RUNS ON BOTH GUESTS, and for one commit it did not. The reasoning
# that took it off FreeBSD is worth keeping because it was half right, which
# is the dangerous kind.
#
# The argument was: a proof is a statement over bitvectors -- "for all x,
# reduceTail (foldOnce x) == x % p136" -- and quantifying over 2^136 inputs
# does not care which kernel asked. That is TRUE, and it still is. Running
# these eight twice buys almost nothing.
#
# The second half was that Cryptol is therefore not needed on that guest at
# all, because the dual oracle's values are pinned literals. That is FALSE.
# tools/dkat.sh runs `cryptol -b` ONCE PER VECTOR and compares the brainfuck
# against what the spec computes, live -- which is what makes it a dual oracle
# rather than a table of numbers somebody once generated. Tiers 2 and 4 are a
# hundred and fifty seven checks and every one of them needs it.
#
# The belief came from grepping THIS FILE for "cryptol", finding three sites,
# and concluding something about the suite. dkat.sh is a different file.
# FreeBSD answered with 156 failures in two tiers, which is what a plausible
# sentence looks like when a machine reads it.
#
# So Cryptol is installed on both guests -- security/hs-cryptol, quarterly, at
# the version guest-setup verifies against CRYPTOL_VERSION -- and once it is
# there, running these eight costs eight z3 invocations rather than a Haskell
# toolchain. At that price an exception is not worth its own documentation.
#
# WHAT SURVIVES is the platform in the summary below. That went in to make an
# asymmetric run legible and is worth keeping anyway: a count with no platform
# beside it is a number nobody can check.

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
# THE PLATFORM IS IN THE SUMMARY, and it is not decoration. It went in when
# one tier briefly declared its guest and two green runs could honestly differ
# in count; that is undone, both guests run all of it, and this stays -- a
# count with no platform beside it is a number nobody can check, and the run
# that disagreed with its sibling by 164 checks is the reason to keep saying
# which machine produced it. brainstem has named its platform since M0.
echo "passed $pass, failed $fail on $(uname -srm)"
[ "$fail" -eq 0 ] || exit 1
