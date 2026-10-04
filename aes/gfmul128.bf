; bfsodium GFMUL128 : multiplication in GF(2^128) as GCM defines it
; NIST SP 800_38D section 6 point 3
;
; NOTE square brackets are brainfuck loops  so comments use braces for counts;
;
; HAND WRITTEN; block/ghashmul is INCLUDED  and brings block/shr128gcm and
; block/halve with it; idiom/xor8 is PASTED once  inside it;
;
; IO  in:  X{16}  Y{16}
;     out: (X dot Y){16}
;
; THIS EXISTS TO BE PINNED  and it is the cheapest program in the AES half of
; this library: no cipher  no S box  no table; A GHASH over a long message is
; hundreds of these and a GCM is that plus the cipher  so a wrong multiply is
; a wrong tag with nothing to say which part went wrong; Here it is sixteen
; bytes in and sixteen out;
;
; AND IT CAN BE CHECKED WITHOUT AN ORACLE AT ALL  which matters because the
; standard prints no multiplication vectors; The field has laws: the identity
; in this reflected representation is 0x80 followed by fifteen noughts  the
; product with nought is nought  the operation commutes  and it distributes
; over exclusive or; The suite checks all four against this program  and
; those checks rest on no reference anyone here wrote;
;
; THE ONE PUBLISHED ANCHOR IS THE SUBKEY; GCM's H is the cipher on the zero
; block  which for the zero key is 66e94bd4ef8a2c3b884cfa59ca342b2e  a value
; four other programs in this suite already pin; So a vector multiplying that
; H is anchored at one end even though the product itself is derived;
;
; TAPE MAP  (home @0)
;   @0x00:0x0f  Z  the accumulator; the product comes back here
;   @0x10:0x1f  X  read here  and SPENT
;   @0x20:0x2f  Y  read here  and SPENT
;   @0x20:0x64  ALSO the block/shr128gcm frame  which is why Y lands at 0x20
;   @0x65:0xa4  block/ghashmul's own scratch  as its tape map lists it

>>>>>>>>>>>>>>>>                                               ; the two operands  read straight into the cells the
                                                               ; multiply wants them in
  ,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>
  ,>,>,                                                        ; continued
                                                               ; ASSERT ptr=47
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=0
                                                               ; ASSERT zero 0:15

                                                               ; MULTIPLICATION IN GF(2^128) AS GCM DEFINES IT  NIST
                                                               ; SP 800_38D Algorithm 1
;
                                                               ; Z = 0  and V = Y   for each of the 128 bits of X
                                                               ; MOST SIGNIFICANT FIRST       if the bit is set  Z
                                                               ; takes V       V shifts right one in the field
;
                                                               ; Both operands are SPENT; X is halved away to nothing
                                                               ; and Y is shifted a hundred and twenty eight times; A
                                                               ; caller that wants either again keeps a copy; GHASH
                                                               ; wants H again on every block and does exactly that;
;
                                                               ; THE FIELD IS NOT THE ONE CMAC USES even though the
                                                               ; polynomial is; GCM writes its elements BIT REFLECTED
                                                               ; so the shift goes RIGHT and reduces with 0xe1 at the
                                                               ; top; block/shr128gcm is that step and its header says
                                                               ; why it is a separate file from block/shl128 rather
                                                               ; than a parameter of it;
;
                                                               ; THE BRANCH IS NOT A BRANCH; the bit multiplies a COPY
                                                               ; of V and the exclusive or runs unconditionally
                                                               ; against that  so the work does not depend on the bit;
                                                               ; Exclusive or with nought is the identity; Same
                                                               ; argument aes/xtime makes  and the reason the cost of
                                                               ; a multiply here does not depend on its operands;
;
                                                               ; THREE CONVEYORS AND NO INDEX  which is what keeps
                                                               ; idiom/xor8 to ONE paste and block/shr128gcm to one
                                                               ; include; X gives up its head byte and slides  the
                                                               ; eight bits of that byte give up their head and slide
                                                               ; and Z gives up its head and takes a new tail; Nothing
                                                               ; is ever addressed by a computed offset;
;
                                                               ; THE BITS COME OUT BACKWARDS AND ARE STORED BACKWARDS;
                                                               ; halving a byte yields its LOW bit first  and
                                                               ; Algorithm 1 wants the HIGH bit first  so the eighth
                                                               ; halving's bit is written to the first cell of the bit
                                                               ; run and the first halving's to the last; Then the
                                                               ; conveyor reads them in the order the algorithm asks
                                                               ; for  and no reversal is needed anywhere else;
