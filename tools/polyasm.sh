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

echo "assembled $repo/poly1305/add136.bf ($(grep -c '' "$repo/poly1305/add136.bf") lines)"
