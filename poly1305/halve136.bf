; bfsodium HALVE136 : 17 byte little endian shift right one
;
; HAND WRITTEN; the bytes are walked from the TOP down  because the bit that
; leaves a byte at the bottom is the bit that arrives at the top of the byte
; below  and walking downward means it is always ready before it is wanted;
;
; INTERFACE entry=16 exit=0 footprint=0:21
; IO  in:  x{17} LE                      (17 bytes)
;     out: (x shifted right one){17} LE  (17 bytes)
;
; TAPE MAP  (home @0)
;   @0x00:0x10  x{17}  u8   the value  and the result  LSB at @0x00
;   @0x11       h      u8   HALVE frame: the byte being halved  counted to nought
;   @0x12       q      u8   HALVE frame: that byte shifted right one
;   @0x13       bit    u8   HALVE frame: that byte low bit
;   @0x14       f      u8   HALVE frame scratch  restored to nought
;   @0x15       c      u8   the bit coming down from the byte above
;
; HALVE counts h down to nought  toggling bit on every step and adding one to q
; on every second one; so q ends as h over two and bit as the low bit  with the
; scratch back at nought; The bit that came down from above is worth 128 in this
; byte  which is why it is added and not shifted;
;
; The TOP byte has no carry to receive: nothing has been halved above it yet  and
; the contract below states that the frame including c is clear on entry; So the
; top byte's block leaves that step out rather than carrying an add that no input
; could ever reach  which is code no test could cover;

  ,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,                            ; read the value little endian
                                                               ; ASSERT ptr=16
                                                               ; ASSERT zero 17:21

; ==== byte 16 ====
                                                               ; ASSERT ptr=16
  [->+<]                                                       ; the byte steps into the halving frame
>
                                                               ; ASSERT ptr=17
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; count it down  toggling the low bit and adding to the
                                                               ; quotient
>                                                              ; the quotient goes back into the byte
  [-<<+>>]
>                                                              ; nothing has come down to the top byte  so there is no
                                                               ; bit to add here
                                                               ; ASSERT ptr=19
  [->>+<<]
<<<<                                                           ; to the byte below

; ==== byte 15 ====
                                                               ; ASSERT ptr=15
  [->>+<<]                                                     ; the byte steps into the halving frame
>>
                                                               ; ASSERT ptr=17
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; count it down  toggling the low bit and adding to the
                                                               ; quotient
>                                                              ; the quotient goes back into the byte
  [-<<<+>>>]
>>>                                                            ; the bit that came down from the byte above is worth
                                                               ; 128 here
                                                               ; ASSERT ptr=21
  [-<<<<<<
  ++++++++++++++++++++++++++++++++++++++++
                                                               ; continued
  ++++++++++++++++++++++++++++++++++++++++
                                                               ; continued
  ++++++++++++++++++++++++++++++++++++++++
                                                               ; continued
  ++++++++
>>>>>>]
<<                                                             ; this byte low bit is what goes down to the byte below
                                                               ; ASSERT ptr=19
  [->>+<<]
<<<<<                                                          ; to the byte below

; ==== byte 14 ====
                                                               ; ASSERT ptr=14
  [->>>+<<<]                                                   ; the byte steps into the halving frame
>>>
                                                               ; ASSERT ptr=17
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; count it down  toggling the low bit and adding to the
                                                               ; quotient
>                                                              ; the quotient goes back into the byte
  [-<<<<+>>>>]
>>>                                                            ; the bit that came down from the byte above is worth
                                                               ; 128 here
                                                               ; ASSERT ptr=21
  [-<<<<<<<
  ++++++++++++++++++++++++++++++++++++++++
                                                               ; continued
  ++++++++++++++++++++++++++++++++++++++++
                                                               ; continued
  ++++++++++++++++++++++++++++++++++++++++
                                                               ; continued
  ++++++++
>>>>>>>]
<<                                                             ; this byte low bit is what goes down to the byte below
                                                               ; ASSERT ptr=19
  [->>+<<]
<<<<<<                                                         ; to the byte below

; ==== byte 13 ====
                                                               ; ASSERT ptr=13
  [->>>>+<<<<]                                                 ; the byte steps into the halving frame
>>>>
                                                               ; ASSERT ptr=17
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; count it down  toggling the low bit and adding to the
                                                               ; quotient
>                                                              ; the quotient goes back into the byte
  [-<<<<<+>>>>>]
>>>                                                            ; the bit that came down from the byte above is worth
                                                               ; 128 here
                                                               ; ASSERT ptr=21
  [-<<<<<<<<
  ++++++++++++++++++++++++++++++++++++++++
                                                               ; continued
  ++++++++++++++++++++++++++++++++++++++++
                                                               ; continued
  ++++++++++++++++++++++++++++++++++++++++
                                                               ; continued
  ++++++++
>>>>>>>>]
<<                                                             ; this byte low bit is what goes down to the byte below
                                                               ; ASSERT ptr=19
  [->>+<<]
