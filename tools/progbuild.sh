#!/bin/sh
# progbuild.sh -- expand every program in programs/, WITH ITS PROSE.
#
#   sh tools/progbuild.sh
#
# tools/rebuild.sh does this for routines, from .skel through bfexpand. A
# program is a .poke and its expander lives in the pinned brainstem checkout,
# so it needs its own script -- and it needs three steps rather than one.
#
# WHY IT IS NOT ONE STEP, which is the whole point of this file.
#
#   1. bfgen --annotate carries the .poke's "#" comments through as ";"
#      comments. Without the flag they are dropped, which is right for
#      brainstem's own fixtures -- a fixture exists to prove a file is nothing
#      but the eight instructions -- and wrong here, because thirty routines
#      in this repository carry their annotations in the committed .bf and it
#      would be strange for the two programs beside them not to.
#
#   2. bflint --fix makes the prose portable. A full stop IS an instruction
#      and so is a comma, so English dropped into brainfuck executes: the
#      sentence you are reading would perform two outputs and an input. The
#      lint rewrites those bytes to safe lookalikes and then PROVES the file
#      still portable by comparing the instruction stream with ";" comments
#      stripped against the stream with them left in. That check is tier 9
#      and it runs on every .bf here.
#
#   3. bflayout turns "annotation above its operation", which is how a
#      skeleton is written, into "brainfuck on the left and English on the
#      right", which is how one is read.
#
# THE INSTRUCTION STREAM MUST NOT MOVE, and that is checked here rather than
# hoped for: the laid-out file is compared against a bare expansion of the
# same .poke, instruction for instruction. Adding prose to a program is only
# acceptable if it cannot change the program, and this is the line that says
# so. The suite checks it again.
#
# The routine style tiers do NOT run on programs/. A routine declares an
# INTERFACE and a tape map because it is pasted into callers; a program is
# the outermost thing there is and declares neither, so bfstyle's rules would
# be demanding furniture that has no meaning here. Legibility and portability
# -- bflayout and bflint -- are what carry over, and they are what this does.
#   sh tools/progbuild.sh --check    compare only; write nothing
#
# --check is what the suite runs. A regeneration check that REWROTE the tree
# would pass by fixing what it was meant to report, which is the one thing a
# provenance tier must never do.
set -eu

check=no
bad=0
if [ "${1:-}" = "--check" ]; then check=yes; shift; fi
[ $# -eq 0 ] || { echo "usage: progbuild.sh [--check]" >&2; exit 2; }

here=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
repo=$(CDPATH= cd -- "$here/.." && pwd)
cd "$repo"

BS=${BRAINSTEM_DIR:-/opt/brainstem}
[ -r "$BS/tools/bfgen.sh" ] || {
    echo "progbuild: no expander at $BS/tools/bfgen.sh" >&2
    echo "progbuild: tools/guest-setup.sh --build provisions it" >&2
    exit 2
}
[ -x tools/bflint ] || { echo "progbuild: tools/bflint is not built" >&2; exit 2; }

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

for p in programs/*.poke; do
    out="${p%.poke}.bf"

    sh "$BS/tools/bfgen.sh" --annotate "$p" > "$tmp/ann"
    ./tools/bflint --fix "$tmp/ann" >/dev/null
    perl tools/bflayout.pl "$tmp/ann" > "$tmp/laid"

    # The proof that the prose is inert. Anything but the eight instructions
    # is dropped from both and the remainder must match byte for byte.
    sh "$BS/tools/bfgen.sh" "$p" > "$tmp/bare"
    tr -cd '><+-.,[]' < "$tmp/laid" > "$tmp/a"
    tr -cd '><+-.,[]' < "$tmp/bare" > "$tmp/b"
    if ! cmp -s "$tmp/a" "$tmp/b"; then
        echo "progbuild: $out would change the program; the prose is not inert" >&2
        exit 1
    fi

    if [ -f "$out" ] && cmp -s "$tmp/laid" "$out"; then
        [ "$check" = yes ] || echo "  unchanged $out"
    elif [ "$check" = yes ]; then
        echo "progbuild: $out is not what this script makes of $p" >&2
        bad=1
    else
        cp "$tmp/laid" "$out"
        echo "  wrote $out"
    fi
done

[ "$bad" -eq 0 ] || exit 1
[ "$check" = yes ] && echo "progbuild: every program matches its skeleton"
exit 0
