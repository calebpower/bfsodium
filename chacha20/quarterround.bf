; bfsodium ChaCha20 QUARTERROUND (RFC 8439 section 2;2;1)
;
; ASSEMBLED FILE: emitted by tools/qrasm;sh from the verified bodies of
; add32;bf  xor32;bf and rotl32;bf; those primitives each pass dual oracle
; KATs  and brainfuck is position independent  so their code is reused here
; verbatim rather than retyped at new offsets;
;
; IO  in:  a{4} LE  b{4} LE  c{4} LE  d{4} LE      (16 bytes)
;     out: the same four words after one quarter round (16 bytes)
;
; TAPE MAP  (home @0)
;   @0x00:0x03  a{4}  u8 LE
;   @0x04:0x07  b{4}  u8 LE
;   @0x08:0x0b  c{4}  u8 LE
;   @0x0c:0x0f  d{4}  u8 LE
;   @0x10       W     the shared workspace base; EVERY embedded body below
;                     addresses cells relative to W  so an "@0x00" inside an
;                     embedded block means cell @0x10 here  "@0x04" means
;                     @0x14  and so on;
;   @0x2a:0x2d  copy temps  so an operand survives being read
;
; The quarter round is four repetitions of the same shape:
;   a gets a plus b ; d gets d xor a ; d rotates left r
; with the roles and r cycling (a b d 16) (c d b 12) (a b d 8) (c d b 7);

; read a b c d  leaving the pointer on d3 @0x0f
,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,

; ================ round 1 : a b d  rotate 16 ================
  <<<<<<<<<<<<<<<   ; move the pointer to @00
; ____ ADD32 : word at @0x00 gets word at @0x04 ____
  [->>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<]>   ; move byte 0 of @00 to @10
  [->>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<]>   ; move byte 1 of @01 to @11
  [->>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<]>   ; move byte 2 of @02 to @12
  [->>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<]   ; move byte 3 of @03 to @13
  >   ; move the pointer to @04
  [->>>>>>>>>>>>>>>>+>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]>   ; byte 0 of @04 to @14 and to temp
  [->>>>>>>>>>>>>>>>+>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]>   ; byte 1 of @05 to @15 and to temp
  [->>>>>>>>>>>>>>>>+>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]>   ; byte 2 of @06 to @16 and to temp
  [->>>>>>>>>>>>>>>>+>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]   ; byte 3 of @07 to @17 and to temp
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; walk to the temps
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]>   ; put temp byte 0 back into @04
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]>   ; put temp byte 1 back into @05
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]>   ; put temp byte 2 back into @06
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]   ; put temp byte 3 back into @07
  <<<<<<<<<<<<<<<<<<<<<   ; move the pointer to @18

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
[-]                          ; drop the final carry
  <<<<<<<<   ; move the pointer to @10
  [-<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>]>   ; move byte 0 of @10 to @00
  [-<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>]>   ; move byte 1 of @11 to @01
  [-<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>]>   ; move byte 2 of @12 to @02
  [-<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>]   ; move byte 3 of @13 to @03
  <<<<<<<<<<<<<<<<<<<   ; move the pointer to @00
; ____ XOR32 : word at @0x0c gets word at @0x00 ____
  >>>>>>>>>>>>   ; move the pointer to @0c
  [->>>>+<<<<]>   ; move byte 0 of @0c to @10
  [->>>>+<<<<]>   ; move byte 1 of @0d to @11
  [->>>>+<<<<]>   ; move byte 2 of @0e to @12
  [->>>>+<<<<]   ; move byte 3 of @0f to @13
  <<<<<<<<<<<<<<<   ; move the pointer to @00
  [->>>>>>>>>>>>>>>>>>>>+>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]>   ; byte 0 of @00 to @14 and to temp
  [->>>>>>>>>>>>>>>>>>>>+>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]>   ; byte 1 of @01 to @15 and to temp
  [->>>>>>>>>>>>>>>>>>>>+>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]>   ; byte 2 of @02 to @16 and to temp
  [->>>>>>>>>>>>>>>>>>>>+>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]   ; byte 3 of @03 to @17 and to temp
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; walk to the temps
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]>   ; put temp byte 0 back into @00
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]>   ; put temp byte 1 back into @01
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]>   ; put temp byte 2 back into @02
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]   ; put temp byte 3 back into @03
  <<<<<<<<<<<<<<<<<<<<<   ; move the pointer to @18

; ==== byte 0 : x0 @0x00  y0 @0x04  into r0 @0x08 ====
  <<<<<<<< [->>>>>>>>>>>>+<<<<<<<<<<<<]              ; move x0 into a
  >>>> [->>>>>>>>>>>>+<<<<<<<<<<<<]                  ; move y0 into b
  >>>>>>>>>>>>>>>>>>> +                              ; p := 1
  > ++++++++                                         ; cnt := 8
  [-                                                 ; ____ eight bit steps ____
    <<<<<<<<<<<< [->>>+<[-<+>>-<]>[-<+>]<<<]         ; HALVE a  giving qa and pa
    >>>> [->>>+<[-<+>>-<]>[-<+>]<<<]                 ; HALVE b  giving qb and pb
    << [->>>>>>>+<[->-<]>[-<+>]<<<<<<<]              ; low bit of a toggles t
    >>>> [->>>+<[->-<]>[-<+>]<<<]                    ; low bit of b toggles t
    >> [->>>[-<+>>>+<<]>>[-<<+>>]<<<<<]              ; if t then res gets p
    <<<<<<< [-<+>]                                   ; a := qa
    >>>> [-<+>]                                      ; b := qb
    >>>>>> [->>+<<]                                  ; p into tmp
    >> [-<<++>>]                                     ; p := tmp doubled
    <                                                ; back to cnt
  ]
  << [-<<<<<<<<<<<<<<+>>>>>>>>>>>>>>]                ; store res into r0
  <<<<<<<<<<<<<<                                     ; back to r0

; ==== byte 1 : x1 @0x01  y1 @0x05  into r1 @0x09 ====
  <<<<<<< [->>>>>>>>>>>+<<<<<<<<<<<]                 ; move x1 into a
  >>>> [->>>>>>>>>>>+<<<<<<<<<<<]                    ; move y1 into b
  >>>>>>>>>>>>>>>>>> +                               ; p := 1
  > ++++++++                                         ; cnt := 8
  [-
    <<<<<<<<<<<< [->>>+<[-<+>>-<]>[-<+>]<<<]         ; HALVE a  giving qa and pa
    >>>> [->>>+<[-<+>>-<]>[-<+>]<<<]                 ; HALVE b  giving qb and pb
    << [->>>>>>>+<[->-<]>[-<+>]<<<<<<<]              ; low bit of a toggles t
    >>>> [->>>+<[->-<]>[-<+>]<<<]                    ; low bit of b toggles t
    >> [->>>[-<+>>>+<<]>>[-<<+>>]<<<<<]              ; if t then res gets p
    <<<<<<< [-<+>]                                   ; a := qa
    >>>> [-<+>]                                      ; b := qb
    >>>>>> [->>+<<]                                  ; p into tmp
    >> [-<<++>>]                                     ; p := tmp doubled
    <                                                ; back to cnt
  ]
  << [-<<<<<<<<<<<<<+>>>>>>>>>>>>>]                  ; store res into r1
  <<<<<<<<<<<<<<                                     ; back to r0

