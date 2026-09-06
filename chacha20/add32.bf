; bfsodium ADD32 : 32 bit little endian add   a := (a plus b) mod 2^32
;
; NOTE square brackets are brainfuck loops  so comments use braces for counts;
;
; IO  in:  a{4} LE  followed by  b{4} LE      (8 bytes)
;     out: sum{4} LE                          (4 bytes; final carry dropped)
;
; TAPE MAP  (home @0)
;   @0x00:0x03  a{4}   u8   result accumulates here (LSB at @0x00)
;   @0x04:0x07  b{4}   u8   addend
;   @0x08       cin    u8   carry into the current byte (starts 0)
;   @0x09       x      u8   ADD8 frame: accumulator
;   @0x0a       y      u8   ADD8 frame: addend (consumed to 0)
;   @0x0b       c      u8   ADD8 frame: carry out
;   @0x0c       t0     u8   ADD8 frame scratch (restored 0)
;   @0x0d       t1     u8   ADD8 frame scratch (restored 0)
;
; ADD8 kernel  (enter at y @0x0a  exit at y @0x0a):
;   adds y into x mod 256  sets y to 0  adds the carry into c  restores t0 t1
;   to 0; It detects the single wrap of x by copying x into two temps  bumping
;   c tentatively  then undoing that bump unless the copy was zero (the proven
;   zero test trick); Since a byte sum is at most 511  x wraps at most once  so
;   c gains at most 1 per ADD8 and the two ADD8s per byte never both carry;
;
; Each byte block adds b{i} then cin into a{i}  stores the low byte back into
; a{i}  and moves the carry out into cin for the next byte; Four byte blocks 
; LSB first; the carry out of byte 3 is the dropped final carry;

; read a{0:3} then b{0:3}  leaving the pointer on cin @0x08
,>,>,>,>,>,>,>,>

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

; emit sum a{0:3} little endian
<<<<<<<< .>.>.>.