;
                                                               ; TAPE MAP  (relative to the block's own zero)
;   @0x00:0x0f  Z   the accumulator; the product comes back here
;   @0x10:0x1f  X   the bit source  SPENT
;   @0x20:0x64  the block/shr128gcm frame; V is its first sixteen cells  SPENT
;   @0x65:0x6c  B{8}   the bits of the byte in hand  high bit first
;   @0x6d:0x7c  VC{16} V multiplied by the bit  SPENT by the exclusive or
;   @0x7d:0x8c  the copy temps that keep V alive
;   @0x8d i  @0x8e j  @0x8f k   the byte  bit and exclusive or counters
;   @0x90:0x93  the block/halve frame  byte q t f
;   @0x94:0xa4  idiom/xor8 pasted at 148; result 148  operands 149 150
;
                                                               ; ASSERT ptr=0
                                                               ; ASSERT zero 0:15
                                                               ; ASSERT zero 48:164

; ============================================================ ; one turn per byte of X  sixteen of them
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>>>>>>>>>>>>>>>>>>>                                      ; continued
  ++++++++++++++++
                                                               ; ASSERT ptr=141
[
  -
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; the bit source gives up its head byte
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<                                                      ; continued
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<]                                 ; continued
>                                                              ; and the rest of it slides down
  [-<+>]
>                                                              ; the next cell
  [-<+>]
>                                                              ; the next cell
  [-<+>]
>                                                              ; the next cell
  [-<+>]
>                                                              ; the next cell
  [-<+>]
>                                                              ; the next cell
  [-<+>]
>                                                              ; the next cell
  [-<+>]
>                                                              ; the next cell
  [-<+>]
>                                                              ; the next cell
  [-<+>]
>                                                              ; the next cell
  [-<+>]
>                                                              ; the next cell
  [-<+>]
>                                                              ; the next cell
  [-<+>]
>                                                              ; the next cell
  [-<+>]
>                                                              ; the next cell
  [-<+>]
>                                                              ; the next cell
  [-<+>]

; ============================================================ ; eight halvings  and the bits are stored in reverse
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; halving 1 of eight; its bit is the one Algorithm 1
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>        ; wants last
                                                               ; HALVE  the byte at this cell  with q t and f in the
                                                               ; three cells above it; q becomes it shifted right one
                                                               ; and t the bit that fell off; the pointer comes back
                                                               ; here; CONVENTIONS section 5 carries the vocabulary
                                                               ; entry;
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>                                                             ; the bit that fell off
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>]                                       ; continued
<                                                              ; and the quotient goes back to be halved again
  [-<+>]
<                                                              ; halving 2 of eight; its bit is the one Algorithm 1
                                                               ; wants in the middle
                                                               ; HALVE  the byte at this cell  with q t and f in the
                                                               ; three cells above it; q becomes it shifted right one
                                                               ; and t the bit that fell off; the pointer comes back
                                                               ; here; CONVENTIONS section 5 carries the vocabulary
                                                               ; entry;
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>                                                             ; the bit that fell off
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>]                                     ; continued
<                                                              ; and the quotient goes back to be halved again
  [-<+>]
<                                                              ; halving 3 of eight; its bit is the one Algorithm 1
                                                               ; wants in the middle
                                                               ; HALVE  the byte at this cell  with q t and f in the
                                                               ; three cells above it; q becomes it shifted right one
                                                               ; and t the bit that fell off; the pointer comes back
                                                               ; here; CONVENTIONS section 5 carries the vocabulary
                                                               ; entry;
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>                                                             ; the bit that fell off
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>]                                   ; continued
<                                                              ; and the quotient goes back to be halved again
  [-<+>]
<                                                              ; halving 4 of eight; its bit is the one Algorithm 1
                                                               ; wants in the middle
                                                               ; HALVE  the byte at this cell  with q t and f in the
                                                               ; three cells above it; q becomes it shifted right one
                                                               ; and t the bit that fell off; the pointer comes back
                                                               ; here; CONVENTIONS section 5 carries the vocabulary
                                                               ; entry;
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>                                                             ; the bit that fell off
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>]                                 ; continued
<                                                              ; and the quotient goes back to be halved again
  [-<+>]
<                                                              ; halving 5 of eight; its bit is the one Algorithm 1
                                                               ; wants in the middle
                                                               ; HALVE  the byte at this cell  with q t and f in the
                                                               ; three cells above it; q becomes it shifted right one
                                                               ; and t the bit that fell off; the pointer comes back
                                                               ; here; CONVENTIONS section 5 carries the vocabulary
                                                               ; entry;
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>                                                             ; the bit that fell off
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>]                               ; continued
<                                                              ; and the quotient goes back to be halved again
  [-<+>]
<                                                              ; halving 6 of eight; its bit is the one Algorithm 1
                                                               ; wants in the middle
                                                               ; HALVE  the byte at this cell  with q t and f in the
                                                               ; three cells above it; q becomes it shifted right one
                                                               ; and t the bit that fell off; the pointer comes back
                                                               ; here; CONVENTIONS section 5 carries the vocabulary
                                                               ; entry;
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>                                                             ; the bit that fell off
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]                             ; continued
<                                                              ; and the quotient goes back to be halved again
  [-<+>]
<                                                              ; halving 7 of eight; its bit is the one Algorithm 1
                                                               ; wants in the middle
                                                               ; HALVE  the byte at this cell  with q t and f in the
                                                               ; three cells above it; q becomes it shifted right one
                                                               ; and t the bit that fell off; the pointer comes back
                                                               ; here; CONVENTIONS section 5 carries the vocabulary
                                                               ; entry;
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>                                                             ; the bit that fell off
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]                           ; continued
<                                                              ; and the quotient goes back to be halved again
  [-<+>]
