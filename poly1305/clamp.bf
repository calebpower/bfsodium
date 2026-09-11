; bfsodium CLAMP : r as RFC 8439 section 2 point 5 requires it
;
; HAND WRITTEN; Bytes 3 7 11 and 15 keep only their low four bits  and bytes 4
; 8 and 12 lose their low two; It was lifted out of poly1305 so the AEAD can
; clamp the same way without a second copy of it existing;
;
; INTERFACE entry=15 exit=15 footprint=0:21
; IO  in:  r{16}              (16 bytes)
;     out: r{17} LE clamped   (17 bytes)
;
; TAPE MAP  (home @0)
;   @0x00:0x0f  r{16}  u8  the key half  clamped where it lies
;   @0x10       hi     u8  the seventeenth byte; NEVER WRITTEN  so it stays
;                          nought  which is what makes the answer a 17 byte
;                          value the rest of the Poly1305 code can take
;   @0x11       v      u8  the byte being worked on; the HALVE anchor
;   @0x12       q      u8  the half it leaves
;   @0x13       t      u8  the bit that fell off
;   @0x14       f      u8  HALVE scratch  restored to nought
;   @0x15       a      u8  the byte being put back together
;
; brainfuck has no AND  so a mask is arithmetic; Keeping the low four bits is
; four HALVEs  each one handing back a bit that is added into a with the weight
; it had  and then throwing away whatever is left above bit three; Losing the
; low two bits is two HALVEs whose bits are dropped  after which the half is
; put back multiplied by four  which is the same value with those two bits
; nought;
;
; The seven bytes are visited left to right so the pointer only ever walks
; forward through them  and each visit is entered and left on the byte itself;

  ,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,                              ; read r
                                                               ; ASSERT ptr=15
                                                               ; ASSERT zero 16:21
<<<<<<<<<<<<                                                   ; to the first byte the clamp touches
; ==== byte 3 ====
  [->>>>>>>>>>>>>>+<<<<<<<<<<<<<<]                             ; the byte steps into the working frame
>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=17
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving  and the bit that falls off is worth 1 here
>>
  [->>+<<]
<
  [-<+>]                                                       ; the half goes back to be halved again
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving  and the bit that falls off is worth 2 here
>>
  [->>++<<]
<
  [-<+>]                                                       ; the half goes back to be halved again
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving  and the bit that falls off is worth 4 here
>>
  [->>++++<<]
<
  [-<+>]                                                       ; the half goes back to be halved again
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving  and the bit that falls off is worth 8 here
>>
  [->>++++++++<<]
<
  [-]                                                          ; what is left above bit three is what the clamp throws
                                                               ; away
                                                               ; ASSERT ptr=18
>>>
  [-<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>]                     ; the byte goes back where it came from
<<<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=3
                                                               ; ASSERT zero 17:21
>                                                              ; on to the next byte the clamp touches
; ==== byte 4 ====
  [->>>>>>>>>>>>>+<<<<<<<<<<<<<]                               ; the byte steps into the working frame
>>>>>>>>>>>>>
                                                               ; ASSERT ptr=17
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving  and the bit that falls off is one the clamp
                                                               ; throws away
>>
  [-]
<
  [-<+>]                                                       ; the half goes back to be halved again
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving  and the bit that falls off is one the clamp
                                                               ; throws away
>>
  [-]
<
                                                               ; ASSERT ptr=18
  [-<<<<<<<<<<<<<<++++>>>>>>>>>>>>>>]                          ; the quarter goes back multiplied by four  which is
                                                               ; those two bits gone
<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=4
                                                               ; ASSERT zero 17:21
>>>                                                            ; on to the next byte the clamp touches
; ==== byte 7 ====
  [->>>>>>>>>>+<<<<<<<<<<]                                     ; the byte steps into the working frame
>>>>>>>>>>
                                                               ; ASSERT ptr=17
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving  and the bit that falls off is worth 1 here
>>
  [->>+<<]
<
  [-<+>]                                                       ; the half goes back to be halved again
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving  and the bit that falls off is worth 2 here
>>
  [->>++<<]
<
  [-<+>]                                                       ; the half goes back to be halved again
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving  and the bit that falls off is worth 4 here
>>
  [->>++++<<]
<
  [-<+>]                                                       ; the half goes back to be halved again
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving  and the bit that falls off is worth 8 here
>>
  [->>++++++++<<]
