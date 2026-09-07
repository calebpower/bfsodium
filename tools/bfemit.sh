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
# It is halven_keep_op with the shifted-out bit discarded, so the shift itself
# has exactly one implementation.
halven_op() {
    halven_keep_op "$1" "$2" "$3"
    note "discard the bit shifted out of the bottom byte"
    goto 0 $(( $3 + 4 )); code '[-]'; goto $(( $3 + 4 )) 0
}

# halven_keep_op: like halven_op but LEAVES the bit shifted out of the bottom
# byte in the frame's carry cell ($3 plus 4) instead of discarding it. The
# multiply walks the bits of r out of the bottom this way.
halven_keep_op() {
    _hx=$1; _hn=$2; _hf=$3
    _hh=$_hf; _hq=$(( _hf + 1 )); _hb=$(( _hf + 2 )); _hc=$(( _hf + 4 ))
    note "$(printf 'HALVE%d : @%03x shifted right one  keeping the bit shifted out' $(( _hn * 8 )) "$_hx")"
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
}

# fold_op: reduce x{$2} towards the range of Poly1305, using 2^130 = 5 mod p.
# $3 is a 40 cell scratch region:
#   +0:+16  hbuf{17}   the value 5H, padded, so the shared adder can add it
#   +17:+22 adder frame for the wide add
#   +23:+27 halve frame
#   +28 b0   +29 b1    the two bits that stay below the split
#   +30 h              the part above bit 130
#   +31:+32 hbuf2{2}   h staged for the small add
#   +33:+38 adder frame for the small add
#   +39 copy temp
#
# The split is at bit 130, and 130 is 128 plus 2, so the part above the split is
# simply the TOP BYTE shifted right two: no multi-byte shifting is needed. What
# stays behind is that byte's low two bits. Then x = L + 5H modulo p.
fold_op() {
    _fx=$1; _fn=$2; _fs=$3
    _fhb=$_fs; _ff3=$(( _fs + 17 )); _ffh=$(( _fs + 23 ))
    _fb0=$(( _fs + 28 )); _fb1=$(( _fs + 29 )); _fh=$(( _fs + 30 ))
    _fhb2=$(( _fs + 31 )); _ff2=$(( _fs + 33 )); _fcpt=$(( _fs + 39 ))
    _ftop=$(( _fx + _fn - 1 ))
    note "FOLD : reduce using 2^130 = 5 modulo p"
    note "the split is at bit 130  which is the top byte shifted right two"
    goto 0 "$_ftop"; mvn "$_ftop" "$_ffh" 1
    goto "$_ftop" "$_ffh"
    note "first halving  the low bit here is bit 128"
    code "$HALVEK"
    goto "$_ffh" $(( _ffh + 2 )); mvn $(( _ffh + 2 )) "$_fb0" 1
    goto $(( _ffh + 2 )) $(( _ffh + 1 )); mvn $(( _ffh + 1 )) "$_ffh" 1
    goto $(( _ffh + 1 )) "$_ffh"
    note "second halving  the low bit here is bit 129"
    code "$HALVEK"
    goto "$_ffh" $(( _ffh + 2 )); mvn $(( _ffh + 2 )) "$_fb1" 1
    goto $(( _ffh + 2 )) $(( _ffh + 1 )); mvn $(( _ffh + 1 )) "$_fh" 1
    goto $(( _ffh + 1 )) 0
    note "the top byte keeps only bits 128 and 129"
    goto 0 "$_fb0"; mvn "$_fb0" "$_ftop" 1
    goto "$_fb0" "$_fb1"
    note "bit 129 is worth two in the top byte"
    code '[-'
    goto "$_fb1" "$_ftop"; code '++'; goto "$_ftop" "$_fb1"
    code ']'
    goto "$_fb1" 0
    note "build 5H by adding H to a two byte buffer five times"
    _fk=0
    while [ $_fk -lt 5 ]; do
        cpn_at "$_fh" "$_fhb2" 1 "$_fcpt"
        addn_op "$_fhb" "$_fhb2" 2 "$_ff2"
        _fk=$(( _fk + 1 ))
    done
    note "discard H now that 5H is built"
    goto 0 "$_fh"; code '[-]'; goto "$_fh" 0
    note "add 5H back into the value"
    addn_op "$_fx" "$_fhb" "$_fn" "$_ff3"
}