<                                                              ; halving 8 of eight; its bit is the one Algorithm 1
                                                               ; wants first
                                                               ; HALVE  the byte at this cell  with q t and f in the
                                                               ; three cells above it; q becomes it shifted right one
                                                               ; and t the bit that fell off; the pointer comes back
                                                               ; here; CONVENTIONS section 5 carries the vocabulary
                                                               ; entry;
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>                                                             ; the bit that fell off
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]                         ; continued
<                                                              ; and the quotient goes back to be halved again
  [-<+>]
<
                                                               ; ASSERT ptr=144

; ============================================================ ; one turn per bit  eight of them  high bit first
<<
  ++++++++
                                                               ; ASSERT ptr=142
[
  -
                                                               ; the bit multiplies a COPY of V; if it is nought the
                                                               ; copy does not happen and the exclusive or below runs
                                                               ; against sixteen clear cells
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  [
  [-]
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<                                                    ; continued
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>+>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<]                                            ; continued
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>                            ; continued
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>>>>>>>>>>>]                                             ; continued
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<                            ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>+>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<]                                            ; continued
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>                            ; continued
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>>>>>>>>>>>]                                             ; continued
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<                            ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>+>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<]                                            ; continued
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>                            ; continued
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>>>>>>>>>>>]                                             ; continued
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<                            ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>+>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<]                                            ; continued
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>                            ; continued
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>>>>>>>>>>>]                                             ; continued
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<                            ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>+>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<]                                            ; continued
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>                            ; continued
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>>>>>>>>>>>]                                             ; continued
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<                            ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>+>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<]                                            ; continued
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>                            ; continued
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>>>>>>>>>>>]                                             ; continued
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<                            ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>+>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<]                                            ; continued
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>                            ; continued
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>>>>>>>>>>>]                                             ; continued
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<                            ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>+>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<]                                            ; continued
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>                            ; continued
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>>>>>>>>>>>]                                             ; continued
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<                            ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>+>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<]                                            ; continued
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>                            ; continued
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>>>>>>>>>>>]                                             ; continued
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<                            ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>+>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<]                                            ; continued
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>                            ; continued
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>>>>>>>>>>>]                                             ; continued
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<                            ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>+>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<]                                            ; continued
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>                            ; continued
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>>>>>>>>>>>]                                             ; continued
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<                            ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>+>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<]                                            ; continued
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>                            ; continued
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>>>>>>>>>>>]                                             ; continued
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<                            ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>+>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<]                                            ; continued
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>                            ; continued
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>>>>>>>>>>>]                                             ; continued
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<                            ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>+>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<]                                            ; continued
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>                            ; continued
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>>>>>>>>>>>]                                             ; continued
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<                            ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>+>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<]                                            ; continued
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>                            ; continued
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>>>>>>>>>>>]                                             ; continued
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<                            ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>+>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<]                                            ; continued
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>                            ; continued
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>>>>>>>>>>>]                                             ; continued
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<                            ; continued
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
>                                                              ; the bits slide down so the next one is again at the
                                                               ; head
  [-<+>]
>                                                              ; the next cell
  [-<+>]
>                                                              ; the next cell
  [-<+>]
>                                                              ; the next cell
  [-<+>]
>                                                              ; the next cell
  [-<+>]
>                                                              ; the next cell
  [-<+>]
>                                                              ; the next cell
  [-<+>]

; ============================================================ ; Z takes it  sixteen turns on two conveyors
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ++++++++++++++++
                                                               ; ASSERT ptr=143
[
  -
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; Z gives up its head
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<                                    ; continued
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<]                                                 ; continued
>                                                              ; and slides  leaving its tail for the answer
  [-<+>]
>                                                              ; the next cell
  [-<+>]
>                                                              ; the next cell
  [-<+>]
>                                                              ; the next cell
  [-<+>]
>                                                              ; the next cell
  [-<+>]
>                                                              ; the next cell
  [-<+>]
>                                                              ; the next cell
  [-<+>]
>                                                              ; the next cell
  [-<+>]
>                                                              ; the next cell
  [-<+>]
>                                                              ; the next cell
  [-<+>]
>                                                              ; the next cell
  [-<+>]
>                                                              ; the next cell
  [-<+>]
>                                                              ; the next cell
  [-<+>]
>                                                              ; the next cell
  [-<+>]
>                                                              ; the next cell
  [-<+>]
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; and the multiplied copy gives up its head
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>                           ; continued
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<]                                 ; continued
>                                                              ; and slides too  which empties it for the next bit
  [-<+>]
>                                                              ; the next cell
  [-<+>]
>                                                              ; the next cell
  [-<+>]
>                                                              ; the next cell
  [-<+>]
>                                                              ; the next cell
  [-<+>]
>                                                              ; the next cell
  [-<+>]
>                                                              ; the next cell
  [-<+>]
