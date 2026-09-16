; bfsodium AND64 : bitwise and of two 64 bit little endian words
;
; NOTE square brackets are brainfuck loops  so comments use braces for counts;
;
; THE 64 BIT WIDENING OF idiom/and32  which is itself chacha20/xor32 with a
; different combining step; The AND8 frame is unchanged down to the character
; and so is every arrow inside the bit step  because those arrows are all
; relative to the frame; Only the three journeys that leave the frame differ
; namely fetching x_i  fetching y_i  and storing res  and only the ASSERT
; numbers move  because those are absolute;
;
; INTERFACE entry=16 exit=16 footprint=0:37
; IO  in:  x{8} LE  followed by  y{8} LE      (16 bytes)
;     out: (x and y){8} LE                    (8 bytes)
;
; TAPE MAP  (home @0)
;   @0x00:0x07  x{8}   u8   first operand   LSB at @0x00
;   @0x08:0x0f  y{8}   u8   second operand
;   @0x10:0x17  r{8}   u8   result
;   @0x18       a      u8   AND8 frame: left byte  halved away to nought
;   @0x19       qa     u8   AND8 frame: a shifted right one
;   @0x1a       pa     u8   AND8 frame: low bit of a
;   @0x1b       fa     u8   AND8 frame scratch  restored nought
;   @0x1c       b      u8   AND8 frame: right byte  halved away to nought
;   @0x1d       qb     u8   AND8 frame: b shifted right one
;   @0x1e       pb     u8   AND8 frame: low bit of b
;   @0x1f       fb     u8   AND8 frame scratch  restored nought
;   @0x20       t      u8   AND8 frame: set when BOTH low bits are set
;   @0x21       ft     u8   AND8 frame scratch  restored nought
;   @0x22       res    u8   AND8 frame: accumulating result byte
;   @0x23       p      u8   AND8 frame: current bit weight  1 2 4 ; 128
;   @0x24       cnt    u8   AND8 frame: bits remaining  starts at eight
;   @0x25       tmp    u8   AND8 frame scratch  restored nought
;
; brainfuck has no bitwise instruction  so AND8 decomposes both bytes; HALVE is
; the workhorse  as it is for the exclusive or: for a cell at position k with q
; at k plus 1  t at k plus 2 and f at k plus 3  it leaves q equal to the value
; shifted right one and t equal to the low bit;
;
; Where XOR8 toggles a flag once per set low bit  AND8 raises it only when BOTH
; are set: the outer loop clears the first bit and enters only if it was set
; and the inner does the same for the second  so the flag goes up on one path
; out of four; A bit left standing alone is cleared afterwards  which is the
; case the nesting cannot reach;
;
; SHA_512 is what wants this at 64 bits  for exactly the reason SHA_256 wanted
; it at 32: Ch is  g xor (e and (f xor g))  and Maj is  (a and b) xor (a and c)
; xor (b and c)  so between this and xor64 there is no need for a NOT at all;

,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>                               ; read x{0:7} then y{0:7}  leaving the pointer on r0
                                                               ; @0x10
                                                               ; ASSERT ptr=16
                                                               ; ASSERT zero 16:37

