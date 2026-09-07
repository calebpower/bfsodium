#!/bin/sh
# qrasm.sh — assemble chacha20/quarterround.bf from the verified primitive
# bodies (RFC 8439 quarter round).
#
# brainfuck has no subroutines, so a composite primitive has to physically
# contain its parts. But brainfuck code is position independent: a block that
# only moves relative to where it starts behaves identically wherever it is
# placed. So the quarter round reuses the EXACT bodies of add32.bf, xor32.bf
# and rotl32.bf -- the ones already checked against RFC vectors and the Cryptol
# spec -- placed at a common workspace base, with glue that moves words in and
# out. Nothing is retyped, so no arrow count is re-derived by hand and the
# parts cannot silently drift from the primitives they were proven as.
#
# This is an assembler, not a compiler: it emits the primitives' own annotated
# brainfuck verbatim, and the emitted file is the committed, reviewable source.
# All emission goes through tools/bfemit so every assembled file shares one
# style, which tools/bfstyle then checks.
#
# MEMORY
#   @0x00:0x03 a   @0x04:0x07 b   @0x08:0x0b c   @0x0c:0x0f d
#   @0x10 workspace base W: the primitive bodies see W as their cell 0
#   @0x2a:0x2d copy temps, so an operand can be read without being consumed
set -eu
here=$(cd "$(dirname "$0")" && pwd); repo=$(cd "$here/.." && pwd)
out="$repo/chacha20/quarterround.bf"

W=16; TB=42

body() { awk '/^,>,/{f=1;next} /^; emit/{f=0} f' "$repo/chacha20/$1.bf"; }
ADD=$(body add32); XOR=$(body xor32); ROTL=$(body rotl32)

. "$here/bfemit.sh"

{
cat <<'HDR'
; bfsodium ChaCha20 QUARTERROUND (RFC 8439 quarter round)
;
; ASSEMBLED FILE: emitted by tools/qrasm from the verified bodies of
; add32  xor32 and rotl32; those primitives each pass dual oracle
; KATs  and brainfuck is position independent  so their code is reused here
; verbatim rather than retyped at new offsets;
;
; IO  in:  a{4} LE  b{4} LE  c{4} LE  d{4} LE      (16 bytes)
;     out: the same four words after one quarter round (16 bytes)
;
; TAPE MAP  (home @0)
;   @0x00:0x03  a{4}  u8 LE
;   @0x04:0x07  b{4}  u8 LE
;   @0x08:0x0b  c{4}  u8 LE
;   @0x0c:0x0f  d{4}  u8 LE
;   @0x10       W     the shared workspace base; EVERY embedded body below
;                     addresses cells relative to W  so an "@0x00" inside an
;                     embedded block means cell @0x10 here  "@0x04" means
;                     @0x14  and so on;
;   @0x2a:0x2d  copy temps  so an operand survives being read
;
; The quarter round is four repetitions of the same shape:
;   a gets a plus b ; d gets d xor a ; d rotates left r
; with the roles and r cycling (a b d 16) (c d b 12) (a b d 8) (c d b 7);

; read a b c d  leaving the pointer on d3 @0x0f
,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,
HDR

printf '\n'; note "================ round 1 : a b d  rotate 16 ================"
goto 15 0;  add_op 0 4;   xor_op 12 0;  rot_op 12 16
printf '\n'; note "================ round 2 : c d b  rotate 12 ================"
add_op 8 12; xor_op 4 8;  rot_op 4 12
printf '\n'; note "================ round 3 : a b d  rotate 8 ================="
add_op 0 4;  xor_op 12 0; rot_op 12 8
printf '\n'; note "================ round 4 : c d b  rotate 7 ================="
add_op 8 12; xor_op 4 8;  rot_op 4 7
printf '\n'; note "emit a b c d little endian"
printf '  .>.>.>.>.>.>.>.>.>.>.>.>.>.>.>.\n'
} > "$out"

echo "assembled $out ($(grep -c '' "$out") lines)"
