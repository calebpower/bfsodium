; bfsodium LEFTENC : NIST SP 800_185 section 2 3 1's left_encode
;
; HAND WRITTEN skeleton;
;
; INTERFACE entry=3 exit=12 footprint=0:17
; IO  in:  x{4} LE                      (4 bytes)
;     out: the encoding  its count byte FIRST
;
; left_encode of x is the shortest big endian run of bytes that holds x  with a
; count of them before; the count is at least one  so nought
; encodes as two bytes and not one;
;
; X IS THIRTY TWO BITS AND THAT IS A CHOICE; the standard allows any x
; below two to the two thousand and fortieth  and everything SP 800_185
; asks of this routine is far smaller: a rate of a hundred and thirty six
; or a hundred and sixty eight  a string's length in bits  or an output
; length; thirty two bits covers all of them and keeps the count to a
; four way branch that needs no index;
;
; THERE IS NO SLIDING HERE AND THAT IS THE POINT; the count decides WHICH
; of x's bytes are copied and not WHERE they land  so each of the four
; cases is a fixed pattern written out  and the assembly that does need
; sliding is one level up where encode_string and bytepad live;
;
; TAPE MAP  (home @0)
;   @0x00:0x03  x{4}   u32 LE  the value; its significant bytes are SPENT
;   @0x04       any    u8   a case has already been chosen
;   @0x05:0x08  f4 f3 f2 f1  u8  exactly one of them is set
;   @0x09       t      u8   the cell a byte is tested through
;   @0x0a       b      u8   and handed back through
;   @0x0b       s      u8   the else arm of the cascade
;   @0x0c       outlen u8   how many bytes the encoding came to
;   @0x0d:0x11  enc{5} u8   the encoding itself

,>,>,>,                                                        ; read the value
                                                               ; ASSERT ptr=3

; ============================================================ ; which case: the highest byte that is not nought
                                                               ; decides
                                                               ; byte 3 is this byte not nought
  [->>>>>>+>+<<<<<<<]
>>>>>>>
  [-<<<<<<<+>>>>>>>]
<
[
  -
<<<<                                                           ; then the count is 3 and no later byte may choose
  [-]
  +
<
  [-]
  +
>>>>>
]

                                                               ; byte 2 only if no higher byte has already chosen
                                                               ; which the else arm says
>>
  [-]
  +
<<<<<<<
  [->>>>>+>+<<<<<<]
>>>>>>
  [-<<<<<<+>>>>>>]
<
  [[-]>>[-]<<]
>>
[
  -
<<<<<<<<<                                                      ; is this byte not nought
  [->>>>>>>+>+<<<<<<<<]
>>>>>>>>
  [-<<<<<<<<+>>>>>>>>]
<
[
  -
<<<                                                            ; then the count is 2 and no later byte may choose
  [-]
  +
<<
  [-]
  +
>>>>>
]
>>
]

                                                               ; byte 1 only if no higher byte has already chosen
                                                               ; which the else arm says
  [-]
  +
<<<<<<<
  [->>>>>+>+<<<<<<]
>>>>>>
  [-<<<<<<+>>>>>>]
<
  [[-]>>[-]<<]
>>
[
  -
<<<<<<<<<<                                                     ; is this byte not nought
  [->>>>>>>>+>+<<<<<<<<<]
>>>>>>>>>
  [-<<<<<<<<<+>>>>>>>>>]
<
[
  -
<<                                                             ; then the count is 1 and no later byte may choose
  [-]
  +
<<<
  [-]
  +
>>>>>
]
>>
]

<<<                                                            ; and one byte is the case when nothing else chose
  [-]
  +
<<<<
  [->>>>>+>+<<<<<<]
>>>>>>
  [-<<<<<<+>>>>>>]
<
  [[-]<[-]>]

; ============================================================ ; each case is a fixed pattern  which is why there is
                                                               ; no index
<                                                              ; 1 byte
[
  -
>>>>>                                                          ; the count first
  +
<<<<<<<<<<<<<                                                  ; then x's bytes  most significant first
  [->>>>>>>>>>>>>>+<<<<<<<<<<<<<<]
>>>>>>>>>>>>                                                   ; and the emit below takes one more than the count
  ++
<<<<
]

<                                                              ; 2 bytes
[
  -
>>>>>>                                                         ; the count first
  ++
<<<<<<<<<<<<                                                   ; then x's bytes  most significant first
  [->>>>>>>>>>>>>+<<<<<<<<<<<<<]
<
  [->>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<]
>>>>>>>>>>>>                                                   ; and the emit below takes one more than the count
  +++
<<<<<
]

<                                                              ; 3 bytes
[
  -
>>>>>>>                                                        ; the count first
  +++
<<<<<<<<<<<                                                    ; then x's bytes  most significant first
  [->>>>>>>>>>>>+<<<<<<<<<<<<]
<
  [->>>>>>>>>>>>>>+<<<<<<<<<<<<<<]
<
  [->>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>                                                   ; and the emit below takes one more than the count
  ++++
<<<<<<
]

<                                                              ; 4 bytes
[
  -
>>>>>>>>                                                       ; the count first
  ++++
<<<<<<<<<<                                                     ; then x's bytes  most significant first
  [->>>>>>>>>>>+<<<<<<<<<<<]
<
  [->>>>>>>>>>>>>+<<<<<<<<<<<<<]
<
  [->>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<]
<
  [->>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>                                                   ; and the emit below takes one more than the count
  +++++
<<<<<<<
]

; ============================================================ ; the frame is left as clean as a caller may assume it
                                                               ; was
                                                               ; ANY is the one cell a case can leave standing  and a
                                                               ; second paste of this routine would then skip every
                                                               ; case and quietly encode nothing; a routine that is
                                                               ; pasted twice must clean up after itself and this one
                                                               ; is  so the contract below is checked rather than
                                                               ; promised
<
  [-]
                                                               ; ASSERT zero 0:11

>>>>>>>>                                                       ; the body ends on the count  which is what the emit
                                                               ; walks from
                                                               ; ASSERT ptr=12

; emit
                                                               ; as many bytes as the encoding came to  head first
                                                               ; sliding the rest down after each one  so the head is
                                                               ; always the same cell
[
  -
>
  .
  [-]
>
  [-<+>]>[-<+>]>[-<+>]>[-<+>]
<<<<<
]
