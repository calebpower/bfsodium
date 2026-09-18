; bfsodium ABSORB : one Poly1305 block  acc := (acc plus blk) times r mod p
;
; HAND WRITTEN; This is the step every Poly1305 message block takes and the
; only place the accumulator changes; It was lifted out of poly1305 so the AEAD
; can take the same step without a second copy of it existing;
;
; INTERFACE entry=50 exit=17 footprint=0:141
; IO  in:  r{17} LE  acc{17} LE  blk{17} LE    (51 bytes)
;     out: acc{17} LE                          (17 bytes)
;
; TAPE MAP  (home @0)
;   @0x00:0x10  r{17}    u8  the clamped r; CONSUMED  so a caller with more
;                           than one block to take keeps its own lasting copy
;                           and hands a fresh one in each time
;   @0x11:0x21  acc{17}  u8  the accumulator  in and out
;   @0x22:0x32  blk{17}  u8  this block  with its ONE already appended;
;                           CONSUMED by the addition
;   @0x11:0x8d   the work frame; BOTH pasted routines run at @0x11  add136
;                           reaching 0x11:0x38 and mulmod136 0x11:0x8d  whose
;                           footprint 0:124 is what sets the size of it
;
; The three operands are laid out so that neither pasted routine needs its
; arguments moved to reach it; add136 wants its accumulator and its addend
; adjacent and finds them at acc and blk  and mulmod136 wants the same two
; cells for the accumulator and r; Since add136 consumes its addend  the block
; slot is empty by the time r needs it  so r simply moves in and the whole step
; costs one seventeen byte move of glue rather than four;
;
; r is MOVED rather than copied  because a copy needs a temp and a hand back
; and the caller has to keep a lasting copy either way; the caller is the only
; place that knows how many blocks are still to come;

  ,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>   ; read r  then the accumulator  then the block  each
  ,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,                  ; seventeen bytes little endian
                                                               ; ASSERT ptr=50
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<                              ; to the accumulator  which is where both pasted
                                                               ; routines run from
                                                               ; ASSERT ptr=17
                                                               ; nothing above the two operands has been touched yet
                                                               ; ASSERT zero 51:141
                                                               ; the block is added into the accumulator  modulo two
                                                               ; to the 136 walk in to this routine entry offset
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=51
                                                               ; ASSERT zero 51:62

; ============================================================ ; ; byte 0
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<                             ; the accumulator byte steps into the adder
                                                               ; ASSERT ptr=17
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<]                                             ; continued
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>                                             ; to the kernel's base  which is where a paste site
                                                               ; always stands
                                                               ; ASSERT ptr=52
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=53
                                                               ; ASSERT zero 55:62
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=52
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=55
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=53
  [->>+<<]
>>
                                                               ; ASSERT ptr=55
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=59
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=62
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=60
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=57
  [-[[-]>>>>+<<<<]]
; ============================================================ ; ; ; the carry out is bit 7 of that  and nothing else
>>>>
                                                               ; ASSERT ptr=61
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=55
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
                                                               ; ASSERT ptr=55
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ============================================================ ; ; ; the sum is twice the halves plus the two low bits
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=59
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=60
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=52
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 53:53
                                                               ; ASSERT zero 55:62

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=52
<                                                              ; the carry in is nought or one  so it takes the old
  [->>+<<]                                                     ; ; kernel
>>
                                                               ; ASSERT ptr=53
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>]                                             ; continued
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
<<<
                                                               ; ASSERT ptr=51
                                                               ; ASSERT zero 52:62

; ============================================================ ; ; byte 1
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<                              ; the accumulator byte steps into the adder
                                                               ; ASSERT ptr=18
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<]                                               ; continued
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>                                              ; to the kernel's base  which is where a paste site
                                                               ; always stands
                                                               ; ASSERT ptr=52
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=53
                                                               ; ASSERT zero 55:62
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=52
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=55
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=53
  [->>+<<]
>>
                                                               ; ASSERT ptr=55
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=59
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=62
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=60
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=57
  [-[[-]>>>>+<<<<]]
; ============================================================ ; ; ; the carry out is bit 7 of that  and nothing else
>>>>
                                                               ; ASSERT ptr=61
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=55
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
                                                               ; ASSERT ptr=55
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ============================================================ ; ; ; the sum is twice the halves plus the two low bits
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=59
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=60
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=52
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 53:53
                                                               ; ASSERT zero 55:62

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=52
<                                                              ; the carry in is nought or one  so it takes the old
  [->>+<<]                                                     ; ; kernel
>>
                                                               ; ASSERT ptr=53
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>]                                               ; continued
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
<<<
                                                               ; ASSERT ptr=51
                                                               ; ASSERT zero 52:62

; ============================================================ ; ; byte 2
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<                               ; the accumulator byte steps into the adder
                                                               ; ASSERT ptr=19
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<]                                                 ; continued
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>                                               ; to the kernel's base  which is where a paste site
                                                               ; always stands
                                                               ; ASSERT ptr=52
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=53
                                                               ; ASSERT zero 55:62
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=52
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=55
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=53
  [->>+<<]
>>
                                                               ; ASSERT ptr=55
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=59
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=62
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=60
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=57
  [-[[-]>>>>+<<<<]]
; ============================================================ ; ; ; the carry out is bit 7 of that  and nothing else
>>>>
                                                               ; ASSERT ptr=61
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=55
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
                                                               ; ASSERT ptr=55
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ============================================================ ; ; ; the sum is twice the halves plus the two low bits
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=59
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=60
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=52
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 53:53
                                                               ; ASSERT zero 55:62

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=52
<                                                              ; the carry in is nought or one  so it takes the old
  [->>+<<]                                                     ; ; kernel
>>
                                                               ; ASSERT ptr=53
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>]                                                 ; continued
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
<<<
                                                               ; ASSERT ptr=51
                                                               ; ASSERT zero 52:62

; ============================================================ ; ; byte 3
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<                                ; the accumulator byte steps into the adder
                                                               ; ASSERT ptr=20
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<]                                                   ; continued
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>                                                ; to the kernel's base  which is where a paste site
                                                               ; always stands
                                                               ; ASSERT ptr=52
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=53
                                                               ; ASSERT zero 55:62
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=52
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=55
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=53
  [->>+<<]
>>
                                                               ; ASSERT ptr=55
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=59
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=62
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=60
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=57
  [-[[-]>>>>+<<<<]]
; ============================================================ ; ; ; the carry out is bit 7 of that  and nothing else
>>>>
                                                               ; ASSERT ptr=61
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=55
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
                                                               ; ASSERT ptr=55
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ============================================================ ; ; ; the sum is twice the halves plus the two low bits
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=59
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=60
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=52
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 53:53
                                                               ; ASSERT zero 55:62

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=52
<                                                              ; the carry in is nought or one  so it takes the old
  [->>+<<]                                                     ; ; kernel
>>
                                                               ; ASSERT ptr=53
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>]                                                   ; continued
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
<<<
                                                               ; ASSERT ptr=51
                                                               ; ASSERT zero 52:62

; ============================================================ ; ; byte 4
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<                                 ; the accumulator byte steps into the adder
                                                               ; ASSERT ptr=21
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<]                                                     ; continued
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>                                                 ; to the kernel's base  which is where a paste site
                                                               ; always stands
                                                               ; ASSERT ptr=52
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=53
                                                               ; ASSERT zero 55:62
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=52
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=55
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=53
  [->>+<<]
>>
                                                               ; ASSERT ptr=55
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=59
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=62
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=60
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=57
  [-[[-]>>>>+<<<<]]
; ============================================================ ; ; ; the carry out is bit 7 of that  and nothing else
>>>>
                                                               ; ASSERT ptr=61
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=55
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
                                                               ; ASSERT ptr=55
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ============================================================ ; ; ; the sum is twice the halves plus the two low bits
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=59
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=60
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=52
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 53:53
                                                               ; ASSERT zero 55:62

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=52
<                                                              ; the carry in is nought or one  so it takes the old
  [->>+<<]                                                     ; ; kernel
>>
                                                               ; ASSERT ptr=53
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>]                                                     ; continued
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
<<<
                                                               ; ASSERT ptr=51
                                                               ; ASSERT zero 52:62

; ============================================================ ; ; byte 5
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<                                  ; the accumulator byte steps into the adder
                                                               ; ASSERT ptr=22
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<]                                                       ; continued
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>>>>>>>>>>>>+<<<<<<<<<<<<<<]
>>>>>>>>>>>>>                                                  ; to the kernel's base  which is where a paste site
                                                               ; always stands
                                                               ; ASSERT ptr=52
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=53
                                                               ; ASSERT zero 55:62
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=52
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=55
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=53
  [->>+<<]
>>
                                                               ; ASSERT ptr=55
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=59
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=62
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=60
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=57
  [-[[-]>>>>+<<<<]]
; ============================================================ ; ; ; the carry out is bit 7 of that  and nothing else
>>>>
                                                               ; ASSERT ptr=61
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=55
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
                                                               ; ASSERT ptr=55
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ============================================================ ; ; ; the sum is twice the halves plus the two low bits
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=59
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=60
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=52
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 53:53
                                                               ; ASSERT zero 55:62

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=52
<                                                              ; the carry in is nought or one  so it takes the old
  [->>+<<]                                                     ; ; kernel
>>
                                                               ; ASSERT ptr=53
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>]                                                       ; continued
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
<<<
                                                               ; ASSERT ptr=51
                                                               ; ASSERT zero 52:62

; ============================================================ ; ; byte 6
<<<<<<<<<<<<<<<<<<<<<<<<<<<<                                   ; the accumulator byte steps into the adder
                                                               ; ASSERT ptr=23
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<]                                                         ; continued
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>>>>>>>>>>>+<<<<<<<<<<<<<]
>>>>>>>>>>>>                                                   ; to the kernel's base  which is where a paste site
                                                               ; always stands
                                                               ; ASSERT ptr=52
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=53
                                                               ; ASSERT zero 55:62
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=52
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=55
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=53
  [->>+<<]
>>
                                                               ; ASSERT ptr=55
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=59
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=62
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=60
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=57
  [-[[-]>>>>+<<<<]]
; ============================================================ ; ; ; the carry out is bit 7 of that  and nothing else
>>>>
                                                               ; ASSERT ptr=61
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=55
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
                                                               ; ASSERT ptr=55
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ============================================================ ; ; ; the sum is twice the halves plus the two low bits
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=59
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=60
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=52
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 53:53
                                                               ; ASSERT zero 55:62

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=52
<                                                              ; the carry in is nought or one  so it takes the old
  [->>+<<]                                                     ; ; kernel
>>
                                                               ; ASSERT ptr=53
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>]                                                         ; continued
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
<<<
                                                               ; ASSERT ptr=51
                                                               ; ASSERT zero 52:62

; ============================================================ ; ; byte 7
<<<<<<<<<<<<<<<<<<<<<<<<<<<                                    ; the accumulator byte steps into the adder
                                                               ; ASSERT ptr=24
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <]                                                           ; continued
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>>>>>>>>>>+<<<<<<<<<<<<]
>>>>>>>>>>>                                                    ; to the kernel's base  which is where a paste site
                                                               ; always stands
                                                               ; ASSERT ptr=52
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=53
                                                               ; ASSERT zero 55:62
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=52
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=55
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=53
  [->>+<<]
>>
                                                               ; ASSERT ptr=55
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=59
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=62
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=60
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=57
  [-[[-]>>>>+<<<<]]
; ============================================================ ; ; ; the carry out is bit 7 of that  and nothing else
>>>>
                                                               ; ASSERT ptr=61
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=55
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
                                                               ; ASSERT ptr=55
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ============================================================ ; ; ; the sum is twice the halves plus the two low bits
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=59
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=60
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=52
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 53:53
                                                               ; ASSERT zero 55:62

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=52
<                                                              ; the carry in is nought or one  so it takes the old
  [->>+<<]                                                     ; ; kernel
>>
                                                               ; ASSERT ptr=53
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >]                                                           ; continued
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
<<<
                                                               ; ASSERT ptr=51
                                                               ; ASSERT zero 52:62

; ============================================================ ; ; byte 8
<<<<<<<<<<<<<<<<<<<<<<<<<<                                     ; the accumulator byte steps into the adder
                                                               ; ASSERT ptr=25
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>>>>>>>>>+<<<<<<<<<<<]
>>>>>>>>>>                                                     ; to the kernel's base  which is where a paste site
                                                               ; always stands
                                                               ; ASSERT ptr=52
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=53
                                                               ; ASSERT zero 55:62
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=52
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=55
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=53
  [->>+<<]
>>
                                                               ; ASSERT ptr=55
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=59
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=62
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=60
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=57
  [-[[-]>>>>+<<<<]]
; ============================================================ ; ; ; the carry out is bit 7 of that  and nothing else
>>>>
                                                               ; ASSERT ptr=61
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=55
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
                                                               ; ASSERT ptr=55
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ============================================================ ; ; ; the sum is twice the halves plus the two low bits
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=59
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=60
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=52
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 53:53
                                                               ; ASSERT zero 55:62

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=52
<                                                              ; the carry in is nought or one  so it takes the old
  [->>+<<]                                                     ; ; kernel
>>
                                                               ; ASSERT ptr=53
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>>]
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
<<<
                                                               ; ASSERT ptr=51
                                                               ; ASSERT zero 52:62

; ============================================================ ; ; byte 9
<<<<<<<<<<<<<<<<<<<<<<<<<                                      ; the accumulator byte steps into the adder
                                                               ; ASSERT ptr=26
  [->>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>>>>>>>>+<<<<<<<<<<]
>>>>>>>>>                                                      ; to the kernel's base  which is where a paste site
                                                               ; always stands
                                                               ; ASSERT ptr=52
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=53
                                                               ; ASSERT zero 55:62
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=52
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=55
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=53
  [->>+<<]
>>
                                                               ; ASSERT ptr=55
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=59
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=62
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=60
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=57
  [-[[-]>>>>+<<<<]]
; ============================================================ ; ; ; the carry out is bit 7 of that  and nothing else
>>>>
                                                               ; ASSERT ptr=61
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=55
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
                                                               ; ASSERT ptr=55
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ============================================================ ; ; ; the sum is twice the halves plus the two low bits
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=59
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=60
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=52
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 53:53
                                                               ; ASSERT zero 55:62

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=52
<                                                              ; the carry in is nought or one  so it takes the old
  [->>+<<]                                                     ; ; kernel
>>
                                                               ; ASSERT ptr=53
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>]
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
<<<
                                                               ; ASSERT ptr=51
                                                               ; ASSERT zero 52:62

; ============================================================ ; ; byte 10
<<<<<<<<<<<<<<<<<<<<<<<<                                       ; the accumulator byte steps into the adder
                                                               ; ASSERT ptr=27
  [->>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>>>>>>>+<<<<<<<<<]
>>>>>>>>                                                       ; to the kernel's base  which is where a paste site
                                                               ; always stands
                                                               ; ASSERT ptr=52
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=53
                                                               ; ASSERT zero 55:62
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=52
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=55
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=53
  [->>+<<]
>>
                                                               ; ASSERT ptr=55
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=59
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=62
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=60
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=57
  [-[[-]>>>>+<<<<]]
; ============================================================ ; ; ; the carry out is bit 7 of that  and nothing else
>>>>
                                                               ; ASSERT ptr=61
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=55
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
                                                               ; ASSERT ptr=55
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ============================================================ ; ; ; the sum is twice the halves plus the two low bits
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=59
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=60
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=52
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 53:53
                                                               ; ASSERT zero 55:62

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=52
<                                                              ; the carry in is nought or one  so it takes the old
  [->>+<<]                                                     ; ; kernel
>>
                                                               ; ASSERT ptr=53
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>]
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
<<<
                                                               ; ASSERT ptr=51
                                                               ; ASSERT zero 52:62

; ============================================================ ; ; byte 11
<<<<<<<<<<<<<<<<<<<<<<<                                        ; the accumulator byte steps into the adder
                                                               ; ASSERT ptr=28
  [->>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>>>>>>+<<<<<<<<]
>>>>>>>                                                        ; to the kernel's base  which is where a paste site
                                                               ; always stands
                                                               ; ASSERT ptr=52
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=53
                                                               ; ASSERT zero 55:62
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=52
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=55
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=53
  [->>+<<]
>>
                                                               ; ASSERT ptr=55
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=59
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=62
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=60
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=57
  [-[[-]>>>>+<<<<]]
; ============================================================ ; ; ; the carry out is bit 7 of that  and nothing else
>>>>
                                                               ; ASSERT ptr=61
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=55
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
                                                               ; ASSERT ptr=55
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ============================================================ ; ; ; the sum is twice the halves plus the two low bits
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=59
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=60
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=52
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 53:53
                                                               ; ASSERT zero 55:62

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=52
<                                                              ; the carry in is nought or one  so it takes the old
  [->>+<<]                                                     ; ; kernel
>>
                                                               ; ASSERT ptr=53
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>]
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
<<<
                                                               ; ASSERT ptr=51
                                                               ; ASSERT zero 52:62

; ============================================================ ; ; byte 12
<<<<<<<<<<<<<<<<<<<<<<                                         ; the accumulator byte steps into the adder
                                                               ; ASSERT ptr=29
  [->>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>>>>>+<<<<<<<]
>>>>>>                                                         ; to the kernel's base  which is where a paste site
                                                               ; always stands
                                                               ; ASSERT ptr=52
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=53
                                                               ; ASSERT zero 55:62
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=52
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=55
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=53
  [->>+<<]
>>
                                                               ; ASSERT ptr=55
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=59
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=62
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=60
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=57
  [-[[-]>>>>+<<<<]]
