# bfemit.sh — the shared emitter used by every bfsodium assembler.
#
# Sourced, not run. It exists so the assemblers cannot drift from each other:
# style consistency across generated files is checked by tools/bfstyle, and the
# only way to keep three generators honest is to give them one implementation.
#
# The canonical style it emits (CONVENTIONS section 6):
#   annotations are standalone lines starting at column 0 with ';'
#   code lines are indented two spaces and never carry a trailing annotation
#   long pointer runs are chunked, and every chunk group is annotated, so no
#   run of code lines goes unexplained
#
# Callers must set, before sourcing:
#   W      workspace base the embedded primitive bodies see as their cell 0
#   TB     four copy temps for operands
#   ADD XOR ROTL   the primitive bodies, lifted verbatim from the .bf files
# and may set CHUNK (defaults to 40).

: "${CHUNK:=40}"

# erun: a run of $2 copies of $1, annotated and chunked across lines.
erun() {
    [ "$2" -le 0 ] && return 0
    case "$1" in
        '>') printf '; travel %d cells right\n' "$2" ;;
        '<') printf '; travel %d cells left\n' "$2" ;;
        '+') printf '; add %d\n' "$2" ;;
        '-') printf '; subtract %d\n' "$2" ;;
        *)   printf '; %d steps\n' "$2" ;;
    esac
    _n=$2
    while [ "$_n" -gt 0 ]; do
        _c=$_n; [ "$_c" -gt "$CHUNK" ] && _c=$CHUNK
        printf '  '; _i=0; while [ $_i -lt $_c ]; do printf '%s' "$1"; _i=$((_i+1)); done
        printf '\n'; _n=$(( _n - _c ))
    done
}
# note: a standalone annotation line
note() { printf '; %s\n' "$1"; }
# code: a bare code line, indented, never annotated inline
code() { printf '  %s\n' "$1"; }

goto() {
    [ "$1" -eq "$2" ] && return 0
    if [ "$2" -gt "$1" ]; then erun ">" $(( $2 - $1 )); else erun "<" $(( $1 - $2 )); fi
}
mvn() {   # move $3 bytes from $1 to $2, source consumed; ends at $1+$3-1
    if [ "$2" -gt "$1" ]; then _d=$(( $2 - $1 )); _f=">"; _b="<"; else _d=$(( $1 - $2 )); _f="<"; _b=">"; fi
    _j=0; while [ $_j -lt $3 ]; do
        note "$(printf 'move byte %d of @%03x to @%03x' "$_j" $(( $1 + _j )) $(( $2 + _j )))"
        code '[-'; erun "$_f" "$_d"; code '+'; erun "$_b" "$_d"
        if [ $_j -lt $(( $3 - 1 )) ]; then code ']>'; else code ']'; fi
        _j=$((_j+1))
    done
}
cpn() {   # copy $3 bytes $1 -> $2 preserving the source, staged through $4
    # The destination may be BELOW the source (the stream cipher rebuilds its
    # state from a key held above it), so the first leg's direction is computed,
    # not assumed. The staging temps at $4 must sit above both.
    if [ "$2" -gt "$1" ]; then _dd=">"; _d=$(( $2 - $1 )); else _dd="<"; _d=$(( $1 - $2 )); fi
    _t=$(( $4 - $1 )); _g=$(( $4 - $2 ))
    _j=0; while [ $_j -lt $3 ]; do
        note "$(printf 'copy byte %d of @%03x to @%03x and to a temp' "$_j" $(( $1 + _j )) $(( $2 + _j )))"
        code '[-'; erun "$_dd" "$_d"; code '+'; erun ">" "$_g"; code '+'; erun "<" "$_t"
        if [ $_j -lt $(( $3 - 1 )) ]; then code ']>'; else code ']'; fi
        _j=$((_j+1))
    done
    note "walk to the temps"; erun ">" $(( $4 - $1 - $3 + 1 ))
    _j=0; while [ $_j -lt $3 ]; do
        note "$(printf 'put temp byte %d back into @%03x' "$_j" $(( $1 + _j )))"
        code '[-'; erun "<" "$_t"; code '+'; erun ">" "$_t"
        if [ $_j -lt $(( $3 - 1 )) ]; then code ']>'; else code ']'; fi
        _j=$((_j+1))
    done
}
mv4() { mvn "$1" "$2" 4; }
cp4() { cpn "$1" "$2" 4 "$TB"; }

# Ops. Every op is entered with the pointer at cell 0 and leaves it at cell 0,
# so ops compose by concatenation (CONVENTIONS section 4).
add_op() {   # dst := dst plus src, src preserved
    note "$(printf 'ADD32 : @%03x gets @%03x' "$1" "$2")"
    goto 0 "$1"; mv4 "$1" "$W"; goto $(( $1 + 3 )) "$2"; cp4 "$2" $(( W + 4 )); goto $(( TB + 3 )) $(( W + 8 ))
    printf '%s\n' "$ADD"
    note "drop the final carry"; code '[-]'
    goto $(( W + 8 )) "$W"; mv4 "$W" "$1"; goto $(( W + 3 )) 0
}
add_mv_op() {  # dst := dst plus src, src CONSUMED
    note "$(printf 'ADD32 : @%03x gets @%03x  the source is consumed' "$1" "$2")"
    goto 0 "$1"; mv4 "$1" "$W"; goto $(( $1 + 3 )) "$2"; mv4 "$2" $(( W + 4 )); goto $(( $2 + 3 )) $(( W + 8 ))
    printf '%s\n' "$ADD"
    note "drop the final carry"; code '[-]'
    goto $(( W + 8 )) "$W"; mv4 "$W" "$1"; goto $(( W + 3 )) 0
}
xor_op() {
    note "$(printf 'XOR32 : @%03x gets @%03x' "$1" "$2")"
    goto 0 "$1"; mv4 "$1" "$W"; goto $(( $1 + 3 )) "$2"; cp4 "$2" $(( W + 4 )); goto $(( TB + 3 )) $(( W + 8 ))
    printf '%s\n' "$XOR"; mv4 $(( W + 8 )) "$1"; goto $(( W + 11 )) 0
}
rot_op() {
    note "$(printf 'ROTL32 : @%03x rotates left %d' "$1" "$2")"
    goto 0 "$1"; mv4 "$1" "$W"; goto $(( $1 + 3 )) $(( W + 4 ))
    note "the rotation count"; erun "+" "$2"
    printf '%s\n' "$ROTL"; goto $(( W + 4 )) "$W"; mv4 "$W" "$1"; goto $(( W + 3 )) 0
}
qr() {    # quarter round on word indices $1 $2 $3 $4
    _qa=$(( $1 * 4 )); _qb=$(( $2 * 4 )); _qc=$(( $3 * 4 )); _qd=$(( $4 * 4 ))
    printf '\n'; note "======== QUARTERROUND on words $1 $2 $3 $4 ========"
    add_op $_qa $_qb; xor_op $_qd $_qa; rot_op $_qd 16
    add_op $_qc $_qd; xor_op $_qb $_qc; rot_op $_qb 12
    add_op $_qa $_qb; xor_op $_qd $_qa; rot_op $_qd 8
    add_op $_qc $_qd; xor_op $_qb $_qc; rot_op $_qb 7
}
