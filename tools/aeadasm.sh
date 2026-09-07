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
