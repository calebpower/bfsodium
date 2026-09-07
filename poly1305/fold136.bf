; bfsodium FOLD136 : one Poly1305 reduction step  using 2^130 = 5 modulo p
;
; HAND WRITTEN; The split is at bit 130  and 130 is 128 plus 2  so the part of
; the value at or above the split is simply the TOP BYTE shifted right twice  and
; the part below it is that byte with all but its bottom two bits removed; No
; shifting of the whole seventeen bytes is needed anywhere;
;
; INTERFACE entry=16 exit=0 footprint=0:46
; IO  in:  x{17} LE                     (17 bytes)
;     out: (L plus 5H){17} LE           (17 bytes)  where x = L plus H times 2^130
;
; TAPE MAP  (home @0)
;   @0x00:0x10  x{17}   u8   the value  and the result; also add136's accumulator
;   @0x11:0x21  b{17}   u8   add136's addend
;   @0x22:0x27  add136's carry and ADD8 frame; its footprint is 0:39 pasted here
;   @0x28       H       u8   the part of the value at or above bit 130; at most 63
;   @0x29       tmp     u8   puts H back after it has been copied
;   @0x2a       h       u8   HALVE frame: the byte being halved
;   @0x2b       q       u8   HALVE frame: that byte shifted right one
;   @0x2c       bit     u8   HALVE frame: that byte low bit
;   @0x2d       f       u8   HALVE frame scratch  restored to nought
;   @0x2e       n       u8   five turns of the adder
;
; H is at most 63  so five times H is at most 315 and the value below the split
; is under 2^130; their sum cannot reach 2^136  so the adder's dropped top carry
; is never reached and folding never loses anything;
;
; The five is done as FIVE TURNS of one pasted adder rather than as a multiply
; or as five pasted adders; add136 clears its own frame on the way out and
; asserts it clear on the way in  which is what makes entering it five times
; mean the same thing as entering it once;

; read the value little endian
  ,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,

; ==== split the top byte at bit 130 ====
; ASSERT ptr=16
; ASSERT zero 17:46
; the top byte steps into the halving frame
  [->>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>>>>>>>>>
; ASSERT ptr=42
; the first halving; the bit it drops is bit 128
  [->>>+<[-<+>>-<]>[-<+>]<<<]
; which is worth one in what is left below the split
>>
; ASSERT ptr=44
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>>>]
; the half steps back into the frame to be halved again
<
; ASSERT ptr=43
  [-<+>]
<
; ASSERT ptr=42
; the second halving; the bit it drops is bit 129
  [->>>+<[-<+>>-<]>[-<+>]<<<]
; which is worth two
>>
; ASSERT ptr=44
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<++>>>>>>>>>>>>>>>>>>>>>>>>>>>>]
; and what is left in the quotient is everything at bit 130 and above
<
; ASSERT ptr=43
  [-<<<+>>>]

; ==== two to the hundred and thirtieth is five  so add that part five times ====
>>>
; ASSERT ptr=46
  +++++
[
  -
; the part above the split is copied into the addend and kept for the next turn
<<<<<<
; ASSERT ptr=40
  [-<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>+<]
>
; ASSERT ptr=41
  [-<+>]
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; continued
  <
; ASSERT ptr=0
; ASSERT zero 34:39
; walk in to this routine entry offset
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ASSERT ptr=34
; ASSERT zero 34:39

; ==== byte 0 ====
; ASSERT ptr=34
; the accumulator byte steps into the adder
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; ASSERT ptr=0
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]
; the addend byte follows it
>>>>>>>>>>>>>>>>>
  [->>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<]
; add the addend into the accumulator byte
>>>>>>>>>>>>>>>>>>>
; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; the carry in follows it
<<
  [->>+<<]
; add that in too
>>
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; the low byte of the sum goes back where it came from
<
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]
; the carry out becomes the carry in of the byte above
>>
  [-<<<+>>>]
<<<

; ==== byte 1 ====
; ASSERT ptr=34
; the accumulator byte steps into the adder
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; ASSERT ptr=1
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]
; the addend byte follows it
>>>>>>>>>>>>>>>>>
  [->>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<]
; add the addend into the accumulator byte
>>>>>>>>>>>>>>>>>>
; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; the carry in follows it
<<
  [->>+<<]
; add that in too
>>
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; the low byte of the sum goes back where it came from
<
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]
; the carry out becomes the carry in of the byte above
>>
  [-<<<+>>>]
<<<

; ==== byte 2 ====
; ASSERT ptr=34
; the accumulator byte steps into the adder
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; ASSERT ptr=2
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]
; the addend byte follows it
>>>>>>>>>>>>>>>>>
  [->>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<]
