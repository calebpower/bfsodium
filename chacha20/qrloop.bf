; bfsodium QRLOOP : the ChaCha20 quarter round as a LOOP  not twelve unrolled ops
;
; HAND WRITTEN; Every tape offset below is one I worked out and wrote as a
; number; the tokens Rn and Ln mean n steps right and n steps left and are
; expanded literally by tools/bfexpand; That is a NOTATION  not a compiler: it
; makes no decision and computes no offset  it only saves me miscounting a run
; of forty six arrows  which is exactly the error that broke the first draft;
;
; The three arithmetic routines are the already verified bodies of add32
; xor32 and rotl32  pasted in ONCE each rather than twelve times;
;
; INTERFACE entry=15 exit=0 footprint=0:58
; IO  in:  a{4} LE  b{4} LE  c{4} LE  d{4} LE   (16 bytes)
;     out: the same four words after one quarter round   (16 bytes)
;
; TAPE MAP  (home @0)
;   @0x00:0x03  a{4}   u8 LE
;   @0x04:0x07  b{4}   u8 LE
;   @0x08:0x0b  c{4}   u8 LE
;   @0x0c:0x0f  d{4}   u8 LE
;   @0x10:0x17  swap{8}     temps for exchanging the two halves of the state
;   @0x18:0x31  W{26}       the workspace; the pasted routines address it as
;                           their own cell zero  which is @0x18 here
;   @0x32:0x35  T{4}        temps  so an operand can be read without being eaten
;   @0x36:0x39  rot{4}      the counts 16 12 8 7  rotated left by one each step
;                           so a step always reads @0x36
;   @0x3a       cnt         four steps
;
; Cryptol PROVES (spec/perm_cry  looped_matches  Q;E;D; over every input) that
; the quarter round is four IDENTICAL steps: a gets a plus b  then d gets
; d xor a rotated left r  and the four words are then permuted (a b c d) to
; (c d a b); That permutation is its own inverse  so after four steps the words
; are back in place and no step ever needs a different pair of operands; Since
; a b is the low half of the state and c d the high half  the permutation is
; just an exchange of the two halves;

  ,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,                              ; read a b c d
; Everything above the four operands must be clear on entry; A caller that
; pastes this routine into a loop enters it many times  and the rotation table
; below is built by adding to whatever is already in those cells  so a routine
; that left them dirty would quietly rotate by the wrong count on every entry
; after the first;
; ASSERT ptr=15
; ASSERT zero 16:58
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>                        ; to the rotation table
  ++++++++++++++++                                             ; the counts sixteen twelve eight seven
>                                                              ; the next byte
  ++++++++++++
>                                                              ; the next byte
  ++++++++
>                                                              ; the next byte
  +++++++
; four steps
; the next byte
>
  ++++

[
  -

; ================ a gets a plus b ================
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<     ; to a
; ASSERT ptr=0
  [->>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<]         ; move a into the workspace
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<]
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<]
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<]
; to b
; the next byte
>
  [->>>>>>>>>>>>>>>>>>>>>>>>+>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<   ; copy b beside it  keeping b by passing each byte
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]                      ; through a temp
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>+>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]                      ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>+>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]                      ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>+>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]                      ; continued
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>                    ; to the temps
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>   ; put them back into b
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]                       ; continued
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]                       ; continued
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]                       ; continued
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]                       ; continued
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<                                  ; to the adder base
; ASSERT ptr=24
; ASSERT zero 32:37
; walk in to this routine entry offset
  >>>>>>>>
                                                               ; @0x08

; ==== byte 0 : a @0x00  b @0x04 ====
  <<<<<<<< [->>>>>>>>>+<<<<<<<<<]                              ; move a0 into x
  >>>> [->>>>>>+<<<<<<]                                        ; move b0 into y
  >>>>>> [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]      ; ADD8 y into x
  << [->>+<<]                                                  ; move cin into y
  >> [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]          ; ADD8 cin into x
  < [-<<<<<<<<<+>>>>>>>>>]                                     ; store x into a0
  >> [-<<<+>>>]                                                ; carry c into cin
  <<<                                                          ; back to cin

