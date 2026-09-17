; bfsodium ROTL64 : rotate a 64 bit little endian word LEFT by n
;
; INTERFACE entry=8 exit=0 footprint=0:27
; IO  in:  w{8} LE  followed by  n{1}       (9 bytes)
;     out: (w rotated left by n){8} LE      (8 bytes)
;
; TAPE MAP  (home @0)
;   @0x00:0x07  w{8}   u8   the word  LSB at @0x00; also rotr64's word
;   @0x08       m      u8   eight minus the bit part of n; rotr64's own counter
;   @0x09:0x14  rotr64's frame; its footprint is 0:20 pasted at this file's own
;               zero  which is what fixes everything below it
;   @0x15       k      u8   how many whole BYTES the word turns left
;   @0x16       s      u8   the bit part of n  worth nought to seven
;   @0x17       h      u8   HALVE frame: the byte being halved
;   @0x18       d      u8   HALVE frame: that byte shifted right one
;   @0x19       t      u8   HALVE frame: that byte low bit
;   @0x1a       f      u8   HALVE frame scratch  restored to nought
;   @0x1b       save   u8   the byte that falls off the top of the word  kept
;                           while the seven below it move up one place
;
; NOTHING HERE DOUBLES  and that is the only reason this file exists; A left
; rotation is the expensive direction in brainfuck because shifting left is
; DOUBLING and doubling a byte is an addition  where shifting right is HALVING
; and halving is a plain countdown; chacha20/rotl32 pays the adder four times
; per bit for exactly that reason and HANDOFF measures idiom/rotr32 at about a
; fifth of it;
;
; So this rotates left WITHOUT ever shifting left  by the identity
;
;   rotate left by (eight times q plus s)
;     = rotate left by eight times (q plus one)  then rotate RIGHT by (eight
;       minus s)
;
; where q is n shifted right three and s is the three bits that fell out; A
; rotation left by a whole multiple of eight is a rotation of whole BYTES  and
; a byte turns by being copied into the cell above it  which costs two
; instructions per unit of its value rather than an addition per bit; What is
; left is a right rotation of between one and eight bits  which is idiom/rotr64
; entered ONCE  pasted at this file's zero so the word is already where it
; wants it;
;
; MEASURED  because it is the whole point: rotr64 costs about sixty thousand
; instructions per bit of rotation  so the worst case here is eight bit steps
; and eight byte turns  where rotr64 asked for a left rotation by one would
; need sixty three right steps and cost over four million;
;
; q plus one is between one and eight and is NOT reduced modulo eight; turning
; an eight byte word left by eight whole bytes returns it to itself  so the
; case q equals seven costs eight cheap turns instead of a comparison;
;
; Every count is on the wire rather than pasted in  the way rotr64 and shr64
; take theirs  so Keccak's rho step can hand this the twenty five offsets FIPS
; 202 gives it from a table;

  ,>,>,>,>,>,>,>,>,                                            ; read w{0:7} then n  leaving the pointer on n @0x08
                                                               ; ASSERT ptr=8
                                                               ; ASSERT zero 9:27

; ============================================================ ; split n into the byte part and the bit part
  [->>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<]                           ; n steps into the halving frame  which empties its
                                                               ; cell for what goes back
>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=23
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; the first halving drops bit nought of n  which is
                                                               ; worth one in the bit part
>>
                                                               ; ASSERT ptr=25
  [-<<<+>>>]
<                                                              ; what is left goes back to be halved again
                                                               ; ASSERT ptr=24
  [-<+>]
<
                                                               ; ASSERT ptr=23
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; the second halving drops bit one  which is worth two
>>
                                                               ; ASSERT ptr=25
  [-<<<++>>>]
<                                                              ; and back again
                                                               ; ASSERT ptr=24
  [-<+>]
<
                                                               ; ASSERT ptr=23
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; the third halving drops bit two  which is worth four
>>
                                                               ; ASSERT ptr=25
  [-<<<++++>>>]
<                                                              ; and the quotient that is left is n shifted right
                                                               ; three  the byte part
                                                               ; ASSERT ptr=24
  [-<<<+>>>]

; ============================================================ ; the right rotation is eight bits less the bit part
<<<<<<<<<<<<<<<<                                               ; to the counter rotr64 will spend
                                                               ; ASSERT ptr=8
  ++++++++
