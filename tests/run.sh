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
run "bflint self-test" ./tools/bflint --selftest
for f in chacha20/*.bf; do run "lint $f" ./tools/bflint "$f"; done

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

dk chacha20/quarterround.bf 1111111104030201436f8d9b67452301 f4922aeacef81ccb2e478145bbc48158 qrRun "quarterround RFC 8439 section 2.2.1"

echo
echo "== summary =="
echo "passed $pass, failed $fail"
[ "$fail" -eq 0 ] || exit 1