; ==== byte 2 : x2 @0x02  y2 @0x06  into r2 @0x0a ====
  <<<<<< [->>>>>>>>>>+<<<<<<<<<<]                    ; move x2 into a
  >>>> [->>>>>>>>>>+<<<<<<<<<<]                      ; move y2 into b
  >>>>>>>>>>>>>>>>> +                                ; p := 1
  > ++++++++                                         ; cnt := 8
  [-
    <<<<<<<<<<<< [->>>+<[-<+>>-<]>[-<+>]<<<]         ; HALVE a  giving qa and pa
    >>>> [->>>+<[-<+>>-<]>[-<+>]<<<]                 ; HALVE b  giving qb and pb
    << [->>>>>>>+<[->-<]>[-<+>]<<<<<<<]              ; low bit of a toggles t
    >>>> [->>>+<[->-<]>[-<+>]<<<]                    ; low bit of b toggles t
    >> [->>>[-<+>>>+<<]>>[-<<+>>]<<<<<]              ; if t then res gets p
    <<<<<<< [-<+>]                                   ; a := qa
    >>>> [-<+>]                                      ; b := qb
    >>>>>> [->>+<<]                                  ; p into tmp
    >> [-<<++>>]                                     ; p := tmp doubled
    <                                                ; back to cnt
  ]
  << [-<<<<<<<<<<<<+>>>>>>>>>>>>]                    ; store res into r2
  <<<<<<<<<<<<<<                                     ; back to r0

; ==== byte 3 : x3 @0x03  y3 @0x07  into r3 @0x0b ====
  <<<<< [->>>>>>>>>+<<<<<<<<<]                       ; move x3 into a
  >>>> [->>>>>>>>>+<<<<<<<<<]                        ; move y3 into b
  >>>>>>>>>>>>>>>> +                                 ; p := 1
  > ++++++++                                         ; cnt := 8
  [-
    <<<<<<<<<<<< [->>>+<[-<+>>-<]>[-<+>]<<<]         ; HALVE a  giving qa and pa
    >>>> [->>>+<[-<+>>-<]>[-<+>]<<<]                 ; HALVE b  giving qb and pb
    << [->>>>>>>+<[->-<]>[-<+>]<<<<<<<]              ; low bit of a toggles t
    >>>> [->>>+<[->-<]>[-<+>]<<<]                    ; low bit of b toggles t
    >> [->>>[-<+>>>+<<]>>[-<<+>>]<<<<<]              ; if t then res gets p
    <<<<<<< [-<+>]                                   ; a := qa
    >>>> [-<+>]                                      ; b := qb
    >>>>>> [->>+<<]                                  ; p into tmp
    >> [-<<++>>]                                     ; p := tmp doubled
    <                                                ; back to cnt
  ]
  << [-<<<<<<<<<<<+>>>>>>>>>>>]                      ; store res into r3
  <<<<<<<<<<<<<<                                     ; back to r0
  [-<<<<<<<<<<<<+>>>>>>>>>>>>]>   ; move byte 0 of @18 to @0c
  [-<<<<<<<<<<<<+>>>>>>>>>>>>]>   ; move byte 1 of @19 to @0d
  [-<<<<<<<<<<<<+>>>>>>>>>>>>]>   ; move byte 2 of @1a to @0e
  [-<<<<<<<<<<<<+>>>>>>>>>>>>]   ; move byte 3 of @1b to @0f
  <<<<<<<<<<<<<<<<<<<<<<<<<<<   ; move the pointer to @00
; ____ ROTL32 : word at @0x0c rotates left 16 ____
  >>>>>>>>>>>>   ; move the pointer to @0c
  [->>>>+<<<<]>   ; move byte 0 of @0c to @10
  [->>>>+<<<<]>   ; move byte 1 of @0d to @11
  [->>>>+<<<<]>   ; move byte 2 of @0e to @12
  [->>>>+<<<<]   ; move byte 3 of @0f to @13
  >>>>>   ; move the pointer to @14
++++++++++++++++   ; rotation count

; ==== rotate one bit  n times ====
[
  -                                                       ; one step consumed

  ; ____ double byte 0 @0x00  carry into c0 @0x05 ____
  <<<< [->>>>>>>>>+<<<<<<<<<]                             ; move w0 into x
  >>>>>>>>> [->+>>+<<<] >>>[-<<<+>>>] <<<                 ; y := x  x restored
  > [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]      ; ADD8 y into x
  < [-<<<<<<<<<+>>>>>>>>>]                                ; store x into w0
  >> [-<<<<<<+>>>>>>]                                     ; carry into c0
  <<<<<<<                                                 ; back to n

  ; ____ double byte 1 @0x01  carry into c1 @0x06 ____
  <<< [->>>>>>>>+<<<<<<<<]                                ; move w1 into x
  >>>>>>>> [->+>>+<<<] >>>[-<<<+>>>] <<<                  ; y := x  x restored
  > [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]      ; ADD8 y into x
  < [-<<<<<<<<+>>>>>>>>]                                  ; store x into w1
  >> [-<<<<<+>>>>>]                                       ; carry into c1
  <<<<<<<                                                 ; back to n

  ; ____ double byte 2 @0x02  carry into c2 @0x07 ____
  << [->>>>>>>+<<<<<<<]                                   ; move w2 into x
  >>>>>>> [->+>>+<<<] >>>[-<<<+>>>] <<<                   ; y := x  x restored
  > [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]      ; ADD8 y into x
  < [-<<<<<<<+>>>>>>>]                                    ; store x into w2
  >> [-<<<<+>>>>]                                         ; carry into c2
  <<<<<<<                                                 ; back to n

  ; ____ double byte 3 @0x03  carry into c3 @0x08 ____
  < [->>>>>>+<<<<<<]                                      ; move w3 into x
  >>>>>> [->+>>+<<<] >>>[-<<<+>>>] <<<                    ; y := x  x restored
  > [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]      ; ADD8 y into x
  < [-<<<<<<+>>>>>>]                                      ; store x into w3
  >> [-<<<+>>>]                                           ; carry into c3
  <<<<<<<                                                 ; back to n

  ; ____ feed the carries around the cycle ____
  >>>> [-<<<<<<<<+>>>>>>>>]                               ; w0 gets c3
  <<< [-<<<<+>>>>]                                        ; w1 gets c0
  > [-<<<<+>>>>]                                          ; w2 gets c1
  > [-<<<<+>>>>]                                          ; w3 gets c2
  <<<                                                     ; back to n
]
  <<<<   ; move the pointer to @10
  [-<<<<+>>>>]>   ; move byte 0 of @10 to @0c
  [-<<<<+>>>>]>   ; move byte 1 of @11 to @0d
  [-<<<<+>>>>]>   ; move byte 2 of @12 to @0e
  [-<<<<+>>>>]   ; move byte 3 of @13 to @0f
  <<<<<<<<<<<<<<<<<<<   ; move the pointer to @00

