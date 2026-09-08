; bfsodium REDUCEP136 : bring a 17 byte value below p = 2^130 minus 5
;
; HAND WRITTEN; ONE fold  then a tail: add five  and look at bit 130; If it
; came up  the value wanted reducing and what is left below the split IS the
; answer; if it did not  it did not  and the answer is the copy kept from
; before the five was added; Clearing bit 130 and above is subtracting 2^130
; which is why no subtractor had to be written;
;
; This folded TWICE for a while; Deleting the second fold changed no answer
; that any vector could see  which is the signal that it was unreachable and
; not merely untested; The reason is a bound: after ONE fold a seventeen byte
; value is at most 2^130 minus one plus five times sixty three  which is under
; 2p  and the tail is exactly the reduction for anything under 2p; So the
; second fold could never have had work to do; spec/perm_cry states that as
; one_fold_suffices and Cryptol PROVES it  Q;E;D;  over every one of the 2^136
; inputs; The companion property tail_alone_is_not_enough is refuted by
; counterexample  so the pair is a real distinction and not a claim that would
; have held whatever was deleted;
;
; INTERFACE entry=16 exit=0 footprint=0:104
; IO  in:  x{17} LE           (17 bytes)
;     out: (x mod p){17} LE   (17 bytes)
;
; TAPE MAP  (home @0)
;   @0x00:0x10  x{17}   u8   the value  and the result
;   @0x11:0x34  the pasted routines' frames; fold136 is 0:52 and add136 is 0:45
;               and both are pasted at this file's own zero
;   @0x38:0x48  S{17}   u8   the value as it stood before five was added
;   @0x49       g       u8   bit 130 after the add; nought or one
;   @0x4a       e       u8   the else arm of that choice
;   @0x4b       h       u8   HALVE frame: the top byte being halved
;   @0x4c       q       u8   HALVE frame: that byte shifted right one
;   @0x4d       bit     u8   HALVE frame: that byte low bit
;   @0x4e       f       u8   HALVE frame scratch  restored to nought
;   @0x58:0x68  temps{17}    hand the value back after it has been copied

  ,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,                            ; read the value little endian
; ASSERT ptr=16
; ASSERT zero 17:104

; ==== one fold is all this needs  and spec/perm_cry proves it ====
<<<<<<<<<<<<<<<<
; ASSERT ptr=0
; ASSERT zero 17:52
  >>>>>>>>>>>>>>>>                                             ; walk in to this routine entry offset

; ==== split the top byte at bit 130 ====
; ASSERT ptr=16
; ASSERT zero 17:52
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<   ; the top byte steps into the halving frame
  <<<<<<<<<]                                                   ; continued
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ASSERT ptr=48
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; the first halving; the bit it drops is bit 128
>>                                                             ; which is worth one in what is left below the split
; ASSERT ptr=50
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>]                                               ; continued
<                                                              ; the half steps back into the frame to be halved again
; ASSERT ptr=49
  [-<+>]
<
; ASSERT ptr=48
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; the second halving; the bit it drops is bit 129
>>                                                             ; which is worth two
; ASSERT ptr=50
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<++>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>]                                              ; continued
<                                                              ; and what is left in the quotient is everything at bit
                                                               ; 130 and above
; ASSERT ptr=49
  [-<<<+>>>]

; ==== two to the hundred and thirtieth is five  so add that part five times ====
>>>
; ASSERT ptr=52
  +++++
[
  -
<<<<<<                                                         ; the part above the split is copied into the addend
                                                               ; and kept for the next turn
; ASSERT ptr=46
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>+<]                                                      ; continued
>
; ASSERT ptr=47
  [-<+>]
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; ASSERT ptr=0
; ASSERT zero 34:45
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>                           ; walk in to this routine entry offset
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
  [->>+<<]                                                     ; ; kernel
>>
; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>]                                             ; continued
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
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
  [->>+<<]                                                     ; ; kernel
>>
; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>]                                               ; continued
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
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
  [->>+<<]                                                     ; ; kernel
>>
; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>]                                                 ; continued
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
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
  [->>+<<]                                                     ; ; kernel
>>
; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>]                                                   ; continued
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
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
  [->>+<<]                                                     ; ; kernel
>>
; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>]                                                     ; continued
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
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
  [->>+<<]                                                     ; ; kernel
>>
; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>]                                                       ; continued
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
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
  [->>+<<]                                                     ; ; kernel
>>
; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>]                                                         ; continued
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
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
  [->>+<<]                                                     ; ; kernel
>>
; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >]                                                           ; continued
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
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
  [->>+<<]                                                     ; ; kernel
>>
; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>>]
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
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
  [->>+<<]                                                     ; ; kernel
>>
; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>]
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
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
  [->>+<<]                                                     ; ; kernel
>>
; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>]
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
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
  [->>+<<]                                                     ; ; kernel
