#!/bin/sh
# polyasm.sh — assemble the Poly1305 pieces (RFC 8439 one time authenticator).
#
# Poly1305 is arithmetic modulo 2^130 minus 5, so unlike ChaCha20 it needs wide
# numbers: the accumulator is 130 bits, which is 17 bytes on the wire. This
# assembler builds those pieces from the same shared emitter every other
# bfsodium assembler uses (tools/bfemit), so the style and the byte adder are
# the ones the existing KATs already cover.
#
# Built so far:
#   add136.bf   17 byte little endian addition, the accumulator's add step
#
# MEMORY for add136
#   @0x00:0x10  a{17}   the accumulator, and the result
#   @0x11:0x21  b{17}   the addend
#   @0x22:0x27  the six cell adder frame: cin, x, y, carry, and two scratch
set -eu
here=$(cd "$(dirname "$0")" && pwd); repo=$(cd "$here/.." && pwd)

W=0; TB=0          # unused here; the shared emitter expects them to be set
. "$here/bfemit.sh"

A=0; B=17; F=34; N=17

{
cat <<'HDR'
; bfsodium ADD136 : 17 byte little endian addition
;
; ASSEMBLED FILE: emitted by tools/polyasm using the shared emitter  so the
; byte adder here is the one chacha20/add32 already proves;
;
; IO  in:  a{17} LE  followed by  b{17} LE     (34 bytes)
;     out: (a plus b mod 2^136){17} LE         (17 bytes)
;
; TAPE MAP  (home @0)
;   @0x00:0x10  a{17}  u8   the accumulator  and the result  LSB at @0x00
;   @0x11:0x21  b{17}  u8   the addend
;   @0x22       cin    u8   carry into the current byte
;   @0x23       x      u8   ADD8 frame: accumulator
;   @0x24       y      u8   ADD8 frame: addend  consumed to 0
;   @0x25       c      u8   ADD8 frame: carry out
;   @0x26       t0     u8   ADD8 frame scratch  restored 0
;   @0x27       t1     u8   ADD8 frame scratch  restored 0
;
; Poly1305 holds a 130 bit accumulator  which is 17 bytes; this is the widened
; form of the 32 bit adder  byte block by byte block with the carry threaded
; between them  and the carry out of the top byte dropped;

; read a then b  leaving the pointer on the last byte of b
HDR

printf '  ,'
k=1; while [ $k -lt $(( N * 2 )) ]; do printf '>,'; [ $(( k % 30 )) -eq 0 ] && printf '\n  '; k=$(( k + 1 )); done
printf '\n'
goto $(( B + N - 1 )) 0

addn_op $A $B $N $F

printf '\n'; note "emit the sum little endian"
goto 0 0
printf '  .'
k=1; while [ $k -lt $N ]; do printf '>.'; k=$(( k + 1 )); done
printf '\n'
} > "$repo/poly1305/add136.bf"