; ============================================================ ; ; ; the carry out is bit 7 of that  and nothing else
>>>>
                                                               ; ASSERT ptr=61
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=55
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
                                                               ; ASSERT ptr=55
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ============================================================ ; ; ; the sum is twice the halves plus the two low bits
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=59
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=60
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=52
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 53:53
                                                               ; ASSERT zero 55:62

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=52
<                                                              ; the carry in is nought or one  so it takes the old
  [->>+<<]                                                     ; ; kernel
>>
                                                               ; ASSERT ptr=53
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>]
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
<<<
                                                               ; ASSERT ptr=51
                                                               ; ASSERT zero 52:62

; ============================================================ ; ; byte 13
<<<<<<<<<<<<<<<<<<<<<                                          ; the accumulator byte steps into the adder
                                                               ; ASSERT ptr=30
  [->>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>>>>+<<<<<<]
>>>>>                                                          ; to the kernel's base  which is where a paste site
                                                               ; always stands
                                                               ; ASSERT ptr=52
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=53
                                                               ; ASSERT zero 55:62
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=52
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=55
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=53
  [->>+<<]
>>
                                                               ; ASSERT ptr=55
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=59
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=62
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=60
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=57
  [-[[-]>>>>+<<<<]]
; ============================================================ ; ; ; the carry out is bit 7 of that  and nothing else
>>>>
                                                               ; ASSERT ptr=61
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=55
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
                                                               ; ASSERT ptr=55
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ============================================================ ; ; ; the sum is twice the halves plus the two low bits
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=59
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=60
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=52
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 53:53
                                                               ; ASSERT zero 55:62

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=52
<                                                              ; the carry in is nought or one  so it takes the old
  [->>+<<]                                                     ; ; kernel
>>
                                                               ; ASSERT ptr=53
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>]
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
<<<
                                                               ; ASSERT ptr=51
                                                               ; ASSERT zero 52:62

; ============================================================ ; ; byte 14
<<<<<<<<<<<<<<<<<<<<                                           ; the accumulator byte steps into the adder
                                                               ; ASSERT ptr=31
  [->>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>>>+<<<<<]
>>>>                                                           ; to the kernel's base  which is where a paste site
                                                               ; always stands
                                                               ; ASSERT ptr=52
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=53
                                                               ; ASSERT zero 55:62
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=52
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=55
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=53
  [->>+<<]
>>
                                                               ; ASSERT ptr=55
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=59
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=62
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=60
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=57
  [-[[-]>>>>+<<<<]]
; ============================================================ ; ; ; the carry out is bit 7 of that  and nothing else
>>>>
                                                               ; ASSERT ptr=61
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=55
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
                                                               ; ASSERT ptr=55
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ============================================================ ; ; ; the sum is twice the halves plus the two low bits
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=59
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=60
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=52
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 53:53
                                                               ; ASSERT zero 55:62

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=52
<                                                              ; the carry in is nought or one  so it takes the old
  [->>+<<]                                                     ; ; kernel
>>
                                                               ; ASSERT ptr=53
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>]
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
<<<
                                                               ; ASSERT ptr=51
                                                               ; ASSERT zero 52:62

; ============================================================ ; ; byte 15
<<<<<<<<<<<<<<<<<<<                                            ; the accumulator byte steps into the adder
                                                               ; ASSERT ptr=32
  [->>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>>+<<<<]
>>>                                                            ; to the kernel's base  which is where a paste site
                                                               ; always stands
                                                               ; ASSERT ptr=52
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=53
                                                               ; ASSERT zero 55:62
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=52
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=55
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=53
  [->>+<<]
>>
                                                               ; ASSERT ptr=55
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=59
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=62
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=60
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=57
  [-[[-]>>>>+<<<<]]
; ============================================================ ; ; ; the carry out is bit 7 of that  and nothing else
>>>>
                                                               ; ASSERT ptr=61
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=55
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
                                                               ; ASSERT ptr=55
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ============================================================ ; ; ; the sum is twice the halves plus the two low bits
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=59
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=60
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=52
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 53:53
                                                               ; ASSERT zero 55:62

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=52
<                                                              ; the carry in is nought or one  so it takes the old
  [->>+<<]                                                     ; ; kernel
>>
                                                               ; ASSERT ptr=53
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>]
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
<<<
                                                               ; ASSERT ptr=51
                                                               ; ASSERT zero 52:62

; ============================================================ ; ; byte 16
<<<<<<<<<<<<<<<<<<                                             ; the accumulator byte steps into the adder
                                                               ; ASSERT ptr=33
  [->>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>+<<<]
>>                                                             ; to the kernel's base  which is where a paste site
                                                               ; always stands
                                                               ; ASSERT ptr=52
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=53
                                                               ; ASSERT zero 55:62
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=52
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=55
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=53
  [->>+<<]
>>
                                                               ; ASSERT ptr=55
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=59
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=62
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=60
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=57
  [-[[-]>>>>+<<<<]]
; ============================================================ ; ; ; the carry out is bit 7 of that  and nothing else
>>>>
                                                               ; ASSERT ptr=61
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=55
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
                                                               ; ASSERT ptr=55
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ============================================================ ; ; ; the sum is twice the halves plus the two low bits
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=59
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=60
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=52
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 53:53
                                                               ; ASSERT zero 55:62

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=52
<                                                              ; the carry in is nought or one  so it takes the old
  [->>+<<]                                                     ; ; kernel
>>
                                                               ; ASSERT ptr=53
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>]
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
<<<
                                                               ; ASSERT ptr=51
                                                               ; ASSERT zero 52:62

                                                               ; the carry out of the top byte is dropped  and cleared
                                                               ; so the frame is as empty as it was found
                                                               ; ASSERT ptr=51
  [-]
                                                               ; ASSERT zero 34:62

  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<                           ; walk back out to the routine base
                                                               ; ASSERT ptr=17
                                                               ; add136 consumes its addend  so the block slot is
                                                               ; clear for r to take; the whole layout rests on that
                                                               ; so it is asserted here rather than trusted;
                                                               ; ASSERT zero 34:50
<<<<<<<<<<<<<<<<<                                              ; to r
                                                               ; ASSERT ptr=0
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<   ; r moves into the slot the block has just left
  <<<<<<<<<<<<<]                                               ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<   ; r moves into the slot the block has just left
  <<<<<<<<<<<<<]                                               ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<   ; r moves into the slot the block has just left
  <<<<<<<<<<<<<]                                               ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<   ; r moves into the slot the block has just left
  <<<<<<<<<<<<<]                                               ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<   ; r moves into the slot the block has just left
  <<<<<<<<<<<<<]                                               ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<   ; r moves into the slot the block has just left
  <<<<<<<<<<<<<]                                               ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<   ; r moves into the slot the block has just left
  <<<<<<<<<<<<<]                                               ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<   ; r moves into the slot the block has just left
  <<<<<<<<<<<<<]                                               ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<   ; r moves into the slot the block has just left
  <<<<<<<<<<<<<]                                               ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<   ; r moves into the slot the block has just left
  <<<<<<<<<<<<<]                                               ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<   ; r moves into the slot the block has just left
  <<<<<<<<<<<<<]                                               ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<   ; r moves into the slot the block has just left
  <<<<<<<<<<<<<]                                               ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<   ; r moves into the slot the block has just left
  <<<<<<<<<<<<<]                                               ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<   ; r moves into the slot the block has just left
  <<<<<<<<<<<<<]                                               ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<   ; r moves into the slot the block has just left
  <<<<<<<<<<<<<]                                               ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<   ; r moves into the slot the block has just left
  <<<<<<<<<<<<<]                                               ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<   ; r moves into the slot the block has just left
  <<<<<<<<<<<<<]                                               ; continued
>                                                              ; back to the accumulator
                                                               ; ASSERT ptr=17
                                                               ; r was moved and not copied  so its own slot is empty
                                                               ; again
                                                               ; ASSERT zero 0:16
                                                               ; the accumulator is multiplied by r  modulo two to the
                                                               ; 130 minus five walk in to this routine entry offset
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=51
                                                               ; ASSERT zero 51:141
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<                             ; to the head of a
                                                               ; ASSERT ptr=17

; ============================================================ ; ; a becomes the running double  and b the multiplier
                                                               ; each in its own
; ============================================================ ; ; place  so that nothing needs carrying once the loop
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<   ; ; starts
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]             ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]             ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]             ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]             ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]             ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]             ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]             ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]             ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]             ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]             ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]             ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]             ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]             ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]             ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]             ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]             ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]             ; continued
                                                               ; ASSERT ptr=33
>                                                              ; to the head of b
                                                               ; ASSERT ptr=34
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]   ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]   ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]   ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]   ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]   ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]   ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]   ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]   ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]   ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]   ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]   ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]   ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]   ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]   ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]   ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]   ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]   ; continued
                                                               ; ASSERT ptr=50

; ============================================================ ; ; a is folded once  because the doubling below would
                                                               ; lose its top bit
>>>>>>>>>>>>>>>>>>                                             ; to the running double
                                                               ; ASSERT ptr=68
                                                               ; ASSERT zero 85:118
  >>>>>>>>>>>>>>>>                                             ; walk in to this routine entry offset

; ============================================================ ; ; ; split the top byte at bit 130
                                                               ; ASSERT ptr=84
                                                               ; ASSERT zero 85:102
  [->>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<]                           ; the top byte steps into the halving frame
>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=99
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; the first halving; the bit it drops is bit 128
>>                                                             ; which is worth one in what is left below the split
                                                               ; ASSERT ptr=101
  [-<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>]
<                                                              ; the half steps back into the frame to be halved again
                                                               ; ASSERT ptr=100
  [-<+>]
<
                                                               ; ASSERT ptr=99
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; the second halving; the bit it drops is bit 129
>>                                                             ; which is worth two
                                                               ; ASSERT ptr=101
  [-<<<<<<<<<<<<<<<<<++>>>>>>>>>>>>>>>>>]
<                                                              ; and what is left in the quotient is everything at bit
                                                               ; 130 and above
                                                               ; ASSERT ptr=100
  [-<<+>>]

; ============================================================ ; ; ; two to the hundred and thirtieth is five  so five
                                                               ; times that part
<<                                                             ; to the part above the split
                                                               ; ASSERT ptr=98
                                                               ; it is spent ONCE  into four copies of itself and one
                                                               ; copy of itself  which is where the five comes from;
                                                               ; neither cell can wrap  because four times sixty three
                                                               ; is two hundred and fifty two
  [-<<<<<<<<<<<<<++++>+>>>>>>>>>>>>]
                                                               ; ASSERT ptr=98
<<<<<<<<<<<<<                                                  ; to the byte pair the eight bit adder works on
                                                               ; ASSERT ptr=85
                                                               ; ASSERT zero 87:95
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=86
                                                               ; ASSERT zero 88:95
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=85
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=88
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=86
  [->>+<<]
>>
                                                               ; ASSERT ptr=88
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=92
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=95
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=93
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=90
  [-[[-]>>>>+<<<<]]
; ============================================================ ; ; ; ; the carry out is bit 7 of that  and nothing
                                                               ; else
>>>>
                                                               ; ASSERT ptr=94
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=88
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
                                                               ; ASSERT ptr=88
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ============================================================ ; ; ; ; the sum is twice the halves plus the two low
                                                               ; bits
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=92
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=93
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=85
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 86:86
                                                               ; ASSERT zero 88:95

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=85
  [->>>>>>>>>>>+<<<<<<<<<<<]                                   ; the sum is five times H modulo 256  and it is the
                                                               ; addend's low byte
>>                                                             ; to the carry add8 computed
                                                               ; ASSERT ptr=87
  [->>>>>>>>>>+<<<<<<<<<<]                                     ; which is the addend's high byte  worth two hundred
                                                               ; and fifty six

; ============================================================ ; ; ; the bottom byte of the value takes the low byte
                                                               ; of
<<<<<<<<<<<<<<<<<<<                                            ; ; five times H
                                                               ; ASSERT ptr=68
  [->>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=96
  [-<<<<<<<<<<+>>>>>>>>>>]
<<<<<<<<<<<
                                                               ; ASSERT ptr=85
                                                               ; ASSERT zero 87:95
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=86
                                                               ; ASSERT zero 88:95
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=85
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=88
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=86
  [->>+<<]
>>
                                                               ; ASSERT ptr=88
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=92
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=95
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=93
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=90
  [-[[-]>>>>+<<<<]]
; ============================================================ ; ; ; ; the carry out is bit 7 of that  and nothing
                                                               ; else
>>>>
                                                               ; ASSERT ptr=94
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=88
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
                                                               ; ASSERT ptr=88
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ============================================================ ; ; ; ; the sum is twice the halves plus the two low
                                                               ; bits
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=92
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=93
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=85
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 86:86
                                                               ; ASSERT zero 88:95

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=85
  [-<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>]                       ; the sum goes home and the carry stays where add8 left
                                                               ; it

; ============================================================ ; ; ; the second byte takes the high byte  and that
                                                               ; carry
<<<<<<<<<<<<<<<<                                               ; ; with it
                                                               ; ASSERT ptr=69
  [->>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=97
  [-<<<<<<<<<<<+>>>>>>>>>>>]
<<<<<<<<<<
                                                               ; ASSERT ptr=87
  [-<+>]
<<
                                                               ; ASSERT ptr=85
                                                               ; ASSERT zero 87:95
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=86
                                                               ; ASSERT zero 88:95
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=85
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=88
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=86
  [->>+<<]
>>
                                                               ; ASSERT ptr=88
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=92
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=95
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=93
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=90
  [-[[-]>>>>+<<<<]]
; ============================================================ ; ; ; ; the carry out is bit 7 of that  and nothing
                                                               ; else
>>>>
                                                               ; ASSERT ptr=94
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=88
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
                                                               ; ASSERT ptr=88
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ============================================================ ; ; ; ; the sum is twice the halves plus the two low
                                                               ; bits
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=92
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=93
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=85
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 86:86
                                                               ; ASSERT zero 88:95

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=85
  [-<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>]
>>
                                                               ; ASSERT ptr=87

; ============================================================ ; ; ; and the carry out of that ripples up through the
                                                               ; rest

[                                                              ; ____ byte 2 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=96
  [-]+
<<<<<<<<<<<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=70
  +
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<]                                                          ; continued
>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=98
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >]                                                           ; continued
<
                                                               ; ASSERT ptr=97
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=87
]
                                                               ; ASSERT ptr=87
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=96
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=87

[                                                              ; ____ byte 3 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=96
  [-]+
<<<<<<<<<<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=71
  +
  [->>>>>>>>>>>>>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]                                                            ; continued
>>>>>>>>>>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=98
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=97
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=87
]
                                                               ; ASSERT ptr=87
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=96
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=87

