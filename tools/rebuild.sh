#!/bin/sh
# rebuild.sh — expand every skeleton, in an order that respects the pastes.
#
# A skeleton pastes the BODY of another routine's .bf, so a callee has to be
# expanded before its callers or the caller embeds a stale copy. Rebuilding
# everything in directory order got this wrong the first time it mattered:
# blockloop.bf was written from the previous qrloop.bf, and only the suite's
# "regenerates" check noticed.
#
# Rather than hard-code a dependency order that would rot the moment a new paste
# is added, this iterates to a FIXPOINT: expand everything, and if any file
# changed, go round again. A correct dependency graph converges in as many
# passes as it is deep; failing to converge means a cycle, which is a real
# error and is reported as one rather than looped on forever.
#
#   rebuild.sh          expand until stable
set -eu
here=$(cd "$(dirname "$0")" && pwd); repo=$(cd "$here/.." && pwd)
cd "$repo"

max=10
pass=1
while [ "$pass" -le "$max" ]; do
    changed=0
    for s in */*.skel; do
        out="${s%.skel}.bf"
        sh tools/bfexpand.sh "$s" > "$out.new"
        if [ -f "$out" ] && cmp -s "$out.new" "$out"; then
            rm -f "$out.new"
        else
            mv "$out.new" "$out"
            changed=$((changed + 1))
            echo "  pass $pass: $out"
        fi
    done
    [ "$changed" -eq 0 ] && { echo "stable after $pass pass(es)"; exit 0; }
    pass=$((pass + 1))
done

echo "rebuild: still changing after $max passes; the pastes have a cycle" >&2
exit 1
