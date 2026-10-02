; bfsodium XOR32 : bitwise exclusive or of two 32 bit little endian words
;
; NOTE square brackets are brainfuck loops  so comments use braces for counts;
;
; HAND WRITTEN; nothing is pasted and nothing is included; the eight bit steps
; are written out here  for the reason below;
;
; INTERFACE entry=8 exit=8 footprint=0:25
; IO  in:  x{4} LE  followed by  y{4} LE       (8 bytes)
;     out: (x xor y){4} LE                     (4 bytes)
;
; brainfuck has no bitwise instruction  so each byte is decomposed; HALVE is
; the workhorse: for a cell at position k with q at k plus 1  t at k plus 2
; and f at k plus 3  it leaves q equal to the value shifted right one and t
; equal to the low bit  by counting down and toggling t on each step; Eight of
; those on each byte  toggling t once per set low bit  leaves t as the
; exclusive or; then the current weight p is added into res when t is set  and
; p doubles for the next bit;
;
; A 256 BY 256 LOOKUP TABLE WAS THE ORIGINAL PLAN and is the wrong shape here:
; the table would sit tens of thousands of cells away from the working frame
; and every lookup would pay that distance in pointer travel  which costs far
; more than recomputing the bits; see the note in CONVENTIONS;
;
; THE KERNEL IS WRITTEN OUT FOUR TIMES AND THAT IS DELIBERATE; block/xor8kernel
; holds exactly this and idiom/xor8 includes it  so including it here instead
; would be the obvious tidy; it is also measurably wrong; An include is textual
; and carries the block's comments into every expansion  and this file is
; PASTED at fifty five sites  so the kernel's twenty two comment lines would
; land four times in each of them; HANDOFF records the measurement: the kernel
; appears 30 thousand times across the committed brainfuck  and factoring it
; would add two thirds of a million lines; A one line idiom repeated often is
; the expensive thing to factor  not the cheap one;
;
; TAPE MAP  (home @0)
;   @0x00:0x03  x{4}   u8   first operand   LSB at @0x00
;   @0x04:0x07  y{4}   u8   second operand
;   @0x08:0x0b  r{4}   u8   result
;   @0x0c       a      u8   the left byte  halved away to 0
;   @0x0d       qa     u8   a shifted right one
;   @0x0e       pa     u8   the low bit of a
;   @0x0f       fa     u8   scratch  restored 0
;   @0x10       b      u8   the right byte  halved away to 0
;   @0x11       qb     u8   b shifted right one
;   @0x12       pb     u8   the low bit of b
;   @0x13       fb     u8   scratch  restored 0
;   @0x14       t      u8   the exclusive or of the two low bits
;   @0x15       ft     u8   scratch  restored 0
;   @0x16       res    u8   the accumulating result byte
;   @0x17       p      u8   the current bit weight  1 2 4 ; 128
;   @0x18       cnt    u8   bits remaining  starts at 8
;   @0x19       tmp    u8   scratch  restored 0
;
; THE FOUR BLOCKS DIFFER ONLY IN THEIR DISTANCES; byte i reads x at i and y at
; i plus 4 and writes r at i plus 8  so each block's three navigation numbers
; walk by one while the frame above stays where it is; The bit steps inside
; them are the same twenty lines four times over;

,>,>,>,>,>,>,>,>                                               ; read x{0:3} then y{0:3}  leaving the pointer on r0
                                                               ; @0x08

; ============================================================ ; byte 0 : x0 @0x00  y0 @0x04  into r0 @0x08
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

; ============================================================ ; byte 1 : x1 @0x01  y1 @0x05  into r1 @0x09
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

; ============================================================ ; byte 2 : x2 @0x02  y2 @0x06  into r2 @0x0a
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

; ============================================================ ; byte 3 : x3 @0x03  y3 @0x07  into r3 @0x0b
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
