; bfsodium ADD136 : 17 byte little endian addition
;
; HAND WRITTEN; the same shape as chacha20/add32  seventeen bytes wide instead
; of four  and using the same two adders for the same two reasons;
;
; INTERFACE entry=34 exit=34 footprint=0:45
; IO  in:  a{17} LE  followed by  b{17} LE     (34 bytes)
;     out: (a plus b mod 2^136){17} LE         (17 bytes)
;
; TAPE MAP  (home @0)
;   @0x00:0x10  a{17}  u8   the accumulator  and the result  LSB at @0x00
;   @0x11:0x21  b{17}  u8   the addend  consumed to nought
;   @0x22       cin    u8   carry into the current byte
;   @0x23:0x2d  idiom/add8's frame  pasted at @0x23; its footprint is 0:10 and
;               that is what sets the size of this one; x is at @0x23  y at
;               @0x24 and the carry out at @0x25
;
; TWO adders  on purpose; idiom/add8 computes the carry from bit 7 rather than
; watching for it  so it costs about twenty thousand instructions whatever it
; is given; the old kernel's cost is the PRODUCT of its operands  which is
; ruinous for a byte of the addend and nearly free for a carry in of nought or
; one; So the byte takes the new adder and the carry in keeps the old one; The
; old kernel borrows @0x26 and @0x27  which are add8's halving frame  and
; leaves them at nought;
;
; A byte sum is at most 511  so the accumulator wraps at most once  and the two
; additions per byte can never both carry;
;
; The carry out of the top byte is dropped  the sum being modulo two to the
; hundred and thirty sixth; It is CLEARED rather than left lying  and the frame
; is asserted clear on entry as well  so this routine may be pasted inside a
; loop and entered again and again; fold136 does exactly that  five times over;

,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>   ; read a{0:16} then b{0:16}
  ,>,>,>,>                                                     ; continued
; ASSERT ptr=34
; ASSERT zero 34:45

; ==== byte 0 ====
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<                             ; the accumulator byte steps into the adder
; ASSERT ptr=0
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<]                                             ; continued
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>                                             ; to the kernel's base  which is where a paste site
                                                               ; always stands
; ASSERT ptr=35
  >                                                            ; walk in to this routine entry offset
; the carry cell is NOT required to be clear: this routine ADDS into it  and a
; wide adder may have put something there; only the scratch must be clean;
; ASSERT ptr=36
; ASSERT zero 38:45
<                                                              ; to the accumulator
; ASSERT ptr=35
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
; ASSERT ptr=36
  [->>+<<]
>>
; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
; ASSERT ptr=42
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
; ASSERT ptr=45
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
; ASSERT ptr=43
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
; both low bits set is a carry into the halves; that is the AND  and it is what
; the copy is spent on: two means both  one or nought means not both
<<<<<
; ASSERT ptr=40
  [-[[-]>>>>+<<<<]]
; ==== the carry out is bit 7 of that  and nothing else ====
>>>>
; ASSERT ptr=44
  [-<<<<<<+>>>>>>]
<<<<<<
; ASSERT ptr=38
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
; ASSERT ptr=38
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ==== the sum is twice the halves plus the two low bits ====
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
; ASSERT ptr=42
  [-<<<<<<<++>>>>>>>]
>
; ASSERT ptr=43
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
; ASSERT ptr=35
; the addend is spent and every scratch cell is back at nought; @0x00 holds the
; sum and @0x02 the carry  so neither is claimed to be clear;
; ASSERT zero 36:36
; ASSERT zero 38:45

; walk back out to the routine base

; ASSERT ptr=35
<                                                              ; the carry in is nought or one  so it takes the old
                                                               ; kernel
  [->>+<<]
>>
; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>]                                             ; continued
>>                                                             ; and the carry out becomes the carry in for the next
                                                               ; byte
  [-<<<+>>>]
<<<
; ASSERT ptr=34
; ASSERT zero 35:45

; ==== byte 1 ====
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<                              ; the accumulator byte steps into the adder
; ASSERT ptr=1
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<]                                               ; continued
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>                                              ; to the kernel's base  which is where a paste site
                                                               ; always stands
; ASSERT ptr=35
  >                                                            ; walk in to this routine entry offset
; the carry cell is NOT required to be clear: this routine ADDS into it  and a
; wide adder may have put something there; only the scratch must be clean;
; ASSERT ptr=36
; ASSERT zero 38:45
<                                                              ; to the accumulator
; ASSERT ptr=35
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
; ASSERT ptr=36
  [->>+<<]
