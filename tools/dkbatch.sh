#!/bin/sh
# dkbatch.sh — ask Cryptol all 552 questions in ONE process.
#
#   sh tools/dkbatch.sh            writes out/cry.answers
#
# tools/dkat.sh used to start a fresh cryptol per vector. Measured in the
# container: a cold invocation is 7,401 ms and TWO HUNDRED expressions in one
# process is 7,348 ms, so the marginal cost of an expression is about 36 ms
# and the whole 7.4 seconds is startup. At 552 vectors that is 68 minutes of
# the gate spent loading spec/bfsodium.cry over and over, against 28 seconds
# of actually answering.
#
# WHY THIS CAN READ tests/run.sh AT ALL: every one of the 552 `dk` lines has
# literal arguments. Not one interpolates a shell variable, so the set of
# questions is a static property of the file and no two-pass run or collect
# mode is needed. If that ever stops being true the extraction below will
# quietly miss a line, which is what the count check in tests/run.sh is for.
#
# THE ANSWER FILE IS NOT COMMITTED. It lives in out/, which .gitignore
# already covers, and it is rebuilt inside every suite run. A checked-in
# answer file would turn the second oracle into a third pinned vector, which
# is the thing the dual oracle exists to avoid.
set -eu

here=$(cd "$(dirname "$0")" && pwd)
repo=$(cd "$here/.." && pwd)
spec="$repo/spec/bfsodium.cry"
out="$repo/out/cry.answers"
mkdir -p "$repo/out"

script=$(mktemp)
pairs=$(mktemp)
trap 'rm -f "$script" "$pairs"' EXIT

# field 2 is the input hex, field 4 the Cryptol expression; an expression may
# be parenthesised and contain spaces, so take everything from field 4 up to
# the quoted label.
awk '
    /^[[:space:]]*dk[[:space:]]/ {
        line = $0
        sub(/^[[:space:]]*dk[[:space:]]+/, "", line)
        n = split(line, f, /[[:space:]]+/)
        inhex = f[2]
        expr = ""
        for (i = 4; i <= n; i++) {
            if (f[i] ~ /^"/) break
            expr = (expr == "" ? f[i] : expr " " f[i])
        }
        print inhex "\t" expr
    }
' "$repo/tests/run.sh" > "$pairs"

n=$(grep -c . "$pairs" || true)
[ "$n" -gt 0 ] || { echo "dkbatch: no dk lines found in tests/run.sh" >&2; exit 1; }

{
    echo ':set base=16'
    echo ":l $spec"
    while IFS="$(printf '\t')" read -r inhex expr; do
        [ -n "$inhex" ] || continue
        bits=$(( ${#inhex} / 2 * 8 ))
        echo "join ($expr (split (0x$inhex : [$bits])))"
    done < "$pairs"
} > "$script"

# One process. An erroring expression prints its complaint and cryptol keeps
# going, so a bad line costs one answer rather than all of them -- which is
# exactly why the row count below has to be checked rather than assumed.
cryptol -b "$script" 2>/dev/null \
    | grep -Eo '0x[0-9a-fA-F]+' \
    | sed 's/^0x//' > "$out.raw"

got=$(grep -c . "$out.raw" || true)
if [ "$got" -ne "$n" ]; then
    echo "dkbatch: asked $n questions and got $got answers" >&2
    echo "dkbatch: refusing to write a short answer file; the suite would" >&2
    echo "         then skip the cryptol half of every missing vector" >&2
    rm -f "$out.raw"
    exit 1
fi

paste "$pairs" "$out.raw" > "$out"
rm -f "$out.raw"
echo "dkbatch: $n answers in one cryptol invocation"