>                                                              ; the next cell
  [-<+>]
>                                                              ; the next cell
  [-<+>]
>                                                              ; the next cell
  [-<+>]
>                                                              ; the next cell
  [-<+>]
>                                                              ; the next cell
  [-<+>]
>                                                              ; the next cell
  [-<+>]
>                                                              ; the next cell
  [-<+>]
>                                                              ; the next cell
  [-<+>]
>>>>>>>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=148
                                                               ; ASSERT zero 151:164
  >>                                                           ; walk in to this routine entry offset
                                                               ; beneath them
                                                               ; ASSERT ptr=150
                                                               ; ASSERT zero 148:148
                                                               ; ASSERT zero 151:164
<                                                              ; x is staged into a
                                                               ; ASSERT ptr=149
  [->>+<<]
>                                                              ; and y into b
  [->>>>>+<<<<<]
>>>>>>>>>>>>                                                   ; the weight starts at one
                                                               ; ASSERT ptr=162
  +
> ++++++++                                                     ; and there are eight bits to do
                                                               ; ASSERT ptr=163
; ============================================================ ; ; eight bit steps
                                                               ; the kernel is a block now  and idiom/xor32 and
                                                               ; idiom/xor64 carry the same one inline; building those
                                                               ; two on it is held out of this rebuild and recorded in
                                                               ; HANDOFF rather than forgotten; THE EIGHT BIT STEPS OF
                                                               ; AN EXCLUSIVE OR  entered at cnt with the fourteen
                                                               ; cell frame below it: a qa pa fa b qb pb fb t ft res p
                                                               ; cnt tmp; a and b are halved away  t ends as the
                                                               ; exclusive or of each bit pair  and res gathers the
                                                               ; weight whenever t is set; CONVENTIONS section 5
                                                               ; carries the entry;
;
                                                               ; THIS IS THE KERNEL idiom/xor32 and idiom/xor64 also
                                                               ; carry  down to the character; they are not yet built
                                                               ; on it  which HANDOFF records as held out of the
                                                               ; rebuild rather than forgotten;
  [-
  <<<<<<<<<<<<                                                 ; HALVE a  giving qa and pa
                                                               ; HALVE  the byte at this cell  with q t and f in the
                                                               ; three cells above it; q becomes it shifted right one
                                                               ; and t the bit that fell off; the pointer comes back
                                                               ; here; CONVENTIONS section 5 carries the vocabulary
                                                               ; entry;
  [->>>+<[-<+>>-<]>[-<+>]<<<]
  >>>>                                                         ; HALVE b  giving qb and pb
                                                               ; HALVE  the byte at this cell  with q t and f in the
                                                               ; three cells above it; q becomes it shifted right one
                                                               ; and t the bit that fell off; the pointer comes back
                                                               ; here; CONVENTIONS section 5 carries the vocabulary
                                                               ; entry;
  [->>>+<[-<+>>-<]>[-<+>]<<<]
  << [->>>>>>>+<[->-<]>[-<+>]<<<<<<<]                          ; the low bit of a toggles t
  >>>> [->>>+<[->-<]>[-<+>]<<<]                                ; the low bit of b toggles t
  >> [->>>[-<+>>>+<<]>>[-<<+>>]<<<<<]                          ; if t then res gets the weight in hand
  <<<<<<< [-<+>]                                               ; a becomes qa
  >>>> [-<+>]                                                  ; b becomes qb
  >>>>>> [->>+<<]                                              ; the weight goes into the scratch
  >> [-<<++>>]                                                 ; and comes back doubled
  <                                                            ; back to the counter
  ]
                                                               ; ASSERT ptr=163
<<                                                             ; the result comes home
                                                               ; ASSERT ptr=161
  [-<<<<<<<<<<<<<+>>>>>>>>>>>>>]
<<<<<<<<<<<<<
                                                               ; ASSERT ptr=148
                                                               ; ASSERT zero 149:164

                                                               ; walk back out to the routine base

  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; and Z takes the tail
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]                       ; continued
<<<<<
                                                               ; ASSERT ptr=143
]

; ============================================================ ; and V shifts right one in the field
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<          ; continued
                                                               ; ASSERT ptr=32
                                                               ; A 128 BIT VALUE SHIFTED RIGHT ONE BIT IN THE FIELD
                                                               ; GCM USES  reducing by 0xe1 at the TOP when the bit
                                                               ; that falls off the END was set;
;
                                                               ; NIST SP 800_38D section 6 point 3  the inner step of
                                                               ; Algorithm 1;
;
                                                               ; THIS IS NOT block/shl128 AND IT IS NOT A REUSE OF IT;
                                                               ; GCM's field is the same polynomial as CMAC's but
                                                               ; written BIT REFLECTED  so where that one shifts LEFT
                                                               ; and reduces with 0x87 into the LAST byte  this one
                                                               ; shifts RIGHT and reduces with 0xe1 into the FIRST;
                                                               ; The two are mirror images and sharing text between
                                                               ; them would mean parameterising a direction  which an
                                                               ; include offset cannot do and which block/moveup16's
                                                               ; header records from the other side; Two files  and
                                                               ; the field laws in the suite are what keep them
                                                               ; honest;
