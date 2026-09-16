; bfsodium SHR64 : shift a 64 bit little endian word right by n
;
; INTERFACE entry=8 exit=8 footprint=0:20
; IO  in:  w{8} LE  followed by  n{1}       (9 bytes)
;     out: (w shifted right by n){8} LE     (8 bytes)
;
; TAPE MAP  (home @0)
;   @0x00:0x07  w{8}   u8   the word  LSB at @0x00
;   @0x08       n      u8   remaining shift steps  the loop counter
;   @0x09:0x10  c{8}   u8   the low bit that fell out of each byte
;   @0x11       h      u8   HALVE frame: the byte being halved
;   @0x12       q      u8   HALVE frame: that byte shifted right one
;   @0x13       t      u8   HALVE frame: that byte low bit
;   @0x14       f      u8   HALVE frame scratch  restored to nought
;
; THE 64 BIT WIDENING OF idiom/shr32  and idiom/rotr64 WITH ONE LINE CHANGED;
; SHA_384 and SHA_512 need both: their sigma functions are two rotations and
; one SHIFT combined by exclusive or  so a shift that is not a rotation is
; not an optimisation here  it is a different answer;
;
; The method is rotr64's and the reasoning is unchanged; shifting RIGHT is
; HALVING  which is a plain countdown  where shifting LEFT is doubling and
; doubling a byte is an addition that pays the adder once per bit; rotr32
; measured about a fifth of rotl32 for that reason and the ratio does not
; change with the width;
;
; One bit of right shift halves all eight bytes and carries each low bit
; into the byte BELOW it: in a little endian word byte i holds bits 8i to
; 8i plus 7  so byte i's low bit is bit 8i  which lands at bit 8i minus 1
; the top bit of byte i minus 1; The low bit of byte 0 is bit 0  and in a
; SHIFT it simply goes  where rotr64 wraps it round to bit 63; A halved byte
; is at most 127  so adding 128 to it cannot overflow and no second pass is
; needed;
;
; ONE THING IS ACTUALLY SIMPLER AT 64 BITS THAN AT 32: the distance from a
; kept bit c_i to the byte it lands in is (9 plus i) minus (i minus 1) which
; is TEN  the same for every i; shr32's carry phase walks a different
; distance each time because its frame is packed tighter; Here there is no
; special case at all  because the one byte rotr64 treats specially is the
; one this file throws away;

,>,>,>,>,>,>,>,>,                                              ; read w{0:7} then n  leaving the pointer on n @0x08
                                                               ; ASSERT ptr=8
                                                               ; ASSERT zero 9:20

; ============================================================ ; shift one bit  n times
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
                                                               ; and c0 fell out of the bottom of the word  so it is
                                                               ; simply discarded; that ONE line is the whole
                                                               ; difference between this file and rotr64  and the two
                                                               ; should be read together
<<<<<<<
                                                               ; ASSERT ptr=9
  [-]
<                                                              ; back to the step counter
                                                               ; ASSERT ptr=8
                                                               ; ASSERT zero 9:20
]
                                                               ; ASSERT ptr=8

; emit
<<<<<<<<                                                       ; the shifted word little endian
  .>.>.>.>.>.>.>.