; ==== byte 1 : a @0x01  b @0x05 ====
  <<<<<<< [->>>>>>>>+<<<<<<<<]                                 ; move a1 into x
  >>>> [->>>>>+<<<<<]                                          ; move b1 into y
  >>>>> [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]       ; ADD8 y into x
  << [->>+<<]                                                  ; move cin into y
  >> [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]          ; ADD8 cin into x
  < [-<<<<<<<<+>>>>>>>>]                                       ; store x into a1
  >> [-<<<+>>>]                                                ; carry c into cin
  <<<                                                          ; back to cin

; ==== byte 2 : a @0x02  b @0x06 ====
  <<<<<< [->>>>>>>+<<<<<<<]                                    ; move a2 into x
  >>>> [->>>>+<<<<]                                            ; move b2 into y
  >>>> [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]        ; ADD8 y into x
  << [->>+<<]                                                  ; move cin into y
  >> [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]          ; ADD8 cin into x
  < [-<<<<<<<+>>>>>>>]                                         ; store x into a2
  >> [-<<<+>>>]                                                ; carry c into cin
  <<<                                                          ; back to cin

; ==== byte 3 : a @0x03  b @0x07 ====
  <<<<< [->>>>>>+<<<<<<]                                       ; move a3 into x
  >>>> [->>>+<<<]                                              ; move b3 into y
  >>> [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]         ; ADD8 y into x
  << [->>+<<]                                                  ; move cin into y
  >> [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]          ; ADD8 cin into x
  < [-<<<<<<+>>>>>>]                                           ; store x into a3
  >> [-<<<+>>>]                                                ; carry c into cin
  <<<                                                          ; back to cin (dropped)

; walk back out to the routine base
  <<<<<<<<
; ASSERT ptr=24
>>>>>>>>                                                       ; to the carry cell and drop it
  [-]
<<<<<<<<
  [-<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>]         ; move the sum back into a
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>]
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>]
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>]

; ================ d gets d xor a ================
<<<<<<<<<<<<<<<                                                ; to d
  [->>>>>>>>>>>>+<<<<<<<<<<<<]                                 ; move d into the workspace
>                                                              ; the next byte
  [->>>>>>>>>>>>+<<<<<<<<<<<<]
>                                                              ; the next byte
  [->>>>>>>>>>>>+<<<<<<<<<<<<]
>                                                              ; the next byte
  [->>>>>>>>>>>>+<<<<<<<<<<<<]
<<<<<<<<<<<<<<<                                                ; to a
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>+>>>>>>>>>>>>>>>>>>>>>>+<<<<   ; copy a beside it  keeping a
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]              ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>+>>>>>>>>>>>>>>>>>>>>>>+<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]              ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>+>>>>>>>>>>>>>>>>>>>>>>+<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]              ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>+>>>>>>>>>>>>>>>>>>>>>>+<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]              ; continued
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>                ; to the temps
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>   ; put them back into a
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]               ; continued
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]               ; continued
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]               ; continued
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]               ; continued
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<                                  ; to the exclusive or base
; ASSERT ptr=24
; ASSERT zero 32:49
; walk in to this routine entry offset
  >>>>>>>>
                                                               ; @0x08