; ================ round 2 : c d b  rotate 12 ================
; ____ ADD32 : word at @0x08 gets word at @0x0c ____
  >>>>>>>>   ; move the pointer to @08
  [->>>>>>>>+<<<<<<<<]>   ; move byte 0 of @08 to @10
  [->>>>>>>>+<<<<<<<<]>   ; move byte 1 of @09 to @11
  [->>>>>>>>+<<<<<<<<]>   ; move byte 2 of @0a to @12
  [->>>>>>>>+<<<<<<<<]   ; move byte 3 of @0b to @13
  >   ; move the pointer to @0c
  [->>>>>>>>+>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]>   ; byte 0 of @0c to @14 and to temp
  [->>>>>>>>+>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]>   ; byte 1 of @0d to @15 and to temp
  [->>>>>>>>+>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]>   ; byte 2 of @0e to @16 and to temp
  [->>>>>>>>+>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]   ; byte 3 of @0f to @17 and to temp
  >>>>>>>>>>>>>>>>>>>>>>>>>>>   ; walk to the temps
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]>   ; put temp byte 0 back into @0c
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]>   ; put temp byte 1 back into @0d
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]>   ; put temp byte 2 back into @0e
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]   ; put temp byte 3 back into @0f
  <<<<<<<<<<<<<<<<<<<<<   ; move the pointer to @18

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
[-]                          ; drop the final carry
  <<<<<<<<   ; move the pointer to @10
  [-<<<<<<<<+>>>>>>>>]>   ; move byte 0 of @10 to @08
  [-<<<<<<<<+>>>>>>>>]>   ; move byte 1 of @11 to @09
  [-<<<<<<<<+>>>>>>>>]>   ; move byte 2 of @12 to @0a
  [-<<<<<<<<+>>>>>>>>]   ; move byte 3 of @13 to @0b
  <<<<<<<<<<<<<<<<<<<   ; move the pointer to @00
; ____ XOR32 : word at @0x04 gets word at @0x08 ____
  >>>>   ; move the pointer to @04
  [->>>>>>>>>>>>+<<<<<<<<<<<<]>   ; move byte 0 of @04 to @10
  [->>>>>>>>>>>>+<<<<<<<<<<<<]>   ; move byte 1 of @05 to @11
  [->>>>>>>>>>>>+<<<<<<<<<<<<]>   ; move byte 2 of @06 to @12
  [->>>>>>>>>>>>+<<<<<<<<<<<<]   ; move byte 3 of @07 to @13
  >   ; move the pointer to @08
  [->>>>>>>>>>>>+>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]>   ; byte 0 of @08 to @14 and to temp
  [->>>>>>>>>>>>+>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]>   ; byte 1 of @09 to @15 and to temp
  [->>>>>>>>>>>>+>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]>   ; byte 2 of @0a to @16 and to temp
  [->>>>>>>>>>>>+>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]   ; byte 3 of @0b to @17 and to temp
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; walk to the temps
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]>   ; put temp byte 0 back into @08
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]>   ; put temp byte 1 back into @09
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]>   ; put temp byte 2 back into @0a
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]   ; put temp byte 3 back into @0b
  <<<<<<<<<<<<<<<<<<<<<   ; move the pointer to @18

; ==== byte 0 : x0 @0x00  y0 @0x04  into r0 @0x08 ====
  <<<<<<<< [->>>>>>>>>>>>+<<<<<<<<<<<<]              ; move x0 into a
  >>>> [->>>>>>>>>>>>+<<<<<<<<<<<<]                  ; move y0 into b
  >>>>>>>>>>>>>>>>>>> +                              ; p := 1
  > ++++++++                                         ; cnt := 8
  [-                                                 ; ____ eight bit steps ____
    <<<<<<<<<<<< [->>>+<[-<+>>-<]>[-<+>]<<<]         ; HALVE a  giving qa and pa
    >>>> [->>>+<[-<+>>-<]>[-<+>]<<<]                 ; HALVE b  giving qb and pb
    << [->>>>>>>+<[->-<]>[-<+>]<<<<<<<]              ; low bit of a toggles t
    >>>> [->>>+<[->-<]>[-<+>]<<<]                    ; low bit of b toggles t
    >> [->>>[-<+>>>+<<]>>[-<<+>>]<<<<<]              ; if t then res gets p
    <<<<<<< [-<+>]                                   ; a := qa
    >>>> [-<+>]                                      ; b := qb
    >>>>>> [->>+<<]                                  ; p into tmp
    >> [-<<++>>]                                     ; p := tmp doubled
    <                                                ; back to cnt
  ]
  << [-<<<<<<<<<<<<<<+>>>>>>>>>>>>>>]                ; store res into r0
  <<<<<<<<<<<<<<                                     ; back to r0

; ==== byte 1 : x1 @0x01  y1 @0x05  into r1 @0x09 ====
  <<<<<<< [->>>>>>>>>>>+<<<<<<<<<<<]                 ; move x1 into a
  >>>> [->>>>>>>>>>>+<<<<<<<<<<<]                    ; move y1 into b
  >>>>>>>>>>>>>>>>>> +                               ; p := 1
  > ++++++++                                         ; cnt := 8
  [-
    <<<<<<<<<<<< [->>>+<[-<+>>-<]>[-<+>]<<<]         ; HALVE a  giving qa and pa
    >>>> [->>>+<[-<+>>-<]>[-<+>]<<<]                 ; HALVE b  giving qb and pb
    << [->>>>>>>+<[->-<]>[-<+>]<<<<<<<]              ; low bit of a toggles t
    >>>> [->>>+<[->-<]>[-<+>]<<<]                    ; low bit of b toggles t
    >> [->>>[-<+>>>+<<]>>[-<<+>>]<<<<<]              ; if t then res gets p
    <<<<<<< [-<+>]                                   ; a := qa
    >>>> [-<+>]                                      ; b := qb
    >>>>>> [->>+<<]                                  ; p into tmp
    >> [-<<++>>]                                     ; p := tmp doubled
    <                                                ; back to cnt
  ]
  << [-<<<<<<<<<<<<<+>>>>>>>>>>>>>]                  ; store res into r1
  <<<<<<<<<<<<<<                                     ; back to r0

