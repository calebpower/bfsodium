#!/bin/sh
# bfexpand.sh — expand the Rn and Ln notation in a .skel into literal brainfuck,
# and paste in the verified routine bodies named by @@NAME@@ markers.
#
# This is a NOTATION expander, not a compiler, and the distinction is the whole
# reason the project had to course correct. It makes no decision: it does not
# choose a tape layout, does not compute an offset from a symbolic name, and
# does not generate a loop. Every offset in a .skel is a number the author
# worked out and wrote down; Rn simply saves miscounting a run of forty six
# arrows by hand, which is precisely the error that broke the first draft of
# the looped quarter round.
#
# Rn and Ln are expanded wherever they appear, including inside a block such as
# [-R24+L24], and never inside a comment line.
#
# The emitted .bf is the committed artifact and is what every check runs on.
#
#   bfexpand.sh FILE.skel > FILE.bf
set -eu
here=$(cd "$(dirname "$0")" && pwd); repo=$(cd "$here/.." && pwd)

body() { awk '/^,>,/{f=1;next} /^; emit/{f=0} f' "$1"; }

while IFS= read -r line; do
    case "$line" in
        '@@ADD32@@')  body "$repo/chacha20/add32.bf"; continue ;;
        '@@XOR32@@')  body "$repo/chacha20/xor32.bf"; continue ;;
        '@@ROTL32@@') body "$repo/chacha20/rotl32.bf"; continue ;;
    esac
    case "$line" in
        ';'*) printf '%s\n' "$line" ;;
        *)    printf '%s\n' "$line" | perl -pe 's/R(\d+)/">" x $1/ge; s/L(\d+)/"<" x $1/ge; s/([><]{40})(?=[><])/$1 . "\n  "/ge' ;;
    esac
done < "$1"