;
                                                               ; IN PLACE; the value goes in at cell nought through
                                                               ; fifteen  big endian  and the answer comes back there;
                                                               ; Everything above is scratch and left clear;
;
                                                               ; A BYTE SHIFTED RIGHT IS block/halve  which hands back
                                                               ; the quotient AND the bit that fell off  so one pass
                                                               ; over the sixteen bytes produces both halves of what
                                                               ; the shift needs: the new bytes  and the bits that
                                                               ; have to travel one place up into the byte before;
;
                                                               ; THE REDUCTION IS UNCONDITIONAL  for the reason
                                                               ; aes/xtime gives: the bit that fell off the whole
                                                               ; value is taken as a VALUE  0xe1 is multiplied by it
                                                               ; and the exclusive or runs whatever that came to;
;
                                                               ; TAPE MAP  (relative to the block's own zero)
;   @0x00:0x0f  v  the value  big endian  the byte at nought most significant
;   @0x10:0x1f  q  each byte shifted right one
;   @0x20:0x2f  p  each bit that fell off; the one at 0x2f is the reduction
;   @0x30:0x33  the block/halve frame  byte q t f
;   @0x34:0x44  idiom/xor8 pasted at 0x34; result 0x34  operands 0x35 0x36
;
                                                               ; ASSERT ptr=32
                                                               ; ASSERT zero 48:100

; ============================================================ ; every byte is halved  which gives the new byte and
                                                               ; the bit below
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<   ; byte 0 of sixteen
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]                   ; continued
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                                                               ; HALVE  the byte at this cell  with q t and f in the
                                                               ; three cells above it; q becomes it shifted right one
                                                               ; and t the bit that fell off; the pointer comes back
                                                               ; here; CONVENTIONS section 5 carries the vocabulary
                                                               ; entry;
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>                                                              ; the quotient is the byte's new value
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>]                                                 ; continued
>                                                              ; and the bit that fell off travels up to the byte
                                                               ; before it
  [-<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>]
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<              ; byte 1 of sixteen
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]                     ; continued
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                                                               ; HALVE  the byte at this cell  with q t and f in the
                                                               ; three cells above it; q becomes it shifted right one
                                                               ; and t the bit that fell off; the pointer comes back
                                                               ; here; CONVENTIONS section 5 carries the vocabulary
                                                               ; entry;
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>                                                              ; the quotient is the byte's new value
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>]                                                   ; continued
>                                                              ; and the bit that fell off travels up to the byte
                                                               ; before it
  [-<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>]
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<               ; byte 2 of sixteen
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]                       ; continued
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                                                               ; HALVE  the byte at this cell  with q t and f in the
                                                               ; three cells above it; q becomes it shifted right one
                                                               ; and t the bit that fell off; the pointer comes back
                                                               ; here; CONVENTIONS section 5 carries the vocabulary
                                                               ; entry;
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>                                                              ; the quotient is the byte's new value
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>]                                                     ; continued
>                                                              ; and the bit that fell off travels up to the byte
                                                               ; before it
  [-<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>]
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<                ; byte 3 of sixteen
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]                         ; continued
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                                                               ; HALVE  the byte at this cell  with q t and f in the
                                                               ; three cells above it; q becomes it shifted right one
                                                               ; and t the bit that fell off; the pointer comes back
                                                               ; here; CONVENTIONS section 5 carries the vocabulary
                                                               ; entry;
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>                                                              ; the quotient is the byte's new value
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>]                                                       ; continued
>                                                              ; and the bit that fell off travels up to the byte
                                                               ; before it
  [-<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>]
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<                 ; byte 4 of sixteen
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]                           ; continued
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                                                               ; HALVE  the byte at this cell  with q t and f in the
                                                               ; three cells above it; q becomes it shifted right one
                                                               ; and t the bit that fell off; the pointer comes back
                                                               ; here; CONVENTIONS section 5 carries the vocabulary
                                                               ; entry;
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>                                                              ; the quotient is the byte's new value
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>]                                                         ; continued
>                                                              ; and the bit that fell off travels up to the byte
                                                               ; before it
  [-<<<<<<<<<<<<<<+>>>>>>>>>>>>>>]
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<                  ; byte 5 of sixteen
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]                             ; continued
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                                                               ; HALVE  the byte at this cell  with q t and f in the
                                                               ; three cells above it; q becomes it shifted right one
                                                               ; and t the bit that fell off; the pointer comes back
                                                               ; here; CONVENTIONS section 5 carries the vocabulary
                                                               ; entry;
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>                                                              ; the quotient is the byte's new value
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >]                                                           ; continued
>                                                              ; and the bit that fell off travels up to the byte
                                                               ; before it
  [-<<<<<<<<<<<<<+>>>>>>>>>>>>>]
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<                   ; byte 6 of sixteen
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<]                               ; continued
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                                                               ; HALVE  the byte at this cell  with q t and f in the
                                                               ; three cells above it; q becomes it shifted right one
                                                               ; and t the bit that fell off; the pointer comes back
                                                               ; here; CONVENTIONS section 5 carries the vocabulary
                                                               ; entry;
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>                                                              ; the quotient is the byte's new value
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>>]
>                                                              ; and the bit that fell off travels up to the byte
                                                               ; before it
  [-<<<<<<<<<<<<+>>>>>>>>>>>>]
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<                    ; byte 7 of sixteen
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<]                                 ; continued
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                                                               ; HALVE  the byte at this cell  with q t and f in the
                                                               ; three cells above it; q becomes it shifted right one
                                                               ; and t the bit that fell off; the pointer comes back
                                                               ; here; CONVENTIONS section 5 carries the vocabulary
                                                               ; entry;
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>                                                              ; the quotient is the byte's new value
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>]
>                                                              ; and the bit that fell off travels up to the byte
                                                               ; before it
  [-<<<<<<<<<<<+>>>>>>>>>>>]
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<                     ; byte 8 of sixteen
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<]                                   ; continued
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                                                               ; HALVE  the byte at this cell  with q t and f in the
                                                               ; three cells above it; q becomes it shifted right one
                                                               ; and t the bit that fell off; the pointer comes back
                                                               ; here; CONVENTIONS section 5 carries the vocabulary
                                                               ; entry;
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>                                                              ; the quotient is the byte's new value
  [-<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>]