[                                                              ; ____ byte 4 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=96
  [-]+
<<<<<<<<<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=72
  +
  [->>>>>>>>>>>>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=98
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=97
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=87
]
                                                               ; ASSERT ptr=87
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=96
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=87

[                                                              ; ____ byte 5 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=96
  [-]+
<<<<<<<<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=73
  +
  [->>>>>>>>>>>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=98
  [-<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=97
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=87
]
                                                               ; ASSERT ptr=87
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=96
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=87

[                                                              ; ____ byte 6 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=96
  [-]+
<<<<<<<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=74
  +
  [->>>>>>>>>>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=98
  [-<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=97
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=87
]
                                                               ; ASSERT ptr=87
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=96
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=87

[                                                              ; ____ byte 7 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=96
  [-]+
<<<<<<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=75
  +
  [->>>>>>>>>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=98
  [-<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=97
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=87
]
                                                               ; ASSERT ptr=87
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=96
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=87

[                                                              ; ____ byte 8 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=96
  [-]+
<<<<<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=76
  +
  [->>>>>>>>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=98
  [-<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=97
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=87
]
                                                               ; ASSERT ptr=87
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=96
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=87

[                                                              ; ____ byte 9 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=96
  [-]+
<<<<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=77
  +
  [->>>>>>>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=98
  [-<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=97
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=87
]
                                                               ; ASSERT ptr=87
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=96
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=87

[                                                              ; ____ byte 10 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=96
  [-]+
<<<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=78
  +
  [->>>>>>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=98
  [-<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=97
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=87
]
                                                               ; ASSERT ptr=87
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=96
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=87

[                                                              ; ____ byte 11 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=96
  [-]+
<<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=79
  +
  [->>>>>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=98
  [-<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=97
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=87
]
                                                               ; ASSERT ptr=87
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=96
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=87

[                                                              ; ____ byte 12 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=96
  [-]+
<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=80
  +
  [->>>>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=98
  [-<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=97
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=87
]
                                                               ; ASSERT ptr=87
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=96
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=87

[                                                              ; ____ byte 13 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=96
  [-]+
<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=81
  +
  [->>>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=98
  [-<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=97
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=87
]
                                                               ; ASSERT ptr=87
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=96
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=87

[                                                              ; ____ byte 14 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=96
  [-]+
<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=82
  +
  [->>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=98
  [-<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=97
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=87
]
                                                               ; ASSERT ptr=87
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=96
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=87

[                                                              ; ____ byte 15 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=96
  [-]+
<<<<<<<<<<<<<
                                                               ; ASSERT ptr=83
  +
  [->>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=98
  [-<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=97
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=87
]
                                                               ; ASSERT ptr=87
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=96
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=87

[                                                              ; ____ byte 16  which does not look  because its carry
  [-]                                                          ; ; cannot happen ____
<<<
                                                               ; ASSERT ptr=84
  +
>>>
                                                               ; ASSERT ptr=87
]
                                                               ; ASSERT ptr=87

; ============================================================ ; ; ; the value is folded
<<<<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=68
                                                               ; ASSERT zero 85:102
                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=68

; ============================================================ ; ; seventeen bytes of b  eight bits each
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; to the byte counter
  >>>>>>>>>>>>>                                                ; continued
                                                               ; ASSERT ptr=141
  +++++++++++++++++
[
  -
<<<<<<<<<<<<<<<<<<<<<<                                         ; to the bottom byte of what is left of b
                                                               ; ASSERT ptr=119
  [->>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<]                       ; it steps out into the cell the halving spends
>                                                              ; and the rest of b slides down one place to take its
  [-<+>]                                                       ; ; turn next
>                                                              ; the next byte
  [-<+>]
>                                                              ; the next byte
  [-<+>]
>                                                              ; the next byte
  [-<+>]
>                                                              ; the next byte
  [-<+>]
>                                                              ; the next byte
  [-<+>]
>                                                              ; the next byte
  [-<+>]
>                                                              ; the next byte
  [-<+>]
>                                                              ; the next byte
  [-<+>]
>                                                              ; the next byte
  [-<+>]
>                                                              ; the next byte
  [-<+>]
>                                                              ; the next byte
  [-<+>]
>                                                              ; the next byte
  [-<+>]
>                                                              ; the next byte
  [-<+>]
>                                                              ; the next byte
  [-<+>]
>                                                              ; the next byte
  [-<+>]
                                                               ; ASSERT ptr=135
>>>>>                                                          ; to the bit counter
                                                               ; ASSERT ptr=140
  ++++++++
[
  -
<<<<                                                           ; to the byte in hand
                                                               ; ASSERT ptr=136
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; the halving leaves the byte's low bit beside its own
                                                               ; half
>                                                              ; the half goes back to be halved again next turn
                                                               ; ASSERT ptr=137
  [-<+>]
>                                                              ; to the bit itself
                                                               ; ASSERT ptr=138
[
  [-]                                                          ; the bit is spent here  so this arm runs once and not
                                                               ; once per unit
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; to the running double
  <<<<<<<<<<                                                   ; continued
                                                               ; ASSERT ptr=68
                                                               ; the double is copied  not moved: the adder spends
                                                               ; what it is given and the next turn still needs it
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>+>>>
  >>>>>>>>>>>>>>]                                              ; continued
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>+>>>
  >>>>>>>>>>>>>>]                                              ; continued
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>+>>>
  >>>>>>>>>>>>>>]                                              ; continued
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>+>>>
  >>>>>>>>>>>>>>]                                              ; continued
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>+>>>
  >>>>>>>>>>>>>>]                                              ; continued
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>+>>>
  >>>>>>>>>>>>>>]                                              ; continued
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>+>>>
  >>>>>>>>>>>>>>]                                              ; continued
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>+>>>
  >>>>>>>>>>>>>>]                                              ; continued
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>+>>>
  >>>>>>>>>>>>>>]                                              ; continued
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>+>>>
  >>>>>>>>>>>>>>]                                              ; continued
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>+>>>
  >>>>>>>>>>>>>>]                                              ; continued
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>+>>>
  >>>>>>>>>>>>>>]                                              ; continued
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>+>>>
  >>>>>>>>>>>>>>]                                              ; continued
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>+>>>
  >>>>>>>>>>>>>>]                                              ; continued
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>+>>>
  >>>>>>>>>>>>>>]                                              ; continued
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>+>>>
  >>>>>>>>>>>>>>]                                              ; continued
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>+>>>
  >>>>>>>>>>>>>>]                                              ; continued
                                                               ; ASSERT ptr=84
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<                              ; to the cell that kept it
                                                               ; ASSERT ptr=51
  [->>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<]
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<]
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<]
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<]
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<]
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<]
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<]
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<]
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<]
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<]
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<]
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<]
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<]
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<]
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<]
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<]
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<]
                                                               ; ASSERT ptr=67
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<             ; to the answer  which is the adder's accumulator
                                                               ; ASSERT ptr=17
                                                               ; ASSERT zero 51:62
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>                           ; walk in to this routine entry offset
                                                               ; ASSERT ptr=51
                                                               ; ASSERT zero 51:62

; ============================================================ ; ; ; byte 0
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<                             ; the accumulator byte steps into the adder
                                                               ; ASSERT ptr=17
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<]                                             ; continued
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>                                             ; to the kernel's base  which is where a paste site
                                                               ; always stands
                                                               ; ASSERT ptr=52
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=53
                                                               ; ASSERT zero 55:62
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=52
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=55
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=53
  [->>+<<]
>>
                                                               ; ASSERT ptr=55
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=59
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=62
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=60
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=57
  [-[[-]>>>>+<<<<]]
; ============================================================ ; ; ; ; the carry out is bit 7 of that  and nothing
                                                               ; else
>>>>
                                                               ; ASSERT ptr=61
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=55
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
                                                               ; ASSERT ptr=55
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ============================================================ ; ; ; ; the sum is twice the halves plus the two low
                                                               ; bits
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=59
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=60
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=52
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 53:53
                                                               ; ASSERT zero 55:62

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=52
<                                                              ; the carry in is nought or one  so it takes the old
  [->>+<<]                                                     ; ; kernel
>>
                                                               ; ASSERT ptr=53
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>]                                             ; continued
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
<<<
                                                               ; ASSERT ptr=51
                                                               ; ASSERT zero 52:62

; ============================================================ ; ; ; byte 1
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<                              ; the accumulator byte steps into the adder
                                                               ; ASSERT ptr=18
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<]                                               ; continued
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>                                              ; to the kernel's base  which is where a paste site
                                                               ; always stands
                                                               ; ASSERT ptr=52
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=53
                                                               ; ASSERT zero 55:62
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=52
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=55
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=53
  [->>+<<]
>>
                                                               ; ASSERT ptr=55
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=59
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=62
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=60
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=57
  [-[[-]>>>>+<<<<]]
; ============================================================ ; ; ; ; the carry out is bit 7 of that  and nothing
                                                               ; else
>>>>
                                                               ; ASSERT ptr=61
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=55
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
                                                               ; ASSERT ptr=55
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ============================================================ ; ; ; ; the sum is twice the halves plus the two low
                                                               ; bits
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=59
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=60
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=52
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 53:53
                                                               ; ASSERT zero 55:62

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=52
<                                                              ; the carry in is nought or one  so it takes the old
  [->>+<<]                                                     ; ; kernel
>>
                                                               ; ASSERT ptr=53
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>]                                               ; continued
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
<<<
                                                               ; ASSERT ptr=51
                                                               ; ASSERT zero 52:62

; ============================================================ ; ; ; byte 2
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<                               ; the accumulator byte steps into the adder
                                                               ; ASSERT ptr=19
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<]                                                 ; continued
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>                                               ; to the kernel's base  which is where a paste site
                                                               ; always stands
                                                               ; ASSERT ptr=52
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=53
                                                               ; ASSERT zero 55:62
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=52
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=55
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=53
  [->>+<<]
>>
                                                               ; ASSERT ptr=55
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=59
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=62
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=60
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=57
  [-[[-]>>>>+<<<<]]
; ============================================================ ; ; ; ; the carry out is bit 7 of that  and nothing
                                                               ; else
>>>>
                                                               ; ASSERT ptr=61
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=55
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
                                                               ; ASSERT ptr=55
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ============================================================ ; ; ; ; the sum is twice the halves plus the two low
                                                               ; bits
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=59
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=60
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=52
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 53:53
                                                               ; ASSERT zero 55:62

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=52
<                                                              ; the carry in is nought or one  so it takes the old
  [->>+<<]                                                     ; ; kernel
>>
                                                               ; ASSERT ptr=53
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>]                                                 ; continued
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
<<<
                                                               ; ASSERT ptr=51
                                                               ; ASSERT zero 52:62

; ============================================================ ; ; ; byte 3
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<                                ; the accumulator byte steps into the adder
                                                               ; ASSERT ptr=20
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<]                                                   ; continued
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>                                                ; to the kernel's base  which is where a paste site
                                                               ; always stands
                                                               ; ASSERT ptr=52
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=53
                                                               ; ASSERT zero 55:62
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=52
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=55
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=53
  [->>+<<]
>>
                                                               ; ASSERT ptr=55
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=59
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=62
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=60
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=57
  [-[[-]>>>>+<<<<]]
; ============================================================ ; ; ; ; the carry out is bit 7 of that  and nothing
                                                               ; else
>>>>
                                                               ; ASSERT ptr=61
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=55
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
                                                               ; ASSERT ptr=55
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ============================================================ ; ; ; ; the sum is twice the halves plus the two low
                                                               ; bits
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=59
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=60
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=52
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 53:53
                                                               ; ASSERT zero 55:62

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=52
<                                                              ; the carry in is nought or one  so it takes the old
  [->>+<<]                                                     ; ; kernel
>>
                                                               ; ASSERT ptr=53
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>]                                                   ; continued
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
<<<
                                                               ; ASSERT ptr=51
                                                               ; ASSERT zero 52:62

; ============================================================ ; ; ; byte 4
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<                                 ; the accumulator byte steps into the adder
                                                               ; ASSERT ptr=21
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<]                                                     ; continued
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>                                                 ; to the kernel's base  which is where a paste site
                                                               ; always stands
                                                               ; ASSERT ptr=52
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=53
                                                               ; ASSERT zero 55:62
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=52
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=55
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=53
  [->>+<<]
>>
                                                               ; ASSERT ptr=55
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=59
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=62
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=60
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=57
  [-[[-]>>>>+<<<<]]
; ============================================================ ; ; ; ; the carry out is bit 7 of that  and nothing
                                                               ; else
>>>>
                                                               ; ASSERT ptr=61
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=55
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
                                                               ; ASSERT ptr=55
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ============================================================ ; ; ; ; the sum is twice the halves plus the two low
                                                               ; bits
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=59
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=60
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=52
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 53:53
                                                               ; ASSERT zero 55:62

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=52
<                                                              ; the carry in is nought or one  so it takes the old
  [->>+<<]                                                     ; ; kernel
>>
                                                               ; ASSERT ptr=53
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>]                                                     ; continued
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
<<<
                                                               ; ASSERT ptr=51
                                                               ; ASSERT zero 52:62

; ============================================================ ; ; ; byte 5
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<                                  ; the accumulator byte steps into the adder
                                                               ; ASSERT ptr=22
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<]                                                       ; continued
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>>>>>>>>>>>>+<<<<<<<<<<<<<<]
>>>>>>>>>>>>>                                                  ; to the kernel's base  which is where a paste site
                                                               ; always stands
                                                               ; ASSERT ptr=52
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=53
                                                               ; ASSERT zero 55:62
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=52
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=55
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=53
  [->>+<<]
>>
                                                               ; ASSERT ptr=55
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=59
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=62
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=60
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=57
  [-[[-]>>>>+<<<<]]
; ============================================================ ; ; ; ; the carry out is bit 7 of that  and nothing
                                                               ; else
>>>>
                                                               ; ASSERT ptr=61
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=55
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
                                                               ; ASSERT ptr=55
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ============================================================ ; ; ; ; the sum is twice the halves plus the two low
                                                               ; bits
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=59
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=60
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=52
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 53:53
                                                               ; ASSERT zero 55:62

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=52
<                                                              ; the carry in is nought or one  so it takes the old
  [->>+<<]                                                     ; ; kernel
>>
                                                               ; ASSERT ptr=53
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>]                                                       ; continued
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
<<<
                                                               ; ASSERT ptr=51
                                                               ; ASSERT zero 52:62

; ============================================================ ; ; ; byte 6
<<<<<<<<<<<<<<<<<<<<<<<<<<<<                                   ; the accumulator byte steps into the adder
                                                               ; ASSERT ptr=23
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<]                                                         ; continued
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>>>>>>>>>>>+<<<<<<<<<<<<<]
>>>>>>>>>>>>                                                   ; to the kernel's base  which is where a paste site
                                                               ; always stands
                                                               ; ASSERT ptr=52
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=53
                                                               ; ASSERT zero 55:62
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=52
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=55
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=53
  [->>+<<]
>>
                                                               ; ASSERT ptr=55
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=59
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=62
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=60
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=57
  [-[[-]>>>>+<<<<]]
; ============================================================ ; ; ; ; the carry out is bit 7 of that  and nothing
                                                               ; else
>>>>
                                                               ; ASSERT ptr=61
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=55
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
                                                               ; ASSERT ptr=55
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ============================================================ ; ; ; ; the sum is twice the halves plus the two low
                                                               ; bits
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=59
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=60
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=52
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 53:53
                                                               ; ASSERT zero 55:62

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=52
<                                                              ; the carry in is nought or one  so it takes the old
  [->>+<<]                                                     ; ; kernel
>>
                                                               ; ASSERT ptr=53
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>]                                                         ; continued
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
<<<
                                                               ; ASSERT ptr=51
                                                               ; ASSERT zero 52:62

; ============================================================ ; ; ; byte 7
<<<<<<<<<<<<<<<<<<<<<<<<<<<                                    ; the accumulator byte steps into the adder
                                                               ; ASSERT ptr=24
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <]                                                           ; continued
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>>>>>>>>>>+<<<<<<<<<<<<]
>>>>>>>>>>>                                                    ; to the kernel's base  which is where a paste site
                                                               ; always stands
                                                               ; ASSERT ptr=52
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=53
                                                               ; ASSERT zero 55:62
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=52
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=55
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=53
  [->>+<<]
>>
                                                               ; ASSERT ptr=55
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=59
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=62
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=60
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=57
  [-[[-]>>>>+<<<<]]
; ============================================================ ; ; ; ; the carry out is bit 7 of that  and nothing
                                                               ; else
>>>>
                                                               ; ASSERT ptr=61
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=55
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
                                                               ; ASSERT ptr=55
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ============================================================ ; ; ; ; the sum is twice the halves plus the two low
                                                               ; bits
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=59
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=60
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=52
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 53:53
                                                               ; ASSERT zero 55:62

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=52
<                                                              ; the carry in is nought or one  so it takes the old
  [->>+<<]                                                     ; ; kernel
>>
                                                               ; ASSERT ptr=53
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >]                                                           ; continued
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
<<<
                                                               ; ASSERT ptr=51
                                                               ; ASSERT zero 52:62

; ============================================================ ; ; ; byte 8
<<<<<<<<<<<<<<<<<<<<<<<<<<                                     ; the accumulator byte steps into the adder
                                                               ; ASSERT ptr=25
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>>>>>>>>>+<<<<<<<<<<<]
>>>>>>>>>>                                                     ; to the kernel's base  which is where a paste site
                                                               ; always stands
                                                               ; ASSERT ptr=52
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=53
                                                               ; ASSERT zero 55:62
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=52
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=55
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=53
  [->>+<<]
>>
                                                               ; ASSERT ptr=55
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=59
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=62
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=60
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=57
  [-[[-]>>>>+<<<<]]
; ============================================================ ; ; ; ; the carry out is bit 7 of that  and nothing
                                                               ; else
>>>>
                                                               ; ASSERT ptr=61
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=55
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
                                                               ; ASSERT ptr=55
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ============================================================ ; ; ; ; the sum is twice the halves plus the two low
                                                               ; bits
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=59
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=60
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=52
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 53:53
                                                               ; ASSERT zero 55:62

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=52
<                                                              ; the carry in is nought or one  so it takes the old
  [->>+<<]                                                     ; ; kernel
>>
                                                               ; ASSERT ptr=53
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>>]
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
<<<
                                                               ; ASSERT ptr=51
                                                               ; ASSERT zero 52:62

; ============================================================ ; ; ; byte 9
<<<<<<<<<<<<<<<<<<<<<<<<<                                      ; the accumulator byte steps into the adder
                                                               ; ASSERT ptr=26
  [->>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>>>>>>>>+<<<<<<<<<<]
>>>>>>>>>                                                      ; to the kernel's base  which is where a paste site
                                                               ; always stands
                                                               ; ASSERT ptr=52
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=53
                                                               ; ASSERT zero 55:62
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=52
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=55
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=53
  [->>+<<]
>>
                                                               ; ASSERT ptr=55
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=59
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=62
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=60
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=57
  [-[[-]>>>>+<<<<]]
; ============================================================ ; ; ; ; the carry out is bit 7 of that  and nothing
                                                               ; else
>>>>
                                                               ; ASSERT ptr=61
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=55
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
                                                               ; ASSERT ptr=55
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ============================================================ ; ; ; ; the sum is twice the halves plus the two low
                                                               ; bits
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=59
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=60
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=52
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 53:53
                                                               ; ASSERT zero 55:62

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=52
<                                                              ; the carry in is nought or one  so it takes the old
  [->>+<<]                                                     ; ; kernel
>>
                                                               ; ASSERT ptr=53
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>]
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
<<<
                                                               ; ASSERT ptr=51
                                                               ; ASSERT zero 52:62

; ============================================================ ; ; ; byte 10
<<<<<<<<<<<<<<<<<<<<<<<<                                       ; the accumulator byte steps into the adder
                                                               ; ASSERT ptr=27
  [->>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>>>>>>>+<<<<<<<<<]
>>>>>>>>                                                       ; to the kernel's base  which is where a paste site
                                                               ; always stands
                                                               ; ASSERT ptr=52
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=53
                                                               ; ASSERT zero 55:62
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=52
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=55
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=53
  [->>+<<]
>>
                                                               ; ASSERT ptr=55
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=59
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=62
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=60
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=57
  [-[[-]>>>>+<<<<]]
; ============================================================ ; ; ; ; the carry out is bit 7 of that  and nothing
                                                               ; else