{
cat <<HALVEHDR
; bfsodium HALVE136 : 17 byte little endian shift right one
;
; ASSEMBLED FILE: emitted by tools/polyasm using the shared emitter;
;
; IO  in:  x{17} LE      (17 bytes)
;     out: (x shifted right one){17} LE   (17 bytes)
;
; TAPE MAP  (home @0)
;   @0x00:0x10  x{17}  u8   the value  and the result  LSB at @0x00
;   @0x11       h      u8   HALVE frame: the byte being halved
;   @0x12       q      u8   HALVE frame: the quotient
;   @0x13       bit    u8   HALVE frame: this byte low bit
;   @0x14       f      u8   HALVE frame scratch  restored 0
;   @0x15       carry  u8   the bit coming down from the byte above
;
; Bytes are walked from the top down  because the bit leaving a byte enters
; the byte below it;

; read x  leaving the pointer on its last byte
HALVEHDR

printf "  ,"
k=1; while [ $k -lt $N ]; do printf ">,"; k=$(( k + 1 )); done
printf "\n"
goto $(( N - 1 )) 0

halven_op 0 $N 17

printf "\n"; note "emit the shifted value little endian"
printf "  ."
k=1; while [ $k -lt $N ]; do printf ">."; k=$(( k + 1 )); done
printf "\n"
} > "$repo/poly1305/halve136.bf"
{
cat <<FOLDHDR
; bfsodium FOLD136 : one Poly1305 reduction step  using 2^130 = 5 modulo p
;
; ASSEMBLED FILE: emitted by tools/polyasm using the shared emitter;
;
; IO  in:  x{17} LE                     (17 bytes)
;     out: (L plus 5H){17} LE           (17 bytes)  where x = L plus H times 2^130
;
; TAPE MAP  (home @0)
;   @0x00:0x10  x{17}     u8   the value  and the result
;   @0x11:0x38  scratch{40}    the fold workspace; see fold_op in tools/bfemit
;
; The split is at bit 130  and 130 is 128 plus 2  so the part above the split
; is simply the top byte shifted right two and no multi byte shift is needed;
FOLDHDR

printf "  ,"
k=1; while [ $k -lt $N ]; do printf ">,"; k=$(( k + 1 )); done
printf "\n"
goto $(( N - 1 )) 0

fold_op 0 $N 17

printf "\n"; note "emit the folded value little endian"
printf "  ."
k=1; while [ $k -lt $N ]; do printf ">."; k=$(( k + 1 )); done
printf "\n"
} > "$repo/poly1305/fold136.bf"
{
cat <<REDHDR
; bfsodium REDUCEP136 : bring a 17 byte value below p = 2^130 minus 5
;
; ASSEMBLED FILE: emitted by tools/polyasm using the shared emitter;
;
; IO  in:  x{17} LE      (17 bytes)
;     out: (x mod p){17} LE   (17 bytes)
;
; TAPE MAP  (home @0)
;   @0x00:0x10  x{17}      u8   the value  and the result
;   @0x11:0x79  scratch{105}    see reducep_op in tools/bfemit
;
; Two folds bring any 17 byte value below 2^130; only the five values between
; p and 2^130 then remain  and for those x minus p is x plus 5 minus 2^130;
REDHDR

printf "  ,"
k=1; while [ $k -lt $N ]; do printf ">,"; k=$(( k + 1 )); done
printf "\n"
goto $(( N - 1 )) 0

reducep_op 0 $N 17

printf "\n"; note "emit the reduced value little endian"
printf "  ."
k=1; while [ $k -lt $N ]; do printf ">."; k=$(( k + 1 )); done
printf "\n"
} > "$repo/poly1305/reducep136.bf"
{
cat <<MULHDR
; bfsodium MULMOD136 : multiply modulo p = 2^130 minus 5
;
; ASSEMBLED FILE: emitted by tools/polyasm using the shared emitter;
;
; IO  in:  a{17} LE  followed by  r{17} LE     (34 bytes)
;     out: (a times r mod p){17} LE            (17 bytes)
;
; TAPE MAP  (home @0)
;   @0x00:0x10  a{17}       u8   the accumulator  and the result
;   @0x11:0x21  r{17}       u8   the multiplier  consumed bit by bit
;   @0x22:0xda  scratch{185}     see mulmod_op in tools/bfemit
;
; There is no multiply instruction  so this is double and add over the bits of
; r  walked out of the bottom; a fold after every add and every doubling keeps
; both operands under 2^130 plus a little  so 17 bytes always suffice;
MULHDR

printf "  ,"
k=1; while [ $k -lt 34 ]; do printf ">,"; [ $(( k % 30 )) -eq 0 ] && printf "\n  "; k=$(( k + 1 )); done
printf "\n"
goto 33 0

mulmod_op 0 17 $N 34

printf "\n"; note "emit the product little endian"
printf "  ."
k=1; while [ $k -lt $N ]; do printf ">."; k=$(( k + 1 )); done
printf "\n"
} > "$repo/poly1305/mulmod136.bf"
echo "assembled $repo/poly1305/mulmod136.bf ($(grep -c "" "$repo/poly1305/mulmod136.bf") lines)"

echo "assembled $repo/poly1305/reducep136.bf ($(grep -c "" "$repo/poly1305/reducep136.bf") lines)"

echo "assembled $repo/poly1305/fold136.bf ($(grep -c "" "$repo/poly1305/fold136.bf") lines)"

echo "assembled $repo/poly1305/halve136.bf ($(grep -c "" "$repo/poly1305/halve136.bf") lines)"

echo "assembled $repo/poly1305/add136.bf ($(grep -c '' "$repo/poly1305/add136.bf") lines)"

# ---- the authenticator itself (RFC 8439 one time authenticator) ----
ACC=0; RR=17; SS=34; NN=51; RC=68
REMLO=85; REMHI=86; PLACED=87; RNZ=88; GG=90; TMPC=91; BLK=92
F1=93; Z1=94; F2=95; Z2=96; F3=97; Z3=98
IT=100; HF=102; AF=107; CPT=113; MS=132; AB=318

# nonzero_remaining: leave $1 nonzero exactly when the length counter is not
# zero, by asking whether each of its two bytes is zero.
nonzero_remaining() {
    iszero_at $REMLO $F1 $Z1 $IT
    iszero_at $REMHI $F2 $Z2 $IT
    note "$(printf 'flag @%03x counts how many length bytes were NOT zero' "$1")"
    goto 0 "$1"; code '++'
    goto "$1" $F1
    code '[[-]'; erun "<" $(( F1 - $1 )); code '-'; erun ">" $(( F1 - $1 )); code ']'
    goto $F1 $F2
    code '[[-]'; erun "<" $(( F2 - $1 )); code '-'; erun ">" $(( F2 - $1 )); code ']'
    goto $F2 0
}

