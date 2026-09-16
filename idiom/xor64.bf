; bfsodium XOR64 : bitwise exclusive or of two 64 bit little endian words
;
; NOTE square brackets are brainfuck loops  so comments use braces for counts;
;
; INTERFACE entry=16 exit=16 footprint=0:37
; IO  in:  x{8} LE  followed by  y{8} LE      (16 bytes)
;     out: (x xor y){8} LE                    (8 bytes)
;
; TAPE MAP  (home @0)
;   @0x00:0x07  x{8}   u8   first operand   LSB at @0x00
;   @0x08:0x0f  y{8}   u8   second operand
;   @0x10:0x17  r{8}   u8   result
;   @0x18       a      u8   XOR8 frame: left byte  halved away to 0
;   @0x19       qa     u8   XOR8 frame: a shifted right one
;   @0x1a       pa     u8   XOR8 frame: low bit of a
;   @0x1b       fa     u8   XOR8 frame scratch  restored 0
;   @0x1c       b      u8   XOR8 frame: right byte  halved away to 0
;   @0x1d       qb     u8   XOR8 frame: b shifted right one
;   @0x1e       pb     u8   XOR8 frame: low bit of b
;   @0x1f       fb     u8   XOR8 frame scratch  restored 0
;   @0x20       t      u8   XOR8 frame: the exclusive or of the two low bits
;   @0x21       ft     u8   XOR8 frame scratch  restored 0
;   @0x22       res    u8   XOR8 frame: accumulating result byte
;   @0x23       p      u8   XOR8 frame: current bit weight  1 2 4 ; 128
;   @0x24       cnt    u8   XOR8 frame: bits remaining  starts at 8
;   @0x25       tmp    u8   XOR8 frame scratch  restored 0
;
; THE 64 BIT WIDENING OF chacha20/xor32  and the second of the four pieces
; SHA_512 needs; Keccak wants it too  since theta and chi are exclusive or
; over 64 bit lanes and nothing else;
;
; The XOR8 FRAME IS UNCHANGED  down to the character: xor32 puts a at the
; foot of its frame with qa pa fa b qb pb fb t ft res p cnt tmp above it in
; that order  and so does this  so every arrow inside the eight bit step is
; the same arrow; Only the three journeys that reach OUTSIDE the frame differ
; namely fetching x_i  fetching y_i  and storing res  and those are the ones
; the generator computes; That is the whole content of widening it;
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

,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>                               ; read x{0:7} then y{0:7}  leaving the pointer on r0
                                                               ; @0x10
                                                               ; ASSERT ptr=16
                                                               ; ASSERT zero 16:37

