; bfsodium ROTL32 : rotate a 32 bit little endian word left by n
;
; INTERFACE entry=4 exit=4 footprint=0:19
; IO  in:  w{4} LE  followed by  n{1}      (5 bytes)
;     out: (w rotated left by n){4} LE     (4 bytes)
;
; TAPE MAP  (home @0)
;   @0x00:0x03  w{4}   u8   the word  LSB at @0x00
;   @0x04       n      u8   remaining rotation steps  the loop counter
;   @0x05:0x08  c{4}   u8   carry out of doubling each byte
;   @0x09:0x13  idiom/add8's frame  pasted at @0x09; its footprint is 0:10 and
;               that is what sets the size of this one; x is at @0x09  y at
;               @0x0a and the carry out at @0x0b
;
; One bit of rotation DOUBLES all four bytes and feeds each carry into the next
; byte cyclically; a doubled byte is even  so adding the neighbour's carry bit
; cannot overflow and no second carry pass is needed;
;
; Doubling is ADD8 of a byte with itself  which is why this file is where the
; adder's cost lands hardest: a rotate by sixteen is sixty four of them; With
; the old kernel  whose cost was the PRODUCT of the operands  a doubling of a
; large byte cost about half a million instructions and this routine was the
; slowest thing in ChaCha20 by an order of magnitude; idiom/add8 computes the
; carry from bit 7 instead  at a cost that does not depend on the operands;

,>,>,>,>,                                                      ; read w{0:3} then n  leaving the pointer on n @0x04
                                                               ; ASSERT ptr=4
                                                               ; ASSERT zero 5:19