<<<<<<<                                                        ; to the byte below

; ==== byte 12 ====
                                                               ; ASSERT ptr=12
  [->>>>>+<<<<<]                                               ; the byte steps into the halving frame
>>>>>
                                                               ; ASSERT ptr=17
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; count it down  toggling the low bit and adding to the
                                                               ; quotient
>                                                              ; the quotient goes back into the byte
  [-<<<<<<+>>>>>>]
>>>                                                            ; the bit that came down from the byte above is worth
                                                               ; 128 here
                                                               ; ASSERT ptr=21
  [-<<<<<<<<<
  ++++++++++++++++++++++++++++++++++++++++
                                                               ; continued
  ++++++++++++++++++++++++++++++++++++++++
                                                               ; continued
  ++++++++++++++++++++++++++++++++++++++++
                                                               ; continued
  ++++++++
>>>>>>>>>]
<<                                                             ; this byte low bit is what goes down to the byte below
                                                               ; ASSERT ptr=19
  [->>+<<]
<<<<<<<<                                                       ; to the byte below

; ==== byte 11 ====
                                                               ; ASSERT ptr=11
  [->>>>>>+<<<<<<]                                             ; the byte steps into the halving frame
>>>>>>
                                                               ; ASSERT ptr=17
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; count it down  toggling the low bit and adding to the
                                                               ; quotient
>                                                              ; the quotient goes back into the byte
  [-<<<<<<<+>>>>>>>]
>>>                                                            ; the bit that came down from the byte above is worth
                                                               ; 128 here
                                                               ; ASSERT ptr=21
  [-<<<<<<<<<<
  ++++++++++++++++++++++++++++++++++++++++
                                                               ; continued
  ++++++++++++++++++++++++++++++++++++++++
                                                               ; continued
  ++++++++++++++++++++++++++++++++++++++++
                                                               ; continued
  ++++++++
>>>>>>>>>>]
<<                                                             ; this byte low bit is what goes down to the byte below
                                                               ; ASSERT ptr=19
  [->>+<<]
<<<<<<<<<                                                      ; to the byte below

; ==== byte 10 ====
                                                               ; ASSERT ptr=10
  [->>>>>>>+<<<<<<<]                                           ; the byte steps into the halving frame
>>>>>>>
                                                               ; ASSERT ptr=17
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; count it down  toggling the low bit and adding to the
                                                               ; quotient
>                                                              ; the quotient goes back into the byte
  [-<<<<<<<<+>>>>>>>>]
>>>                                                            ; the bit that came down from the byte above is worth
                                                               ; 128 here
                                                               ; ASSERT ptr=21
  [-<<<<<<<<<<<
  ++++++++++++++++++++++++++++++++++++++++
                                                               ; continued
  ++++++++++++++++++++++++++++++++++++++++
                                                               ; continued
  ++++++++++++++++++++++++++++++++++++++++
                                                               ; continued
  ++++++++
>>>>>>>>>>>]
<<                                                             ; this byte low bit is what goes down to the byte below
                                                               ; ASSERT ptr=19
  [->>+<<]
<<<<<<<<<<                                                     ; to the byte below

; ==== byte 9 ====
                                                               ; ASSERT ptr=9
  [->>>>>>>>+<<<<<<<<]                                         ; the byte steps into the halving frame
>>>>>>>>
                                                               ; ASSERT ptr=17
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; count it down  toggling the low bit and adding to the
                                                               ; quotient
>                                                              ; the quotient goes back into the byte
  [-<<<<<<<<<+>>>>>>>>>]
>>>                                                            ; the bit that came down from the byte above is worth
                                                               ; 128 here
                                                               ; ASSERT ptr=21
  [-<<<<<<<<<<<<
  ++++++++++++++++++++++++++++++++++++++++
                                                               ; continued
  ++++++++++++++++++++++++++++++++++++++++
                                                               ; continued
  ++++++++++++++++++++++++++++++++++++++++
                                                               ; continued
  ++++++++
>>>>>>>>>>>>]
<<                                                             ; this byte low bit is what goes down to the byte below
                                                               ; ASSERT ptr=19
  [->>+<<]
<<<<<<<<<<<                                                    ; to the byte below

; ==== byte 8 ====
                                                               ; ASSERT ptr=8
  [->>>>>>>>>+<<<<<<<<<]                                       ; the byte steps into the halving frame
>>>>>>>>>
                                                               ; ASSERT ptr=17
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; count it down  toggling the low bit and adding to the
                                                               ; quotient
>                                                              ; the quotient goes back into the byte
  [-<<<<<<<<<<+>>>>>>>>>>]
