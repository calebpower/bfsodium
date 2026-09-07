#!/bin/sh
# streamasm.sh — assemble chacha20/stream.bf, the ChaCha20 stream cipher
# (RFC 8439 stream cipher), from the verified primitive bodies.
#
# Same principle as qrasm.sh and blockasm.sh: brainfuck is position
# independent, so the proven bodies of add32.bf, xor32.bf and rotl32.bf are
# spliced in verbatim at a shared workspace base. Here the whole block function
# sits inside an outer loop that runs once per 64 bytes of message, so the
# eighty quarter rounds of a block appear once, not eighty times, and the block
# code appears once no matter how long the message is.
#
# The message length arrives on the wire as a 2 byte prefix, because a
# primitive here never relies on end of input to know when to stop
# (CONVENTIONS section 7). Each of the 64 byte slots in a block is gated on
# "bytes remaining", so a partial final block emits exactly the right number.
#
# MEMORY
#   @0x000:0x03f  state{16}    the working state, rebuilt every block
#   @0x040:0x07f  orig{16}     a copy, consumed by the final add
#   @0x080        rounds       10 double rounds, the loop counter
#   @0x0a0:0x0df  stemp{64}    temps for duplicating and for copying in
#   @0x0e0        W            workspace the embedded bodies see as cell 0
#   @0x0fc:0x0ff  copy temps
#   @0x100:0x11f  key{32}      kept for every block
#   @0x120:0x123  counter{4}   little endian, incremented per block
#   @0x124:0x12f  nonce{12}
#   @0x130:0x131  remaining{2} little endian, the bytes still to emit
#   @0x132:0x13f  flags and scratch
#   @0x140:0x17f  keystream{64}
#   @0x190:0x19d  XOR8 frame for the per byte exclusive or
set -eu
here=$(cd "$(dirname "$0")" && pwd); repo=$(cd "$here/.." && pwd)
out="$repo/chacha20/stream.bf"

W=224; TB=252; ST=160; CTR=128; CHUNK=40
KEY=256; CNT=288; NON=292
# Ordering matters: each flag sits immediately BELOW its scratch cell, and the
# iszero staging temp sits above every cell iszero touches, so all of the moves
# below have a known direction.
REMLO=304; REMHI=305
F0=306; Z0=307; F1=308; Z1=309; F2=310; Z2=311
WZ=312; WZZ=313; FLAG=314
IT=390        # iszero staging temp; must sit above every cell iszero tests
CC=386; CZ=387; GG=388   # counter carry  its iszero scratch  and its gate
HT=440   # staging temps for copies whose source is above the destination
KS=320
XA=400; XCNT=412; XRES=410; XP=411

body() { awk '/^,>,/{f=1;next} /^; emit/{f=0} f' "$repo/chacha20/$1.bf"; }
ADD=$(body add32); XOR=$(body xor32); ROTL=$(body rotl32)
# The XOR8 inner loop, lifted from the verified xor32.bf: the block from the
# first "[-" line through its matching "]". Entered and left at cnt.
X8=$(awk '/^  \[-$/{f=1} f{print} f&&/^  \]$/{exit}' "$repo/chacha20/xor32.bf")

. "$here/bfemit.sh"

# isZero: leaves $2 (a flag) equal to 1 when the byte at $1 is zero, using $3
# as scratch. Pointer starts and ends at cell 0.
iszero() {
    printf '; flag @%03x := 1 assuming @%03x is zero\n' "$2" "$1"
    goto 0 "$2"; printf '  +\n'
    printf '; copy @%03x into scratch @%03x\n' "$1" "$3"
    goto "$2" "$1"
    printf '  [-\n'; erun ">" $(( $3 - $1 )); printf '  +\n'; erun ">" $(( IT - $3 )); printf '  +\n'
    erun "<" $(( IT - $1 )); printf '  ]\n'
    goto "$1" "$IT"; printf '  [-\n'; erun "<" $(( IT - $1 )); printf '  +\n'; erun ">" $(( IT - $1 )); printf '  ]\n'
    printf '; if the scratch is nonzero  clear it and clear the flag\n'
    goto "$IT" "$3"; printf '  [[-]\n'; erun "<" $(( $3 - $2 )); printf '  -\n'; erun ">" $(( $3 - $2 )); printf '  ]\n'
    goto "$3" 0
}

