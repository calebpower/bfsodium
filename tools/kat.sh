#!/bin/sh
# kat.sh — one known-answer test through the pinned interpreter.
#
#   kat.sh PROGRAM.bf INPUT_HEX EXPECT_HEX [LABEL]
#
# Feeds INPUT_HEX (as raw bytes) to PROGRAM.bf via bfi, renders stdout as hex,
# and compares to EXPECT_HEX. Exit 0 on match, 1 on mismatch. This is oracle A
# (the published/expected vector); the Cryptol oracle is applied separately.
set -eu

here=$(cd "$(dirname "$0")" && pwd)
repo=$(cd "$here/.." && pwd)
bfi="$repo/tools/bfi"
hx="$repo/tools/hx"

prog="$1"; in_hex="$2"; want="$3"; label="${4:-$1}"

got=$(printf '%s' "$in_hex" | "$hx" -r | "$bfi" "$prog" | "$hx")

if [ "$got" = "$want" ]; then
    echo "PASS $label"
else
    echo "FAIL $label"
    echo "   in=$in_hex"
    echo " want=$want"
    echo "  got=$got"
    exit 1
fi