; add the addend into the accumulator byte
>>>>>>>>>>>>>>>>>
; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; the carry in follows it
<<
  [->>+<<]
; add that in too
>>
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; the low byte of the sum goes back where it came from
<
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]
; the carry out becomes the carry in of the byte above
>>
  [-<<<+>>>]
<<<

; ==== byte 3 ====
; ASSERT ptr=34
; the accumulator byte steps into the adder
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; ASSERT ptr=3
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]
; the addend byte follows it
>>>>>>>>>>>>>>>>>
  [->>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<]
; add the addend into the accumulator byte
>>>>>>>>>>>>>>>>
; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; the carry in follows it
<<
  [->>+<<]
; add that in too
>>
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; the low byte of the sum goes back where it came from
<
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]
; the carry out becomes the carry in of the byte above
>>
  [-<<<+>>>]
<<<

; ==== byte 4 ====
; ASSERT ptr=34
; the accumulator byte steps into the adder
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; ASSERT ptr=4
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]
; the addend byte follows it
>>>>>>>>>>>>>>>>>
  [->>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<]
; add the addend into the accumulator byte
>>>>>>>>>>>>>>>
; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; the carry in follows it
<<
  [->>+<<]
; add that in too
>>
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; the low byte of the sum goes back where it came from
<
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]
; the carry out becomes the carry in of the byte above
>>
  [-<<<+>>>]
<<<

; ==== byte 5 ====
; ASSERT ptr=34
; the accumulator byte steps into the adder
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; ASSERT ptr=5
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]
; the addend byte follows it
>>>>>>>>>>>>>>>>>
  [->>>>>>>>>>>>>>+<<<<<<<<<<<<<<]
; add the addend into the accumulator byte
>>>>>>>>>>>>>>
; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; the carry in follows it
<<
  [->>+<<]
; add that in too
>>
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; the low byte of the sum goes back where it came from
<
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]
; the carry out becomes the carry in of the byte above
>>
  [-<<<+>>>]
<<<

; ==== byte 6 ====
; ASSERT ptr=34
; the accumulator byte steps into the adder
<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; ASSERT ptr=6
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]
; the addend byte follows it
>>>>>>>>>>>>>>>>>
  [->>>>>>>>>>>>>+<<<<<<<<<<<<<]
; add the addend into the accumulator byte
>>>>>>>>>>>>>
; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; the carry in follows it
<<
  [->>+<<]
; add that in too
>>
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; the low byte of the sum goes back where it came from
<
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]
; the carry out becomes the carry in of the byte above
>>
  [-<<<+>>>]
<<<

; ==== byte 7 ====
; ASSERT ptr=34
; the accumulator byte steps into the adder
<<<<<<<<<<<<<<<<<<<<<<<<<<<
; ASSERT ptr=7
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<]
; the addend byte follows it
>>>>>>>>>>>>>>>>>
  [->>>>>>>>>>>>+<<<<<<<<<<<<]
; add the addend into the accumulator byte
>>>>>>>>>>>>
; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; the carry in follows it
<<
  [->>+<<]
; add that in too
>>
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; the low byte of the sum goes back where it came from
<
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>>>]
; the carry out becomes the carry in of the byte above
>>
  [-<<<+>>>]
<<<

; ==== byte 8 ====
; ASSERT ptr=34
; the accumulator byte steps into the adder
<<<<<<<<<<<<<<<<<<<<<<<<<<
; ASSERT ptr=8
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<]
; the addend byte follows it
>>>>>>>>>>>>>>>>>
  [->>>>>>>>>>>+<<<<<<<<<<<]
; add the addend into the accumulator byte
>>>>>>>>>>>
; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; the carry in follows it
<<
  [->>+<<]
; add that in too
>>
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; the low byte of the sum goes back where it came from
<
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>>]
; the carry out becomes the carry in of the byte above
>>
  [-<<<+>>>]
<<<

; ==== byte 9 ====
; ASSERT ptr=34
; the accumulator byte steps into the adder
<<<<<<<<<<<<<<<<<<<<<<<<<
; ASSERT ptr=9
  [->>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<]
; the addend byte follows it
>>>>>>>>>>>>>>>>>
  [->>>>>>>>>>+<<<<<<<<<<]
; add the addend into the accumulator byte
>>>>>>>>>>
; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; the carry in follows it
<<
  [->>+<<]
; add that in too
>>
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; the low byte of the sum goes back where it came from
<
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>]
; the carry out becomes the carry in of the byte above
>>
  [-<<<+>>>]
<<<

; ==== byte 10 ====
; ASSERT ptr=34
; the accumulator byte steps into the adder
<<<<<<<<<<<<<<<<<<<<<<<<
; ASSERT ptr=10
  [->>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<]