>                                                              ; and the bit that fell off travels up to the byte
                                                               ; before it
  [-<<<<<<<<<<+>>>>>>>>>>]
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<                      ; byte 9 of sixteen
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<]                                     ; continued
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                                                               ; HALVE  the byte at this cell  with q t and f in the
                                                               ; three cells above it; q becomes it shifted right one
                                                               ; and t the bit that fell off; the pointer comes back
                                                               ; here; CONVENTIONS section 5 carries the vocabulary
                                                               ; entry;
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>                                                              ; the quotient is the byte's new value
  [-<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>]
>                                                              ; and the bit that fell off travels up to the byte
                                                               ; before it
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<                       ; byte 10 of sixteen
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<]                                       ; continued
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                                                               ; HALVE  the byte at this cell  with q t and f in the
                                                               ; three cells above it; q becomes it shifted right one
                                                               ; and t the bit that fell off; the pointer comes back
                                                               ; here; CONVENTIONS section 5 carries the vocabulary
                                                               ; entry;
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>                                                              ; the quotient is the byte's new value
  [-<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>]
>                                                              ; and the bit that fell off travels up to the byte
                                                               ; before it
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<                        ; byte 11 of sixteen
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<]                                         ; continued
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                                                               ; HALVE  the byte at this cell  with q t and f in the
                                                               ; three cells above it; q becomes it shifted right one
                                                               ; and t the bit that fell off; the pointer comes back
                                                               ; here; CONVENTIONS section 5 carries the vocabulary
                                                               ; entry;
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>                                                              ; the quotient is the byte's new value
  [-<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>]
>                                                              ; and the bit that fell off travels up to the byte
                                                               ; before it
  [-<<<<<<<+>>>>>>>]
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<                         ; byte 12 of sixteen
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<]                                           ; continued
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                                                               ; HALVE  the byte at this cell  with q t and f in the
                                                               ; three cells above it; q becomes it shifted right one
                                                               ; and t the bit that fell off; the pointer comes back
                                                               ; here; CONVENTIONS section 5 carries the vocabulary
                                                               ; entry;
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>                                                              ; the quotient is the byte's new value
  [-<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>]
>                                                              ; and the bit that fell off travels up to the byte
                                                               ; before it
  [-<<<<<<+>>>>>>]
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<                          ; byte 13 of sixteen
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<]                                             ; continued
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                                                               ; HALVE  the byte at this cell  with q t and f in the
                                                               ; three cells above it; q becomes it shifted right one
                                                               ; and t the bit that fell off; the pointer comes back
                                                               ; here; CONVENTIONS section 5 carries the vocabulary
                                                               ; entry;
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>                                                              ; the quotient is the byte's new value
  [-<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>]
>                                                              ; and the bit that fell off travels up to the byte
                                                               ; before it
  [-<<<<<+>>>>>]
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<                           ; byte 14 of sixteen
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<]                                               ; continued
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                                                               ; HALVE  the byte at this cell  with q t and f in the
                                                               ; three cells above it; q becomes it shifted right one
                                                               ; and t the bit that fell off; the pointer comes back
                                                               ; here; CONVENTIONS section 5 carries the vocabulary
                                                               ; entry;
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>                                                              ; the quotient is the byte's new value
  [-<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>]
>                                                              ; and the bit that fell off travels up to the byte
                                                               ; before it
  [-<<<<+>>>>]
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<                            ; byte 15 of sixteen
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<]                                                 ; continued
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                                                               ; HALVE  the byte at this cell  with q t and f in the
                                                               ; three cells above it; q becomes it shifted right one
                                                               ; and t the bit that fell off; the pointer comes back
                                                               ; here; CONVENTIONS section 5 carries the vocabulary
                                                               ; entry;
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>                                                              ; the quotient is the byte's new value
  [-<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>]
