; bfsodium FOLD136 : one Poly1305 reduction step  using 2^130 = 5 modulo p
;
; HAND WRITTEN; The split is at bit 130  and 130 is 128 plus 2  so the part of
; the value at or above the split is simply the TOP BYTE shifted right twice  and
; the part below it is that byte with all but its bottom two bits removed; No
; shifting of the whole seventeen bytes is needed anywhere;
;
; INTERFACE entry=16 exit=0 footprint=0:34
; IO  in:  x{17} LE                     (17 bytes)
;     out: (L plus 5H){17} LE           (17 bytes)  where x = L plus H times 2^130
;
; TAPE MAP  (home @0)
;   @0x00:0x10  x{17}   u8   the value  and the result
;   @0x11:0x1b  the eight bit adder's frame; add8 pasted at @0x11  so its
;               accumulator is @0x11  its addend @0x12 and its carry @0x13
;   @0x1c       Alo     u8   five times H  low byte;  LATER the ripple's else arm
;   @0x1d       Ahi     u8   five times H  high byte; LATER the ripple's copy
;   @0x1e       H       u8   the part at or above bit 130  at most 63; LATER the
;                            cell that hands that copy back
;   @0x1f       h       u8   HALVE frame: the byte being halved
;   @0x20       q       u8   HALVE frame: that byte shifted right one
;   @0x21       bit     u8   HALVE frame: that byte low bit
;   @0x22       f       u8   HALVE frame scratch  restored to nought
;
; THREE CELLS ARE USED TWICE and that is deliberate rather than clever: Alo  Ahi
; and H are all SPENT before the carry ripple begins  so the ripple borrows them
; for its else arm and its copy rather than asking for three more; Every one of
; them is nought when the ripple starts and nought when it ends;
;
; H is at most 63  so five times H is at most 315 and the value below the split
; is under 2^130; their sum cannot reach 2^136  so the top carry is never
; reached and folding never loses anything;
;
; FIVE TIMES H IS ONE ADDEND  not five turns of the adder; Five times sixty
; three is three hundred and fifteen  which is TWO BYTES  so this file builds
; four times H and one copy of H side by side  adds those two bytes with add8
; and has the low byte and the high byte of the addend in hand;
;
; AND THAT IS WHY THIS FILE NO LONGER ENTERS add136; A seventeen byte add is
; seventeen entries of add8  and add8 costs about fourteen thousand instructions
; whatever its addend is  because nearly all of that is the seven halvings that
; find bit 7 of the ACCUMULATOR; So fifteen of those seventeen entries were
; spending fourteen thousand instructions to add NOUGHT; This file adds the two
; bytes it actually has with two entries of add8 and lets the carry out of the
; second one RIPPLE  and a ripple through a byte that is not 255 costs one
; instruction;
;
; MEASURED at both ends of its own vector set: on the all ones value this file
; cost 635880 instructions and now costs 116020  and on a value with no short
; bytes 436942 and now 125114; Inside mulmod136's large vector  which enters
; this file two hundred and seventy two times  the add136 it no longer enters
; was thirty one and a half million of that file's hundred and forty five;
;
; THE RIPPLE IS FIFTEEN BLOCKS AND FOURTEEN OF THEM ARE UNROLLED THE SAME WAY:
; if the carry is set it is spent  the byte takes the one  and the byte is
; copied out and looked at; a byte that came to nought had 255 in it and the
; carry lives on; The sixteenth byte does not look  because the sum cannot reach
; 2^136 and so the carry out of the top byte is a carry that cannot happen;

  ,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,                            ; read the value little endian

; ============================================================ ; split the top byte at bit 130
                                                               ; ASSERT ptr=16
                                                               ; ASSERT zero 17:34
  [->>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<]                           ; the top byte steps into the halving frame
>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=31
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; the first halving; the bit it drops is bit 128
>>                                                             ; which is worth one in what is left below the split
                                                               ; ASSERT ptr=33
  [-<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>]
<                                                              ; the half steps back into the frame to be halved again
                                                               ; ASSERT ptr=32
  [-<+>]