>>
; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
; ASSERT ptr=42
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
; ASSERT ptr=45
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
; ASSERT ptr=43
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
; both low bits set is a carry into the halves; that is the AND  and it is what
; the copy is spent on: two means both  one or nought means not both
<<<<<
; ASSERT ptr=40
  [-[[-]>>>>+<<<<]]
; ==== the carry out is bit 7 of that  and nothing else ====
>>>>
; ASSERT ptr=44
  [-<<<<<<+>>>>>>]
<<<<<<
; ASSERT ptr=38
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
; ASSERT ptr=38
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ==== the sum is twice the halves plus the two low bits ====
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
; ASSERT ptr=42
  [-<<<<<<<++>>>>>>>]
>
; ASSERT ptr=43
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
; ASSERT ptr=35
; the addend is spent and every scratch cell is back at nought; @0x00 holds the
; sum and @0x02 the carry  so neither is claimed to be clear;
; ASSERT zero 36:36
; ASSERT zero 38:45

; walk back out to the routine base

; ASSERT ptr=35
<                                                              ; the carry in is nought or one  so it takes the old
                                                               ; kernel
  [->>+<<]
>>
; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>]                                               ; continued
>>                                                             ; and the carry out becomes the carry in for the next
                                                               ; byte
  [-<<<+>>>]
<<<
; ASSERT ptr=34
; ASSERT zero 35:45

; ==== byte 2 ====
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<                               ; the accumulator byte steps into the adder
; ASSERT ptr=2
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<]                                                 ; continued
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>                                               ; to the kernel's base  which is where a paste site
                                                               ; always stands
; ASSERT ptr=35
  >                                                            ; walk in to this routine entry offset
; the carry cell is NOT required to be clear: this routine ADDS into it  and a
; wide adder may have put something there; only the scratch must be clean;
; ASSERT ptr=36
; ASSERT zero 38:45
<                                                              ; to the accumulator
; ASSERT ptr=35
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
; ASSERT ptr=36
  [->>+<<]
>>
; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
; ASSERT ptr=42
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
; ASSERT ptr=45
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
; ASSERT ptr=43
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
; both low bits set is a carry into the halves; that is the AND  and it is what
; the copy is spent on: two means both  one or nought means not both
<<<<<
; ASSERT ptr=40
  [-[[-]>>>>+<<<<]]
; ==== the carry out is bit 7 of that  and nothing else ====
>>>>
; ASSERT ptr=44
  [-<<<<<<+>>>>>>]
<<<<<<
; ASSERT ptr=38
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
; ASSERT ptr=38
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ==== the sum is twice the halves plus the two low bits ====
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
; ASSERT ptr=42
  [-<<<<<<<++>>>>>>>]
>
; ASSERT ptr=43
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
; ASSERT ptr=35
; the addend is spent and every scratch cell is back at nought; @0x00 holds the
; sum and @0x02 the carry  so neither is claimed to be clear;
; ASSERT zero 36:36
; ASSERT zero 38:45

; walk back out to the routine base

; ASSERT ptr=35
<                                                              ; the carry in is nought or one  so it takes the old
                                                               ; kernel
  [->>+<<]
>>
; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>]                                                 ; continued
>>                                                             ; and the carry out becomes the carry in for the next
                                                               ; byte
  [-<<<+>>>]
<<<
; ASSERT ptr=34
; ASSERT zero 35:45

; ==== byte 3 ====
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<                                ; the accumulator byte steps into the adder
; ASSERT ptr=3
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<]                                                   ; continued
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>                                                ; to the kernel's base  which is where a paste site
                                                               ; always stands
; ASSERT ptr=35
  >                                                            ; walk in to this routine entry offset
; the carry cell is NOT required to be clear: this routine ADDS into it  and a
; wide adder may have put something there; only the scratch must be clean;
; ASSERT ptr=36
; ASSERT zero 38:45
<                                                              ; to the accumulator
; ASSERT ptr=35
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
; ASSERT ptr=36
  [->>+<<]
>>
; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
; ASSERT ptr=42
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
; ASSERT ptr=45
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
; ASSERT ptr=43
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
; both low bits set is a carry into the halves; that is the AND  and it is what
; the copy is spent on: two means both  one or nought means not both
<<<<<
; ASSERT ptr=40
  [-[[-]>>>>+<<<<]]
; ==== the carry out is bit 7 of that  and nothing else ====
>>>>
; ASSERT ptr=44
  [-<<<<<<+>>>>>>]
<<<<<<
; ASSERT ptr=38
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
; ASSERT ptr=38
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ==== the sum is twice the halves plus the two low bits ====
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
; ASSERT ptr=42
  [-<<<<<<<++>>>>>>>]