; ==== byte 2 : x2 @0x02  y2 @0x06  into r2 @0x0a ====
  <<<<<< [->>>>>>>>>>+<<<<<<<<<<]                    ; move x2 into a
  >>>> [->>>>>>>>>>+<<<<<<<<<<]                      ; move y2 into b
  >>>>>>>>>>>>>>>>> +                                ; p := 1
  > ++++++++                                         ; cnt := 8
  [-
    <<<<<<<<<<<< [->>>+<[-<+>>-<]>[-<+>]<<<]         ; HALVE a  giving qa and pa
    >>>> [->>>+<[-<+>>-<]>[-<+>]<<<]                 ; HALVE b  giving qb and pb
    << [->>>>>>>+<[->-<]>[-<+>]<<<<<<<]              ; low bit of a toggles t
    >>>> [->>>+<[->-<]>[-<+>]<<<]                    ; low bit of b toggles t
    >> [->>>[-<+>>>+<<]>>[-<<+>>]<<<<<]              ; if t then res gets p
    <<<<<<< [-<+>]                                   ; a := qa
    >>>> [-<+>]                                      ; b := qb
    >>>>>> [->>+<<]                                  ; p into tmp
    >> [-<<++>>]                                     ; p := tmp doubled
    <                                                ; back to cnt
  ]
  << [-<<<<<<<<<<<<+>>>>>>>>>>>>]                    ; store res into r2
  <<<<<<<<<<<<<<                                     ; back to r0

; ==== byte 3 : x3 @0x03  y3 @0x07  into r3 @0x0b ====
  <<<<< [->>>>>>>>>+<<<<<<<<<]                       ; move x3 into a
  >>>> [->>>>>>>>>+<<<<<<<<<]                        ; move y3 into b
  >>>>>>>>>>>>>>>> +                                 ; p := 1
  > ++++++++                                         ; cnt := 8
  [-
    <<<<<<<<<<<< [->>>+<[-<+>>-<]>[-<+>]<<<]         ; HALVE a  giving qa and pa
    >>>> [->>>+<[-<+>>-<]>[-<+>]<<<]                 ; HALVE b  giving qb and pb
    << [->>>>>>>+<[->-<]>[-<+>]<<<<<<<]              ; low bit of a toggles t
    >>>> [->>>+<[->-<]>[-<+>]<<<]                    ; low bit of b toggles t
    >> [->>>[-<+>>>+<<]>>[-<<+>>]<<<<<]              ; if t then res gets p
    <<<<<<< [-<+>]                                   ; a := qa
    >>>> [-<+>]                                      ; b := qb
    >>>>>> [->>+<<]                                  ; p into tmp
    >> [-<<++>>]                                     ; p := tmp doubled
    <                                                ; back to cnt
  ]
  << [-<<<<<<<<<<<+>>>>>>>>>>>]                      ; store res into r3
  <<<<<<<<<<<<<<                                     ; back to r0
  [-<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>]>   ; move byte 0 of @18 to @04
  [-<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>]>   ; move byte 1 of @19 to @05
  [-<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>]>   ; move byte 2 of @1a to @06
  [-<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>]   ; move byte 3 of @1b to @07
  <<<<<<<<<<<<<<<<<<<<<<<<<<<   ; move the pointer to @00
; ____ ROTL32 : word at @0x04 rotates left 12 ____
  >>>>   ; move the pointer to @04
  [->>>>>>>>>>>>+<<<<<<<<<<<<]>   ; move byte 0 of @04 to @10
  [->>>>>>>>>>>>+<<<<<<<<<<<<]>   ; move byte 1 of @05 to @11
  [->>>>>>>>>>>>+<<<<<<<<<<<<]>   ; move byte 2 of @06 to @12
  [->>>>>>>>>>>>+<<<<<<<<<<<<]   ; move byte 3 of @07 to @13
  >>>>>>>>>>>>>   ; move the pointer to @14
++++++++++++   ; rotation count

; ==== rotate one bit  n times ====
[
  -                                                       ; one step consumed

  ; ____ double byte 0 @0x00  carry into c0 @0x05 ____
  <<<< [->>>>>>>>>+<<<<<<<<<]                             ; move w0 into x
  >>>>>>>>> [->+>>+<<<] >>>[-<<<+>>>] <<<                 ; y := x  x restored
  > [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]      ; ADD8 y into x
  < [-<<<<<<<<<+>>>>>>>>>]                                ; store x into w0
  >> [-<<<<<<+>>>>>>]                                     ; carry into c0
  <<<<<<<                                                 ; back to n

  ; ____ double byte 1 @0x01  carry into c1 @0x06 ____
  <<< [->>>>>>>>+<<<<<<<<]                                ; move w1 into x
  >>>>>>>> [->+>>+<<<] >>>[-<<<+>>>] <<<                  ; y := x  x restored
  > [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]      ; ADD8 y into x
  < [-<<<<<<<<+>>>>>>>>]                                  ; store x into w1
  >> [-<<<<<+>>>>>]                                       ; carry into c1
  <<<<<<<                                                 ; back to n

  ; ____ double byte 2 @0x02  carry into c2 @0x07 ____
  << [->>>>>>>+<<<<<<<]                                   ; move w2 into x
  >>>>>>> [->+>>+<<<] >>>[-<<<+>>>] <<<                   ; y := x  x restored
  > [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]      ; ADD8 y into x
  < [-<<<<<<<+>>>>>>>]                                    ; store x into w2
  >> [-<<<<+>>>>]                                         ; carry into c2
  <<<<<<<                                                 ; back to n

  ; ____ double byte 3 @0x03  carry into c3 @0x08 ____
  < [->>>>>>+<<<<<<]                                      ; move w3 into x
  >>>>>> [->+>>+<<<] >>>[-<<<+>>>] <<<                    ; y := x  x restored
  > [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]      ; ADD8 y into x
  < [-<<<<<<+>>>>>>]                                      ; store x into w3
  >> [-<<<+>>>]                                           ; carry into c3
  <<<<<<<                                                 ; back to n

  ; ____ feed the carries around the cycle ____
  >>>> [-<<<<<<<<+>>>>>>>>]                               ; w0 gets c3
  <<< [-<<<<+>>>>]                                        ; w1 gets c0
  > [-<<<<+>>>>]                                          ; w2 gets c1
  > [-<<<<+>>>>]                                          ; w3 gets c2
  <<<                                                     ; back to n
]
  <<<<   ; move the pointer to @10
  [-<<<<<<<<<<<<+>>>>>>>>>>>>]>   ; move byte 0 of @10 to @04
  [-<<<<<<<<<<<<+>>>>>>>>>>>>]>   ; move byte 1 of @11 to @05
  [-<<<<<<<<<<<<+>>>>>>>>>>>>]>   ; move byte 2 of @12 to @06
  [-<<<<<<<<<<<<+>>>>>>>>>>>>]   ; move byte 3 of @13 to @07
  <<<<<<<<<<<<<<<<<<<   ; move the pointer to @00