>>>>
                                                               ; ASSERT ptr=61
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=55
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
                                                               ; ASSERT ptr=55
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ============================================================ ; ; ; ; the sum is twice the halves plus the two low
                                                               ; bits
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=59
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=60
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=52
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 53:53
                                                               ; ASSERT zero 55:62

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=52
<                                                              ; the carry in is nought or one  so it takes the old
  [->>+<<]                                                     ; ; kernel
>>
                                                               ; ASSERT ptr=53
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>]
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
<<<
                                                               ; ASSERT ptr=51
                                                               ; ASSERT zero 52:62

; ============================================================ ; ; ; byte 11
<<<<<<<<<<<<<<<<<<<<<<<                                        ; the accumulator byte steps into the adder
                                                               ; ASSERT ptr=28
  [->>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>>>>>>+<<<<<<<<]
>>>>>>>                                                        ; to the kernel's base  which is where a paste site
                                                               ; always stands
                                                               ; ASSERT ptr=52
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=53
                                                               ; ASSERT zero 55:62
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=52
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=55
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=53
  [->>+<<]
>>
                                                               ; ASSERT ptr=55
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=59
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=62
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=60
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=57
  [-[[-]>>>>+<<<<]]
; ============================================================ ; ; ; ; the carry out is bit 7 of that  and nothing
                                                               ; else
>>>>
                                                               ; ASSERT ptr=61
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=55
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
                                                               ; ASSERT ptr=55
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ============================================================ ; ; ; ; the sum is twice the halves plus the two low
                                                               ; bits
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=59
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=60
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=52
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 53:53
                                                               ; ASSERT zero 55:62

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=52
<                                                              ; the carry in is nought or one  so it takes the old
  [->>+<<]                                                     ; ; kernel
>>
                                                               ; ASSERT ptr=53
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>]
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
<<<
                                                               ; ASSERT ptr=51
                                                               ; ASSERT zero 52:62

; ============================================================ ; ; ; byte 12
<<<<<<<<<<<<<<<<<<<<<<                                         ; the accumulator byte steps into the adder
                                                               ; ASSERT ptr=29
  [->>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>>>>>+<<<<<<<]
>>>>>>                                                         ; to the kernel's base  which is where a paste site
                                                               ; always stands
                                                               ; ASSERT ptr=52
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=53
                                                               ; ASSERT zero 55:62
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=52
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=55
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=53
  [->>+<<]
>>
                                                               ; ASSERT ptr=55
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=59
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=62
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=60
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=57
  [-[[-]>>>>+<<<<]]
; ============================================================ ; ; ; ; the carry out is bit 7 of that  and nothing
                                                               ; else
>>>>
                                                               ; ASSERT ptr=61
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=55
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
                                                               ; ASSERT ptr=55
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ============================================================ ; ; ; ; the sum is twice the halves plus the two low
                                                               ; bits
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=59
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=60
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=52
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 53:53
                                                               ; ASSERT zero 55:62

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=52
<                                                              ; the carry in is nought or one  so it takes the old
  [->>+<<]                                                     ; ; kernel
>>
                                                               ; ASSERT ptr=53
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>]
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
<<<
                                                               ; ASSERT ptr=51
                                                               ; ASSERT zero 52:62

; ============================================================ ; ; ; byte 13
<<<<<<<<<<<<<<<<<<<<<                                          ; the accumulator byte steps into the adder
                                                               ; ASSERT ptr=30
  [->>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>>>>+<<<<<<]
>>>>>                                                          ; to the kernel's base  which is where a paste site
                                                               ; always stands
                                                               ; ASSERT ptr=52
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=53
                                                               ; ASSERT zero 55:62
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=52
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=55
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=53
  [->>+<<]
>>
                                                               ; ASSERT ptr=55
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=59
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=62
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=60
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=57
  [-[[-]>>>>+<<<<]]
; ============================================================ ; ; ; ; the carry out is bit 7 of that  and nothing
                                                               ; else
>>>>
                                                               ; ASSERT ptr=61
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=55
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
                                                               ; ASSERT ptr=55
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ============================================================ ; ; ; ; the sum is twice the halves plus the two low
                                                               ; bits
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=59
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=60
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=52
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 53:53
                                                               ; ASSERT zero 55:62

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=52
<                                                              ; the carry in is nought or one  so it takes the old
  [->>+<<]                                                     ; ; kernel
>>
                                                               ; ASSERT ptr=53
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>]
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
<<<
                                                               ; ASSERT ptr=51
                                                               ; ASSERT zero 52:62

; ============================================================ ; ; ; byte 14
<<<<<<<<<<<<<<<<<<<<                                           ; the accumulator byte steps into the adder
                                                               ; ASSERT ptr=31
  [->>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>>>+<<<<<]
>>>>                                                           ; to the kernel's base  which is where a paste site
                                                               ; always stands
                                                               ; ASSERT ptr=52
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=53
                                                               ; ASSERT zero 55:62
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=52
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=55
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=53
  [->>+<<]
>>
                                                               ; ASSERT ptr=55
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=59
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=62
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=60
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=57
  [-[[-]>>>>+<<<<]]
; ============================================================ ; ; ; ; the carry out is bit 7 of that  and nothing
                                                               ; else
>>>>
                                                               ; ASSERT ptr=61
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=55
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
                                                               ; ASSERT ptr=55
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ============================================================ ; ; ; ; the sum is twice the halves plus the two low
                                                               ; bits
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=59
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=60
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=52
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 53:53
                                                               ; ASSERT zero 55:62

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=52
<                                                              ; the carry in is nought or one  so it takes the old
  [->>+<<]                                                     ; ; kernel
>>
                                                               ; ASSERT ptr=53
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>]
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
<<<
                                                               ; ASSERT ptr=51
                                                               ; ASSERT zero 52:62

; ============================================================ ; ; ; byte 15
<<<<<<<<<<<<<<<<<<<                                            ; the accumulator byte steps into the adder
                                                               ; ASSERT ptr=32
  [->>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>>+<<<<]
>>>                                                            ; to the kernel's base  which is where a paste site
                                                               ; always stands
                                                               ; ASSERT ptr=52
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=53
                                                               ; ASSERT zero 55:62
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=52
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=55
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=53
  [->>+<<]
>>
                                                               ; ASSERT ptr=55
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=59
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=62
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=60
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=57
  [-[[-]>>>>+<<<<]]
; ============================================================ ; ; ; ; the carry out is bit 7 of that  and nothing
                                                               ; else
>>>>
                                                               ; ASSERT ptr=61
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=55
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
                                                               ; ASSERT ptr=55
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ============================================================ ; ; ; ; the sum is twice the halves plus the two low
                                                               ; bits
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=59
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=60
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=52
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 53:53
                                                               ; ASSERT zero 55:62

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=52
<                                                              ; the carry in is nought or one  so it takes the old
  [->>+<<]                                                     ; ; kernel
>>
                                                               ; ASSERT ptr=53
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>]
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
<<<
                                                               ; ASSERT ptr=51
                                                               ; ASSERT zero 52:62

; ============================================================ ; ; ; byte 16
<<<<<<<<<<<<<<<<<<                                             ; the accumulator byte steps into the adder
                                                               ; ASSERT ptr=33
  [->>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>+<<<]
>>                                                             ; to the kernel's base  which is where a paste site
                                                               ; always stands
                                                               ; ASSERT ptr=52
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=53
                                                               ; ASSERT zero 55:62
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=52
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=55
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=53
  [->>+<<]
>>
                                                               ; ASSERT ptr=55
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=59
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=62
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=60
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=57
  [-[[-]>>>>+<<<<]]
; ============================================================ ; ; ; ; the carry out is bit 7 of that  and nothing
                                                               ; else
>>>>
                                                               ; ASSERT ptr=61
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=55
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
                                                               ; ASSERT ptr=55
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ============================================================ ; ; ; ; the sum is twice the halves plus the two low
                                                               ; bits
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=59
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=60
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=52
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 53:53
                                                               ; ASSERT zero 55:62

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=52
<                                                              ; the carry in is nought or one  so it takes the old
  [->>+<<]                                                     ; ; kernel
>>
                                                               ; ASSERT ptr=53
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>]
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
<<<
                                                               ; ASSERT ptr=51
                                                               ; ASSERT zero 52:62

                                                               ; the carry out of the top byte is dropped  and cleared
                                                               ; so the frame is as empty as it was found
                                                               ; ASSERT ptr=51
  [-]
                                                               ; ASSERT zero 34:62

  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<                           ; walk back out to the routine base
                                                               ; ASSERT ptr=17
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; back to the bit  which is nought now  so this arm is
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; done
  >>>                                                          ; continued
]
                                                               ; ASSERT ptr=138
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; to the running double  which doubles whether the bit
  <<<<<<<<<<                                                   ; was set or not
                                                               ; ASSERT ptr=68
                                                               ; ASSERT zero 85:92
  >>>>>>>>>>>>>>>>                                             ; walk in to this routine entry offset
                                                               ; ASSERT ptr=84
                                                               ; ASSERT zero 85:92
<<<<<<<<<<<<<<<<                                               ; to the bottom of the value  which is where a shift
                                                               ; left starts

; ============================================================ ; ; ; byte 0
                                                               ; ASSERT ptr=68
  [->>>>>>>>>>>>>>>>>+>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<]          ; the byte is taken twice: once to be doubled and once
                                                               ; to give up its top bit
>>>>>>>>>>>>>>>>>>>>>>>                                        ; to the copy that will be doubled
                                                               ; ASSERT ptr=91
  [-<<++>>]                                                    ; doubling wraps modulo 256 by itself  and that wrap IS
                                                               ; the low byte wanted
>                                                              ; seven turns of halving leave nothing but the top bit
  +++++++
[
  -
<<<<<<<                                                        ; to the value
                                                               ; ASSERT ptr=85
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>                                                             ; the bit that falls off is not wanted here
  [-]
<                                                              ; the half becomes the value for the next turn
  [-<+>]
>>>>>>                                                         ; back to the turn counter
]
                                                               ; ASSERT ptr=92
<<<                                                            ; the doubled byte goes back where it came from
                                                               ; ASSERT ptr=89
  [-<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>]
                                                               ; byte nought receives no carry: nothing is below it
                                                               ; and the frame is clear on entry  so this step could
                                                               ; never have run
<<<<
                                                               ; this byte top bit is what goes up to the byte above
                                                               ; ASSERT ptr=85
  [->>>>>+<<<<<]
<<<<<<<<<<<<<<<<                                               ; to the byte above

; ============================================================ ; ; ; byte 1
                                                               ; ASSERT ptr=69
  [->>>>>>>>>>>>>>>>+>>>>>>+<<<<<<<<<<<<<<<<<<<<<<]            ; the byte is taken twice: once to be doubled and once
                                                               ; to give up its top bit
>>>>>>>>>>>>>>>>>>>>>>                                         ; to the copy that will be doubled
                                                               ; ASSERT ptr=91
  [-<<++>>]                                                    ; doubling wraps modulo 256 by itself  and that wrap IS
                                                               ; the low byte wanted
>                                                              ; seven turns of halving leave nothing but the top bit
  +++++++
[
  -
<<<<<<<                                                        ; to the value
                                                               ; ASSERT ptr=85
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>                                                             ; the bit that falls off is not wanted here
  [-]
<                                                              ; the half becomes the value for the next turn
  [-<+>]
>>>>>>                                                         ; back to the turn counter
]
                                                               ; ASSERT ptr=92
<<<                                                            ; the doubled byte goes back where it came from
                                                               ; ASSERT ptr=89
  [-<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>]
>                                                              ; and the bit that came up from the byte below is added
  [-<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>]               ; ; to it
<<<<<                                                          ; this byte top bit is what goes up to the byte above
                                                               ; ASSERT ptr=85
  [->>>>>+<<<<<]
<<<<<<<<<<<<<<<                                                ; to the byte above

; ============================================================ ; ; ; byte 2
                                                               ; ASSERT ptr=70
  [->>>>>>>>>>>>>>>+>>>>>>+<<<<<<<<<<<<<<<<<<<<<]              ; the byte is taken twice: once to be doubled and once
                                                               ; to give up its top bit
>>>>>>>>>>>>>>>>>>>>>                                          ; to the copy that will be doubled
                                                               ; ASSERT ptr=91
  [-<<++>>]                                                    ; doubling wraps modulo 256 by itself  and that wrap IS
                                                               ; the low byte wanted
>                                                              ; seven turns of halving leave nothing but the top bit
  +++++++
[
  -
<<<<<<<                                                        ; to the value
                                                               ; ASSERT ptr=85
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>                                                             ; the bit that falls off is not wanted here
  [-]
<                                                              ; the half becomes the value for the next turn
  [-<+>]
>>>>>>                                                         ; back to the turn counter
]
                                                               ; ASSERT ptr=92
<<<                                                            ; the doubled byte goes back where it came from
                                                               ; ASSERT ptr=89
  [-<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>]
>                                                              ; and the bit that came up from the byte below is added
  [-<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>]                 ; ; to it
<<<<<                                                          ; this byte top bit is what goes up to the byte above
                                                               ; ASSERT ptr=85
  [->>>>>+<<<<<]
<<<<<<<<<<<<<<                                                 ; to the byte above

; ============================================================ ; ; ; byte 3
                                                               ; ASSERT ptr=71
  [->>>>>>>>>>>>>>+>>>>>>+<<<<<<<<<<<<<<<<<<<<]                ; the byte is taken twice: once to be doubled and once
                                                               ; to give up its top bit
>>>>>>>>>>>>>>>>>>>>                                           ; to the copy that will be doubled
                                                               ; ASSERT ptr=91
  [-<<++>>]                                                    ; doubling wraps modulo 256 by itself  and that wrap IS
                                                               ; the low byte wanted
>                                                              ; seven turns of halving leave nothing but the top bit
  +++++++
[
  -
<<<<<<<                                                        ; to the value
                                                               ; ASSERT ptr=85
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>                                                             ; the bit that falls off is not wanted here
  [-]
<                                                              ; the half becomes the value for the next turn
  [-<+>]
>>>>>>                                                         ; back to the turn counter
]
                                                               ; ASSERT ptr=92
<<<                                                            ; the doubled byte goes back where it came from
                                                               ; ASSERT ptr=89
  [-<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>]
>                                                              ; and the bit that came up from the byte below is added
  [-<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>]                   ; ; to it
<<<<<                                                          ; this byte top bit is what goes up to the byte above
                                                               ; ASSERT ptr=85
  [->>>>>+<<<<<]
<<<<<<<<<<<<<                                                  ; to the byte above

; ============================================================ ; ; ; byte 4
                                                               ; ASSERT ptr=72
  [->>>>>>>>>>>>>+>>>>>>+<<<<<<<<<<<<<<<<<<<]                  ; the byte is taken twice: once to be doubled and once
                                                               ; to give up its top bit
>>>>>>>>>>>>>>>>>>>                                            ; to the copy that will be doubled
                                                               ; ASSERT ptr=91
  [-<<++>>]                                                    ; doubling wraps modulo 256 by itself  and that wrap IS
                                                               ; the low byte wanted
>                                                              ; seven turns of halving leave nothing but the top bit
  +++++++
[
  -
<<<<<<<                                                        ; to the value
                                                               ; ASSERT ptr=85
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>                                                             ; the bit that falls off is not wanted here
  [-]
<                                                              ; the half becomes the value for the next turn
  [-<+>]
>>>>>>                                                         ; back to the turn counter
]
                                                               ; ASSERT ptr=92
<<<                                                            ; the doubled byte goes back where it came from
                                                               ; ASSERT ptr=89
  [-<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>]
>                                                              ; and the bit that came up from the byte below is added
  [-<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>]                     ; ; to it
<<<<<                                                          ; this byte top bit is what goes up to the byte above
                                                               ; ASSERT ptr=85
  [->>>>>+<<<<<]
<<<<<<<<<<<<                                                   ; to the byte above

; ============================================================ ; ; ; byte 5
                                                               ; ASSERT ptr=73
  [->>>>>>>>>>>>+>>>>>>+<<<<<<<<<<<<<<<<<<]                    ; the byte is taken twice: once to be doubled and once
                                                               ; to give up its top bit
>>>>>>>>>>>>>>>>>>                                             ; to the copy that will be doubled
                                                               ; ASSERT ptr=91
  [-<<++>>]                                                    ; doubling wraps modulo 256 by itself  and that wrap IS
                                                               ; the low byte wanted
>                                                              ; seven turns of halving leave nothing but the top bit
  +++++++
[
  -
<<<<<<<                                                        ; to the value
                                                               ; ASSERT ptr=85
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>                                                             ; the bit that falls off is not wanted here
  [-]
<                                                              ; the half becomes the value for the next turn
  [-<+>]
>>>>>>                                                         ; back to the turn counter
]
                                                               ; ASSERT ptr=92
<<<                                                            ; the doubled byte goes back where it came from
                                                               ; ASSERT ptr=89
  [-<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>]
>                                                              ; and the bit that came up from the byte below is added
  [-<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>]                       ; ; to it
<<<<<                                                          ; this byte top bit is what goes up to the byte above
                                                               ; ASSERT ptr=85
  [->>>>>+<<<<<]
<<<<<<<<<<<                                                    ; to the byte above

; ============================================================ ; ; ; byte 6
                                                               ; ASSERT ptr=74
  [->>>>>>>>>>>+>>>>>>+<<<<<<<<<<<<<<<<<]                      ; the byte is taken twice: once to be doubled and once
                                                               ; to give up its top bit
>>>>>>>>>>>>>>>>>                                              ; to the copy that will be doubled
                                                               ; ASSERT ptr=91
  [-<<++>>]                                                    ; doubling wraps modulo 256 by itself  and that wrap IS
                                                               ; the low byte wanted