<
                                                               ; ASSERT ptr=31
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; the second halving; the bit it drops is bit 129
>>                                                             ; which is worth two
                                                               ; ASSERT ptr=33
  [-<<<<<<<<<<<<<<<<<++>>>>>>>>>>>>>>>>>]
<                                                              ; and what is left in the quotient is everything at bit
                                                               ; 130 and above
                                                               ; ASSERT ptr=32
  [-<<+>>]

; ============================================================ ; two to the hundred and thirtieth is five  so five
                                                               ; times that part
<<                                                             ; to the part above the split
                                                               ; ASSERT ptr=30
                                                               ; it is spent ONCE  into four copies of itself and one
                                                               ; copy of itself  which is where the five comes from;
                                                               ; neither cell can wrap  because four times sixty three
                                                               ; is two hundred and fifty two
  [-<<<<<<<<<<<<<++++>+>>>>>>>>>>>>]
                                                               ; ASSERT ptr=30
<<<<<<<<<<<<<                                                  ; to the byte pair the eight bit adder works on
                                                               ; ASSERT ptr=17
                                                               ; ASSERT zero 19:27
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=18
                                                               ; ASSERT zero 20:27
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=17
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=20
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=18
  [->>+<<]
>>
                                                               ; ASSERT ptr=20
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=24
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=27
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=25
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=22
  [-[[-]>>>>+<<<<]]
; ============================================================ ; ; the carry out is bit 7 of that  and nothing else
>>>>
                                                               ; ASSERT ptr=26
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=20
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 1 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 2 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 3 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 4 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 5 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 6 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 7 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
                                                               ; ASSERT ptr=20
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ============================================================ ; ; the sum is twice the halves plus the two low bits
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=24
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=25
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=17
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 18:18
                                                               ; ASSERT zero 20:27

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=17
  [->>>>>>>>>>>+<<<<<<<<<<<]                                   ; the sum is five times H modulo 256  and it is the
                                                               ; addend's low byte
>>                                                             ; to the carry add8 computed
                                                               ; ASSERT ptr=19
  [->>>>>>>>>>+<<<<<<<<<<]                                     ; which is the addend's high byte  worth two hundred
                                                               ; and fifty six

; ============================================================ ; the bottom byte of the value takes the low byte of
                                                               ; five times H
<<<<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=0
  [->>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=28
  [-<<<<<<<<<<+>>>>>>>>>>]
<<<<<<<<<<<
                                                               ; ASSERT ptr=17
                                                               ; ASSERT zero 19:27
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=18
                                                               ; ASSERT zero 20:27
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=17
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=20
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=18
  [->>+<<]
>>
                                                               ; ASSERT ptr=20
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=24
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=27
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=25
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=22
  [-[[-]>>>>+<<<<]]
; ============================================================ ; ; the carry out is bit 7 of that  and nothing else
>>>>
                                                               ; ASSERT ptr=26
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=20
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 1 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 2 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 3 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 4 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 5 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 6 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 7 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
                                                               ; ASSERT ptr=20
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ============================================================ ; ; the sum is twice the halves plus the two low bits
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=24
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=25
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=17
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 18:18
                                                               ; ASSERT zero 20:27

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=17
  [-<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>]                       ; the sum goes home and the carry stays where add8 left
                                                               ; it

; ============================================================ ; the second byte takes the high byte  and that carry
                                                               ; with it
<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=1
  [->>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=29
  [-<<<<<<<<<<<+>>>>>>>>>>>]
<<<<<<<<<<
                                                               ; ASSERT ptr=19
  [-<+>]
<<
                                                               ; ASSERT ptr=17
                                                               ; ASSERT zero 19:27
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=18
                                                               ; ASSERT zero 20:27
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=17
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=20
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=18
  [->>+<<]
>>
                                                               ; ASSERT ptr=20
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=24
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=27
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=25
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=22
  [-[[-]>>>>+<<<<]]
; ============================================================ ; ; the carry out is bit 7 of that  and nothing else
>>>>
                                                               ; ASSERT ptr=26
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=20
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 1 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 2 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 3 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 4 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 5 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 6 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 7 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
                                                               ; ASSERT ptr=20
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ============================================================ ; ; the sum is twice the halves plus the two low bits
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=24
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=25
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=17
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 18:18
                                                               ; ASSERT zero 20:27

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=17
  [-<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>]
>>
                                                               ; ASSERT ptr=19

; ============================================================ ; and the carry out of that ripples up through the rest

[                                                              ; ____ byte 2 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=28
  [-]+
<<<<<<<<<<<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=2
  +
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<]                                                          ; continued
>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=30
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >]                                                           ; continued
<
                                                               ; ASSERT ptr=29
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=19
]
                                                               ; ASSERT ptr=19
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=28
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=19

