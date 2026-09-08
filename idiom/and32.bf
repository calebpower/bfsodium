; bfsodium AND32 : bitwise and of two 32 bit little endian words
;
; NOTE square brackets are brainfuck loops  so comments use braces for counts;
;
; HAND WRITTEN; The same shape as chacha20/xor32  which decomposes both bytes a
; bit at a time; only the step that combines the two bits differs  and that is
; the whole of the difference between and  or  and exclusive or;
;
; INTERFACE entry=8 exit=8 footprint=0:25
; IO  in:  x{4} LE  followed by  y{4} LE       (8 bytes)
;     out: (x and y){4} LE                     (4 bytes)
;
; TAPE MAP  (home @0)
;   @0x00:0x03  x{4}   u8   first operand   LSB at @0x00
;   @0x04:0x07  y{4}   u8   second operand
;   @0x08:0x0b  r{4}   u8   result
;   @0x0c       a      u8   AND8 frame: left byte  halved away to nought
;   @0x0d       qa     u8   AND8 frame: a shifted right one
;   @0x0e       pa     u8   AND8 frame: low bit of a
;   @0x0f       fa     u8   AND8 frame scratch  restored nought
;   @0x10       b      u8   AND8 frame: right byte  halved away to nought
;   @0x11       qb     u8   AND8 frame: b shifted right one
;   @0x12       pb     u8   AND8 frame: low bit of b
;   @0x13       fb     u8   AND8 frame scratch  restored nought
;   @0x14       t      u8   AND8 frame: set when BOTH low bits are set
;   @0x15       ft     u8   AND8 frame scratch  restored nought
;   @0x16       res    u8   AND8 frame: accumulating result byte
;   @0x17       p      u8   AND8 frame: current bit weight  1 2 4 ; 128
;   @0x18       cnt    u8   AND8 frame: bits remaining  starts at eight
;   @0x19       tmp    u8   AND8 frame scratch  restored nought
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
; SHA_256 is what wants this: Ch is  g xor (e and (f xor g))  and Maj is
; (a and b) xor (a and c) xor (b and c)  so between this and xor32 there is no
; need for a NOT at all;

,>,>,>,>,>,>,>,>                                               ; read x{0:3} then y{0:3}  leaving the pointer on r0
                                                               ; @0x08
; ASSERT ptr=8
; ASSERT zero 8:25

; ==== byte 0 : x0 @0x00  y0 @0x04  into r0 @0x08 ====
<<<<<<<<                                                       ; move x0 into a
; ASSERT ptr=0
  [->>>>>>>>>>>>+<<<<<<<<<<<<]