>                                                              ; seven turns of halving leave nothing but the top bit
  +++++++
[
  -
<<<<<<<                                                        ; to the value
                                                               ; ASSERT ptr=85
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>                                                             ; the bit that falls off is not wanted here
  [-]
<                                                              ; the half becomes the value for the next turn
  [-<+>]
>>>>>>                                                         ; back to the turn counter
]
                                                               ; ASSERT ptr=92
<<<                                                            ; the doubled byte goes back where it came from
                                                               ; ASSERT ptr=89
  [-<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>]
>                                                              ; and the bit that came up from the byte below is added
  [-<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>]                         ; ; to it
<<<<<                                                          ; this byte top bit is what goes up to the byte above
                                                               ; ASSERT ptr=85
  [->>>>>+<<<<<]
<<<<<<<<<<                                                     ; to the byte above

; ============================================================ ; ; ; byte 7
                                                               ; ASSERT ptr=75
  [->>>>>>>>>>+>>>>>>+<<<<<<<<<<<<<<<<]                        ; the byte is taken twice: once to be doubled and once
                                                               ; to give up its top bit
>>>>>>>>>>>>>>>>                                               ; to the copy that will be doubled
                                                               ; ASSERT ptr=91
  [-<<++>>]                                                    ; doubling wraps modulo 256 by itself  and that wrap IS
                                                               ; the low byte wanted
>                                                              ; seven turns of halving leave nothing but the top bit
  +++++++
[
  -
<<<<<<<                                                        ; to the value
                                                               ; ASSERT ptr=85
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>                                                             ; the bit that falls off is not wanted here
  [-]
<                                                              ; the half becomes the value for the next turn
  [-<+>]
>>>>>>                                                         ; back to the turn counter
]
                                                               ; ASSERT ptr=92
<<<                                                            ; the doubled byte goes back where it came from
                                                               ; ASSERT ptr=89
  [-<<<<<<<<<<<<<<+>>>>>>>>>>>>>>]
>                                                              ; and the bit that came up from the byte below is added
  [-<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>]                           ; ; to it
<<<<<                                                          ; this byte top bit is what goes up to the byte above
                                                               ; ASSERT ptr=85
  [->>>>>+<<<<<]
<<<<<<<<<                                                      ; to the byte above

; ============================================================ ; ; ; byte 8
                                                               ; ASSERT ptr=76
  [->>>>>>>>>+>>>>>>+<<<<<<<<<<<<<<<]                          ; the byte is taken twice: once to be doubled and once
                                                               ; to give up its top bit
>>>>>>>>>>>>>>>                                                ; to the copy that will be doubled
                                                               ; ASSERT ptr=91
  [-<<++>>]                                                    ; doubling wraps modulo 256 by itself  and that wrap IS
                                                               ; the low byte wanted
>                                                              ; seven turns of halving leave nothing but the top bit
  +++++++
[
  -
<<<<<<<                                                        ; to the value
                                                               ; ASSERT ptr=85
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>                                                             ; the bit that falls off is not wanted here
  [-]
<                                                              ; the half becomes the value for the next turn
  [-<+>]
>>>>>>                                                         ; back to the turn counter
]
                                                               ; ASSERT ptr=92
<<<                                                            ; the doubled byte goes back where it came from
                                                               ; ASSERT ptr=89
  [-<<<<<<<<<<<<<+>>>>>>>>>>>>>]
>                                                              ; and the bit that came up from the byte below is added
  [-<<<<<<<<<<<<<<+>>>>>>>>>>>>>>]                             ; ; to it
<<<<<                                                          ; this byte top bit is what goes up to the byte above
                                                               ; ASSERT ptr=85
  [->>>>>+<<<<<]
<<<<<<<<                                                       ; to the byte above

; ============================================================ ; ; ; byte 9
                                                               ; ASSERT ptr=77
  [->>>>>>>>+>>>>>>+<<<<<<<<<<<<<<]                            ; the byte is taken twice: once to be doubled and once
                                                               ; to give up its top bit
>>>>>>>>>>>>>>                                                 ; to the copy that will be doubled
                                                               ; ASSERT ptr=91
  [-<<++>>]                                                    ; doubling wraps modulo 256 by itself  and that wrap IS
                                                               ; the low byte wanted
>                                                              ; seven turns of halving leave nothing but the top bit
  +++++++
[
  -
<<<<<<<                                                        ; to the value
                                                               ; ASSERT ptr=85
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>                                                             ; the bit that falls off is not wanted here
  [-]
<                                                              ; the half becomes the value for the next turn
  [-<+>]
>>>>>>                                                         ; back to the turn counter
]
                                                               ; ASSERT ptr=92
<<<                                                            ; the doubled byte goes back where it came from
                                                               ; ASSERT ptr=89
  [-<<<<<<<<<<<<+>>>>>>>>>>>>]
>                                                              ; and the bit that came up from the byte below is added
  [-<<<<<<<<<<<<<+>>>>>>>>>>>>>]                               ; ; to it
<<<<<                                                          ; this byte top bit is what goes up to the byte above
                                                               ; ASSERT ptr=85
  [->>>>>+<<<<<]
<<<<<<<                                                        ; to the byte above

; ============================================================ ; ; ; byte 10
                                                               ; ASSERT ptr=78
  [->>>>>>>+>>>>>>+<<<<<<<<<<<<<]                              ; the byte is taken twice: once to be doubled and once
                                                               ; to give up its top bit
>>>>>>>>>>>>>                                                  ; to the copy that will be doubled
                                                               ; ASSERT ptr=91
  [-<<++>>]                                                    ; doubling wraps modulo 256 by itself  and that wrap IS
                                                               ; the low byte wanted
>                                                              ; seven turns of halving leave nothing but the top bit
  +++++++
[
  -
<<<<<<<                                                        ; to the value
                                                               ; ASSERT ptr=85
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>                                                             ; the bit that falls off is not wanted here
  [-]
<                                                              ; the half becomes the value for the next turn
  [-<+>]
>>>>>>                                                         ; back to the turn counter
]
                                                               ; ASSERT ptr=92
<<<                                                            ; the doubled byte goes back where it came from
                                                               ; ASSERT ptr=89
  [-<<<<<<<<<<<+>>>>>>>>>>>]
>                                                              ; and the bit that came up from the byte below is added
  [-<<<<<<<<<<<<+>>>>>>>>>>>>]                                 ; ; to it
<<<<<                                                          ; this byte top bit is what goes up to the byte above
                                                               ; ASSERT ptr=85
  [->>>>>+<<<<<]
<<<<<<                                                         ; to the byte above

; ============================================================ ; ; ; byte 11
                                                               ; ASSERT ptr=79
  [->>>>>>+>>>>>>+<<<<<<<<<<<<]                                ; the byte is taken twice: once to be doubled and once
                                                               ; to give up its top bit
>>>>>>>>>>>>                                                   ; to the copy that will be doubled
                                                               ; ASSERT ptr=91
  [-<<++>>]                                                    ; doubling wraps modulo 256 by itself  and that wrap IS
                                                               ; the low byte wanted
>                                                              ; seven turns of halving leave nothing but the top bit
  +++++++
[
  -
<<<<<<<                                                        ; to the value
                                                               ; ASSERT ptr=85
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>                                                             ; the bit that falls off is not wanted here
  [-]
<                                                              ; the half becomes the value for the next turn
  [-<+>]
>>>>>>                                                         ; back to the turn counter
]
                                                               ; ASSERT ptr=92
<<<                                                            ; the doubled byte goes back where it came from
                                                               ; ASSERT ptr=89
  [-<<<<<<<<<<+>>>>>>>>>>]
>                                                              ; and the bit that came up from the byte below is added
  [-<<<<<<<<<<<+>>>>>>>>>>>]                                   ; ; to it
<<<<<                                                          ; this byte top bit is what goes up to the byte above
                                                               ; ASSERT ptr=85
  [->>>>>+<<<<<]
<<<<<                                                          ; to the byte above

; ============================================================ ; ; ; byte 12
                                                               ; ASSERT ptr=80
  [->>>>>+>>>>>>+<<<<<<<<<<<]                                  ; the byte is taken twice: once to be doubled and once
                                                               ; to give up its top bit
>>>>>>>>>>>                                                    ; to the copy that will be doubled
                                                               ; ASSERT ptr=91
  [-<<++>>]                                                    ; doubling wraps modulo 256 by itself  and that wrap IS
                                                               ; the low byte wanted
>                                                              ; seven turns of halving leave nothing but the top bit
  +++++++
[
  -
<<<<<<<                                                        ; to the value
                                                               ; ASSERT ptr=85
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>                                                             ; the bit that falls off is not wanted here
  [-]
<                                                              ; the half becomes the value for the next turn
  [-<+>]
>>>>>>                                                         ; back to the turn counter
]
                                                               ; ASSERT ptr=92
<<<                                                            ; the doubled byte goes back where it came from
                                                               ; ASSERT ptr=89
  [-<<<<<<<<<+>>>>>>>>>]
>                                                              ; and the bit that came up from the byte below is added
  [-<<<<<<<<<<+>>>>>>>>>>]                                     ; ; to it
<<<<<                                                          ; this byte top bit is what goes up to the byte above
                                                               ; ASSERT ptr=85
  [->>>>>+<<<<<]
<<<<                                                           ; to the byte above

; ============================================================ ; ; ; byte 13
                                                               ; ASSERT ptr=81
  [->>>>+>>>>>>+<<<<<<<<<<]                                    ; the byte is taken twice: once to be doubled and once
                                                               ; to give up its top bit
>>>>>>>>>>                                                     ; to the copy that will be doubled
                                                               ; ASSERT ptr=91
  [-<<++>>]                                                    ; doubling wraps modulo 256 by itself  and that wrap IS
                                                               ; the low byte wanted
>                                                              ; seven turns of halving leave nothing but the top bit
  +++++++
[
  -
<<<<<<<                                                        ; to the value
                                                               ; ASSERT ptr=85
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>                                                             ; the bit that falls off is not wanted here
  [-]
<                                                              ; the half becomes the value for the next turn
  [-<+>]
>>>>>>                                                         ; back to the turn counter
]
                                                               ; ASSERT ptr=92
<<<                                                            ; the doubled byte goes back where it came from
                                                               ; ASSERT ptr=89
  [-<<<<<<<<+>>>>>>>>]
>                                                              ; and the bit that came up from the byte below is added
  [-<<<<<<<<<+>>>>>>>>>]                                       ; ; to it
<<<<<                                                          ; this byte top bit is what goes up to the byte above
                                                               ; ASSERT ptr=85
  [->>>>>+<<<<<]
<<<                                                            ; to the byte above

; ============================================================ ; ; ; byte 14
                                                               ; ASSERT ptr=82
  [->>>+>>>>>>+<<<<<<<<<]                                      ; the byte is taken twice: once to be doubled and once
                                                               ; to give up its top bit
>>>>>>>>>                                                      ; to the copy that will be doubled
                                                               ; ASSERT ptr=91
  [-<<++>>]                                                    ; doubling wraps modulo 256 by itself  and that wrap IS
                                                               ; the low byte wanted
>                                                              ; seven turns of halving leave nothing but the top bit
  +++++++
[
  -
<<<<<<<                                                        ; to the value
                                                               ; ASSERT ptr=85
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>                                                             ; the bit that falls off is not wanted here
  [-]
<                                                              ; the half becomes the value for the next turn
  [-<+>]
>>>>>>                                                         ; back to the turn counter
]
                                                               ; ASSERT ptr=92
<<<                                                            ; the doubled byte goes back where it came from
                                                               ; ASSERT ptr=89
  [-<<<<<<<+>>>>>>>]
>                                                              ; and the bit that came up from the byte below is added
  [-<<<<<<<<+>>>>>>>>]                                         ; ; to it
<<<<<                                                          ; this byte top bit is what goes up to the byte above
                                                               ; ASSERT ptr=85
  [->>>>>+<<<<<]
<<                                                             ; to the byte above

; ============================================================ ; ; ; byte 15
                                                               ; ASSERT ptr=83
  [->>+>>>>>>+<<<<<<<<]                                        ; the byte is taken twice: once to be doubled and once
                                                               ; to give up its top bit
>>>>>>>>                                                       ; to the copy that will be doubled
                                                               ; ASSERT ptr=91
  [-<<++>>]                                                    ; doubling wraps modulo 256 by itself  and that wrap IS
                                                               ; the low byte wanted
>                                                              ; seven turns of halving leave nothing but the top bit
  +++++++
[
  -
<<<<<<<                                                        ; to the value
                                                               ; ASSERT ptr=85
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>                                                             ; the bit that falls off is not wanted here
  [-]
<                                                              ; the half becomes the value for the next turn
  [-<+>]
>>>>>>                                                         ; back to the turn counter
]
                                                               ; ASSERT ptr=92
<<<                                                            ; the doubled byte goes back where it came from
                                                               ; ASSERT ptr=89
  [-<<<<<<+>>>>>>]
>                                                              ; and the bit that came up from the byte below is added
  [-<<<<<<<+>>>>>>>]                                           ; ; to it
<<<<<                                                          ; this byte top bit is what goes up to the byte above
                                                               ; ASSERT ptr=85
  [->>>>>+<<<<<]
<                                                              ; to the byte above

; ============================================================ ; ; ; byte 16
                                                               ; ASSERT ptr=84
  [->+>>>>>>+<<<<<<<]                                          ; the byte is taken twice: once to be doubled and once
                                                               ; to give up its top bit
>>>>>>>                                                        ; to the copy that will be doubled
                                                               ; ASSERT ptr=91
  [-<<++>>]                                                    ; doubling wraps modulo 256 by itself  and that wrap IS
                                                               ; the low byte wanted
>                                                              ; seven turns of halving leave nothing but the top bit
  +++++++
[
  -
<<<<<<<                                                        ; to the value
                                                               ; ASSERT ptr=85
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>                                                             ; the bit that falls off is not wanted here
  [-]
<                                                              ; the half becomes the value for the next turn
  [-<+>]
>>>>>>                                                         ; back to the turn counter
]
                                                               ; ASSERT ptr=92
<<<                                                            ; the doubled byte goes back where it came from
                                                               ; ASSERT ptr=89
  [-<<<<<+>>>>>]
>                                                              ; and the bit that came up from the byte below is added
  [-<<<<<<+>>>>>>]                                             ; ; to it
<<<<<                                                          ; this byte top bit is what goes up to the byte above
                                                               ; ASSERT ptr=85
  [->>>>>+<<<<<]

>>>>>                                                          ; the bit shifted out of the top byte is discarded
                                                               ; ASSERT ptr=90
  [-]
<<<<<<<<<<<<<<<<<<<<<<                                         ; back to the head of the value
                                                               ; ASSERT ptr=68
                                                               ; ASSERT zero 85:92
                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=68
                                                               ; ASSERT zero 85:118
  >>>>>>>>>>>>>>>>                                             ; walk in to this routine entry offset

; ============================================================ ; ; ; split the top byte at bit 130
                                                               ; ASSERT ptr=84
                                                               ; ASSERT zero 85:102
  [->>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<]                           ; the top byte steps into the halving frame
>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=99
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; the first halving; the bit it drops is bit 128
>>                                                             ; which is worth one in what is left below the split
                                                               ; ASSERT ptr=101
  [-<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>]
<                                                              ; the half steps back into the frame to be halved again
                                                               ; ASSERT ptr=100
  [-<+>]
<
                                                               ; ASSERT ptr=99
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; the second halving; the bit it drops is bit 129
>>                                                             ; which is worth two
                                                               ; ASSERT ptr=101
  [-<<<<<<<<<<<<<<<<<++>>>>>>>>>>>>>>>>>]
<                                                              ; and what is left in the quotient is everything at bit
                                                               ; 130 and above
                                                               ; ASSERT ptr=100
  [-<<+>>]

; ============================================================ ; ; ; two to the hundred and thirtieth is five  so five
                                                               ; times that part
<<                                                             ; to the part above the split
                                                               ; ASSERT ptr=98
                                                               ; it is spent ONCE  into four copies of itself and one
                                                               ; copy of itself  which is where the five comes from;
                                                               ; neither cell can wrap  because four times sixty three
                                                               ; is two hundred and fifty two
  [-<<<<<<<<<<<<<++++>+>>>>>>>>>>>>]
                                                               ; ASSERT ptr=98
<<<<<<<<<<<<<                                                  ; to the byte pair the eight bit adder works on
                                                               ; ASSERT ptr=85
                                                               ; ASSERT zero 87:95
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=86
                                                               ; ASSERT zero 88:95
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=85
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=88
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=86
  [->>+<<]
>>
                                                               ; ASSERT ptr=88
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=92
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=95
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=93
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=90
  [-[[-]>>>>+<<<<]]
; ============================================================ ; ; ; ; the carry out is bit 7 of that  and nothing
                                                               ; else
>>>>
                                                               ; ASSERT ptr=94
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=88
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
                                                               ; ASSERT ptr=88
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ============================================================ ; ; ; ; the sum is twice the halves plus the two low
                                                               ; bits
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=92
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=93
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=85
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 86:86
                                                               ; ASSERT zero 88:95

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=85
  [->>>>>>>>>>>+<<<<<<<<<<<]                                   ; the sum is five times H modulo 256  and it is the
                                                               ; addend's low byte
>>                                                             ; to the carry add8 computed
                                                               ; ASSERT ptr=87
  [->>>>>>>>>>+<<<<<<<<<<]                                     ; which is the addend's high byte  worth two hundred
                                                               ; and fifty six