; ================ round 3 : a b d  rotate 8 =================
; ____ ADD32 : word at @0x00 gets word at @0x04 ____
  [->>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<]>   ; move byte 0 of @00 to @10
  [->>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<]>   ; move byte 1 of @01 to @11
  [->>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<]>   ; move byte 2 of @02 to @12
  [->>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<]   ; move byte 3 of @03 to @13
  >   ; move the pointer to @04
  [->>>>>>>>>>>>>>>>+>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]>   ; byte 0 of @04 to @14 and to temp
  [->>>>>>>>>>>>>>>>+>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]>   ; byte 1 of @05 to @15 and to temp
  [->>>>>>>>>>>>>>>>+>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]>   ; byte 2 of @06 to @16 and to temp
  [->>>>>>>>>>>>>>>>+>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]   ; byte 3 of @07 to @17 and to temp
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; walk to the temps
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]>   ; put temp byte 0 back into @04
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]>   ; put temp byte 1 back into @05
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]>   ; put temp byte 2 back into @06
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]   ; put temp byte 3 back into @07
  <<<<<<<<<<<<<<<<<<<<<   ; move the pointer to @18

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
[-]                          ; drop the final carry
  <<<<<<<<   ; move the pointer to @10
  [-<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>]>   ; move byte 0 of @10 to @00
  [-<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>]>   ; move byte 1 of @11 to @01
  [-<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>]>   ; move byte 2 of @12 to @02
  [-<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>]   ; move byte 3 of @13 to @03
  <<<<<<<<<<<<<<<<<<<   ; move the pointer to @00
; ____ XOR32 : word at @0x0c gets word at @0x00 ____
  >>>>>>>>>>>>   ; move the pointer to @0c
  [->>>>+<<<<]>   ; move byte 0 of @0c to @10
  [->>>>+<<<<]>   ; move byte 1 of @0d to @11
  [->>>>+<<<<]>   ; move byte 2 of @0e to @12
  [->>>>+<<<<]   ; move byte 3 of @0f to @13
  <<<<<<<<<<<<<<<   ; move the pointer to @00
  [->>>>>>>>>>>>>>>>>>>>+>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]>   ; byte 0 of @00 to @14 and to temp
  [->>>>>>>>>>>>>>>>>>>>+>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]>   ; byte 1 of @01 to @15 and to temp
  [->>>>>>>>>>>>>>>>>>>>+>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]>   ; byte 2 of @02 to @16 and to temp
  [->>>>>>>>>>>>>>>>>>>>+>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]   ; byte 3 of @03 to @17 and to temp
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; walk to the temps
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]>   ; put temp byte 0 back into @00
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]>   ; put temp byte 1 back into @01
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]>   ; put temp byte 2 back into @02
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]   ; put temp byte 3 back into @03
  <<<<<<<<<<<<<<<<<<<<<   ; move the pointer to @18

; ==== byte 0 : x0 @0x00  y0 @0x04  into r0 @0x08 ====
  <<<<<<<< [->>>>>>>>>>>>+<<<<<<<<<<<<]              ; move x0 into a
  >>>> [->>>>>>>>>>>>+<<<<<<<<<<<<]                  ; move y0 into b
  >>>>>>>>>>>>>>>>>>> +                              ; p := 1
  > ++++++++                                         ; cnt := 8
  [-                                                 ; ____ eight bit steps ____
    <<<<<<<<<<<< [->>>+<[-<+>>-<]>[-<+>]<<<]         ; HALVE a  giving qa and pa
    >>>> [->>>+<[-<+>>-<]>[-<+>]<<<]                 ; HALVE b  giving qb and pb
    << [->>>>>>>+<[->-<]>[-<+>]<<<<<<<]              ; low bit of a toggles t
    >>>> [->>>+<[->-<]>[-<+>]<<<]                    ; low bit of b toggles t
    >> [->>>[-<+>>>+<<]>>[-<<+>>]<<<<<]              ; if t then res gets p
    <<<<<<< [-<+>]                                   ; a := qa
    >>>> [-<+>]                                      ; b := qb
    >>>>>> [->>+<<]                                  ; p into tmp
    >> [-<<++>>]                                     ; p := tmp doubled
    <                                                ; back to cnt
  ]
  << [-<<<<<<<<<<<<<<+>>>>>>>>>>>>>>]                ; store res into r0
  <<<<<<<<<<<<<<                                     ; back to r0

; ==== byte 1 : x1 @0x01  y1 @0x05  into r1 @0x09 ====
  <<<<<<< [->>>>>>>>>>>+<<<<<<<<<<<]                 ; move x1 into a
  >>>> [->>>>>>>>>>>+<<<<<<<<<<<]                    ; move y1 into b
  >>>>>>>>>>>>>>>>>> +                               ; p := 1
  > ++++++++                                         ; cnt := 8
  [-
    <<<<<<<<<<<< [->>>+<[-<+>>-<]>[-<+>]<<<]         ; HALVE a  giving qa and pa
    >>>> [->>>+<[-<+>>-<]>[-<+>]<<<]                 ; HALVE b  giving qb and pb
    << [->>>>>>>+<[->-<]>[-<+>]<<<<<<<]              ; low bit of a toggles t
    >>>> [->>>+<[->-<]>[-<+>]<<<]                    ; low bit of b toggles t
    >> [->>>[-<+>>>+<<]>>[-<<+>>]<<<<<]              ; if t then res gets p
    <<<<<<< [-<+>]                                   ; a := qa
    >>>> [-<+>]                                      ; b := qb
    >>>>>> [->>+<<]                                  ; p into tmp
    >> [-<<++>>]                                     ; p := tmp doubled
    <                                                ; back to cnt
  ]
  << [-<<<<<<<<<<<<<+>>>>>>>>>>>>>]                  ; store res into r1
  <<<<<<<<<<<<<<                                     ; back to r0

