#!/bin/sh
# tests/run.sh — the whole bfsodium suite. This is what `reaper test` gates on.
#
# Tiers exercised here (CONVENTIONS section 8):
#   1 interpreter self-test      the oracle of record must itself be sound
#   2 idiom boundary KATs        edges: carry cascade, top bit wrap, identities
#   4 golden vector, dual oracle  brainfuck == pinned vector == Cryptol spec
#   9 legibility and portability  bflint, itself self-tested first
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
    if timeout 120 ./tools/dkat.sh "$1" "$2" "$3" "$4" "$5" >/dev/null 2>&1
    then echo "PASS $5"; pass=$((pass+1)); else echo "FAIL $5"; fail=$((fail+1)); fi
}

echo "== build =="
cc -O2 -std=c99 -o tools/bfi tools/bfi.c
cc -O2 -std=c99 -o tools/hx  tools/hx.c
cc -O2 -std=c99 -o tools/bflint tools/bflint.c
cc -O2 -std=c99 -o tools/bfstyle tools/bfstyle.c
chmod +x tools/kat.sh tools/dkat.sh
echo "built"

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
for f in chacha20/*.bf poly1305/*.bf; do run "lint $f" ./tools/bflint "$f"; done
for f in chacha20/*.bf poly1305/*.bf; do run "style $f" ./tools/bfstyle "$f"; done

echo
echo "== tiers 2 and 4: primitives, dual oracle =="
dk chacha20/add32.bf 1200000034000000 46000000 add32Run "add32 18+52"
dk chacha20/add32.bf ffffffff01000000 00000000 add32Run "add32 carry cascade"
dk chacha20/add32.bf ff00000001000000 00010000 add32Run "add32 cross byte carry"
dk chacha20/add32.bf 7856341211111111 89674523 add32Run "add32 mixed"
dk chacha20/add32.bf 0000000000000000 00000000 add32Run "add32 zero"
dk chacha20/add32.bf ffffffffffffffff feffffff add32Run "add32 max plus max"

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

dk chacha20/blockcore.bf 000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f01000000000000090000004a00000000 10f1e7e4d13b5915500fdd1fa32071c4c7d1f4c733c068030422aa9ac3d46c4ed2826446079faa0914c2d705d98b02a2b5129cd1de164eb9cbd083e8a2503c4e blockRun "block function through the emitter"

dk chacha20/stream.bf 000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f01000000000000000000004a0000000072004c616469657320616e642047656e746c656d656e206f662074686520636c617373206f66202739393a204966204920636f756c64206f6666657220796f75206f6e6c79206f6e652074697020666f7220746865206675747572652c2073756e73637265656e20776f756c642062652069742e 6e2e359a2568f98041ba0728dd0d6981e97e7aec1d4360c20a27afccfd9fae0bf91b65c5524733ab8f593dabcd62b3571639d624e65152ab8f530c359f0861d807ca0dbf500d6a6156a38e088a22b65e52bc514d16ccf806818ce91ab77937365af90bbf74a35be6b40b8eedf2785e42874d streamRun "stream cipher RFC 8439 section 2.4.2"

dk chacha20/block.bf 000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f01000000000000090000004a00000000 10f1e7e4d13b5915500fdd1fa32071c4c7d1f4c733c068030422aa9ac3d46c4ed2826446079faa0914c2d705d98b02a2b5129cd1de164eb9cbd083e8a2503c4e blockRun "block function RFC 8439 section 2.3.2"

dk chacha20/rowrot.bf 000000000100000002000000030000000400000005000000060000000700000008000000090000000a0000000b0000000c0000000d0000000e0000000f000000 0100000002000000030000000000000005000000060000000700000004000000090000000a0000000b000000080000000d0000000e0000000f0000000c000000 rowrotRun "row rotation  each row left by one word"

dk chacha20/qrloop.bf 1111111104030201436f8d9b67452301 f4922aeacef81ccb2e478145bbc48158 qrRun "quarter round as a loop  RFC 8439 section 2.2.1"

dk poly1305/add136.bf 01000000000000000000000000000000000100000000000000000000000000000000 0200000000000000000000000000000000 add136Run "add136 one plus one"
dk poly1305/add136.bf ffffffffffffffffffffffffffffffffff0100000000000000000000000000000000 0000000000000000000000000000000000 add136Run "add136 full carry cascade"
dk poly1305/add136.bf ff000000000000000000000000000000000100000000000000000000000000000000 0001000000000000000000000000000000 add136Run "add136 cross byte carry"
dk poly1305/add136.bf 0000000000000000000000000000000000ffffffffffffffffffffffffffffffffff ffffffffffffffffffffffffffffffffff add136Run "add136 zero plus max"

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

dk poly1305/poly1305.bf 85d6be7857556d337f4452fe42d506a80103808afb0db2fd4abff6af4149f51b220043727970746f6772617068696320466f72756d2052657365617263682047726f7570 a8061dc1305136c6c22b8baf0c0127a9 poly1305Run34 "poly1305 RFC 8439 section 2.5.2"

echo
echo "== tier 5: declared contracts enforced =="
tmpc=$(mktemp -d)
printf "; IO none\n; TAPE MAP @0x00\n; three right\n  >>>\n; ASSERT ptr=5\n  +\n" > "$tmpc/bad.bf"
printf "; IO none\n; TAPE MAP @0x00\n; dirty a cell\n  >>>+<<<\n; ASSERT zero 0:5\n  +\n" > "$tmpc/dirty.bf"
run "contract checker catches a wrong pointer" sh -c "BFI_CONTRACTS=1 ./tools/bfi $tmpc/bad.bf </dev/null 2>/dev/null; test \$? -eq 4"
run "contract checker catches dirty scratch" sh -c "BFI_CONTRACTS=1 ./tools/bfi $tmpc/dirty.bf </dev/null 2>/dev/null; test \$? -eq 4"
run "contracts are inert without the flag" sh -c "./tools/bfi $tmpc/bad.bf </dev/null >/dev/null 2>&1"
rm -rf "$tmpc"
run "qrloop honours its declared contracts" sh -c "printf 1111111104030201436f8d9b67452301 | ./tools/hx -r | BFI_CONTRACTS=1 ./tools/bfi chacha20/qrloop.bf >/dev/null"

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

echo
echo "== summary =="
echo "passed $pass, failed $fail"
[ "$fail" -eq 0 ] || exit 1
