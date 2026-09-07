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

# The computational middle of a routine: after its input, before its output.
#
# A routine's read is not always one line -- rowrot reads sixty four bytes over
# four lines with a comment between each -- and stopping at the first of them
# left forty seven ",>" pairs in the paste, which walked the caller's pointer
# forty seven cells off its base. So the prologue ends at the first line that is
# neither a read line nor a comment; comments seen meanwhile are held back and
# printed only if that line arrives, so the routine's own first remark survives
# the paste but the "; continued" chatter of its read does not.
body() {
    awk '
        { c = $0; sub(/;.*/, "", c); sub(/[ \t]+$/, "", c) }
        !f && c ~ /^[ \t]*[,>]+$/ && c ~ /,/ { f = 1; pre = 1; next }
        !f                          { next }
        pre && c ~ /^[ \t]*[,>]+$/ && c ~ /,/ { nb = 0; next }
        pre && /^[ \t]*;/           { buf[nb++] = $0; next }
        pre                         { pre = 0
                                      for (i = 0; i < nb; i++) print buf[i]
                                      nb = 0 }
        /^; emit/                   { f = 0 }
        f' "$1"
}

# A routine states its contracts relative to its own base, as "ptr=+24", so the
# same line is true wherever the routine is pasted. The committed brainfuck must
# not carry that notation: '+' is an instruction, and a canonical interpreter
# with no ';' rule would execute every one of them. So the offsets are resolved
# to absolute numbers here -- by the paste base when imported, and by zero when
# a routine is written out on its own.
rebase() {
    awk -v b="$1" '
        /^; ASSERT ptr=/  { n=$3; sub(/ptr=/,"",n); sub(/^\+/,"",n)
                            print "; ASSERT ptr=" n+b; next }
        /^; ASSERT zero / { split($4,p,":"); sub(/^\+/,"",p[1]); sub(/^\+/,"",p[2])
                            print "; ASSERT zero " p[1]+b ":" p[2]+b; next }
        { print }'
}

import() {
    _base=$2
    case "$_base" in
        ''|*[!0-9]*)
            echo "bfexpand: $1 pasted with no base; every paste site states the" >&2
            echo "          cell its routine's zero lands on, so the routine's" >&2
            echo "          contracts can be rewritten to that base" >&2
            exit 1 ;;
    esac
    _if=$(grep -m1 '^; INTERFACE' "$1" || true)
    _en=$(printf '%s' "$_if" | sed -n 's/.*entry=\([0-9]*\).*/\1/p')
    _ex=$(printf '%s' "$_if" | sed -n 's/.*exit=\([0-9]*\).*/\1/p')
    [ -n "$_en" ] || { echo "bfexpand: $1 has no INTERFACE line" >&2; exit 1; }
    printf '; walk in to this routine entry offset\n  '; rep '>' "$_en"; printf '\n'
    body "$1" | rebase "$_base"
    printf '; walk back out to the routine base\n  '; rep '<' "$_ex"; printf '\n'
}

# The expansion is written to a file and laid out afterwards, rather than piped
# straight into the layout pass. A pipeline runs its left hand side in a subshell,
# so the hard error for a paste site with no base exited that subshell and the
# pipeline reported the layout's success instead. A redirection keeps the loop in
# THIS shell, where "exit 1" still means what it says.
raw=$(mktemp)
trap 'rm -f "$raw"' EXIT HUP INT TERM

{
while IFS= read -r line; do
    case "$line" in
        '@@ADD136@@'*)  import "$repo/poly1305/add136.bf" "${line##* }"; continue ;;
        '@@DBL136@@'*)   import "$repo/poly1305/dbl136.bf" "${line##* }"; continue ;;
        '@@HALVE136@@'*) import "$repo/poly1305/halve136.bf" "${line##* }"; continue ;;
        '@@REDUCEP136@@'*) import "$repo/poly1305/reducep136.bf" "${line##* }"; continue ;;
        '@@FOLD136@@'*) import "$repo/poly1305/fold136.bf" "${line##* }"; continue ;;
        '@@ADD32@@'*)   import "$repo/chacha20/add32.bf"  "${line##* }"; continue ;;
        '@@XOR32@@'*)   import "$repo/chacha20/xor32.bf"  "${line##* }"; continue ;;
        '@@ROTL32@@'*)  import "$repo/chacha20/rotl32.bf" "${line##* }"; continue ;;
        '@@BLOCK@@'*)   import "$repo/chacha20/blockloop.bf" "${line##* }"; continue ;;
        '@@QR@@'*)      import "$repo/chacha20/qrloop.bf"  "${line##* }"; continue ;;
        '@@ROWROT@@'*)  import "$repo/chacha20/rowrot.bf"  "${line##* }"; continue ;;
        '@@STAGGER@@'*) import "$repo/chacha20/stagger.bf" "${line##* }"; continue ;;
    esac
    case "$line" in
        '; ASSERT '*) printf '%s\n' "$line" | rebase 0 ;;
        ';'*)         printf '%s\n' "$line" ;;
        *)            printf '%s\n' "$line" | perl -pe 's{^([^;]*)}{ my $c = $1; $c =~ s/R(\d+)/">" x $1/ge; $c =~ s/L(\d+)/"<" x $1/ge; $c }e' ;;
    esac
done < "$1"
} > "$raw"

perl "$here/bflayout.pl" < "$raw"
