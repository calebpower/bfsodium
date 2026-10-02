#!/bin/sh
# dkprobe.sh — prove that out/cry.answers is load-bearing.
#
# tools/dkat.sh reads its Cryptol answer from out/cry.answers instead of
# starting a cryptol per vector. That is only sound if a WRONG answer in the
# file actually turns a vector red. If the lookup were broken -- reading the
# wrong column, matching nothing and defaulting to empty, comparing a string
# against itself -- all 552 vectors would still pass on their pinned values
# alone, and the suite would be running half an oracle while claiming two.
#
# So: corrupt the first answer, run that vector, and require it to FAIL.
# Restore the file either way.
set -u

here=$(cd "$(dirname "$0")" && pwd)
repo=$(cd "$here/.." && pwd)
answers="$repo/out/cry.answers"
[ -f "$answers" ] || { echo "dkprobe: out/cry.answers is missing" >&2; exit 1; }

tab=$(printf '\t')
first=$(head -1 "$answers")
inhex=$(printf '%s' "$first" | cut -d"$tab" -f1)
expr=$(printf '%s' "$first" | cut -d"$tab" -f2)
real=$(printf '%s' "$first" | cut -d"$tab" -f3)

# the program and the pinned vector for that same dk line
line=$(grep -m1 "^[[:space:]]*dk[[:space:]]" "$repo/tests/run.sh")
prog=$(printf '%s' "$line" | awk '{print $2}')
want=$(printf '%s' "$line" | awk '{print $4}')

cp "$answers" "$answers.bak"
restore() { mv -f "$answers.bak" "$answers"; }

# a wrong answer of the right shape
bad=$(printf '%s' "$real" | tr '0123456789abcdef' '1234567890fedcba')
[ "$bad" != "$real" ] || bad="deadbeef"
printf '%s\t%s\t%s\n' "$inhex" "$expr" "$bad" > "$answers"
tail -n +2 "$answers.bak" >> "$answers"

if sh "$repo/tools/dkat.sh" "$prog" "$inhex" "$want" "$expr" dkprobe >/dev/null 2>&1; then
    restore
    echo "dkprobe: a corrupted answer did NOT fail its vector" >&2
    echo "         out/cry.answers is not being read; the cryptol half of" >&2
    echo "         every dual-oracle check is vacuous" >&2
    exit 1
fi

restore

# and the honest polarity: with the file intact the same vector must pass,
# or the probe above proves nothing except that the vector is broken.
if ! sh "$repo/tools/dkat.sh" "$prog" "$inhex" "$want" "$expr" dkprobe >/dev/null 2>&1; then
    echo "dkprobe: the vector fails even with the correct answer" >&2
    exit 1
fi

echo "dkprobe: a wrong answer fails and the right one passes"
