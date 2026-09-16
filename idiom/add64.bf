; bfsodium ADD64 : 64 bit little endian add   a := (a plus b) mod 2^64
;
; NOTE square brackets are brainfuck loops  so comments use braces for counts;
;
; INTERFACE entry=16 exit=16 footprint=0:27
; IO  in:  a{8} LE  followed by  b{8} LE      (16 bytes)
;     out: sum{8} LE                          (8 bytes; final carry dropped)
;
; TAPE MAP  (home @0)
;   @0x00:0x07  a{8}   u8   result accumulates here (LSB at @0x00)
;   @0x08:0x0f  b{8}   u8   addend
;   @0x10       cin    u8   carry into the current byte (starts nought)
;   @0x11:0x1b  idiom/add8's frame  pasted at @0x11; its footprint is 0:10 and
;               that is what sets the size of this one; x is at @0x11  y at
;               @0x12 and the carry out at @0x13
;
; THE 64 BIT WIDENING OF chacha20/add32  and the last of the four pieces
; SHA_512 needs; Widening an adder is the easy one of the four  because a
; ripple carry does not care how long the chain is: eight byte blocks instead
; of four  the same idiom/add8 paste  and the same carry cell walking along;
;
; Each byte block adds b{i} then cin into a{i}  stores the low byte back into
; a{i}  and moves the carry out into cin for the next byte; Eight byte blocks
; LSB first; the carry out of byte 7 is the dropped final carry  and it is
; cleared rather than left behind  so the frame is as clean on the way out as a
; caller is entitled to assume on the way in;
;
; TWO adders  on purpose; idiom/add8 computes the carry from bit 7 instead of
; watching for it  which costs about twenty thousand instructions whatever the
; operands are; that is far cheaper than the old kernel for the byte of b  and
; far dearer for the carry in  which is nought or one; So the carry in keeps
; the old kernel  whose cost is the product of the operands and is therefore
; nearly free when one of them is at most one; The old kernel borrows @0x14 and
; @0x15  which are add8's halving frame  and leaves them at nought;

,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>                               ; read a{0:7} then b{0:7}  leaving the pointer on cin
                                                               ; @0x10
                                                               ; ASSERT ptr=16
                                                               ; ASSERT zero 16:27

; ============================================================ ; byte 0 : a @0x00  b @0x08
<<<<<<<<<<<<<<<<                                               ; move a0 into the accumulator
                                                               ; ASSERT ptr=0
  [->>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<]
>>>>>>>>                                                       ; move b0 into the addend
  [->>>>>>>>>>+<<<<<<<<<<]
>>>>>>>>>                                                      ; to the kernel base  which is where a paste site
                                                               ; always stands
                                                               ; ASSERT ptr=17
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
<                                                              ; the carry in is nought or one  so it takes the old
                                                               ; kernel
  [->>+<<]
>>
                                                               ; ASSERT ptr=18
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; store the sum back into a0
  [-<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>]
>>                                                             ; the carry out becomes the carry in for the next byte
  [-<<<+>>>]
<<<                                                            ; back to the carry in
                                                               ; ASSERT ptr=16
                                                               ; ASSERT zero 17:27

; ============================================================ ; byte 1 : a @0x01  b @0x09
<<<<<<<<<<<<<<<                                                ; move a1 into the accumulator
                                                               ; ASSERT ptr=1
  [->>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<]
>>>>>>>>                                                       ; move b1 into the addend
  [->>>>>>>>>+<<<<<<<<<]
>>>>>>>>                                                       ; to the kernel base  which is where a paste site
                                                               ; always stands
                                                               ; ASSERT ptr=17
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
<                                                              ; the carry in is nought or one  so it takes the old
                                                               ; kernel
  [->>+<<]
>>
                                                               ; ASSERT ptr=18
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; store the sum back into a1
  [-<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>]
>>                                                             ; the carry out becomes the carry in for the next byte
  [-<<<+>>>]
<<<                                                            ; back to the carry in
                                                               ; ASSERT ptr=16
                                                               ; ASSERT zero 17:27

; ============================================================ ; byte 2 : a @0x02  b @0x0a
<<<<<<<<<<<<<<                                                 ; move a2 into the accumulator
                                                               ; ASSERT ptr=2
  [->>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<]
>>>>>>>>                                                       ; move b2 into the addend
  [->>>>>>>>+<<<<<<<<]
>>>>>>>                                                        ; to the kernel base  which is where a paste site
                                                               ; always stands
                                                               ; ASSERT ptr=17
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
<                                                              ; the carry in is nought or one  so it takes the old
                                                               ; kernel
  [->>+<<]
>>
                                                               ; ASSERT ptr=18
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; store the sum back into a2
  [-<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>]
>>                                                             ; the carry out becomes the carry in for the next byte
  [-<<<+>>>]
<<<                                                            ; back to the carry in
                                                               ; ASSERT ptr=16
                                                               ; ASSERT zero 17:27

; ============================================================ ; byte 3 : a @0x03  b @0x0b
<<<<<<<<<<<<<                                                  ; move a3 into the accumulator
                                                               ; ASSERT ptr=3
  [->>>>>>>>>>>>>>+<<<<<<<<<<<<<<]