# cpn_at: cpn, but it walks to the source first and returns to cell 0, so it can
# be called from the pointer-at-zero convention the ops use.
cpn_at() {
    goto 0 "$1"; cpn "$1" "$2" "$3" "$4"; goto $(( $4 + $3 - 1 )) 0
}

# reducep_op: bring x{$2} into the canonical range below p = 2^130 minus 5.
# $3 is a 105 cell scratch region:
#   +0:+39    fold scratch (see fold_op)
#   +40:+56   dbuf{17}   x plus 5, used to decide whether x is at least p
#   +57:+62   adder frame
#   +63:+67   halve frame
#   +68 b0  +69 b1  +70 q
#   +71:+87   copy temps
#   +88:+104  fivebuf{17}, the constant 5 padded so the wide adder can add it
#
# Two folds bring any 17 byte value below 2^130: the first leaves it under
# 2^130 plus 315, and the second turns any value at or above 2^130 into
# something under 325. That leaves only the five values between p and 2^130 to
# deal with, and the trick for those is that x minus p equals x plus 5 minus
# 2^130. So add 5, and if that crossed bit 130 the value was at least p: keep
# the sum with bit 130 cleared. Otherwise keep x untouched.
reducep_op() {
    _rx=$1; _rn=$2; _rs=$3
    _rd=$(( _rs + 40 )); _raf=$(( _rs + 57 )); _rhf=$(( _rs + 63 ))
    _rb0=$(( _rs + 68 )); _rb1=$(( _rs + 69 )); _rq=$(( _rs + 70 ))
    _rcpt=$(( _rs + 71 )); _rfive=$(( _rs + 88 ))
    _rtop=$(( _rd + _rn - 1 ))
    note "REDUCE : bring the value below p = 2^130 minus 5"
    fold_op "$_rx" "$_rn" "$_rs"
    fold_op "$_rx" "$_rn" "$_rs"
    note "copy the value and add five to it  to test whether it reaches p"
    cpn_at "$_rx" "$_rd" "$_rn" "$_rcpt"
    goto 0 "$_rfive"; erun "+" 5; goto "$_rfive" 0
    addn_op "$_rd" "$_rfive" "$_rn" "$_raf"
    note "split the sum's top byte  bit 130 tells us whether x was at least p"
    goto 0 "$_rtop"; mvn "$_rtop" "$_rhf" 1
    goto "$_rtop" "$_rhf"; code "$HALVEK"
    goto "$_rhf" $(( _rhf + 2 )); mvn $(( _rhf + 2 )) "$_rb0" 1
    goto $(( _rhf + 2 )) $(( _rhf + 1 )); mvn $(( _rhf + 1 )) "$_rhf" 1
    goto $(( _rhf + 1 )) "$_rhf"; code "$HALVEK"
    goto "$_rhf" $(( _rhf + 2 )); mvn $(( _rhf + 2 )) "$_rb1" 1
    goto $(( _rhf + 2 )) $(( _rhf + 1 )); mvn $(( _rhf + 1 )) "$_rq" 1
    goto $(( _rhf + 1 )) 0
    note "put the two low bits back  so the sum has bit 130 cleared"
    goto 0 "$_rb0"; mvn "$_rb0" "$_rtop" 1
    goto "$_rb0" "$_rb1"
    code '[-'
    goto "$_rb1" "$_rtop"; code '++'; goto "$_rtop" "$_rb1"
    code ']'
    goto "$_rb1" 0
    note "if the sum crossed bit 130  the value was at least p  so take the sum"
    goto 0 "$_rq"; code '['; code '[-]'; goto "$_rq" 0
    _rk=0
    while [ $_rk -lt $_rn ]; do
        goto 0 $(( _rx + _rk )); code '[-]'; goto $(( _rx + _rk )) 0
        _rk=$(( _rk + 1 ))
    done
    goto 0 "$_rd"; mvn "$_rd" "$_rx" "$_rn"; goto $(( _rd + _rn - 1 )) "$_rq"
    code ']'
    goto "$_rq" 0
    note "discard the trial sum  it is already empty when it was taken"
    _rk=0
    while [ $_rk -lt $_rn ]; do
        goto 0 $(( _rd + _rk )); code '[-]'; goto $(( _rd + _rk )) 0
        _rk=$(( _rk + 1 ))
    done
}

