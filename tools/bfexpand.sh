#!/bin/sh
# bfexpand.sh — expand a .skel into the committed brainfuck.
#
# It does exactly two mechanical things and makes no decisions:
#
#   Rn / Ln    expand to n copies of > or <, wherever they appear, including
#              inside a block such as [-R24+L24], and never inside a comment.
#              Every offset in a .skel is a number the author worked out and
#              wrote down; this only saves miscounting a run of forty six
#              arrows by hand, which is the error that broke two drafts.
#
#   @@NAME@@   pastes a verified routine, wrapped so the CALLER always enters
#              and leaves at the routine's base. The routine declares its own
#              entry and exit offsets in its "; INTERFACE" line, and the
#              wrapper walks in and back out. That is why every paste site in
#              every skeleton now reads the same way, instead of the author
#              having to remember that add32 wants base plus 8 while rotl32
#              wants base plus 4 -- an inconsistency that cost two drafts.
#
# It is NOT a compiler: it chooses no tape layout, computes no offset from a
# symbolic name, and generates no loop. The emitted .bf is the committed
# artifact and every check runs on it.
#
#   bfexpand.sh FILE.skel > FILE.bf
set -eu
here=$(cd "$(dirname "$0")" && pwd); repo=$(cd "$here/.." && pwd)

rep() { _i=0; while [ "$_i" -lt "$2" ]; do printf '%s' "$1"; _i=$((_i+1)); done; }

# the computational middle of a routine: after its input line, before its output
body() { awk '/^,>,/{f=1;next} /^; emit/{f=0} f' "$1"; }

import() {
    _if=$(grep -m1 '^; INTERFACE' "$1" || true)
    _en=$(printf '%s' "$_if" | sed -n 's/.*entry=\([0-9]*\).*/\1/p')
    _ex=$(printf '%s' "$_if" | sed -n 's/.*exit=\([0-9]*\).*/\1/p')
    [ -n "$_en" ] || { echo "bfexpand: $1 has no INTERFACE line" >&2; exit 1; }
    printf '; walk in to this routine entry offset\n  '; rep '>' "$_en"; printf '\n'
    body "$1"
    printf '; walk back out to the routine base\n  '; rep '<' "$_ex"; printf '\n'
}

while IFS= read -r line; do
    case "$line" in
        '@@ADD32@@')  import "$repo/chacha20/add32.bf";  continue ;;
        '@@XOR32@@')  import "$repo/chacha20/xor32.bf";  continue ;;
        '@@ROTL32@@') import "$repo/chacha20/rotl32.bf"; continue ;;
    esac
    case "$line" in
        ';'*) printf '%s\n' "$line" ;;
        *)    printf '%s\n' "$line" | perl -pe 's/R(\d+)/">" x $1/ge; s/L(\d+)/"<" x $1/ge; s/([><]{40})(?=[><])/$1 . "\n  "/ge' ;;
    esac
done < "$1"
