#!/bin/sh
# dkat.sh — one dual-oracle known-answer test.
#
#   dkat.sh PROG.bf INPUT_HEX EXPECT_HEX CRYPTOL_EXPR [LABEL]
#
# The brainfuck output must equal BOTH:
#   A. EXPECT_HEX      — the pinned/published vector, and
#   B. the Cryptol spec's CRYPTOL_EXPR applied to the same input bytes.
# CRYPTOL_EXPR is a function of the input byte-vector defined in
# spec/bfsodium.cry, e.g.  add32Run  or  (rotl32Run 16).
set -eu

here=$(cd "$(dirname "$0")" && pwd)
repo=$(cd "$here/.." && pwd)
bfi="$repo/tools/bfi"; hx="$repo/tools/hx"; spec="$repo/spec/bfsodium.cry"

prog="$1"; in_hex="$2"; want="$3"; expr="$4"; label="${5:-$1}"
ibits=$(( ${#in_hex} / 2 * 8 ))

got=$(printf '%s' "$in_hex" | "$hx" -r | "$bfi" "$prog" | "$hx")

tmp=$(mktemp)
{ echo ':set base=16'
  echo ":l $spec"
  echo "join ($expr (split (0x$in_hex : [$ibits])))"
} > "$tmp"
cry=$(cryptol -b "$tmp" 2>/dev/null | grep -Eo '0x[0-9a-fA-F]+' | tail -1 | sed 's/^0x//')
rm -f "$tmp"

fail=0
[ "$got" = "$want" ] || { echo "FAIL[vector]  $label  got=$got want=$want"; fail=1; }
[ "$got" = "$cry"  ] || { echo "FAIL[cryptol] $label  got=$got cry=$cry"; fail=1; }
if [ "$fail" = 0 ]; then echo "PASS $label  (bf = vector = cryptol = $got)"; else exit 1; fi