[                                                              ; ____ byte 3 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=28
  [-]+
<<<<<<<<<<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=3
  +
  [->>>>>>>>>>>>>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]                                                            ; continued
>>>>>>>>>>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=30
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=29
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=19
]
                                                               ; ASSERT ptr=19
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=28
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=19

[                                                              ; ____ byte 4 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=28
  [-]+
<<<<<<<<<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=4
  +
  [->>>>>>>>>>>>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=30
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=29
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=19
]
                                                               ; ASSERT ptr=19
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=28
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=19

[                                                              ; ____ byte 5 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=28
  [-]+
<<<<<<<<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=5
  +
  [->>>>>>>>>>>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=30
  [-<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=29
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=19
]
                                                               ; ASSERT ptr=19
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=28
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=19

[                                                              ; ____ byte 6 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=28
  [-]+
<<<<<<<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=6
  +
  [->>>>>>>>>>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=30
  [-<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=29
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=19
]
                                                               ; ASSERT ptr=19
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=28
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=19

[                                                              ; ____ byte 7 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=28
  [-]+
<<<<<<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=7
  +
  [->>>>>>>>>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=30
  [-<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=29
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=19
]
                                                               ; ASSERT ptr=19
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=28
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=19

[                                                              ; ____ byte 8 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=28
  [-]+
<<<<<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=8
  +
  [->>>>>>>>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=30
  [-<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=29
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=19
]
                                                               ; ASSERT ptr=19
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=28
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=19

[                                                              ; ____ byte 9 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=28
  [-]+
<<<<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=9
  +
  [->>>>>>>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=30
  [-<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=29
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=19
]
                                                               ; ASSERT ptr=19
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=28
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=19

[                                                              ; ____ byte 10 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=28
  [-]+
<<<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=10
  +
  [->>>>>>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=30
  [-<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=29
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=19
]
                                                               ; ASSERT ptr=19
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=28
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=19

[                                                              ; ____ byte 11 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=28
  [-]+
<<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=11
  +
  [->>>>>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=30
  [-<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=29
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=19
]
                                                               ; ASSERT ptr=19
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=28
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=19

[                                                              ; ____ byte 12 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=28
  [-]+
<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=12
  +
  [->>>>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=30
  [-<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=29
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=19
]
                                                               ; ASSERT ptr=19
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=28
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=19

[                                                              ; ____ byte 13 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=28
  [-]+
<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=13
  +
  [->>>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=30
  [-<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=29
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=19
]
                                                               ; ASSERT ptr=19
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=28
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=19

[                                                              ; ____ byte 14 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=28
  [-]+
<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=14
  +
  [->>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=30
  [-<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=29
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=19
]
                                                               ; ASSERT ptr=19
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=28
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=19

[                                                              ; ____ byte 15 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=28
  [-]+
<<<<<<<<<<<<<
                                                               ; ASSERT ptr=15
  +
  [->>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=30
  [-<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=29
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=19
]
                                                               ; ASSERT ptr=19
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=28
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=19

[                                                              ; ____ byte 16  which does not look  because its carry
                                                               ; cannot happen ____
  [-]
<<<
                                                               ; ASSERT ptr=16
  +
>>>
                                                               ; ASSERT ptr=19
]
                                                               ; ASSERT ptr=19

; ============================================================ ; the value is folded
<<<<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=0
                                                               ; ASSERT zero 17:34
; emit the folded value little endian
  .>.>.>.>.>.>.>.>.>.>.>.>.>.>.>.>.