>
; ASSERT ptr=43
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
; ASSERT ptr=35
; the addend is spent and every scratch cell is back at nought; @0x00 holds the
; sum and @0x02 the carry  so neither is claimed to be clear;
; ASSERT zero 36:36
; ASSERT zero 38:45

; walk back out to the routine base

; ASSERT ptr=35
<                                                              ; the carry in is nought or one  so it takes the old
                                                               ; kernel
  [->>+<<]
>>
; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>]                                                   ; continued
>>                                                             ; and the carry out becomes the carry in for the next
                                                               ; byte
  [-<<<+>>>]
<<<
; ASSERT ptr=34
; ASSERT zero 35:45

; ==== byte 4 ====
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<                                 ; the accumulator byte steps into the adder
; ASSERT ptr=4
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<]                                                     ; continued
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>                                                 ; to the kernel's base  which is where a paste site
                                                               ; always stands
; ASSERT ptr=35
  >                                                            ; walk in to this routine entry offset
; the carry cell is NOT required to be clear: this routine ADDS into it  and a
; wide adder may have put something there; only the scratch must be clean;
; ASSERT ptr=36
; ASSERT zero 38:45
<                                                              ; to the accumulator
; ASSERT ptr=35
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
; ASSERT ptr=36
  [->>+<<]
>>
; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
; ASSERT ptr=42
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
; ASSERT ptr=45
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
; ASSERT ptr=43
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
; both low bits set is a carry into the halves; that is the AND  and it is what
; the copy is spent on: two means both  one or nought means not both
<<<<<
; ASSERT ptr=40
  [-[[-]>>>>+<<<<]]
; ==== the carry out is bit 7 of that  and nothing else ====
>>>>
; ASSERT ptr=44
  [-<<<<<<+>>>>>>]
<<<<<<
; ASSERT ptr=38
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
; ASSERT ptr=38
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ==== the sum is twice the halves plus the two low bits ====
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
; ASSERT ptr=42
  [-<<<<<<<++>>>>>>>]
>
; ASSERT ptr=43
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
; ASSERT ptr=35
; the addend is spent and every scratch cell is back at nought; @0x00 holds the
; sum and @0x02 the carry  so neither is claimed to be clear;
; ASSERT zero 36:36
; ASSERT zero 38:45

; walk back out to the routine base

; ASSERT ptr=35
<                                                              ; the carry in is nought or one  so it takes the old
                                                               ; kernel
  [->>+<<]
>>
; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>]                                                     ; continued
>>                                                             ; and the carry out becomes the carry in for the next
                                                               ; byte
  [-<<<+>>>]
<<<
; ASSERT ptr=34
; ASSERT zero 35:45

; ==== byte 5 ====
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<                                  ; the accumulator byte steps into the adder
; ASSERT ptr=5
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<]                                                       ; continued
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>>>>>>>>>>>>+<<<<<<<<<<<<<<]
>>>>>>>>>>>>>                                                  ; to the kernel's base  which is where a paste site
                                                               ; always stands
; ASSERT ptr=35
  >                                                            ; walk in to this routine entry offset
; the carry cell is NOT required to be clear: this routine ADDS into it  and a
; wide adder may have put something there; only the scratch must be clean;
; ASSERT ptr=36
; ASSERT zero 38:45
<                                                              ; to the accumulator
; ASSERT ptr=35
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
; ASSERT ptr=36
  [->>+<<]
>>
; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
; ASSERT ptr=42
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
; ASSERT ptr=45
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
; ASSERT ptr=43
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
; both low bits set is a carry into the halves; that is the AND  and it is what
; the copy is spent on: two means both  one or nought means not both
<<<<<
; ASSERT ptr=40
  [-[[-]>>>>+<<<<]]
; ==== the carry out is bit 7 of that  and nothing else ====
>>>>
; ASSERT ptr=44
  [-<<<<<<+>>>>>>]
<<<<<<
; ASSERT ptr=38
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
; ASSERT ptr=38
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ==== the sum is twice the halves plus the two low bits ====
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
; ASSERT ptr=42
  [-<<<<<<<++>>>>>>>]
>
; ASSERT ptr=43
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
; ASSERT ptr=35
; the addend is spent and every scratch cell is back at nought; @0x00 holds the
; sum and @0x02 the carry  so neither is claimed to be clear;
; ASSERT zero 36:36
; ASSERT zero 38:45

; walk back out to the routine base

; ASSERT ptr=35
<                                                              ; the carry in is nought or one  so it takes the old
                                                               ; kernel
  [->>+<<]
>>
; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>]                                                       ; continued
>>                                                             ; and the carry out becomes the carry in for the next
                                                               ; byte
  [-<<<+>>>]