>>>>                                                           ; move y0 into b
  [->>>>>>>>>>>>+<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>>                                            ; the weight starts at one
; ASSERT ptr=23
  +
>                                                              ; eight bits
  ++++++++
[                                                              ; ____ one bit step ____
  -
<<<<<<<<<<<<                                                   ; HALVE a  giving qa and pa
; ASSERT ptr=12
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>>>                                                           ; HALVE b  giving qb and pb
; ASSERT ptr=16
  [->>>+<[-<+>>-<]>[-<+>]<<<]
<<                                                             ; both low bits set is the and  and only that raises t
; ASSERT ptr=14
  [[-]>>>>[[-]>>+<<]<<<<]
>>>>                                                           ; a bit left standing on its own is cleared  which the
                                                               ; nesting cannot reach
  [-]
>>                                                             ; if t then res gets the weight
; ASSERT ptr=20
  [->>>[-<+>>>+<<]>>[-<<+>>]<<<<<]
<<<<<<<                                                        ; a becomes its own half
; ASSERT ptr=13
  [-<+>]
>>>>                                                           ; and b likewise
  [-<+>]
>>>>>>                                                         ; the weight doubles for the next bit
; ASSERT ptr=23
  [->>+<<]
>>
  [-<<++>>]
<                                                              ; back to the bit counter
; ASSERT ptr=24
]
; ASSERT ptr=24
; res holds the byte just built  and the weight has doubled past 128 to nought;
; everything else the bit loop touched is back where it started;
; ASSERT zero 12:21
; ASSERT zero 23:23
<<                                                             ; store res into r0
; ASSERT ptr=22
  [-<<<<<<<<<<<<<<+>>>>>>>>>>>>>>]
<<<<<<<<<<<<<<                                                 ; back to the head of the result
; ASSERT ptr=8

; ==== byte 1 : x1 @0x01  y1 @0x05  into r1 @0x09 ====
<<<<<<<                                                        ; move x1 into a
; ASSERT ptr=1
  [->>>>>>>>>>>+<<<<<<<<<<<]
>>>>                                                           ; move y1 into b
  [->>>>>>>>>>>+<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>                                             ; the weight starts at one
; ASSERT ptr=23
  +
>                                                              ; eight bits
  ++++++++
[                                                              ; ____ one bit step ____
  -
<<<<<<<<<<<<                                                   ; HALVE a  giving qa and pa
; ASSERT ptr=12
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>>>                                                           ; HALVE b  giving qb and pb
; ASSERT ptr=16
  [->>>+<[-<+>>-<]>[-<+>]<<<]
<<                                                             ; both low bits set is the and  and only that raises t
; ASSERT ptr=14
  [[-]>>>>[[-]>>+<<]<<<<]
>>>>                                                           ; a bit left standing on its own is cleared  which the
                                                               ; nesting cannot reach
  [-]
>>                                                             ; if t then res gets the weight
; ASSERT ptr=20
  [->>>[-<+>>>+<<]>>[-<<+>>]<<<<<]
<<<<<<<                                                        ; a becomes its own half
; ASSERT ptr=13
  [-<+>]
>>>>                                                           ; and b likewise
  [-<+>]
>>>>>>                                                         ; the weight doubles for the next bit
; ASSERT ptr=23
  [->>+<<]
>>
  [-<<++>>]
<                                                              ; back to the bit counter
; ASSERT ptr=24
]
; ASSERT ptr=24
; res holds the byte just built  and the weight has doubled past 128 to nought;
; everything else the bit loop touched is back where it started;
; ASSERT zero 12:21
; ASSERT zero 23:23
<<                                                             ; store res into r1
; ASSERT ptr=22
  [-<<<<<<<<<<<<<+>>>>>>>>>>>>>]
<<<<<<<<<<<<<<                                                 ; back to the head of the result
; ASSERT ptr=8

; ==== byte 2 : x2 @0x02  y2 @0x06  into r2 @0x0a ====
<<<<<<                                                         ; move x2 into a
; ASSERT ptr=2
  [->>>>>>>>>>+<<<<<<<<<<]
>>>>                                                           ; move y2 into b
  [->>>>>>>>>>+<<<<<<<<<<]
>>>>>>>>>>>>>>>>>                                              ; the weight starts at one
; ASSERT ptr=23
  +
>                                                              ; eight bits
  ++++++++
[                                                              ; ____ one bit step ____
  -
<<<<<<<<<<<<                                                   ; HALVE a  giving qa and pa
; ASSERT ptr=12
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>>>                                                           ; HALVE b  giving qb and pb
; ASSERT ptr=16
  [->>>+<[-<+>>-<]>[-<+>]<<<]
<<                                                             ; both low bits set is the and  and only that raises t
; ASSERT ptr=14
  [[-]>>>>[[-]>>+<<]<<<<]
>>>>                                                           ; a bit left standing on its own is cleared  which the
                                                               ; nesting cannot reach
  [-]
>>                                                             ; if t then res gets the weight
; ASSERT ptr=20
  [->>>[-<+>>>+<<]>>[-<<+>>]<<<<<]
<<<<<<<                                                        ; a becomes its own half
; ASSERT ptr=13
  [-<+>]
>>>>                                                           ; and b likewise
  [-<+>]
>>>>>>                                                         ; the weight doubles for the next bit
; ASSERT ptr=23
  [->>+<<]
>>
  [-<<++>>]
<                                                              ; back to the bit counter
; ASSERT ptr=24
]
; ASSERT ptr=24
; res holds the byte just built  and the weight has doubled past 128 to nought;
; everything else the bit loop touched is back where it started;
; ASSERT zero 12:21
; ASSERT zero 23:23
<<                                                             ; store res into r2
; ASSERT ptr=22
  [-<<<<<<<<<<<<+>>>>>>>>>>>>]
<<<<<<<<<<<<<<                                                 ; back to the head of the result
; ASSERT ptr=8

; ==== byte 3 : x3 @0x03  y3 @0x07  into r3 @0x0b ====
<<<<<                                                          ; move x3 into a
; ASSERT ptr=3
  [->>>>>>>>>+<<<<<<<<<]
>>>>                                                           ; move y3 into b
  [->>>>>>>>>+<<<<<<<<<]
>>>>>>>>>>>>>>>>                                               ; the weight starts at one
; ASSERT ptr=23
  +
>                                                              ; eight bits
  ++++++++
[                                                              ; ____ one bit step ____
  -
<<<<<<<<<<<<                                                   ; HALVE a  giving qa and pa
; ASSERT ptr=12
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>>>                                                           ; HALVE b  giving qb and pb
; ASSERT ptr=16
  [->>>+<[-<+>>-<]>[-<+>]<<<]
<<                                                             ; both low bits set is the and  and only that raises t
; ASSERT ptr=14
  [[-]>>>>[[-]>>+<<]<<<<]
>>>>                                                           ; a bit left standing on its own is cleared  which the
                                                               ; nesting cannot reach
  [-]
>>                                                             ; if t then res gets the weight
; ASSERT ptr=20
  [->>>[-<+>>>+<<]>>[-<<+>>]<<<<<]
<<<<<<<                                                        ; a becomes its own half
; ASSERT ptr=13
  [-<+>]
>>>>                                                           ; and b likewise
  [-<+>]
>>>>>>                                                         ; the weight doubles for the next bit
; ASSERT ptr=23
  [->>+<<]
>>
  [-<<++>>]
<                                                              ; back to the bit counter
; ASSERT ptr=24
]
; ASSERT ptr=24
; res holds the byte just built  and the weight has doubled past 128 to nought;
; everything else the bit loop touched is back where it started;
; ASSERT zero 12:21
; ASSERT zero 23:23
<<                                                             ; store res into r3
; ASSERT ptr=22
  [-<<<<<<<<<<<+>>>>>>>>>>>]
<<<<<<<<<<<<<<                                                 ; back to the head of the result
; ASSERT ptr=8

; ASSERT zero 0:7
; ASSERT zero 12:25

; emit
  .>.>.>.                                                      ; the and  four bytes little endian