>>>>>>>>>>>>>>                                                 ; the bit part is spent taking that count down  and
                                                               ; never takes it to nought
                                                               ; ASSERT ptr=22
  [-<<<<<<<<<<<<<<->>>>>>>>>>>>>>]

; ============================================================ ; the word turns left one whole byte  q plus one times
<
                                                               ; ASSERT ptr=21
                                                               ; the byte part is one turn short of what is wanted
                                                               ; because the right rotation above turns the word back
                                                               ; by up to a whole byte
  +
[
  -
<<<<<<<<<<<<<<                                                 ; to the top byte of the word
                                                               ; ASSERT ptr=7
  [->>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<]                 ; it is kept while the seven bytes below it move up
                                                               ; into its place
                                                               ; each byte takes the place of the one above it  from
                                                               ; the top down  so that none of them is written over
                                                               ; before it has moved
<
  [->+<] <
  [->+<] <
  [->+<] <
  [->+<] <
  [->+<] <
  [->+<] <
  [->+<]
                                                               ; ASSERT ptr=0
>>>>>>>>>>>>>>>>>>>>>>>>>>>                                    ; and the byte that fell off the top comes back in at
                                                               ; the bottom
                                                               ; ASSERT ptr=27
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>>]
<<<<<<                                                         ; back to the count of turns
]
                                                               ; ASSERT ptr=21

; ============================================================ ; and what is left is a right rotation of one to eight
                                                               ; bits
<<<<<<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=0
                                                               ; ASSERT zero 9:20
  >>>>>>>>                                                     ; walk in to this routine entry offset
                                                               ; ASSERT ptr=8
                                                               ; ASSERT zero 9:20

