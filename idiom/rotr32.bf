; bfsodium ROTR32 : rotate a 32 bit little endian word right by n
;
; INTERFACE entry=4 exit=4 footprint=0:12
; IO  in:  w{4} LE  followed by  n{1}       (5 bytes)
;     out: (w rotated right by n){4} LE     (4 bytes)
;
; TAPE MAP  (home @0)
;   @0x00:0x03  w{4}   u8   the word  LSB at @0x00
;   @0x04       n      u8   remaining rotation steps  the loop counter
;   @0x05:0x08  c{4}   u8   the low bit that fell out of each byte
;   @0x09       h      u8   HALVE frame: the byte being halved
;   @0x0a       q      u8   HALVE frame: that byte shifted right one
;   @0x0b       t      u8   HALVE frame: that byte low bit
;   @0x0c       f      u8   HALVE frame scratch  restored to nought
;
; This is the mirror of chacha20/rotl32 and it is MUCH cheaper  which is the
; whole reason it exists; rotl32 shifts LEFT by doubling  and doubling a byte
; is an addition  so it pays the adder four times per bit; shifting RIGHT is
; halving  and HALVE is a plain countdown that costs about a fifth as much;
;
; One bit of right rotation halves all four bytes and carries each low bit into
; the byte BELOW it: in a little endian word byte i holds bits 8i to 8i plus 7
; so byte i's low bit is bit 8i  which lands at bit 8i minus 1  the top bit of
; byte i minus 1; The low bit of byte 0 is bit 0  which wraps around to bit 31
; the top bit of byte 3; A halved byte is at most 127  so adding 128 to it
; cannot overflow and no second pass is needed;

,>,>,>,>,                                                      ; read w{0:3} then n  leaving the pointer on n @0x04
; ASSERT ptr=4
; ASSERT zero 5:12

; ==== rotate one bit  n times ====
[
  -                                                            ; one step consumed

; ____ halve byte 0 @0x00  its low bit into c0 @0x05 ____
; the byte steps into the halving frame
<<<<
  [->>>>>>>>>+<<<<<<<<<]
>>>>>>>>>
; ASSERT ptr=9
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>                                                              ; the half goes back as the byte
  [-<<<<<<<<<<+>>>>>>>>>>]
>                                                              ; and the bit that fell off is kept
  [-<<<<<<+>>>>>>]
<<<<<<<                                                        ; back to the step counter
; ASSERT ptr=4

; ____ halve byte 1 @0x01  its low bit into c1 @0x06 ____
; the byte steps into the halving frame
<<<
  [->>>>>>>>+<<<<<<<<]
>>>>>>>>
; ASSERT ptr=9
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>                                                              ; the half goes back as the byte
  [-<<<<<<<<<+>>>>>>>>>]
>                                                              ; and the bit that fell off is kept
  [-<<<<<+>>>>>]
<<<<<<<                                                        ; back to the step counter
; ASSERT ptr=4

; ____ halve byte 2 @0x02  its low bit into c2 @0x07 ____
; the byte steps into the halving frame
<<
  [->>>>>>>+<<<<<<<]
>>>>>>>
; ASSERT ptr=9
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>                                                              ; the half goes back as the byte
  [-<<<<<<<<+>>>>>>>>]
>                                                              ; and the bit that fell off is kept
  [-<<<<+>>>>]
<<<<<<<                                                        ; back to the step counter
; ASSERT ptr=4

; ____ halve byte 3 @0x03  its low bit into c3 @0x08 ____
; the byte steps into the halving frame
<
  [->>>>>>+<<<<<<]
>>>>>>
; ASSERT ptr=9
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>                                                              ; the half goes back as the byte
  [-<<<<<<<+>>>>>>>]
>                                                              ; and the bit that fell off is kept
  [-<<<+>>>]
<<<<<<<                                                        ; back to the step counter
; ASSERT ptr=4

; ____ each kept bit lands as the top bit of the byte below it ____
; c1 is the top bit of w0
>>
; ASSERT ptr=6
  [-<<<<<<++++++++++++++++++++++++++++++++++++++++++++++++++
  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   ; continued
  ++++++++++++++++++++>>>>>>]                                  ; continued
>                                                              ; c2 is the top bit of w1
  [-<<<<<<++++++++++++++++++++++++++++++++++++++++++++++++++
  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   ; continued
  ++++++++++++++++++++>>>>>>]                                  ; continued
>                                                              ; c3 is the top bit of w2
  [-<<<<<<++++++++++++++++++++++++++++++++++++++++++++++++++
  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   ; continued
  ++++++++++++++++++++>>>>>>]                                  ; continued
<<<                                                            ; and c0 wraps all the way round to the top bit of w3
; ASSERT ptr=5
  [-<<++++++++++++++++++++++++++++++++++++++++++++++++++++++
  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   ; continued
  ++++++++++++++++>>]                                          ; continued
<                                                              ; back to the step counter
; ASSERT ptr=4
; ASSERT zero 5:12
]
; ASSERT ptr=4

; emit
<<<<                                                           ; the rotated word little endian
  .>.>.>.