; ==== byte 2 : x2 @0x02  y2 @0x06  into r2 @0x0a ====
  <<<<<< [->>>>>>>>>>+<<<<<<<<<<]                    ; move x2 into a
  >>>> [->>>>>>>>>>+<<<<<<<<<<]                      ; move y2 into b
  >>>>>>>>>>>>>>>>> +                                ; p := 1
  > ++++++++                                         ; cnt := 8
  [-
    <<<<<<<<<<<< [->>>+<[-<+>>-<]>[-<+>]<<<]         ; HALVE a  giving qa and pa
    >>>> [->>>+<[-<+>>-<]>[-<+>]<<<]                 ; HALVE b  giving qb and pb
    << [->>>>>>>+<[->-<]>[-<+>]<<<<<<<]              ; low bit of a toggles t
    >>>> [->>>+<[->-<]>[-<+>]<<<]                    ; low bit of b toggles t
    >> [->>>[-<+>>>+<<]>>[-<<+>>]<<<<<]              ; if t then res gets p
    <<<<<<< [-<+>]                                   ; a := qa
    >>>> [-<+>]                                      ; b := qb
    >>>>>> [->>+<<]                                  ; p into tmp
    >> [-<<++>>]                                     ; p := tmp doubled
    <                                                ; back to cnt
  ]
  << [-<<<<<<<<<<<<+>>>>>>>>>>>>]                    ; store res into r2
  <<<<<<<<<<<<<<                                     ; back to r0

; ==== byte 3 : x3 @0x03  y3 @0x07  into r3 @0x0b ====
  <<<<< [->>>>>>>>>+<<<<<<<<<]                       ; move x3 into a
  >>>> [->>>>>>>>>+<<<<<<<<<]                        ; move y3 into b
  >>>>>>>>>>>>>>>> +                                 ; p := 1
  > ++++++++                                         ; cnt := 8
  [-
    <<<<<<<<<<<< [->>>+<[-<+>>-<]>[-<+>]<<<]         ; HALVE a  giving qa and pa
    >>>> [->>>+<[-<+>>-<]>[-<+>]<<<]                 ; HALVE b  giving qb and pb
    << [->>>>>>>+<[->-<]>[-<+>]<<<<<<<]              ; low bit of a toggles t
    >>>> [->>>+<[->-<]>[-<+>]<<<]                    ; low bit of b toggles t
    >> [->>>[-<+>>>+<<]>>[-<<+>>]<<<<<]              ; if t then res gets p
    <<<<<<< [-<+>]                                   ; a := qa
    >>>> [-<+>]                                      ; b := qb
    >>>>>> [->>+<<]                                  ; p into tmp
    >> [-<<++>>]                                     ; p := tmp doubled
    <                                                ; back to cnt
  ]
  << [-<<<<<<<<<<<+>>>>>>>>>>>]                      ; store res into r3
  <<<<<<<<<<<<<<                                     ; back to r0
  [-<<<<<<<<<<<<+>>>>>>>>>>>>]>   ; move byte 0 of @18 to @0c
  [-<<<<<<<<<<<<+>>>>>>>>>>>>]>   ; move byte 1 of @19 to @0d
  [-<<<<<<<<<<<<+>>>>>>>>>>>>]>   ; move byte 2 of @1a to @0e
  [-<<<<<<<<<<<<+>>>>>>>>>>>>]   ; move byte 3 of @1b to @0f
  <<<<<<<<<<<<<<<<<<<<<<<<<<<   ; move the pointer to @00
; ____ ROTL32 : word at @0x0c rotates left 8 ____
  >>>>>>>>>>>>   ; move the pointer to @0c
  [->>>>+<<<<]>   ; move byte 0 of @0c to @10
  [->>>>+<<<<]>   ; move byte 1 of @0d to @11
  [->>>>+<<<<]>   ; move byte 2 of @0e to @12
  [->>>>+<<<<]   ; move byte 3 of @0f to @13
  >>>>>   ; move the pointer to @14
++++++++   ; rotation count

; ==== rotate one bit  n times ====
[
  -                                                       ; one step consumed

  ; ____ double byte 0 @0x00  carry into c0 @0x05 ____
  <<<< [->>>>>>>>>+<<<<<<<<<]                             ; move w0 into x
  >>>>>>>>> [->+>>+<<<] >>>[-<<<+>>>] <<<                 ; y := x  x restored
  > [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]      ; ADD8 y into x
  < [-<<<<<<<<<+>>>>>>>>>]                                ; store x into w0
  >> [-<<<<<<+>>>>>>]                                     ; carry into c0
  <<<<<<<                                                 ; back to n

  ; ____ double byte 1 @0x01  carry into c1 @0x06 ____
  <<< [->>>>>>>>+<<<<<<<<]                                ; move w1 into x
  >>>>>>>> [->+>>+<<<] >>>[-<<<+>>>] <<<                  ; y := x  x restored
  > [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]      ; ADD8 y into x
  < [-<<<<<<<<+>>>>>>>>]                                  ; store x into w1
  >> [-<<<<<+>>>>>]                                       ; carry into c1
  <<<<<<<                                                 ; back to n

  ; ____ double byte 2 @0x02  carry into c2 @0x07 ____
  << [->>>>>>>+<<<<<<<]                                   ; move w2 into x
  >>>>>>> [->+>>+<<<] >>>[-<<<+>>>] <<<                   ; y := x  x restored
  > [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]      ; ADD8 y into x
  < [-<<<<<<<+>>>>>>>]                                    ; store x into w2
  >> [-<<<<+>>>>]                                         ; carry into c2
  <<<<<<<                                                 ; back to n

  ; ____ double byte 3 @0x03  carry into c3 @0x08 ____
  < [->>>>>>+<<<<<<]                                      ; move w3 into x
  >>>>>> [->+>>+<<<] >>>[-<<<+>>>] <<<                    ; y := x  x restored
  > [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]      ; ADD8 y into x
  < [-<<<<<<+>>>>>>]                                      ; store x into w3
  >> [-<<<+>>>]                                           ; carry into c3
  <<<<<<<                                                 ; back to n

  ; ____ feed the carries around the cycle ____
  >>>> [-<<<<<<<<+>>>>>>>>]                               ; w0 gets c3
  <<< [-<<<<+>>>>]                                        ; w1 gets c0
  > [-<<<<+>>>>]                                          ; w2 gets c1
  > [-<<<<+>>>>]                                          ; w3 gets c2
  <<<                                                     ; back to n
]
  <<<<   ; move the pointer to @10
  [-<<<<+>>>>]>   ; move byte 0 of @10 to @0c
  [-<<<<+>>>>]>   ; move byte 1 of @11 to @0d
  [-<<<<+>>>>]>   ; move byte 2 of @12 to @0e
  [-<<<<+>>>>]   ; move byte 3 of @13 to @0f
  <<<<<<<<<<<<<<<<<<<   ; move the pointer to @00

