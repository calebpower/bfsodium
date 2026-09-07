; bfsodium DBL136 : 17 byte little endian shift left one
;
; HAND WRITTEN; the mirror of halve136  walked from the BOTTOM up  because the
; bit that leaves a byte at the top is the bit that arrives at the bottom of the
; byte above;
;
; This exists so that mulmod136 can double its running value without calling the
; adder; add136 costs work proportional to the PRODUCT of the two byte values it
; is adding  which on full bytes is about twelve million instructions  while this
; is about a hundred and fifty thousand; Doubling is a shift  so it should cost
; what a shift costs;
;
; INTERFACE entry=16 exit=0 footprint=0:24
; IO  in:  x{17} LE                     (17 bytes)
;     out: (x shifted left one){17} LE  (17 bytes)
;
; TAPE MAP  (home @0)
;   @0x00:0x10  x{17}  u8   the value  and the result  LSB at @0x00
;   @0x11       v      u8   the byte being reduced to its top bit
;   @0x12       q      u8   HALVE frame: v shifted right one
;   @0x13       bit    u8   HALVE frame: v low bit  discarded here
;   @0x14       f      u8   HALVE frame scratch  restored to nought
;   @0x15       out    u8   the byte doubled  which wraps modulo 256 by itself
;   @0x16       cin    u8   the bit coming up from the byte below
;   @0x17       d      u8   a second copy of the byte  consumed by the doubling
;   @0x18       n      u8   seven turns of the halving
;
; The top bit is found by halving SEVEN times rather than by detecting the wrap
; of the doubling; a wrap test needs the value copied out and compared on every
; step  and seven halvings of a byte costs about two times the byte  which is
; cheaper and reuses an idiom that is already proved;
;
; The doubled byte needs no wrap test at all: a cell wraps modulo 256 on its own
; and that is exactly the low byte wanted;

  ,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,                            ; read the value little endian
; ASSERT ptr=16
; ASSERT zero 17:24
<<<<<<<<<<<<<<<<                                               ; to the bottom of the value  which is where a shift
                                                               ; left starts

; ==== byte 0 ====
; ASSERT ptr=0
  [->>>>>>>>>>>>>>>>>+>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<]          ; the byte is taken twice: once to be doubled and once
                                                               ; to give up its top bit
>>>>>>>>>>>>>>>>>>>>>>>                                        ; to the copy that will be doubled
; ASSERT ptr=23
  [-<<++>>]                                                    ; doubling wraps modulo 256 by itself  and that wrap IS
                                                               ; the low byte wanted
>                                                              ; seven turns of halving leave nothing but the top bit
  +++++++
[
  -
<<<<<<<                                                        ; to the value
; ASSERT ptr=17
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>                                                             ; the bit that falls off is not wanted here
  [-]
<                                                              ; the half becomes the value for the next turn
  [-<+>]
>>>>>>                                                         ; back to the turn counter
]
; ASSERT ptr=24
<<<                                                            ; the doubled byte goes back where it came from
; ASSERT ptr=21
  [-<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>]
; byte nought receives no carry: nothing is below it  and the frame is clear
; on entry  so this step could never have run
<<<<
; this byte top bit is what goes up to the byte above
; ASSERT ptr=17
  [->>>>>+<<<<<]
<<<<<<<<<<<<<<<<                                               ; to the byte above

; ==== byte 1 ====
; ASSERT ptr=1
  [->>>>>>>>>>>>>>>>+>>>>>>+<<<<<<<<<<<<<<<<<<<<<<]            ; the byte is taken twice: once to be doubled and once
                                                               ; to give up its top bit
>>>>>>>>>>>>>>>>>>>>>>                                         ; to the copy that will be doubled
; ASSERT ptr=23
  [-<<++>>]                                                    ; doubling wraps modulo 256 by itself  and that wrap IS
                                                               ; the low byte wanted
>                                                              ; seven turns of halving leave nothing but the top bit
  +++++++