; ==== rotate one bit  n times ====
[
  -                                                            ; one step consumed

                                                               ; ____ double byte 0 @0x00  carry into c0 @0x05 ____
                                                               ; move w0 into the accumulator
<<<<
  [->>>>>>>>>+<<<<<<<<<]
>>>>>>>>>                                                      ; to the kernel's base  which is where a paste site
                                                               ; always stands
                                                               ; ASSERT ptr=9
  [->+>>+<<<]                                                  ; the addend is the accumulator itself  copied and
                                                               ; handed straight back
>>>
  [-<<<+>>>]
<<<
                                                               ; ASSERT ptr=9
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=10
                                                               ; ASSERT zero 12:19
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=9
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=12
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=10
  [->>+<<]
>>
                                                               ; ASSERT ptr=12
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=16
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=19
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=17
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=14
  [-[[-]>>>>+<<<<]]
; ==== the carry out is bit 7 of that  and nothing else ====
>>>>
                                                               ; ASSERT ptr=18
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=12
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
                                                               ; ASSERT ptr=12
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ==== the sum is twice the halves plus the two low bits ====
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=16
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=17
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=9
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 10:10
                                                               ; ASSERT zero 12:19

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=9
  [-<<<<<<<<<+>>>>>>>>>]                                       ; store the doubled byte back into w0
>>                                                             ; and its top bit  which fell out  into c0
  [-<<<<<<+>>>>>>]
<<<<<<<                                                        ; back to the step counter
                                                               ; ASSERT ptr=4

                                                               ; ____ double byte 1 @0x01  carry into c1 @0x06 ____
                                                               ; move w1 into the accumulator
<<<
  [->>>>>>>>+<<<<<<<<]
>>>>>>>>                                                       ; to the kernel's base  which is where a paste site
                                                               ; always stands
                                                               ; ASSERT ptr=9
  [->+>>+<<<]                                                  ; the addend is the accumulator itself  copied and
                                                               ; handed straight back
>>>
  [-<<<+>>>]
<<<
                                                               ; ASSERT ptr=9
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=10
                                                               ; ASSERT zero 12:19
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=9
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=12
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=10
  [->>+<<]
>>
                                                               ; ASSERT ptr=12
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=16
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=19
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=17
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=14
  [-[[-]>>>>+<<<<]]
; ==== the carry out is bit 7 of that  and nothing else ====
>>>>
                                                               ; ASSERT ptr=18
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=12
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
                                                               ; ASSERT ptr=12
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ==== the sum is twice the halves plus the two low bits ====
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=16
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=17
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=9
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 10:10
                                                               ; ASSERT zero 12:19

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=9
  [-<<<<<<<<+>>>>>>>>]                                         ; store the doubled byte back into w1
>>                                                             ; and its top bit  which fell out  into c1
  [-<<<<<+>>>>>]
<<<<<<<                                                        ; back to the step counter
                                                               ; ASSERT ptr=4

                                                               ; ____ double byte 2 @0x02  carry into c2 @0x07 ____
                                                               ; move w2 into the accumulator
<<
  [->>>>>>>+<<<<<<<]
>>>>>>>                                                        ; to the kernel's base  which is where a paste site
                                                               ; always stands
                                                               ; ASSERT ptr=9
  [->+>>+<<<]                                                  ; the addend is the accumulator itself  copied and
                                                               ; handed straight back
>>>
  [-<<<+>>>]
<<<
                                                               ; ASSERT ptr=9
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=10
                                                               ; ASSERT zero 12:19
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=9
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=12
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=10
  [->>+<<]
>>
                                                               ; ASSERT ptr=12
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=16
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=19
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=17
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=14
  [-[[-]>>>>+<<<<]]
; ==== the carry out is bit 7 of that  and nothing else ====
>>>>
                                                               ; ASSERT ptr=18
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=12
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
                                                               ; ASSERT ptr=12
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ==== the sum is twice the halves plus the two low bits ====
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=16
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=17
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=9
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 10:10
                                                               ; ASSERT zero 12:19

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=9
  [-<<<<<<<+>>>>>>>]                                           ; store the doubled byte back into w2
>>                                                             ; and its top bit  which fell out  into c2
  [-<<<<+>>>>]
<<<<<<<                                                        ; back to the step counter
                                                               ; ASSERT ptr=4

                                                               ; ____ double byte 3 @0x03  carry into c3 @0x08 ____
                                                               ; move w3 into the accumulator
<
  [->>>>>>+<<<<<<]
>>>>>>                                                         ; to the kernel's base  which is where a paste site
                                                               ; always stands
                                                               ; ASSERT ptr=9
  [->+>>+<<<]                                                  ; the addend is the accumulator itself  copied and
                                                               ; handed straight back
>>>
  [-<<<+>>>]
<<<
                                                               ; ASSERT ptr=9
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=10
                                                               ; ASSERT zero 12:19
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=9
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=12
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=10
  [->>+<<]
>>
                                                               ; ASSERT ptr=12
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=16
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=19
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=17
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=14
  [-[[-]>>>>+<<<<]]
; ==== the carry out is bit 7 of that  and nothing else ====
>>>>
                                                               ; ASSERT ptr=18
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=12
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
                                                               ; ASSERT ptr=12
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ==== the sum is twice the halves plus the two low bits ====
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=16
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=17
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=9
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 10:10
                                                               ; ASSERT zero 12:19

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=9
  [-<<<<<<+>>>>>>]                                             ; store the doubled byte back into w3
>>                                                             ; and its top bit  which fell out  into c3
  [-<<<+>>>]
<<<<<<<                                                        ; back to the step counter
                                                               ; ASSERT ptr=4

                                                               ; ____ feed the carries around the cycle ____ w0 gets
                                                               ; c3
>>>>
  [-<<<<<<<<+>>>>>>>>]
<<<                                                            ; w1 gets c0
  [-<<<<+>>>>]
>                                                              ; w2 gets c1
  [-<<<<+>>>>]
>                                                              ; w3 gets c2
  [-<<<<+>>>>]
<<<                                                            ; back to the step counter
                                                               ; ASSERT ptr=4
                                                               ; ASSERT zero 5:19
]
                                                               ; ASSERT ptr=4

; emit
<<<<                                                           ; the rotated word little endian
  .>.>.>.