>                                                              ; and the bit that fell off travels up to the byte
                                                               ; before it
  [-<<<+>>>]

; ============================================================ ; the new bytes go back into place
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<                             ; byte 0
  [-<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>]
>                                                              ; byte 1
  [-<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>]
>                                                              ; byte 2
  [-<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>]
>                                                              ; byte 3
  [-<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>]
>                                                              ; byte 4
  [-<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>]
>                                                              ; byte 5
  [-<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>]
>                                                              ; byte 6
  [-<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>]
>                                                              ; byte 7
  [-<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>]
>                                                              ; byte 8
  [-<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>]
>                                                              ; byte 9
  [-<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>]
>                                                              ; byte 10
  [-<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>]
>                                                              ; byte 11
  [-<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>]
>                                                              ; byte 12
  [-<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>]
>                                                              ; byte 13
  [-<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>]
>                                                              ; byte 14
  [-<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>]
>                                                              ; byte 15
  [-<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>]

; ============================================================ ; and each takes the bit that fell out of the byte
                                                               ; after it
                                                               ; the bit is nought or one  so the guard runs at most
                                                               ; once and adds the weight of the top bit; the offset
                                                               ; is the same for every byte  which is what the tape
                                                               ; map was laid out to make true the bit from byte 0
                                                               ; joins byte 1
>
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    +++++++++++++++++++++++++++++++++++++++++++++
    +++++++++++++++++++++++++++++++++++++++++++++
    ++++++++++++++++++++++++++++++++++++++
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]
>                                                              ; the bit from byte 1 joins byte 2
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    +++++++++++++++++++++++++++++++++++++++++++++
    +++++++++++++++++++++++++++++++++++++++++++++
    ++++++++++++++++++++++++++++++++++++++
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]
>                                                              ; the bit from byte 2 joins byte 3
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    +++++++++++++++++++++++++++++++++++++++++++++
    +++++++++++++++++++++++++++++++++++++++++++++
    ++++++++++++++++++++++++++++++++++++++
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]
>                                                              ; the bit from byte 3 joins byte 4
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    +++++++++++++++++++++++++++++++++++++++++++++
    +++++++++++++++++++++++++++++++++++++++++++++
    ++++++++++++++++++++++++++++++++++++++
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]
>                                                              ; the bit from byte 4 joins byte 5
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    +++++++++++++++++++++++++++++++++++++++++++++
    +++++++++++++++++++++++++++++++++++++++++++++
    ++++++++++++++++++++++++++++++++++++++
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]
>                                                              ; the bit from byte 5 joins byte 6
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    +++++++++++++++++++++++++++++++++++++++++++++
    +++++++++++++++++++++++++++++++++++++++++++++
    ++++++++++++++++++++++++++++++++++++++
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]
>                                                              ; the bit from byte 6 joins byte 7
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    +++++++++++++++++++++++++++++++++++++++++++++
    +++++++++++++++++++++++++++++++++++++++++++++
    ++++++++++++++++++++++++++++++++++++++
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]
>                                                              ; the bit from byte 7 joins byte 8
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    +++++++++++++++++++++++++++++++++++++++++++++
    +++++++++++++++++++++++++++++++++++++++++++++
    ++++++++++++++++++++++++++++++++++++++
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]
>                                                              ; the bit from byte 8 joins byte 9
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    +++++++++++++++++++++++++++++++++++++++++++++
    +++++++++++++++++++++++++++++++++++++++++++++
    ++++++++++++++++++++++++++++++++++++++
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]
>                                                              ; the bit from byte 9 joins byte 10
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    +++++++++++++++++++++++++++++++++++++++++++++
    +++++++++++++++++++++++++++++++++++++++++++++
    ++++++++++++++++++++++++++++++++++++++
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]
>                                                              ; the bit from byte 10 joins byte 11
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    +++++++++++++++++++++++++++++++++++++++++++++
    +++++++++++++++++++++++++++++++++++++++++++++
    ++++++++++++++++++++++++++++++++++++++
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]
>                                                              ; the bit from byte 11 joins byte 12
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    +++++++++++++++++++++++++++++++++++++++++++++
    +++++++++++++++++++++++++++++++++++++++++++++
    ++++++++++++++++++++++++++++++++++++++
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]
>                                                              ; the bit from byte 12 joins byte 13
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    +++++++++++++++++++++++++++++++++++++++++++++
    +++++++++++++++++++++++++++++++++++++++++++++
    ++++++++++++++++++++++++++++++++++++++
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]
>                                                              ; the bit from byte 13 joins byte 14
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    +++++++++++++++++++++++++++++++++++++++++++++
    +++++++++++++++++++++++++++++++++++++++++++++
    ++++++++++++++++++++++++++++++++++++++
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]
>                                                              ; the bit from byte 14 joins byte 15
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    +++++++++++++++++++++++++++++++++++++++++++++
    +++++++++++++++++++++++++++++++++++++++++++++
    ++++++++++++++++++++++++++++++++++++++
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]