>>>                                                            ; the bit that came down from the byte above is worth
                                                               ; 128 here
                                                               ; ASSERT ptr=21
  [-<<<<<<<<<<<<<
  ++++++++++++++++++++++++++++++++++++++++
                                                               ; continued
  ++++++++++++++++++++++++++++++++++++++++
                                                               ; continued
  ++++++++++++++++++++++++++++++++++++++++
                                                               ; continued
  ++++++++
>>>>>>>>>>>>>]
<<                                                             ; this byte low bit is what goes down to the byte below
                                                               ; ASSERT ptr=19
  [->>+<<]
<<<<<<<<<<<<                                                   ; to the byte below

; ==== byte 7 ====
                                                               ; ASSERT ptr=7
  [->>>>>>>>>>+<<<<<<<<<<]                                     ; the byte steps into the halving frame
>>>>>>>>>>
                                                               ; ASSERT ptr=17
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; count it down  toggling the low bit and adding to the
                                                               ; quotient
>                                                              ; the quotient goes back into the byte
  [-<<<<<<<<<<<+>>>>>>>>>>>]
>>>                                                            ; the bit that came down from the byte above is worth
                                                               ; 128 here
                                                               ; ASSERT ptr=21
  [-<<<<<<<<<<<<<<
  ++++++++++++++++++++++++++++++++++++++++
                                                               ; continued
  ++++++++++++++++++++++++++++++++++++++++
                                                               ; continued
  ++++++++++++++++++++++++++++++++++++++++
                                                               ; continued
  ++++++++
>>>>>>>>>>>>>>]
<<                                                             ; this byte low bit is what goes down to the byte below
                                                               ; ASSERT ptr=19
  [->>+<<]
<<<<<<<<<<<<<                                                  ; to the byte below

; ==== byte 6 ====
                                                               ; ASSERT ptr=6
  [->>>>>>>>>>>+<<<<<<<<<<<]                                   ; the byte steps into the halving frame
>>>>>>>>>>>
                                                               ; ASSERT ptr=17
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; count it down  toggling the low bit and adding to the
                                                               ; quotient
>                                                              ; the quotient goes back into the byte
  [-<<<<<<<<<<<<+>>>>>>>>>>>>]
>>>                                                            ; the bit that came down from the byte above is worth
                                                               ; 128 here
                                                               ; ASSERT ptr=21
  [-<<<<<<<<<<<<<<<
  ++++++++++++++++++++++++++++++++++++++++
                                                               ; continued
  ++++++++++++++++++++++++++++++++++++++++
                                                               ; continued
  ++++++++++++++++++++++++++++++++++++++++
                                                               ; continued
  ++++++++
>>>>>>>>>>>>>>>]
<<                                                             ; this byte low bit is what goes down to the byte below
                                                               ; ASSERT ptr=19
  [->>+<<]
<<<<<<<<<<<<<<                                                 ; to the byte below

; ==== byte 5 ====
                                                               ; ASSERT ptr=5
  [->>>>>>>>>>>>+<<<<<<<<<<<<]                                 ; the byte steps into the halving frame
>>>>>>>>>>>>
                                                               ; ASSERT ptr=17
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; count it down  toggling the low bit and adding to the
                                                               ; quotient
>                                                              ; the quotient goes back into the byte
  [-<<<<<<<<<<<<<+>>>>>>>>>>>>>]
>>>                                                            ; the bit that came down from the byte above is worth
                                                               ; 128 here
                                                               ; ASSERT ptr=21
  [-<<<<<<<<<<<<<<<<
  ++++++++++++++++++++++++++++++++++++++++
                                                               ; continued
  ++++++++++++++++++++++++++++++++++++++++
                                                               ; continued
  ++++++++++++++++++++++++++++++++++++++++
                                                               ; continued
  ++++++++
>>>>>>>>>>>>>>>>]
<<                                                             ; this byte low bit is what goes down to the byte below
                                                               ; ASSERT ptr=19
  [->>+<<]
<<<<<<<<<<<<<<<                                                ; to the byte below

; ==== byte 4 ====
                                                               ; ASSERT ptr=4
  [->>>>>>>>>>>>>+<<<<<<<<<<<<<]                               ; the byte steps into the halving frame
>>>>>>>>>>>>>
                                                               ; ASSERT ptr=17
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; count it down  toggling the low bit and adding to the
                                                               ; quotient
>                                                              ; the quotient goes back into the byte
  [-<<<<<<<<<<<<<<+>>>>>>>>>>>>>>]
