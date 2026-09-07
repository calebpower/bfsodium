; bfsodium ADD136 : 17 byte little endian addition
;
; HAND WRITTEN; the same shape as chacha20/add32  seventeen bytes wide instead
; of four  and using the SAME ADD8 kernel  which chacha20/add32 already holds to
; the RFC vectors;
;
; INTERFACE entry=34 exit=34 footprint=0:39
; IO  in:  a{17} LE  followed by  b{17} LE     (34 bytes)
;     out: (a plus b mod 2^136){17} LE         (17 bytes)
;
; TAPE MAP  (home @0)
;   @0x00:0x10  a{17}  u8   the accumulator  and the result  LSB at @0x00
;   @0x11:0x21  b{17}  u8   the addend  consumed to nought
;   @0x22       cin    u8   carry into the current byte
;   @0x23       x      u8   ADD8 frame: accumulator
;   @0x24       y      u8   ADD8 frame: addend  consumed to nought
;   @0x25       c      u8   ADD8 frame: carry out
;   @0x26       t0     u8   ADD8 frame scratch  restored to nought
;   @0x27       t1     u8   ADD8 frame scratch  restored to nought
;
; ADD8 kernel  (enter at y @0x24  exit at y @0x24):
;   adds y into x modulo 256  sets y to nought  adds the carry into c  and
;   restores the scratch; It detects the single wrap of x by copying x into two
;   temps  bumping c tentatively  then undoing that bump unless the copy was
;   nought; A byte sum is at most 511  so x wraps at most once  and the two ADD8
;   calls per byte can never both carry;
;
; The carry out of the top byte is dropped  the sum being modulo two to the
; hundred and thirty sixth; It is CLEARED rather than left lying  and the frame
; is asserted clear on entry as well  so this routine may be pasted inside a
; loop and entered again and again; fold136 does exactly that  five times over;

  ,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>                     ; read a{0:16} then b{0:16}  leaving the pointer on the
                                                               ; carry in
; continued
  ,>,>,>,>,>,>,>,>,>,>,>,>,>,>
; ASSERT ptr=34
; ASSERT zero 34:39

; ==== byte 0 ====
; ASSERT ptr=34
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<                             ; the accumulator byte steps into the adder
; ASSERT ptr=0
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<]                                             ; continued
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>>                                            ; add the addend into the accumulator byte
; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<<                                                             ; the carry in follows it
  [->>+<<]
>>                                                             ; add that in too
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>]                                             ; continued
>>                                                             ; the carry out becomes the carry in of the byte above
  [-<<<+>>>]
<<<

; ==== byte 1 ====
; ASSERT ptr=34
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<                              ; the accumulator byte steps into the adder
; ASSERT ptr=1
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<]                                               ; continued
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>                                             ; add the addend into the accumulator byte
; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<<                                                             ; the carry in follows it
  [->>+<<]
>>                                                             ; add that in too
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>]                                               ; continued
>>                                                             ; the carry out becomes the carry in of the byte above
  [-<<<+>>>]
<<<

; ==== byte 2 ====
; ASSERT ptr=34
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<                               ; the accumulator byte steps into the adder
; ASSERT ptr=2
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<]                                                 ; continued
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>                                              ; add the addend into the accumulator byte
; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<<                                                             ; the carry in follows it
  [->>+<<]
>>                                                             ; add that in too
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>]                                                 ; continued
>>                                                             ; the carry out becomes the carry in of the byte above
  [-<<<+>>>]
<<<

; ==== byte 3 ====
; ASSERT ptr=34
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<                                ; the accumulator byte steps into the adder
; ASSERT ptr=3
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<]                                                   ; continued
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>                                               ; add the addend into the accumulator byte
; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<<                                                             ; the carry in follows it
  [->>+<<]
>>                                                             ; add that in too
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>]                                                   ; continued
>>                                                             ; the carry out becomes the carry in of the byte above
  [-<<<+>>>]
<<<

; ==== byte 4 ====
; ASSERT ptr=34
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<                                 ; the accumulator byte steps into the adder
; ASSERT ptr=4
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<]                                                     ; continued
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>                                                ; add the addend into the accumulator byte
; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<<                                                             ; the carry in follows it
  [->>+<<]
>>                                                             ; add that in too
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>]                                                     ; continued
>>                                                             ; the carry out becomes the carry in of the byte above
  [-<<<+>>>]
<<<

; ==== byte 5 ====
; ASSERT ptr=34
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<                                  ; the accumulator byte steps into the adder
; ASSERT ptr=5
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<]                                                       ; continued
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>>>>>>>>>>>>+<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>                                                 ; add the addend into the accumulator byte
; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<<                                                             ; the carry in follows it
  [->>+<<]
>>                                                             ; add that in too
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>]                                                       ; continued
>>                                                             ; the carry out becomes the carry in of the byte above
  [-<<<+>>>]
<<<

; ==== byte 6 ====
; ASSERT ptr=34
<<<<<<<<<<<<<<<<<<<<<<<<<<<<                                   ; the accumulator byte steps into the adder
; ASSERT ptr=6
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<]                                                         ; continued
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>>>>>>>>>>>+<<<<<<<<<<<<<]
>>>>>>>>>>>>>                                                  ; add the addend into the accumulator byte
; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<<                                                             ; the carry in follows it
  [->>+<<]
>>                                                             ; add that in too
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>]                                                         ; continued
>>                                                             ; the carry out becomes the carry in of the byte above
  [-<<<+>>>]
<<<