<<<
; ASSERT ptr=34
; ASSERT zero 35:45

; ==== byte 6 ====
<<<<<<<<<<<<<<<<<<<<<<<<<<<<                                   ; the accumulator byte steps into the adder
; ASSERT ptr=6
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<]                                                         ; continued
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>>>>>>>>>>>+<<<<<<<<<<<<<]
>>>>>>>>>>>>                                                   ; to the kernel's base  which is where a paste site
                                                               ; always stands
; ASSERT ptr=35
  >                                                            ; walk in to this routine entry offset
; the carry cell is NOT required to be clear: this routine ADDS into it  and a
; wide adder may have put something there; only the scratch must be clean;
; ASSERT ptr=36
; ASSERT zero 38:45
<                                                              ; to the accumulator
; ASSERT ptr=35
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
; ASSERT ptr=36
  [->>+<<]
>>
; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
; ASSERT ptr=42
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
; ASSERT ptr=45
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
; ASSERT ptr=43
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
; both low bits set is a carry into the halves; that is the AND  and it is what
; the copy is spent on: two means both  one or nought means not both
<<<<<
; ASSERT ptr=40
  [-[[-]>>>>+<<<<]]
; ==== the carry out is bit 7 of that  and nothing else ====
>>>>
; ASSERT ptr=44
  [-<<<<<<+>>>>>>]
<<<<<<
; ASSERT ptr=38
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
; ASSERT ptr=38
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ==== the sum is twice the halves plus the two low bits ====
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
; ASSERT ptr=42
  [-<<<<<<<++>>>>>>>]
>
; ASSERT ptr=43
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
; ASSERT ptr=35
; the addend is spent and every scratch cell is back at nought; @0x00 holds the
; sum and @0x02 the carry  so neither is claimed to be clear;
; ASSERT zero 36:36
; ASSERT zero 38:45

; walk back out to the routine base

; ASSERT ptr=35
<                                                              ; the carry in is nought or one  so it takes the old
                                                               ; kernel
  [->>+<<]
>>
; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>]                                                         ; continued
>>                                                             ; and the carry out becomes the carry in for the next
                                                               ; byte
  [-<<<+>>>]
<<<
; ASSERT ptr=34
; ASSERT zero 35:45

; ==== byte 7 ====
<<<<<<<<<<<<<<<<<<<<<<<<<<<                                    ; the accumulator byte steps into the adder
; ASSERT ptr=7
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <]                                                           ; continued
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>>>>>>>>>>+<<<<<<<<<<<<]
>>>>>>>>>>>                                                    ; to the kernel's base  which is where a paste site
                                                               ; always stands
; ASSERT ptr=35
  >                                                            ; walk in to this routine entry offset
; the carry cell is NOT required to be clear: this routine ADDS into it  and a
; wide adder may have put something there; only the scratch must be clean;
; ASSERT ptr=36
; ASSERT zero 38:45
<                                                              ; to the accumulator
; ASSERT ptr=35
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
; ASSERT ptr=36
  [->>+<<]
>>
; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
; ASSERT ptr=42
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
; ASSERT ptr=45
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
; ASSERT ptr=43
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
; both low bits set is a carry into the halves; that is the AND  and it is what
; the copy is spent on: two means both  one or nought means not both
<<<<<
; ASSERT ptr=40
  [-[[-]>>>>+<<<<]]
; ==== the carry out is bit 7 of that  and nothing else ====
>>>>
; ASSERT ptr=44
  [-<<<<<<+>>>>>>]
<<<<<<
; ASSERT ptr=38
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
; ASSERT ptr=38
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ==== the sum is twice the halves plus the two low bits ====
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
; ASSERT ptr=42
  [-<<<<<<<++>>>>>>>]
>
; ASSERT ptr=43
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
; ASSERT ptr=35
; the addend is spent and every scratch cell is back at nought; @0x00 holds the
; sum and @0x02 the carry  so neither is claimed to be clear;
; ASSERT zero 36:36
; ASSERT zero 38:45

; walk back out to the routine base

; ASSERT ptr=35
<                                                              ; the carry in is nought or one  so it takes the old
                                                               ; kernel
  [->>+<<]
>>
; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >]                                                           ; continued
>>                                                             ; and the carry out becomes the carry in for the next
                                                               ; byte
  [-<<<+>>>]
<<<
; ASSERT ptr=34
; ASSERT zero 35:45

; ==== byte 8 ====
<<<<<<<<<<<<<<<<<<<<<<<<<<                                     ; the accumulator byte steps into the adder
; ASSERT ptr=8
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>>>>>>>>>+<<<<<<<<<<<]
>>>>>>>>>>                                                     ; to the kernel's base  which is where a paste site
                                                               ; always stands
