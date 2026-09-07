#!/bin/sh
# aeadasm.sh — assemble the ChaCha20-Poly1305 pieces that need the ChaCha block
# as a callable step rather than a whole program (RFC 8439 section 2.8).
#
# The AEAD has to ask for a keystream block several times, with the key and
# nonce held in cells rather than read from input, so the block function is
# used here through chacha_block_op in tools/bfemit rather than through the
# standalone chacha20/block program.
#
# Built so far:
#   chacha20/blockcore.bf   the block function via the emitter, so the emitter
#                           is held to the same RFC vector as block.bf
set -eu
here=$(cd "$(dirname "$0")" && pwd); repo=$(cd "$here/.." && pwd)

SB=0                 # the keystream block, and the state the rounds work on
ORIG=64              # the copy added back at the end
STEMP=128            # staging temps for duplicating the state
ROUNDS=192
KEY=200; CTRC=232; NONCE=236
W=260; TB=290        # workspace the embedded primitive bodies address
HT=400               # staging temps for copying the key, counter and nonce in

body() { awk '/^,>,/{f=1;next} /^; emit/{f=0} f' "$repo/chacha20/$1.bf"; }
ADD=$(body add32); XOR=$(body xor32); ROTL=$(body rotl32)
. "$here/bfemit.sh"

{
cat <<'HDR'
; bfsodium CHACHA20 BLOCKCORE : the block function  reached through the emitter
;
; ASSEMBLED FILE: emitted by tools/aeadasm; it computes the same thing as
; chacha20/block  but with the key  counter and nonce held in cells rather than
; read straight into the state  which is what the AEAD needs;
;
; IO  in:  key{32}  counter{4} LE  nonce{12}        (48 bytes)
;     out: keystream block{64}                      (64 bytes)
;
; TAPE MAP  (home @0)
;   @0x000:0x03f  block{64}   u8   the state  and the keystream block
;   @0x040:0x07f  orig{64}    u8   a copy  added back at the end
;   @0x080:0x0bf  stemp{64}   u8   temps for duplicating the state
;   @0x0c0        rounds      u8   ten double rounds  the loop counter
;   @0x0c8:0x0e7  key{32}     u8   held  so it survives being used
;   @0x0e8:0x0eb  counter{4}  u8   little endian
;   @0x0ec:0x0f7  nonce{12}   u8
;   @0x104        W                workspace base for the embedded bodies
;   @0x190:0x1af  staging temps for copying the key  counter and nonce in
HDR

note "read the key  counter and nonce into cells  not into the state"
goto 0 $KEY
printf '  ,'
k=1; while [ $k -lt 48 ]; do printf '>,'; [ $(( k % 30 )) -eq 0 ] && printf '\n  '; k=$(( k + 1 )); done
printf '\n'
goto $(( KEY + 47 )) 0

chacha_block_op $SB $KEY $CTRC $NONCE $ORIG $STEMP $ROUNDS $HT

printf '\n'; note "emit the keystream block"
goto 0 0
printf '  .'
k=1; while [ $k -lt 64 ]; do printf '>.'; [ $(( k % 20 )) -eq 0 ] && printf '\n  '; k=$(( k + 1 )); done
printf '\n'
} > "$repo/chacha20/blockcore.bf"

echo "assembled $repo/chacha20/blockcore.bf ($(grep -c '' "$repo/chacha20/blockcore.bf") lines)"

# ---- the AEAD (RFC 8439 section 2.8) ----
#
# The lengths of the additional data and the plaintext are fixed when the
# program is assembled, not read at run time. That is a real narrowing and it
# is deliberate: with the lengths known, every padding boundary, every block
# count and every buffer offset is a constant, so the program needs no indexed
# addressing anywhere. The general form would need the runtime gating that
# chacha20/stream and poly1305/poly1305 already carry, and it is future work;
# what is here computes the real AEAD, for the sizes it was told about.
#
#   aeadasm.sh [aad_len] [pt_len]     defaults to the RFC section 2.8.2 vector
AADLEN=${1:-12}
PTLEN=${2:-114}
APAD=$(( (AADLEN + 15) / 16 * 16 ))
CPAD=$(( (PTLEN + 15) / 16 * 16 ))
MACLEN=$(( APAD + CPAD + 16 ))
MACBLOCKS=$(( MACLEN / 16 ))
KSBLOCKS=$(( (PTLEN + 63) / 64 ))