; ==== byte 0 : x0 @0x00  y0 @0x04  into r0 @0x08 ====
  <<<<<<<< [->>>>>>>>>>>>+<<<<<<<<<<<<]                        ; move x0 into a
  >>>> [->>>>>>>>>>>>+<<<<<<<<<<<<]                            ; move y0 into b
  >>>>>>>>>>>>>>>>>>> +                                        ; p := 1
  > ++++++++                                                   ; cnt := 8
  [-                                                           ; ____ eight bit steps ____
  <<<<<<<<<<<< [->>>+<[-<+>>-<]>[-<+>]<<<]                     ; HALVE a  giving qa and pa
  >>>> [->>>+<[-<+>>-<]>[-<+>]<<<]                             ; HALVE b  giving qb and pb
  << [->>>>>>>+<[->-<]>[-<+>]<<<<<<<]                          ; low bit of a toggles t
  >>>> [->>>+<[->-<]>[-<+>]<<<]                                ; low bit of b toggles t
  >> [->>>[-<+>>>+<<]>>[-<<+>>]<<<<<]                          ; if t then res gets p
  <<<<<<< [-<+>]                                               ; a := qa
  >>>> [-<+>]                                                  ; b := qb
  >>>>>> [->>+<<]                                              ; p into tmp
  >> [-<<++>>]                                                 ; p := tmp doubled
  <                                                            ; back to cnt
  ]
  << [-<<<<<<<<<<<<<<+>>>>>>>>>>>>>>]                          ; store res into r0
  <<<<<<<<<<<<<<                                               ; back to r0

; ==== byte 1 : x1 @0x01  y1 @0x05  into r1 @0x09 ====
  <<<<<<< [->>>>>>>>>>>+<<<<<<<<<<<]                           ; move x1 into a
  >>>> [->>>>>>>>>>>+<<<<<<<<<<<]                              ; move y1 into b
  >>>>>>>>>>>>>>>>>> +                                         ; p := 1
  > ++++++++                                                   ; cnt := 8
  [-
  <<<<<<<<<<<< [->>>+<[-<+>>-<]>[-<+>]<<<]                     ; HALVE a  giving qa and pa
  >>>> [->>>+<[-<+>>-<]>[-<+>]<<<]                             ; HALVE b  giving qb and pb
  << [->>>>>>>+<[->-<]>[-<+>]<<<<<<<]                          ; low bit of a toggles t
  >>>> [->>>+<[->-<]>[-<+>]<<<]                                ; low bit of b toggles t
  >> [->>>[-<+>>>+<<]>>[-<<+>>]<<<<<]                          ; if t then res gets p
  <<<<<<< [-<+>]                                               ; a := qa
  >>>> [-<+>]                                                  ; b := qb
  >>>>>> [->>+<<]                                              ; p into tmp
  >> [-<<++>>]                                                 ; p := tmp doubled
  <                                                            ; back to cnt
  ]
  << [-<<<<<<<<<<<<<+>>>>>>>>>>>>>]                            ; store res into r1
  <<<<<<<<<<<<<<                                               ; back to r0

; ==== byte 2 : x2 @0x02  y2 @0x06  into r2 @0x0a ====
  <<<<<< [->>>>>>>>>>+<<<<<<<<<<]                              ; move x2 into a
  >>>> [->>>>>>>>>>+<<<<<<<<<<]                                ; move y2 into b
  >>>>>>>>>>>>>>>>> +                                          ; p := 1
  > ++++++++                                                   ; cnt := 8
  [-
  <<<<<<<<<<<< [->>>+<[-<+>>-<]>[-<+>]<<<]                     ; HALVE a  giving qa and pa
  >>>> [->>>+<[-<+>>-<]>[-<+>]<<<]                             ; HALVE b  giving qb and pb
  << [->>>>>>>+<[->-<]>[-<+>]<<<<<<<]                          ; low bit of a toggles t
  >>>> [->>>+<[->-<]>[-<+>]<<<]                                ; low bit of b toggles t
  >> [->>>[-<+>>>+<<]>>[-<<+>>]<<<<<]                          ; if t then res gets p
  <<<<<<< [-<+>]                                               ; a := qa
  >>>> [-<+>]                                                  ; b := qb
  >>>>>> [->>+<<]                                              ; p into tmp
  >> [-<<++>>]                                                 ; p := tmp doubled
  <                                                            ; back to cnt
  ]
  << [-<<<<<<<<<<<<+>>>>>>>>>>>>]                              ; store res into r2
  <<<<<<<<<<<<<<                                               ; back to r0