; ASSERT ptr=35
  >                                                            ; walk in to this routine entry offset
; the carry cell is NOT required to be clear: this routine ADDS into it  and a
; wide adder may have put something there; only the scratch must be clean;
; ASSERT ptr=36
; ASSERT zero 38:45
<                                                              ; to the accumulator
; ASSERT ptr=35
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
; ASSERT ptr=36
  [->>+<<]
>>
; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
; ASSERT ptr=42
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
; ASSERT ptr=45
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
; ASSERT ptr=43
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
; both low bits set is a carry into the halves; that is the AND  and it is what
; the copy is spent on: two means both  one or nought means not both
<<<<<
; ASSERT ptr=40
  [-[[-]>>>>+<<<<]]
; ==== the carry out is bit 7 of that  and nothing else ====
>>>>
; ASSERT ptr=44
  [-<<<<<<+>>>>>>]
<<<<<<
; ASSERT ptr=38
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
; ASSERT ptr=38
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ==== the sum is twice the halves plus the two low bits ====
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
; ASSERT ptr=42
  [-<<<<<<<++>>>>>>>]
>
; ASSERT ptr=43
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
; ASSERT ptr=35
; the addend is spent and every scratch cell is back at nought; @0x00 holds the
; sum and @0x02 the carry  so neither is claimed to be clear;
; ASSERT zero 36:36
; ASSERT zero 38:45

; walk back out to the routine base

; ASSERT ptr=35
<                                                              ; the carry in is nought or one  so it takes the old
                                                               ; kernel
  [->>+<<]
>>
; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>>]
>>                                                             ; and the carry out becomes the carry in for the next
                                                               ; byte
  [-<<<+>>>]
<<<
; ASSERT ptr=34
; ASSERT zero 35:45

; ==== byte 9 ====
<<<<<<<<<<<<<<<<<<<<<<<<<                                      ; the accumulator byte steps into the adder
; ASSERT ptr=9
  [->>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>>>>>>>>+<<<<<<<<<<]
>>>>>>>>>                                                      ; to the kernel's base  which is where a paste site
                                                               ; always stands
; ASSERT ptr=35
  >                                                            ; walk in to this routine entry offset
; the carry cell is NOT required to be clear: this routine ADDS into it  and a
; wide adder may have put something there; only the scratch must be clean;
; ASSERT ptr=36
; ASSERT zero 38:45
<                                                              ; to the accumulator
; ASSERT ptr=35
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
; ASSERT ptr=36
  [->>+<<]
>>
; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
; ASSERT ptr=42
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
; ASSERT ptr=45
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
; ASSERT ptr=43
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
; both low bits set is a carry into the halves; that is the AND  and it is what
; the copy is spent on: two means both  one or nought means not both
<<<<<
; ASSERT ptr=40
  [-[[-]>>>>+<<<<]]
; ==== the carry out is bit 7 of that  and nothing else ====
>>>>
; ASSERT ptr=44
  [-<<<<<<+>>>>>>]
<<<<<<
; ASSERT ptr=38
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
; ASSERT ptr=38
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ==== the sum is twice the halves plus the two low bits ====
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
; ASSERT ptr=42
  [-<<<<<<<++>>>>>>>]
>
; ASSERT ptr=43
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
; ASSERT ptr=35
; the addend is spent and every scratch cell is back at nought; @0x00 holds the
; sum and @0x02 the carry  so neither is claimed to be clear;
; ASSERT zero 36:36
; ASSERT zero 38:45

; walk back out to the routine base

; ASSERT ptr=35
<                                                              ; the carry in is nought or one  so it takes the old
                                                               ; kernel
  [->>+<<]
>>
; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>]
>>                                                             ; and the carry out becomes the carry in for the next
                                                               ; byte
  [-<<<+>>>]
<<<
; ASSERT ptr=34
; ASSERT zero 35:45

; ==== byte 10 ====
<<<<<<<<<<<<<<<<<<<<<<<<                                       ; the accumulator byte steps into the adder
; ASSERT ptr=10
  [->>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>>>>>>>+<<<<<<<<<]
>>>>>>>>                                                       ; to the kernel's base  which is where a paste site
                                                               ; always stands
; ASSERT ptr=35
  >                                                            ; walk in to this routine entry offset
; the carry cell is NOT required to be clear: this routine ADDS into it  and a
; wide adder may have put something there; only the scratch must be clean;
; ASSERT ptr=36
; ASSERT zero 38:45
<                                                              ; to the accumulator
; ASSERT ptr=35
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
; ASSERT ptr=36
  [->>+<<]
