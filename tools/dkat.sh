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

# THE ANSWER COMES FROM out/cry.answers IF IT IS THERE, and starting a
# cryptol per vector if it is not. tools/dkbatch.sh asks all 552 questions in
# one process because the whole 7.4 seconds of an invocation is startup; see
# the measurement in its header.
#
# A MISSING PAIR IS A FAILURE AND NOT A FALLBACK. If the answer file exists
# but does not hold this question, something has gone wrong with the batch
# and the right response is to say so loudly -- not to quietly start cryptol
# and paper over it, because a fallback that works hides the bug that made it
# necessary, and 552 vectors would go on passing while the batch rotted.
answers="$repo/out/cry.answers"
if [ -f "$answers" ]; then
    cry=$(awk -F'	' -v i="$in_hex" -v e="$expr"               '$1 == i && $2 == e { print $3; found = 1; exit } END { exit !found }'           "$answers") || {
        echo "FAIL[cryptol] $label  no answer for $expr on $in_hex in out/cry.answers" >&2
        exit 1
    }
else
    tmp=$(mktemp)
    { echo ':set base=16'
      echo ":l $spec"
      echo "join ($expr (split (0x$in_hex : [$ibits])))"
    } > "$tmp"
    cry=$(cryptol -b "$tmp" 2>/dev/null | grep -Eo '0x[0-9a-fA-F]+' | tail -1 | sed 's/^0x//')
    rm -f "$tmp"
fi

fail=0
[ "$got" = "$want" ] || { echo "FAIL[vector]  $label  got=$got want=$want"; fail=1; }
[ "$got" = "$cry"  ] || { echo "FAIL[cryptol] $label  got=$got cry=$cry"; fail=1; }
if [ "$fail" = 0 ]; then echo "PASS $label  (bf = vector = cryptol = $got)"; else exit 1; fi