[
  -
<<<<<<<                                                        ; to the value
; ASSERT ptr=17
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>                                                             ; the bit that falls off is not wanted here
  [-]
<                                                              ; the half becomes the value for the next turn
  [-<+>]
>>>>>>                                                         ; back to the turn counter
]
; ASSERT ptr=24
<<<                                                            ; the doubled byte goes back where it came from
; ASSERT ptr=21
  [-<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>]
>                                                              ; and the bit that came up from the byte below is added
                                                               ; to it
  [-<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>]
<<<<<                                                          ; this byte top bit is what goes up to the byte above
; ASSERT ptr=17
  [->>>>>+<<<<<]
<<<<<<<<<<<<<<<                                                ; to the byte above

; ==== byte 2 ====
; ASSERT ptr=2
  [->>>>>>>>>>>>>>>+>>>>>>+<<<<<<<<<<<<<<<<<<<<<]              ; the byte is taken twice: once to be doubled and once
                                                               ; to give up its top bit
>>>>>>>>>>>>>>>>>>>>>                                          ; to the copy that will be doubled
; ASSERT ptr=23
  [-<<++>>]                                                    ; doubling wraps modulo 256 by itself  and that wrap IS
                                                               ; the low byte wanted
>                                                              ; seven turns of halving leave nothing but the top bit
  +++++++
[
  -
<<<<<<<                                                        ; to the value
; ASSERT ptr=17
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>                                                             ; the bit that falls off is not wanted here
  [-]
<                                                              ; the half becomes the value for the next turn
  [-<+>]
>>>>>>                                                         ; back to the turn counter
]
; ASSERT ptr=24
<<<                                                            ; the doubled byte goes back where it came from
; ASSERT ptr=21
  [-<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>]
>                                                              ; and the bit that came up from the byte below is added
                                                               ; to it
  [-<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>]
<<<<<                                                          ; this byte top bit is what goes up to the byte above
; ASSERT ptr=17
  [->>>>>+<<<<<]
<<<<<<<<<<<<<<                                                 ; to the byte above

; ==== byte 3 ====
; ASSERT ptr=3
  [->>>>>>>>>>>>>>+>>>>>>+<<<<<<<<<<<<<<<<<<<<]                ; the byte is taken twice: once to be doubled and once
                                                               ; to give up its top bit
>>>>>>>>>>>>>>>>>>>>                                           ; to the copy that will be doubled
; ASSERT ptr=23
  [-<<++>>]                                                    ; doubling wraps modulo 256 by itself  and that wrap IS
                                                               ; the low byte wanted
>                                                              ; seven turns of halving leave nothing but the top bit
  +++++++
[
  -
<<<<<<<                                                        ; to the value
; ASSERT ptr=17
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>                                                             ; the bit that falls off is not wanted here
  [-]
<                                                              ; the half becomes the value for the next turn
  [-<+>]
>>>>>>                                                         ; back to the turn counter
]
; ASSERT ptr=24
<<<                                                            ; the doubled byte goes back where it came from
; ASSERT ptr=21
  [-<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>]
>                                                              ; and the bit that came up from the byte below is added
                                                               ; to it
  [-<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>]
<<<<<                                                          ; this byte top bit is what goes up to the byte above
; ASSERT ptr=17
  [->>>>>+<<<<<]
<<<<<<<<<<<<<                                                  ; to the byte above

; ==== byte 4 ====
; ASSERT ptr=4
  [->>>>>>>>>>>>>+>>>>>>+<<<<<<<<<<<<<<<<<<<]                  ; the byte is taken twice: once to be doubled and once
                                                               ; to give up its top bit
>>>>>>>>>>>>>>>>>>>                                            ; to the copy that will be doubled
; ASSERT ptr=23
  [-<<++>>]                                                    ; doubling wraps modulo 256 by itself  and that wrap IS
                                                               ; the low byte wanted
>                                                              ; seven turns of halving leave nothing but the top bit
  +++++++
[
  -
<<<<<<<                                                        ; to the value
; ASSERT ptr=17
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>                                                             ; the bit that falls off is not wanted here
  [-]
<                                                              ; the half becomes the value for the next turn
  [-<+>]
>>>>>>                                                         ; back to the turn counter
]
; ASSERT ptr=24
<<<                                                            ; the doubled byte goes back where it came from
; ASSERT ptr=21
  [-<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>]
