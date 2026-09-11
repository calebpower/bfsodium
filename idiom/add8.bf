; bfsodium ADD8 : add with carry  in time proportional to the operands
;
; HAND WRITTEN; This is the kernel every wide adder in the library is built
; from  and it was the slowest thing in it; The old one tested whether the
; accumulator had just wrapped ONCE PER UNIT of the addend  and that test cost
; a copy of the accumulator  so the whole kernel cost the PRODUCT of the two
; bytes: about three quarters of a million instructions at 255 plus 255;
;
; INTERFACE entry=1 exit=0 footprint=0:10
; IO  in:  x{1}  y{1}         (2 bytes)
;     out: sum{1}  carry{1}   (2 bytes)
;
; TAPE MAP  (home @0)
;   @0x00  x    u8  the accumulator; becomes the sum
;   @0x01  y    u8  the addend  consumed to nought
;   @0x02  c    u8  the carry out is ADDED into this  never assigned
;   @0x03  v    u8  HALVE frame: the byte being halved
;   @0x04  q    u8  HALVE frame: that byte shifted right one
;   @0x05  t    u8  HALVE frame: that byte low bit
;   @0x06  f    u8  HALVE frame scratch  restored to nought
;   @0x07  hs   u8  the two halves added; at most 254  so it cannot wrap
;   @0x08  bl   u8  the two low bits added; nought one or two
;   @0x09  hc   u8  hs plus the carry the low bits make; bit 7 of it IS the
;                   carry out  which is the whole trick
;   @0x0a  g    u8  hands a value back after it has been copied
;
; The carry is not watched for; it is COMPUTED once  from
;   carry = bit 7 of ( xhalf plus yhalf plus (both low bits set) )
; and the sum comes back from the same two halves as
;   sum = 2 times ( xhalf plus yhalf ) plus xlow plus ylow
; where xhalf is x shifted right one and xlow is its low bit
; so the halving is paid for twice over; Both identities are proved in
; spec/perm_cry over every one of the 65536 pairs  and the routine itself is
; checked against every one of them by tests/run_sh;
;
; The halves cannot overflow: each is at most 127  so their sum is at most 254
; and the cell never wraps  which is what makes bit 7 of it meaningful;
;
; Bit 7 is taken by halving seven times and keeping the quotient; that chain is
; what the kernel costs  about twenty thousand instructions  and it does not
; depend on the addend at all; So this is far faster than the old kernel for
; the operands that actually occur and SLOWER for very small ones; the wide
; adders keep the old kernel for adding a carry in  where the addend is nought
; or one and the old kernel is nearly free;

  ,>,                                                          ; read the accumulator and the addend
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=1
                                                               ; ASSERT zero 3:10
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=0
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=3
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=1
  [->>+<<]
>>
                                                               ; ASSERT ptr=3
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
                                                               ; each is at most 127
  [->>>+<<<]
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=7
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=10
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=8
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=5
  [-[[-]>>>>+<<<<]]
; ==== the carry out is bit 7 of that  and nothing else ====
>>>>
                                                               ; ASSERT ptr=9
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=3
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 1 of seven; the bit that falls off is not
                                                               ; wanted
>>
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 2 of seven; the bit that falls off is not
                                                               ; wanted
>>
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 3 of seven; the bit that falls off is not
                                                               ; wanted
>>
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 4 of seven; the bit that falls off is not
                                                               ; wanted
>>
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 5 of seven; the bit that falls off is not
                                                               ; wanted
>>
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 6 of seven; the bit that falls off is not
                                                               ; wanted
>>
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 7 of seven; the bit that falls off is not
                                                               ; wanted
>>
  [-]
<<
>
  [-<+>]
<
                                                               ; ASSERT ptr=3
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ==== the sum is twice the halves plus the two low bits ====
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=7
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=8
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=0
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 1:1
                                                               ; ASSERT zero 3:10

; emit
  .>>.                                                         ; the sum and then the carry