>>>                                                            ; the bit that came down from the byte above is worth
                                                               ; 128 here
                                                               ; ASSERT ptr=21
  [-<<<<<<<<<<<<<<<<<
  ++++++++++++++++++++++++++++++++++++++++
                                                               ; continued
  ++++++++++++++++++++++++++++++++++++++++
                                                               ; continued
  ++++++++++++++++++++++++++++++++++++++++
                                                               ; continued
  ++++++++
>>>>>>>>>>>>>>>>>]
<<                                                             ; this byte low bit is what goes down to the byte below
                                                               ; ASSERT ptr=19
  [->>+<<]
<<<<<<<<<<<<<<<<                                               ; to the byte below

; ==== byte 3 ====
                                                               ; ASSERT ptr=3
  [->>>>>>>>>>>>>>+<<<<<<<<<<<<<<]                             ; the byte steps into the halving frame
>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=17
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; count it down  toggling the low bit and adding to the
                                                               ; quotient
>                                                              ; the quotient goes back into the byte
  [-<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>]
>>>                                                            ; the bit that came down from the byte above is worth
                                                               ; 128 here
                                                               ; ASSERT ptr=21
  [-<<<<<<<<<<<<<<<<<<
  ++++++++++++++++++++++++++++++++++++++++
                                                               ; continued
  ++++++++++++++++++++++++++++++++++++++++
                                                               ; continued
  ++++++++++++++++++++++++++++++++++++++++
                                                               ; continued
  ++++++++
>>>>>>>>>>>>>>>>>>]
<<                                                             ; this byte low bit is what goes down to the byte below
                                                               ; ASSERT ptr=19
  [->>+<<]
<<<<<<<<<<<<<<<<<                                              ; to the byte below

; ==== byte 2 ====
                                                               ; ASSERT ptr=2
  [->>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<]                           ; the byte steps into the halving frame
>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=17
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; count it down  toggling the low bit and adding to the
                                                               ; quotient
>                                                              ; the quotient goes back into the byte
  [-<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>]
>>>                                                            ; the bit that came down from the byte above is worth
                                                               ; 128 here
                                                               ; ASSERT ptr=21
  [-<<<<<<<<<<<<<<<<<<<
  ++++++++++++++++++++++++++++++++++++++++
                                                               ; continued
  ++++++++++++++++++++++++++++++++++++++++
                                                               ; continued
  ++++++++++++++++++++++++++++++++++++++++
                                                               ; continued
  ++++++++
>>>>>>>>>>>>>>>>>>>]
<<                                                             ; this byte low bit is what goes down to the byte below
                                                               ; ASSERT ptr=19
  [->>+<<]
<<<<<<<<<<<<<<<<<<                                             ; to the byte below

; ==== byte 1 ====
                                                               ; ASSERT ptr=1
  [->>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<]                         ; the byte steps into the halving frame
>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=17
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; count it down  toggling the low bit and adding to the
                                                               ; quotient
>                                                              ; the quotient goes back into the byte
  [-<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>]
>>>                                                            ; the bit that came down from the byte above is worth
                                                               ; 128 here
                                                               ; ASSERT ptr=21
  [-<<<<<<<<<<<<<<<<<<<<
  ++++++++++++++++++++++++++++++++++++++++
                                                               ; continued
  ++++++++++++++++++++++++++++++++++++++++
                                                               ; continued
  ++++++++++++++++++++++++++++++++++++++++
                                                               ; continued
  ++++++++
>>>>>>>>>>>>>>>>>>>>]
<<                                                             ; this byte low bit is what goes down to the byte below
                                                               ; ASSERT ptr=19
  [->>+<<]
<<<<<<<<<<<<<<<<<<<                                            ; to the byte below

; ==== byte 0 ====
                                                               ; ASSERT ptr=0
  [->>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<]                       ; the byte steps into the halving frame
>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=17
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; count it down  toggling the low bit and adding to the
                                                               ; quotient
>                                                              ; the quotient goes back into the byte
  [-<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>]
>>>                                                            ; the bit that came down from the byte above is worth
                                                               ; 128 here
                                                               ; ASSERT ptr=21
  [-<<<<<<<<<<<<<<<<<<<<<
  ++++++++++++++++++++++++++++++++++++++++
                                                               ; continued
  ++++++++++++++++++++++++++++++++++++++++
                                                               ; continued
  ++++++++++++++++++++++++++++++++++++++++
                                                               ; continued
  ++++++++
>>>>>>>>>>>>>>>>>>>>>]
<<                                                             ; this byte low bit is what goes down to the byte below
                                                               ; ASSERT ptr=19
  [->>+<<]

>>                                                             ; the bit shifted out of the bottom byte is discarded
                                                               ; ASSERT ptr=21
  [-]
<<<<<<<<<<<<<<<<<<<<<                                          ; back to the head of the value
                                                               ; ASSERT ptr=0
                                                               ; ASSERT zero 17:21
; emit the shifted value little endian
  .>.>.>.>.>.>.>.>.>.>.>.>.>.>.>.>.
