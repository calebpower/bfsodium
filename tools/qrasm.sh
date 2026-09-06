#!/bin/sh
# qrasm.sh — assemble chacha20/quarterround.bf from the verified primitive bodies.
#
# brainfuck has no subroutines, so a composite primitive has to physically
# contain its parts. But brainfuck code is position independent: a block that
# only moves relative to where it starts behaves identically wherever it is
# placed. So the ChaCha20 quarter round reuses the EXACT bodies of add32.bf,
# xor32.bf and rotl32.bf -- the ones already checked against RFC vectors and
# the Cryptol spec -- placed at a common workspace base, with glue that moves
# words in and out. Nothing is retyped, so no arrow count is re-derived by
# hand and the parts cannot silently drift from the primitives they were
# proven as.
#
# This is an assembler, not a compiler: it emits the primitives' own annotated
# brainfuck verbatim, and the emitted file is the committed, reviewable source.
#
# MEMORY (home words, then a shared workspace at base 16):
#   @0x00:0x03 a   @0x04:0x07 b   @0x08:0x0b c   @0x0c:0x0f d
#   @0x10 workspace base W: the primitive bodies see W as their cell 0, so
#         every "@0x00" in an embedded body's comments means W plus that.
#   @0x2a:0x2d copy temps, so an operand can be read without being consumed.
set -eu
here=$(cd "$(dirname "$0")" && pwd); repo=$(cd "$here/.." && pwd)
out="$repo/chacha20/quarterround.bf"

# Extract a primitive's computational body: everything after its input line
# and before its output line.
body() { awk '/^,>,/{f=1;next} /^; emit/{f=0} f' "$repo/chacha20/$1.bf"; }
ADD=$(body add32); XOR=$(body xor32); ROTL=$(body rotl32)

rep() { i=0; while [ $i -lt "$2" ]; do printf '%s' "$1"; i=$((i+1)); done; }

# Emitters put one operation per line with an annotation, so the output meets
# the legibility rules in CONVENTIONS (no unannotated walls of command bytes).

# move 4 bytes from $1 to $2 (the source is consumed)
mv4() {
    if [ "$2" -gt "$1" ]; then d=$(( $2 - $1 )); f=">"; b="<"; else d=$(( $1 - $2 )); f="<"; b=">"; fi
    j=0; while [ $j -lt 4 ]; do
        printf '  ['; printf -- '-'; rep "$f" "$d"; printf '+'; rep "$b" "$d"; printf ']'
        [ $j -lt 3 ] && printf '>'
        printf '   ; move byte %d of @%02x to @%02x\n' "$j" $(( $1 + j )) $(( $2 + j ))
        j=$((j+1))
    done
}
# copy 4 bytes from $1 to $2 preserving the source, staging through temps @42
cp4() {
    d=$(( $2 - $1 )); t=$(( 42 - $1 )); g=$(( 42 - $2 ))
    j=0; while [ $j -lt 4 ]; do
        printf '  ['; printf -- '-'; rep ">" "$d"; printf '+'; rep ">" "$g"; printf '+'; rep "<" "$t"; printf ']'
        [ $j -lt 3 ] && printf '>'
        printf '   ; byte %d of @%02x to @%02x and to temp\n' "$j" $(( $1 + j )) $(( $2 + j ))
        j=$((j+1))
    done
    printf '  '; rep ">" $(( 42 - $1 - 3 )); printf '   ; walk to the temps\n'
    j=0; while [ $j -lt 4 ]; do
        printf '  ['; printf -- '-'; rep "<" "$t"; printf '+'; rep ">" "$t"; printf ']'
        [ $j -lt 3 ] && printf '>'
        printf '   ; put temp byte %d back into @%02x\n' "$j" $(( $1 + j ))
        j=$((j+1))
    done
}
goto() {
    [ "$1" -eq "$2" ] && return 0
    printf '  '
    if [ "$2" -gt "$1" ]; then rep ">" $(( $2 - $1 )); else rep "<" $(( $1 - $2 )); fi
    printf '   ; move the pointer to @%02x\n' "$2"
}

# Op helpers. CONVENTION: every op is entered with the pointer at cell 0 and
# leaves it at cell 0, so ops compose by plain concatenation -- the same
# pointer neutrality rule CONVENTIONS section 4 requires of hand written blocks.
add_op() {  # $1 dst home, $2 src home  -> dst := dst plus src
    echo "; ---- ADD32 : word at @$(printf '0x%02x' $1) gets word at @$(printf '0x%02x' $2) ----"
    goto 0 "$1"; mv4 "$1" 16; goto $(( $1 + 3 )) "$2"; cp4 "$2" 20; goto 45 24
    printf '%s\n' "$ADD"; echo "[-]                          ; drop the final carry"
    goto 24 16; mv4 16 "$1"; goto 19 0
}
xor_op() {  # $1 dst home, $2 src home  -> dst := dst xor src
    echo "; ---- XOR32 : word at @$(printf '0x%02x' $1) gets word at @$(printf '0x%02x' $2) ----"
    goto 0 "$1"; mv4 "$1" 16; goto $(( $1 + 3 )) "$2"; cp4 "$2" 20; goto 45 24
    printf '%s\n' "$XOR"; mv4 24 "$1"; goto 27 0
}
rot_op() {  # $1 home, $2 rotation
    echo "; ---- ROTL32 : word at @$(printf '0x%02x' $1) rotates left $2 ----"
    goto 0 "$1"; mv4 "$1" 16; goto $(( $1 + 3 )) 20; rep "+" "$2"; printf '   ; rotation count\n'
    printf '%s\n' "$ROTL"; goto 20 16; mv4 16 "$1"; goto 19 0
}

{
cat <<'HDR'
; bfsodium ChaCha20 QUARTERROUND (RFC 8439 section 2.2.1)
;
; ASSEMBLED FILE: emitted by tools/qrasm.sh from the verified bodies of
; add32.bf  xor32.bf and rotl32.bf; those primitives each pass dual oracle
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
echo; echo "; ================ round 1 : a b d  rotate 16 ================"
goto 15 0;  add_op 0 4;   xor_op 12 0;  rot_op 12 16
echo; echo "; ================ round 2 : c d b  rotate 12 ================"
add_op 8 12; xor_op 4 8;  rot_op 4 12
echo; echo "; ================ round 3 : a b d  rotate 8 ================="
add_op 0 4;  xor_op 12 0; rot_op 12 8
echo; echo "; ================ round 4 : c d b  rotate 7 ================="
add_op 8 12; xor_op 4 8;  rot_op 4 7
echo; echo "; emit a b c d little endian"
printf '.>.>.>.>.>.>.>.>.>.>.>.>.>.>.>.\n'
} > "$out"

echo "assembled $out"
