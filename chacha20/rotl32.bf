; bfsodium ROTL32 : rotate a 32 bit little endian word left by n bits
;
; NOTE square brackets are brainfuck loops  so comments use braces for counts;
;
; INTERFACE entry=4 exit=4 footprint=0:13
; IO  in:  w{4} LE  followed by  n{1}          (5 bytes)
;     out: (w rotated left by n){4} LE         (4 bytes)
;
; TAPE MAP  (home @0)
;   @0x00:0x03  w{4}   u8   the word  LSB at @0x00
;   @0x04       n      u8   remaining rotation steps  the loop counter
;   @0x05:0x08  c{4}   u8   carry out of doubling each byte
;   @0x09       x      u8   ADD8 frame: accumulator
;   @0x0a       y      u8   ADD8 frame: addend  consumed to 0
;   @0x0b       c      u8   ADD8 frame: carry out
;   @0x0c       t0     u8   ADD8 frame scratch  restored 0
;   @0x0d       t1     u8   ADD8 frame scratch  restored 0
;
; A rotation by n is n single bit rotations  driven by the counter at @0x04;
; One single bit rotation doubles every byte and feeds each carry into the
; next byte cyclically; doubling byte i yields bit 7 of byte i as its carry
; and leaves the byte even  so adding the neighbour carry cannot overflow;
; The doubling reuses the proven ADD8 kernel with y set to a copy of x  since
; x plus x is exactly 2x with carry equal to bit 7 of x;

; read w{0:3} then n  leaving the pointer on n @0x04
,>,>,>,>,

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

; emit the rotated word little endian
<<<< .>.>.>.