; ==== byte 3 : x3 @0x03  y3 @0x07  into r3 @0x0b ====
  <<<<< [->>>>>>>>>+<<<<<<<<<]                                 ; move x3 into a
  >>>> [->>>>>>>>>+<<<<<<<<<]                                  ; move y3 into b
  >>>>>>>>>>>>>>>> +                                           ; p := 1
  > ++++++++                                                   ; cnt := 8
  [-
  <<<<<<<<<<<< [->>>+<[-<+>>-<]>[-<+>]<<<]                     ; HALVE a  giving qa and pa
  >>>> [->>>+<[-<+>>-<]>[-<+>]<<<]                             ; HALVE b  giving qb and pb
  << [->>>>>>>+<[->-<]>[-<+>]<<<<<<<]                          ; low bit of a toggles t
  >>>> [->>>+<[->-<]>[-<+>]<<<]                                ; low bit of b toggles t
  >> [->>>[-<+>>>+<<]>>[-<<+>>]<<<<<]                          ; if t then res gets p
  <<<<<<< [-<+>]                                               ; a := qa
  >>>> [-<+>]                                                  ; b := qb
  >>>>>> [->>+<<]                                              ; p into tmp
  >> [-<<++>>]                                                 ; p := tmp doubled
  <                                                            ; back to cnt
  ]
  << [-<<<<<<<<<<<+>>>>>>>>>>>]                                ; store res into r3
  <<<<<<<<<<<<<<                                               ; back to r0

; walk back out to the routine base
  <<<<<<<<
; ASSERT ptr=24
>>>>>>>>                                                       ; to the result
  [-<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>]                 ; move the result back into d
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>]
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>]
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>]

; ================ d rotates left by this step's count ================
<<<<<<<<<<<<<<<<<<<<<<<                                        ; to d
  [->>>>>>>>>>>>+<<<<<<<<<<<<]                                 ; move d into the workspace
>                                                              ; the next byte
  [->>>>>>>>>>>>+<<<<<<<<<<<<]
>                                                              ; the next byte
  [->>>>>>>>>>>>+<<<<<<<<<<<<]
>                                                              ; the next byte
  [->>>>>>>>>>>>+<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>                        ; to the rotation table
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>+>>>>]    ; copy this step's count beside the word  keeping the
                                                               ; table
<<<<                                                           ; put the temp back
  [->>>>+<<<<]
<<<<<<<<<<<<<<<<<<<<<<<<<<                                     ; to the rotate base
; ASSERT ptr=24
; ASSERT zero 29:37
; walk in to this routine entry offset
  >>>>

; ==== rotate one bit  n times ====
[
  -                                                            ; one step consumed

; ____ double byte 0 @0x00  carry into c0 @0x05 ____
; move w0 into x
  <<<< [->>>>>>>>>+<<<<<<<<<]
  >>>>>>>>> [->+>>+<<<] >>>[-<<<+>>>] <<<                      ; y := x  x restored
  > [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]           ; ADD8 y into x
  < [-<<<<<<<<<+>>>>>>>>>]                                     ; store x into w0
  >> [-<<<<<<+>>>>>>]                                          ; carry into c0
  <<<<<<<                                                      ; back to n

; ____ double byte 1 @0x01  carry into c1 @0x06 ____
; move w1 into x
  <<< [->>>>>>>>+<<<<<<<<]
  >>>>>>>> [->+>>+<<<] >>>[-<<<+>>>] <<<                       ; y := x  x restored
  > [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]           ; ADD8 y into x
  < [-<<<<<<<<+>>>>>>>>]                                       ; store x into w1
  >> [-<<<<<+>>>>>]                                            ; carry into c1
  <<<<<<<                                                      ; back to n

; ____ double byte 2 @0x02  carry into c2 @0x07 ____
; move w2 into x
  << [->>>>>>>+<<<<<<<]
  >>>>>>> [->+>>+<<<] >>>[-<<<+>>>] <<<                        ; y := x  x restored
  > [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]           ; ADD8 y into x
  < [-<<<<<<<+>>>>>>>]                                         ; store x into w2
  >> [-<<<<+>>>>]                                              ; carry into c2
  <<<<<<<                                                      ; back to n

; ____ double byte 3 @0x03  carry into c3 @0x08 ____
; move w3 into x
  < [->>>>>>+<<<<<<]
  >>>>>> [->+>>+<<<] >>>[-<<<+>>>] <<<                         ; y := x  x restored
  > [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]           ; ADD8 y into x
  < [-<<<<<<+>>>>>>]                                           ; store x into w3
  >> [-<<<+>>>]                                                ; carry into c3
  <<<<<<<                                                      ; back to n

; ____ feed the carries around the cycle ____
; w0 gets c3
  >>>> [-<<<<<<<<+>>>>>>>>]
  <<< [-<<<<+>>>>]                                             ; w1 gets c0
  > [-<<<<+>>>>]                                               ; w2 gets c1
  > [-<<<<+>>>>]                                               ; w3 gets c2
  <<<                                                          ; back to n
]