>>>>>>>>                                                       ; move b3 into the addend
  [->>>>>>>+<<<<<<<]
>>>>>>                                                         ; to the kernel base  which is where a paste site
                                                               ; always stands
                                                               ; ASSERT ptr=17
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
<                                                              ; the carry in is nought or one  so it takes the old
                                                               ; kernel
  [->>+<<]
>>
                                                               ; ASSERT ptr=18
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; store the sum back into a3
  [-<<<<<<<<<<<<<<+>>>>>>>>>>>>>>]
>>                                                             ; the carry out becomes the carry in for the next byte
  [-<<<+>>>]
<<<                                                            ; back to the carry in
                                                               ; ASSERT ptr=16
                                                               ; ASSERT zero 17:27

; ============================================================ ; byte 4 : a @0x04  b @0x0c
<<<<<<<<<<<<                                                   ; move a4 into the accumulator
                                                               ; ASSERT ptr=4
  [->>>>>>>>>>>>>+<<<<<<<<<<<<<]
>>>>>>>>                                                       ; move b4 into the addend
  [->>>>>>+<<<<<<]
>>>>>                                                          ; to the kernel base  which is where a paste site
                                                               ; always stands
                                                               ; ASSERT ptr=17
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
<                                                              ; the carry in is nought or one  so it takes the old
                                                               ; kernel
  [->>+<<]
>>
                                                               ; ASSERT ptr=18
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; store the sum back into a4
  [-<<<<<<<<<<<<<+>>>>>>>>>>>>>]
>>                                                             ; the carry out becomes the carry in for the next byte
  [-<<<+>>>]
<<<                                                            ; back to the carry in
                                                               ; ASSERT ptr=16
                                                               ; ASSERT zero 17:27

; ============================================================ ; byte 5 : a @0x05  b @0x0d
<<<<<<<<<<<                                                    ; move a5 into the accumulator
                                                               ; ASSERT ptr=5
  [->>>>>>>>>>>>+<<<<<<<<<<<<]
>>>>>>>>                                                       ; move b5 into the addend
  [->>>>>+<<<<<]
>>>>                                                           ; to the kernel base  which is where a paste site
                                                               ; always stands
                                                               ; ASSERT ptr=17
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
<                                                              ; the carry in is nought or one  so it takes the old
                                                               ; kernel
  [->>+<<]
>>
                                                               ; ASSERT ptr=18
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; store the sum back into a5
  [-<<<<<<<<<<<<+>>>>>>>>>>>>]
>>                                                             ; the carry out becomes the carry in for the next byte
  [-<<<+>>>]
<<<                                                            ; back to the carry in
                                                               ; ASSERT ptr=16
                                                               ; ASSERT zero 17:27

; ============================================================ ; byte 6 : a @0x06  b @0x0e
<<<<<<<<<<                                                     ; move a6 into the accumulator
                                                               ; ASSERT ptr=6
  [->>>>>>>>>>>+<<<<<<<<<<<]
>>>>>>>>                                                       ; move b6 into the addend
  [->>>>+<<<<]
>>>                                                            ; to the kernel base  which is where a paste site
                                                               ; always stands
                                                               ; ASSERT ptr=17
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
<                                                              ; the carry in is nought or one  so it takes the old
                                                               ; kernel
  [->>+<<]
>>
                                                               ; ASSERT ptr=18
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; store the sum back into a6
  [-<<<<<<<<<<<+>>>>>>>>>>>]
>>                                                             ; the carry out becomes the carry in for the next byte
  [-<<<+>>>]
<<<                                                            ; back to the carry in
                                                               ; ASSERT ptr=16
                                                               ; ASSERT zero 17:27

; ============================================================ ; byte 7 : a @0x07  b @0x0f
<<<<<<<<<                                                      ; move a7 into the accumulator
                                                               ; ASSERT ptr=7
  [->>>>>>>>>>+<<<<<<<<<<]
>>>>>>>>                                                       ; move b7 into the addend
  [->>>+<<<]
>>                                                             ; to the kernel base  which is where a paste site
                                                               ; always stands
                                                               ; ASSERT ptr=17
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
<                                                              ; the carry in is nought or one  so it takes the old
                                                               ; kernel
  [->>+<<]
>>
                                                               ; ASSERT ptr=18
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; store the sum back into a7
  [-<<<<<<<<<<+>>>>>>>>>>]
>>                                                             ; the carry out becomes the carry in for the next byte
  [-<<<+>>>]
<<<                                                            ; back to the carry in
                                                               ; ASSERT ptr=16
                                                               ; ASSERT zero 17:27

; ============================================================ ; the carry out of byte 7 is the final carry  and it is
                                                               ; dropped
  [-]
                                                               ; ASSERT ptr=16
                                                               ; the addend has been consumed and every scratch cell
                                                               ; is back at nought; a{8} is NOT clear  because a{8} is
                                                               ; the answer;
                                                               ; ASSERT zero 8:27

; emit
<<<<<<<<<<<<<<<<                                               ; the sum  eight bytes little endian
  .>.>.>.>.>.>.>.