{
cat <<'PHDR'
; bfsodium POLY1305 : the one time authenticator (RFC 8439 one time authenticator)
;
; ASSEMBLED FILE: emitted by tools/polyasm from the shared emitter and the wide
; arithmetic already proven by add136  fold136  reducep136 and mulmod136;
;
; IO  in:  key{32}  len{2} LE  msg{len}
;     out: tag{16}
;
; The length prefix is how the program knows when to stop; a bfsodium primitive
; never relies on end of input (CONVENTIONS section 7);
;
; TAPE MAP  (home @0)
;   @0x000:0x010  acc{17}   u8   the accumulator  reduced below p each block
;   @0x011:0x021  r{17}     u8   the clamped multiplier  kept for every block
;   @0x022:0x032  s{17}     u8   the second half of the key  added at the end
;   @0x033:0x043  n{17}     u8   this block as a number  with its high one
;   @0x044:0x054  rc{17}    u8   a copy of r  since the multiply consumes it
;   @0x055:0x056  remaining{2} u16 LE  message bytes still to absorb
;   @0x057        placed    u8   whether this block's high one has been placed
;   @0x058        rnz       u8   nonzero while bytes remain
;   @0x05a:0x05c  gg tmp blk     gating cells
;   @0x05d:0x062  flags and their scratch
;   @0x064        iszero staging temp
;   @0x066:0x06a  halve frame
;   @0x06b:0x070  adder frame
;   @0x071:0x081  copy temps
;   @0x084:0x138  multiply scratch
;   @0x13e:0x141  bit cells for the clamp
;
; Each 16 byte block becomes a number with a one appended above it  is added to
; the accumulator  and the accumulator is multiplied by r modulo 2^130 minus 5;
; a short final block puts its one directly above whatever bytes it had;
PHDR

note "read the key: sixteen bytes of r then sixteen of s"
goto 0 $RR
printf '  ,'; k=1; while [ $k -lt 16 ]; do printf '>,'; k=$(( k + 1 )); done; printf '\n'
goto $(( RR + 15 )) $SS
printf '  ,'; k=1; while [ $k -lt 16 ]; do printf '>,'; k=$(( k + 1 )); done; printf '\n'
note "read the two length bytes"
goto $(( SS + 15 )) $REMLO
printf '  ,>,\n'
goto $REMHI 0

note "clamp r  which is the masking the RFC requires"
for c in 3 7 11 15; do and15_op $(( RR + c )) $HF $AB; done
for c in 4 8 12; do and252_op $(( RR + c )) $HF; done

note "absorb the message one block at a time"
nonzero_remaining $BLK
goto 0 $BLK
note "while bytes remain"
code '['
code '[-]'
goto $BLK 0

k=0
while [ $k -lt 16 ]; do
    note "======== byte slot $k of this block ========"
    nonzero_remaining $RNZ
    iszero_at $RNZ $F3 $Z3 $IT
    note "when bytes remain  take one into the block and count it off"
    goto 0 $RNZ; code '['; code '[-]'; goto $RNZ 0
    goto 0 $(( NN + k )); code ','; goto $(( NN + k )) 0
    iszero_at $REMLO $F1 $Z1 $IT
    goto 0 $REMLO; code '-'; goto $REMLO 0
    note "borrow into the high byte when the low byte wrapped"
    goto 0 $F1; code '[[-]'; erun "<" $(( F1 - REMHI )); code '-'; erun ">" $(( F1 - REMHI )); code ']'
    goto $F1 $RNZ; code ']'; goto $RNZ 0
    note "otherwise this is where the high one goes  if it is not placed yet"
    cpn_at $F3 $GG 1 $IT
    cpn_at $PLACED $TMPC 1 $IT
    goto 0 $TMPC; code '[[-]'; erun "<" $(( TMPC - GG )); code '[-]'; erun ">" $(( TMPC - GG )); code ']'
    goto $TMPC 0
    goto 0 $GG; code '['; code '[-]'
    goto $GG $(( NN + k )); code '+'
    goto $(( NN + k )) $PLACED; code '+'
    goto $PLACED $GG; code ']'; goto $GG 0
    note "clear the leftover flag"
    goto 0 $F3; code '[-]'; goto $F3 0
    k=$(( k + 1 ))
done

note "a full block puts its high one in the seventeenth byte"
iszero_at $PLACED $F3 $Z3 $IT
goto 0 $F3; code '['; code '[-]'
goto $F3 $(( NN + 16 )); code '+'
goto $(( NN + 16 )) $F3; code ']'; goto $F3 0
note "reset for the next block"
goto 0 $PLACED; code '[-]'; goto $PLACED 0

note "the accumulator absorbs this block  then is multiplied by r"
addn_op $ACC $NN 17 $AF
cpn_at $RR $RC 17 $CPT
mulmod_op $ACC $RC 17 $MS

nonzero_remaining $BLK
goto 0 $BLK
code ']'
goto $BLK 0

note "finally add s  the tag is the low sixteen bytes of the result"
addn_op $ACC $SS 17 $AF

printf '\n'; note "emit the sixteen byte tag"
printf '  .'
k=1; while [ $k -lt 16 ]; do printf '>.'; k=$(( k + 1 )); done
printf '\n'
} > "$repo/poly1305/poly1305.bf"
echo "assembled $repo/poly1305/poly1305.bf ($(grep -c '' "$repo/poly1305/poly1305.bf") lines)"