{
cat <<'HDR'
; bfsodium ChaCha20 STREAM CIPHER (RFC 8439 stream cipher)
;
; ASSEMBLED FILE: emitted by tools/streamasm from the verified bodies of
; add32  xor32 and rotl32; brainfuck is position independent  so those
; bodies are reused here verbatim rather than retyped at new offsets;
;
; IO  in:  key{32}  counter{4} LE  nonce{12}  len{2} LE  plaintext{len}
;     out: ciphertext{len}
;
; The length prefix is how the program knows when to stop; a bfsodium primitive
; never relies on end of input (CONVENTIONS section 7);
;
; TAPE MAP  (home @0)
;   @0x000:0x03f  state{16}    u32 LE   the working state  rebuilt each block
;   @0x040:0x07f  orig{16}     u32 LE   a copy  consumed by the final add
;   @0x080        rounds       u8       10 double rounds  the loop counter
;   @0x0a0:0x0df  stemp{64}    u8       temps for duplicating and copying in
;   @0x0e0        W                     workspace base; EVERY embedded body
;                                       addresses cells relative to W  so an
;                                       "@0x00" inside one means @0x0e0 here
;   @0x0fc:0x0ff  copy temps
;   @0x100:0x11f  key{32}      u8       kept for every block
;   @0x120:0x123  counter{4}   u32 LE   incremented once per block
;   @0x124:0x12f  nonce{12}    u8
;   @0x130:0x131  remaining{2} u16 LE   bytes still to emit
;   @0x132:0x13f  flags and scratch
;   @0x140:0x17f  keystream{64} u8      this block's keystream
;   @0x190:0x19d  XOR8 frame            for the per byte exclusive or
;
; One pass of the outer loop makes one keystream block and consumes up to 64
; bytes of message; the counter is incremented at the end of each pass;
HDR

echo; echo "; ==== read key  counter  nonce and the length prefix ===="
printf '; 32 key bytes into @100:@11f\n'
goto 0 $KEY
printf '  ,'; k=1; while [ $k -lt 32 ]; do printf '>,'; [ $(( k % 30 )) -eq 0 ] && printf '\n  '; k=$(( k + 1 )); done; printf '\n'
printf '; 4 counter bytes then 12 nonce bytes then the 2 length bytes\n'
printf '  >,'; k=1; while [ $k -lt 18 ]; do printf '>,'; [ $(( k % 30 )) -eq 0 ] && printf '\n  '; k=$(( k + 1 )); done; printf '\n'
goto $(( REMHI )) 0

echo; echo "; ==== outer loop : one pass per 64 byte block ===="
echo "; the loop runs while remaining is nonzero"
iszero $REMLO $F0 $Z0
iszero $REMHI $F1 $Z1
printf '; continue flag @%03x := 1 unless BOTH length bytes were zero\n' "$FLAG"
goto 0 $FLAG; printf '  ++\n'
goto $FLAG $F0; printf '  [[-]\n'; erun ">" $(( FLAG - F0 )); printf '  -\n'; erun "<" $(( FLAG - F0 )); printf '  ]\n'
goto $F0 $F1; printf '  [[-]\n'; erun ">" $(( FLAG - F1 )); printf '  -\n'; erun "<" $(( FLAG - F1 )); printf '  ]\n'
goto $F1 $FLAG
note "while there are bytes left"; code "["
note "clear the flag; it is recomputed at the end of the pass"; code "[-]"
goto $FLAG 0

echo; echo "; ==== build the state : the constant  then key  counter  nonce ===="
prev=0; cell=0
for v in 101 120 112 97 110 100 32 51 50 45 98 121 116 101 32 107; do
    goto $prev $cell; printf '; @%03x gets %d\n' "$cell" "$v"; erun "+" "$v"
    prev=$cell; cell=$(( cell + 1 ))
done
goto $prev 0
goto 0 $KEY; cpn $KEY 16 32 $HT
goto $(( HT + 31 )) 0
goto 0 $CNT; cpn $CNT 48 4 $HT
goto $(( HT + 3 )) 0
goto 0 $NON; cpn $NON 52 12 $HT
goto $(( HT + 11 )) 0

echo; echo "; ==== duplicate the state into orig ===="
k=0; while [ $k -lt 64 ]; do
    printf '; byte @%03x to @%03x and to a temp\n' "$k" $(( k + 64 ))
    printf '  [-\n'; erun ">" 64; printf '  +\n'; erun ">" $(( ST - 64 )); printf '  +\n'; erun "<" "$ST"
    printf '  ]'; [ $k -lt 63 ] && printf '>'; printf '\n'
    k=$(( k + 1 ))
done
printf '; walk to the temps\n'; erun ">" $(( ST - 63 ))
k=0; while [ $k -lt 64 ]; do
    printf '; temp back into @%03x\n' "$k"
    printf '  [-\n'; erun "<" "$ST"; printf '  +\n'; erun ">" "$ST"
    printf '  ]'; [ $k -lt 63 ] && printf '>'; printf '\n'
    k=$(( k + 1 ))
done
goto $(( ST + 63 )) $CTR
note "ten double rounds"; code "++++++++++"

echo; echo "; ==== ten double rounds ===="
note "one double round"; code "[-"
goto $CTR 0
qr 0 4 8 12 ; qr 1 5 9 13 ; qr 2 6 10 14 ; qr 3 7 11 15
qr 0 5 10 15 ; qr 1 6 11 12 ; qr 2 7 8 13 ; qr 3 4 9 14
goto 0 $CTR
code "]"

echo; echo "; ==== add the original state back  consuming orig ===="
goto $CTR 0
k=0; while [ $k -lt 16 ]; do add_mv_op $(( k * 4 )) $(( 64 + k * 4 )); k=$(( k + 1 )); done

echo; echo "; ==== move the block into the keystream  clearing the state ===="
mvn 0 $KS 64
goto 63 0

echo; echo "; ==== emit up to 64 bytes  each gated on remaining ===="
b=0
while [ $b -lt 64 ]; do
    printf '\n; ======== message byte slot %d ========\n' "$b"
    iszero $REMLO $F0 $Z0
    iszero $REMHI $F1 $Z1
    printf '; slot flag @%03x := 1 unless remaining is zero\n' "$FLAG"
    goto 0 $FLAG; printf '  ++\n'
    goto $FLAG $F0; printf '  [[-]\n'; erun ">" $(( FLAG - F0 )); printf '  -\n'; erun "<" $(( FLAG - F0 )); printf '  ]\n'
    goto $F0 $F1; printf '  [[-]\n'; erun ">" $(( FLAG - F1 )); printf '  -\n'; erun "<" $(( FLAG - F1 )); printf '  ]\n'
    goto $F1 $FLAG
    note "run this slot once when bytes remain"; code '[[-]'
    note "read one plaintext byte into the XOR frame"
    goto $FLAG $XA; code ','
    note "$(printf 'move keystream byte %d into the frame' "$b")"
    goto $XA $(( KS + b ))
    code '[-'; erun ">" $(( XA + 4 - KS - b )); code '+'; erun "<" $(( XA + 4 - KS - b )); code ']'
    goto $(( KS + b )) $XP; note "the bit weight starts at 1"; code '+'
    goto $XP $XCNT; note "eight bits"; code '++++++++'
    printf '%s\n' "$X8"
    printf '; emit the ciphertext byte\n'
    goto $XCNT $XRES; printf '  .\n  [-]\n'
    printf '; decrement remaining  borrowing into the high byte when it wraps\n'
    goto $XRES 0
    iszero $REMLO $WZ $WZZ
    goto 0 $REMLO; printf '  -\n'
    goto $REMLO $WZ; printf '  [[-]\n'; erun "<" $(( WZ - REMHI )); printf '  -\n'; erun ">" $(( WZ - REMHI )); printf '  ]\n'
    goto $WZ $FLAG
    printf ']\n'
    goto $FLAG 0
    b=$(( b + 1 ))
done

echo; echo "; ==== increment the 32 bit block counter ===="
note "the carry is threaded through a cell rather than each byte being tested"
note "on its own  so a byte is only touched when the byte below it carried"
note "the carry starts set  because one is always added to the low byte"
goto 0 $CC; code '+'
goto $CC 0
for i in 0 1 2 3; do
    note "$(printf 'counter byte %d' "$i")"
    note "move the carry into the gate  so the gate can be cleared inside it"
    goto 0 $CC
    code '[-'; erun ">" $(( GG - CC )); code '+'; erun "<" $(( GG - CC )); code ']'
    goto $CC $GG
    note "run once  and only when the byte below carried"
    code '['; code '[-]'
    goto $GG $(( CNT + i )); code '+'
    goto $(( CNT + i )) 0
    note "the carry out is set exactly when this byte wrapped to zero"
    iszero $(( CNT + i )) $CC $CZ
    goto 0 $GG
    code ']'
    goto $GG 0
done

echo; echo "; ==== recompute the continue flag for the next pass ===="
iszero $REMLO $F0 $Z0
iszero $REMHI $F1 $Z1
goto 0 $FLAG; printf '  ++\n'
goto $FLAG $F0; printf '  [[-]\n'; erun ">" $(( FLAG - F0 )); printf '  -\n'; erun "<" $(( FLAG - F0 )); printf '  ]\n'
goto $F0 $F1; printf '  [[-]\n'; erun ">" $(( FLAG - F1 )); printf '  -\n'; erun "<" $(( FLAG - F1 )); printf '  ]\n'
goto $F1 $FLAG
note "end of the outer loop"; code "]"
} > "$out"

echo "assembled $out ($(grep -c '' "$out") lines)"