; ================ round 4 : c d b  rotate 7 =================
; ____ ADD32 : word at @0x08 gets word at @0x0c ____
  >>>>>>>>   ; move the pointer to @08
  [->>>>>>>>+<<<<<<<<]>   ; move byte 0 of @08 to @10
  [->>>>>>>>+<<<<<<<<]>   ; move byte 1 of @09 to @11
  [->>>>>>>>+<<<<<<<<]>   ; move byte 2 of @0a to @12
  [->>>>>>>>+<<<<<<<<]   ; move byte 3 of @0b to @13
  >   ; move the pointer to @0c
  [->>>>>>>>+>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]>   ; byte 0 of @0c to @14 and to temp
  [->>>>>>>>+>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]>   ; byte 1 of @0d to @15 and to temp
  [->>>>>>>>+>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]>   ; byte 2 of @0e to @16 and to temp
  [->>>>>>>>+>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]   ; byte 3 of @0f to @17 and to temp
  >>>>>>>>>>>>>>>>>>>>>>>>>>>   ; walk to the temps
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]>   ; put temp byte 0 back into @0c
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]>   ; put temp byte 1 back into @0d
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]>   ; put temp byte 2 back into @0e
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]   ; put temp byte 3 back into @0f
  <<<<<<<<<<<<<<<<<<<<<   ; move the pointer to @18

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
[-]                          ; drop the final carry
  <<<<<<<<   ; move the pointer to @10
  [-<<<<<<<<+>>>>>>>>]>   ; move byte 0 of @10 to @08
  [-<<<<<<<<+>>>>>>>>]>   ; move byte 1 of @11 to @09
  [-<<<<<<<<+>>>>>>>>]>   ; move byte 2 of @12 to @0a
  [-<<<<<<<<+>>>>>>>>]   ; move byte 3 of @13 to @0b
  <<<<<<<<<<<<<<<<<<<   ; move the pointer to @00
; ____ XOR32 : word at @0x04 gets word at @0x08 ____
  >>>>   ; move the pointer to @04
  [->>>>>>>>>>>>+<<<<<<<<<<<<]>   ; move byte 0 of @04 to @10
  [->>>>>>>>>>>>+<<<<<<<<<<<<]>   ; move byte 1 of @05 to @11
  [->>>>>>>>>>>>+<<<<<<<<<<<<]>   ; move byte 2 of @06 to @12
  [->>>>>>>>>>>>+<<<<<<<<<<<<]   ; move byte 3 of @07 to @13
  >   ; move the pointer to @08
  [->>>>>>>>>>>>+>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]>   ; byte 0 of @08 to @14 and to temp
  [->>>>>>>>>>>>+>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]>   ; byte 1 of @09 to @15 and to temp
  [->>>>>>>>>>>>+>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]>   ; byte 2 of @0a to @16 and to temp
  [->>>>>>>>>>>>+>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]   ; byte 3 of @0b to @17 and to temp
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; walk to the temps
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]>   ; put temp byte 0 back into @08
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]>   ; put temp byte 1 back into @09
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]>   ; put temp byte 2 back into @0a
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]   ; put temp byte 3 back into @0b
  <<<<<<<<<<<<<<<<<<<<<   ; move the pointer to @18

; ==== byte 0 : x0 @0x00  y0 @0x04  into r0 @0x08 ====
  <<<<<<<< [->>>>>>>>>>>>+<<<<<<<<<<<<]              ; move x0 into a
  >>>> [->>>>>>>>>>>>+<<<<<<<<<<<<]                  ; move y0 into b
  >>>>>>>>>>>>>>>>>>> +                              ; p := 1
  > ++++++++                                         ; cnt := 8
  [-                                                 ; ____ eight bit steps ____
    <<<<<<<<<<<< [->>>+<[-<+>>-<]>[-<+>]<<<]         ; HALVE a  giving qa and pa
    >>>> [->>>+<[-<+>>-<]>[-<+>]<<<]                 ; HALVE b  giving qb and pb
    << [->>>>>>>+<[->-<]>[-<+>]<<<<<<<]              ; low bit of a toggles t
    >>>> [->>>+<[->-<]>[-<+>]<<<]                    ; low bit of b toggles t
    >> [->>>[-<+>>>+<<]>>[-<<+>>]<<<<<]              ; if t then res gets p
    <<<<<<< [-<+>]                                   ; a := qa
    >>>> [-<+>]                                      ; b := qb
    >>>>>> [->>+<<]                                  ; p into tmp
    >> [-<<++>>]                                     ; p := tmp doubled
    <                                                ; back to cnt
  ]
  << [-<<<<<<<<<<<<<<+>>>>>>>>>>>>>>]                ; store res into r0
  <<<<<<<<<<<<<<                                     ; back to r0

; ==== byte 1 : x1 @0x01  y1 @0x05  into r1 @0x09 ====
  <<<<<<< [->>>>>>>>>>>+<<<<<<<<<<<]                 ; move x1 into a
  >>>> [->>>>>>>>>>>+<<<<<<<<<<<]                    ; move y1 into b
  >>>>>>>>>>>>>>>>>> +                               ; p := 1
  > ++++++++                                         ; cnt := 8
  [-
    <<<<<<<<<<<< [->>>+<[-<+>>-<]>[-<+>]<<<]         ; HALVE a  giving qa and pa
    >>>> [->>>+<[-<+>>-<]>[-<+>]<<<]                 ; HALVE b  giving qb and pb
    << [->>>>>>>+<[->-<]>[-<+>]<<<<<<<]              ; low bit of a toggles t
    >>>> [->>>+<[->-<]>[-<+>]<<<]                    ; low bit of b toggles t
    >> [->>>[-<+>>>+<<]>>[-<<+>>]<<<<<]              ; if t then res gets p
    <<<<<<< [-<+>]                                   ; a := qa
    >>>> [-<+>]                                      ; b := qb
    >>>>>> [->>+<<]                                  ; p into tmp
    >> [-<<++>>]                                     ; p := tmp doubled
    <                                                ; back to cnt
  ]
  << [-<<<<<<<<<<<<<+>>>>>>>>>>>>>]                  ; store res into r1
  <<<<<<<<<<<<<<                                     ; back to r0

