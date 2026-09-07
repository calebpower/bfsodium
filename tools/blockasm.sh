#!/bin/sh
# blockasm.sh — assemble chacha20/block.bf, the ChaCha20 block function
# (RFC 8439 block function), from the verified primitive bodies.
#
# Same principle as qrasm.sh: brainfuck is position independent, so the bodies
# of add32.bf, xor32.bf and rotl32.bf -- each already checked against RFC
# vectors and the Cryptol spec -- are spliced in verbatim at a shared workspace
# base, with glue that moves words in and out. Nothing is retyped, so the parts
# cannot drift from the code that was proven.
#
# The ten double rounds are a counter driven loop, so the eight quarter rounds
# appear once in the source rather than eighty times.
#
# The workspace sits far from the state, so pointer runs here are long. Every
# run is emitted on its own chunked line, so no line is an unexplained wall of
# command bytes. Newlines are ignored by brainfuck, so this is presentational
# only, and the KAT is re-run afterwards to prove it.
#
# MEMORY
#   @0x00:0x3f  working state, 16 words of 4 little endian bytes
#   @0x40:0x7f  the original state, kept for the final add
#   @0x80       round counter (10 double rounds)
#   @0xa0:0xdf  temps for duplicating the state
#   @0xe0       W, the workspace the embedded primitive bodies see as cell 0
#   @0xfc       copy temps, so an operand survives being read
set -eu
here=$(cd "$(dirname "$0")" && pwd); repo=$(cd "$here/.." && pwd)
out="$repo/chacha20/block.bf"

W=224          # workspace base for the embedded bodies
TB=252         # 4 copy temps for operands
ST=160         # 64 temps for duplicating the state
CTR=128        # round counter
CHUNK=40       # command bytes per emitted line

body() { awk '/^,>,/{f=1;next} /^; emit/{f=0} f' "$repo/chacha20/$1.bf"; }
ADD=$(body add32); XOR=$(body xor32); ROTL=$(body rotl32)

. "$here/bfemit.sh"


{
cat <<'HDR'
; bfsodium ChaCha20 BLOCK FUNCTION (RFC 8439 block function)
;
; ASSEMBLED FILE: emitted by tools/blockasm from the verified bodies of
; add32  xor32 and rotl32; brainfuck is position independent  so those
; bodies are reused here verbatim rather than retyped at new offsets;
;
; IO  in:  key{32}  counter{4} LE  nonce{12}        (48 bytes)
;     out: keystream block{64}                      (64 bytes)
;
; TAPE MAP  (home @0)
;   @0x00:0x3f  state{16}  u32 LE   the working state
;   @0x40:0x7f  orig{16}   u32 LE   a copy  added back at the end
;   @0x80       rounds     u8       10 double rounds  the loop counter
;   @0xa0:0xdf  stemp{64}  u8       temps for duplicating the state
;   @0xe0       W                   workspace base; EVERY embedded body below
;                                   addresses cells relative to W  so an
;                                   "@0x00" inside an embedded block means
;                                   @0xe0 here  "@0x04" means @0xe4  and so on
;   @0xfc:0xff  copy temps          so an operand survives being read
;
; The state is the 16 byte constant "expand 32 byte k"  then the key  then the
; block counter  then the nonce; ten double rounds each apply four column
; quarter rounds and four diagonal ones; finally the original state is added
; back word by word  which is what makes the function non invertible;
HDR

echo; echo "; ==== the constant  which is the ASCII of expand 32 byte k ===="
prev=0
cell=0
for v in 101 120 112 97 110 100 32 51 50 45 98 121 116 101 32 107; do
    goto $prev $cell
    printf '; @%02x gets %d\n' "$cell" "$v"; erun "+" "$v"
    prev=$cell; cell=$(( cell + 1 ))
done

echo; echo "; ==== read the key  counter and nonce into words 4 through 15 ===="
goto $prev 16
printf '; 48 bytes into @10:@3f\n  ,'
k=1; while [ $k -lt 48 ]; do printf '>,'; [ $(( k % 30 )) -eq 0 ] && printf '\n  '; k=$(( k + 1 )); done
printf '\n'

echo; echo "; ==== duplicate the state into orig ===="
goto 63 0
k=0; while [ $k -lt 64 ]; do
    printf '; byte @%02x to @%02x and to a temp\n' "$k" $(( k + 64 ))
    printf '  [-\n'; erun ">" 64; printf '  +\n'; erun ">" $(( ST - 64 )); printf '  +\n'; erun "<" "$ST"
    printf '  ]'; [ $k -lt 63 ] && printf '>'; printf '\n'
    k=$(( k + 1 ))
done
printf '; walk to the temps\n'; erun ">" $(( ST - 63 ))
k=0; while [ $k -lt 64 ]; do
    printf '; temp back into @%02x\n' "$k"
    printf '  [-\n'; erun "<" "$ST"; printf '  +\n'; erun ">" "$ST"
    printf '  ]'; [ $k -lt 63 ] && printf '>'; printf '\n'
    k=$(( k + 1 ))
done
goto $(( ST + 63 )) $CTR
note "ten double rounds"; code "++++++++++"

echo; echo "; ==== ten double rounds ===="
note "one double round"; code "[-"
goto $CTR 0
echo; echo "; ==== the column round ===="
qr 0 4 8 12 ; qr 1 5 9 13 ; qr 2 6 10 14 ; qr 3 7 11 15
echo; echo "; ==== the diagonal round ===="
qr 0 5 10 15 ; qr 1 6 11 12 ; qr 2 7 8 13 ; qr 3 4 9 14
goto 0 $CTR
code "]"

echo; echo "; ==== add the original state back  word by word ===="
goto $CTR 0
k=0; while [ $k -lt 16 ]; do add_op $(( k * 4 )) $(( 64 + k * 4 )); k=$(( k + 1 )); done

echo; echo "; emit the 64 byte keystream block"
printf '  .'
k=1; while [ $k -lt 64 ]; do printf '>.'; [ $(( k % 20 )) -eq 0 ] && printf '\n  '; k=$(( k + 1 )); done
printf '\n'
} > "$out"

echo "assembled $out ($(grep -c '' "$out") lines)"