; ============================================================ ; byte 0 : x0 @0x00  y0 @0x08  into r0 @0x10
<<<<<<<<<<<<<<<<                                               ; move x0 into a
                                                               ; ASSERT ptr=0
  [->>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>                                                       ; move y0 into b
  [->>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>>>>>>>>>>                                    ; the weight starts at one
                                                               ; ASSERT ptr=35
  +
>                                                              ; eight bits
  ++++++++
[                                                              ; ____ one bit step ____
  -
<<<<<<<<<<<<                                                   ; HALVE a  giving qa and pa
                                                               ; ASSERT ptr=24
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>>>                                                           ; HALVE b  giving qb and pb
                                                               ; ASSERT ptr=28
  [->>>+<[-<+>>-<]>[-<+>]<<<]
<<                                                             ; both low bits set is the and  and only that raises t
                                                               ; ASSERT ptr=26
  [[-]>>>>[[-]>>+<<]<<<<]
>>>>                                                           ; a bit left standing on its own is cleared  which the
                                                               ; nesting cannot reach
  [-]
>>                                                             ; if t then res gets the weight
                                                               ; ASSERT ptr=32
  [->>>[-<+>>>+<<]>>[-<<+>>]<<<<<]
<<<<<<<                                                        ; a becomes its own half
                                                               ; ASSERT ptr=25
  [-<+>]
>>>>                                                           ; and b likewise
  [-<+>]
>>>>>>                                                         ; the weight doubles for the next bit
                                                               ; ASSERT ptr=35
  [->>+<<]
>>
  [-<<++>>]
<                                                              ; back to the bit counter
                                                               ; ASSERT ptr=36
]
                                                               ; ASSERT ptr=36
                                                               ; res holds the byte just built  and the weight has
                                                               ; doubled past 128 to nought; everything else the bit
                                                               ; loop touched is back where it started;
                                                               ; ASSERT zero 24:33
                                                               ; ASSERT zero 35:35
<<                                                             ; store res into r0
                                                               ; ASSERT ptr=34
  [-<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>]
<<<<<<<<<<<<<<<<<<                                             ; back to the head of the result
                                                               ; ASSERT ptr=16

; ============================================================ ; byte 1 : x1 @0x01  y1 @0x09  into r1 @0x11
<<<<<<<<<<<<<<<                                                ; move x1 into a
                                                               ; ASSERT ptr=1
  [->>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>                                                       ; move y1 into b
  [->>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>>>>>>>>>                                     ; the weight starts at one
                                                               ; ASSERT ptr=35
  +
>                                                              ; eight bits
  ++++++++
[                                                              ; ____ one bit step ____
  -
<<<<<<<<<<<<                                                   ; HALVE a  giving qa and pa
                                                               ; ASSERT ptr=24
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>>>                                                           ; HALVE b  giving qb and pb
                                                               ; ASSERT ptr=28
  [->>>+<[-<+>>-<]>[-<+>]<<<]
<<                                                             ; both low bits set is the and  and only that raises t
                                                               ; ASSERT ptr=26
  [[-]>>>>[[-]>>+<<]<<<<]
>>>>                                                           ; a bit left standing on its own is cleared  which the
                                                               ; nesting cannot reach
  [-]
>>                                                             ; if t then res gets the weight
                                                               ; ASSERT ptr=32
  [->>>[-<+>>>+<<]>>[-<<+>>]<<<<<]
<<<<<<<                                                        ; a becomes its own half
                                                               ; ASSERT ptr=25
  [-<+>]
>>>>                                                           ; and b likewise
  [-<+>]
>>>>>>                                                         ; the weight doubles for the next bit
                                                               ; ASSERT ptr=35
  [->>+<<]
>>
  [-<<++>>]
<                                                              ; back to the bit counter
                                                               ; ASSERT ptr=36
]
                                                               ; ASSERT ptr=36
                                                               ; res holds the byte just built  and the weight has
                                                               ; doubled past 128 to nought; everything else the bit
                                                               ; loop touched is back where it started;
                                                               ; ASSERT zero 24:33
                                                               ; ASSERT zero 35:35
<<                                                             ; store res into r1
                                                               ; ASSERT ptr=34
  [-<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>]
<<<<<<<<<<<<<<<<<<                                             ; back to the head of the result
                                                               ; ASSERT ptr=16

; ============================================================ ; byte 2 : x2 @0x02  y2 @0x0a  into r2 @0x12
<<<<<<<<<<<<<<                                                 ; move x2 into a
                                                               ; ASSERT ptr=2
  [->>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>                                                       ; move y2 into b
  [->>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>>>>>>>>                                      ; the weight starts at one
                                                               ; ASSERT ptr=35
  +
>                                                              ; eight bits
  ++++++++
[                                                              ; ____ one bit step ____
  -
<<<<<<<<<<<<                                                   ; HALVE a  giving qa and pa
                                                               ; ASSERT ptr=24
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>>>                                                           ; HALVE b  giving qb and pb
                                                               ; ASSERT ptr=28
  [->>>+<[-<+>>-<]>[-<+>]<<<]
<<                                                             ; both low bits set is the and  and only that raises t
                                                               ; ASSERT ptr=26
  [[-]>>>>[[-]>>+<<]<<<<]
>>>>                                                           ; a bit left standing on its own is cleared  which the
                                                               ; nesting cannot reach
  [-]
>>                                                             ; if t then res gets the weight
                                                               ; ASSERT ptr=32
  [->>>[-<+>>>+<<]>>[-<<+>>]<<<<<]
<<<<<<<                                                        ; a becomes its own half
                                                               ; ASSERT ptr=25
  [-<+>]
>>>>                                                           ; and b likewise
  [-<+>]
>>>>>>                                                         ; the weight doubles for the next bit
                                                               ; ASSERT ptr=35
  [->>+<<]
>>
  [-<<++>>]
<                                                              ; back to the bit counter
                                                               ; ASSERT ptr=36
]
                                                               ; ASSERT ptr=36
                                                               ; res holds the byte just built  and the weight has
                                                               ; doubled past 128 to nought; everything else the bit
                                                               ; loop touched is back where it started;
                                                               ; ASSERT zero 24:33
                                                               ; ASSERT zero 35:35
<<                                                             ; store res into r2
                                                               ; ASSERT ptr=34
  [-<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>]
<<<<<<<<<<<<<<<<<<                                             ; back to the head of the result
                                                               ; ASSERT ptr=16

; ============================================================ ; byte 3 : x3 @0x03  y3 @0x0b  into r3 @0x13
<<<<<<<<<<<<<                                                  ; move x3 into a
                                                               ; ASSERT ptr=3
  [->>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>                                                       ; move y3 into b
  [->>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>>>>>>>                                       ; the weight starts at one
                                                               ; ASSERT ptr=35
  +
>                                                              ; eight bits
  ++++++++
[                                                              ; ____ one bit step ____
  -
<<<<<<<<<<<<                                                   ; HALVE a  giving qa and pa
                                                               ; ASSERT ptr=24
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>>>                                                           ; HALVE b  giving qb and pb
                                                               ; ASSERT ptr=28
  [->>>+<[-<+>>-<]>[-<+>]<<<]
<<                                                             ; both low bits set is the and  and only that raises t
                                                               ; ASSERT ptr=26
  [[-]>>>>[[-]>>+<<]<<<<]
>>>>                                                           ; a bit left standing on its own is cleared  which the
                                                               ; nesting cannot reach
  [-]
>>                                                             ; if t then res gets the weight
                                                               ; ASSERT ptr=32
  [->>>[-<+>>>+<<]>>[-<<+>>]<<<<<]
<<<<<<<                                                        ; a becomes its own half
                                                               ; ASSERT ptr=25
  [-<+>]
>>>>                                                           ; and b likewise
  [-<+>]
>>>>>>                                                         ; the weight doubles for the next bit
                                                               ; ASSERT ptr=35
  [->>+<<]
>>
  [-<<++>>]
<                                                              ; back to the bit counter
                                                               ; ASSERT ptr=36
]
                                                               ; ASSERT ptr=36
                                                               ; res holds the byte just built  and the weight has
                                                               ; doubled past 128 to nought; everything else the bit
                                                               ; loop touched is back where it started;
                                                               ; ASSERT zero 24:33
                                                               ; ASSERT zero 35:35
<<                                                             ; store res into r3
                                                               ; ASSERT ptr=34
  [-<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>]
<<<<<<<<<<<<<<<<<<                                             ; back to the head of the result
                                                               ; ASSERT ptr=16

; ============================================================ ; byte 4 : x4 @0x04  y4 @0x0c  into r4 @0x14
<<<<<<<<<<<<                                                   ; move x4 into a
                                                               ; ASSERT ptr=4
  [->>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>                                                       ; move y4 into b
  [->>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>>>>>>                                        ; the weight starts at one
                                                               ; ASSERT ptr=35
  +
>                                                              ; eight bits
  ++++++++
[                                                              ; ____ one bit step ____
  -
<<<<<<<<<<<<                                                   ; HALVE a  giving qa and pa
                                                               ; ASSERT ptr=24
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>>>                                                           ; HALVE b  giving qb and pb
                                                               ; ASSERT ptr=28
  [->>>+<[-<+>>-<]>[-<+>]<<<]
<<                                                             ; both low bits set is the and  and only that raises t
                                                               ; ASSERT ptr=26
  [[-]>>>>[[-]>>+<<]<<<<]
>>>>                                                           ; a bit left standing on its own is cleared  which the
                                                               ; nesting cannot reach
  [-]
>>                                                             ; if t then res gets the weight
                                                               ; ASSERT ptr=32
  [->>>[-<+>>>+<<]>>[-<<+>>]<<<<<]
<<<<<<<                                                        ; a becomes its own half
                                                               ; ASSERT ptr=25
  [-<+>]
>>>>                                                           ; and b likewise
  [-<+>]
>>>>>>                                                         ; the weight doubles for the next bit
                                                               ; ASSERT ptr=35
  [->>+<<]
>>
  [-<<++>>]
<                                                              ; back to the bit counter
                                                               ; ASSERT ptr=36
]
                                                               ; ASSERT ptr=36
                                                               ; res holds the byte just built  and the weight has
                                                               ; doubled past 128 to nought; everything else the bit
                                                               ; loop touched is back where it started;
                                                               ; ASSERT zero 24:33
                                                               ; ASSERT zero 35:35
<<                                                             ; store res into r4
                                                               ; ASSERT ptr=34
  [-<<<<<<<<<<<<<<+>>>>>>>>>>>>>>]
<<<<<<<<<<<<<<<<<<                                             ; back to the head of the result
                                                               ; ASSERT ptr=16

; ============================================================ ; byte 5 : x5 @0x05  y5 @0x0d  into r5 @0x15
<<<<<<<<<<<                                                    ; move x5 into a
                                                               ; ASSERT ptr=5
  [->>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<]
>>>>>>>>                                                       ; move y5 into b
  [->>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>>>>>                                         ; the weight starts at one
                                                               ; ASSERT ptr=35
  +
>                                                              ; eight bits
  ++++++++
[                                                              ; ____ one bit step ____
  -
<<<<<<<<<<<<                                                   ; HALVE a  giving qa and pa
                                                               ; ASSERT ptr=24
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>>>                                                           ; HALVE b  giving qb and pb
                                                               ; ASSERT ptr=28
  [->>>+<[-<+>>-<]>[-<+>]<<<]
<<                                                             ; both low bits set is the and  and only that raises t
                                                               ; ASSERT ptr=26
  [[-]>>>>[[-]>>+<<]<<<<]
>>>>                                                           ; a bit left standing on its own is cleared  which the
                                                               ; nesting cannot reach
  [-]
>>                                                             ; if t then res gets the weight
                                                               ; ASSERT ptr=32
  [->>>[-<+>>>+<<]>>[-<<+>>]<<<<<]
<<<<<<<                                                        ; a becomes its own half
                                                               ; ASSERT ptr=25
  [-<+>]
>>>>                                                           ; and b likewise
  [-<+>]
>>>>>>                                                         ; the weight doubles for the next bit
                                                               ; ASSERT ptr=35
  [->>+<<]
>>
  [-<<++>>]
<                                                              ; back to the bit counter
                                                               ; ASSERT ptr=36
]
                                                               ; ASSERT ptr=36
                                                               ; res holds the byte just built  and the weight has
                                                               ; doubled past 128 to nought; everything else the bit
                                                               ; loop touched is back where it started;
                                                               ; ASSERT zero 24:33
                                                               ; ASSERT zero 35:35
<<                                                             ; store res into r5
                                                               ; ASSERT ptr=34
  [-<<<<<<<<<<<<<+>>>>>>>>>>>>>]
<<<<<<<<<<<<<<<<<<                                             ; back to the head of the result
                                                               ; ASSERT ptr=16

; ============================================================ ; byte 6 : x6 @0x06  y6 @0x0e  into r6 @0x16
<<<<<<<<<<                                                     ; move x6 into a
                                                               ; ASSERT ptr=6
  [->>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<]
>>>>>>>>                                                       ; move y6 into b
  [->>>>>>>>>>>>>>+<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>>>>                                          ; the weight starts at one
                                                               ; ASSERT ptr=35
  +
>                                                              ; eight bits
  ++++++++
[                                                              ; ____ one bit step ____
  -
<<<<<<<<<<<<                                                   ; HALVE a  giving qa and pa
                                                               ; ASSERT ptr=24
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>>>                                                           ; HALVE b  giving qb and pb
                                                               ; ASSERT ptr=28
  [->>>+<[-<+>>-<]>[-<+>]<<<]
<<                                                             ; both low bits set is the and  and only that raises t
                                                               ; ASSERT ptr=26
  [[-]>>>>[[-]>>+<<]<<<<]
>>>>                                                           ; a bit left standing on its own is cleared  which the
                                                               ; nesting cannot reach
  [-]
>>                                                             ; if t then res gets the weight
                                                               ; ASSERT ptr=32
  [->>>[-<+>>>+<<]>>[-<<+>>]<<<<<]
<<<<<<<                                                        ; a becomes its own half
                                                               ; ASSERT ptr=25
  [-<+>]
>>>>                                                           ; and b likewise
  [-<+>]
>>>>>>                                                         ; the weight doubles for the next bit
                                                               ; ASSERT ptr=35
  [->>+<<]
>>
  [-<<++>>]
<                                                              ; back to the bit counter
                                                               ; ASSERT ptr=36
]
                                                               ; ASSERT ptr=36
                                                               ; res holds the byte just built  and the weight has
                                                               ; doubled past 128 to nought; everything else the bit
                                                               ; loop touched is back where it started;
                                                               ; ASSERT zero 24:33
                                                               ; ASSERT zero 35:35
<<                                                             ; store res into r6
                                                               ; ASSERT ptr=34
  [-<<<<<<<<<<<<+>>>>>>>>>>>>]
<<<<<<<<<<<<<<<<<<                                             ; back to the head of the result
                                                               ; ASSERT ptr=16

; ============================================================ ; byte 7 : x7 @0x07  y7 @0x0f  into r7 @0x17
<<<<<<<<<                                                      ; move x7 into a
                                                               ; ASSERT ptr=7
  [->>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<]
>>>>>>>>                                                       ; move y7 into b
  [->>>>>>>>>>>>>+<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>>>                                           ; the weight starts at one
                                                               ; ASSERT ptr=35
  +
>                                                              ; eight bits
  ++++++++
[                                                              ; ____ one bit step ____
  -
<<<<<<<<<<<<                                                   ; HALVE a  giving qa and pa
                                                               ; ASSERT ptr=24
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>>>                                                           ; HALVE b  giving qb and pb
                                                               ; ASSERT ptr=28
  [->>>+<[-<+>>-<]>[-<+>]<<<]
<<                                                             ; both low bits set is the and  and only that raises t
                                                               ; ASSERT ptr=26
  [[-]>>>>[[-]>>+<<]<<<<]
>>>>                                                           ; a bit left standing on its own is cleared  which the
                                                               ; nesting cannot reach
  [-]
>>                                                             ; if t then res gets the weight
                                                               ; ASSERT ptr=32
  [->>>[-<+>>>+<<]>>[-<<+>>]<<<<<]
<<<<<<<                                                        ; a becomes its own half
                                                               ; ASSERT ptr=25
  [-<+>]
>>>>                                                           ; and b likewise
  [-<+>]
>>>>>>                                                         ; the weight doubles for the next bit
                                                               ; ASSERT ptr=35
  [->>+<<]
>>
  [-<<++>>]
<                                                              ; back to the bit counter
                                                               ; ASSERT ptr=36
]
                                                               ; ASSERT ptr=36
                                                               ; res holds the byte just built  and the weight has
                                                               ; doubled past 128 to nought; everything else the bit
                                                               ; loop touched is back where it started;
                                                               ; ASSERT zero 24:33
                                                               ; ASSERT zero 35:35
<<                                                             ; store res into r7
                                                               ; ASSERT ptr=34
  [-<<<<<<<<<<<+>>>>>>>>>>>]
<<<<<<<<<<<<<<<<<<                                             ; back to the head of the result
                                                               ; ASSERT ptr=16

; emit
.>.>.>.>.>.>.>.                                                ; the result little endian
