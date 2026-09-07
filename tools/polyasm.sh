#!/bin/sh
# polyasm.sh — assemble the Poly1305 pieces (RFC 8439 section 2.5).
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