; ============================================================ ; byte 0 : x0 @0x00  y0 @0x08  into r0 @0x10
<<<<<<<<<<<<<<<<                                               ; x0 moves into a
  [->>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>                                                       ; y0 moves into b
  [->>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>>>>>>>>>>                                    ; p := 1
                                                               ; ASSERT ptr=35
  +
> ++++++++                                                     ; cnt := 8
                                                               ; ASSERT ptr=36
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
                                                               ; ASSERT ptr=36
<<                                                             ; res is stored as r0
  [-<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>]
<<<<<<<<<<<<<<<<<<                                             ; back to r0
                                                               ; ASSERT ptr=16
                                                               ; ASSERT zero 24:37

; ============================================================ ; byte 1 : x1 @0x01  y1 @0x09  into r1 @0x11
<<<<<<<<<<<<<<<                                                ; x1 moves into a
  [->>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>                                                       ; y1 moves into b
  [->>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>>>>>>>>>                                     ; p := 1
                                                               ; ASSERT ptr=35
  +
> ++++++++                                                     ; cnt := 8
                                                               ; ASSERT ptr=36
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
                                                               ; ASSERT ptr=36
<<                                                             ; res is stored as r1
  [-<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>]
<<<<<<<<<<<<<<<<<<                                             ; back to r0
                                                               ; ASSERT ptr=16
                                                               ; ASSERT zero 24:37

; ============================================================ ; byte 2 : x2 @0x02  y2 @0x0a  into r2 @0x12
<<<<<<<<<<<<<<                                                 ; x2 moves into a
  [->>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>                                                       ; y2 moves into b
  [->>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>>>>>>>>                                      ; p := 1
                                                               ; ASSERT ptr=35
  +
> ++++++++                                                     ; cnt := 8
                                                               ; ASSERT ptr=36
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
                                                               ; ASSERT ptr=36
<<                                                             ; res is stored as r2
  [-<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>]
<<<<<<<<<<<<<<<<<<                                             ; back to r0
                                                               ; ASSERT ptr=16
                                                               ; ASSERT zero 24:37

; ============================================================ ; byte 3 : x3 @0x03  y3 @0x0b  into r3 @0x13
<<<<<<<<<<<<<                                                  ; x3 moves into a
  [->>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>                                                       ; y3 moves into b
  [->>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>>>>>>>                                       ; p := 1
                                                               ; ASSERT ptr=35
  +
> ++++++++                                                     ; cnt := 8
                                                               ; ASSERT ptr=36
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
                                                               ; ASSERT ptr=36
<<                                                             ; res is stored as r3
  [-<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>]
<<<<<<<<<<<<<<<<<<                                             ; back to r0
                                                               ; ASSERT ptr=16
                                                               ; ASSERT zero 24:37

; ============================================================ ; byte 4 : x4 @0x04  y4 @0x0c  into r4 @0x14
<<<<<<<<<<<<                                                   ; x4 moves into a
  [->>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>                                                       ; y4 moves into b
  [->>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>>>>>>                                        ; p := 1
                                                               ; ASSERT ptr=35
  +
> ++++++++                                                     ; cnt := 8
                                                               ; ASSERT ptr=36
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
                                                               ; ASSERT ptr=36
<<                                                             ; res is stored as r4
  [-<<<<<<<<<<<<<<+>>>>>>>>>>>>>>]
<<<<<<<<<<<<<<<<<<                                             ; back to r0
                                                               ; ASSERT ptr=16
                                                               ; ASSERT zero 24:37

; ============================================================ ; byte 5 : x5 @0x05  y5 @0x0d  into r5 @0x15
<<<<<<<<<<<                                                    ; x5 moves into a
  [->>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<]
>>>>>>>>                                                       ; y5 moves into b
  [->>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>>>>>                                         ; p := 1
                                                               ; ASSERT ptr=35
  +
> ++++++++                                                     ; cnt := 8
                                                               ; ASSERT ptr=36
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
                                                               ; ASSERT ptr=36
<<                                                             ; res is stored as r5
  [-<<<<<<<<<<<<<+>>>>>>>>>>>>>]
<<<<<<<<<<<<<<<<<<                                             ; back to r0
                                                               ; ASSERT ptr=16
                                                               ; ASSERT zero 24:37

; ============================================================ ; byte 6 : x6 @0x06  y6 @0x0e  into r6 @0x16
<<<<<<<<<<                                                     ; x6 moves into a
  [->>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<]
>>>>>>>>                                                       ; y6 moves into b
  [->>>>>>>>>>>>>>+<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>>>>                                          ; p := 1
                                                               ; ASSERT ptr=35
  +
> ++++++++                                                     ; cnt := 8
                                                               ; ASSERT ptr=36
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
                                                               ; ASSERT ptr=36
<<                                                             ; res is stored as r6
  [-<<<<<<<<<<<<+>>>>>>>>>>>>]
<<<<<<<<<<<<<<<<<<                                             ; back to r0
                                                               ; ASSERT ptr=16
                                                               ; ASSERT zero 24:37

; ============================================================ ; byte 7 : x7 @0x07  y7 @0x0f  into r7 @0x17
<<<<<<<<<                                                      ; x7 moves into a
  [->>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<]
>>>>>>>>                                                       ; y7 moves into b
  [->>>>>>>>>>>>>+<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>>>                                           ; p := 1
                                                               ; ASSERT ptr=35
  +
> ++++++++                                                     ; cnt := 8
                                                               ; ASSERT ptr=36
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
                                                               ; ASSERT ptr=36
<<                                                             ; res is stored as r7
  [-<<<<<<<<<<<+>>>>>>>>>>>]
<<<<<<<<<<<<<<<<<<                                             ; back to r0
                                                               ; ASSERT ptr=16
                                                               ; ASSERT zero 24:37

; emit
.>.>.>.>.>.>.>.                                                ; the result little endian
