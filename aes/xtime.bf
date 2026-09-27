; bfsodium XTIME : multiply a byte by x in the AES field
;
; NOTE square brackets are brainfuck loops  so comments use braces for counts;
;
; HAND WRITTEN; idiom/xor8 is PASTED once;
;
; INTERFACE entry=0 exit=0 footprint=0:21
; IO  in:  a{1}            (1 byte)
;     out: xtime(a){1}     (1 byte)
;
; FIPS 197 section 4 point 2 : the field is GF(2^8) modulo the polynomial
; x^8 plus x^4 plus x^3 plus x plus 1  which is 0x11b  and multiplying by x is
; a shift left by one followed by a conditional reduction;
;
;   xtime(a)  is  (a doubled)  xor  0x1b if the top bit of a was set
;
; THE DOUBLING NEEDS NO MASK; a cell wraps at 256 and that is exactly the
; modulo the shift wants  so doubling is one loop and no test;
;
; AND THE REDUCTION IS UNCONDITIONAL HERE; the top bit is taken as a value
; rather than as a branch  the constant 0x1b is multiplied by it  and the
; exclusive or runs whatever that came to; Exclusive or with nought is the
; identity  so the branch that FIPS 197 writes in prose costs nothing beyond
; the multiply; That is cheaper than a test and it is also constant time
; against the input  which the walk in index/fetch256 is emphatically not;
;
; TAPE MAP  (home @0)
;   @0x00:0x10  idiom/xor8 pasted at this file's own zero; its operands are
;               the doubled byte at @0x01 and the reduction at @0x02  and its
;               answer comes to rest at @0x00 which is where the answer goes
;   @0x11  ad   u8  a copy of a  spent into the doubling
;   @0x12  ah   u8  a copy of a  halved seven times down to its top bit
;   @0x13  q    u8  HALVE frame: the byte shifted right one
;   @0x14  t    u8  HALVE frame: the bit that falls off
;   @0x15  f    u8  HALVE frame scratch  restored to nought
;
; THE TOP BIT IS TAKEN BY HALVING SEVEN TIMES and keeping the quotient  which
; is the chain idiom/add8 uses for its carry and is the same code; It costs
; about twice the value and does not depend on anything else;

  ,                                                            ; read the byte
                                                               ; ASSERT ptr=0
                                                               ; ASSERT zero 1:21
  [->>>>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<<<]                    ; two copies of it  one to double and one to take the
                                                               ; top bit from
>>>>>>>>>>>>>>>>>                                              ; the doubling; the cell wraps at 256 and the wrap IS
                                                               ; the shift
                                                               ; ASSERT ptr=17
  [-<<<<<<<<<<<<<<<<++>>>>>>>>>>>>>>>>]
>                                                              ; and the top bit  by seven halvings that keep the
                                                               ; quotient
                                                               ; ASSERT ptr=18
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving one of seven; the bit that falls off is not
                                                               ; wanted
>>
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving two of seven; the bit that falls off is not
                                                               ; wanted
>>
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving three of seven; the bit that falls off is not
                                                               ; wanted
>>
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving four of seven; the bit that falls off is not
                                                               ; wanted
>>
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving five of seven; the bit that falls off is not
                                                               ; wanted
>>
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving six of seven; the bit that falls off is not
                                                               ; wanted
>>
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving seven of seven; the bit that falls off is not
                                                               ; wanted
>>
  [-]
<<
>
  [-<+>]
<
                                                               ; ASSERT ptr=18
  [-<<<<<<<<<<<<<<<<+++++++++++++++++++++++++++>>>>>>>>>>>>>   ; what is left is the top bit; the reduction constant
  >>>]                                                         ; is that bit times 0x1b
<<<<<<<<<<<<<<<<<<                                             ; home  where the exclusive or is pasted
                                                               ; ASSERT ptr=0
                                                               ; ASSERT zero 17:21
  >>                                                           ; walk in to this routine entry offset
                                                               ; beneath them
                                                               ; ASSERT ptr=2
                                                               ; ASSERT zero 0:0
                                                               ; ASSERT zero 3:16
<                                                              ; x is staged into a
                                                               ; ASSERT ptr=1
  [->>+<<]
>                                                              ; and y into b
  [->>>>>+<<<<<]
>>>>>>>>>>>>                                                   ; the weight starts at one
                                                               ; ASSERT ptr=14
  +
> ++++++++                                                     ; and there are eight bits to do
                                                               ; ASSERT ptr=15
; ============================================================ ; ; eight bit steps
  [-
  <<<<<<<<<<<< [->>>+<[-<+>>-<]>[-<+>]<<<]                     ; HALVE a  giving qa and pa
  >>>> [->>>+<[-<+>>-<]>[-<+>]<<<]                             ; HALVE b  giving qb and pb
  << [->>>>>>>+<[->-<]>[-<+>]<<<<<<<]                          ; the low bit of a toggles t
  >>>> [->>>+<[->-<]>[-<+>]<<<]                                ; the low bit of b toggles t
  >> [->>>[-<+>>>+<<]>>[-<<+>>]<<<<<]                          ; if t then res gets the weight in hand
  <<<<<<< [-<+>]                                               ; a becomes qa
  >>>> [-<+>]                                                  ; b becomes qb
  >>>>>> [->>+<<]                                              ; the weight goes into the scratch
  >> [-<<++>>]                                                 ; and comes back doubled
  <                                                            ; back to the counter
  ]
                                                               ; ASSERT ptr=15
<<                                                             ; the result comes home
                                                               ; ASSERT ptr=13
  [-<<<<<<<<<<<<<+>>>>>>>>>>>>>]
<<<<<<<<<<<<<
                                                               ; ASSERT ptr=0
                                                               ; ASSERT zero 1:16

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=0
                                                               ; ASSERT zero 1:21

; emit
  .                                                            ; the product  which is the whole of the answer