; ============================================================ ; ; ; the bottom byte of the value takes the low byte
                                                               ; of
<<<<<<<<<<<<<<<<<<<                                            ; ; five times H
                                                               ; ASSERT ptr=68
  [->>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=96
  [-<<<<<<<<<<+>>>>>>>>>>]
<<<<<<<<<<<
                                                               ; ASSERT ptr=85
                                                               ; ASSERT zero 87:95
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=86
                                                               ; ASSERT zero 88:95
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=85
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=88
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=86
  [->>+<<]
>>
                                                               ; ASSERT ptr=88
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=92
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=95
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=93
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=90
  [-[[-]>>>>+<<<<]]
; ============================================================ ; ; ; ; the carry out is bit 7 of that  and nothing
                                                               ; else
>>>>
                                                               ; ASSERT ptr=94
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=88
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
                                                               ; ASSERT ptr=88
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ============================================================ ; ; ; ; the sum is twice the halves plus the two low
                                                               ; bits
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=92
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=93
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=85
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 86:86
                                                               ; ASSERT zero 88:95

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=85
  [-<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>]                       ; the sum goes home and the carry stays where add8 left
                                                               ; it

; ============================================================ ; ; ; the second byte takes the high byte  and that
                                                               ; carry
<<<<<<<<<<<<<<<<                                               ; ; with it
                                                               ; ASSERT ptr=69
  [->>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=97
  [-<<<<<<<<<<<+>>>>>>>>>>>]
<<<<<<<<<<
                                                               ; ASSERT ptr=87
  [-<+>]
<<
                                                               ; ASSERT ptr=85
                                                               ; ASSERT zero 87:95
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=86
                                                               ; ASSERT zero 88:95
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=85
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=88
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=86
  [->>+<<]
>>
                                                               ; ASSERT ptr=88
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=92
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=95
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=93
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=90
  [-[[-]>>>>+<<<<]]
; ============================================================ ; ; ; ; the carry out is bit 7 of that  and nothing
                                                               ; else
>>>>
                                                               ; ASSERT ptr=94
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=88
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
                                                               ; ASSERT ptr=88
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ============================================================ ; ; ; ; the sum is twice the halves plus the two low
                                                               ; bits
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=92
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=93
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=85
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 86:86
                                                               ; ASSERT zero 88:95

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=85
  [-<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>]
>>
                                                               ; ASSERT ptr=87

; ============================================================ ; ; ; and the carry out of that ripples up through the
                                                               ; rest

[                                                              ; ____ byte 2 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=96
  [-]+
<<<<<<<<<<<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=70
  +
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<]                                                          ; continued
>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=98
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >]                                                           ; continued
<
                                                               ; ASSERT ptr=97
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=87
]
                                                               ; ASSERT ptr=87
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=96
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=87

[                                                              ; ____ byte 3 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=96
  [-]+
<<<<<<<<<<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=71
  +
  [->>>>>>>>>>>>>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]                                                            ; continued
>>>>>>>>>>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=98
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=97
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=87
]
                                                               ; ASSERT ptr=87
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=96
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=87