>>
; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
; ASSERT ptr=42
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
; ASSERT ptr=45
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
; ASSERT ptr=43
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
; both low bits set is a carry into the halves; that is the AND  and it is what
; the copy is spent on: two means both  one or nought means not both
<<<<<
; ASSERT ptr=40
  [-[[-]>>>>+<<<<]]
; ==== the carry out is bit 7 of that  and nothing else ====
>>>>
; ASSERT ptr=44
  [-<<<<<<+>>>>>>]
<<<<<<
; ASSERT ptr=38
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
; ASSERT ptr=38
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ==== the sum is twice the halves plus the two low bits ====
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
; ASSERT ptr=42
  [-<<<<<<<++>>>>>>>]
>
; ASSERT ptr=43
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
; ASSERT ptr=35
; the addend is spent and every scratch cell is back at nought; @0x00 holds the
; sum and @0x02 the carry  so neither is claimed to be clear;
; ASSERT zero 36:36
; ASSERT zero 38:45

; walk back out to the routine base

; ASSERT ptr=35
<                                                              ; the carry in is nought or one  so it takes the old
                                                               ; kernel
  [->>+<<]
>>
; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>]
>>                                                             ; and the carry out becomes the carry in for the next
                                                               ; byte
  [-<<<+>>>]
<<<
; ASSERT ptr=34
; ASSERT zero 35:45

; ==== byte 11 ====
<<<<<<<<<<<<<<<<<<<<<<<                                        ; the accumulator byte steps into the adder
; ASSERT ptr=11
  [->>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>>>>>>+<<<<<<<<]
>>>>>>>                                                        ; to the kernel's base  which is where a paste site
                                                               ; always stands
; ASSERT ptr=35
  >                                                            ; walk in to this routine entry offset
; the carry cell is NOT required to be clear: this routine ADDS into it  and a
; wide adder may have put something there; only the scratch must be clean;
; ASSERT ptr=36
; ASSERT zero 38:45
<                                                              ; to the accumulator
; ASSERT ptr=35
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
; ASSERT ptr=36
  [->>+<<]
>>
; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
; ASSERT ptr=42
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
; ASSERT ptr=45
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
; ASSERT ptr=43
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
; both low bits set is a carry into the halves; that is the AND  and it is what
; the copy is spent on: two means both  one or nought means not both
<<<<<
; ASSERT ptr=40
  [-[[-]>>>>+<<<<]]
; ==== the carry out is bit 7 of that  and nothing else ====
>>>>
; ASSERT ptr=44
  [-<<<<<<+>>>>>>]
<<<<<<
; ASSERT ptr=38
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
; ASSERT ptr=38
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ==== the sum is twice the halves plus the two low bits ====
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
; ASSERT ptr=42
  [-<<<<<<<++>>>>>>>]
>
; ASSERT ptr=43
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
; ASSERT ptr=35
; the addend is spent and every scratch cell is back at nought; @0x00 holds the
; sum and @0x02 the carry  so neither is claimed to be clear;
; ASSERT zero 36:36
; ASSERT zero 38:45

; walk back out to the routine base

; ASSERT ptr=35
<                                                              ; the carry in is nought or one  so it takes the old
                                                               ; kernel
  [->>+<<]
>>
; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>]
>>                                                             ; and the carry out becomes the carry in for the next
                                                               ; byte
  [-<<<+>>>]
<<<
; ASSERT ptr=34
; ASSERT zero 35:45

; ==== byte 12 ====
<<<<<<<<<<<<<<<<<<<<<<                                         ; the accumulator byte steps into the adder
; ASSERT ptr=12
  [->>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>>>>>+<<<<<<<]
>>>>>>                                                         ; to the kernel's base  which is where a paste site
                                                               ; always stands
; ASSERT ptr=35
  >                                                            ; walk in to this routine entry offset
; the carry cell is NOT required to be clear: this routine ADDS into it  and a
; wide adder may have put something there; only the scratch must be clean;
; ASSERT ptr=36
; ASSERT zero 38:45
<                                                              ; to the accumulator
; ASSERT ptr=35
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
; ASSERT ptr=36
  [->>+<<]
>>
; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
; ASSERT ptr=42
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
; ASSERT ptr=45
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
; ASSERT ptr=43
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
; both low bits set is a carry into the halves; that is the AND  and it is what
; the copy is spent on: two means both  one or nought means not both
<<<<<
; ASSERT ptr=40
  [-[[-]>>>>+<<<<]]
; ==== the carry out is bit 7 of that  and nothing else ====
>>>>
; ASSERT ptr=44
  [-<<<<<<+>>>>>>]
