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
    # sh has no local variables, so every helper here prefixes its own working
    # names. A collision is not a syntax error, it silently truncates a caller's
    # loop: erun once used _i and cut the 17 byte adder down to 6 bytes.
    _en=$2
    while [ "$_en" -gt 0 ]; do
        _ec=$_en; [ "$_ec" -gt "$CHUNK" ] && _ec=$CHUNK
        printf '  '; _ei=0; while [ $_ei -lt $_ec ]; do printf '%s' "$1"; _ei=$((_ei+1)); done
        printf '\n'; _en=$(( _en - _ec ))
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
# ADD8K is the proven byte adder from chacha20/add32.bf, lifted verbatim rather
# than retyped so a widened adder cannot drift from the one the KATs cover.
# Entered at y, with x at y-1, the carry out at y+1 and scratch at y+2 and y+3.
ADD8K='[-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]'

# addn_op: dst{$3} := dst plus src modulo 2^(8*$3), little endian, where $4 is a
# six cell frame: cin, x, y, carry out, and two scratch. The final carry is
# dropped, exactly as add32 drops it. Entered and left at cell 0.
#
# Poly1305 needs a 17 byte accumulator, so the adder has to widen; the shape is
# add32's, byte block by byte block, with the carry threaded between them.
addn_op() {
    _ad=$1; _as=$2; _an=$3; _f=$4
    _cin=$_f; _x=$(( _f + 1 )); _y=$(( _f + 2 )); _cy=$(( _f + 3 ))
    note "$(printf 'ADD%d : @%03x gets @%03x  little endian' $(( _an * 8 )) "$_ad" "$_as")"
    _ai=0
    while [ $_ai -lt $_an ]; do
        note "$(printf 'byte %d' "$_ai")"
        goto 0 $(( _ad + _ai )); mvn $(( _ad + _ai )) "$_x" 1
        goto $(( _ad + _ai )) $(( _as + _ai )); mvn $(( _as + _ai )) "$_y" 1
        goto $(( _as + _ai )) "$_y"
        note "add the addend byte into the accumulator byte"
        code "$ADD8K"
        goto "$_y" "$_cin"; mvn "$_cin" "$_y" 1
        goto "$_cin" "$_y"
        note "add the carry coming in from the byte below"
        code "$ADD8K"
        goto "$_y" "$_x"; mvn "$_x" $(( _ad + _ai )) 1
        goto "$_x" "$_cy"; mvn "$_cy" "$_cin" 1
        goto "$_cy" 0
        _ai=$(( _ai + 1 ))
    done
    note "drop the carry out of the top byte"
    goto 0 "$_cin"; code '[-]'; goto "$_cin" 0
}

# HALVEK is the proven halving step from chacha20/xor32.bf, lifted verbatim.
# Entered at the value, with the quotient at +1, the low bit at +2 and scratch
# at +3: it leaves the value shifted right one and its low bit beside it.
HALVEK='[->>>+<[-<+>>-<]>[-<+>]<<<]'

# halven_op: x{$2} := x shifted right one, little endian, where $3 is a five
# cell frame: h, q, bit, scratch, carry. Entered and left at cell 0.
#
# Bytes are walked from the TOP down, because the bit leaving a byte enters the
# byte below it: each byte is halved, the bit carried in from above is put back
# as the top bit, and this byte's own low bit becomes the carry for the next.
# The reduction modulo 2^130 minus 5 needs a shift, and 130 bits is not a whole
# number of bytes, so this is how the odd two bits are reached.
halven_op() {
    _hx=$1; _hn=$2; _hf=$3
    _hh=$_hf; _hq=$(( _hf + 1 )); _hb=$(( _hf + 2 )); _hc=$(( _hf + 4 ))
    note "$(printf 'HALVE%d : @%03x shifted right one  little endian' $(( _hn * 8 )) "$_hx")"
    _hi=$(( _hn - 1 ))
    while [ $_hi -ge 0 ]; do
        note "$(printf 'byte %d  the top byte first' "$_hi")"
        goto 0 $(( _hx + _hi )); mvn $(( _hx + _hi )) "$_hh" 1
        goto $(( _hx + _hi )) "$_hh"
        note "halve it  leaving the quotient and this byte's low bit"
        code "$HALVEK"
        goto "$_hh" "$_hc"
        note "a bit carried in from the byte above becomes the top bit here"
        code '[-'
        goto "$_hc" "$_hq"; erun "+" 128; goto "$_hq" "$_hc"
        code ']'
        goto "$_hc" "$_hq"; mvn "$_hq" $(( _hx + _hi )) 1
        goto "$_hq" "$_hb"; mvn "$_hb" "$_hc" 1
        goto "$_hb" 0
        _hi=$(( _hi - 1 ))
    done
    note "discard the bit shifted out of the bottom byte"
    goto 0 "$_hc"; code '[-]'; goto "$_hc" 0
}

qr() {    # quarter round on word indices $1 $2 $3 $4
    _qa=$(( $1 * 4 )); _qb=$(( $2 * 4 )); _qc=$(( $3 * 4 )); _qd=$(( $4 * 4 ))
    printf '\n'; note "======== QUARTERROUND on words $1 $2 $3 $4 ========"
    add_op $_qa $_qb; xor_op $_qd $_qa; rot_op $_qd 16
    add_op $_qc $_qd; xor_op $_qb $_qc; rot_op $_qb 12
    add_op $_qa $_qb; xor_op $_qd $_qa; rot_op $_qd 8
    add_op $_qc $_qd; xor_op $_qb $_qc; rot_op $_qb 7
}