>>
; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>]
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
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
  [->>+<<]                                                     ; ; kernel
>>
; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>]
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
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
  [->>+<<]                                                     ; ; kernel
>>
; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>]
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
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
  [->>+<<]                                                     ; ; kernel
>>
; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>]
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
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
  [->>+<<]                                                     ; ; kernel
>>
; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>]
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
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
  [->>+<<]                                                     ; ; kernel
>>
; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>]
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
<<<
; ASSERT ptr=34
; ASSERT zero 35:45

; the carry out of the top byte is dropped  and cleared so the frame is as
; empty as it was found
; ASSERT ptr=34
  [-]
; ASSERT zero 17:45

  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<                           ; walk back out to the routine base
; ASSERT ptr=0
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>           ; back to the turn counter
]
; ASSERT ptr=52
<<<<<<                                                         ; the part above the split has been spent five times
                                                               ; over
; ASSERT ptr=46
  [-]
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; ASSERT ptr=0
; ASSERT zero 17:52
; walk back out to the routine base

; ASSERT ptr=0

; ==== keep a copy  because the five may have to be taken back off ====
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
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<]                                                      ; continued
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; the temps hand the value straight back
  >>>>>>>>>>>>                                                 ; continued
; ASSERT ptr=88
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
; ASSERT ptr=0

; ==== add five ====
>>>>>>>>>>>>>>>>>
; ASSERT ptr=17
  +++++
<<<<<<<<<<<<<<<<<
; ASSERT ptr=0
; ASSERT zero 34:45
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>                           ; walk in to this routine entry offset
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
  [->>+<<]                                                     ; ; kernel
>>
; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>]                                             ; continued
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
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
  [->>+<<]                                                     ; ; kernel
>>
; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>]                                               ; continued
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
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
  [->>+<<]                                                     ; ; kernel
>>
; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>]                                                 ; continued
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
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
  [->>+<<]                                                     ; ; kernel
>>
; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>]                                                   ; continued
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
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
  [->>+<<]                                                     ; ; kernel
>>
; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>]                                                     ; continued
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
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
  [->>+<<]                                                     ; ; kernel
>>
; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>]                                                       ; continued
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
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
  [->>+<<]                                                     ; ; kernel
>>
; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>]                                                         ; continued
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
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
  [->>+<<]                                                     ; ; kernel
>>
; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >]                                                           ; continued
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
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
  [->>+<<]                                                     ; ; kernel
>>
; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>>]
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
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
  [->>+<<]                                                     ; ; kernel
>>
; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>]
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
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
  [->>+<<]                                                     ; ; kernel
>>
; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>]
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
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
  [->>+<<]                                                     ; ; kernel
>>
; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>]
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
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
  [->>+<<]                                                     ; ; kernel
>>
; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>]
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
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
  [->>+<<]                                                     ; ; kernel
>>
; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>]
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
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
  [->>+<<]                                                     ; ; kernel
>>
; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>]
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
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
  [->>+<<]                                                     ; ; kernel
>>
; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>]
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
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
  [->>+<<]                                                     ; ; kernel
>>
; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>]
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
<<<
; ASSERT ptr=34
; ASSERT zero 35:45

; the carry out of the top byte is dropped  and cleared so the frame is as
; empty as it was found
; ASSERT ptr=34
  [-]
; ASSERT zero 17:45

  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<                           ; walk back out to the routine base
; ASSERT ptr=0

; ==== did bit 130 come up ====
>>>>>>>>>>>>>>>>
; ASSERT ptr=16
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; the top byte steps into the halving frame
  >>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<]                                                       ; continued
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ASSERT ptr=75
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>                                                             ; bit 128 is worth one below the split
; ASSERT ptr=77
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>>>>>]                                                   ; continued
<                                                              ; and the half is halved again
  [-<+>]
<
; ASSERT ptr=75
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>                                                             ; bit 129 is worth two
; ASSERT ptr=77
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<++>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>>>>>>]                                                  ; continued
; what is left is bit 130  which is nought or one because the value was below
; two to the hundred and thirtieth before five was added to it
<
  [-<<<+>>>]
<<<
; ASSERT ptr=73

; ==== if it came up  the value had to be reduced and this IS the answer ====
>                                                              ; the else arm is armed first  and the then arm disarms
                                                               ; it
  [-]
  +
<
; ASSERT ptr=73
[
  -
<<<<<<<<<<<<<<<<<                                              ; the saved copy is not wanted
; ASSERT ptr=56
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
; ==== if it did not  the value is the copy from before the five ====
>
; ASSERT ptr=74
[
  -
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<                                               ; continued
; ASSERT ptr=0
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
; ASSERT ptr=56
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
; ASSERT ptr=74
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<                                               ; continued
; ASSERT ptr=0
; ASSERT zero 17:104
; emit the reduced value little endian
  .>.>.>.>.>.>.>.>.>.>.>.>.>.>.>.>.