<<<<<<
; ASSERT ptr=38
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
; ASSERT ptr=38
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ==== the sum is twice the halves plus the two low bits ====
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
; ASSERT ptr=42
  [-<<<<<<<++>>>>>>>]
>
; ASSERT ptr=43
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
; ASSERT ptr=35
; the addend is spent and every scratch cell is back at nought; @0x00 holds the
; sum and @0x02 the carry  so neither is claimed to be clear;
; ASSERT zero 36:36
; ASSERT zero 38:45

; walk back out to the routine base

; ASSERT ptr=35
<                                                              ; the carry in is nought or one  so it takes the old
                                                               ; kernel
  [->>+<<]
>>
; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>]
>>                                                             ; and the carry out becomes the carry in for the next
                                                               ; byte
  [-<<<+>>>]
<<<
; ASSERT ptr=34
; ASSERT zero 35:45

; ==== byte 13 ====
<<<<<<<<<<<<<<<<<<<<<                                          ; the accumulator byte steps into the adder
; ASSERT ptr=13
  [->>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>>>>+<<<<<<]
>>>>>                                                          ; to the kernel's base  which is where a paste site
                                                               ; always stands
; ASSERT ptr=35
  >                                                            ; walk in to this routine entry offset
; the carry cell is NOT required to be clear: this routine ADDS into it  and a
; wide adder may have put something there; only the scratch must be clean;
; ASSERT ptr=36
; ASSERT zero 38:45
<                                                              ; to the accumulator
; ASSERT ptr=35
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
; ASSERT ptr=36
  [->>+<<]
>>
; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
; ASSERT ptr=42
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
; ASSERT ptr=45
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
; ASSERT ptr=43
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
; both low bits set is a carry into the halves; that is the AND  and it is what
; the copy is spent on: two means both  one or nought means not both
<<<<<
; ASSERT ptr=40
  [-[[-]>>>>+<<<<]]
; ==== the carry out is bit 7 of that  and nothing else ====
>>>>
; ASSERT ptr=44
  [-<<<<<<+>>>>>>]
<<<<<<
; ASSERT ptr=38
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
; ASSERT ptr=38
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ==== the sum is twice the halves plus the two low bits ====
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
; ASSERT ptr=42
  [-<<<<<<<++>>>>>>>]
>
; ASSERT ptr=43
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
; ASSERT ptr=35
; the addend is spent and every scratch cell is back at nought; @0x00 holds the
; sum and @0x02 the carry  so neither is claimed to be clear;
; ASSERT zero 36:36
; ASSERT zero 38:45

; walk back out to the routine base

; ASSERT ptr=35
<                                                              ; the carry in is nought or one  so it takes the old
                                                               ; kernel
  [->>+<<]
>>
; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>]
>>                                                             ; and the carry out becomes the carry in for the next
                                                               ; byte
  [-<<<+>>>]
<<<
; ASSERT ptr=34
; ASSERT zero 35:45

; ==== byte 14 ====
<<<<<<<<<<<<<<<<<<<<                                           ; the accumulator byte steps into the adder
; ASSERT ptr=14
  [->>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>>>+<<<<<]
>>>>                                                           ; to the kernel's base  which is where a paste site
                                                               ; always stands
; ASSERT ptr=35
  >                                                            ; walk in to this routine entry offset
; the carry cell is NOT required to be clear: this routine ADDS into it  and a
; wide adder may have put something there; only the scratch must be clean;
; ASSERT ptr=36
; ASSERT zero 38:45
<                                                              ; to the accumulator
; ASSERT ptr=35
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
; ASSERT ptr=36
  [->>+<<]
>>
; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
; ASSERT ptr=42
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
; ASSERT ptr=45
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
; ASSERT ptr=43
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
; both low bits set is a carry into the halves; that is the AND  and it is what
; the copy is spent on: two means both  one or nought means not both
<<<<<
; ASSERT ptr=40
  [-[[-]>>>>+<<<<]]
; ==== the carry out is bit 7 of that  and nothing else ====
>>>>
; ASSERT ptr=44
  [-<<<<<<+>>>>>>]
<<<<<<
; ASSERT ptr=38
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
; ASSERT ptr=38
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ==== the sum is twice the halves plus the two low bits ====
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
; ASSERT ptr=42
  [-<<<<<<<++>>>>>>>]
>
; ASSERT ptr=43
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
; ASSERT ptr=35
; the addend is spent and every scratch cell is back at nought; @0x00 holds the
; sum and @0x02 the carry  so neither is claimed to be clear;
; ASSERT zero 36:36
; ASSERT zero 38:45

; walk back out to the routine base

; ASSERT ptr=35
<                                                              ; the carry in is nought or one  so it takes the old
                                                               ; kernel
  [->>+<<]