>                                                              ; and the bit that came up from the byte below is added
                                                               ; to it
  [-<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>]
<<<<<                                                          ; this byte top bit is what goes up to the byte above
; ASSERT ptr=17
  [->>>>>+<<<<<]
<<<<<<<<<<<<                                                   ; to the byte above

; ==== byte 5 ====
; ASSERT ptr=5
  [->>>>>>>>>>>>+>>>>>>+<<<<<<<<<<<<<<<<<<]                    ; the byte is taken twice: once to be doubled and once
                                                               ; to give up its top bit
>>>>>>>>>>>>>>>>>>                                             ; to the copy that will be doubled
; ASSERT ptr=23
  [-<<++>>]                                                    ; doubling wraps modulo 256 by itself  and that wrap IS
                                                               ; the low byte wanted
>                                                              ; seven turns of halving leave nothing but the top bit
  +++++++
[
  -
<<<<<<<                                                        ; to the value
; ASSERT ptr=17
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>                                                             ; the bit that falls off is not wanted here
  [-]
<                                                              ; the half becomes the value for the next turn
  [-<+>]
>>>>>>                                                         ; back to the turn counter
]
; ASSERT ptr=24
<<<                                                            ; the doubled byte goes back where it came from
; ASSERT ptr=21
  [-<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>]
>                                                              ; and the bit that came up from the byte below is added
                                                               ; to it
  [-<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>]
<<<<<                                                          ; this byte top bit is what goes up to the byte above
; ASSERT ptr=17
  [->>>>>+<<<<<]
<<<<<<<<<<<                                                    ; to the byte above

; ==== byte 6 ====
; ASSERT ptr=6
  [->>>>>>>>>>>+>>>>>>+<<<<<<<<<<<<<<<<<]                      ; the byte is taken twice: once to be doubled and once
                                                               ; to give up its top bit
>>>>>>>>>>>>>>>>>                                              ; to the copy that will be doubled
; ASSERT ptr=23
  [-<<++>>]                                                    ; doubling wraps modulo 256 by itself  and that wrap IS
                                                               ; the low byte wanted
>                                                              ; seven turns of halving leave nothing but the top bit
  +++++++
[
  -
<<<<<<<                                                        ; to the value
; ASSERT ptr=17
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>                                                             ; the bit that falls off is not wanted here
  [-]
<                                                              ; the half becomes the value for the next turn
  [-<+>]
>>>>>>                                                         ; back to the turn counter
]
; ASSERT ptr=24
<<<                                                            ; the doubled byte goes back where it came from
; ASSERT ptr=21
  [-<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>]
>                                                              ; and the bit that came up from the byte below is added
                                                               ; to it
  [-<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>]
<<<<<                                                          ; this byte top bit is what goes up to the byte above
; ASSERT ptr=17
  [->>>>>+<<<<<]
<<<<<<<<<<                                                     ; to the byte above

; ==== byte 7 ====
; ASSERT ptr=7
  [->>>>>>>>>>+>>>>>>+<<<<<<<<<<<<<<<<]                        ; the byte is taken twice: once to be doubled and once
                                                               ; to give up its top bit
>>>>>>>>>>>>>>>>                                               ; to the copy that will be doubled
; ASSERT ptr=23
  [-<<++>>]                                                    ; doubling wraps modulo 256 by itself  and that wrap IS
                                                               ; the low byte wanted
>                                                              ; seven turns of halving leave nothing but the top bit
  +++++++
[
  -
<<<<<<<                                                        ; to the value
; ASSERT ptr=17
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>                                                             ; the bit that falls off is not wanted here
  [-]
<                                                              ; the half becomes the value for the next turn
  [-<+>]
>>>>>>                                                         ; back to the turn counter
]
; ASSERT ptr=24
<<<                                                            ; the doubled byte goes back where it came from
; ASSERT ptr=21
  [-<<<<<<<<<<<<<<+>>>>>>>>>>>>>>]
>                                                              ; and the bit that came up from the byte below is added
                                                               ; to it
  [-<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>]