; ==== byte 2 : x2 @0x02  y2 @0x06  into r2 @0x0a ====
  <<<<<< [->>>>>>>>>>+<<<<<<<<<<]                    ; move x2 into a
  >>>> [->>>>>>>>>>+<<<<<<<<<<]                      ; move y2 into b
  >>>>>>>>>>>>>>>>> +                                ; p := 1
  > ++++++++                                         ; cnt := 8
  [-
    <<<<<<<<<<<< [->>>+<[-<+>>-<]>[-<+>]<<<]         ; HALVE a  giving qa and pa
    >>>> [->>>+<[-<+>>-<]>[-<+>]<<<]                 ; HALVE b  giving qb and pb
    << [->>>>>>>+<[->-<]>[-<+>]<<<<<<<]              ; low bit of a toggles t
    >>>> [->>>+<[->-<]>[-<+>]<<<]                    ; low bit of b toggles t
    >> [->>>[-<+>>>+<<]>>[-<<+>>]<<<<<]              ; if t then res gets p
    <<<<<<< [-<+>]                                   ; a := qa
    >>>> [-<+>]                                      ; b := qb
    >>>>>> [->>+<<]                                  ; p into tmp
    >> [-<<++>>]                                     ; p := tmp doubled
    <                                                ; back to cnt
  ]
  << [-<<<<<<<<<<<<+>>>>>>>>>>>>]                    ; store res into r2
  <<<<<<<<<<<<<<                                     ; back to r0

; ==== byte 3 : x3 @0x03  y3 @0x07  into r3 @0x0b ====
  <<<<< [->>>>>>>>>+<<<<<<<<<]                       ; move x3 into a
  >>>> [->>>>>>>>>+<<<<<<<<<]                        ; move y3 into b
  >>>>>>>>>>>>>>>> +                                 ; p := 1
  > ++++++++                                         ; cnt := 8
  [-
    <<<<<<<<<<<< [->>>+<[-<+>>-<]>[-<+>]<<<]         ; HALVE a  giving qa and pa
    >>>> [->>>+<[-<+>>-<]>[-<+>]<<<]                 ; HALVE b  giving qb and pb
    << [->>>>>>>+<[->-<]>[-<+>]<<<<<<<]              ; low bit of a toggles t
    >>>> [->>>+<[->-<]>[-<+>]<<<]                    ; low bit of b toggles t
    >> [->>>[-<+>>>+<<]>>[-<<+>>]<<<<<]              ; if t then res gets p
    <<<<<<< [-<+>]                                   ; a := qa
    >>>> [-<+>]                                      ; b := qb
    >>>>>> [->>+<<]                                  ; p into tmp
    >> [-<<++>>]                                     ; p := tmp doubled
    <                                                ; back to cnt
  ]
  << [-<<<<<<<<<<<+>>>>>>>>>>>]                      ; store res into r3
  <<<<<<<<<<<<<<                                     ; back to r0
  [-<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>]>   ; move byte 0 of @18 to @04
  [-<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>]>   ; move byte 1 of @19 to @05
  [-<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>]>   ; move byte 2 of @1a to @06
  [-<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>]   ; move byte 3 of @1b to @07
  <<<<<<<<<<<<<<<<<<<<<<<<<<<   ; move the pointer to @00
; ____ ROTL32 : word at @0x04 rotates left 7 ____
  >>>>   ; move the pointer to @04
  [->>>>>>>>>>>>+<<<<<<<<<<<<]>   ; move byte 0 of @04 to @10
  [->>>>>>>>>>>>+<<<<<<<<<<<<]>   ; move byte 1 of @05 to @11
  [->>>>>>>>>>>>+<<<<<<<<<<<<]>   ; move byte 2 of @06 to @12
  [->>>>>>>>>>>>+<<<<<<<<<<<<]   ; move byte 3 of @07 to @13
  >>>>>>>>>>>>>   ; move the pointer to @14
+++++++   ; rotation count

; ==== rotate one bit  n times ====
[
  -                                                       ; one step consumed

  ; ____ double byte 0 @0x00  carry into c0 @0x05 ____
  <<<< [->>>>>>>>>+<<<<<<<<<]                             ; move w0 into x
  >>>>>>>>> [->+>>+<<<] >>>[-<<<+>>>] <<<                 ; y := x  x restored
  > [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]      ; ADD8 y into x
  < [-<<<<<<<<<+>>>>>>>>>]                                ; store x into w0
  >> [-<<<<<<+>>>>>>]                                     ; carry into c0
  <<<<<<<                                                 ; back to n

  ; ____ double byte 1 @0x01  carry into c1 @0x06 ____
  <<< [->>>>>>>>+<<<<<<<<]                                ; move w1 into x
  >>>>>>>> [->+>>+<<<] >>>[-<<<+>>>] <<<                  ; y := x  x restored
  > [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]      ; ADD8 y into x
  < [-<<<<<<<<+>>>>>>>>]                                  ; store x into w1
  >> [-<<<<<+>>>>>]                                       ; carry into c1
  <<<<<<<                                                 ; back to n

  ; ____ double byte 2 @0x02  carry into c2 @0x07 ____
  << [->>>>>>>+<<<<<<<]                                   ; move w2 into x
  >>>>>>> [->+>>+<<<] >>>[-<<<+>>>] <<<                   ; y := x  x restored
  > [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]      ; ADD8 y into x
  < [-<<<<<<<+>>>>>>>]                                    ; store x into w2
  >> [-<<<<+>>>>]                                         ; carry into c2
  <<<<<<<                                                 ; back to n

  ; ____ double byte 3 @0x03  carry into c3 @0x08 ____
  < [->>>>>>+<<<<<<]                                      ; move w3 into x
  >>>>>> [->+>>+<<<] >>>[-<<<+>>>] <<<                    ; y := x  x restored
  > [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]      ; ADD8 y into x
  < [-<<<<<<+>>>>>>]                                      ; store x into w3
  >> [-<<<+>>>]                                           ; carry into c3
  <<<<<<<                                                 ; back to n

  ; ____ feed the carries around the cycle ____
  >>>> [-<<<<<<<<+>>>>>>>>]                               ; w0 gets c3
  <<< [-<<<<+>>>>]                                        ; w1 gets c0
  > [-<<<<+>>>>]                                          ; w2 gets c1
  > [-<<<<+>>>>]                                          ; w3 gets c2
  <<<                                                     ; back to n
]
  <<<<   ; move the pointer to @10
  [-<<<<<<<<<<<<+>>>>>>>>>>>>]>   ; move byte 0 of @10 to @04
  [-<<<<<<<<<<<<+>>>>>>>>>>>>]>   ; move byte 1 of @11 to @05
  [-<<<<<<<<<<<<+>>>>>>>>>>>>]>   ; move byte 2 of @12 to @06
  [-<<<<<<<<<<<<+>>>>>>>>>>>>]   ; move byte 3 of @13 to @07
  <<<<<<<<<<<<<<<<<<<   ; move the pointer to @00

; emit a b c d little endian
.>.>.>.>.>.>.>.>.>.>.>.>.>.>.>.
