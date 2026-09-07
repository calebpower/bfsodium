; bfsodium XOR32 : bitwise exclusive or of two 32 bit little endian words
;
; NOTE square brackets are brainfuck loops  so comments use braces for counts;
;
; INTERFACE entry=8 exit=8 footprint=0:25
; IO  in:  x{4} LE  followed by  y{4} LE       (8 bytes)
;     out: (x xor y){4} LE                     (4 bytes)
;
; TAPE MAP  (home @0)
;   @0x00:0x03  x{4}   u8   first operand   LSB at @0x00
;   @0x04:0x07  y{4}   u8   second operand
;   @0x08:0x0b  r{4}   u8   result
;   @0x0c       a      u8   XOR8 frame: left byte  halved away to 0
;   @0x0d       qa     u8   XOR8 frame: a shifted right one
;   @0x0e       pa     u8   XOR8 frame: low bit of a
;   @0x0f       fa     u8   XOR8 frame scratch  restored 0
;   @0x10       b      u8   XOR8 frame: right byte  halved away to 0
;   @0x11       qb     u8   XOR8 frame: b shifted right one
;   @0x12       pb     u8   XOR8 frame: low bit of b
;   @0x13       fb     u8   XOR8 frame scratch  restored 0
;   @0x14       t      u8   XOR8 frame: the exclusive or of the two low bits
;   @0x15       ft     u8   XOR8 frame scratch  restored 0
;   @0x16       res    u8   XOR8 frame: accumulating result byte
;   @0x17       p      u8   XOR8 frame: current bit weight  1 2 4 ; 128
;   @0x18       cnt    u8   XOR8 frame: bits remaining  starts at 8
;   @0x19       tmp    u8   XOR8 frame scratch  restored 0
;
; brainfuck has no bitwise instruction  so XOR8 decomposes both bytes;
; A 256 by 256 lookup table was the original plan but is the wrong shape here:
; the table would sit tens of thousands of cells away from the working frame
; and every lookup would pay that distance in pointer travel  which costs far
; more than recomputing the bits; see the note in CONVENTIONS;
;
; HALVE is the workhorse: for a cell at position k with q at k plus 1  t at
; k plus 2 and f at k plus 3  it leaves q equal to the value shifted right one
; and t equal to the low bit  by counting down and toggling t on each step;
; XOR8 runs it eight times on each byte  toggles t once per set low bit  so t
; ends as the exclusive or  then adds the current weight p into res when t is
; set  and doubles p for the next bit;

,>,>,>,>,>,>,>,>                                               ; read x{0:3} then y{0:3}  leaving the pointer on r0
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

; emit the result little endian
.>.>.>.