<<<<<                                                          ; this byte top bit is what goes up to the byte above
; ASSERT ptr=17
  [->>>>>+<<<<<]
<<<<<<<<<                                                      ; to the byte above

; ==== byte 8 ====
; ASSERT ptr=8
  [->>>>>>>>>+>>>>>>+<<<<<<<<<<<<<<<]                          ; the byte is taken twice: once to be doubled and once
                                                               ; to give up its top bit
>>>>>>>>>>>>>>>                                                ; to the copy that will be doubled
; ASSERT ptr=23
  [-<<++>>]                                                    ; doubling wraps modulo 256 by itself  and that wrap IS
                                                               ; the low byte wanted
>                                                              ; seven turns of halving leave nothing but the top bit
  +++++++
[
  -
<<<<<<<                                                        ; to the value
; ASSERT ptr=17
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>                                                             ; the bit that falls off is not wanted here
  [-]
<                                                              ; the half becomes the value for the next turn
  [-<+>]
>>>>>>                                                         ; back to the turn counter
]
; ASSERT ptr=24
<<<                                                            ; the doubled byte goes back where it came from
; ASSERT ptr=21
  [-<<<<<<<<<<<<<+>>>>>>>>>>>>>]
>                                                              ; and the bit that came up from the byte below is added
                                                               ; to it
  [-<<<<<<<<<<<<<<+>>>>>>>>>>>>>>]
<<<<<                                                          ; this byte top bit is what goes up to the byte above
; ASSERT ptr=17
  [->>>>>+<<<<<]
<<<<<<<<                                                       ; to the byte above

; ==== byte 9 ====
; ASSERT ptr=9
  [->>>>>>>>+>>>>>>+<<<<<<<<<<<<<<]                            ; the byte is taken twice: once to be doubled and once
                                                               ; to give up its top bit
>>>>>>>>>>>>>>                                                 ; to the copy that will be doubled
; ASSERT ptr=23
  [-<<++>>]                                                    ; doubling wraps modulo 256 by itself  and that wrap IS
                                                               ; the low byte wanted
>                                                              ; seven turns of halving leave nothing but the top bit
  +++++++
[
  -
<<<<<<<                                                        ; to the value
; ASSERT ptr=17
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>                                                             ; the bit that falls off is not wanted here
  [-]
<                                                              ; the half becomes the value for the next turn
  [-<+>]
>>>>>>                                                         ; back to the turn counter
]
; ASSERT ptr=24
<<<                                                            ; the doubled byte goes back where it came from
; ASSERT ptr=21
  [-<<<<<<<<<<<<+>>>>>>>>>>>>]
>                                                              ; and the bit that came up from the byte below is added
                                                               ; to it
  [-<<<<<<<<<<<<<+>>>>>>>>>>>>>]
<<<<<                                                          ; this byte top bit is what goes up to the byte above
; ASSERT ptr=17
  [->>>>>+<<<<<]
<<<<<<<                                                        ; to the byte above

; ==== byte 10 ====
; ASSERT ptr=10
  [->>>>>>>+>>>>>>+<<<<<<<<<<<<<]                              ; the byte is taken twice: once to be doubled and once
                                                               ; to give up its top bit
>>>>>>>>>>>>>                                                  ; to the copy that will be doubled
; ASSERT ptr=23
  [-<<++>>]                                                    ; doubling wraps modulo 256 by itself  and that wrap IS
                                                               ; the low byte wanted
>                                                              ; seven turns of halving leave nothing but the top bit
  +++++++
[
  -
<<<<<<<                                                        ; to the value
; ASSERT ptr=17
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>                                                             ; the bit that falls off is not wanted here
  [-]
<                                                              ; the half becomes the value for the next turn
  [-<+>]
>>>>>>                                                         ; back to the turn counter
]
; ASSERT ptr=24
<<<                                                            ; the doubled byte goes back where it came from
; ASSERT ptr=21
  [-<<<<<<<<<<<+>>>>>>>>>>>]
>                                                              ; and the bit that came up from the byte below is added
                                                               ; to it
  [-<<<<<<<<<<<<+>>>>>>>>>>>>]