; ============================================================ ; ; rotate one bit  n times
[
  -                                                            ; one step consumed

                                                               ; ____ halve byte 0 @0x00  its low bit into c0 @0x09
                                                               ; ____ the byte steps into the halving frame
<<<<<<<<
  [->>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=17
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>                                                              ; the half goes back as the byte
  [-<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>]
>                                                              ; and the bit that fell off is kept
  [-<<<<<<<<<<+>>>>>>>>>>]
<<<<<<<<<<<                                                    ; back to the step counter
                                                               ; ASSERT ptr=8

                                                               ; ____ halve byte 1 @0x01  its low bit into c1 @0x0a
                                                               ; ____ the byte steps into the halving frame
<<<<<<<
  [->>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=17
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>                                                              ; the half goes back as the byte
  [-<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>]
>                                                              ; and the bit that fell off is kept
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<<<                                                    ; back to the step counter
                                                               ; ASSERT ptr=8

                                                               ; ____ halve byte 2 @0x02  its low bit into c2 @0x0b
                                                               ; ____ the byte steps into the halving frame
<<<<<<
  [->>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=17
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>                                                              ; the half goes back as the byte
  [-<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>]
>                                                              ; and the bit that fell off is kept
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<<<<                                                    ; back to the step counter
                                                               ; ASSERT ptr=8

                                                               ; ____ halve byte 3 @0x03  its low bit into c3 @0x0c
                                                               ; ____ the byte steps into the halving frame
<<<<<
  [->>>>>>>>>>>>>>+<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=17
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>                                                              ; the half goes back as the byte
  [-<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>]
>                                                              ; and the bit that fell off is kept
  [-<<<<<<<+>>>>>>>]
<<<<<<<<<<<                                                    ; back to the step counter
                                                               ; ASSERT ptr=8

                                                               ; ____ halve byte 4 @0x04  its low bit into c4 @0x0d
                                                               ; ____ the byte steps into the halving frame
<<<<
  [->>>>>>>>>>>>>+<<<<<<<<<<<<<]
>>>>>>>>>>>>>
                                                               ; ASSERT ptr=17
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>                                                              ; the half goes back as the byte
  [-<<<<<<<<<<<<<<+>>>>>>>>>>>>>>]
>                                                              ; and the bit that fell off is kept
  [-<<<<<<+>>>>>>]
<<<<<<<<<<<                                                    ; back to the step counter
                                                               ; ASSERT ptr=8

                                                               ; ____ halve byte 5 @0x05  its low bit into c5 @0x0e
                                                               ; ____ the byte steps into the halving frame
<<<
  [->>>>>>>>>>>>+<<<<<<<<<<<<]
>>>>>>>>>>>>
                                                               ; ASSERT ptr=17
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>                                                              ; the half goes back as the byte
  [-<<<<<<<<<<<<<+>>>>>>>>>>>>>]
>                                                              ; and the bit that fell off is kept
  [-<<<<<+>>>>>]
<<<<<<<<<<<                                                    ; back to the step counter
                                                               ; ASSERT ptr=8

                                                               ; ____ halve byte 6 @0x06  its low bit into c6 @0x0f
                                                               ; ____ the byte steps into the halving frame
<<
  [->>>>>>>>>>>+<<<<<<<<<<<]
>>>>>>>>>>>
                                                               ; ASSERT ptr=17
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>                                                              ; the half goes back as the byte
  [-<<<<<<<<<<<<+>>>>>>>>>>>>]
>                                                              ; and the bit that fell off is kept
  [-<<<<+>>>>]
<<<<<<<<<<<                                                    ; back to the step counter
                                                               ; ASSERT ptr=8

                                                               ; ____ halve byte 7 @0x07  its low bit into c7 @0x10
                                                               ; ____ the byte steps into the halving frame
<
  [->>>>>>>>>>+<<<<<<<<<<]
>>>>>>>>>>
                                                               ; ASSERT ptr=17
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>                                                              ; the half goes back as the byte
  [-<<<<<<<<<<<+>>>>>>>>>>>]
>                                                              ; and the bit that fell off is kept
  [-<<<+>>>]
<<<<<<<<<<<                                                    ; back to the step counter
                                                               ; ASSERT ptr=8

                                                               ; ____ each kept bit lands as the top bit of the byte
                                                               ; below it ____ c1 is the top bit of w0  and the
                                                               ; distance is ten for every one of c1 through c7  which
                                                               ; is why this reads as one step repeated
>>
                                                               ; ASSERT ptr=10
  [-<<<<<<<<<<++++++++++++++++++++++++++++++++++++++++++++++   ; c1 is the top bit of w0
  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   ; continued
  ++++++++++++++++++++++++>>>>>>>>>>]                          ; continued
>
  [-<<<<<<<<<<++++++++++++++++++++++++++++++++++++++++++++++   ; c2 is the top bit of w1
  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   ; continued
  ++++++++++++++++++++++++>>>>>>>>>>]                          ; continued
>
  [-<<<<<<<<<<++++++++++++++++++++++++++++++++++++++++++++++   ; c3 is the top bit of w2
  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   ; continued
  ++++++++++++++++++++++++>>>>>>>>>>]                          ; continued
>
  [-<<<<<<<<<<++++++++++++++++++++++++++++++++++++++++++++++   ; c4 is the top bit of w3
  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   ; continued
  ++++++++++++++++++++++++>>>>>>>>>>]                          ; continued
>
  [-<<<<<<<<<<++++++++++++++++++++++++++++++++++++++++++++++   ; c5 is the top bit of w4
  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   ; continued
  ++++++++++++++++++++++++>>>>>>>>>>]                          ; continued
>
  [-<<<<<<<<<<++++++++++++++++++++++++++++++++++++++++++++++   ; c6 is the top bit of w5
  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   ; continued
  ++++++++++++++++++++++++>>>>>>>>>>]                          ; continued
>
  [-<<<<<<<<<<++++++++++++++++++++++++++++++++++++++++++++++   ; c7 is the top bit of w6
  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   ; continued
  ++++++++++++++++++++++++>>>>>>>>>>]                          ; continued
<<<<<<<                                                        ; and c0 wraps all the way round to the top bit of w7
                                                               ; ASSERT ptr=9
  [-<<++++++++++++++++++++++++++++++++++++++++++++++++++++++
  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   ; continued
  ++++++++++++++++>>]                                          ; continued
<                                                              ; back to the step counter
                                                               ; ASSERT ptr=8
                                                               ; ASSERT zero 9:20
]
                                                               ; ASSERT ptr=8

  <<<<<<<<                                                     ; walk back out to the routine base
                                                               ; ASSERT ptr=0
                                                               ; ASSERT zero 8:27
; emit the rotated word little endian
  .>.>.>.>.>.>.>.