; the addend byte follows it
>>>>>>>>>>>>>>>>>
  [->>>>>>>>>+<<<<<<<<<]
; add the addend into the accumulator byte
>>>>>>>>>
; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; the carry in follows it
<<
  [->>+<<]
; add that in too
>>
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; the low byte of the sum goes back where it came from
<
  [-<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>]
; the carry out becomes the carry in of the byte above
>>
  [-<<<+>>>]
<<<

; ==== byte 11 ====
; ASSERT ptr=34
; the accumulator byte steps into the adder
<<<<<<<<<<<<<<<<<<<<<<<
; ASSERT ptr=11
  [->>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<]
; the addend byte follows it
>>>>>>>>>>>>>>>>>
  [->>>>>>>>+<<<<<<<<]
; add the addend into the accumulator byte
>>>>>>>>
; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; the carry in follows it
<<
  [->>+<<]
; add that in too
>>
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; the low byte of the sum goes back where it came from
<
  [-<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>]
; the carry out becomes the carry in of the byte above
>>
  [-<<<+>>>]
<<<

; ==== byte 12 ====
; ASSERT ptr=34
; the accumulator byte steps into the adder
<<<<<<<<<<<<<<<<<<<<<<
; ASSERT ptr=12
  [->>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<]
; the addend byte follows it
>>>>>>>>>>>>>>>>>
  [->>>>>>>+<<<<<<<]
; add the addend into the accumulator byte
>>>>>>>
; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; the carry in follows it
<<
  [->>+<<]
; add that in too
>>
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; the low byte of the sum goes back where it came from
<
  [-<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>]
; the carry out becomes the carry in of the byte above
>>
  [-<<<+>>>]
<<<

; ==== byte 13 ====
; ASSERT ptr=34
; the accumulator byte steps into the adder
<<<<<<<<<<<<<<<<<<<<<
; ASSERT ptr=13
  [->>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<]
; the addend byte follows it
>>>>>>>>>>>>>>>>>
  [->>>>>>+<<<<<<]
; add the addend into the accumulator byte
>>>>>>
; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; the carry in follows it
<<
  [->>+<<]
; add that in too
>>
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; the low byte of the sum goes back where it came from
<
  [-<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>]
; the carry out becomes the carry in of the byte above
>>
  [-<<<+>>>]
<<<

; ==== byte 14 ====
; ASSERT ptr=34
; the accumulator byte steps into the adder
<<<<<<<<<<<<<<<<<<<<
; ASSERT ptr=14
  [->>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<]
; the addend byte follows it
>>>>>>>>>>>>>>>>>
  [->>>>>+<<<<<]
; add the addend into the accumulator byte
>>>>>
; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; the carry in follows it
<<
  [->>+<<]
; add that in too
>>
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; the low byte of the sum goes back where it came from
<
  [-<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>]
; the carry out becomes the carry in of the byte above
>>
  [-<<<+>>>]
<<<

; ==== byte 15 ====
; ASSERT ptr=34
; the accumulator byte steps into the adder
<<<<<<<<<<<<<<<<<<<
; ASSERT ptr=15
  [->>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<]
; the addend byte follows it
>>>>>>>>>>>>>>>>>
  [->>>>+<<<<]
; add the addend into the accumulator byte
>>>>
; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; the carry in follows it
<<
  [->>+<<]
; add that in too
>>
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; the low byte of the sum goes back where it came from
<
  [-<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>]
; the carry out becomes the carry in of the byte above
>>
  [-<<<+>>>]
<<<

; ==== byte 16 ====
; ASSERT ptr=34
; the accumulator byte steps into the adder
<<<<<<<<<<<<<<<<<<
; ASSERT ptr=16
  [->>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<]
; the addend byte follows it
>>>>>>>>>>>>>>>>>
  [->>>+<<<]
; add the addend into the accumulator byte
>>>
; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; the carry in follows it
<<
  [->>+<<]
; add that in too
>>
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; the low byte of the sum goes back where it came from
<
  [-<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>]
; the carry out becomes the carry in of the byte above
>>
  [-<<<+>>>]
<<<

; the carry out of the top byte is dropped  and cleared so the frame is as
; empty as it was found
; ASSERT ptr=34
  [-]
; ASSERT zero 17:39
; walk back out to the routine base
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; ASSERT ptr=0
; back to the turn counter
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; continued
  >>>>>>
]
; ASSERT ptr=46
; the part above the split has been spent five times over
<<<<<<
; ASSERT ptr=40
  [-]
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; ASSERT ptr=0
; ASSERT zero 17:46
; emit the folded value little endian
  .>.>.>.>.>.>.>.>.>.>.>.>.>.>.>.>.