[                                                              ; ____ byte 4 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=96
  [-]+
<<<<<<<<<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=72
  +
  [->>>>>>>>>>>>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=98
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=97
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=87
]
                                                               ; ASSERT ptr=87
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=96
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=87

[                                                              ; ____ byte 5 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=96
  [-]+
<<<<<<<<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=73
  +
  [->>>>>>>>>>>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=98
  [-<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=97
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=87
]
                                                               ; ASSERT ptr=87
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=96
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=87

[                                                              ; ____ byte 6 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=96
  [-]+
<<<<<<<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=74
  +
  [->>>>>>>>>>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=98
  [-<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=97
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=87
]
                                                               ; ASSERT ptr=87
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=96
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=87

[                                                              ; ____ byte 7 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=96
  [-]+
<<<<<<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=75
  +
  [->>>>>>>>>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=98
  [-<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=97
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=87
]
                                                               ; ASSERT ptr=87
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=96
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=87

[                                                              ; ____ byte 8 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=96
  [-]+
<<<<<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=76
  +
  [->>>>>>>>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=98
  [-<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=97
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=87
]
                                                               ; ASSERT ptr=87
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=96
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=87

[                                                              ; ____ byte 9 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=96
  [-]+
<<<<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=77
  +
  [->>>>>>>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=98
  [-<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=97
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=87
]
                                                               ; ASSERT ptr=87
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=96
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=87

[                                                              ; ____ byte 10 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=96
  [-]+
<<<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=78
  +
  [->>>>>>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=98
  [-<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=97
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=87
]
                                                               ; ASSERT ptr=87
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=96
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=87

[                                                              ; ____ byte 11 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=96
  [-]+
<<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=79
  +
  [->>>>>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=98
  [-<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=97
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=87
]
                                                               ; ASSERT ptr=87
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=96
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=87

[                                                              ; ____ byte 12 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=96
  [-]+
<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=80
  +
  [->>>>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=98
  [-<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=97
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=87
]
                                                               ; ASSERT ptr=87
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=96
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=87

[                                                              ; ____ byte 13 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=96
  [-]+
<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=81
  +
  [->>>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=98
  [-<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=97
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=87
]
                                                               ; ASSERT ptr=87
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=96
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=87

[                                                              ; ____ byte 14 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=96
  [-]+
<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=82
  +
  [->>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=98
  [-<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=97
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=87
]
                                                               ; ASSERT ptr=87
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=96
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=87

[                                                              ; ____ byte 15 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=96
  [-]+
<<<<<<<<<<<<<
                                                               ; ASSERT ptr=83
  +
  [->>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=98
  [-<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=97
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=87
]
                                                               ; ASSERT ptr=87
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=96
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=87

[                                                              ; ____ byte 16  which does not look  because its carry
  [-]                                                          ; ; cannot happen ____
<<<
                                                               ; ASSERT ptr=84
  +
>>>
                                                               ; ASSERT ptr=87
]
                                                               ; ASSERT ptr=87

; ============================================================ ; ; ; the value is folded
<<<<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=68
                                                               ; ASSERT zero 85:102
                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=68
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; back to the bit counter
  >>>>>>>>>>>>                                                 ; continued
]
                                                               ; ASSERT ptr=140
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; the byte is spent  so the answer is folded once for
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; the eight adds it took
  <<<<<                                                        ; continued
                                                               ; ASSERT ptr=17
                                                               ; ASSERT zero 34:67
  >>>>>>>>>>>>>>>>                                             ; walk in to this routine entry offset

; ============================================================ ; ; ; split the top byte at bit 130
                                                               ; ASSERT ptr=33
                                                               ; ASSERT zero 34:51
  [->>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<]                           ; the top byte steps into the halving frame
>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=48
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; the first halving; the bit it drops is bit 128
>>                                                             ; which is worth one in what is left below the split
                                                               ; ASSERT ptr=50
  [-<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>]
<                                                              ; the half steps back into the frame to be halved again
                                                               ; ASSERT ptr=49
  [-<+>]
<
                                                               ; ASSERT ptr=48
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; the second halving; the bit it drops is bit 129
>>                                                             ; which is worth two
                                                               ; ASSERT ptr=50
  [-<<<<<<<<<<<<<<<<<++>>>>>>>>>>>>>>>>>]
<                                                              ; and what is left in the quotient is everything at bit
                                                               ; 130 and above
                                                               ; ASSERT ptr=49
  [-<<+>>]

; ============================================================ ; ; ; two to the hundred and thirtieth is five  so five
                                                               ; times that part
<<                                                             ; to the part above the split
                                                               ; ASSERT ptr=47
                                                               ; it is spent ONCE  into four copies of itself and one
                                                               ; copy of itself  which is where the five comes from;
                                                               ; neither cell can wrap  because four times sixty three
                                                               ; is two hundred and fifty two
  [-<<<<<<<<<<<<<++++>+>>>>>>>>>>>>]
                                                               ; ASSERT ptr=47
<<<<<<<<<<<<<                                                  ; to the byte pair the eight bit adder works on
                                                               ; ASSERT ptr=34
                                                               ; ASSERT zero 36:44
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=35
                                                               ; ASSERT zero 37:44
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=34
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=37
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=35
  [->>+<<]
>>
                                                               ; ASSERT ptr=37
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=41
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=44
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=42
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=39
  [-[[-]>>>>+<<<<]]
; ============================================================ ; ; ; ; the carry out is bit 7 of that  and nothing
                                                               ; else
>>>>
                                                               ; ASSERT ptr=43
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=37
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
                                                               ; ASSERT ptr=37
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ============================================================ ; ; ; ; the sum is twice the halves plus the two low
                                                               ; bits
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=41
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=42
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=34
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 35:35
                                                               ; ASSERT zero 37:44

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=34
  [->>>>>>>>>>>+<<<<<<<<<<<]                                   ; the sum is five times H modulo 256  and it is the
                                                               ; addend's low byte
>>                                                             ; to the carry add8 computed
                                                               ; ASSERT ptr=36
  [->>>>>>>>>>+<<<<<<<<<<]                                     ; which is the addend's high byte  worth two hundred
                                                               ; and fifty six

; ============================================================ ; ; ; the bottom byte of the value takes the low byte
                                                               ; of
<<<<<<<<<<<<<<<<<<<                                            ; ; five times H
                                                               ; ASSERT ptr=17
  [->>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=45
  [-<<<<<<<<<<+>>>>>>>>>>]
<<<<<<<<<<<
                                                               ; ASSERT ptr=34
                                                               ; ASSERT zero 36:44
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=35
                                                               ; ASSERT zero 37:44
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=34
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=37
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=35
  [->>+<<]
>>
                                                               ; ASSERT ptr=37
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=41
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=44
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=42
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=39
  [-[[-]>>>>+<<<<]]
; ============================================================ ; ; ; ; the carry out is bit 7 of that  and nothing
                                                               ; else
>>>>
                                                               ; ASSERT ptr=43
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=37
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
                                                               ; ASSERT ptr=37
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ============================================================ ; ; ; ; the sum is twice the halves plus the two low
                                                               ; bits
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=41
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=42
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=34
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 35:35
                                                               ; ASSERT zero 37:44

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=34
  [-<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>]                       ; the sum goes home and the carry stays where add8 left
                                                               ; it

; ============================================================ ; ; ; the second byte takes the high byte  and that
                                                               ; carry
<<<<<<<<<<<<<<<<                                               ; ; with it
                                                               ; ASSERT ptr=18
  [->>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=46
  [-<<<<<<<<<<<+>>>>>>>>>>>]
<<<<<<<<<<
                                                               ; ASSERT ptr=36
  [-<+>]
<<
                                                               ; ASSERT ptr=34
                                                               ; ASSERT zero 36:44
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=35
                                                               ; ASSERT zero 37:44
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=34
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=37
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=35
  [->>+<<]
>>
                                                               ; ASSERT ptr=37
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=41
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=44
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=42
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=39
  [-[[-]>>>>+<<<<]]
; ============================================================ ; ; ; ; the carry out is bit 7 of that  and nothing
                                                               ; else
>>>>
                                                               ; ASSERT ptr=43
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=37
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
                                                               ; ASSERT ptr=37
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ============================================================ ; ; ; ; the sum is twice the halves plus the two low
                                                               ; bits
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=41
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=42
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=34
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 35:35
                                                               ; ASSERT zero 37:44

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=34
  [-<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>]
>>
                                                               ; ASSERT ptr=36

; ============================================================ ; ; ; and the carry out of that ripples up through the
                                                               ; rest

[                                                              ; ____ byte 2 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=45
  [-]+
<<<<<<<<<<<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=19
  +
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<]                                                          ; continued
>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=47
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >]                                                           ; continued
<
                                                               ; ASSERT ptr=46
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=36
]
                                                               ; ASSERT ptr=36
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=45
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=36

[                                                              ; ____ byte 3 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=45
  [-]+
<<<<<<<<<<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=20
  +
  [->>>>>>>>>>>>>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]                                                            ; continued
>>>>>>>>>>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=47
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=46
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=36
]
                                                               ; ASSERT ptr=36
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=45
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=36

[                                                              ; ____ byte 4 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=45
  [-]+
<<<<<<<<<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=21
  +
  [->>>>>>>>>>>>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=47
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=46
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=36
]
                                                               ; ASSERT ptr=36
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=45
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=36

[                                                              ; ____ byte 5 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=45
  [-]+
<<<<<<<<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=22
  +
  [->>>>>>>>>>>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=47
  [-<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=46
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=36
]
                                                               ; ASSERT ptr=36
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=45
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=36

[                                                              ; ____ byte 6 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=45
  [-]+
<<<<<<<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=23
  +
  [->>>>>>>>>>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=47
  [-<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=46
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=36
]
                                                               ; ASSERT ptr=36
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=45
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=36

[                                                              ; ____ byte 7 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=45
  [-]+
<<<<<<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=24
  +
  [->>>>>>>>>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=47
  [-<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=46
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=36
]
                                                               ; ASSERT ptr=36
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=45
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=36

[                                                              ; ____ byte 8 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=45
  [-]+
<<<<<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=25
  +
  [->>>>>>>>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=47
  [-<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=46
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=36
]
                                                               ; ASSERT ptr=36
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=45
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=36

[                                                              ; ____ byte 9 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=45
  [-]+
<<<<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=26
  +
  [->>>>>>>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=47
  [-<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=46
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=36
]
                                                               ; ASSERT ptr=36
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=45
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=36

[                                                              ; ____ byte 10 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=45
  [-]+
<<<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=27
  +
  [->>>>>>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=47
  [-<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=46
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=36
]
                                                               ; ASSERT ptr=36
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=45
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=36

[                                                              ; ____ byte 11 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=45
  [-]+
<<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=28
  +
  [->>>>>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=47
  [-<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=46
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=36
]
                                                               ; ASSERT ptr=36
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=45
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=36

[                                                              ; ____ byte 12 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=45
  [-]+
<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=29
  +
  [->>>>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=47
  [-<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=46
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=36
]
                                                               ; ASSERT ptr=36
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=45
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=36

[                                                              ; ____ byte 13 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=45
  [-]+
<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=30
  +
  [->>>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=47
  [-<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=46
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=36
]
                                                               ; ASSERT ptr=36
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=45
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=36

[                                                              ; ____ byte 14 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=45
  [-]+
<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=31
  +
  [->>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=47
  [-<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=46
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=36
]
                                                               ; ASSERT ptr=36
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=45
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=36

[                                                              ; ____ byte 15 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=45
  [-]+
<<<<<<<<<<<<<
                                                               ; ASSERT ptr=32
  +
  [->>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=47
  [-<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=46
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=36
]
                                                               ; ASSERT ptr=36
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=45
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=36

[                                                              ; ____ byte 16  which does not look  because its carry
  [-]                                                          ; ; cannot happen ____
<<<
                                                               ; ASSERT ptr=33
  +
>>>
                                                               ; ASSERT ptr=36
]
                                                               ; ASSERT ptr=36

; ============================================================ ; ; ; the value is folded
<<<<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=17
                                                               ; ASSERT zero 34:51
                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=17
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; back to the byte counter
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>>                                                       ; continued
]
                                                               ; ASSERT ptr=141

; ============================================================ ; ; the running double has done its work and is emptied
                                                               ; because the
; ============================================================ ; ; reduction below is pasted over the cells it was
                                                               ; using
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<                                                ; continued
                                                               ; ASSERT ptr=68
  [-]
>                                                              ; the next byte
  [-]
>                                                              ; the next byte
  [-]
>                                                              ; the next byte
  [-]
>                                                              ; the next byte
  [-]
>                                                              ; the next byte
  [-]
>                                                              ; the next byte
  [-]
>                                                              ; the next byte
  [-]
>                                                              ; the next byte
  [-]
>                                                              ; the next byte
  [-]
>                                                              ; the next byte
  [-]
>                                                              ; the next byte
  [-]
>                                                              ; the next byte
  [-]
>                                                              ; the next byte
  [-]
>                                                              ; the next byte
  [-]
>                                                              ; the next byte
  [-]
>                                                              ; the next byte
  [-]
                                                               ; ASSERT ptr=84
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; to the answer
  <<<<<<<                                                      ; continued
                                                               ; ASSERT ptr=17
                                                               ; ASSERT zero 34:121
  >>>>>>>>>>>>>>>>                                             ; walk in to this routine entry offset
                                                               ; ASSERT ptr=33
                                                               ; ASSERT zero 34:121

; ============================================================ ; ; ; one fold is all this needs  and spec/perm_cry
                                                               ; proves
<<<<<<<<<<<<<<<<                                               ; ; it
                                                               ; ASSERT ptr=17
                                                               ; ASSERT zero 34:67
  >>>>>>>>>>>>>>>>                                             ; walk in to this routine entry offset

; ============================================================ ; ; ; ; split the top byte at bit 130
                                                               ; ASSERT ptr=33
                                                               ; ASSERT zero 34:51
  [->>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<]                           ; the top byte steps into the halving frame
>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=48
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; the first halving; the bit it drops is bit 128
>>                                                             ; which is worth one in what is left below the split
                                                               ; ASSERT ptr=50
  [-<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>]
<                                                              ; the half steps back into the frame to be halved again
                                                               ; ASSERT ptr=49
  [-<+>]
<
                                                               ; ASSERT ptr=48
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; the second halving; the bit it drops is bit 129
>>                                                             ; which is worth two
                                                               ; ASSERT ptr=50
  [-<<<<<<<<<<<<<<<<<++>>>>>>>>>>>>>>>>>]
<                                                              ; and what is left in the quotient is everything at bit
                                                               ; 130 and above
                                                               ; ASSERT ptr=49
  [-<<+>>]

; ============================================================ ; ; ; ; two to the hundred and thirtieth is five  so
                                                               ; five
                                                               ; times that part
<<                                                             ; to the part above the split
                                                               ; ASSERT ptr=47
                                                               ; it is spent ONCE  into four copies of itself and one
                                                               ; copy of itself  which is where the five comes from;
                                                               ; neither cell can wrap  because four times sixty three
                                                               ; is two hundred and fifty two
  [-<<<<<<<<<<<<<++++>+>>>>>>>>>>>>]
                                                               ; ASSERT ptr=47
<<<<<<<<<<<<<                                                  ; to the byte pair the eight bit adder works on
                                                               ; ASSERT ptr=34
                                                               ; ASSERT zero 36:44
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=35
                                                               ; ASSERT zero 37:44
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=34
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=37
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=35
  [->>+<<]
>>
                                                               ; ASSERT ptr=37
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=41
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=44
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=42
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=39
  [-[[-]>>>>+<<<<]]
; ============================================================ ; ; ; ; ; the carry out is bit 7 of that  and nothing
>>>>                                                           ; ; else
                                                               ; ASSERT ptr=43
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=37
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
                                                               ; ASSERT ptr=37
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ============================================================ ; ; ; ; ; the sum is twice the halves plus the two low
                                                               ; bits
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=41
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=42
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=34
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 35:35
                                                               ; ASSERT zero 37:44

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=34
  [->>>>>>>>>>>+<<<<<<<<<<<]                                   ; the sum is five times H modulo 256  and it is the
                                                               ; addend's low byte
>>                                                             ; to the carry add8 computed
                                                               ; ASSERT ptr=36
  [->>>>>>>>>>+<<<<<<<<<<]                                     ; which is the addend's high byte  worth two hundred
                                                               ; and fifty six

; ============================================================ ; ; ; ; the bottom byte of the value takes the low byte
                                                               ; of
<<<<<<<<<<<<<<<<<<<                                            ; ; five times H
                                                               ; ASSERT ptr=17
  [->>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=45
  [-<<<<<<<<<<+>>>>>>>>>>]
<<<<<<<<<<<
                                                               ; ASSERT ptr=34
                                                               ; ASSERT zero 36:44
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=35
                                                               ; ASSERT zero 37:44
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=34
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=37
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=35
  [->>+<<]
>>
                                                               ; ASSERT ptr=37
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=41
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=44
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=42
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=39
  [-[[-]>>>>+<<<<]]
; ============================================================ ; ; ; ; ; the carry out is bit 7 of that  and nothing
>>>>                                                           ; ; else
                                                               ; ASSERT ptr=43
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=37
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
                                                               ; ASSERT ptr=37
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ============================================================ ; ; ; ; ; the sum is twice the halves plus the two low
                                                               ; bits
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=41
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=42
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=34
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 35:35
                                                               ; ASSERT zero 37:44

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=34
  [-<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>]                       ; the sum goes home and the carry stays where add8 left
                                                               ; it

; ============================================================ ; ; ; ; the second byte takes the high byte  and that
                                                               ; carry
<<<<<<<<<<<<<<<<                                               ; ; with it
                                                               ; ASSERT ptr=18
  [->>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=46
  [-<<<<<<<<<<<+>>>>>>>>>>>]
<<<<<<<<<<
                                                               ; ASSERT ptr=36
  [-<+>]
<<
                                                               ; ASSERT ptr=34
                                                               ; ASSERT zero 36:44
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=35
                                                               ; ASSERT zero 37:44
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=34
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=37
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=35
  [->>+<<]
>>
                                                               ; ASSERT ptr=37
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=41
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=44
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=42
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=39
  [-[[-]>>>>+<<<<]]
; ============================================================ ; ; ; ; ; the carry out is bit 7 of that  and nothing
>>>>                                                           ; ; else
                                                               ; ASSERT ptr=43
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=37
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
                                                               ; ASSERT ptr=37
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ============================================================ ; ; ; ; ; the sum is twice the halves plus the two low
                                                               ; bits
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=41
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=42
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=34
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 35:35
                                                               ; ASSERT zero 37:44

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=34
  [-<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>]
>>
                                                               ; ASSERT ptr=36

; ============================================================ ; ; ; ; and the carry out of that ripples up through
                                                               ; the
                                                               ; rest

[                                                              ; ____ byte 2 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=45
  [-]+
<<<<<<<<<<<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=19
  +
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<]                                                          ; continued
>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=47
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >]                                                           ; continued
<
                                                               ; ASSERT ptr=46
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=36
]
                                                               ; ASSERT ptr=36
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=45
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=36

[                                                              ; ____ byte 3 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=45
  [-]+
<<<<<<<<<<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=20
  +
  [->>>>>>>>>>>>>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]                                                            ; continued
>>>>>>>>>>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=47
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=46
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=36
]
                                                               ; ASSERT ptr=36
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=45
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=36

[                                                              ; ____ byte 4 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=45
  [-]+
<<<<<<<<<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=21
  +
  [->>>>>>>>>>>>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=47
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=46
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=36
]
                                                               ; ASSERT ptr=36
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=45
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=36

[                                                              ; ____ byte 5 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=45
  [-]+
<<<<<<<<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=22
  +
  [->>>>>>>>>>>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=47
  [-<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=46
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=36
]
                                                               ; ASSERT ptr=36
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=45
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=36

[                                                              ; ____ byte 6 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=45
  [-]+
<<<<<<<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=23
  +
  [->>>>>>>>>>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=47
  [-<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=46
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=36
]
                                                               ; ASSERT ptr=36
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=45
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=36

[                                                              ; ____ byte 7 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=45
  [-]+
<<<<<<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=24
  +
  [->>>>>>>>>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=47
  [-<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=46
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=36
]
                                                               ; ASSERT ptr=36
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=45
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=36

[                                                              ; ____ byte 8 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=45
  [-]+
<<<<<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=25
  +
  [->>>>>>>>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=47
  [-<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=46
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=36
]
                                                               ; ASSERT ptr=36
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=45
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=36

[                                                              ; ____ byte 9 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=45
  [-]+
<<<<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=26
  +
  [->>>>>>>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=47
  [-<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=46
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=36
]
                                                               ; ASSERT ptr=36
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=45
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=36

[                                                              ; ____ byte 10 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=45
  [-]+
<<<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=27
  +
  [->>>>>>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=47
  [-<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=46
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=36
]
                                                               ; ASSERT ptr=36
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=45
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=36

[                                                              ; ____ byte 11 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=45
  [-]+
<<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=28
  +
  [->>>>>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=47
  [-<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=46
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=36
]
                                                               ; ASSERT ptr=36
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=45
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=36

[                                                              ; ____ byte 12 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=45
  [-]+
<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=29
  +
  [->>>>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=47
  [-<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=46
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=36
]
                                                               ; ASSERT ptr=36
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=45
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=36

[                                                              ; ____ byte 13 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=45
  [-]+
<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=30
  +
  [->>>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=47
  [-<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=46
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=36
]
                                                               ; ASSERT ptr=36
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=45
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=36

[                                                              ; ____ byte 14 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=45
  [-]+
<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=31
  +
  [->>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=47
  [-<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=46
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=36
]
                                                               ; ASSERT ptr=36
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=45
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=36

[                                                              ; ____ byte 15 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=45
  [-]+
<<<<<<<<<<<<<
                                                               ; ASSERT ptr=32
  +
  [->>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=47
  [-<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=46
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=36
]
                                                               ; ASSERT ptr=36
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=45
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=36

[                                                              ; ____ byte 16  which does not look  because its carry
  [-]                                                          ; ; cannot happen ____
<<<
                                                               ; ASSERT ptr=33
  +
>>>
                                                               ; ASSERT ptr=36
]
                                                               ; ASSERT ptr=36

; ============================================================ ; ; ; ; the value is folded
<<<<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=17
                                                               ; ASSERT zero 34:51
                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=17

; ============================================================ ; ; ; keep a copy  because the five may have to be
                                                               ; taken
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; ; back off
  +>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<]                                                      ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<]                                                      ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<]                                                      ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<]                                                      ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<]                                                      ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<]                                                      ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<]                                                      ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<]                                                      ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<]                                                      ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<]                                                      ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<]                                                      ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<]                                                      ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<]                                                      ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<]                                                      ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<]                                                      ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<]                                                      ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<]                                                      ; continued
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; the temps hand the value straight back
  >>>>>>>>>>>>                                                 ; continued
                                                               ; ASSERT ptr=105
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>]                                                       ; continued
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>]                                                       ; continued
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>]                                                       ; continued
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>]                                                       ; continued
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>]                                                       ; continued
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>]                                                       ; continued
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>]                                                       ; continued
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>]                                                       ; continued
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>]                                                       ; continued
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>]                                                       ; continued
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>]                                                       ; continued
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>]                                                       ; continued
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>]                                                       ; continued
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>]                                                       ; continued
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>]                                                       ; continued
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>]                                                       ; continued
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>]                                                       ; continued
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<                 ; continued
                                                               ; ASSERT ptr=17

; ============================================================ ; ; ; add five
>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=34
  +++++
<<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=17
                                                               ; ASSERT zero 51:62
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>                           ; walk in to this routine entry offset
                                                               ; ASSERT ptr=51
                                                               ; ASSERT zero 51:62

; ============================================================ ; ; ; ; byte 0
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<                             ; the accumulator byte steps into the adder
                                                               ; ASSERT ptr=17
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<]                                             ; continued
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>                                             ; to the kernel's base  which is where a paste site
                                                               ; always stands
                                                               ; ASSERT ptr=52
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=53
                                                               ; ASSERT zero 55:62
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=52
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=55
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=53
  [->>+<<]
>>
                                                               ; ASSERT ptr=55
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=59
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=62
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=60
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=57
  [-[[-]>>>>+<<<<]]
; ============================================================ ; ; ; ; ; the carry out is bit 7 of that  and nothing
>>>>                                                           ; ; else
                                                               ; ASSERT ptr=61
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=55
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
                                                               ; ASSERT ptr=55
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ============================================================ ; ; ; ; ; the sum is twice the halves plus the two low
                                                               ; bits
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=59
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=60
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=52
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 53:53
                                                               ; ASSERT zero 55:62

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=52
<                                                              ; the carry in is nought or one  so it takes the old
  [->>+<<]                                                     ; ; kernel
>>
                                                               ; ASSERT ptr=53
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>]                                             ; continued
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
<<<
                                                               ; ASSERT ptr=51
                                                               ; ASSERT zero 52:62

; ============================================================ ; ; ; ; byte 1
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<                              ; the accumulator byte steps into the adder
                                                               ; ASSERT ptr=18
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<]                                               ; continued
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>                                              ; to the kernel's base  which is where a paste site
                                                               ; always stands
                                                               ; ASSERT ptr=52
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=53
                                                               ; ASSERT zero 55:62
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=52
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=55
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=53
  [->>+<<]
>>
                                                               ; ASSERT ptr=55
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=59
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=62
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=60
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=57
  [-[[-]>>>>+<<<<]]
; ============================================================ ; ; ; ; ; the carry out is bit 7 of that  and nothing
>>>>                                                           ; ; else
                                                               ; ASSERT ptr=61
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=55
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
                                                               ; ASSERT ptr=55
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ============================================================ ; ; ; ; ; the sum is twice the halves plus the two low
                                                               ; bits
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=59
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=60
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=52
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 53:53
                                                               ; ASSERT zero 55:62

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=52
<                                                              ; the carry in is nought or one  so it takes the old
  [->>+<<]                                                     ; ; kernel
>>
                                                               ; ASSERT ptr=53
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>]                                               ; continued
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
<<<
                                                               ; ASSERT ptr=51
                                                               ; ASSERT zero 52:62

; ============================================================ ; ; ; ; byte 2
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<                               ; the accumulator byte steps into the adder
                                                               ; ASSERT ptr=19
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<]                                                 ; continued
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>                                               ; to the kernel's base  which is where a paste site
                                                               ; always stands
                                                               ; ASSERT ptr=52
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=53
                                                               ; ASSERT zero 55:62
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=52
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=55
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=53
  [->>+<<]
>>
                                                               ; ASSERT ptr=55
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=59
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=62
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=60
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=57
  [-[[-]>>>>+<<<<]]
; ============================================================ ; ; ; ; ; the carry out is bit 7 of that  and nothing
>>>>                                                           ; ; else
                                                               ; ASSERT ptr=61
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=55
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
                                                               ; ASSERT ptr=55
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ============================================================ ; ; ; ; ; the sum is twice the halves plus the two low
                                                               ; bits
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=59
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=60
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=52
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 53:53
                                                               ; ASSERT zero 55:62

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=52
<                                                              ; the carry in is nought or one  so it takes the old
  [->>+<<]                                                     ; ; kernel
>>
                                                               ; ASSERT ptr=53
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>]                                                 ; continued
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
<<<
                                                               ; ASSERT ptr=51
                                                               ; ASSERT zero 52:62

; ============================================================ ; ; ; ; byte 3
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<                                ; the accumulator byte steps into the adder
                                                               ; ASSERT ptr=20
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<]                                                   ; continued
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>                                                ; to the kernel's base  which is where a paste site
                                                               ; always stands
                                                               ; ASSERT ptr=52
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=53
                                                               ; ASSERT zero 55:62
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=52
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=55
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=53
  [->>+<<]
>>
                                                               ; ASSERT ptr=55
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=59
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=62
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=60
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=57
  [-[[-]>>>>+<<<<]]
; ============================================================ ; ; ; ; ; the carry out is bit 7 of that  and nothing
>>>>                                                           ; ; else
                                                               ; ASSERT ptr=61
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=55
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
                                                               ; ASSERT ptr=55
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ============================================================ ; ; ; ; ; the sum is twice the halves plus the two low
                                                               ; bits
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=59
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=60
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=52
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 53:53
                                                               ; ASSERT zero 55:62

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=52
<                                                              ; the carry in is nought or one  so it takes the old
  [->>+<<]                                                     ; ; kernel
>>
                                                               ; ASSERT ptr=53
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>]                                                   ; continued
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
<<<
                                                               ; ASSERT ptr=51
                                                               ; ASSERT zero 52:62

; ============================================================ ; ; ; ; byte 4
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<                                 ; the accumulator byte steps into the adder
                                                               ; ASSERT ptr=21
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<]                                                     ; continued
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>                                                 ; to the kernel's base  which is where a paste site
                                                               ; always stands
                                                               ; ASSERT ptr=52
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=53
                                                               ; ASSERT zero 55:62
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=52
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=55
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=53
  [->>+<<]
>>
                                                               ; ASSERT ptr=55
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=59
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=62
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=60
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=57
  [-[[-]>>>>+<<<<]]
; ============================================================ ; ; ; ; ; the carry out is bit 7 of that  and nothing
>>>>                                                           ; ; else
                                                               ; ASSERT ptr=61
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=55
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
                                                               ; ASSERT ptr=55
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ============================================================ ; ; ; ; ; the sum is twice the halves plus the two low
                                                               ; bits
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=59
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=60
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=52
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 53:53
                                                               ; ASSERT zero 55:62

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=52
<                                                              ; the carry in is nought or one  so it takes the old
  [->>+<<]                                                     ; ; kernel
>>
                                                               ; ASSERT ptr=53
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>]                                                     ; continued
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
<<<
                                                               ; ASSERT ptr=51
                                                               ; ASSERT zero 52:62

; ============================================================ ; ; ; ; byte 5
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<                                  ; the accumulator byte steps into the adder
                                                               ; ASSERT ptr=22
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<]                                                       ; continued
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>>>>>>>>>>>>+<<<<<<<<<<<<<<]
>>>>>>>>>>>>>                                                  ; to the kernel's base  which is where a paste site
                                                               ; always stands
                                                               ; ASSERT ptr=52
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=53
                                                               ; ASSERT zero 55:62
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=52
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=55
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=53
  [->>+<<]
>>
                                                               ; ASSERT ptr=55
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=59
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=62
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=60
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=57
  [-[[-]>>>>+<<<<]]
; ============================================================ ; ; ; ; ; the carry out is bit 7 of that  and nothing
>>>>                                                           ; ; else
                                                               ; ASSERT ptr=61
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=55
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
                                                               ; ASSERT ptr=55
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ============================================================ ; ; ; ; ; the sum is twice the halves plus the two low
                                                               ; bits
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=59
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=60
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=52
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 53:53
                                                               ; ASSERT zero 55:62

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=52
<                                                              ; the carry in is nought or one  so it takes the old
  [->>+<<]                                                     ; ; kernel
>>
                                                               ; ASSERT ptr=53
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>]                                                       ; continued
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
<<<
                                                               ; ASSERT ptr=51
                                                               ; ASSERT zero 52:62

; ============================================================ ; ; ; ; byte 6
<<<<<<<<<<<<<<<<<<<<<<<<<<<<                                   ; the accumulator byte steps into the adder
                                                               ; ASSERT ptr=23
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<]                                                         ; continued
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>>>>>>>>>>>+<<<<<<<<<<<<<]
>>>>>>>>>>>>                                                   ; to the kernel's base  which is where a paste site
                                                               ; always stands
                                                               ; ASSERT ptr=52
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=53
                                                               ; ASSERT zero 55:62
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=52
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=55
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=53
  [->>+<<]
>>
                                                               ; ASSERT ptr=55
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=59
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=62
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=60
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=57
  [-[[-]>>>>+<<<<]]
; ============================================================ ; ; ; ; ; the carry out is bit 7 of that  and nothing
>>>>                                                           ; ; else
                                                               ; ASSERT ptr=61
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=55
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
                                                               ; ASSERT ptr=55
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ============================================================ ; ; ; ; ; the sum is twice the halves plus the two low
                                                               ; bits
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=59
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=60
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=52
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 53:53
                                                               ; ASSERT zero 55:62

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=52
<                                                              ; the carry in is nought or one  so it takes the old
  [->>+<<]                                                     ; ; kernel
>>
                                                               ; ASSERT ptr=53
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>]                                                         ; continued
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
<<<
                                                               ; ASSERT ptr=51
                                                               ; ASSERT zero 52:62

; ============================================================ ; ; ; ; byte 7
<<<<<<<<<<<<<<<<<<<<<<<<<<<                                    ; the accumulator byte steps into the adder
                                                               ; ASSERT ptr=24
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <]                                                           ; continued
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>>>>>>>>>>+<<<<<<<<<<<<]
>>>>>>>>>>>                                                    ; to the kernel's base  which is where a paste site
                                                               ; always stands
                                                               ; ASSERT ptr=52
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=53
                                                               ; ASSERT zero 55:62
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=52
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=55
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=53
  [->>+<<]
>>
                                                               ; ASSERT ptr=55
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=59
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=62
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=60
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=57
  [-[[-]>>>>+<<<<]]
; ============================================================ ; ; ; ; ; the carry out is bit 7 of that  and nothing
>>>>                                                           ; ; else
                                                               ; ASSERT ptr=61
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=55
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
                                                               ; ASSERT ptr=55
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ============================================================ ; ; ; ; ; the sum is twice the halves plus the two low
                                                               ; bits
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=59
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=60
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=52
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 53:53
                                                               ; ASSERT zero 55:62

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=52
<                                                              ; the carry in is nought or one  so it takes the old
  [->>+<<]                                                     ; ; kernel
>>
                                                               ; ASSERT ptr=53
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >]                                                           ; continued
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
<<<
                                                               ; ASSERT ptr=51
                                                               ; ASSERT zero 52:62

; ============================================================ ; ; ; ; byte 8
<<<<<<<<<<<<<<<<<<<<<<<<<<                                     ; the accumulator byte steps into the adder
                                                               ; ASSERT ptr=25
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>>>>>>>>>+<<<<<<<<<<<]
>>>>>>>>>>                                                     ; to the kernel's base  which is where a paste site
                                                               ; always stands
                                                               ; ASSERT ptr=52
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=53
                                                               ; ASSERT zero 55:62
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=52
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=55
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=53
  [->>+<<]
>>
                                                               ; ASSERT ptr=55
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=59
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=62
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=60
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=57
  [-[[-]>>>>+<<<<]]
; ============================================================ ; ; ; ; ; the carry out is bit 7 of that  and nothing
>>>>                                                           ; ; else
                                                               ; ASSERT ptr=61
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=55
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
                                                               ; ASSERT ptr=55
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ============================================================ ; ; ; ; ; the sum is twice the halves plus the two low
                                                               ; bits
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=59
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=60
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=52
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 53:53
                                                               ; ASSERT zero 55:62

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=52
<                                                              ; the carry in is nought or one  so it takes the old
  [->>+<<]                                                     ; ; kernel
>>
                                                               ; ASSERT ptr=53
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>>]
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
<<<
                                                               ; ASSERT ptr=51
                                                               ; ASSERT zero 52:62

; ============================================================ ; ; ; ; byte 9
<<<<<<<<<<<<<<<<<<<<<<<<<                                      ; the accumulator byte steps into the adder
                                                               ; ASSERT ptr=26
  [->>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>>>>>>>>+<<<<<<<<<<]
>>>>>>>>>                                                      ; to the kernel's base  which is where a paste site
                                                               ; always stands
                                                               ; ASSERT ptr=52
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=53
                                                               ; ASSERT zero 55:62
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=52
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=55
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=53
  [->>+<<]
>>
                                                               ; ASSERT ptr=55
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=59
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=62
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=60
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=57
  [-[[-]>>>>+<<<<]]
; ============================================================ ; ; ; ; ; the carry out is bit 7 of that  and nothing
>>>>                                                           ; ; else
                                                               ; ASSERT ptr=61
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=55
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
                                                               ; ASSERT ptr=55
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ============================================================ ; ; ; ; ; the sum is twice the halves plus the two low
                                                               ; bits
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=59
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=60
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=52
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 53:53
                                                               ; ASSERT zero 55:62

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=52
<                                                              ; the carry in is nought or one  so it takes the old
  [->>+<<]                                                     ; ; kernel
>>
                                                               ; ASSERT ptr=53
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>]
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
<<<
                                                               ; ASSERT ptr=51
                                                               ; ASSERT zero 52:62

; ============================================================ ; ; ; ; byte 10
<<<<<<<<<<<<<<<<<<<<<<<<                                       ; the accumulator byte steps into the adder
                                                               ; ASSERT ptr=27
  [->>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>>>>>>>+<<<<<<<<<]
>>>>>>>>                                                       ; to the kernel's base  which is where a paste site
                                                               ; always stands
                                                               ; ASSERT ptr=52
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=53
                                                               ; ASSERT zero 55:62
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=52
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=55
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=53
  [->>+<<]
>>
                                                               ; ASSERT ptr=55
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=59
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=62
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=60
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=57
  [-[[-]>>>>+<<<<]]
; ============================================================ ; ; ; ; ; the carry out is bit 7 of that  and nothing
>>>>                                                           ; ; else
                                                               ; ASSERT ptr=61
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=55
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
                                                               ; ASSERT ptr=55
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ============================================================ ; ; ; ; ; the sum is twice the halves plus the two low
                                                               ; bits
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=59
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=60
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=52
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 53:53
                                                               ; ASSERT zero 55:62

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=52
<                                                              ; the carry in is nought or one  so it takes the old
  [->>+<<]                                                     ; ; kernel
>>
                                                               ; ASSERT ptr=53
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>]
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
<<<
                                                               ; ASSERT ptr=51
                                                               ; ASSERT zero 52:62

; ============================================================ ; ; ; ; byte 11
<<<<<<<<<<<<<<<<<<<<<<<                                        ; the accumulator byte steps into the adder
                                                               ; ASSERT ptr=28
  [->>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>>>>>>+<<<<<<<<]
>>>>>>>                                                        ; to the kernel's base  which is where a paste site
                                                               ; always stands
                                                               ; ASSERT ptr=52
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=53
                                                               ; ASSERT zero 55:62
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=52
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=55
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=53
  [->>+<<]
>>
                                                               ; ASSERT ptr=55
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=59
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=62
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=60
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=57
  [-[[-]>>>>+<<<<]]
; ============================================================ ; ; ; ; ; the carry out is bit 7 of that  and nothing
>>>>                                                           ; ; else
                                                               ; ASSERT ptr=61
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=55
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
                                                               ; ASSERT ptr=55
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ============================================================ ; ; ; ; ; the sum is twice the halves plus the two low
                                                               ; bits
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=59
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=60
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=52
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 53:53
                                                               ; ASSERT zero 55:62

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=52
<                                                              ; the carry in is nought or one  so it takes the old
  [->>+<<]                                                     ; ; kernel
>>
                                                               ; ASSERT ptr=53
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>]
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
<<<
                                                               ; ASSERT ptr=51
                                                               ; ASSERT zero 52:62

; ============================================================ ; ; ; ; byte 12
<<<<<<<<<<<<<<<<<<<<<<                                         ; the accumulator byte steps into the adder
                                                               ; ASSERT ptr=29
  [->>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>>>>>+<<<<<<<]
>>>>>>                                                         ; to the kernel's base  which is where a paste site
                                                               ; always stands
                                                               ; ASSERT ptr=52
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=53
                                                               ; ASSERT zero 55:62
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=52
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=55
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=53
  [->>+<<]
>>
                                                               ; ASSERT ptr=55
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=59
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=62
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=60
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=57
  [-[[-]>>>>+<<<<]]
; ============================================================ ; ; ; ; ; the carry out is bit 7 of that  and nothing
>>>>                                                           ; ; else
                                                               ; ASSERT ptr=61
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=55
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
                                                               ; ASSERT ptr=55
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ============================================================ ; ; ; ; ; the sum is twice the halves plus the two low
                                                               ; bits
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=59
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=60
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=52
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 53:53
                                                               ; ASSERT zero 55:62

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=52
<                                                              ; the carry in is nought or one  so it takes the old
  [->>+<<]                                                     ; ; kernel
>>
                                                               ; ASSERT ptr=53
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>]
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
<<<
                                                               ; ASSERT ptr=51
                                                               ; ASSERT zero 52:62

; ============================================================ ; ; ; ; byte 13
<<<<<<<<<<<<<<<<<<<<<                                          ; the accumulator byte steps into the adder
                                                               ; ASSERT ptr=30
  [->>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>>>>+<<<<<<]
>>>>>                                                          ; to the kernel's base  which is where a paste site
                                                               ; always stands
                                                               ; ASSERT ptr=52
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=53
                                                               ; ASSERT zero 55:62
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=52
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=55
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=53
  [->>+<<]
>>
                                                               ; ASSERT ptr=55
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=59
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=62
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=60
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=57
  [-[[-]>>>>+<<<<]]
; ============================================================ ; ; ; ; ; the carry out is bit 7 of that  and nothing
>>>>                                                           ; ; else
                                                               ; ASSERT ptr=61
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=55
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
                                                               ; ASSERT ptr=55
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ============================================================ ; ; ; ; ; the sum is twice the halves plus the two low
                                                               ; bits
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=59
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=60
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=52
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 53:53
                                                               ; ASSERT zero 55:62

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=52
<                                                              ; the carry in is nought or one  so it takes the old
  [->>+<<]                                                     ; ; kernel
>>
                                                               ; ASSERT ptr=53
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>]
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
<<<
                                                               ; ASSERT ptr=51
                                                               ; ASSERT zero 52:62

; ============================================================ ; ; ; ; byte 14
<<<<<<<<<<<<<<<<<<<<                                           ; the accumulator byte steps into the adder
                                                               ; ASSERT ptr=31
  [->>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>>>+<<<<<]
>>>>                                                           ; to the kernel's base  which is where a paste site
                                                               ; always stands
                                                               ; ASSERT ptr=52
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=53
                                                               ; ASSERT zero 55:62
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=52
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=55
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=53
  [->>+<<]
>>
                                                               ; ASSERT ptr=55
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=59
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=62
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=60
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=57
  [-[[-]>>>>+<<<<]]
; ============================================================ ; ; ; ; ; the carry out is bit 7 of that  and nothing
>>>>                                                           ; ; else
                                                               ; ASSERT ptr=61
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=55
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
                                                               ; ASSERT ptr=55
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ============================================================ ; ; ; ; ; the sum is twice the halves plus the two low
                                                               ; bits
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=59
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=60
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=52
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 53:53
                                                               ; ASSERT zero 55:62

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=52
<                                                              ; the carry in is nought or one  so it takes the old
  [->>+<<]                                                     ; ; kernel
>>
                                                               ; ASSERT ptr=53
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>]
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
<<<
                                                               ; ASSERT ptr=51
                                                               ; ASSERT zero 52:62

; ============================================================ ; ; ; ; byte 15
<<<<<<<<<<<<<<<<<<<                                            ; the accumulator byte steps into the adder
                                                               ; ASSERT ptr=32
  [->>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>>+<<<<]
>>>                                                            ; to the kernel's base  which is where a paste site
                                                               ; always stands
                                                               ; ASSERT ptr=52
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=53
                                                               ; ASSERT zero 55:62
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=52
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=55
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=53
  [->>+<<]
>>
                                                               ; ASSERT ptr=55
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=59
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=62
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=60
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=57
  [-[[-]>>>>+<<<<]]
; ============================================================ ; ; ; ; ; the carry out is bit 7 of that  and nothing
>>>>                                                           ; ; else
                                                               ; ASSERT ptr=61
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=55
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
                                                               ; ASSERT ptr=55
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ============================================================ ; ; ; ; ; the sum is twice the halves plus the two low
                                                               ; bits
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=59
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=60
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=52
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 53:53
                                                               ; ASSERT zero 55:62

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=52
<                                                              ; the carry in is nought or one  so it takes the old
  [->>+<<]                                                     ; ; kernel
>>
                                                               ; ASSERT ptr=53
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>]
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
<<<
                                                               ; ASSERT ptr=51
                                                               ; ASSERT zero 52:62

; ============================================================ ; ; ; ; byte 16
<<<<<<<<<<<<<<<<<<                                             ; the accumulator byte steps into the adder
                                                               ; ASSERT ptr=33
  [->>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>+<<<]
>>                                                             ; to the kernel's base  which is where a paste site
                                                               ; always stands
                                                               ; ASSERT ptr=52
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=53
                                                               ; ASSERT zero 55:62
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=52
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=55
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=53
  [->>+<<]
>>
                                                               ; ASSERT ptr=55
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=59
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=62
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=60
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=57
  [-[[-]>>>>+<<<<]]
; ============================================================ ; ; ; ; ; the carry out is bit 7 of that  and nothing
>>>>                                                           ; ; else
                                                               ; ASSERT ptr=61
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=55
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
                                                               ; ASSERT ptr=55
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ============================================================ ; ; ; ; ; the sum is twice the halves plus the two low
                                                               ; bits
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=59
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=60
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=52
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 53:53
                                                               ; ASSERT zero 55:62

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=52
<                                                              ; the carry in is nought or one  so it takes the old
  [->>+<<]                                                     ; ; kernel
>>
                                                               ; ASSERT ptr=53
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>]
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
<<<
                                                               ; ASSERT ptr=51
                                                               ; ASSERT zero 52:62

                                                               ; the carry out of the top byte is dropped  and cleared
                                                               ; so the frame is as empty as it was found
                                                               ; ASSERT ptr=51
  [-]
                                                               ; ASSERT zero 34:62

  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<                           ; walk back out to the routine base
                                                               ; ASSERT ptr=17

; ============================================================ ; ; ; did bit 130 come up
>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=33
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; the top byte steps into the halving frame
  >>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<]                                                       ; continued
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=92
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>                                                             ; bit 128 is worth one below the split
                                                               ; ASSERT ptr=94
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>>>>>]                                                   ; continued
<                                                              ; and the half is halved again
  [-<+>]
<
                                                               ; ASSERT ptr=92
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>                                                             ; bit 129 is worth two
                                                               ; ASSERT ptr=94
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<++>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>>>>>>]                                                  ; continued
                                                               ; what is left is bit 130  which is nought or one
                                                               ; because the value was below two to the hundred and
                                                               ; thirtieth before five was added to it
<
  [-<<<+>>>]
<<<
                                                               ; ASSERT ptr=90

; ============================================================ ; ; ; if it came up  the value had to be reduced and
                                                               ; this
                                                               ; IS the answer
>                                                              ; the else arm is armed first  and the then arm disarms
  [-]                                                          ; ; it
  +
<
                                                               ; ASSERT ptr=90
[
  -
<<<<<<<<<<<<<<<<<                                              ; the saved copy is not wanted
                                                               ; ASSERT ptr=73
  [-]
>                                                              ; the next byte
  [-]
>                                                              ; the next byte
  [-]
>                                                              ; the next byte
  [-]
>                                                              ; the next byte
  [-]
>                                                              ; the next byte
  [-]
>                                                              ; the next byte
  [-]
>                                                              ; the next byte
  [-]
>                                                              ; the next byte
  [-]
>                                                              ; the next byte
  [-]
>                                                              ; the next byte
  [-]
>                                                              ; the next byte
  [-]
>                                                              ; the next byte
  [-]
>                                                              ; the next byte
  [-]
>                                                              ; the next byte
  [-]
>                                                              ; the next byte
  [-]
>                                                              ; the next byte
  [-]
>>                                                             ; disarm the else and go back to the flag
  -
<
]
; ============================================================ ; ; ; if it did not  the value is the copy from before
                                                               ; the
>                                                              ; ; five
                                                               ; ASSERT ptr=91
[
  -
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<                                               ; continued
                                                               ; ASSERT ptr=17
  [-]
>                                                              ; the next byte
  [-]
>                                                              ; the next byte
  [-]
>                                                              ; the next byte
  [-]
>                                                              ; the next byte
  [-]
>                                                              ; the next byte
  [-]
>                                                              ; the next byte
  [-]
>                                                              ; the next byte
  [-]
>                                                              ; the next byte
  [-]
>                                                              ; the next byte
  [-]
>                                                              ; the next byte
  [-]
>                                                              ; the next byte
  [-]
>                                                              ; the next byte
  [-]
>                                                              ; the next byte
  [-]
>                                                              ; the next byte
  [-]
>                                                              ; the next byte
  [-]
>                                                              ; the next byte
  [-]
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>                       ; the saved copy comes back
                                                               ; ASSERT ptr=73
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]   ; continued
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]   ; continued
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]   ; continued
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]   ; continued
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]   ; continued
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]   ; continued
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]   ; continued
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]   ; continued
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]   ; continued
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]   ; continued
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]   ; continued
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]   ; continued
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]   ; continued
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]   ; continued
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]   ; continued
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]   ; continued
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]   ; continued
>>                                                             ; back to the else flag
]
                                                               ; ASSERT ptr=91
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<                                               ; continued
                                                               ; ASSERT ptr=17
                                                               ; ASSERT zero 34:121
                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=17
                                                               ; ASSERT zero 34:141
                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=17

; emit
  .>.>.>.>.>.>.>.>.>.>.>.>.>.>.>.>.                            ; the accumulator  seventeen bytes little endian