<<<<<                                                          ; this byte top bit is what goes up to the byte above
; ASSERT ptr=17
  [->>>>>+<<<<<]
<<<<<<                                                         ; to the byte above

; ==== byte 11 ====
; ASSERT ptr=11
  [->>>>>>+>>>>>>+<<<<<<<<<<<<]                                ; the byte is taken twice: once to be doubled and once
                                                               ; to give up its top bit
>>>>>>>>>>>>                                                   ; to the copy that will be doubled
; ASSERT ptr=23
  [-<<++>>]                                                    ; doubling wraps modulo 256 by itself  and that wrap IS
                                                               ; the low byte wanted
>                                                              ; seven turns of halving leave nothing but the top bit
  +++++++
[
  -
<<<<<<<                                                        ; to the value
; ASSERT ptr=17
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>                                                             ; the bit that falls off is not wanted here
  [-]
<                                                              ; the half becomes the value for the next turn
  [-<+>]
>>>>>>                                                         ; back to the turn counter
]
; ASSERT ptr=24
<<<                                                            ; the doubled byte goes back where it came from
; ASSERT ptr=21
  [-<<<<<<<<<<+>>>>>>>>>>]
>                                                              ; and the bit that came up from the byte below is added
                                                               ; to it
  [-<<<<<<<<<<<+>>>>>>>>>>>]
<<<<<                                                          ; this byte top bit is what goes up to the byte above
; ASSERT ptr=17
  [->>>>>+<<<<<]
<<<<<                                                          ; to the byte above

; ==== byte 12 ====
; ASSERT ptr=12
  [->>>>>+>>>>>>+<<<<<<<<<<<]                                  ; the byte is taken twice: once to be doubled and once
                                                               ; to give up its top bit
>>>>>>>>>>>                                                    ; to the copy that will be doubled
; ASSERT ptr=23
  [-<<++>>]                                                    ; doubling wraps modulo 256 by itself  and that wrap IS
                                                               ; the low byte wanted
>                                                              ; seven turns of halving leave nothing but the top bit
  +++++++
[
  -
<<<<<<<                                                        ; to the value
; ASSERT ptr=17
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>                                                             ; the bit that falls off is not wanted here
  [-]
<                                                              ; the half becomes the value for the next turn
  [-<+>]
>>>>>>                                                         ; back to the turn counter
]
; ASSERT ptr=24
<<<                                                            ; the doubled byte goes back where it came from
; ASSERT ptr=21
  [-<<<<<<<<<+>>>>>>>>>]
>                                                              ; and the bit that came up from the byte below is added
                                                               ; to it
  [-<<<<<<<<<<+>>>>>>>>>>]
<<<<<                                                          ; this byte top bit is what goes up to the byte above
; ASSERT ptr=17
  [->>>>>+<<<<<]
<<<<                                                           ; to the byte above

; ==== byte 13 ====
; ASSERT ptr=13
  [->>>>+>>>>>>+<<<<<<<<<<]                                    ; the byte is taken twice: once to be doubled and once
                                                               ; to give up its top bit
>>>>>>>>>>                                                     ; to the copy that will be doubled
; ASSERT ptr=23
  [-<<++>>]                                                    ; doubling wraps modulo 256 by itself  and that wrap IS
                                                               ; the low byte wanted
>                                                              ; seven turns of halving leave nothing but the top bit
  +++++++
[
  -
<<<<<<<                                                        ; to the value
; ASSERT ptr=17
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>                                                             ; the bit that falls off is not wanted here
  [-]
<                                                              ; the half becomes the value for the next turn
  [-<+>]
>>>>>>                                                         ; back to the turn counter
]
; ASSERT ptr=24
<<<                                                            ; the doubled byte goes back where it came from
; ASSERT ptr=21
  [-<<<<<<<<+>>>>>>>>]
>                                                              ; and the bit that came up from the byte below is added
                                                               ; to it
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<                                                          ; this byte top bit is what goes up to the byte above
; ASSERT ptr=17
  [->>>>>+<<<<<]
<<<                                                            ; to the byte above