OTK=250; RB=282; SB2=299; ACC=316; NBLK=333; RC=350
PT=370; MAC=700
HFR=1100; AFR=1106; XFR=1113; CPT2=1130; IT2=1150
MS2=1250; AB2=1440
W=1160; TB=1190; HT=1200

X8K=$(awk '/^  \[-$/{f=1} f{print} f&&/^  \]$/{exit}' "$repo/chacha20/xor32.bf")

le8() {   # $1 as eight little endian byte values
    _v=$1
    printf '%d %d %d %d 0 0 0 0' $(( _v % 256 )) $(( _v / 256 % 256 )) \
                                 $(( _v / 65536 % 256 )) $(( _v / 16777216 % 256 ))
}

{
cat <<HDR
; bfsodium CHACHA20_POLY1305 : the AEAD (RFC 8439 authenticated encryption)
;
; ASSEMBLED FILE: emitted by tools/aeadasm for aad length $AADLEN and plaintext
; length $PTLEN; the lengths are fixed when the program is assembled  so every
; padding boundary  block count and buffer offset is a constant and no indexed
; addressing is needed anywhere;
;
; IO  in:  key{32}  nonce{12}  aad{$AADLEN}  plaintext{$PTLEN}
;     out: ciphertext{$PTLEN}  tag{16}
;
; TAPE MAP  (home @0)
;   @0x000:0x03f  ks{64}      u8   the keystream block  and the ChaCha state
;   @0x040:0x07f  orig{64}    u8   the state copy added back at the end
;   @0x080:0x0bf  stemp{64}   u8   temps for duplicating the state
;   @0x0c0        rounds      u8
;   @0x0c8:0x0e7  key{32}     u8   held  so every block can use it
;   @0x0e8:0x0eb  counter{4}  u8   little endian  set per block
;   @0x0ec:0x0f7  nonce{12}   u8
;   @0x0fa:0x119  otk{32}     u8   the one time Poly1305 key  block zero
;   @0x11a:0x12a  r{17}       u8   clamped
;   @0x12b:0x13b  s{17}       u8
;   @0x13c:0x14c  acc{17}     u8   the Poly1305 accumulator
;   @0x14d:0x15d  n{17}       u8   the block being absorbed
;   @0x15e:0x16e  rc{17}      u8   a copy of r  since the multiply consumes it
;   @0x172        plaintext
;   @0x2bc        mac data: aad  padded  then ciphertext  padded  then lengths
;
; The one time key is ChaCha block zero; the ciphertext uses blocks one onward;
; the tag authenticates the additional data and the ciphertext  each padded to
; a multiple of sixteen  followed by their two lengths as eight byte numbers;
HDR

note "read the key and nonce"
goto 0 $KEY
printf '  ,'; k=1; while [ $k -lt 44 ]; do printf '>,'; [ $(( k % 30 )) -eq 0 ] && printf '\n  '; k=$(( k + 1 )); done; printf '\n'
goto $(( KEY + 43 )) 0
if [ "$AADLEN" -gt 0 ]; then
    note "read the additional data straight into the start of the mac data"
    goto 0 $MAC
    printf '  ,'; k=1; while [ $k -lt "$AADLEN" ]; do printf '>,'; k=$(( k + 1 )); done; printf '\n'
    goto $(( MAC + AADLEN - 1 )) 0
fi
note "read the plaintext"
goto 0 $PT
printf '  ,'; k=1; while [ $k -lt "$PTLEN" ]; do printf '>,'; [ $(( k % 30 )) -eq 0 ] && printf '\n  '; k=$(( k + 1 )); done; printf '\n'
goto $(( PT + PTLEN - 1 )) 0

note "======== block zero gives the one time Poly1305 key ========"
chacha_block_op 0 $KEY 232 236 64 128 192 $HT
note "keep the first thirty two bytes of it"
goto 0 0; mvn 0 $OTK 32; goto 31 0
note "clear the rest of the block"
k=32; while [ $k -lt 64 ]; do goto 0 $k; code '[-]'; goto $k 0; k=$(( k + 1 )); done

note "r is the first half of the one time key  clamped"
goto 0 $OTK; mvn $OTK $RB 16; goto $(( OTK + 15 )) 0
for c in 3 7 11 15; do and15_op $(( RB + c )) $HFR $AB2; done
for c in 4 8 12; do and252_op $(( RB + c )) $HFR; done
note "s is the second half"
goto 0 $(( OTK + 16 )); mvn $(( OTK + 16 )) $SB2 16; goto $(( OTK + 31 )) 0

b=0
while [ $b -lt "$KSBLOCKS" ]; do
    note "======== keystream block $(( b + 1 )) ========"
    goto 0 232; code '[-]'; erun "+" $(( b + 1 )); goto 232 0
    k=233; while [ $k -lt 236 ]; do goto 0 $k; code '[-]'; goto $k 0; k=$(( k + 1 )); done
    chacha_block_op 0 $KEY 232 236 64 128 192 $HT
    j=0
    while [ $j -lt 64 ] && [ $(( b * 64 + j )) -lt "$PTLEN" ]; do
        i=$(( b * 64 + j ))
        note "ciphertext byte $i"
        goto 0 $(( PT + i )); mvn $(( PT + i )) $(( MAC + APAD + i )) 1; goto $(( PT + i )) 0
        xor8_op $(( MAC + APAD + i )) $j $XFR
        j=$(( j + 1 ))
    done
    note "clear what is left of this keystream block"
    k=0; while [ $k -lt 64 ]; do goto 0 $k; code '[-]'; goto $k 0; k=$(( k + 1 )); done
    b=$(( b + 1 ))
done

note "the length block: the two lengths as eight byte little endian numbers"
setbytes_op $(( MAC + APAD + CPAD )) $(le8 $AADLEN)
setbytes_op $(( MAC + APAD + CPAD + 8 )) $(le8 $PTLEN)

note "emit the ciphertext"
goto 0 $(( MAC + APAD ))
printf '  .'; k=1; while [ $k -lt "$PTLEN" ]; do printf '>.'; [ $(( k % 20 )) -eq 0 ] && printf '\n  '; k=$(( k + 1 )); done; printf '\n'
goto $(( MAC + APAD + PTLEN - 1 )) 0

note "======== authenticate the mac data  $MACBLOCKS blocks ========"
blk=0
while [ $blk -lt "$MACBLOCKS" ]; do
    note "---- mac block $blk ----"
    goto 0 $MAC; mvn $MAC $NBLK 16; goto $(( MAC + 15 )) 0
    note "every mac block is full  so the appended one always sits above it"
    goto 0 $(( NBLK + 16 )); code '+'; goto $(( NBLK + 16 )) 0
    addn_op $ACC $NBLK 17 $AFR
    cpn_at $RB $RC 17 $CPT2
    mulmod_op $ACC $RC 17 $MS2
    if [ $(( blk + 1 )) -lt "$MACBLOCKS" ]; then
        shiftdown_op $MAC 16 $(( MACLEN - 16 ))
    fi
    blk=$(( blk + 1 ))
done

note "add s  the tag is the low sixteen bytes"
addn_op $ACC $SB2 17 $AFR

printf '\n'; note "emit the sixteen byte tag"
goto 0 $ACC
printf '  .'; k=1; while [ $k -lt 16 ]; do printf '>.'; k=$(( k + 1 )); done; printf '\n'
} > "$repo/chacha20/aead.bf"

echo "assembled $repo/chacha20/aead.bf ($(grep -c '' "$repo/chacha20/aead.bf") lines) for aad=$AADLEN pt=$PTLEN"