; ==== byte 7 ====
; ASSERT ptr=34
<<<<<<<<<<<<<<<<<<<<<<<<<<<                                    ; the accumulator byte steps into the adder
; ASSERT ptr=7
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <]                                                           ; continued
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>>>>>>>>>>+<<<<<<<<<<<<]
>>>>>>>>>>>>                                                   ; add the addend into the accumulator byte
; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<<                                                             ; the carry in follows it
  [->>+<<]
>>                                                             ; add that in too
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >]                                                           ; continued
>>                                                             ; the carry out becomes the carry in of the byte above
  [-<<<+>>>]
<<<

; ==== byte 8 ====
; ASSERT ptr=34
<<<<<<<<<<<<<<<<<<<<<<<<<<                                     ; the accumulator byte steps into the adder
; ASSERT ptr=8
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>>>>>>>>>+<<<<<<<<<<<]
>>>>>>>>>>>                                                    ; add the addend into the accumulator byte
; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<<                                                             ; the carry in follows it
  [->>+<<]
>>                                                             ; add that in too
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>>]
>>                                                             ; the carry out becomes the carry in of the byte above
  [-<<<+>>>]
<<<

; ==== byte 9 ====
; ASSERT ptr=34
<<<<<<<<<<<<<<<<<<<<<<<<<                                      ; the accumulator byte steps into the adder
; ASSERT ptr=9
  [->>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>>>>>>>>+<<<<<<<<<<]
>>>>>>>>>>                                                     ; add the addend into the accumulator byte
; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<<                                                             ; the carry in follows it
  [->>+<<]
>>                                                             ; add that in too
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>]
>>                                                             ; the carry out becomes the carry in of the byte above
  [-<<<+>>>]
<<<

; ==== byte 10 ====
; ASSERT ptr=34
<<<<<<<<<<<<<<<<<<<<<<<<                                       ; the accumulator byte steps into the adder
; ASSERT ptr=10
  [->>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>>>>>>>+<<<<<<<<<]
>>>>>>>>>                                                      ; add the addend into the accumulator byte
; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<<                                                             ; the carry in follows it
  [->>+<<]
>>                                                             ; add that in too
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>]
>>                                                             ; the carry out becomes the carry in of the byte above
  [-<<<+>>>]
<<<

; ==== byte 11 ====
; ASSERT ptr=34
<<<<<<<<<<<<<<<<<<<<<<<                                        ; the accumulator byte steps into the adder
; ASSERT ptr=11
  [->>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>>>>>>+<<<<<<<<]
>>>>>>>>                                                       ; add the addend into the accumulator byte
; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<<                                                             ; the carry in follows it
  [->>+<<]
>>                                                             ; add that in too
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>]
>>                                                             ; the carry out becomes the carry in of the byte above
  [-<<<+>>>]
<<<

; ==== byte 12 ====
; ASSERT ptr=34
<<<<<<<<<<<<<<<<<<<<<<                                         ; the accumulator byte steps into the adder
; ASSERT ptr=12
  [->>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>>>>>+<<<<<<<]
>>>>>>>                                                        ; add the addend into the accumulator byte
; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<<                                                             ; the carry in follows it
  [->>+<<]
>>                                                             ; add that in too
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>]
>>                                                             ; the carry out becomes the carry in of the byte above
  [-<<<+>>>]
<<<

; ==== byte 13 ====
; ASSERT ptr=34
<<<<<<<<<<<<<<<<<<<<<                                          ; the accumulator byte steps into the adder
; ASSERT ptr=13
  [->>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>>>>+<<<<<<]
>>>>>>                                                         ; add the addend into the accumulator byte
; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<<                                                             ; the carry in follows it
  [->>+<<]
>>                                                             ; add that in too
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>]
>>                                                             ; the carry out becomes the carry in of the byte above
  [-<<<+>>>]
<<<

; ==== byte 14 ====
; ASSERT ptr=34
<<<<<<<<<<<<<<<<<<<<                                           ; the accumulator byte steps into the adder
; ASSERT ptr=14
  [->>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>>>+<<<<<]
>>>>>                                                          ; add the addend into the accumulator byte
; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<<                                                             ; the carry in follows it
  [->>+<<]
>>                                                             ; add that in too
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>]
>>                                                             ; the carry out becomes the carry in of the byte above
  [-<<<+>>>]
<<<

; ==== byte 15 ====
; ASSERT ptr=34
<<<<<<<<<<<<<<<<<<<                                            ; the accumulator byte steps into the adder
; ASSERT ptr=15
  [->>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>>+<<<<]
>>>>                                                           ; add the addend into the accumulator byte
; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<<                                                             ; the carry in follows it
  [->>+<<]
>>                                                             ; add that in too
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>]
>>                                                             ; the carry out becomes the carry in of the byte above
  [-<<<+>>>]
<<<

; ==== byte 16 ====
; ASSERT ptr=34
<<<<<<<<<<<<<<<<<<                                             ; the accumulator byte steps into the adder
; ASSERT ptr=16
  [->>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>+<<<]
>>>                                                            ; add the addend into the accumulator byte
; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<<                                                             ; the carry in follows it
  [->>+<<]
>>                                                             ; add that in too
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>]
>>                                                             ; the carry out becomes the carry in of the byte above
  [-<<<+>>>]
<<<

; the carry out of the top byte is dropped  and cleared so the frame is as
; empty as it was found
; ASSERT ptr=34
  [-]
; ASSERT zero 17:39
; emit the sum little endian
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; ASSERT ptr=0
  .>.>.>.>.>.>.>.>.>.>.>.>.>.>.>.>.