<
  [-]                                                          ; what is left above bit three is what the clamp throws
                                                               ; away
                                                               ; ASSERT ptr=18
>>>
  [-<<<<<<<<<<<<<<+>>>>>>>>>>>>>>]                             ; the byte goes back where it came from
<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=7
                                                               ; ASSERT zero 17:21
>                                                              ; on to the next byte the clamp touches
; ==== byte 8 ====
  [->>>>>>>>>+<<<<<<<<<]                                       ; the byte steps into the working frame
>>>>>>>>>
                                                               ; ASSERT ptr=17
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving  and the bit that falls off is one the clamp
                                                               ; throws away
>>
  [-]
<
  [-<+>]                                                       ; the half goes back to be halved again
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving  and the bit that falls off is one the clamp
                                                               ; throws away
>>
  [-]
<
                                                               ; ASSERT ptr=18
  [-<<<<<<<<<<++++>>>>>>>>>>]                                  ; the quarter goes back multiplied by four  which is
                                                               ; those two bits gone
<<<<<<<<<<
                                                               ; ASSERT ptr=8
                                                               ; ASSERT zero 17:21
>>>                                                            ; on to the next byte the clamp touches
; ==== byte 11 ====
  [->>>>>>+<<<<<<]                                             ; the byte steps into the working frame
>>>>>>
                                                               ; ASSERT ptr=17
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving  and the bit that falls off is worth 1 here
>>
  [->>+<<]
<
  [-<+>]                                                       ; the half goes back to be halved again
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving  and the bit that falls off is worth 2 here
>>
  [->>++<<]
<
  [-<+>]                                                       ; the half goes back to be halved again
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving  and the bit that falls off is worth 4 here
>>
  [->>++++<<]
<
  [-<+>]                                                       ; the half goes back to be halved again
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving  and the bit that falls off is worth 8 here
>>
  [->>++++++++<<]
<
  [-]                                                          ; what is left above bit three is what the clamp throws
                                                               ; away
                                                               ; ASSERT ptr=18
>>>
  [-<<<<<<<<<<+>>>>>>>>>>]                                     ; the byte goes back where it came from
<<<<<<<<<<
                                                               ; ASSERT ptr=11
                                                               ; ASSERT zero 17:21
>                                                              ; on to the next byte the clamp touches
; ==== byte 12 ====
  [->>>>>+<<<<<]                                               ; the byte steps into the working frame
>>>>>
                                                               ; ASSERT ptr=17
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving  and the bit that falls off is one the clamp
                                                               ; throws away
>>
  [-]
<
  [-<+>]                                                       ; the half goes back to be halved again
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving  and the bit that falls off is one the clamp
                                                               ; throws away
>>
  [-]
<
                                                               ; ASSERT ptr=18
  [-<<<<<<++++>>>>>>]                                          ; the quarter goes back multiplied by four  which is
                                                               ; those two bits gone
<<<<<<
                                                               ; ASSERT ptr=12
                                                               ; ASSERT zero 17:21
>>>                                                            ; on to the next byte the clamp touches
; ==== byte 15 ====
  [->>+<<]                                                     ; the byte steps into the working frame
>>
                                                               ; ASSERT ptr=17
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving  and the bit that falls off is worth 1 here
>>
  [->>+<<]
<
  [-<+>]                                                       ; the half goes back to be halved again
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving  and the bit that falls off is worth 2 here
>>
  [->>++<<]
<
  [-<+>]                                                       ; the half goes back to be halved again
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving  and the bit that falls off is worth 4 here
>>
  [->>++++<<]
<
  [-<+>]                                                       ; the half goes back to be halved again
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving  and the bit that falls off is worth 8 here
>>
  [->>++++++++<<]
<
  [-]                                                          ; what is left above bit three is what the clamp throws
                                                               ; away
                                                               ; ASSERT ptr=18
>>>
  [-<<<<<<+>>>>>>]                                             ; the byte goes back where it came from
<<<<<<
                                                               ; ASSERT ptr=15
                                                               ; ASSERT zero 17:21

; emit
<<<<<<<<<<<<<<<                                                ; back to the head of r
  .>  .>  .>  .>  .>  .>  .>  .>  .>  .>  .>  .>  .>  .>  .>   ; the clamped r  seventeen bytes little endian
    .>.                                                        ; continued
