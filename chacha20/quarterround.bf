; bfsodium ChaCha20 QUARTERROUND (RFC 8439 quarter round)
;
; ASSEMBLED FILE: emitted by tools/qrasm from the verified bodies of
; add32  xor32 and rotl32; those primitives each pass dual oracle
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
; travel 15 cells left
  <<<<<<<<<<<<<<<
; ADD32 : @000 gets @004
; move byte 0 of @000 to @010
  [-
; travel 16 cells right
  >>>>>>>>>>>>>>>>
  +
; travel 16 cells left
  <<<<<<<<<<<<<<<<
  ]>
; move byte 1 of @001 to @011
  [-
; travel 16 cells right
  >>>>>>>>>>>>>>>>
  +
; travel 16 cells left
  <<<<<<<<<<<<<<<<
  ]>
; move byte 2 of @002 to @012
  [-
; travel 16 cells right
  >>>>>>>>>>>>>>>>
  +
; travel 16 cells left
  <<<<<<<<<<<<<<<<
  ]>
; move byte 3 of @003 to @013
  [-
; travel 16 cells right
  >>>>>>>>>>>>>>>>
  +
; travel 16 cells left
  <<<<<<<<<<<<<<<<
  ]
; travel 1 cells right
  >
; copy byte 0 of @004 to @014 and to a temp
  [-
; travel 16 cells right
  >>>>>>>>>>>>>>>>
  +
; travel 22 cells right
  >>>>>>>>>>>>>>>>>>>>>>
  +
; travel 38 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]>
; copy byte 1 of @005 to @015 and to a temp
  [-
; travel 16 cells right
  >>>>>>>>>>>>>>>>
  +
; travel 22 cells right
  >>>>>>>>>>>>>>>>>>>>>>
  +
; travel 38 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]>
; copy byte 2 of @006 to @016 and to a temp
  [-
; travel 16 cells right
  >>>>>>>>>>>>>>>>
  +
; travel 22 cells right
  >>>>>>>>>>>>>>>>>>>>>>
  +
; travel 38 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]>
; copy byte 3 of @007 to @017 and to a temp
  [-
; travel 16 cells right
  >>>>>>>>>>>>>>>>
  +
; travel 22 cells right
  >>>>>>>>>>>>>>>>>>>>>>
  +
; travel 38 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; walk to the temps
; travel 35 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; put temp byte 0 back into @004
  [-
; travel 38 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 38 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]>
; put temp byte 1 back into @005
  [-
; travel 38 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 38 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]>
; put temp byte 2 back into @006
  [-
; travel 38 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 38 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]>
; put temp byte 3 back into @007
  [-
; travel 38 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 38 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 21 cells left
  <<<<<<<<<<<<<<<<<<<<<

; ==== byte 0 : a @0x00  b @0x04 ====
; move a0 into x
  <<<<<<<< [->>>>>>>>>+<<<<<<<<<]
; move b0 into y
  >>>> [->>>>>>+<<<<<<]
; ADD8 y into x
  >>>>>> [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; move cin into y
  << [->>+<<]
; ADD8 cin into x
  >> [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; store x into a0
  < [-<<<<<<<<<+>>>>>>>>>]
; carry c into cin
  >> [-<<<+>>>]
; back to cin
  <<<

; ==== byte 1 : a @0x01  b @0x05 ====
; move a1 into x
  <<<<<<< [->>>>>>>>+<<<<<<<<]
; move b1 into y
  >>>> [->>>>>+<<<<<]
; ADD8 y into x
  >>>>> [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; move cin into y
  << [->>+<<]
; ADD8 cin into x
  >> [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; store x into a1
  < [-<<<<<<<<+>>>>>>>>]
; carry c into cin
  >> [-<<<+>>>]
; back to cin
  <<<

; ==== byte 2 : a @0x02  b @0x06 ====
; move a2 into x
  <<<<<< [->>>>>>>+<<<<<<<]
; move b2 into y
  >>>> [->>>>+<<<<]
; ADD8 y into x
  >>>> [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; move cin into y
  << [->>+<<]
; ADD8 cin into x
  >> [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; store x into a2
  < [-<<<<<<<+>>>>>>>]
; carry c into cin
  >> [-<<<+>>>]
; back to cin
  <<<

; ==== byte 3 : a @0x03  b @0x07 ====
; move a3 into x
  <<<<< [->>>>>>+<<<<<<]
; move b3 into y
  >>>> [->>>+<<<]
; ADD8 y into x
  >>> [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; move cin into y
  << [->>+<<]
; ADD8 cin into x
  >> [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; store x into a3
  < [-<<<<<<+>>>>>>]
; carry c into cin
  >> [-<<<+>>>]
; back to cin (dropped)
  <<<
; drop the final carry
  [-]
; travel 8 cells left
  <<<<<<<<
; move byte 0 of @010 to @000
  [-
; travel 16 cells left
  <<<<<<<<<<<<<<<<
  +
; travel 16 cells right
  >>>>>>>>>>>>>>>>
  ]>
; move byte 1 of @011 to @001
  [-
; travel 16 cells left
  <<<<<<<<<<<<<<<<
  +
; travel 16 cells right
  >>>>>>>>>>>>>>>>
  ]>
; move byte 2 of @012 to @002
  [-
; travel 16 cells left
  <<<<<<<<<<<<<<<<
  +
; travel 16 cells right
  >>>>>>>>>>>>>>>>
  ]>
; move byte 3 of @013 to @003
  [-
; travel 16 cells left
  <<<<<<<<<<<<<<<<
  +
; travel 16 cells right
  >>>>>>>>>>>>>>>>
  ]
; travel 19 cells left
  <<<<<<<<<<<<<<<<<<<
; XOR32 : @00c gets @000
; travel 12 cells right
  >>>>>>>>>>>>
; move byte 0 of @00c to @010
  [-
; travel 4 cells right
  >>>>
  +
; travel 4 cells left
  <<<<
  ]>
; move byte 1 of @00d to @011
  [-
; travel 4 cells right
  >>>>
  +
; travel 4 cells left
  <<<<
  ]>
; move byte 2 of @00e to @012
  [-
; travel 4 cells right
  >>>>
  +
; travel 4 cells left
  <<<<
  ]>
; move byte 3 of @00f to @013
  [-
; travel 4 cells right
  >>>>
  +
; travel 4 cells left
  <<<<
  ]
; travel 15 cells left
  <<<<<<<<<<<<<<<
; copy byte 0 of @000 to @014 and to a temp
  [-
; travel 20 cells right
  >>>>>>>>>>>>>>>>>>>>
  +
; travel 22 cells right
  >>>>>>>>>>>>>>>>>>>>>>
  +
; travel 42 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<
  ]>
; copy byte 1 of @001 to @015 and to a temp
  [-
; travel 20 cells right
  >>>>>>>>>>>>>>>>>>>>
  +
; travel 22 cells right
  >>>>>>>>>>>>>>>>>>>>>>
  +
; travel 42 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<
  ]>
; copy byte 2 of @002 to @016 and to a temp
  [-
; travel 20 cells right
  >>>>>>>>>>>>>>>>>>>>
  +
; travel 22 cells right
  >>>>>>>>>>>>>>>>>>>>>>
  +
; travel 42 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<
  ]>
; copy byte 3 of @003 to @017 and to a temp
  [-
; travel 20 cells right
  >>>>>>>>>>>>>>>>>>>>
  +
; travel 22 cells right
  >>>>>>>>>>>>>>>>>>>>>>
  +
; travel 42 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<
  ]
; walk to the temps
; travel 39 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; put temp byte 0 back into @000
  [-
; travel 42 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<
  +
; travel 42 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>
  ]>
; put temp byte 1 back into @001
  [-
; travel 42 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<
  +
; travel 42 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>
  ]>
; put temp byte 2 back into @002
  [-
; travel 42 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<
  +
; travel 42 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>
  ]>
; put temp byte 3 back into @003
  [-
; travel 42 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<
  +
; travel 42 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>
  ]
; travel 21 cells left
  <<<<<<<<<<<<<<<<<<<<<

; ==== byte 0 : x0 @0x00  y0 @0x04  into r0 @0x08 ====
; move x0 into a
  <<<<<<<< [->>>>>>>>>>>>+<<<<<<<<<<<<]
; move y0 into b
  >>>> [->>>>>>>>>>>>+<<<<<<<<<<<<]
; p := 1
  >>>>>>>>>>>>>>>>>>> +
; cnt := 8
  > ++++++++
; ____ eight bit steps ____
  [-
; HALVE a  giving qa and pa
  <<<<<<<<<<<< [->>>+<[-<+>>-<]>[-<+>]<<<]
; HALVE b  giving qb and pb
  >>>> [->>>+<[-<+>>-<]>[-<+>]<<<]
; low bit of a toggles t
  << [->>>>>>>+<[->-<]>[-<+>]<<<<<<<]
; low bit of b toggles t
  >>>> [->>>+<[->-<]>[-<+>]<<<]
; if t then res gets p
  >> [->>>[-<+>>>+<<]>>[-<<+>>]<<<<<]
; a := qa
  <<<<<<< [-<+>]
; b := qb
  >>>> [-<+>]
; p into tmp
  >>>>>> [->>+<<]
; p := tmp doubled
  >> [-<<++>>]
; back to cnt
  <
  ]
; store res into r0
  << [-<<<<<<<<<<<<<<+>>>>>>>>>>>>>>]
; back to r0
  <<<<<<<<<<<<<<

; ==== byte 1 : x1 @0x01  y1 @0x05  into r1 @0x09 ====
; move x1 into a
  <<<<<<< [->>>>>>>>>>>+<<<<<<<<<<<]
; move y1 into b
  >>>> [->>>>>>>>>>>+<<<<<<<<<<<]
; p := 1
  >>>>>>>>>>>>>>>>>> +
; cnt := 8
  > ++++++++
  [-
; HALVE a  giving qa and pa
  <<<<<<<<<<<< [->>>+<[-<+>>-<]>[-<+>]<<<]
; HALVE b  giving qb and pb
  >>>> [->>>+<[-<+>>-<]>[-<+>]<<<]
; low bit of a toggles t
  << [->>>>>>>+<[->-<]>[-<+>]<<<<<<<]
; low bit of b toggles t
  >>>> [->>>+<[->-<]>[-<+>]<<<]
; if t then res gets p
  >> [->>>[-<+>>>+<<]>>[-<<+>>]<<<<<]
; a := qa
  <<<<<<< [-<+>]
; b := qb
  >>>> [-<+>]
; p into tmp
  >>>>>> [->>+<<]
; p := tmp doubled
  >> [-<<++>>]
; back to cnt
  <
  ]
; store res into r1
  << [-<<<<<<<<<<<<<+>>>>>>>>>>>>>]
; back to r0
  <<<<<<<<<<<<<<

; ==== byte 2 : x2 @0x02  y2 @0x06  into r2 @0x0a ====
; move x2 into a
  <<<<<< [->>>>>>>>>>+<<<<<<<<<<]
; move y2 into b
  >>>> [->>>>>>>>>>+<<<<<<<<<<]
; p := 1
  >>>>>>>>>>>>>>>>> +
; cnt := 8
  > ++++++++
  [-
; HALVE a  giving qa and pa
  <<<<<<<<<<<< [->>>+<[-<+>>-<]>[-<+>]<<<]
; HALVE b  giving qb and pb
  >>>> [->>>+<[-<+>>-<]>[-<+>]<<<]
; low bit of a toggles t
  << [->>>>>>>+<[->-<]>[-<+>]<<<<<<<]
; low bit of b toggles t
  >>>> [->>>+<[->-<]>[-<+>]<<<]
; if t then res gets p
  >> [->>>[-<+>>>+<<]>>[-<<+>>]<<<<<]
; a := qa
  <<<<<<< [-<+>]
; b := qb
  >>>> [-<+>]
; p into tmp
  >>>>>> [->>+<<]
; p := tmp doubled
  >> [-<<++>>]
; back to cnt
  <
  ]
; store res into r2
  << [-<<<<<<<<<<<<+>>>>>>>>>>>>]
; back to r0
  <<<<<<<<<<<<<<

; ==== byte 3 : x3 @0x03  y3 @0x07  into r3 @0x0b ====
; move x3 into a
  <<<<< [->>>>>>>>>+<<<<<<<<<]
; move y3 into b
  >>>> [->>>>>>>>>+<<<<<<<<<]
; p := 1
  >>>>>>>>>>>>>>>> +
; cnt := 8
  > ++++++++
  [-
; HALVE a  giving qa and pa
  <<<<<<<<<<<< [->>>+<[-<+>>-<]>[-<+>]<<<]
; HALVE b  giving qb and pb
  >>>> [->>>+<[-<+>>-<]>[-<+>]<<<]
; low bit of a toggles t
  << [->>>>>>>+<[->-<]>[-<+>]<<<<<<<]
; low bit of b toggles t
  >>>> [->>>+<[->-<]>[-<+>]<<<]
; if t then res gets p
  >> [->>>[-<+>>>+<<]>>[-<<+>>]<<<<<]
; a := qa
  <<<<<<< [-<+>]
; b := qb
  >>>> [-<+>]
; p into tmp
  >>>>>> [->>+<<]
; p := tmp doubled
  >> [-<<++>>]
; back to cnt
  <
  ]
; store res into r3
  << [-<<<<<<<<<<<+>>>>>>>>>>>]
; back to r0
  <<<<<<<<<<<<<<
; move byte 0 of @018 to @00c
  [-
; travel 12 cells left
  <<<<<<<<<<<<
  +
; travel 12 cells right
  >>>>>>>>>>>>
  ]>
; move byte 1 of @019 to @00d
  [-
; travel 12 cells left
  <<<<<<<<<<<<
  +
; travel 12 cells right
  >>>>>>>>>>>>
  ]>
; move byte 2 of @01a to @00e
  [-
; travel 12 cells left
  <<<<<<<<<<<<
  +
; travel 12 cells right
  >>>>>>>>>>>>
  ]>
; move byte 3 of @01b to @00f
  [-
; travel 12 cells left
  <<<<<<<<<<<<
  +
; travel 12 cells right
  >>>>>>>>>>>>
  ]
; travel 27 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<
; ROTL32 : @00c rotates left 16
; travel 12 cells right
  >>>>>>>>>>>>
; move byte 0 of @00c to @010
  [-
; travel 4 cells right
  >>>>
  +
; travel 4 cells left
  <<<<
  ]>
; move byte 1 of @00d to @011
  [-
; travel 4 cells right
  >>>>
  +
; travel 4 cells left
  <<<<
  ]>
; move byte 2 of @00e to @012
  [-
; travel 4 cells right
  >>>>
  +
; travel 4 cells left
  <<<<
  ]>
; move byte 3 of @00f to @013
  [-
; travel 4 cells right
  >>>>
  +
; travel 4 cells left
  <<<<
  ]
; travel 5 cells right
  >>>>>
; the rotation count
; add 16
  ++++++++++++++++

; ==== rotate one bit  n times ====
[
; one step consumed
  -

; ____ double byte 0 @0x00  carry into c0 @0x05 ____
; move w0 into x
  <<<< [->>>>>>>>>+<<<<<<<<<]
; y := x  x restored
  >>>>>>>>> [->+>>+<<<] >>>[-<<<+>>>] <<<
; ADD8 y into x
  > [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; store x into w0
  < [-<<<<<<<<<+>>>>>>>>>]
; carry into c0
  >> [-<<<<<<+>>>>>>]
; back to n
  <<<<<<<

; ____ double byte 1 @0x01  carry into c1 @0x06 ____
; move w1 into x
  <<< [->>>>>>>>+<<<<<<<<]
; y := x  x restored
  >>>>>>>> [->+>>+<<<] >>>[-<<<+>>>] <<<
; ADD8 y into x
  > [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; store x into w1
  < [-<<<<<<<<+>>>>>>>>]
; carry into c1
  >> [-<<<<<+>>>>>]
; back to n
  <<<<<<<

; ____ double byte 2 @0x02  carry into c2 @0x07 ____
; move w2 into x
  << [->>>>>>>+<<<<<<<]
; y := x  x restored
  >>>>>>> [->+>>+<<<] >>>[-<<<+>>>] <<<
; ADD8 y into x
  > [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; store x into w2
  < [-<<<<<<<+>>>>>>>]
; carry into c2
  >> [-<<<<+>>>>]
; back to n
  <<<<<<<

; ____ double byte 3 @0x03  carry into c3 @0x08 ____
; move w3 into x
  < [->>>>>>+<<<<<<]
; y := x  x restored
  >>>>>> [->+>>+<<<] >>>[-<<<+>>>] <<<
; ADD8 y into x
  > [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; store x into w3
  < [-<<<<<<+>>>>>>]
; carry into c3
  >> [-<<<+>>>]
; back to n
  <<<<<<<

; ____ feed the carries around the cycle ____
; w0 gets c3
  >>>> [-<<<<<<<<+>>>>>>>>]
; w1 gets c0
  <<< [-<<<<+>>>>]
; w2 gets c1
  > [-<<<<+>>>>]
; w3 gets c2
  > [-<<<<+>>>>]
; back to n
  <<<
]
; travel 4 cells left
  <<<<
; move byte 0 of @010 to @00c
  [-
; travel 4 cells left
  <<<<
  +
; travel 4 cells right
  >>>>
  ]>
; move byte 1 of @011 to @00d
  [-
; travel 4 cells left
  <<<<
  +
; travel 4 cells right
  >>>>
  ]>
; move byte 2 of @012 to @00e
  [-
; travel 4 cells left
  <<<<
  +
; travel 4 cells right
  >>>>
  ]>
; move byte 3 of @013 to @00f
  [-
; travel 4 cells left
  <<<<
  +
; travel 4 cells right
  >>>>
  ]
; travel 19 cells left
  <<<<<<<<<<<<<<<<<<<

; ================ round 2 : c d b  rotate 12 ================
; ADD32 : @008 gets @00c
; travel 8 cells right
  >>>>>>>>
; move byte 0 of @008 to @010
  [-
; travel 8 cells right
  >>>>>>>>
  +
; travel 8 cells left
  <<<<<<<<
  ]>
; move byte 1 of @009 to @011
  [-
; travel 8 cells right
  >>>>>>>>
  +
; travel 8 cells left
  <<<<<<<<
  ]>
; move byte 2 of @00a to @012
  [-
; travel 8 cells right
  >>>>>>>>
  +
; travel 8 cells left
  <<<<<<<<
  ]>
; move byte 3 of @00b to @013
  [-
; travel 8 cells right
  >>>>>>>>
  +
; travel 8 cells left
  <<<<<<<<
  ]
; travel 1 cells right
  >
; copy byte 0 of @00c to @014 and to a temp
  [-
; travel 8 cells right
  >>>>>>>>
  +
; travel 22 cells right
  >>>>>>>>>>>>>>>>>>>>>>
  +
; travel 30 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]>
; copy byte 1 of @00d to @015 and to a temp
  [-
; travel 8 cells right
  >>>>>>>>
  +
; travel 22 cells right
  >>>>>>>>>>>>>>>>>>>>>>
  +
; travel 30 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]>
; copy byte 2 of @00e to @016 and to a temp
  [-
; travel 8 cells right
  >>>>>>>>
  +
; travel 22 cells right
  >>>>>>>>>>>>>>>>>>>>>>
  +
; travel 30 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]>
; copy byte 3 of @00f to @017 and to a temp
  [-
; travel 8 cells right
  >>>>>>>>
  +
; travel 22 cells right
  >>>>>>>>>>>>>>>>>>>>>>
  +
; travel 30 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; walk to the temps
; travel 27 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>
; put temp byte 0 back into @00c
  [-
; travel 30 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 30 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]>
; put temp byte 1 back into @00d
  [-
; travel 30 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 30 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]>
; put temp byte 2 back into @00e
  [-
; travel 30 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 30 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]>
; put temp byte 3 back into @00f
  [-
; travel 30 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 30 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 21 cells left
  <<<<<<<<<<<<<<<<<<<<<

; ==== byte 0 : a @0x00  b @0x04 ====
; move a0 into x
  <<<<<<<< [->>>>>>>>>+<<<<<<<<<]
; move b0 into y
  >>>> [->>>>>>+<<<<<<]
; ADD8 y into x
  >>>>>> [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; move cin into y
  << [->>+<<]
; ADD8 cin into x
  >> [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; store x into a0
  < [-<<<<<<<<<+>>>>>>>>>]
; carry c into cin
  >> [-<<<+>>>]
; back to cin
  <<<

; ==== byte 1 : a @0x01  b @0x05 ====
; move a1 into x
  <<<<<<< [->>>>>>>>+<<<<<<<<]
; move b1 into y
  >>>> [->>>>>+<<<<<]
; ADD8 y into x
  >>>>> [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; move cin into y
  << [->>+<<]
; ADD8 cin into x
  >> [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; store x into a1
  < [-<<<<<<<<+>>>>>>>>]
; carry c into cin
  >> [-<<<+>>>]
; back to cin
  <<<

; ==== byte 2 : a @0x02  b @0x06 ====
; move a2 into x
  <<<<<< [->>>>>>>+<<<<<<<]
; move b2 into y
  >>>> [->>>>+<<<<]
; ADD8 y into x
  >>>> [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; move cin into y
  << [->>+<<]
; ADD8 cin into x
  >> [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; store x into a2
  < [-<<<<<<<+>>>>>>>]
; carry c into cin
  >> [-<<<+>>>]
; back to cin
  <<<

; ==== byte 3 : a @0x03  b @0x07 ====
; move a3 into x
  <<<<< [->>>>>>+<<<<<<]
; move b3 into y
  >>>> [->>>+<<<]
; ADD8 y into x
  >>> [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; move cin into y
  << [->>+<<]
; ADD8 cin into x
  >> [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; store x into a3
  < [-<<<<<<+>>>>>>]
; carry c into cin
  >> [-<<<+>>>]
; back to cin (dropped)
  <<<
; drop the final carry
  [-]
; travel 8 cells left
  <<<<<<<<
; move byte 0 of @010 to @008
  [-
; travel 8 cells left
  <<<<<<<<
  +
; travel 8 cells right
  >>>>>>>>
  ]>
; move byte 1 of @011 to @009
  [-
; travel 8 cells left
  <<<<<<<<
  +
; travel 8 cells right
  >>>>>>>>
  ]>
; move byte 2 of @012 to @00a
  [-
; travel 8 cells left
  <<<<<<<<
  +
; travel 8 cells right
  >>>>>>>>
  ]>
; move byte 3 of @013 to @00b
  [-
; travel 8 cells left
  <<<<<<<<
  +
; travel 8 cells right
  >>>>>>>>
  ]
; travel 19 cells left
  <<<<<<<<<<<<<<<<<<<
; XOR32 : @004 gets @008
; travel 4 cells right
  >>>>
; move byte 0 of @004 to @010
  [-
; travel 12 cells right
  >>>>>>>>>>>>
  +
; travel 12 cells left
  <<<<<<<<<<<<
  ]>
; move byte 1 of @005 to @011
  [-
; travel 12 cells right
  >>>>>>>>>>>>
  +
; travel 12 cells left
  <<<<<<<<<<<<
  ]>
; move byte 2 of @006 to @012
  [-
; travel 12 cells right
  >>>>>>>>>>>>
  +
; travel 12 cells left
  <<<<<<<<<<<<
  ]>
; move byte 3 of @007 to @013
  [-
; travel 12 cells right
  >>>>>>>>>>>>
  +
; travel 12 cells left
  <<<<<<<<<<<<
  ]
; travel 1 cells right
  >
; copy byte 0 of @008 to @014 and to a temp
  [-
; travel 12 cells right
  >>>>>>>>>>>>
  +
; travel 22 cells right
  >>>>>>>>>>>>>>>>>>>>>>
  +
; travel 34 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]>
; copy byte 1 of @009 to @015 and to a temp
  [-
; travel 12 cells right
  >>>>>>>>>>>>
  +
; travel 22 cells right
  >>>>>>>>>>>>>>>>>>>>>>
  +
; travel 34 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]>
; copy byte 2 of @00a to @016 and to a temp
  [-
; travel 12 cells right
  >>>>>>>>>>>>
  +
; travel 22 cells right
  >>>>>>>>>>>>>>>>>>>>>>
  +
; travel 34 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]>
; copy byte 3 of @00b to @017 and to a temp
  [-
; travel 12 cells right
  >>>>>>>>>>>>
  +
; travel 22 cells right
  >>>>>>>>>>>>>>>>>>>>>>
  +
; travel 34 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; walk to the temps
; travel 31 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; put temp byte 0 back into @008
  [-
; travel 34 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]>
; put temp byte 1 back into @009
  [-
; travel 34 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]>
; put temp byte 2 back into @00a
  [-
; travel 34 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]>
; put temp byte 3 back into @00b
  [-
; travel 34 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 21 cells left
  <<<<<<<<<<<<<<<<<<<<<

; ==== byte 0 : x0 @0x00  y0 @0x04  into r0 @0x08 ====
; move x0 into a
  <<<<<<<< [->>>>>>>>>>>>+<<<<<<<<<<<<]
; move y0 into b
  >>>> [->>>>>>>>>>>>+<<<<<<<<<<<<]
; p := 1
  >>>>>>>>>>>>>>>>>>> +
; cnt := 8
  > ++++++++
; ____ eight bit steps ____
  [-
; HALVE a  giving qa and pa
  <<<<<<<<<<<< [->>>+<[-<+>>-<]>[-<+>]<<<]
; HALVE b  giving qb and pb
  >>>> [->>>+<[-<+>>-<]>[-<+>]<<<]
; low bit of a toggles t
  << [->>>>>>>+<[->-<]>[-<+>]<<<<<<<]
; low bit of b toggles t
  >>>> [->>>+<[->-<]>[-<+>]<<<]
; if t then res gets p
  >> [->>>[-<+>>>+<<]>>[-<<+>>]<<<<<]
; a := qa
  <<<<<<< [-<+>]
; b := qb
  >>>> [-<+>]
; p into tmp
  >>>>>> [->>+<<]
; p := tmp doubled
  >> [-<<++>>]
; back to cnt
  <
  ]
; store res into r0
  << [-<<<<<<<<<<<<<<+>>>>>>>>>>>>>>]
; back to r0
  <<<<<<<<<<<<<<

; ==== byte 1 : x1 @0x01  y1 @0x05  into r1 @0x09 ====
; move x1 into a
  <<<<<<< [->>>>>>>>>>>+<<<<<<<<<<<]
; move y1 into b
  >>>> [->>>>>>>>>>>+<<<<<<<<<<<]
; p := 1
  >>>>>>>>>>>>>>>>>> +
; cnt := 8
  > ++++++++
  [-
; HALVE a  giving qa and pa
  <<<<<<<<<<<< [->>>+<[-<+>>-<]>[-<+>]<<<]
; HALVE b  giving qb and pb
  >>>> [->>>+<[-<+>>-<]>[-<+>]<<<]
; low bit of a toggles t
  << [->>>>>>>+<[->-<]>[-<+>]<<<<<<<]
; low bit of b toggles t
  >>>> [->>>+<[->-<]>[-<+>]<<<]
; if t then res gets p
  >> [->>>[-<+>>>+<<]>>[-<<+>>]<<<<<]
; a := qa
  <<<<<<< [-<+>]
; b := qb
  >>>> [-<+>]
; p into tmp
  >>>>>> [->>+<<]
; p := tmp doubled
  >> [-<<++>>]
; back to cnt
  <
  ]
; store res into r1
  << [-<<<<<<<<<<<<<+>>>>>>>>>>>>>]
; back to r0
  <<<<<<<<<<<<<<

; ==== byte 2 : x2 @0x02  y2 @0x06  into r2 @0x0a ====
; move x2 into a
  <<<<<< [->>>>>>>>>>+<<<<<<<<<<]
; move y2 into b
  >>>> [->>>>>>>>>>+<<<<<<<<<<]
; p := 1
  >>>>>>>>>>>>>>>>> +
; cnt := 8
  > ++++++++
  [-
; HALVE a  giving qa and pa
  <<<<<<<<<<<< [->>>+<[-<+>>-<]>[-<+>]<<<]
; HALVE b  giving qb and pb
  >>>> [->>>+<[-<+>>-<]>[-<+>]<<<]
; low bit of a toggles t
  << [->>>>>>>+<[->-<]>[-<+>]<<<<<<<]
; low bit of b toggles t
  >>>> [->>>+<[->-<]>[-<+>]<<<]
; if t then res gets p
  >> [->>>[-<+>>>+<<]>>[-<<+>>]<<<<<]
; a := qa
  <<<<<<< [-<+>]
; b := qb
  >>>> [-<+>]
; p into tmp
  >>>>>> [->>+<<]
; p := tmp doubled
  >> [-<<++>>]
; back to cnt
  <
  ]
; store res into r2
  << [-<<<<<<<<<<<<+>>>>>>>>>>>>]
; back to r0
  <<<<<<<<<<<<<<

; ==== byte 3 : x3 @0x03  y3 @0x07  into r3 @0x0b ====
; move x3 into a
  <<<<< [->>>>>>>>>+<<<<<<<<<]
; move y3 into b
  >>>> [->>>>>>>>>+<<<<<<<<<]
; p := 1
  >>>>>>>>>>>>>>>> +
; cnt := 8
  > ++++++++
  [-
; HALVE a  giving qa and pa
  <<<<<<<<<<<< [->>>+<[-<+>>-<]>[-<+>]<<<]
; HALVE b  giving qb and pb
  >>>> [->>>+<[-<+>>-<]>[-<+>]<<<]
; low bit of a toggles t
  << [->>>>>>>+<[->-<]>[-<+>]<<<<<<<]
; low bit of b toggles t
  >>>> [->>>+<[->-<]>[-<+>]<<<]
; if t then res gets p
  >> [->>>[-<+>>>+<<]>>[-<<+>>]<<<<<]
; a := qa
  <<<<<<< [-<+>]
; b := qb
  >>>> [-<+>]
; p into tmp
  >>>>>> [->>+<<]
; p := tmp doubled
  >> [-<<++>>]
; back to cnt
  <
  ]
; store res into r3
  << [-<<<<<<<<<<<+>>>>>>>>>>>]
; back to r0
  <<<<<<<<<<<<<<
; move byte 0 of @018 to @004
  [-
; travel 20 cells left
  <<<<<<<<<<<<<<<<<<<<
  +
; travel 20 cells right
  >>>>>>>>>>>>>>>>>>>>
  ]>
; move byte 1 of @019 to @005
  [-
; travel 20 cells left
  <<<<<<<<<<<<<<<<<<<<
  +
; travel 20 cells right
  >>>>>>>>>>>>>>>>>>>>
  ]>
; move byte 2 of @01a to @006
  [-
; travel 20 cells left
  <<<<<<<<<<<<<<<<<<<<
  +
; travel 20 cells right
  >>>>>>>>>>>>>>>>>>>>
  ]>
; move byte 3 of @01b to @007
  [-
; travel 20 cells left
  <<<<<<<<<<<<<<<<<<<<
  +
; travel 20 cells right
  >>>>>>>>>>>>>>>>>>>>
  ]
; travel 27 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<
; ROTL32 : @004 rotates left 12
; travel 4 cells right
  >>>>
; move byte 0 of @004 to @010
  [-
; travel 12 cells right
  >>>>>>>>>>>>
  +
; travel 12 cells left
  <<<<<<<<<<<<
  ]>
; move byte 1 of @005 to @011
  [-
; travel 12 cells right
  >>>>>>>>>>>>
  +
; travel 12 cells left
  <<<<<<<<<<<<
  ]>
; move byte 2 of @006 to @012
  [-
; travel 12 cells right
  >>>>>>>>>>>>
  +
; travel 12 cells left
  <<<<<<<<<<<<
  ]>
; move byte 3 of @007 to @013
  [-
; travel 12 cells right
  >>>>>>>>>>>>
  +
; travel 12 cells left
  <<<<<<<<<<<<
  ]
; travel 13 cells right
  >>>>>>>>>>>>>
; the rotation count
; add 12
  ++++++++++++

; ==== rotate one bit  n times ====
[
; one step consumed
  -

; ____ double byte 0 @0x00  carry into c0 @0x05 ____
; move w0 into x
  <<<< [->>>>>>>>>+<<<<<<<<<]
; y := x  x restored
  >>>>>>>>> [->+>>+<<<] >>>[-<<<+>>>] <<<
; ADD8 y into x
  > [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; store x into w0
  < [-<<<<<<<<<+>>>>>>>>>]
; carry into c0
  >> [-<<<<<<+>>>>>>]
; back to n
  <<<<<<<

; ____ double byte 1 @0x01  carry into c1 @0x06 ____
; move w1 into x
  <<< [->>>>>>>>+<<<<<<<<]
; y := x  x restored
  >>>>>>>> [->+>>+<<<] >>>[-<<<+>>>] <<<
; ADD8 y into x
  > [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; store x into w1
  < [-<<<<<<<<+>>>>>>>>]
; carry into c1
  >> [-<<<<<+>>>>>]
; back to n
  <<<<<<<

; ____ double byte 2 @0x02  carry into c2 @0x07 ____
; move w2 into x
  << [->>>>>>>+<<<<<<<]
; y := x  x restored
  >>>>>>> [->+>>+<<<] >>>[-<<<+>>>] <<<
; ADD8 y into x
  > [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; store x into w2
  < [-<<<<<<<+>>>>>>>]
; carry into c2
  >> [-<<<<+>>>>]
; back to n
  <<<<<<<

; ____ double byte 3 @0x03  carry into c3 @0x08 ____
; move w3 into x
  < [->>>>>>+<<<<<<]
; y := x  x restored
  >>>>>> [->+>>+<<<] >>>[-<<<+>>>] <<<
; ADD8 y into x
  > [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; store x into w3
  < [-<<<<<<+>>>>>>]
; carry into c3
  >> [-<<<+>>>]
; back to n
  <<<<<<<

; ____ feed the carries around the cycle ____
; w0 gets c3
  >>>> [-<<<<<<<<+>>>>>>>>]
; w1 gets c0
  <<< [-<<<<+>>>>]
; w2 gets c1
  > [-<<<<+>>>>]
; w3 gets c2
  > [-<<<<+>>>>]
; back to n
  <<<
]
; travel 4 cells left
  <<<<
; move byte 0 of @010 to @004
  [-
; travel 12 cells left
  <<<<<<<<<<<<
  +
; travel 12 cells right
  >>>>>>>>>>>>
  ]>
; move byte 1 of @011 to @005
  [-
; travel 12 cells left
  <<<<<<<<<<<<
  +
; travel 12 cells right
  >>>>>>>>>>>>
  ]>
; move byte 2 of @012 to @006
  [-
; travel 12 cells left
  <<<<<<<<<<<<
  +
; travel 12 cells right
  >>>>>>>>>>>>
  ]>
; move byte 3 of @013 to @007
  [-
; travel 12 cells left
  <<<<<<<<<<<<
  +
; travel 12 cells right
  >>>>>>>>>>>>
  ]
; travel 19 cells left
  <<<<<<<<<<<<<<<<<<<

; ================ round 3 : a b d  rotate 8 =================
; ADD32 : @000 gets @004
; move byte 0 of @000 to @010
  [-
; travel 16 cells right
  >>>>>>>>>>>>>>>>
  +
; travel 16 cells left
  <<<<<<<<<<<<<<<<
  ]>
; move byte 1 of @001 to @011
  [-
; travel 16 cells right
  >>>>>>>>>>>>>>>>
  +
; travel 16 cells left
  <<<<<<<<<<<<<<<<
  ]>
; move byte 2 of @002 to @012
  [-
; travel 16 cells right
  >>>>>>>>>>>>>>>>
  +
; travel 16 cells left
  <<<<<<<<<<<<<<<<
  ]>
; move byte 3 of @003 to @013
  [-
; travel 16 cells right
  >>>>>>>>>>>>>>>>
  +
; travel 16 cells left
  <<<<<<<<<<<<<<<<
  ]
; travel 1 cells right
  >
; copy byte 0 of @004 to @014 and to a temp
  [-
; travel 16 cells right
  >>>>>>>>>>>>>>>>
  +
; travel 22 cells right
  >>>>>>>>>>>>>>>>>>>>>>
  +
; travel 38 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]>
; copy byte 1 of @005 to @015 and to a temp
  [-
; travel 16 cells right
  >>>>>>>>>>>>>>>>
  +
; travel 22 cells right
  >>>>>>>>>>>>>>>>>>>>>>
  +
; travel 38 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]>
; copy byte 2 of @006 to @016 and to a temp
  [-
; travel 16 cells right
  >>>>>>>>>>>>>>>>
  +
; travel 22 cells right
  >>>>>>>>>>>>>>>>>>>>>>
  +
; travel 38 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]>
; copy byte 3 of @007 to @017 and to a temp
  [-
; travel 16 cells right
  >>>>>>>>>>>>>>>>
  +
; travel 22 cells right
  >>>>>>>>>>>>>>>>>>>>>>
  +
; travel 38 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; walk to the temps
; travel 35 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; put temp byte 0 back into @004
  [-
; travel 38 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 38 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]>
; put temp byte 1 back into @005
  [-
; travel 38 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 38 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]>
; put temp byte 2 back into @006
  [-
; travel 38 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 38 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]>
; put temp byte 3 back into @007
  [-
; travel 38 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 38 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 21 cells left
  <<<<<<<<<<<<<<<<<<<<<

; ==== byte 0 : a @0x00  b @0x04 ====
; move a0 into x
  <<<<<<<< [->>>>>>>>>+<<<<<<<<<]
; move b0 into y
  >>>> [->>>>>>+<<<<<<]
; ADD8 y into x
  >>>>>> [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; move cin into y
  << [->>+<<]
; ADD8 cin into x
  >> [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; store x into a0
  < [-<<<<<<<<<+>>>>>>>>>]
; carry c into cin
  >> [-<<<+>>>]
; back to cin
  <<<

; ==== byte 1 : a @0x01  b @0x05 ====
; move a1 into x
  <<<<<<< [->>>>>>>>+<<<<<<<<]
; move b1 into y
  >>>> [->>>>>+<<<<<]
; ADD8 y into x
  >>>>> [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; move cin into y
  << [->>+<<]
; ADD8 cin into x
  >> [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; store x into a1
  < [-<<<<<<<<+>>>>>>>>]
; carry c into cin
  >> [-<<<+>>>]
; back to cin
  <<<

; ==== byte 2 : a @0x02  b @0x06 ====
; move a2 into x
  <<<<<< [->>>>>>>+<<<<<<<]
; move b2 into y
  >>>> [->>>>+<<<<]
; ADD8 y into x
  >>>> [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; move cin into y
  << [->>+<<]
; ADD8 cin into x
  >> [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; store x into a2
  < [-<<<<<<<+>>>>>>>]
; carry c into cin
  >> [-<<<+>>>]
; back to cin
  <<<

; ==== byte 3 : a @0x03  b @0x07 ====
; move a3 into x
  <<<<< [->>>>>>+<<<<<<]
; move b3 into y
  >>>> [->>>+<<<]
; ADD8 y into x
  >>> [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; move cin into y
  << [->>+<<]
; ADD8 cin into x
  >> [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; store x into a3
  < [-<<<<<<+>>>>>>]
; carry c into cin
  >> [-<<<+>>>]
; back to cin (dropped)
  <<<
; drop the final carry
  [-]
; travel 8 cells left
  <<<<<<<<
; move byte 0 of @010 to @000
  [-
; travel 16 cells left
  <<<<<<<<<<<<<<<<
  +
; travel 16 cells right
  >>>>>>>>>>>>>>>>
  ]>
; move byte 1 of @011 to @001
  [-
; travel 16 cells left
  <<<<<<<<<<<<<<<<
  +
; travel 16 cells right
  >>>>>>>>>>>>>>>>
  ]>
; move byte 2 of @012 to @002
  [-
; travel 16 cells left
  <<<<<<<<<<<<<<<<
  +
; travel 16 cells right
  >>>>>>>>>>>>>>>>
  ]>
; move byte 3 of @013 to @003
  [-
; travel 16 cells left
  <<<<<<<<<<<<<<<<
  +
; travel 16 cells right
  >>>>>>>>>>>>>>>>
  ]
; travel 19 cells left
  <<<<<<<<<<<<<<<<<<<
; XOR32 : @00c gets @000
; travel 12 cells right
  >>>>>>>>>>>>
; move byte 0 of @00c to @010
  [-
; travel 4 cells right
  >>>>
  +
; travel 4 cells left
  <<<<
  ]>
; move byte 1 of @00d to @011
  [-
; travel 4 cells right
  >>>>
  +
; travel 4 cells left
  <<<<
  ]>
; move byte 2 of @00e to @012
  [-
; travel 4 cells right
  >>>>
  +
; travel 4 cells left
  <<<<
  ]>
; move byte 3 of @00f to @013
  [-
; travel 4 cells right
  >>>>
  +
; travel 4 cells left
  <<<<
  ]
; travel 15 cells left
  <<<<<<<<<<<<<<<
; copy byte 0 of @000 to @014 and to a temp
  [-
; travel 20 cells right
  >>>>>>>>>>>>>>>>>>>>
  +
; travel 22 cells right
  >>>>>>>>>>>>>>>>>>>>>>
  +
; travel 42 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<
  ]>
; copy byte 1 of @001 to @015 and to a temp
  [-
; travel 20 cells right
  >>>>>>>>>>>>>>>>>>>>
  +
; travel 22 cells right
  >>>>>>>>>>>>>>>>>>>>>>
  +
; travel 42 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<
  ]>
; copy byte 2 of @002 to @016 and to a temp
  [-
; travel 20 cells right
  >>>>>>>>>>>>>>>>>>>>
  +
; travel 22 cells right
  >>>>>>>>>>>>>>>>>>>>>>
  +
; travel 42 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<
  ]>
; copy byte 3 of @003 to @017 and to a temp
  [-
; travel 20 cells right
  >>>>>>>>>>>>>>>>>>>>
  +
; travel 22 cells right
  >>>>>>>>>>>>>>>>>>>>>>
  +
; travel 42 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<
  ]
; walk to the temps
; travel 39 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; put temp byte 0 back into @000
  [-
; travel 42 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<
  +
; travel 42 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>
  ]>
; put temp byte 1 back into @001
  [-
; travel 42 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<
  +
; travel 42 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>
  ]>
; put temp byte 2 back into @002
  [-
; travel 42 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<
  +
; travel 42 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>
  ]>
; put temp byte 3 back into @003
  [-
; travel 42 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<
  +
; travel 42 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>
  ]
; travel 21 cells left
  <<<<<<<<<<<<<<<<<<<<<

; ==== byte 0 : x0 @0x00  y0 @0x04  into r0 @0x08 ====
; move x0 into a
  <<<<<<<< [->>>>>>>>>>>>+<<<<<<<<<<<<]
; move y0 into b
  >>>> [->>>>>>>>>>>>+<<<<<<<<<<<<]
; p := 1
  >>>>>>>>>>>>>>>>>>> +
; cnt := 8
  > ++++++++
; ____ eight bit steps ____
  [-
; HALVE a  giving qa and pa
  <<<<<<<<<<<< [->>>+<[-<+>>-<]>[-<+>]<<<]
; HALVE b  giving qb and pb
  >>>> [->>>+<[-<+>>-<]>[-<+>]<<<]
; low bit of a toggles t
  << [->>>>>>>+<[->-<]>[-<+>]<<<<<<<]
; low bit of b toggles t
  >>>> [->>>+<[->-<]>[-<+>]<<<]
; if t then res gets p
  >> [->>>[-<+>>>+<<]>>[-<<+>>]<<<<<]
; a := qa
  <<<<<<< [-<+>]
; b := qb
  >>>> [-<+>]
; p into tmp
  >>>>>> [->>+<<]
; p := tmp doubled
  >> [-<<++>>]
; back to cnt
  <
  ]
; store res into r0
  << [-<<<<<<<<<<<<<<+>>>>>>>>>>>>>>]
; back to r0
  <<<<<<<<<<<<<<

; ==== byte 1 : x1 @0x01  y1 @0x05  into r1 @0x09 ====
; move x1 into a
  <<<<<<< [->>>>>>>>>>>+<<<<<<<<<<<]
; move y1 into b
  >>>> [->>>>>>>>>>>+<<<<<<<<<<<]
; p := 1
  >>>>>>>>>>>>>>>>>> +
; cnt := 8
  > ++++++++
  [-
; HALVE a  giving qa and pa
  <<<<<<<<<<<< [->>>+<[-<+>>-<]>[-<+>]<<<]
; HALVE b  giving qb and pb
  >>>> [->>>+<[-<+>>-<]>[-<+>]<<<]
; low bit of a toggles t
  << [->>>>>>>+<[->-<]>[-<+>]<<<<<<<]
; low bit of b toggles t
  >>>> [->>>+<[->-<]>[-<+>]<<<]
; if t then res gets p
  >> [->>>[-<+>>>+<<]>>[-<<+>>]<<<<<]
; a := qa
  <<<<<<< [-<+>]
; b := qb
  >>>> [-<+>]
; p into tmp
  >>>>>> [->>+<<]
; p := tmp doubled
  >> [-<<++>>]
; back to cnt
  <
  ]
; store res into r1
  << [-<<<<<<<<<<<<<+>>>>>>>>>>>>>]
; back to r0
  <<<<<<<<<<<<<<

; ==== byte 2 : x2 @0x02  y2 @0x06  into r2 @0x0a ====
; move x2 into a
  <<<<<< [->>>>>>>>>>+<<<<<<<<<<]
; move y2 into b
  >>>> [->>>>>>>>>>+<<<<<<<<<<]
; p := 1
  >>>>>>>>>>>>>>>>> +
; cnt := 8
  > ++++++++
  [-
; HALVE a  giving qa and pa
  <<<<<<<<<<<< [->>>+<[-<+>>-<]>[-<+>]<<<]
; HALVE b  giving qb and pb
  >>>> [->>>+<[-<+>>-<]>[-<+>]<<<]
; low bit of a toggles t
  << [->>>>>>>+<[->-<]>[-<+>]<<<<<<<]
; low bit of b toggles t
  >>>> [->>>+<[->-<]>[-<+>]<<<]
; if t then res gets p
  >> [->>>[-<+>>>+<<]>>[-<<+>>]<<<<<]
; a := qa
  <<<<<<< [-<+>]
; b := qb
  >>>> [-<+>]
; p into tmp
  >>>>>> [->>+<<]
; p := tmp doubled
  >> [-<<++>>]
; back to cnt
  <
  ]
; store res into r2
  << [-<<<<<<<<<<<<+>>>>>>>>>>>>]
; back to r0
  <<<<<<<<<<<<<<

; ==== byte 3 : x3 @0x03  y3 @0x07  into r3 @0x0b ====
; move x3 into a
  <<<<< [->>>>>>>>>+<<<<<<<<<]
; move y3 into b
  >>>> [->>>>>>>>>+<<<<<<<<<]
; p := 1
  >>>>>>>>>>>>>>>> +
; cnt := 8
  > ++++++++
  [-
; HALVE a  giving qa and pa
  <<<<<<<<<<<< [->>>+<[-<+>>-<]>[-<+>]<<<]
; HALVE b  giving qb and pb
  >>>> [->>>+<[-<+>>-<]>[-<+>]<<<]
; low bit of a toggles t
  << [->>>>>>>+<[->-<]>[-<+>]<<<<<<<]
; low bit of b toggles t
  >>>> [->>>+<[->-<]>[-<+>]<<<]
; if t then res gets p
  >> [->>>[-<+>>>+<<]>>[-<<+>>]<<<<<]
; a := qa
  <<<<<<< [-<+>]
; b := qb
  >>>> [-<+>]
; p into tmp
  >>>>>> [->>+<<]
; p := tmp doubled
  >> [-<<++>>]
; back to cnt
  <
  ]
; store res into r3
  << [-<<<<<<<<<<<+>>>>>>>>>>>]
; back to r0
  <<<<<<<<<<<<<<
; move byte 0 of @018 to @00c
  [-
; travel 12 cells left
  <<<<<<<<<<<<
  +
; travel 12 cells right
  >>>>>>>>>>>>
  ]>
; move byte 1 of @019 to @00d
  [-
; travel 12 cells left
  <<<<<<<<<<<<
  +
; travel 12 cells right
  >>>>>>>>>>>>
  ]>
; move byte 2 of @01a to @00e
  [-
; travel 12 cells left
  <<<<<<<<<<<<
  +
; travel 12 cells right
  >>>>>>>>>>>>
  ]>
; move byte 3 of @01b to @00f
  [-
; travel 12 cells left
  <<<<<<<<<<<<
  +
; travel 12 cells right
  >>>>>>>>>>>>
  ]
; travel 27 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<
; ROTL32 : @00c rotates left 8
; travel 12 cells right
  >>>>>>>>>>>>
; move byte 0 of @00c to @010
  [-
; travel 4 cells right
  >>>>
  +
; travel 4 cells left
  <<<<
  ]>
; move byte 1 of @00d to @011
  [-
; travel 4 cells right
  >>>>
  +
; travel 4 cells left
  <<<<
  ]>
; move byte 2 of @00e to @012
  [-
; travel 4 cells right
  >>>>
  +
; travel 4 cells left
  <<<<
  ]>
; move byte 3 of @00f to @013
  [-
; travel 4 cells right
  >>>>
  +
; travel 4 cells left
  <<<<
  ]
; travel 5 cells right
  >>>>>
; the rotation count
; add 8
  ++++++++

; ==== rotate one bit  n times ====
[
; one step consumed
  -

; ____ double byte 0 @0x00  carry into c0 @0x05 ____
; move w0 into x
  <<<< [->>>>>>>>>+<<<<<<<<<]
; y := x  x restored
  >>>>>>>>> [->+>>+<<<] >>>[-<<<+>>>] <<<
; ADD8 y into x
  > [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; store x into w0
  < [-<<<<<<<<<+>>>>>>>>>]
; carry into c0
  >> [-<<<<<<+>>>>>>]
; back to n
  <<<<<<<

; ____ double byte 1 @0x01  carry into c1 @0x06 ____
; move w1 into x
  <<< [->>>>>>>>+<<<<<<<<]
; y := x  x restored
  >>>>>>>> [->+>>+<<<] >>>[-<<<+>>>] <<<
; ADD8 y into x
  > [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; store x into w1
  < [-<<<<<<<<+>>>>>>>>]
; carry into c1
  >> [-<<<<<+>>>>>]
; back to n
  <<<<<<<

; ____ double byte 2 @0x02  carry into c2 @0x07 ____
; move w2 into x
  << [->>>>>>>+<<<<<<<]
; y := x  x restored
  >>>>>>> [->+>>+<<<] >>>[-<<<+>>>] <<<
; ADD8 y into x
  > [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; store x into w2
  < [-<<<<<<<+>>>>>>>]
; carry into c2
  >> [-<<<<+>>>>]
; back to n
  <<<<<<<

; ____ double byte 3 @0x03  carry into c3 @0x08 ____
; move w3 into x
  < [->>>>>>+<<<<<<]
; y := x  x restored
  >>>>>> [->+>>+<<<] >>>[-<<<+>>>] <<<
; ADD8 y into x
  > [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; store x into w3
  < [-<<<<<<+>>>>>>]
; carry into c3
  >> [-<<<+>>>]
; back to n
  <<<<<<<

; ____ feed the carries around the cycle ____
; w0 gets c3
  >>>> [-<<<<<<<<+>>>>>>>>]
; w1 gets c0
  <<< [-<<<<+>>>>]
; w2 gets c1
  > [-<<<<+>>>>]
; w3 gets c2
  > [-<<<<+>>>>]
; back to n
  <<<
]
; travel 4 cells left
  <<<<
; move byte 0 of @010 to @00c
  [-
; travel 4 cells left
  <<<<
  +
; travel 4 cells right
  >>>>
  ]>
; move byte 1 of @011 to @00d
  [-
; travel 4 cells left
  <<<<
  +
; travel 4 cells right
  >>>>
  ]>
; move byte 2 of @012 to @00e
  [-
; travel 4 cells left
  <<<<
  +
; travel 4 cells right
  >>>>
  ]>
; move byte 3 of @013 to @00f
  [-
; travel 4 cells left
  <<<<
  +
; travel 4 cells right
  >>>>
  ]
; travel 19 cells left
  <<<<<<<<<<<<<<<<<<<

; ================ round 4 : c d b  rotate 7 =================
; ADD32 : @008 gets @00c
; travel 8 cells right
  >>>>>>>>
; move byte 0 of @008 to @010
  [-
; travel 8 cells right
  >>>>>>>>
  +
; travel 8 cells left
  <<<<<<<<
  ]>
; move byte 1 of @009 to @011
  [-
; travel 8 cells right
  >>>>>>>>
  +
; travel 8 cells left
  <<<<<<<<
  ]>
; move byte 2 of @00a to @012
  [-
; travel 8 cells right
  >>>>>>>>
  +
; travel 8 cells left
  <<<<<<<<
  ]>
; move byte 3 of @00b to @013
  [-
; travel 8 cells right
  >>>>>>>>
  +
; travel 8 cells left
  <<<<<<<<
  ]
; travel 1 cells right
  >
; copy byte 0 of @00c to @014 and to a temp
  [-
; travel 8 cells right
  >>>>>>>>
  +
; travel 22 cells right
  >>>>>>>>>>>>>>>>>>>>>>
  +
; travel 30 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]>
; copy byte 1 of @00d to @015 and to a temp
  [-
; travel 8 cells right
  >>>>>>>>
  +
; travel 22 cells right
  >>>>>>>>>>>>>>>>>>>>>>
  +
; travel 30 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]>
; copy byte 2 of @00e to @016 and to a temp
  [-
; travel 8 cells right
  >>>>>>>>
  +
; travel 22 cells right
  >>>>>>>>>>>>>>>>>>>>>>
  +
; travel 30 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]>
; copy byte 3 of @00f to @017 and to a temp
  [-
; travel 8 cells right
  >>>>>>>>
  +
; travel 22 cells right
  >>>>>>>>>>>>>>>>>>>>>>
  +
; travel 30 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; walk to the temps
; travel 27 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>
; put temp byte 0 back into @00c
  [-
; travel 30 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 30 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]>
; put temp byte 1 back into @00d
  [-
; travel 30 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 30 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]>
; put temp byte 2 back into @00e
  [-
; travel 30 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 30 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]>
; put temp byte 3 back into @00f
  [-
; travel 30 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 30 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 21 cells left
  <<<<<<<<<<<<<<<<<<<<<

; ==== byte 0 : a @0x00  b @0x04 ====
; move a0 into x
  <<<<<<<< [->>>>>>>>>+<<<<<<<<<]
; move b0 into y
  >>>> [->>>>>>+<<<<<<]
; ADD8 y into x
  >>>>>> [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; move cin into y
  << [->>+<<]
; ADD8 cin into x
  >> [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; store x into a0
  < [-<<<<<<<<<+>>>>>>>>>]
; carry c into cin
  >> [-<<<+>>>]
; back to cin
  <<<

; ==== byte 1 : a @0x01  b @0x05 ====
; move a1 into x
  <<<<<<< [->>>>>>>>+<<<<<<<<]
; move b1 into y
  >>>> [->>>>>+<<<<<]
; ADD8 y into x
  >>>>> [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; move cin into y
  << [->>+<<]
; ADD8 cin into x
  >> [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; store x into a1
  < [-<<<<<<<<+>>>>>>>>]
; carry c into cin
  >> [-<<<+>>>]
; back to cin
  <<<

; ==== byte 2 : a @0x02  b @0x06 ====
; move a2 into x
  <<<<<< [->>>>>>>+<<<<<<<]
; move b2 into y
  >>>> [->>>>+<<<<]
; ADD8 y into x
  >>>> [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; move cin into y
  << [->>+<<]
; ADD8 cin into x
  >> [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; store x into a2
  < [-<<<<<<<+>>>>>>>]
; carry c into cin
  >> [-<<<+>>>]
; back to cin
  <<<

; ==== byte 3 : a @0x03  b @0x07 ====
; move a3 into x
  <<<<< [->>>>>>+<<<<<<]
; move b3 into y
  >>>> [->>>+<<<]
; ADD8 y into x
  >>> [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; move cin into y
  << [->>+<<]
; ADD8 cin into x
  >> [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; store x into a3
  < [-<<<<<<+>>>>>>]
; carry c into cin
  >> [-<<<+>>>]
; back to cin (dropped)
  <<<
; drop the final carry
  [-]
; travel 8 cells left
  <<<<<<<<
; move byte 0 of @010 to @008
  [-
; travel 8 cells left
  <<<<<<<<
  +
; travel 8 cells right
  >>>>>>>>
  ]>
; move byte 1 of @011 to @009
  [-
; travel 8 cells left
  <<<<<<<<
  +
; travel 8 cells right
  >>>>>>>>
  ]>
; move byte 2 of @012 to @00a
  [-
; travel 8 cells left
  <<<<<<<<
  +
; travel 8 cells right
  >>>>>>>>
  ]>
; move byte 3 of @013 to @00b
  [-
; travel 8 cells left
  <<<<<<<<
  +
; travel 8 cells right
  >>>>>>>>
  ]
; travel 19 cells left
  <<<<<<<<<<<<<<<<<<<
; XOR32 : @004 gets @008
; travel 4 cells right
  >>>>
; move byte 0 of @004 to @010
  [-
; travel 12 cells right
  >>>>>>>>>>>>
  +
; travel 12 cells left
  <<<<<<<<<<<<
  ]>
; move byte 1 of @005 to @011
  [-
; travel 12 cells right
  >>>>>>>>>>>>
  +
; travel 12 cells left
  <<<<<<<<<<<<
  ]>
; move byte 2 of @006 to @012
  [-
; travel 12 cells right
  >>>>>>>>>>>>
  +
; travel 12 cells left
  <<<<<<<<<<<<
  ]>
; move byte 3 of @007 to @013
  [-
; travel 12 cells right
  >>>>>>>>>>>>
  +
; travel 12 cells left
  <<<<<<<<<<<<
  ]
; travel 1 cells right
  >
; copy byte 0 of @008 to @014 and to a temp
  [-
; travel 12 cells right
  >>>>>>>>>>>>
  +
; travel 22 cells right
  >>>>>>>>>>>>>>>>>>>>>>
  +
; travel 34 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]>
; copy byte 1 of @009 to @015 and to a temp
  [-
; travel 12 cells right
  >>>>>>>>>>>>
  +
; travel 22 cells right
  >>>>>>>>>>>>>>>>>>>>>>
  +
; travel 34 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]>
; copy byte 2 of @00a to @016 and to a temp
  [-
; travel 12 cells right
  >>>>>>>>>>>>
  +
; travel 22 cells right
  >>>>>>>>>>>>>>>>>>>>>>
  +
; travel 34 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]>
; copy byte 3 of @00b to @017 and to a temp
  [-
; travel 12 cells right
  >>>>>>>>>>>>
  +
; travel 22 cells right
  >>>>>>>>>>>>>>>>>>>>>>
  +
; travel 34 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; walk to the temps
; travel 31 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; put temp byte 0 back into @008
  [-
; travel 34 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]>
; put temp byte 1 back into @009
  [-
; travel 34 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]>
; put temp byte 2 back into @00a
  [-
; travel 34 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]>
; put temp byte 3 back into @00b
  [-
; travel 34 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 21 cells left
  <<<<<<<<<<<<<<<<<<<<<

; ==== byte 0 : x0 @0x00  y0 @0x04  into r0 @0x08 ====
; move x0 into a
  <<<<<<<< [->>>>>>>>>>>>+<<<<<<<<<<<<]
; move y0 into b
  >>>> [->>>>>>>>>>>>+<<<<<<<<<<<<]
; p := 1
  >>>>>>>>>>>>>>>>>>> +
; cnt := 8
  > ++++++++
; ____ eight bit steps ____
  [-
; HALVE a  giving qa and pa
  <<<<<<<<<<<< [->>>+<[-<+>>-<]>[-<+>]<<<]
; HALVE b  giving qb and pb
  >>>> [->>>+<[-<+>>-<]>[-<+>]<<<]
; low bit of a toggles t
  << [->>>>>>>+<[->-<]>[-<+>]<<<<<<<]
; low bit of b toggles t
  >>>> [->>>+<[->-<]>[-<+>]<<<]
; if t then res gets p
  >> [->>>[-<+>>>+<<]>>[-<<+>>]<<<<<]
; a := qa
  <<<<<<< [-<+>]
; b := qb
  >>>> [-<+>]
; p into tmp
  >>>>>> [->>+<<]
; p := tmp doubled
  >> [-<<++>>]
; back to cnt
  <
  ]
; store res into r0
  << [-<<<<<<<<<<<<<<+>>>>>>>>>>>>>>]
; back to r0
  <<<<<<<<<<<<<<

; ==== byte 1 : x1 @0x01  y1 @0x05  into r1 @0x09 ====
; move x1 into a
  <<<<<<< [->>>>>>>>>>>+<<<<<<<<<<<]
; move y1 into b
  >>>> [->>>>>>>>>>>+<<<<<<<<<<<]
; p := 1
  >>>>>>>>>>>>>>>>>> +
; cnt := 8
  > ++++++++
  [-
; HALVE a  giving qa and pa
  <<<<<<<<<<<< [->>>+<[-<+>>-<]>[-<+>]<<<]
; HALVE b  giving qb and pb
  >>>> [->>>+<[-<+>>-<]>[-<+>]<<<]
; low bit of a toggles t
  << [->>>>>>>+<[->-<]>[-<+>]<<<<<<<]
; low bit of b toggles t
  >>>> [->>>+<[->-<]>[-<+>]<<<]
; if t then res gets p
  >> [->>>[-<+>>>+<<]>>[-<<+>>]<<<<<]
; a := qa
  <<<<<<< [-<+>]
; b := qb
  >>>> [-<+>]
; p into tmp
  >>>>>> [->>+<<]
; p := tmp doubled
  >> [-<<++>>]
; back to cnt
  <
  ]
; store res into r1
  << [-<<<<<<<<<<<<<+>>>>>>>>>>>>>]
; back to r0
  <<<<<<<<<<<<<<

; ==== byte 2 : x2 @0x02  y2 @0x06  into r2 @0x0a ====
; move x2 into a
  <<<<<< [->>>>>>>>>>+<<<<<<<<<<]
; move y2 into b
  >>>> [->>>>>>>>>>+<<<<<<<<<<]
; p := 1
  >>>>>>>>>>>>>>>>> +
; cnt := 8
  > ++++++++
  [-
; HALVE a  giving qa and pa
  <<<<<<<<<<<< [->>>+<[-<+>>-<]>[-<+>]<<<]
; HALVE b  giving qb and pb
  >>>> [->>>+<[-<+>>-<]>[-<+>]<<<]
; low bit of a toggles t
  << [->>>>>>>+<[->-<]>[-<+>]<<<<<<<]
; low bit of b toggles t
  >>>> [->>>+<[->-<]>[-<+>]<<<]
; if t then res gets p
  >> [->>>[-<+>>>+<<]>>[-<<+>>]<<<<<]
; a := qa
  <<<<<<< [-<+>]
; b := qb
  >>>> [-<+>]
; p into tmp
  >>>>>> [->>+<<]
; p := tmp doubled
  >> [-<<++>>]
; back to cnt
  <
  ]
; store res into r2
  << [-<<<<<<<<<<<<+>>>>>>>>>>>>]
; back to r0
  <<<<<<<<<<<<<<

; ==== byte 3 : x3 @0x03  y3 @0x07  into r3 @0x0b ====
; move x3 into a
  <<<<< [->>>>>>>>>+<<<<<<<<<]
; move y3 into b
  >>>> [->>>>>>>>>+<<<<<<<<<]
; p := 1
  >>>>>>>>>>>>>>>> +
; cnt := 8
  > ++++++++
  [-
; HALVE a  giving qa and pa
  <<<<<<<<<<<< [->>>+<[-<+>>-<]>[-<+>]<<<]
; HALVE b  giving qb and pb
  >>>> [->>>+<[-<+>>-<]>[-<+>]<<<]
; low bit of a toggles t
  << [->>>>>>>+<[->-<]>[-<+>]<<<<<<<]
; low bit of b toggles t
  >>>> [->>>+<[->-<]>[-<+>]<<<]
; if t then res gets p
  >> [->>>[-<+>>>+<<]>>[-<<+>>]<<<<<]
; a := qa
  <<<<<<< [-<+>]
; b := qb
  >>>> [-<+>]
; p into tmp
  >>>>>> [->>+<<]
; p := tmp doubled
  >> [-<<++>>]
; back to cnt
  <
  ]
; store res into r3
  << [-<<<<<<<<<<<+>>>>>>>>>>>]
; back to r0
  <<<<<<<<<<<<<<
; move byte 0 of @018 to @004
  [-
; travel 20 cells left
  <<<<<<<<<<<<<<<<<<<<
  +
; travel 20 cells right
  >>>>>>>>>>>>>>>>>>>>
  ]>
; move byte 1 of @019 to @005
  [-
; travel 20 cells left
  <<<<<<<<<<<<<<<<<<<<
  +
; travel 20 cells right
  >>>>>>>>>>>>>>>>>>>>
  ]>
; move byte 2 of @01a to @006
  [-
; travel 20 cells left
  <<<<<<<<<<<<<<<<<<<<
  +
; travel 20 cells right
  >>>>>>>>>>>>>>>>>>>>
  ]>
; move byte 3 of @01b to @007
  [-
; travel 20 cells left
  <<<<<<<<<<<<<<<<<<<<
  +
; travel 20 cells right
  >>>>>>>>>>>>>>>>>>>>
  ]
; travel 27 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<
; ROTL32 : @004 rotates left 7
; travel 4 cells right
  >>>>
; move byte 0 of @004 to @010
  [-
; travel 12 cells right
  >>>>>>>>>>>>
  +
; travel 12 cells left
  <<<<<<<<<<<<
  ]>
; move byte 1 of @005 to @011
  [-
; travel 12 cells right
  >>>>>>>>>>>>
  +
; travel 12 cells left
  <<<<<<<<<<<<
  ]>
; move byte 2 of @006 to @012
  [-
; travel 12 cells right
  >>>>>>>>>>>>
  +
; travel 12 cells left
  <<<<<<<<<<<<
  ]>
; move byte 3 of @007 to @013
  [-
; travel 12 cells right
  >>>>>>>>>>>>
  +
; travel 12 cells left
  <<<<<<<<<<<<
  ]
; travel 13 cells right
  >>>>>>>>>>>>>
; the rotation count
; add 7
  +++++++

; ==== rotate one bit  n times ====
[
; one step consumed
  -

; ____ double byte 0 @0x00  carry into c0 @0x05 ____
; move w0 into x
  <<<< [->>>>>>>>>+<<<<<<<<<]
; y := x  x restored
  >>>>>>>>> [->+>>+<<<] >>>[-<<<+>>>] <<<
; ADD8 y into x
  > [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; store x into w0
  < [-<<<<<<<<<+>>>>>>>>>]
; carry into c0
  >> [-<<<<<<+>>>>>>]
; back to n
  <<<<<<<

; ____ double byte 1 @0x01  carry into c1 @0x06 ____
; move w1 into x
  <<< [->>>>>>>>+<<<<<<<<]
; y := x  x restored
  >>>>>>>> [->+>>+<<<] >>>[-<<<+>>>] <<<
; ADD8 y into x
  > [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; store x into w1
  < [-<<<<<<<<+>>>>>>>>]
; carry into c1
  >> [-<<<<<+>>>>>]
; back to n
  <<<<<<<

; ____ double byte 2 @0x02  carry into c2 @0x07 ____
; move w2 into x
  << [->>>>>>>+<<<<<<<]
; y := x  x restored
  >>>>>>> [->+>>+<<<] >>>[-<<<+>>>] <<<
; ADD8 y into x
  > [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; store x into w2
  < [-<<<<<<<+>>>>>>>]
; carry into c2
  >> [-<<<<+>>>>]
; back to n
  <<<<<<<

; ____ double byte 3 @0x03  carry into c3 @0x08 ____
; move w3 into x
  < [->>>>>>+<<<<<<]
; y := x  x restored
  >>>>>> [->+>>+<<<] >>>[-<<<+>>>] <<<
; ADD8 y into x
  > [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; store x into w3
  < [-<<<<<<+>>>>>>]
; carry into c3
  >> [-<<<+>>>]
; back to n
  <<<<<<<

; ____ feed the carries around the cycle ____
; w0 gets c3
  >>>> [-<<<<<<<<+>>>>>>>>]
; w1 gets c0
  <<< [-<<<<+>>>>]
; w2 gets c1
  > [-<<<<+>>>>]
; w3 gets c2
  > [-<<<<+>>>>]
; back to n
  <<<
]
; travel 4 cells left
  <<<<
; move byte 0 of @010 to @004
  [-
; travel 12 cells left
  <<<<<<<<<<<<
  +
; travel 12 cells right
  >>>>>>>>>>>>
  ]>
; move byte 1 of @011 to @005
  [-
; travel 12 cells left
  <<<<<<<<<<<<
  +
; travel 12 cells right
  >>>>>>>>>>>>
  ]>
; move byte 2 of @012 to @006
  [-
; travel 12 cells left
  <<<<<<<<<<<<
  +
; travel 12 cells right
  >>>>>>>>>>>>
  ]>
; move byte 3 of @013 to @007
  [-
; travel 12 cells left
  <<<<<<<<<<<<
  +
; travel 12 cells right
  >>>>>>>>>>>>
  ]
; travel 19 cells left
  <<<<<<<<<<<<<<<<<<<

; emit a b c d little endian
  .>.>.>.>.>.>.>.>.>.>.>.>.>.>.>.