; ==== byte 14 ====
; ASSERT ptr=14
  [->>>+>>>>>>+<<<<<<<<<]                                      ; the byte is taken twice: once to be doubled and once
                                                               ; to give up its top bit
>>>>>>>>>                                                      ; to the copy that will be doubled
; ASSERT ptr=23
  [-<<++>>]                                                    ; doubling wraps modulo 256 by itself  and that wrap IS
                                                               ; the low byte wanted
>                                                              ; seven turns of halving leave nothing but the top bit
  +++++++
[
  -
<<<<<<<                                                        ; to the value
; ASSERT ptr=17
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>                                                             ; the bit that falls off is not wanted here
  [-]
<                                                              ; the half becomes the value for the next turn
  [-<+>]
>>>>>>                                                         ; back to the turn counter
]
; ASSERT ptr=24
<<<                                                            ; the doubled byte goes back where it came from
; ASSERT ptr=21
  [-<<<<<<<+>>>>>>>]
>                                                              ; and the bit that came up from the byte below is added
                                                               ; to it
  [-<<<<<<<<+>>>>>>>>]
<<<<<                                                          ; this byte top bit is what goes up to the byte above
; ASSERT ptr=17
  [->>>>>+<<<<<]
<<                                                             ; to the byte above

; ==== byte 15 ====
; ASSERT ptr=15
  [->>+>>>>>>+<<<<<<<<]                                        ; the byte is taken twice: once to be doubled and once
                                                               ; to give up its top bit
>>>>>>>>                                                       ; to the copy that will be doubled
; ASSERT ptr=23
  [-<<++>>]                                                    ; doubling wraps modulo 256 by itself  and that wrap IS
                                                               ; the low byte wanted
>                                                              ; seven turns of halving leave nothing but the top bit
  +++++++
[
  -
<<<<<<<                                                        ; to the value
; ASSERT ptr=17
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>                                                             ; the bit that falls off is not wanted here
  [-]
<                                                              ; the half becomes the value for the next turn
  [-<+>]
>>>>>>                                                         ; back to the turn counter
]
; ASSERT ptr=24
<<<                                                            ; the doubled byte goes back where it came from
; ASSERT ptr=21
  [-<<<<<<+>>>>>>]
>                                                              ; and the bit that came up from the byte below is added
                                                               ; to it
  [-<<<<<<<+>>>>>>>]
<<<<<                                                          ; this byte top bit is what goes up to the byte above
; ASSERT ptr=17
  [->>>>>+<<<<<]
<                                                              ; to the byte above

; ==== byte 16 ====
; ASSERT ptr=16
  [->+>>>>>>+<<<<<<<]                                          ; the byte is taken twice: once to be doubled and once
                                                               ; to give up its top bit
>>>>>>>                                                        ; to the copy that will be doubled
; ASSERT ptr=23
  [-<<++>>]                                                    ; doubling wraps modulo 256 by itself  and that wrap IS
                                                               ; the low byte wanted
>                                                              ; seven turns of halving leave nothing but the top bit
  +++++++
[
  -
<<<<<<<                                                        ; to the value
; ASSERT ptr=17
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>                                                             ; the bit that falls off is not wanted here
  [-]
<                                                              ; the half becomes the value for the next turn
  [-<+>]
>>>>>>                                                         ; back to the turn counter
]
; ASSERT ptr=24
<<<                                                            ; the doubled byte goes back where it came from
; ASSERT ptr=21
  [-<<<<<+>>>>>]
>                                                              ; and the bit that came up from the byte below is added
                                                               ; to it
  [-<<<<<<+>>>>>>]
<<<<<                                                          ; this byte top bit is what goes up to the byte above
; ASSERT ptr=17
  [->>>>>+<<<<<]

>>>>>                                                          ; the bit shifted out of the top byte is discarded
; ASSERT ptr=22
  [-]
<<<<<<<<<<<<<<<<<<<<<<                                         ; back to the head of the value
; ASSERT ptr=0
; ASSERT zero 17:24
; emit the shifted value little endian
  .>.>.>.>.>.>.>.>.>.>.>.>.>.>.>.>.