; ============================================================ ; the bit that fell off the WHOLE value is the
                                                               ; reduction
                                                               ; it is not tested; 0xe1 is multiplied by it  so the
                                                               ; exclusive or below runs against 0xe1 or against
                                                               ; nought and costs the same either way
>
  [->>>>>>
    +++++++++++++++++++++++++++++++++++++++++++++
    +++++++++++++++++++++++++++++++++++++++++++++
    +++++++++++++++++++++++++++++++++++++++++++++
    +++++++++++++++++++++++++++++++++++++++++++++
    +++++++++++++++++++++++++++++++++++++++++++++
  <<<<<<]

; ============================================================ ; and the first byte takes it
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]       ; continued
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=84
                                                               ; ASSERT zero 87:100
  >>                                                           ; walk in to this routine entry offset
                                                               ; beneath them
                                                               ; ASSERT ptr=86
                                                               ; ASSERT zero 84:84
                                                               ; ASSERT zero 87:100
<                                                              ; x is staged into a
                                                               ; ASSERT ptr=85
  [->>+<<]
>                                                              ; and y into b
  [->>>>>+<<<<<]
>>>>>>>>>>>>                                                   ; the weight starts at one
                                                               ; ASSERT ptr=98
  +
> ++++++++                                                     ; and there are eight bits to do
                                                               ; ASSERT ptr=99
; ============================================================ ; ; eight bit steps
                                                               ; the kernel is a block now  and idiom/xor32 and
                                                               ; idiom/xor64 carry the same one inline; building those
                                                               ; two on it is held out of this rebuild and recorded in
                                                               ; HANDOFF rather than forgotten; THE EIGHT BIT STEPS OF
                                                               ; AN EXCLUSIVE OR  entered at cnt with the fourteen
                                                               ; cell frame below it: a qa pa fa b qb pb fb t ft res p
                                                               ; cnt tmp; a and b are halved away  t ends as the
                                                               ; exclusive or of each bit pair  and res gathers the
                                                               ; weight whenever t is set; CONVENTIONS section 5
                                                               ; carries the entry;
;
                                                               ; THIS IS THE KERNEL idiom/xor32 and idiom/xor64 also
                                                               ; carry  down to the character; they are not yet built
                                                               ; on it  which HANDOFF records as held out of the
                                                               ; rebuild rather than forgotten;
  [-
  <<<<<<<<<<<<                                                 ; HALVE a  giving qa and pa
                                                               ; HALVE  the byte at this cell  with q t and f in the
                                                               ; three cells above it; q becomes it shifted right one
                                                               ; and t the bit that fell off; the pointer comes back
                                                               ; here; CONVENTIONS section 5 carries the vocabulary
                                                               ; entry;
  [->>>+<[-<+>>-<]>[-<+>]<<<]
  >>>>                                                         ; HALVE b  giving qb and pb
                                                               ; HALVE  the byte at this cell  with q t and f in the
                                                               ; three cells above it; q becomes it shifted right one
                                                               ; and t the bit that fell off; the pointer comes back
                                                               ; here; CONVENTIONS section 5 carries the vocabulary
                                                               ; entry;
  [->>>+<[-<+>>-<]>[-<+>]<<<]
  << [->>>>>>>+<[->-<]>[-<+>]<<<<<<<]                          ; the low bit of a toggles t
  >>>> [->>>+<[->-<]>[-<+>]<<<]                                ; the low bit of b toggles t
  >> [->>>[-<+>>>+<<]>>[-<<+>>]<<<<<]                          ; if t then res gets the weight in hand
  <<<<<<< [-<+>]                                               ; a becomes qa
  >>>> [-<+>]                                                  ; b becomes qb
  >>>>>> [->>+<<]                                              ; the weight goes into the scratch
  >> [-<<++>>]                                                 ; and comes back doubled
  <                                                            ; back to the counter
  ]
                                                               ; ASSERT ptr=99
<<                                                             ; the result comes home
                                                               ; ASSERT ptr=97
  [-<<<<<<<<<<<<<+>>>>>>>>>>>>>]
<<<<<<<<<<<<<
                                                               ; ASSERT ptr=84
                                                               ; ASSERT zero 85:100

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=84
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]           ; continued
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=32
                                                               ; ASSERT zero 48:100
                                                               ; ASSERT ptr=32
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>           ; continued
                                                               ; ASSERT ptr=142
]
<
                                                               ; ASSERT ptr=141
]
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<                                      ; continued
                                                               ; ASSERT ptr=0
                                                               ; X is spent to nothing and V has been shifted a
                                                               ; hundred and twenty eight times; neither is claimed to
                                                               ; hold anything in particular  but everything this
                                                               ; block used as scratch is clear
                                                               ; ASSERT zero 101:140
                                                               ; ASSERT zero 141:164
                                                               ; ASSERT ptr=0

; emit
  .>.>.>.>.>.>.>.>.>.>.>.>.>.>.>.