; walk back out to the routine base
  <<<<
; ASSERT ptr=24
  [-<<<<<<<<<<<<+>>>>>>>>>>>>]                                 ; move the rotated word back into d
>                                                              ; the next byte
  [-<<<<<<<<<<<<+>>>>>>>>>>>>]
>                                                              ; the next byte
  [-<<<<<<<<<<<<+>>>>>>>>>>>>]
>                                                              ; the next byte
  [-<<<<<<<<<<<<+>>>>>>>>>>>>]

; ================ permute: exchange the low and high halves ================
<<<<<<<<<<<<<<<<<<<<<<<<<<<                                    ; to a
  [->>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<]                         ; byte 0
>>>>>>>>
  [-<<<<<<<<+>>>>>>>>]
>>>>>>>>
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<<<<<<<<<
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<]                         ; byte 1
>>>>>>>>
  [-<<<<<<<<+>>>>>>>>]
>>>>>>>>
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<<<<<<<<<
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<]                         ; byte 2
>>>>>>>>
  [-<<<<<<<<+>>>>>>>>]
>>>>>>>>
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<<<<<<<<<
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<]                         ; byte 3
>>>>>>>>
  [-<<<<<<<<+>>>>>>>>]
>>>>>>>>
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<<<<<<<<<
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<]                         ; byte 4
>>>>>>>>
  [-<<<<<<<<+>>>>>>>>]
>>>>>>>>
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<<<<<<<<<
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<]                         ; byte 5
>>>>>>>>
  [-<<<<<<<<+>>>>>>>>]
>>>>>>>>
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<<<<<<<<<
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<]                         ; byte 6
>>>>>>>>
  [-<<<<<<<<+>>>>>>>>]
>>>>>>>>
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<<<<<<<<<
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<]                         ; byte 7
>>>>>>>>
  [-<<<<<<<<+>>>>>>>>]
>>>>>>>>
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<<<<<<<<<

; ================ rotate the count table left by one ================
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>                ; to the table
  [-<<<<+>>>>]                                                 ; the used count goes to a temp
; the other three shuffle down
; the next byte
>
  [-<+>]
>                                                              ; the next byte
  [-<+>]
>                                                              ; the next byte
  [-<+>]
<<<<<<<                                                        ; to the temp
  [->>>>>>>+<<<<<<<]                                           ; and the used count becomes the last
>>>>>>>>                                                       ; back to the step counter
; ASSERT ptr=58
; ASSERT zero 16:23
]

; Four rotations put the four counts back exactly where they started  so they
; are still sitting in the table; Clear them; The step counter is already zero
; and the workspace and the temps are emptied as they are used  so once the
; table is gone every cell above the four operands is clear and the routine can
; be entered again with the same effect as the first time;
; ASSERT ptr=58
<<<<
  [-]
>                                                              ; the next byte
  [-]
>                                                              ; the next byte
  [-]
>                                                              ; the next byte
  [-]
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<      ; to the start of the state
; ASSERT ptr=0
; ASSERT zero 16:58
; emit a b c d
  .>.>.>.>.>.>.>.>.>.>.>.>.>.>.>.