>>
; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>]
>>                                                             ; and the carry out becomes the carry in for the next
                                                               ; byte
  [-<<<+>>>]
<<<
; ASSERT ptr=34
; ASSERT zero 35:45

; ==== byte 15 ====
<<<<<<<<<<<<<<<<<<<                                            ; the accumulator byte steps into the adder
; ASSERT ptr=15
  [->>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>>+<<<<]
>>>                                                            ; to the kernel's base  which is where a paste site
                                                               ; always stands
; ASSERT ptr=35
  >                                                            ; walk in to this routine entry offset
; the carry cell is NOT required to be clear: this routine ADDS into it  and a
; wide adder may have put something there; only the scratch must be clean;
; ASSERT ptr=36
; ASSERT zero 38:45
<                                                              ; to the accumulator
; ASSERT ptr=35
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
; ASSERT ptr=36
  [->>+<<]
>>
; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
; ASSERT ptr=42
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
; ASSERT ptr=45
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
; ASSERT ptr=43
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
; both low bits set is a carry into the halves; that is the AND  and it is what
; the copy is spent on: two means both  one or nought means not both
<<<<<
; ASSERT ptr=40
  [-[[-]>>>>+<<<<]]
; ==== the carry out is bit 7 of that  and nothing else ====
>>>>
; ASSERT ptr=44
  [-<<<<<<+>>>>>>]
<<<<<<
; ASSERT ptr=38
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
; ASSERT ptr=38
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ==== the sum is twice the halves plus the two low bits ====
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
; ASSERT ptr=42
  [-<<<<<<<++>>>>>>>]
>
; ASSERT ptr=43
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
; ASSERT ptr=35
; the addend is spent and every scratch cell is back at nought; @0x00 holds the
; sum and @0x02 the carry  so neither is claimed to be clear;
; ASSERT zero 36:36
; ASSERT zero 38:45

; walk back out to the routine base

; ASSERT ptr=35
<                                                              ; the carry in is nought or one  so it takes the old
                                                               ; kernel
  [->>+<<]
>>
; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>]
>>                                                             ; and the carry out becomes the carry in for the next
                                                               ; byte
  [-<<<+>>>]
<<<
; ASSERT ptr=34
; ASSERT zero 35:45

; ==== byte 16 ====
<<<<<<<<<<<<<<<<<<                                             ; the accumulator byte steps into the adder
; ASSERT ptr=16
  [->>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>+<<<]
>>                                                             ; to the kernel's base  which is where a paste site
                                                               ; always stands
; ASSERT ptr=35
  >                                                            ; walk in to this routine entry offset
; the carry cell is NOT required to be clear: this routine ADDS into it  and a
; wide adder may have put something there; only the scratch must be clean;
; ASSERT ptr=36
; ASSERT zero 38:45
<                                                              ; to the accumulator
; ASSERT ptr=35
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
; ASSERT ptr=36
  [->>+<<]
>>
; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
; ASSERT ptr=42
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
; ASSERT ptr=45
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
; ASSERT ptr=43
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
; both low bits set is a carry into the halves; that is the AND  and it is what
; the copy is spent on: two means both  one or nought means not both
<<<<<
; ASSERT ptr=40
  [-[[-]>>>>+<<<<]]
; ==== the carry out is bit 7 of that  and nothing else ====
>>>>
; ASSERT ptr=44
  [-<<<<<<+>>>>>>]
<<<<<<
; ASSERT ptr=38
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
; ASSERT ptr=38
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ==== the sum is twice the halves plus the two low bits ====
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
; ASSERT ptr=42
  [-<<<<<<<++>>>>>>>]
>
; ASSERT ptr=43
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
; ASSERT ptr=35
; the addend is spent and every scratch cell is back at nought; @0x00 holds the
; sum and @0x02 the carry  so neither is claimed to be clear;
; ASSERT zero 36:36
; ASSERT zero 38:45

; walk back out to the routine base

; ASSERT ptr=35
<                                                              ; the carry in is nought or one  so it takes the old
                                                               ; kernel
  [->>+<<]
>>
; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>]
>>                                                             ; and the carry out becomes the carry in for the next
                                                               ; byte
  [-<<<+>>>]
<<<
; ASSERT ptr=34
; ASSERT zero 35:45

; the carry out of the top byte is dropped  and cleared so the frame is as
; empty as it was found
; ASSERT ptr=34
  [-]
; ASSERT zero 17:45

; emit
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<                             ; the sum little endian
; ASSERT ptr=0
  .>.>.>.>.>.>.>.>.>.>.>.>.>.>.>.>.