# mulmod_op: acc{$3} := acc times r modulo p, where p = 2^130 minus 5. The
# multiplier r{$3} is CONSUMED. $4 is a 185 cell scratch region:
#   +0:+16   t{17}     the running value, doubled each step
#   +17:+33  res{17}   the accumulating product
#   +34:+50  tmp{17}   a copy buffer, since the wide adder consumes its source
#   +51:+55  halve frame for r; its carry cell holds the bit just shifted out
#   +56      the step counter
#   +57:+62  adder frame
#   +63:+79  copy temps
#   +80:+184 reduce scratch, which contains the fold scratch
#
# There is no multiply instruction, so this is double and add, walking the bits
# of r out of the BOTTOM: at each step the low bit of r says whether to add the
# running value into the product, then the running value doubles and r shifts
# right. A fold after every add and every doubling keeps both operands under
# 2^130 plus a little, so their sum always fits in 17 bytes and nothing has to
# widen. The product is reduced to canonical form only at the end, because
# intermediate values need only be congruent, not least.
mulmod_op() {
    _macc=$1; _mr=$2; _mn=$3; _ms=$4
    _mt=$_ms; _mres=$(( _ms + 17 )); _mtmp=$(( _ms + 34 ))
    _mhf=$(( _ms + 51 )); _mbit=$(( _ms + 55 )); _mctr=$(( _ms + 56 ))
    _maf=$(( _ms + 57 )); _mcpt=$(( _ms + 63 )); _mrs=$(( _ms + 80 ))
    note "MULMOD : the accumulator times r  modulo 2^130 minus 5"
    note "the accumulator moves into the running value  leaving room for the product"
    goto 0 "$_macc"; mvn "$_macc" "$_mt" "$_mn"; goto $(( _macc + _mn - 1 )) 0
    note "one step per bit of r  all 136 of them  since r is 17 bytes wide"
    note "stopping at 128 would silently ignore any bits in the top byte"
    goto 0 "$_mctr"; erun "+" 136; goto "$_mctr" 0
    goto 0 "$_mctr"; code '[-'; goto "$_mctr" 0
    halven_keep_op "$_mr" "$_mn" "$_mhf"
    note "when the bit shifted out was set  add the running value into the product"
    goto 0 "$_mbit"; code '['; code '[-]'; goto "$_mbit" 0
    cpn_at "$_mt" "$_mtmp" "$_mn" "$_mcpt"
    addn_op "$_mres" "$_mtmp" "$_mn" "$_maf"
    fold_op "$_mres" "$_mn" "$_mrs"
    goto 0 "$_mbit"; code ']'; goto "$_mbit" 0
    note "double the running value for the next bit  then fold it back down"
    cpn_at "$_mt" "$_mtmp" "$_mn" "$_mcpt"
    addn_op "$_mt" "$_mtmp" "$_mn" "$_maf"
    fold_op "$_mt" "$_mn" "$_mrs"
    goto 0 "$_mctr"; code ']'; goto "$_mctr" 0
    note "the running value is spent  discard it"
    _mk=0
    while [ $_mk -lt $_mn ]; do
        goto 0 $(( _mt + _mk )); code '[-]'; goto $(( _mt + _mk )) 0
        _mk=$(( _mk + 1 ))
    done
    note "only now does the product need to be least  not merely congruent"
    reducep_op "$_mres" "$_mn" "$_mrs"
    goto 0 "$_mres"; mvn "$_mres" "$_macc" "$_mn"; goto $(( _mres + _mn - 1 )) 0
}

qr() {    # quarter round on word indices $1 $2 $3 $4
    _qa=$(( $1 * 4 )); _qb=$(( $2 * 4 )); _qc=$(( $3 * 4 )); _qd=$(( $4 * 4 ))
    printf '\n'; note "======== QUARTERROUND on words $1 $2 $3 $4 ========"
    add_op $_qa $_qb; xor_op $_qd $_qa; rot_op $_qd 16
    add_op $_qc $_qd; xor_op $_qb $_qc; rot_op $_qb 12
    add_op $_qa $_qb; xor_op $_qd $_qa; rot_op $_qd 8
    add_op $_qc $_qd; xor_op $_qb $_qc; rot_op $_qb 7
}
