; bfsodium MULMOD136 : (a times b) modulo p = 2^130 minus 5
;
; HAND WRITTEN; double and add  lowest bit of b first; acc starts at nought and
; t starts at a  and on each of the 136 turns: if b's low bit is set then acc
; gains t  t doubles  and b shifts down one; After 136 turns every bit of b has
; had its say  and one reduction at the end brings the answer below p;
;
; INTERFACE entry=34 exit=0 footprint=0:124
; IO  in:  a{17} LE  followed by  b{17} LE     (34 bytes)
;     out: (a times b mod p){17} LE            (17 bytes)
;
; TAPE MAP  (home @0)
;   @0x00:0x10  acc{17}  the answer being accumulated; it is ALSO add136's
;                        accumulator  fold136's value and reducep136's value
;                        because each of those is pasted at cell nought
;   @0x11:0x21  b{17}    add136's addend  which the adder spends to nought
;   @0x22:0x32  tmp{17}  hands the running double back after it has been copied;
;               these same cells are add136's own carry frame at @0x22:0x2d and
;               the rest of fold136's frame above it  which is WHY the double is
;               put back before the adder is entered rather than after
;               (reducep136 pasted at nought reaches @0x68  and everything up to
;               there is clear of other business by the time it runs)
;   @0x33:0x43  t{17}    a doubled once per turn  folded each time
;   @0x44:0x65  the frame the pastes over t share: dbl136 at @0x33 reaches
;               @0x4b and fold136 at @0x33 reaches @0x65
;   @0x66:0x76  bv{17}   b  slid down one BYTE per eight turns until it is gone
;   @0x77       cur      the byte of b being spent  halved once per turn
;   @0x78       q        HALVE frame: cur shifted right one
;   @0x79       bit      HALVE frame: cur's low bit  which is b's bit
;   @0x7a       f        HALVE frame scratch  restored to nought
;   @0x7b       bitn     eight turns  one per bit of the byte in hand
;   @0x7c       byten    seventeen turns  one per byte of b
;
; NOTHING IS CARRIED TO A WORK FRAME AND BACK  and that is the whole of this
; file's cost; A paste site names the cell its routine's zero lands on  and
; every site is its own copy of the code  so the double and the fold over t are
; pasted AT t  and the add  the fold and the reduction over acc are pasted AT
; acc; The only seventeen byte moves left inside the loop are t into add136's
; addend slot and t back out of the cell that kept it  thirty four cells and
; seventeen cells  where the work frame version moved everything two hundred
; and twenty;
;
; MEASURED  on the large vector: the version that kept one work frame at cell
; nought and carried both operands to it spent 527 of its 996 million
; instructions on those carries alone  because a move costs about twice the
; DISTANCE for every unit of the byte's value; A hundred and seventeen million
; more went on shifting b right one bit per turn  which is why b is now walked
; a byte at a time and only the byte in hand is halved;
;
; THE TURNS ARE NESTED  seventeen bytes of eight bits rather than 136 flat  and
; that is what makes the fold on acc affordable: acc is folded ONCE PER BYTE
; instead of once per set bit; Eight turns can each add a t under 2^130 plus
; 315  so acc stays under 2^134 between folds and seventeen bytes hold 2^136;
; t is still folded every turn  because doubling an unfolded value would lose
; its top bit;
;
; a is folded ONCE before the loop; it arrives as any seventeen byte value  and
; doubling one of those would lose its top bit;
;
; The seventeen byte moves and the slide below are written as REPETITIONS of one
; token  the way sha512/hashcore writes its long runs; every distance in them is
; a number worked out from the map above;

  ,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>   ; read a{0:16} then b{0:16}  leaving the pointer past
  ,>,>,>,>,>                                                   ; both
                                                               ; ASSERT ptr=34
                                                               ; ASSERT zero 34:124
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<                             ; to the head of a
                                                               ; ASSERT ptr=0

; ============================================================ ; a becomes the running double  and b the multiplier
                                                               ; each in its own
; ============================================================ ; place  so that nothing needs carrying once the loop
                                                               ; starts
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]             ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]             ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]             ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]             ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]             ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]             ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]             ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]             ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]             ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]             ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]             ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]             ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]             ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]             ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]             ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]             ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]             ; continued
                                                               ; ASSERT ptr=16
>                                                              ; to the head of b
                                                               ; ASSERT ptr=17
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]   ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]   ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]   ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]   ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]   ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]   ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]   ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]   ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]   ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]   ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]   ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]   ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]   ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]   ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]   ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]   ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]   ; continued
                                                               ; ASSERT ptr=33

; ============================================================ ; a is folded once  because the doubling below would
                                                               ; lose its top bit
>>>>>>>>>>>>>>>>>>                                             ; to the running double
                                                               ; ASSERT ptr=51
                                                               ; ASSERT zero 68:101
  >>>>>>>>>>>>>>>>                                             ; walk in to this routine entry offset

; ============================================================ ; ; split the top byte at bit 130
                                                               ; ASSERT ptr=67
                                                               ; ASSERT zero 68:85
  [->>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<]                           ; the top byte steps into the halving frame
>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=82
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; the first halving; the bit it drops is bit 128
>>                                                             ; which is worth one in what is left below the split
                                                               ; ASSERT ptr=84
  [-<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>]
<                                                              ; the half steps back into the frame to be halved again
                                                               ; ASSERT ptr=83
  [-<+>]
<
                                                               ; ASSERT ptr=82
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; the second halving; the bit it drops is bit 129
>>                                                             ; which is worth two
                                                               ; ASSERT ptr=84
  [-<<<<<<<<<<<<<<<<<++>>>>>>>>>>>>>>>>>]
<                                                              ; and what is left in the quotient is everything at bit
                                                               ; 130 and above
                                                               ; ASSERT ptr=83
  [-<<+>>]

; ============================================================ ; ; two to the hundred and thirtieth is five  so five
                                                               ; times that part
<<                                                             ; to the part above the split
                                                               ; ASSERT ptr=81
                                                               ; it is spent ONCE  into four copies of itself and one
                                                               ; copy of itself  which is where the five comes from;
                                                               ; neither cell can wrap  because four times sixty three
                                                               ; is two hundred and fifty two
  [-<<<<<<<<<<<<<++++>+>>>>>>>>>>>>]
                                                               ; ASSERT ptr=81
<<<<<<<<<<<<<                                                  ; to the byte pair the eight bit adder works on
                                                               ; ASSERT ptr=68
                                                               ; ASSERT zero 70:78
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=69
                                                               ; ASSERT zero 71:78
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=68
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=71
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=69
  [->>+<<]
>>
                                                               ; ASSERT ptr=71
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=75
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=78
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=76
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=73
  [-[[-]>>>>+<<<<]]
; ============================================================ ; ; ; the carry out is bit 7 of that  and nothing else
>>>>
                                                               ; ASSERT ptr=77
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=71
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 1 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 2 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 3 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 4 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 5 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 6 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 7 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
                                                               ; ASSERT ptr=71
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ============================================================ ; ; ; the sum is twice the halves plus the two low bits
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=75
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=76
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=68
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 69:69
                                                               ; ASSERT zero 71:78

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=68
  [->>>>>>>>>>>+<<<<<<<<<<<]                                   ; the sum is five times H modulo 256  and it is the
                                                               ; addend's low byte
>>                                                             ; to the carry add8 computed
                                                               ; ASSERT ptr=70
  [->>>>>>>>>>+<<<<<<<<<<]                                     ; which is the addend's high byte  worth two hundred
                                                               ; and fifty six

; ============================================================ ; ; the bottom byte of the value takes the low byte of
<<<<<<<<<<<<<<<<<<<                                            ; ; five times H
                                                               ; ASSERT ptr=51
  [->>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=79
  [-<<<<<<<<<<+>>>>>>>>>>]
<<<<<<<<<<<
                                                               ; ASSERT ptr=68
                                                               ; ASSERT zero 70:78
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=69
                                                               ; ASSERT zero 71:78
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=68
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=71
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=69
  [->>+<<]
>>
                                                               ; ASSERT ptr=71
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=75
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=78
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=76
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=73
  [-[[-]>>>>+<<<<]]
; ============================================================ ; ; ; the carry out is bit 7 of that  and nothing else
>>>>
                                                               ; ASSERT ptr=77
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=71
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 1 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 2 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 3 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 4 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 5 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 6 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 7 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
                                                               ; ASSERT ptr=71
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ============================================================ ; ; ; the sum is twice the halves plus the two low bits
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=75
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=76
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=68
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 69:69
                                                               ; ASSERT zero 71:78

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=68
  [-<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>]                       ; the sum goes home and the carry stays where add8 left
                                                               ; it

; ============================================================ ; ; the second byte takes the high byte  and that carry
<<<<<<<<<<<<<<<<                                               ; ; with it
                                                               ; ASSERT ptr=52
  [->>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=80
  [-<<<<<<<<<<<+>>>>>>>>>>>]
<<<<<<<<<<
                                                               ; ASSERT ptr=70
  [-<+>]
<<
                                                               ; ASSERT ptr=68
                                                               ; ASSERT zero 70:78
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=69
                                                               ; ASSERT zero 71:78
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=68
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=71
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=69
  [->>+<<]
>>
                                                               ; ASSERT ptr=71
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=75
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=78
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=76
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=73
  [-[[-]>>>>+<<<<]]
; ============================================================ ; ; ; the carry out is bit 7 of that  and nothing else
>>>>
                                                               ; ASSERT ptr=77
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=71
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 1 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 2 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 3 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 4 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 5 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 6 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 7 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
                                                               ; ASSERT ptr=71
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ============================================================ ; ; ; the sum is twice the halves plus the two low bits
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=75
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=76
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=68
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 69:69
                                                               ; ASSERT zero 71:78

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=68
  [-<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>]
>>
                                                               ; ASSERT ptr=70

; ============================================================ ; ; and the carry out of that ripples up through the
                                                               ; rest

[                                                              ; ____ byte 2 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=79
  [-]+
<<<<<<<<<<<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=53
  +
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<]                                                          ; continued
>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=81
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >]                                                           ; continued
<
                                                               ; ASSERT ptr=80
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=70
]
                                                               ; ASSERT ptr=70
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=79
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=70

[                                                              ; ____ byte 3 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=79
  [-]+
<<<<<<<<<<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=54
  +
  [->>>>>>>>>>>>>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]                                                            ; continued
>>>>>>>>>>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=81
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=80
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=70
]
                                                               ; ASSERT ptr=70
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=79
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=70

[                                                              ; ____ byte 4 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=79
  [-]+
<<<<<<<<<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=55
  +
  [->>>>>>>>>>>>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=81
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=80
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=70
]
                                                               ; ASSERT ptr=70
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=79
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=70

[                                                              ; ____ byte 5 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=79
  [-]+
<<<<<<<<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=56
  +
  [->>>>>>>>>>>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=81
  [-<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=80
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=70
]
                                                               ; ASSERT ptr=70
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=79
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=70

[                                                              ; ____ byte 6 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=79
  [-]+
<<<<<<<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=57
  +
  [->>>>>>>>>>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=81
  [-<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=80
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=70
]
                                                               ; ASSERT ptr=70
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=79
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=70

[                                                              ; ____ byte 7 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=79
  [-]+
<<<<<<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=58
  +
  [->>>>>>>>>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=81
  [-<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=80
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=70
]
                                                               ; ASSERT ptr=70
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=79
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=70

[                                                              ; ____ byte 8 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=79
  [-]+
<<<<<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=59
  +
  [->>>>>>>>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=81
  [-<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=80
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=70
]
                                                               ; ASSERT ptr=70
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=79
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=70

[                                                              ; ____ byte 9 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=79
  [-]+
<<<<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=60
  +
  [->>>>>>>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=81
  [-<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=80
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=70
]
                                                               ; ASSERT ptr=70
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=79
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=70

[                                                              ; ____ byte 10 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=79
  [-]+
<<<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=61
  +
  [->>>>>>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=81
  [-<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=80
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=70
]
                                                               ; ASSERT ptr=70
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=79
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=70

[                                                              ; ____ byte 11 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=79
  [-]+
<<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=62
  +
  [->>>>>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=81
  [-<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=80
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=70
]
                                                               ; ASSERT ptr=70
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=79
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=70

[                                                              ; ____ byte 12 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=79
  [-]+
<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=63
  +
  [->>>>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=81
  [-<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=80
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=70
]
                                                               ; ASSERT ptr=70
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=79
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=70

[                                                              ; ____ byte 13 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=79
  [-]+
<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=64
  +
  [->>>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=81
  [-<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=80
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=70
]
                                                               ; ASSERT ptr=70
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=79
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=70

[                                                              ; ____ byte 14 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=79
  [-]+
<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=65
  +
  [->>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=81
  [-<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=80
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=70
]
                                                               ; ASSERT ptr=70
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=79
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=70

[                                                              ; ____ byte 15 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=79
  [-]+
<<<<<<<<<<<<<
                                                               ; ASSERT ptr=66
  +
  [->>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=81
  [-<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=80
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=70
]
                                                               ; ASSERT ptr=70
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=79
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=70

[                                                              ; ____ byte 16  which does not look  because its carry
  [-]                                                          ; ; cannot happen ____
<<<
                                                               ; ASSERT ptr=67
  +
>>>
                                                               ; ASSERT ptr=70
]
                                                               ; ASSERT ptr=70

; ============================================================ ; ; the value is folded
<<<<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=51
                                                               ; ASSERT zero 68:85
                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=51

; ============================================================ ; seventeen bytes of b  eight bits each
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; to the byte counter
  >>>>>>>>>>>>>                                                ; continued
                                                               ; ASSERT ptr=124
  +++++++++++++++++
[
  -
<<<<<<<<<<<<<<<<<<<<<<                                         ; to the bottom byte of what is left of b
                                                               ; ASSERT ptr=102
  [->>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<]                       ; it steps out into the cell the halving spends
>                                                              ; and the rest of b slides down one place to take its
                                                               ; turn next
  [-<+>]
>                                                              ; the next byte
  [-<+>]
>                                                              ; the next byte
  [-<+>]
>                                                              ; the next byte
  [-<+>]
>                                                              ; the next byte
  [-<+>]
>                                                              ; the next byte
  [-<+>]
>                                                              ; the next byte
  [-<+>]
>                                                              ; the next byte
  [-<+>]
>                                                              ; the next byte
  [-<+>]
>                                                              ; the next byte
  [-<+>]
>                                                              ; the next byte
  [-<+>]
>                                                              ; the next byte
  [-<+>]
>                                                              ; the next byte
  [-<+>]
>                                                              ; the next byte
  [-<+>]
>                                                              ; the next byte
  [-<+>]
>                                                              ; the next byte
  [-<+>]
                                                               ; ASSERT ptr=118
>>>>>                                                          ; to the bit counter
                                                               ; ASSERT ptr=123
  ++++++++
[
  -
<<<<                                                           ; to the byte in hand
                                                               ; ASSERT ptr=119
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; the halving leaves the byte's low bit beside its own
                                                               ; half
>                                                              ; the half goes back to be halved again next turn
                                                               ; ASSERT ptr=120
  [-<+>]
>                                                              ; to the bit itself
                                                               ; ASSERT ptr=121
[
  [-]                                                          ; the bit is spent here  so this arm runs once and not
                                                               ; once per unit
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; to the running double
  <<<<<<<<<<                                                   ; continued
                                                               ; ASSERT ptr=51
                                                               ; the double is copied  not moved: the adder spends
                                                               ; what it is given and the next turn still needs it
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>+>>>
  >>>>>>>>>>>>>>]                                              ; continued
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>+>>>
  >>>>>>>>>>>>>>]                                              ; continued
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>+>>>
  >>>>>>>>>>>>>>]                                              ; continued
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>+>>>
  >>>>>>>>>>>>>>]                                              ; continued
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>+>>>
  >>>>>>>>>>>>>>]                                              ; continued
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>+>>>
  >>>>>>>>>>>>>>]                                              ; continued
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>+>>>
  >>>>>>>>>>>>>>]                                              ; continued
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>+>>>
  >>>>>>>>>>>>>>]                                              ; continued
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>+>>>
  >>>>>>>>>>>>>>]                                              ; continued
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>+>>>
  >>>>>>>>>>>>>>]                                              ; continued
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>+>>>
  >>>>>>>>>>>>>>]                                              ; continued
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>+>>>
  >>>>>>>>>>>>>>]                                              ; continued
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>+>>>
  >>>>>>>>>>>>>>]                                              ; continued
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>+>>>
  >>>>>>>>>>>>>>]                                              ; continued
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>+>>>
  >>>>>>>>>>>>>>]                                              ; continued
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>+>>>
  >>>>>>>>>>>>>>]                                              ; continued
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>+>>>
  >>>>>>>>>>>>>>]                                              ; continued
                                                               ; ASSERT ptr=67
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<                              ; to the cell that kept it
                                                               ; ASSERT ptr=34
  [->>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<]
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<]
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<]
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<]
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<]
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<]
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<]
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<]
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<]
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<]
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<]
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<]
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<]
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<]
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<]
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<]
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<]
                                                               ; ASSERT ptr=50
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<             ; to the answer  which is the adder's accumulator
                                                               ; ASSERT ptr=0
                                                               ; ASSERT zero 34:45
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>                           ; walk in to this routine entry offset
                                                               ; ASSERT ptr=34
                                                               ; ASSERT zero 34:45

; ============================================================ ; ; byte 0
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<                             ; the accumulator byte steps into the adder
                                                               ; ASSERT ptr=0
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<]                                             ; continued
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>                                             ; to the kernel's base  which is where a paste site
                                                               ; always stands
                                                               ; ASSERT ptr=35
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=36
                                                               ; ASSERT zero 38:45
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=35
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=36
  [->>+<<]
>>
                                                               ; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=42
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=45
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=43
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=40
  [-[[-]>>>>+<<<<]]
; ============================================================ ; ; ; the carry out is bit 7 of that  and nothing else
>>>>
                                                               ; ASSERT ptr=44
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 1 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 2 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 3 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 4 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 5 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 6 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 7 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
                                                               ; ASSERT ptr=38
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ============================================================ ; ; ; the sum is twice the halves plus the two low bits
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=42
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=43
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=35
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 36:36
                                                               ; ASSERT zero 38:45

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=35
<                                                              ; the carry in is nought or one  so it takes the old
  [->>+<<]                                                     ; ; kernel
>>
                                                               ; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>]                                             ; continued
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
<<<
                                                               ; ASSERT ptr=34
                                                               ; ASSERT zero 35:45

; ============================================================ ; ; byte 1
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<                              ; the accumulator byte steps into the adder
                                                               ; ASSERT ptr=1
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<]                                               ; continued
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>                                              ; to the kernel's base  which is where a paste site
                                                               ; always stands
                                                               ; ASSERT ptr=35
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=36
                                                               ; ASSERT zero 38:45
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=35
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=36
  [->>+<<]
>>
                                                               ; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=42
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=45
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=43
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=40
  [-[[-]>>>>+<<<<]]
; ============================================================ ; ; ; the carry out is bit 7 of that  and nothing else
>>>>
                                                               ; ASSERT ptr=44
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 1 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 2 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 3 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 4 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 5 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 6 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 7 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
                                                               ; ASSERT ptr=38
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ============================================================ ; ; ; the sum is twice the halves plus the two low bits
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=42
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=43
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=35
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 36:36
                                                               ; ASSERT zero 38:45

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=35
<                                                              ; the carry in is nought or one  so it takes the old
  [->>+<<]                                                     ; ; kernel
>>
                                                               ; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>]                                               ; continued
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
<<<
                                                               ; ASSERT ptr=34
                                                               ; ASSERT zero 35:45

; ============================================================ ; ; byte 2
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<                               ; the accumulator byte steps into the adder
                                                               ; ASSERT ptr=2
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<]                                                 ; continued
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>                                               ; to the kernel's base  which is where a paste site
                                                               ; always stands
                                                               ; ASSERT ptr=35
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=36
                                                               ; ASSERT zero 38:45
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=35
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=36
  [->>+<<]
>>
                                                               ; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=42
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=45
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=43
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=40
  [-[[-]>>>>+<<<<]]
; ============================================================ ; ; ; the carry out is bit 7 of that  and nothing else
>>>>
                                                               ; ASSERT ptr=44
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 1 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 2 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 3 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 4 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 5 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 6 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 7 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
                                                               ; ASSERT ptr=38
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ============================================================ ; ; ; the sum is twice the halves plus the two low bits
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=42
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=43
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=35
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 36:36
                                                               ; ASSERT zero 38:45

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=35
<                                                              ; the carry in is nought or one  so it takes the old
  [->>+<<]                                                     ; ; kernel
>>
                                                               ; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>]                                                 ; continued
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
<<<
                                                               ; ASSERT ptr=34
                                                               ; ASSERT zero 35:45

; ============================================================ ; ; byte 3
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<                                ; the accumulator byte steps into the adder
                                                               ; ASSERT ptr=3
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<]                                                   ; continued
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>                                                ; to the kernel's base  which is where a paste site
                                                               ; always stands
                                                               ; ASSERT ptr=35
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=36
                                                               ; ASSERT zero 38:45
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=35
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=36
  [->>+<<]
>>
                                                               ; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=42
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=45
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=43
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=40
  [-[[-]>>>>+<<<<]]
; ============================================================ ; ; ; the carry out is bit 7 of that  and nothing else
>>>>
                                                               ; ASSERT ptr=44
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 1 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 2 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 3 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 4 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 5 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 6 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 7 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
                                                               ; ASSERT ptr=38
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ============================================================ ; ; ; the sum is twice the halves plus the two low bits
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=42
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=43
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=35
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 36:36
                                                               ; ASSERT zero 38:45

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=35
<                                                              ; the carry in is nought or one  so it takes the old
  [->>+<<]                                                     ; ; kernel
>>
                                                               ; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>]                                                   ; continued
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
<<<
                                                               ; ASSERT ptr=34
                                                               ; ASSERT zero 35:45

; ============================================================ ; ; byte 4
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<                                 ; the accumulator byte steps into the adder
                                                               ; ASSERT ptr=4
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<]                                                     ; continued
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>                                                 ; to the kernel's base  which is where a paste site
                                                               ; always stands
                                                               ; ASSERT ptr=35
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=36
                                                               ; ASSERT zero 38:45
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=35
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=36
  [->>+<<]
>>
                                                               ; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=42
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=45
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=43
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=40
  [-[[-]>>>>+<<<<]]
; ============================================================ ; ; ; the carry out is bit 7 of that  and nothing else
>>>>
                                                               ; ASSERT ptr=44
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 1 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 2 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 3 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 4 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 5 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 6 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 7 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
                                                               ; ASSERT ptr=38
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ============================================================ ; ; ; the sum is twice the halves plus the two low bits
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=42
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=43
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=35
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 36:36
                                                               ; ASSERT zero 38:45

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=35
<                                                              ; the carry in is nought or one  so it takes the old
  [->>+<<]                                                     ; ; kernel
>>
                                                               ; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>]                                                     ; continued
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
<<<
                                                               ; ASSERT ptr=34
                                                               ; ASSERT zero 35:45

; ============================================================ ; ; byte 5
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<                                  ; the accumulator byte steps into the adder
                                                               ; ASSERT ptr=5
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<]                                                       ; continued
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>>>>>>>>>>>>+<<<<<<<<<<<<<<]
>>>>>>>>>>>>>                                                  ; to the kernel's base  which is where a paste site
                                                               ; always stands
                                                               ; ASSERT ptr=35
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=36
                                                               ; ASSERT zero 38:45
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=35
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=36
  [->>+<<]
>>
                                                               ; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=42
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=45
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=43
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=40
  [-[[-]>>>>+<<<<]]
; ============================================================ ; ; ; the carry out is bit 7 of that  and nothing else
>>>>
                                                               ; ASSERT ptr=44
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 1 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 2 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 3 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 4 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 5 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 6 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 7 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
                                                               ; ASSERT ptr=38
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ============================================================ ; ; ; the sum is twice the halves plus the two low bits
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=42
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=43
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=35
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 36:36
                                                               ; ASSERT zero 38:45

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=35
<                                                              ; the carry in is nought or one  so it takes the old
  [->>+<<]                                                     ; ; kernel
>>
                                                               ; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>]                                                       ; continued
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
<<<
                                                               ; ASSERT ptr=34
                                                               ; ASSERT zero 35:45

; ============================================================ ; ; byte 6
<<<<<<<<<<<<<<<<<<<<<<<<<<<<                                   ; the accumulator byte steps into the adder
                                                               ; ASSERT ptr=6
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<]                                                         ; continued
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>>>>>>>>>>>+<<<<<<<<<<<<<]
>>>>>>>>>>>>                                                   ; to the kernel's base  which is where a paste site
                                                               ; always stands
                                                               ; ASSERT ptr=35
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=36
                                                               ; ASSERT zero 38:45
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=35
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=36
  [->>+<<]
>>
                                                               ; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=42
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=45
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=43
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=40
  [-[[-]>>>>+<<<<]]
; ============================================================ ; ; ; the carry out is bit 7 of that  and nothing else
>>>>
                                                               ; ASSERT ptr=44
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 1 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 2 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 3 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 4 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 5 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 6 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 7 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
                                                               ; ASSERT ptr=38
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ============================================================ ; ; ; the sum is twice the halves plus the two low bits
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=42
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=43
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=35
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 36:36
                                                               ; ASSERT zero 38:45

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=35
<                                                              ; the carry in is nought or one  so it takes the old
  [->>+<<]                                                     ; ; kernel
>>
                                                               ; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>]                                                         ; continued
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
<<<
                                                               ; ASSERT ptr=34
                                                               ; ASSERT zero 35:45

; ============================================================ ; ; byte 7
<<<<<<<<<<<<<<<<<<<<<<<<<<<                                    ; the accumulator byte steps into the adder
                                                               ; ASSERT ptr=7
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <]                                                           ; continued
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>>>>>>>>>>+<<<<<<<<<<<<]
>>>>>>>>>>>                                                    ; to the kernel's base  which is where a paste site
                                                               ; always stands
                                                               ; ASSERT ptr=35
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=36
                                                               ; ASSERT zero 38:45
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=35
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=36
  [->>+<<]
>>
                                                               ; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=42
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=45
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=43
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=40
  [-[[-]>>>>+<<<<]]
; ============================================================ ; ; ; the carry out is bit 7 of that  and nothing else
>>>>
                                                               ; ASSERT ptr=44
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 1 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 2 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 3 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 4 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 5 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 6 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 7 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
                                                               ; ASSERT ptr=38
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ============================================================ ; ; ; the sum is twice the halves plus the two low bits
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=42
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=43
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=35
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 36:36
                                                               ; ASSERT zero 38:45

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=35
<                                                              ; the carry in is nought or one  so it takes the old
  [->>+<<]                                                     ; ; kernel
>>
                                                               ; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >]                                                           ; continued
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
<<<
                                                               ; ASSERT ptr=34
                                                               ; ASSERT zero 35:45

; ============================================================ ; ; byte 8
<<<<<<<<<<<<<<<<<<<<<<<<<<                                     ; the accumulator byte steps into the adder
                                                               ; ASSERT ptr=8
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>>>>>>>>>+<<<<<<<<<<<]
>>>>>>>>>>                                                     ; to the kernel's base  which is where a paste site
                                                               ; always stands
                                                               ; ASSERT ptr=35
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=36
                                                               ; ASSERT zero 38:45
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=35
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=36
  [->>+<<]
>>
                                                               ; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=42
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=45
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=43
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=40
  [-[[-]>>>>+<<<<]]
; ============================================================ ; ; ; the carry out is bit 7 of that  and nothing else
>>>>
                                                               ; ASSERT ptr=44
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 1 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 2 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 3 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 4 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 5 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 6 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 7 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
                                                               ; ASSERT ptr=38
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ============================================================ ; ; ; the sum is twice the halves plus the two low bits
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=42
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=43
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=35
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 36:36
                                                               ; ASSERT zero 38:45

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=35
<                                                              ; the carry in is nought or one  so it takes the old
  [->>+<<]                                                     ; ; kernel
>>
                                                               ; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>>]
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
<<<
                                                               ; ASSERT ptr=34
                                                               ; ASSERT zero 35:45

; ============================================================ ; ; byte 9
<<<<<<<<<<<<<<<<<<<<<<<<<                                      ; the accumulator byte steps into the adder
                                                               ; ASSERT ptr=9
  [->>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>>>>>>>>+<<<<<<<<<<]
>>>>>>>>>                                                      ; to the kernel's base  which is where a paste site
                                                               ; always stands
                                                               ; ASSERT ptr=35
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=36
                                                               ; ASSERT zero 38:45
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=35
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=36
  [->>+<<]
>>
                                                               ; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=42
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=45
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=43
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=40
  [-[[-]>>>>+<<<<]]
; ============================================================ ; ; ; the carry out is bit 7 of that  and nothing else
>>>>
                                                               ; ASSERT ptr=44
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 1 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 2 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 3 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 4 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 5 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 6 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 7 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
                                                               ; ASSERT ptr=38
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ============================================================ ; ; ; the sum is twice the halves plus the two low bits
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=42
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=43
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=35
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 36:36
                                                               ; ASSERT zero 38:45

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=35
<                                                              ; the carry in is nought or one  so it takes the old
  [->>+<<]                                                     ; ; kernel
>>
                                                               ; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>]
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
<<<
                                                               ; ASSERT ptr=34
                                                               ; ASSERT zero 35:45

; ============================================================ ; ; byte 10
<<<<<<<<<<<<<<<<<<<<<<<<                                       ; the accumulator byte steps into the adder
                                                               ; ASSERT ptr=10
  [->>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>>>>>>>+<<<<<<<<<]
>>>>>>>>                                                       ; to the kernel's base  which is where a paste site
                                                               ; always stands
                                                               ; ASSERT ptr=35
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=36
                                                               ; ASSERT zero 38:45
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=35
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=36
  [->>+<<]
>>
                                                               ; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=42
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=45
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=43
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=40
  [-[[-]>>>>+<<<<]]
; ============================================================ ; ; ; the carry out is bit 7 of that  and nothing else
>>>>
                                                               ; ASSERT ptr=44
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 1 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 2 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 3 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 4 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 5 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 6 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 7 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
                                                               ; ASSERT ptr=38
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ============================================================ ; ; ; the sum is twice the halves plus the two low bits
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=42
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=43
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=35
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 36:36
                                                               ; ASSERT zero 38:45

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=35
<                                                              ; the carry in is nought or one  so it takes the old
  [->>+<<]                                                     ; ; kernel
>>
                                                               ; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>]
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
<<<
                                                               ; ASSERT ptr=34
                                                               ; ASSERT zero 35:45

; ============================================================ ; ; byte 11
<<<<<<<<<<<<<<<<<<<<<<<                                        ; the accumulator byte steps into the adder
                                                               ; ASSERT ptr=11
  [->>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>>>>>>+<<<<<<<<]
>>>>>>>                                                        ; to the kernel's base  which is where a paste site
                                                               ; always stands
                                                               ; ASSERT ptr=35
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=36
                                                               ; ASSERT zero 38:45
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=35
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=36
  [->>+<<]
>>
                                                               ; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=42
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=45
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=43
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=40
  [-[[-]>>>>+<<<<]]
; ============================================================ ; ; ; the carry out is bit 7 of that  and nothing else
>>>>
                                                               ; ASSERT ptr=44
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 1 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 2 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 3 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 4 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 5 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 6 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 7 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
                                                               ; ASSERT ptr=38
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ============================================================ ; ; ; the sum is twice the halves plus the two low bits
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=42
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=43
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=35
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 36:36
                                                               ; ASSERT zero 38:45

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=35
<                                                              ; the carry in is nought or one  so it takes the old
  [->>+<<]                                                     ; ; kernel
>>
                                                               ; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>]
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
<<<
                                                               ; ASSERT ptr=34
                                                               ; ASSERT zero 35:45

; ============================================================ ; ; byte 12
<<<<<<<<<<<<<<<<<<<<<<                                         ; the accumulator byte steps into the adder
                                                               ; ASSERT ptr=12
  [->>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>>>>>+<<<<<<<]
>>>>>>                                                         ; to the kernel's base  which is where a paste site
                                                               ; always stands
                                                               ; ASSERT ptr=35
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=36
                                                               ; ASSERT zero 38:45
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=35
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=36
  [->>+<<]
>>
                                                               ; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=42
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=45
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=43
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=40
  [-[[-]>>>>+<<<<]]
; ============================================================ ; ; ; the carry out is bit 7 of that  and nothing else
>>>>
                                                               ; ASSERT ptr=44
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 1 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 2 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 3 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 4 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 5 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 6 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 7 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
                                                               ; ASSERT ptr=38
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ============================================================ ; ; ; the sum is twice the halves plus the two low bits
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=42
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=43
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=35
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 36:36
                                                               ; ASSERT zero 38:45

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=35
<                                                              ; the carry in is nought or one  so it takes the old
  [->>+<<]                                                     ; ; kernel
>>
                                                               ; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>]
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
<<<
                                                               ; ASSERT ptr=34
                                                               ; ASSERT zero 35:45

; ============================================================ ; ; byte 13
<<<<<<<<<<<<<<<<<<<<<                                          ; the accumulator byte steps into the adder
                                                               ; ASSERT ptr=13
  [->>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>>>>+<<<<<<]
>>>>>                                                          ; to the kernel's base  which is where a paste site
                                                               ; always stands
                                                               ; ASSERT ptr=35
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=36
                                                               ; ASSERT zero 38:45
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=35
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=36
  [->>+<<]
>>
                                                               ; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=42
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=45
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=43
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=40
  [-[[-]>>>>+<<<<]]
; ============================================================ ; ; ; the carry out is bit 7 of that  and nothing else
>>>>
                                                               ; ASSERT ptr=44
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 1 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 2 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 3 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 4 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 5 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 6 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 7 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
                                                               ; ASSERT ptr=38
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ============================================================ ; ; ; the sum is twice the halves plus the two low bits
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=42
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=43
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=35
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 36:36
                                                               ; ASSERT zero 38:45

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=35
<                                                              ; the carry in is nought or one  so it takes the old
  [->>+<<]                                                     ; ; kernel
>>
                                                               ; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>]
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
<<<
                                                               ; ASSERT ptr=34
                                                               ; ASSERT zero 35:45

; ============================================================ ; ; byte 14
<<<<<<<<<<<<<<<<<<<<                                           ; the accumulator byte steps into the adder
                                                               ; ASSERT ptr=14
  [->>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>>>+<<<<<]
>>>>                                                           ; to the kernel's base  which is where a paste site
                                                               ; always stands
                                                               ; ASSERT ptr=35
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=36
                                                               ; ASSERT zero 38:45
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=35
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=36
  [->>+<<]
>>
                                                               ; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=42
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=45
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=43
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=40
  [-[[-]>>>>+<<<<]]
; ============================================================ ; ; ; the carry out is bit 7 of that  and nothing else
>>>>
                                                               ; ASSERT ptr=44
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 1 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 2 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 3 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 4 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 5 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 6 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 7 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
                                                               ; ASSERT ptr=38
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ============================================================ ; ; ; the sum is twice the halves plus the two low bits
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=42
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=43
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=35
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 36:36
                                                               ; ASSERT zero 38:45

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=35
<                                                              ; the carry in is nought or one  so it takes the old
  [->>+<<]                                                     ; ; kernel
>>
                                                               ; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>]
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
<<<
                                                               ; ASSERT ptr=34
                                                               ; ASSERT zero 35:45

; ============================================================ ; ; byte 15
<<<<<<<<<<<<<<<<<<<                                            ; the accumulator byte steps into the adder
                                                               ; ASSERT ptr=15
  [->>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>>+<<<<]
>>>                                                            ; to the kernel's base  which is where a paste site
                                                               ; always stands
                                                               ; ASSERT ptr=35
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=36
                                                               ; ASSERT zero 38:45
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=35
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=36
  [->>+<<]
>>
                                                               ; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=42
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=45
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=43
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=40
  [-[[-]>>>>+<<<<]]
; ============================================================ ; ; ; the carry out is bit 7 of that  and nothing else
>>>>
                                                               ; ASSERT ptr=44
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 1 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 2 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 3 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 4 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 5 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 6 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 7 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
                                                               ; ASSERT ptr=38
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ============================================================ ; ; ; the sum is twice the halves plus the two low bits
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=42
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=43
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=35
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 36:36
                                                               ; ASSERT zero 38:45

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=35
<                                                              ; the carry in is nought or one  so it takes the old
  [->>+<<]                                                     ; ; kernel
>>
                                                               ; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>]
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
<<<
                                                               ; ASSERT ptr=34
                                                               ; ASSERT zero 35:45

; ============================================================ ; ; byte 16
<<<<<<<<<<<<<<<<<<                                             ; the accumulator byte steps into the adder
                                                               ; ASSERT ptr=16
  [->>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>+<<<]
>>                                                             ; to the kernel's base  which is where a paste site
                                                               ; always stands
                                                               ; ASSERT ptr=35
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=36
                                                               ; ASSERT zero 38:45
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=35
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=36
  [->>+<<]
>>
                                                               ; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=42
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=45
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=43
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=40
  [-[[-]>>>>+<<<<]]
; ============================================================ ; ; ; the carry out is bit 7 of that  and nothing else
>>>>
                                                               ; ASSERT ptr=44
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 1 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 2 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 3 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 4 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 5 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 6 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 7 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
                                                               ; ASSERT ptr=38
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ============================================================ ; ; ; the sum is twice the halves plus the two low bits
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=42
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=43
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=35
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 36:36
                                                               ; ASSERT zero 38:45

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=35
<                                                              ; the carry in is nought or one  so it takes the old
  [->>+<<]                                                     ; ; kernel
>>
                                                               ; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>]
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
<<<
                                                               ; ASSERT ptr=34
                                                               ; ASSERT zero 35:45

                                                               ; the carry out of the top byte is dropped  and cleared
                                                               ; so the frame is as empty as it was found
                                                               ; ASSERT ptr=34
  [-]
                                                               ; ASSERT zero 17:45

  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<                           ; walk back out to the routine base
                                                               ; ASSERT ptr=0
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; back to the bit  which is nought now  so this arm is
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; done
  >>>                                                          ; continued
]
                                                               ; ASSERT ptr=121
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; to the running double  which doubles whether the bit
  <<<<<<<<<<                                                   ; was set or not
                                                               ; ASSERT ptr=51
                                                               ; ASSERT zero 68:75
  >>>>>>>>>>>>>>>>                                             ; walk in to this routine entry offset
                                                               ; ASSERT ptr=67
                                                               ; ASSERT zero 68:75
<<<<<<<<<<<<<<<<                                               ; to the bottom of the value  which is where a shift
                                                               ; left starts

; ============================================================ ; ; byte 0
                                                               ; ASSERT ptr=51
  [->>>>>>>>>>>>>>>>>+>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<]          ; the byte is taken twice: once to be doubled and once
                                                               ; to give up its top bit
>>>>>>>>>>>>>>>>>>>>>>>                                        ; to the copy that will be doubled
                                                               ; ASSERT ptr=74
  [-<<++>>]                                                    ; doubling wraps modulo 256 by itself  and that wrap IS
                                                               ; the low byte wanted
>                                                              ; seven turns of halving leave nothing but the top bit
  +++++++
[
  -
<<<<<<<                                                        ; to the value
                                                               ; ASSERT ptr=68
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>                                                             ; the bit that falls off is not wanted here
  [-]
<                                                              ; the half becomes the value for the next turn
  [-<+>]
>>>>>>                                                         ; back to the turn counter
]
                                                               ; ASSERT ptr=75
<<<                                                            ; the doubled byte goes back where it came from
                                                               ; ASSERT ptr=72
  [-<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>]
                                                               ; byte nought receives no carry: nothing is below it
                                                               ; and the frame is clear on entry  so this step could
                                                               ; never have run
<<<<
                                                               ; this byte top bit is what goes up to the byte above
                                                               ; ASSERT ptr=68
  [->>>>>+<<<<<]
<<<<<<<<<<<<<<<<                                               ; to the byte above

; ============================================================ ; ; byte 1
                                                               ; ASSERT ptr=52
  [->>>>>>>>>>>>>>>>+>>>>>>+<<<<<<<<<<<<<<<<<<<<<<]            ; the byte is taken twice: once to be doubled and once
                                                               ; to give up its top bit
>>>>>>>>>>>>>>>>>>>>>>                                         ; to the copy that will be doubled
                                                               ; ASSERT ptr=74
  [-<<++>>]                                                    ; doubling wraps modulo 256 by itself  and that wrap IS
                                                               ; the low byte wanted
>                                                              ; seven turns of halving leave nothing but the top bit
  +++++++
[
  -
<<<<<<<                                                        ; to the value
                                                               ; ASSERT ptr=68
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>                                                             ; the bit that falls off is not wanted here
  [-]
<                                                              ; the half becomes the value for the next turn
  [-<+>]
>>>>>>                                                         ; back to the turn counter
]
                                                               ; ASSERT ptr=75
<<<                                                            ; the doubled byte goes back where it came from
                                                               ; ASSERT ptr=72
  [-<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>]
>                                                              ; and the bit that came up from the byte below is added
  [-<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>]               ; ; to it
<<<<<                                                          ; this byte top bit is what goes up to the byte above
                                                               ; ASSERT ptr=68
  [->>>>>+<<<<<]
<<<<<<<<<<<<<<<                                                ; to the byte above

; ============================================================ ; ; byte 2
                                                               ; ASSERT ptr=53
  [->>>>>>>>>>>>>>>+>>>>>>+<<<<<<<<<<<<<<<<<<<<<]              ; the byte is taken twice: once to be doubled and once
                                                               ; to give up its top bit
>>>>>>>>>>>>>>>>>>>>>                                          ; to the copy that will be doubled
                                                               ; ASSERT ptr=74
  [-<<++>>]                                                    ; doubling wraps modulo 256 by itself  and that wrap IS
                                                               ; the low byte wanted
>                                                              ; seven turns of halving leave nothing but the top bit
  +++++++
[
  -
<<<<<<<                                                        ; to the value
                                                               ; ASSERT ptr=68
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>                                                             ; the bit that falls off is not wanted here
  [-]
<                                                              ; the half becomes the value for the next turn
  [-<+>]
>>>>>>                                                         ; back to the turn counter
]
                                                               ; ASSERT ptr=75
<<<                                                            ; the doubled byte goes back where it came from
                                                               ; ASSERT ptr=72
  [-<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>]
>                                                              ; and the bit that came up from the byte below is added
  [-<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>]                 ; ; to it
<<<<<                                                          ; this byte top bit is what goes up to the byte above
                                                               ; ASSERT ptr=68
  [->>>>>+<<<<<]
<<<<<<<<<<<<<<                                                 ; to the byte above

; ============================================================ ; ; byte 3
                                                               ; ASSERT ptr=54
  [->>>>>>>>>>>>>>+>>>>>>+<<<<<<<<<<<<<<<<<<<<]                ; the byte is taken twice: once to be doubled and once
                                                               ; to give up its top bit
>>>>>>>>>>>>>>>>>>>>                                           ; to the copy that will be doubled
                                                               ; ASSERT ptr=74
  [-<<++>>]                                                    ; doubling wraps modulo 256 by itself  and that wrap IS
                                                               ; the low byte wanted
>                                                              ; seven turns of halving leave nothing but the top bit
  +++++++
[
  -
<<<<<<<                                                        ; to the value
                                                               ; ASSERT ptr=68
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>                                                             ; the bit that falls off is not wanted here
  [-]
<                                                              ; the half becomes the value for the next turn
  [-<+>]
>>>>>>                                                         ; back to the turn counter
]
                                                               ; ASSERT ptr=75
<<<                                                            ; the doubled byte goes back where it came from
                                                               ; ASSERT ptr=72
  [-<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>]
>                                                              ; and the bit that came up from the byte below is added
  [-<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>]                   ; ; to it
<<<<<                                                          ; this byte top bit is what goes up to the byte above
                                                               ; ASSERT ptr=68
  [->>>>>+<<<<<]
<<<<<<<<<<<<<                                                  ; to the byte above

; ============================================================ ; ; byte 4
                                                               ; ASSERT ptr=55
  [->>>>>>>>>>>>>+>>>>>>+<<<<<<<<<<<<<<<<<<<]                  ; the byte is taken twice: once to be doubled and once
                                                               ; to give up its top bit
>>>>>>>>>>>>>>>>>>>                                            ; to the copy that will be doubled
                                                               ; ASSERT ptr=74
  [-<<++>>]                                                    ; doubling wraps modulo 256 by itself  and that wrap IS
                                                               ; the low byte wanted
>                                                              ; seven turns of halving leave nothing but the top bit
  +++++++
[
  -
<<<<<<<                                                        ; to the value
                                                               ; ASSERT ptr=68
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>                                                             ; the bit that falls off is not wanted here
  [-]
<                                                              ; the half becomes the value for the next turn
  [-<+>]
>>>>>>                                                         ; back to the turn counter
]
                                                               ; ASSERT ptr=75
<<<                                                            ; the doubled byte goes back where it came from
                                                               ; ASSERT ptr=72
  [-<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>]
>                                                              ; and the bit that came up from the byte below is added
  [-<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>]                     ; ; to it
<<<<<                                                          ; this byte top bit is what goes up to the byte above
                                                               ; ASSERT ptr=68
  [->>>>>+<<<<<]
<<<<<<<<<<<<                                                   ; to the byte above

; ============================================================ ; ; byte 5
                                                               ; ASSERT ptr=56
  [->>>>>>>>>>>>+>>>>>>+<<<<<<<<<<<<<<<<<<]                    ; the byte is taken twice: once to be doubled and once
                                                               ; to give up its top bit
>>>>>>>>>>>>>>>>>>                                             ; to the copy that will be doubled
                                                               ; ASSERT ptr=74
  [-<<++>>]                                                    ; doubling wraps modulo 256 by itself  and that wrap IS
                                                               ; the low byte wanted
>                                                              ; seven turns of halving leave nothing but the top bit
  +++++++
[
  -
<<<<<<<                                                        ; to the value
                                                               ; ASSERT ptr=68
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>                                                             ; the bit that falls off is not wanted here
  [-]
<                                                              ; the half becomes the value for the next turn
  [-<+>]
>>>>>>                                                         ; back to the turn counter
]
                                                               ; ASSERT ptr=75
<<<                                                            ; the doubled byte goes back where it came from
                                                               ; ASSERT ptr=72
  [-<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>]
>                                                              ; and the bit that came up from the byte below is added
  [-<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>]                       ; ; to it
<<<<<                                                          ; this byte top bit is what goes up to the byte above
                                                               ; ASSERT ptr=68
  [->>>>>+<<<<<]
<<<<<<<<<<<                                                    ; to the byte above

; ============================================================ ; ; byte 6
                                                               ; ASSERT ptr=57
  [->>>>>>>>>>>+>>>>>>+<<<<<<<<<<<<<<<<<]                      ; the byte is taken twice: once to be doubled and once
                                                               ; to give up its top bit
>>>>>>>>>>>>>>>>>                                              ; to the copy that will be doubled
                                                               ; ASSERT ptr=74
  [-<<++>>]                                                    ; doubling wraps modulo 256 by itself  and that wrap IS
                                                               ; the low byte wanted
>                                                              ; seven turns of halving leave nothing but the top bit
  +++++++
[
  -
<<<<<<<                                                        ; to the value
                                                               ; ASSERT ptr=68
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>                                                             ; the bit that falls off is not wanted here
  [-]
<                                                              ; the half becomes the value for the next turn
  [-<+>]
>>>>>>                                                         ; back to the turn counter
]
                                                               ; ASSERT ptr=75
<<<                                                            ; the doubled byte goes back where it came from
                                                               ; ASSERT ptr=72
  [-<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>]
>                                                              ; and the bit that came up from the byte below is added
  [-<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>]                         ; ; to it
<<<<<                                                          ; this byte top bit is what goes up to the byte above
                                                               ; ASSERT ptr=68
  [->>>>>+<<<<<]
<<<<<<<<<<                                                     ; to the byte above

; ============================================================ ; ; byte 7
                                                               ; ASSERT ptr=58
  [->>>>>>>>>>+>>>>>>+<<<<<<<<<<<<<<<<]                        ; the byte is taken twice: once to be doubled and once
                                                               ; to give up its top bit
>>>>>>>>>>>>>>>>                                               ; to the copy that will be doubled
                                                               ; ASSERT ptr=74
  [-<<++>>]                                                    ; doubling wraps modulo 256 by itself  and that wrap IS
                                                               ; the low byte wanted
>                                                              ; seven turns of halving leave nothing but the top bit
  +++++++
[
  -
<<<<<<<                                                        ; to the value
                                                               ; ASSERT ptr=68
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>                                                             ; the bit that falls off is not wanted here
  [-]
<                                                              ; the half becomes the value for the next turn
  [-<+>]
>>>>>>                                                         ; back to the turn counter
]
                                                               ; ASSERT ptr=75
<<<                                                            ; the doubled byte goes back where it came from
                                                               ; ASSERT ptr=72
  [-<<<<<<<<<<<<<<+>>>>>>>>>>>>>>]
>                                                              ; and the bit that came up from the byte below is added
  [-<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>]                           ; ; to it
<<<<<                                                          ; this byte top bit is what goes up to the byte above
                                                               ; ASSERT ptr=68
  [->>>>>+<<<<<]
<<<<<<<<<                                                      ; to the byte above

; ============================================================ ; ; byte 8
                                                               ; ASSERT ptr=59
  [->>>>>>>>>+>>>>>>+<<<<<<<<<<<<<<<]                          ; the byte is taken twice: once to be doubled and once
                                                               ; to give up its top bit
>>>>>>>>>>>>>>>                                                ; to the copy that will be doubled
                                                               ; ASSERT ptr=74
  [-<<++>>]                                                    ; doubling wraps modulo 256 by itself  and that wrap IS
                                                               ; the low byte wanted
>                                                              ; seven turns of halving leave nothing but the top bit
  +++++++
[
  -
<<<<<<<                                                        ; to the value
                                                               ; ASSERT ptr=68
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>                                                             ; the bit that falls off is not wanted here
  [-]
<                                                              ; the half becomes the value for the next turn
  [-<+>]
>>>>>>                                                         ; back to the turn counter
]
                                                               ; ASSERT ptr=75
<<<                                                            ; the doubled byte goes back where it came from
                                                               ; ASSERT ptr=72
  [-<<<<<<<<<<<<<+>>>>>>>>>>>>>]
>                                                              ; and the bit that came up from the byte below is added
  [-<<<<<<<<<<<<<<+>>>>>>>>>>>>>>]                             ; ; to it
<<<<<                                                          ; this byte top bit is what goes up to the byte above
                                                               ; ASSERT ptr=68
  [->>>>>+<<<<<]
<<<<<<<<                                                       ; to the byte above

; ============================================================ ; ; byte 9
                                                               ; ASSERT ptr=60
  [->>>>>>>>+>>>>>>+<<<<<<<<<<<<<<]                            ; the byte is taken twice: once to be doubled and once
                                                               ; to give up its top bit
>>>>>>>>>>>>>>                                                 ; to the copy that will be doubled
                                                               ; ASSERT ptr=74
  [-<<++>>]                                                    ; doubling wraps modulo 256 by itself  and that wrap IS
                                                               ; the low byte wanted
>                                                              ; seven turns of halving leave nothing but the top bit
  +++++++
[
  -
<<<<<<<                                                        ; to the value
                                                               ; ASSERT ptr=68
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>                                                             ; the bit that falls off is not wanted here
  [-]
<                                                              ; the half becomes the value for the next turn
  [-<+>]
>>>>>>                                                         ; back to the turn counter
]
                                                               ; ASSERT ptr=75
<<<                                                            ; the doubled byte goes back where it came from
                                                               ; ASSERT ptr=72
  [-<<<<<<<<<<<<+>>>>>>>>>>>>]
>                                                              ; and the bit that came up from the byte below is added
  [-<<<<<<<<<<<<<+>>>>>>>>>>>>>]                               ; ; to it
<<<<<                                                          ; this byte top bit is what goes up to the byte above
                                                               ; ASSERT ptr=68
  [->>>>>+<<<<<]
<<<<<<<                                                        ; to the byte above

; ============================================================ ; ; byte 10
                                                               ; ASSERT ptr=61
  [->>>>>>>+>>>>>>+<<<<<<<<<<<<<]                              ; the byte is taken twice: once to be doubled and once
                                                               ; to give up its top bit
>>>>>>>>>>>>>                                                  ; to the copy that will be doubled
                                                               ; ASSERT ptr=74
  [-<<++>>]                                                    ; doubling wraps modulo 256 by itself  and that wrap IS
                                                               ; the low byte wanted
>                                                              ; seven turns of halving leave nothing but the top bit
  +++++++
[
  -
<<<<<<<                                                        ; to the value
                                                               ; ASSERT ptr=68
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>                                                             ; the bit that falls off is not wanted here
  [-]
<                                                              ; the half becomes the value for the next turn
  [-<+>]
>>>>>>                                                         ; back to the turn counter
]
                                                               ; ASSERT ptr=75
<<<                                                            ; the doubled byte goes back where it came from
                                                               ; ASSERT ptr=72
  [-<<<<<<<<<<<+>>>>>>>>>>>]
>                                                              ; and the bit that came up from the byte below is added
  [-<<<<<<<<<<<<+>>>>>>>>>>>>]                                 ; ; to it
<<<<<                                                          ; this byte top bit is what goes up to the byte above
                                                               ; ASSERT ptr=68
  [->>>>>+<<<<<]
<<<<<<                                                         ; to the byte above

; ============================================================ ; ; byte 11
                                                               ; ASSERT ptr=62
  [->>>>>>+>>>>>>+<<<<<<<<<<<<]                                ; the byte is taken twice: once to be doubled and once
                                                               ; to give up its top bit
>>>>>>>>>>>>                                                   ; to the copy that will be doubled
                                                               ; ASSERT ptr=74
  [-<<++>>]                                                    ; doubling wraps modulo 256 by itself  and that wrap IS
                                                               ; the low byte wanted
>                                                              ; seven turns of halving leave nothing but the top bit
  +++++++
[
  -
<<<<<<<                                                        ; to the value
                                                               ; ASSERT ptr=68
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>                                                             ; the bit that falls off is not wanted here
  [-]
<                                                              ; the half becomes the value for the next turn
  [-<+>]
>>>>>>                                                         ; back to the turn counter
]
                                                               ; ASSERT ptr=75
<<<                                                            ; the doubled byte goes back where it came from
                                                               ; ASSERT ptr=72
  [-<<<<<<<<<<+>>>>>>>>>>]
>                                                              ; and the bit that came up from the byte below is added
  [-<<<<<<<<<<<+>>>>>>>>>>>]                                   ; ; to it
<<<<<                                                          ; this byte top bit is what goes up to the byte above
                                                               ; ASSERT ptr=68
  [->>>>>+<<<<<]
<<<<<                                                          ; to the byte above

; ============================================================ ; ; byte 12
                                                               ; ASSERT ptr=63
  [->>>>>+>>>>>>+<<<<<<<<<<<]                                  ; the byte is taken twice: once to be doubled and once
                                                               ; to give up its top bit
>>>>>>>>>>>                                                    ; to the copy that will be doubled
                                                               ; ASSERT ptr=74
  [-<<++>>]                                                    ; doubling wraps modulo 256 by itself  and that wrap IS
                                                               ; the low byte wanted
>                                                              ; seven turns of halving leave nothing but the top bit
  +++++++
[
  -
<<<<<<<                                                        ; to the value
                                                               ; ASSERT ptr=68
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>                                                             ; the bit that falls off is not wanted here
  [-]
<                                                              ; the half becomes the value for the next turn
  [-<+>]
>>>>>>                                                         ; back to the turn counter
]
                                                               ; ASSERT ptr=75
<<<                                                            ; the doubled byte goes back where it came from
                                                               ; ASSERT ptr=72
  [-<<<<<<<<<+>>>>>>>>>]
>                                                              ; and the bit that came up from the byte below is added
  [-<<<<<<<<<<+>>>>>>>>>>]                                     ; ; to it
<<<<<                                                          ; this byte top bit is what goes up to the byte above
                                                               ; ASSERT ptr=68
  [->>>>>+<<<<<]
<<<<                                                           ; to the byte above

; ============================================================ ; ; byte 13
                                                               ; ASSERT ptr=64
  [->>>>+>>>>>>+<<<<<<<<<<]                                    ; the byte is taken twice: once to be doubled and once
                                                               ; to give up its top bit
>>>>>>>>>>                                                     ; to the copy that will be doubled
                                                               ; ASSERT ptr=74
  [-<<++>>]                                                    ; doubling wraps modulo 256 by itself  and that wrap IS
                                                               ; the low byte wanted
>                                                              ; seven turns of halving leave nothing but the top bit
  +++++++
[
  -
<<<<<<<                                                        ; to the value
                                                               ; ASSERT ptr=68
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>                                                             ; the bit that falls off is not wanted here
  [-]
<                                                              ; the half becomes the value for the next turn
  [-<+>]
>>>>>>                                                         ; back to the turn counter
]
                                                               ; ASSERT ptr=75
<<<                                                            ; the doubled byte goes back where it came from
                                                               ; ASSERT ptr=72
  [-<<<<<<<<+>>>>>>>>]
>                                                              ; and the bit that came up from the byte below is added
  [-<<<<<<<<<+>>>>>>>>>]                                       ; ; to it
<<<<<                                                          ; this byte top bit is what goes up to the byte above
                                                               ; ASSERT ptr=68
  [->>>>>+<<<<<]
<<<                                                            ; to the byte above

; ============================================================ ; ; byte 14
                                                               ; ASSERT ptr=65
  [->>>+>>>>>>+<<<<<<<<<]                                      ; the byte is taken twice: once to be doubled and once
                                                               ; to give up its top bit
>>>>>>>>>                                                      ; to the copy that will be doubled
                                                               ; ASSERT ptr=74
  [-<<++>>]                                                    ; doubling wraps modulo 256 by itself  and that wrap IS
                                                               ; the low byte wanted
>                                                              ; seven turns of halving leave nothing but the top bit
  +++++++
[
  -
<<<<<<<                                                        ; to the value
                                                               ; ASSERT ptr=68
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>                                                             ; the bit that falls off is not wanted here
  [-]
<                                                              ; the half becomes the value for the next turn
  [-<+>]
>>>>>>                                                         ; back to the turn counter
]
                                                               ; ASSERT ptr=75
<<<                                                            ; the doubled byte goes back where it came from
                                                               ; ASSERT ptr=72
  [-<<<<<<<+>>>>>>>]
>                                                              ; and the bit that came up from the byte below is added
  [-<<<<<<<<+>>>>>>>>]                                         ; ; to it
<<<<<                                                          ; this byte top bit is what goes up to the byte above
                                                               ; ASSERT ptr=68
  [->>>>>+<<<<<]
<<                                                             ; to the byte above

; ============================================================ ; ; byte 15
                                                               ; ASSERT ptr=66
  [->>+>>>>>>+<<<<<<<<]                                        ; the byte is taken twice: once to be doubled and once
                                                               ; to give up its top bit
>>>>>>>>                                                       ; to the copy that will be doubled
                                                               ; ASSERT ptr=74
  [-<<++>>]                                                    ; doubling wraps modulo 256 by itself  and that wrap IS
                                                               ; the low byte wanted
>                                                              ; seven turns of halving leave nothing but the top bit
  +++++++
[
  -
<<<<<<<                                                        ; to the value
                                                               ; ASSERT ptr=68
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>                                                             ; the bit that falls off is not wanted here
  [-]
<                                                              ; the half becomes the value for the next turn
  [-<+>]
>>>>>>                                                         ; back to the turn counter
]
                                                               ; ASSERT ptr=75
<<<                                                            ; the doubled byte goes back where it came from
                                                               ; ASSERT ptr=72
  [-<<<<<<+>>>>>>]
>                                                              ; and the bit that came up from the byte below is added
  [-<<<<<<<+>>>>>>>]                                           ; ; to it
<<<<<                                                          ; this byte top bit is what goes up to the byte above
                                                               ; ASSERT ptr=68
  [->>>>>+<<<<<]
<                                                              ; to the byte above

; ============================================================ ; ; byte 16
                                                               ; ASSERT ptr=67
  [->+>>>>>>+<<<<<<<]                                          ; the byte is taken twice: once to be doubled and once
                                                               ; to give up its top bit
>>>>>>>                                                        ; to the copy that will be doubled
                                                               ; ASSERT ptr=74
  [-<<++>>]                                                    ; doubling wraps modulo 256 by itself  and that wrap IS
                                                               ; the low byte wanted
>                                                              ; seven turns of halving leave nothing but the top bit
  +++++++
[
  -
<<<<<<<                                                        ; to the value
                                                               ; ASSERT ptr=68
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>                                                             ; the bit that falls off is not wanted here
  [-]
<                                                              ; the half becomes the value for the next turn
  [-<+>]
>>>>>>                                                         ; back to the turn counter
]
                                                               ; ASSERT ptr=75
<<<                                                            ; the doubled byte goes back where it came from
                                                               ; ASSERT ptr=72
  [-<<<<<+>>>>>]
>                                                              ; and the bit that came up from the byte below is added
  [-<<<<<<+>>>>>>]                                             ; ; to it
<<<<<                                                          ; this byte top bit is what goes up to the byte above
                                                               ; ASSERT ptr=68
  [->>>>>+<<<<<]

>>>>>                                                          ; the bit shifted out of the top byte is discarded
                                                               ; ASSERT ptr=73
  [-]
<<<<<<<<<<<<<<<<<<<<<<                                         ; back to the head of the value
                                                               ; ASSERT ptr=51
                                                               ; ASSERT zero 68:75
                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=51
                                                               ; ASSERT zero 68:101
  >>>>>>>>>>>>>>>>                                             ; walk in to this routine entry offset

; ============================================================ ; ; split the top byte at bit 130
                                                               ; ASSERT ptr=67
                                                               ; ASSERT zero 68:85
  [->>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<]                           ; the top byte steps into the halving frame
>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=82
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; the first halving; the bit it drops is bit 128
>>                                                             ; which is worth one in what is left below the split
                                                               ; ASSERT ptr=84
  [-<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>]
<                                                              ; the half steps back into the frame to be halved again
                                                               ; ASSERT ptr=83
  [-<+>]
<
                                                               ; ASSERT ptr=82
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; the second halving; the bit it drops is bit 129
>>                                                             ; which is worth two
                                                               ; ASSERT ptr=84
  [-<<<<<<<<<<<<<<<<<++>>>>>>>>>>>>>>>>>]
<                                                              ; and what is left in the quotient is everything at bit
                                                               ; 130 and above
                                                               ; ASSERT ptr=83
  [-<<+>>]

; ============================================================ ; ; two to the hundred and thirtieth is five  so five
                                                               ; times that part
<<                                                             ; to the part above the split
                                                               ; ASSERT ptr=81
                                                               ; it is spent ONCE  into four copies of itself and one
                                                               ; copy of itself  which is where the five comes from;
                                                               ; neither cell can wrap  because four times sixty three
                                                               ; is two hundred and fifty two
  [-<<<<<<<<<<<<<++++>+>>>>>>>>>>>>]
                                                               ; ASSERT ptr=81
<<<<<<<<<<<<<                                                  ; to the byte pair the eight bit adder works on
                                                               ; ASSERT ptr=68
                                                               ; ASSERT zero 70:78
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=69
                                                               ; ASSERT zero 71:78
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=68
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=71
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=69
  [->>+<<]
>>
                                                               ; ASSERT ptr=71
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=75
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=78
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=76
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=73
  [-[[-]>>>>+<<<<]]
; ============================================================ ; ; ; the carry out is bit 7 of that  and nothing else
>>>>
                                                               ; ASSERT ptr=77
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=71
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 1 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 2 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 3 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 4 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 5 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 6 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 7 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
                                                               ; ASSERT ptr=71
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ============================================================ ; ; ; the sum is twice the halves plus the two low bits
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=75
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=76
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=68
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 69:69
                                                               ; ASSERT zero 71:78

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=68
  [->>>>>>>>>>>+<<<<<<<<<<<]                                   ; the sum is five times H modulo 256  and it is the
                                                               ; addend's low byte
>>                                                             ; to the carry add8 computed
                                                               ; ASSERT ptr=70
  [->>>>>>>>>>+<<<<<<<<<<]                                     ; which is the addend's high byte  worth two hundred
                                                               ; and fifty six

; ============================================================ ; ; the bottom byte of the value takes the low byte of
<<<<<<<<<<<<<<<<<<<                                            ; ; five times H
                                                               ; ASSERT ptr=51
  [->>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=79
  [-<<<<<<<<<<+>>>>>>>>>>]
<<<<<<<<<<<
                                                               ; ASSERT ptr=68
                                                               ; ASSERT zero 70:78
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=69
                                                               ; ASSERT zero 71:78
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=68
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=71
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=69
  [->>+<<]
>>
                                                               ; ASSERT ptr=71
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=75
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=78
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=76
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=73
  [-[[-]>>>>+<<<<]]
; ============================================================ ; ; ; the carry out is bit 7 of that  and nothing else
>>>>
                                                               ; ASSERT ptr=77
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=71
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 1 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 2 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 3 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 4 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 5 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 6 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 7 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
                                                               ; ASSERT ptr=71
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ============================================================ ; ; ; the sum is twice the halves plus the two low bits
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=75
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=76
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=68
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 69:69
                                                               ; ASSERT zero 71:78

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=68
  [-<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>]                       ; the sum goes home and the carry stays where add8 left
                                                               ; it

; ============================================================ ; ; the second byte takes the high byte  and that carry
<<<<<<<<<<<<<<<<                                               ; ; with it
                                                               ; ASSERT ptr=52
  [->>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=80
  [-<<<<<<<<<<<+>>>>>>>>>>>]
<<<<<<<<<<
                                                               ; ASSERT ptr=70
  [-<+>]
<<
                                                               ; ASSERT ptr=68
                                                               ; ASSERT zero 70:78
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=69
                                                               ; ASSERT zero 71:78
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=68
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=71
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=69
  [->>+<<]
>>
                                                               ; ASSERT ptr=71
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=75
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=78
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=76
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=73
  [-[[-]>>>>+<<<<]]
; ============================================================ ; ; ; the carry out is bit 7 of that  and nothing else
>>>>
                                                               ; ASSERT ptr=77
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=71
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 1 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 2 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 3 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 4 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 5 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 6 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 7 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
                                                               ; ASSERT ptr=71
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ============================================================ ; ; ; the sum is twice the halves plus the two low bits
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=75
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=76
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=68
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 69:69
                                                               ; ASSERT zero 71:78

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=68
  [-<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>]
>>
                                                               ; ASSERT ptr=70

; ============================================================ ; ; and the carry out of that ripples up through the
                                                               ; rest

[                                                              ; ____ byte 2 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=79
  [-]+
<<<<<<<<<<<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=53
  +
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<]                                                          ; continued
>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=81
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >]                                                           ; continued
<
                                                               ; ASSERT ptr=80
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=70
]
                                                               ; ASSERT ptr=70
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=79
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=70

[                                                              ; ____ byte 3 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=79
  [-]+
<<<<<<<<<<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=54
  +
  [->>>>>>>>>>>>>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]                                                            ; continued
>>>>>>>>>>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=81
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=80
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=70
]
                                                               ; ASSERT ptr=70
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=79
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=70

[                                                              ; ____ byte 4 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=79
  [-]+
<<<<<<<<<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=55
  +
  [->>>>>>>>>>>>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=81
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=80
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=70
]
                                                               ; ASSERT ptr=70
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=79
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=70

[                                                              ; ____ byte 5 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=79
  [-]+
<<<<<<<<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=56
  +
  [->>>>>>>>>>>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=81
  [-<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=80
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=70
]
                                                               ; ASSERT ptr=70
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=79
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=70

[                                                              ; ____ byte 6 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=79
  [-]+
<<<<<<<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=57
  +
  [->>>>>>>>>>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=81
  [-<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=80
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=70
]
                                                               ; ASSERT ptr=70
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=79
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=70

[                                                              ; ____ byte 7 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=79
  [-]+
<<<<<<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=58
  +
  [->>>>>>>>>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=81
  [-<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=80
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=70
]
                                                               ; ASSERT ptr=70
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=79
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=70

[                                                              ; ____ byte 8 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=79
  [-]+
<<<<<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=59
  +
  [->>>>>>>>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=81
  [-<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=80
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=70
]
                                                               ; ASSERT ptr=70
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=79
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=70

[                                                              ; ____ byte 9 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=79
  [-]+
<<<<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=60
  +
  [->>>>>>>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=81
  [-<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=80
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=70
]
                                                               ; ASSERT ptr=70
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=79
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=70

[                                                              ; ____ byte 10 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=79
  [-]+
<<<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=61
  +
  [->>>>>>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=81
  [-<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=80
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=70
]
                                                               ; ASSERT ptr=70
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=79
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=70

[                                                              ; ____ byte 11 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=79
  [-]+
<<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=62
  +
  [->>>>>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=81
  [-<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=80
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=70
]
                                                               ; ASSERT ptr=70
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=79
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=70

[                                                              ; ____ byte 12 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=79
  [-]+
<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=63
  +
  [->>>>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=81
  [-<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=80
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=70
]
                                                               ; ASSERT ptr=70
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=79
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=70

[                                                              ; ____ byte 13 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=79
  [-]+
<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=64
  +
  [->>>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=81
  [-<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=80
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=70
]
                                                               ; ASSERT ptr=70
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=79
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=70

[                                                              ; ____ byte 14 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=79
  [-]+
<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=65
  +
  [->>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=81
  [-<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=80
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=70
]
                                                               ; ASSERT ptr=70
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=79
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=70

[                                                              ; ____ byte 15 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=79
  [-]+
<<<<<<<<<<<<<
                                                               ; ASSERT ptr=66
  +
  [->>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=81
  [-<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=80
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=70
]
                                                               ; ASSERT ptr=70
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=79
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=70

[                                                              ; ____ byte 16  which does not look  because its carry
  [-]                                                          ; ; cannot happen ____
<<<
                                                               ; ASSERT ptr=67
  +
>>>
                                                               ; ASSERT ptr=70
]
                                                               ; ASSERT ptr=70

; ============================================================ ; ; the value is folded
<<<<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=51
                                                               ; ASSERT zero 68:85
                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=51
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; back to the bit counter
  >>>>>>>>>>>>                                                 ; continued
]
                                                               ; ASSERT ptr=123
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; the byte is spent  so the answer is folded once for
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; the eight adds it took
  <<<<<                                                        ; continued
                                                               ; ASSERT ptr=0
                                                               ; ASSERT zero 17:50
  >>>>>>>>>>>>>>>>                                             ; walk in to this routine entry offset

; ============================================================ ; ; split the top byte at bit 130
                                                               ; ASSERT ptr=16
                                                               ; ASSERT zero 17:34
  [->>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<]                           ; the top byte steps into the halving frame
>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=31
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; the first halving; the bit it drops is bit 128
>>                                                             ; which is worth one in what is left below the split
                                                               ; ASSERT ptr=33
  [-<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>]
<                                                              ; the half steps back into the frame to be halved again
                                                               ; ASSERT ptr=32
  [-<+>]
<
                                                               ; ASSERT ptr=31
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; the second halving; the bit it drops is bit 129
>>                                                             ; which is worth two
                                                               ; ASSERT ptr=33
  [-<<<<<<<<<<<<<<<<<++>>>>>>>>>>>>>>>>>]
<                                                              ; and what is left in the quotient is everything at bit
                                                               ; 130 and above
                                                               ; ASSERT ptr=32
  [-<<+>>]

; ============================================================ ; ; two to the hundred and thirtieth is five  so five
                                                               ; times that part
<<                                                             ; to the part above the split
                                                               ; ASSERT ptr=30
                                                               ; it is spent ONCE  into four copies of itself and one
                                                               ; copy of itself  which is where the five comes from;
                                                               ; neither cell can wrap  because four times sixty three
                                                               ; is two hundred and fifty two
  [-<<<<<<<<<<<<<++++>+>>>>>>>>>>>>]
                                                               ; ASSERT ptr=30
<<<<<<<<<<<<<                                                  ; to the byte pair the eight bit adder works on
                                                               ; ASSERT ptr=17
                                                               ; ASSERT zero 19:27
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=18
                                                               ; ASSERT zero 20:27
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=17
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=20
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=18
  [->>+<<]
>>
                                                               ; ASSERT ptr=20
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=24
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=27
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=25
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=22
  [-[[-]>>>>+<<<<]]
; ============================================================ ; ; ; the carry out is bit 7 of that  and nothing else
>>>>
                                                               ; ASSERT ptr=26
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=20
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 1 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 2 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 3 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 4 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 5 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 6 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 7 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
                                                               ; ASSERT ptr=20
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ============================================================ ; ; ; the sum is twice the halves plus the two low bits
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=24
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=25
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=17
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 18:18
                                                               ; ASSERT zero 20:27

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=17
  [->>>>>>>>>>>+<<<<<<<<<<<]                                   ; the sum is five times H modulo 256  and it is the
                                                               ; addend's low byte
>>                                                             ; to the carry add8 computed
                                                               ; ASSERT ptr=19
  [->>>>>>>>>>+<<<<<<<<<<]                                     ; which is the addend's high byte  worth two hundred
                                                               ; and fifty six

; ============================================================ ; ; the bottom byte of the value takes the low byte of
<<<<<<<<<<<<<<<<<<<                                            ; ; five times H
                                                               ; ASSERT ptr=0
  [->>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=28
  [-<<<<<<<<<<+>>>>>>>>>>]
<<<<<<<<<<<
                                                               ; ASSERT ptr=17
                                                               ; ASSERT zero 19:27
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=18
                                                               ; ASSERT zero 20:27
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=17
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=20
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=18
  [->>+<<]
>>
                                                               ; ASSERT ptr=20
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=24
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=27
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=25
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=22
  [-[[-]>>>>+<<<<]]
; ============================================================ ; ; ; the carry out is bit 7 of that  and nothing else
>>>>
                                                               ; ASSERT ptr=26
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=20
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 1 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 2 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 3 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 4 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 5 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 6 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 7 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
                                                               ; ASSERT ptr=20
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ============================================================ ; ; ; the sum is twice the halves plus the two low bits
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=24
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=25
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=17
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 18:18
                                                               ; ASSERT zero 20:27

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=17
  [-<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>]                       ; the sum goes home and the carry stays where add8 left
                                                               ; it

; ============================================================ ; ; the second byte takes the high byte  and that carry
<<<<<<<<<<<<<<<<                                               ; ; with it
                                                               ; ASSERT ptr=1
  [->>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=29
  [-<<<<<<<<<<<+>>>>>>>>>>>]
<<<<<<<<<<
                                                               ; ASSERT ptr=19
  [-<+>]
<<
                                                               ; ASSERT ptr=17
                                                               ; ASSERT zero 19:27
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=18
                                                               ; ASSERT zero 20:27
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=17
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=20
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=18
  [->>+<<]
>>
                                                               ; ASSERT ptr=20
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=24
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=27
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=25
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=22
  [-[[-]>>>>+<<<<]]
; ============================================================ ; ; ; the carry out is bit 7 of that  and nothing else
>>>>
                                                               ; ASSERT ptr=26
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=20
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 1 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 2 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 3 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 4 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 5 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 6 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 7 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
                                                               ; ASSERT ptr=20
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ============================================================ ; ; ; the sum is twice the halves plus the two low bits
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=24
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=25
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=17
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 18:18
                                                               ; ASSERT zero 20:27

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=17
  [-<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>]
>>
                                                               ; ASSERT ptr=19

; ============================================================ ; ; and the carry out of that ripples up through the
                                                               ; rest

[                                                              ; ____ byte 2 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=28
  [-]+
<<<<<<<<<<<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=2
  +
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<]                                                          ; continued
>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=30
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >]                                                           ; continued
<
                                                               ; ASSERT ptr=29
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=19
]
                                                               ; ASSERT ptr=19
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=28
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=19

[                                                              ; ____ byte 3 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=28
  [-]+
<<<<<<<<<<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=3
  +
  [->>>>>>>>>>>>>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]                                                            ; continued
>>>>>>>>>>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=30
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=29
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=19
]
                                                               ; ASSERT ptr=19
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=28
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=19

[                                                              ; ____ byte 4 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=28
  [-]+
<<<<<<<<<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=4
  +
  [->>>>>>>>>>>>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=30
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=29
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=19
]
                                                               ; ASSERT ptr=19
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=28
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=19

[                                                              ; ____ byte 5 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=28
  [-]+
<<<<<<<<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=5
  +
  [->>>>>>>>>>>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=30
  [-<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=29
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=19
]
                                                               ; ASSERT ptr=19
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=28
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=19

[                                                              ; ____ byte 6 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=28
  [-]+
<<<<<<<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=6
  +
  [->>>>>>>>>>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=30
  [-<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=29
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=19
]
                                                               ; ASSERT ptr=19
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=28
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=19

[                                                              ; ____ byte 7 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=28
  [-]+
<<<<<<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=7
  +
  [->>>>>>>>>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=30
  [-<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=29
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=19
]
                                                               ; ASSERT ptr=19
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=28
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=19

[                                                              ; ____ byte 8 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=28
  [-]+
<<<<<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=8
  +
  [->>>>>>>>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=30
  [-<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=29
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=19
]
                                                               ; ASSERT ptr=19
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=28
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=19

[                                                              ; ____ byte 9 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=28
  [-]+
<<<<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=9
  +
  [->>>>>>>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=30
  [-<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=29
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=19
]
                                                               ; ASSERT ptr=19
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=28
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=19

[                                                              ; ____ byte 10 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=28
  [-]+
<<<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=10
  +
  [->>>>>>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=30
  [-<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=29
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=19
]
                                                               ; ASSERT ptr=19
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=28
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=19

[                                                              ; ____ byte 11 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=28
  [-]+
<<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=11
  +
  [->>>>>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=30
  [-<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=29
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=19
]
                                                               ; ASSERT ptr=19
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=28
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=19

[                                                              ; ____ byte 12 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=28
  [-]+
<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=12
  +
  [->>>>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=30
  [-<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=29
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=19
]
                                                               ; ASSERT ptr=19
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=28
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=19

[                                                              ; ____ byte 13 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=28
  [-]+
<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=13
  +
  [->>>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=30
  [-<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=29
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=19
]
                                                               ; ASSERT ptr=19
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=28
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=19

[                                                              ; ____ byte 14 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=28
  [-]+
<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=14
  +
  [->>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=30
  [-<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=29
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=19
]
                                                               ; ASSERT ptr=19
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=28
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=19

[                                                              ; ____ byte 15 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=28
  [-]+
<<<<<<<<<<<<<
                                                               ; ASSERT ptr=15
  +
  [->>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=30
  [-<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=29
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=19
]
                                                               ; ASSERT ptr=19
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=28
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=19

[                                                              ; ____ byte 16  which does not look  because its carry
  [-]                                                          ; ; cannot happen ____
<<<
                                                               ; ASSERT ptr=16
  +
>>>
                                                               ; ASSERT ptr=19
]
                                                               ; ASSERT ptr=19

; ============================================================ ; ; the value is folded
<<<<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=0
                                                               ; ASSERT zero 17:34
                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=0
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; back to the byte counter
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>>                                                       ; continued
]
                                                               ; ASSERT ptr=124

; ============================================================ ; the running double has done its work and is emptied
                                                               ; because the
; ============================================================ ; reduction below is pasted over the cells it was using
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<                                                ; continued
                                                               ; ASSERT ptr=51
  [-]
>                                                              ; the next byte
  [-]
>                                                              ; the next byte
  [-]
>                                                              ; the next byte
  [-]
>                                                              ; the next byte
  [-]
>                                                              ; the next byte
  [-]
>                                                              ; the next byte
  [-]
>                                                              ; the next byte
  [-]
>                                                              ; the next byte
  [-]
>                                                              ; the next byte
  [-]
>                                                              ; the next byte
  [-]
>                                                              ; the next byte
  [-]
>                                                              ; the next byte
  [-]
>                                                              ; the next byte
  [-]
>                                                              ; the next byte
  [-]
>                                                              ; the next byte
  [-]
>                                                              ; the next byte
  [-]
                                                               ; ASSERT ptr=67
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; to the answer
  <<<<<<<                                                      ; continued
                                                               ; ASSERT ptr=0
                                                               ; ASSERT zero 17:104
  >>>>>>>>>>>>>>>>                                             ; walk in to this routine entry offset
                                                               ; ASSERT ptr=16
                                                               ; ASSERT zero 17:104

; ============================================================ ; ; one fold is all this needs  and spec/perm_cry
                                                               ; proves
<<<<<<<<<<<<<<<<                                               ; ; it
                                                               ; ASSERT ptr=0
                                                               ; ASSERT zero 17:50
  >>>>>>>>>>>>>>>>                                             ; walk in to this routine entry offset

; ============================================================ ; ; ; split the top byte at bit 130
                                                               ; ASSERT ptr=16
                                                               ; ASSERT zero 17:34
  [->>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<]                           ; the top byte steps into the halving frame
>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=31
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; the first halving; the bit it drops is bit 128
>>                                                             ; which is worth one in what is left below the split
                                                               ; ASSERT ptr=33
  [-<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>]
<                                                              ; the half steps back into the frame to be halved again
                                                               ; ASSERT ptr=32
  [-<+>]
<
                                                               ; ASSERT ptr=31
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; the second halving; the bit it drops is bit 129
>>                                                             ; which is worth two
                                                               ; ASSERT ptr=33
  [-<<<<<<<<<<<<<<<<<++>>>>>>>>>>>>>>>>>]
<                                                              ; and what is left in the quotient is everything at bit
                                                               ; 130 and above
                                                               ; ASSERT ptr=32
  [-<<+>>]

; ============================================================ ; ; ; two to the hundred and thirtieth is five  so five
                                                               ; times that part
<<                                                             ; to the part above the split
                                                               ; ASSERT ptr=30
                                                               ; it is spent ONCE  into four copies of itself and one
                                                               ; copy of itself  which is where the five comes from;
                                                               ; neither cell can wrap  because four times sixty three
                                                               ; is two hundred and fifty two
  [-<<<<<<<<<<<<<++++>+>>>>>>>>>>>>]
                                                               ; ASSERT ptr=30
<<<<<<<<<<<<<                                                  ; to the byte pair the eight bit adder works on
                                                               ; ASSERT ptr=17
                                                               ; ASSERT zero 19:27
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=18
                                                               ; ASSERT zero 20:27
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=17
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=20
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=18
  [->>+<<]
>>
                                                               ; ASSERT ptr=20
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=24
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=27
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=25
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=22
  [-[[-]>>>>+<<<<]]
; ============================================================ ; ; ; ; the carry out is bit 7 of that  and nothing
                                                               ; else
>>>>
                                                               ; ASSERT ptr=26
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=20
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 1 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 2 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 3 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 4 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 5 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 6 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 7 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
                                                               ; ASSERT ptr=20
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ============================================================ ; ; ; ; the sum is twice the halves plus the two low
                                                               ; bits
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=24
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=25
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=17
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 18:18
                                                               ; ASSERT zero 20:27

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=17
  [->>>>>>>>>>>+<<<<<<<<<<<]                                   ; the sum is five times H modulo 256  and it is the
                                                               ; addend's low byte
>>                                                             ; to the carry add8 computed
                                                               ; ASSERT ptr=19
  [->>>>>>>>>>+<<<<<<<<<<]                                     ; which is the addend's high byte  worth two hundred
                                                               ; and fifty six

; ============================================================ ; ; ; the bottom byte of the value takes the low byte
                                                               ; of
<<<<<<<<<<<<<<<<<<<                                            ; ; five times H
                                                               ; ASSERT ptr=0
  [->>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=28
  [-<<<<<<<<<<+>>>>>>>>>>]
<<<<<<<<<<<
                                                               ; ASSERT ptr=17
                                                               ; ASSERT zero 19:27
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=18
                                                               ; ASSERT zero 20:27
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=17
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=20
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=18
  [->>+<<]
>>
                                                               ; ASSERT ptr=20
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=24
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=27
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=25
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=22
  [-[[-]>>>>+<<<<]]
; ============================================================ ; ; ; ; the carry out is bit 7 of that  and nothing
                                                               ; else
>>>>
                                                               ; ASSERT ptr=26
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=20
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 1 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 2 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 3 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 4 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 5 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 6 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 7 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
                                                               ; ASSERT ptr=20
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ============================================================ ; ; ; ; the sum is twice the halves plus the two low
                                                               ; bits
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=24
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=25
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=17
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 18:18
                                                               ; ASSERT zero 20:27

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=17
  [-<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>]                       ; the sum goes home and the carry stays where add8 left
                                                               ; it

; ============================================================ ; ; ; the second byte takes the high byte  and that
                                                               ; carry
<<<<<<<<<<<<<<<<                                               ; ; with it
                                                               ; ASSERT ptr=1
  [->>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=29
  [-<<<<<<<<<<<+>>>>>>>>>>>]
<<<<<<<<<<
                                                               ; ASSERT ptr=19
  [-<+>]
<<
                                                               ; ASSERT ptr=17
                                                               ; ASSERT zero 19:27
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=18
                                                               ; ASSERT zero 20:27
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=17
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=20
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=18
  [->>+<<]
>>
                                                               ; ASSERT ptr=20
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=24
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=27
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=25
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=22
  [-[[-]>>>>+<<<<]]
; ============================================================ ; ; ; ; the carry out is bit 7 of that  and nothing
                                                               ; else
>>>>
                                                               ; ASSERT ptr=26
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=20
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 1 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 2 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 3 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 4 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 5 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 6 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 7 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
                                                               ; ASSERT ptr=20
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ============================================================ ; ; ; ; the sum is twice the halves plus the two low
                                                               ; bits
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=24
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=25
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=17
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 18:18
                                                               ; ASSERT zero 20:27

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=17
  [-<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>]
>>
                                                               ; ASSERT ptr=19

; ============================================================ ; ; ; and the carry out of that ripples up through the
                                                               ; rest

[                                                              ; ____ byte 2 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=28
  [-]+
<<<<<<<<<<<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=2
  +
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<]                                                          ; continued
>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=30
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >]                                                           ; continued
<
                                                               ; ASSERT ptr=29
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=19
]
                                                               ; ASSERT ptr=19
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=28
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=19

[                                                              ; ____ byte 3 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=28
  [-]+
<<<<<<<<<<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=3
  +
  [->>>>>>>>>>>>>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]                                                            ; continued
>>>>>>>>>>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=30
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=29
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=19
]
                                                               ; ASSERT ptr=19
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=28
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=19

[                                                              ; ____ byte 4 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=28
  [-]+
<<<<<<<<<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=4
  +
  [->>>>>>>>>>>>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=30
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=29
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=19
]
                                                               ; ASSERT ptr=19
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=28
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=19

[                                                              ; ____ byte 5 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=28
  [-]+
<<<<<<<<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=5
  +
  [->>>>>>>>>>>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=30
  [-<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=29
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=19
]
                                                               ; ASSERT ptr=19
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=28
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=19

[                                                              ; ____ byte 6 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=28
  [-]+
<<<<<<<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=6
  +
  [->>>>>>>>>>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=30
  [-<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=29
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=19
]
                                                               ; ASSERT ptr=19
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=28
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=19

[                                                              ; ____ byte 7 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=28
  [-]+
<<<<<<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=7
  +
  [->>>>>>>>>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=30
  [-<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=29
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=19
]
                                                               ; ASSERT ptr=19
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=28
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=19

[                                                              ; ____ byte 8 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=28
  [-]+
<<<<<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=8
  +
  [->>>>>>>>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=30
  [-<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=29
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=19
]
                                                               ; ASSERT ptr=19
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=28
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=19

[                                                              ; ____ byte 9 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=28
  [-]+
<<<<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=9
  +
  [->>>>>>>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=30
  [-<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=29
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=19
]
                                                               ; ASSERT ptr=19
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=28
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=19

[                                                              ; ____ byte 10 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=28
  [-]+
<<<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=10
  +
  [->>>>>>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=30
  [-<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=29
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=19
]
                                                               ; ASSERT ptr=19
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=28
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=19

[                                                              ; ____ byte 11 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=28
  [-]+
<<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=11
  +
  [->>>>>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=30
  [-<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=29
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=19
]
                                                               ; ASSERT ptr=19
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=28
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=19

[                                                              ; ____ byte 12 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=28
  [-]+
<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=12
  +
  [->>>>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=30
  [-<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=29
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=19
]
                                                               ; ASSERT ptr=19
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=28
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=19

[                                                              ; ____ byte 13 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=28
  [-]+
<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=13
  +
  [->>>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=30
  [-<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=29
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=19
]
                                                               ; ASSERT ptr=19
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=28
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=19

[                                                              ; ____ byte 14 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=28
  [-]+
<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=14
  +
  [->>>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=30
  [-<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=29
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=19
]
                                                               ; ASSERT ptr=19
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=28
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=19

[                                                              ; ____ byte 15 ____
  [-]
>>>>>>>>>
                                                               ; ASSERT ptr=28
  [-]+
<<<<<<<<<<<<<
                                                               ; ASSERT ptr=15
  +
  [->>>>>>>>>>>>>>+>+<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=30
  [-<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>]
<
                                                               ; ASSERT ptr=29
  [[-]<[-]>]
<<<<<<<<<<
                                                               ; ASSERT ptr=19
]
                                                               ; ASSERT ptr=19
                                                               ; whatever is left of the else arm is the carry into
                                                               ; the byte above; it is set INSIDE the loop above and
                                                               ; moved out AFTER it  because a loop that sets its own
                                                               ; condition runs again  and the first draft of this
                                                               ; file did exactly that and carried into the same byte
                                                               ; twice
>>>>>>>>>
                                                               ; ASSERT ptr=28
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<
                                                               ; ASSERT ptr=19

[                                                              ; ____ byte 16  which does not look  because its carry
  [-]                                                          ; ; cannot happen ____
<<<
                                                               ; ASSERT ptr=16
  +
>>>
                                                               ; ASSERT ptr=19
]
                                                               ; ASSERT ptr=19

; ============================================================ ; ; ; the value is folded
<<<<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=0
                                                               ; ASSERT zero 17:34
                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=0

; ============================================================ ; ; keep a copy  because the five may have to be taken
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; ; back off
  +>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<]                                                      ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<]                                                      ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<]                                                      ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<]                                                      ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<]                                                      ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<]                                                      ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<]                                                      ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<]                                                      ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<]                                                      ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<]                                                      ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<]                                                      ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<]                                                      ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<]                                                      ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<]                                                      ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<]                                                      ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<]                                                      ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<]                                                      ; continued
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; the temps hand the value straight back
  >>>>>>>>>>>>                                                 ; continued
                                                               ; ASSERT ptr=88
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>]                                                       ; continued
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>]                                                       ; continued
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>]                                                       ; continued
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>]                                                       ; continued
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>]                                                       ; continued
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>]                                                       ; continued
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>]                                                       ; continued
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>]                                                       ; continued
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>]                                                       ; continued
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>]                                                       ; continued
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>]                                                       ; continued
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>]                                                       ; continued
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>]                                                       ; continued
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>]                                                       ; continued
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>]                                                       ; continued
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>]                                                       ; continued
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>]                                                       ; continued
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<                 ; continued
                                                               ; ASSERT ptr=0

; ============================================================ ; ; add five
>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=17
  +++++
<<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=0
                                                               ; ASSERT zero 34:45
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>                           ; walk in to this routine entry offset
                                                               ; ASSERT ptr=34
                                                               ; ASSERT zero 34:45

; ============================================================ ; ; ; byte 0
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<                             ; the accumulator byte steps into the adder
                                                               ; ASSERT ptr=0
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<]                                             ; continued
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>>                                             ; to the kernel's base  which is where a paste site
                                                               ; always stands
                                                               ; ASSERT ptr=35
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=36
                                                               ; ASSERT zero 38:45
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=35
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=36
  [->>+<<]
>>
                                                               ; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=42
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=45
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=43
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=40
  [-[[-]>>>>+<<<<]]
; ============================================================ ; ; ; ; the carry out is bit 7 of that  and nothing
                                                               ; else
>>>>
                                                               ; ASSERT ptr=44
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 1 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 2 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 3 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 4 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 5 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 6 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 7 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
                                                               ; ASSERT ptr=38
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ============================================================ ; ; ; ; the sum is twice the halves plus the two low
                                                               ; bits
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=42
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=43
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=35
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 36:36
                                                               ; ASSERT zero 38:45

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=35
<                                                              ; the carry in is nought or one  so it takes the old
  [->>+<<]                                                     ; ; kernel
>>
                                                               ; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>]                                             ; continued
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
<<<
                                                               ; ASSERT ptr=34
                                                               ; ASSERT zero 35:45

; ============================================================ ; ; ; byte 1
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<                              ; the accumulator byte steps into the adder
                                                               ; ASSERT ptr=1
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<]                                               ; continued
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>                                              ; to the kernel's base  which is where a paste site
                                                               ; always stands
                                                               ; ASSERT ptr=35
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=36
                                                               ; ASSERT zero 38:45
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=35
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=36
  [->>+<<]
>>
                                                               ; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=42
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=45
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=43
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=40
  [-[[-]>>>>+<<<<]]
; ============================================================ ; ; ; ; the carry out is bit 7 of that  and nothing
                                                               ; else
>>>>
                                                               ; ASSERT ptr=44
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 1 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 2 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 3 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 4 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 5 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 6 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 7 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
                                                               ; ASSERT ptr=38
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ============================================================ ; ; ; ; the sum is twice the halves plus the two low
                                                               ; bits
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=42
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=43
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=35
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 36:36
                                                               ; ASSERT zero 38:45

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=35
<                                                              ; the carry in is nought or one  so it takes the old
  [->>+<<]                                                     ; ; kernel
>>
                                                               ; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>]                                               ; continued
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
<<<
                                                               ; ASSERT ptr=34
                                                               ; ASSERT zero 35:45

; ============================================================ ; ; ; byte 2
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<                               ; the accumulator byte steps into the adder
                                                               ; ASSERT ptr=2
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<]                                                 ; continued
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>                                               ; to the kernel's base  which is where a paste site
                                                               ; always stands
                                                               ; ASSERT ptr=35
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=36
                                                               ; ASSERT zero 38:45
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=35
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=36
  [->>+<<]
>>
                                                               ; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=42
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=45
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=43
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=40
  [-[[-]>>>>+<<<<]]
; ============================================================ ; ; ; ; the carry out is bit 7 of that  and nothing
                                                               ; else
>>>>
                                                               ; ASSERT ptr=44
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 1 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 2 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 3 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 4 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 5 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 6 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 7 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
                                                               ; ASSERT ptr=38
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ============================================================ ; ; ; ; the sum is twice the halves plus the two low
                                                               ; bits
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=42
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=43
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=35
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 36:36
                                                               ; ASSERT zero 38:45

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=35
<                                                              ; the carry in is nought or one  so it takes the old
  [->>+<<]                                                     ; ; kernel
>>
                                                               ; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>]                                                 ; continued
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
<<<
                                                               ; ASSERT ptr=34
                                                               ; ASSERT zero 35:45

; ============================================================ ; ; ; byte 3
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<                                ; the accumulator byte steps into the adder
                                                               ; ASSERT ptr=3
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<]                                                   ; continued
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>                                                ; to the kernel's base  which is where a paste site
                                                               ; always stands
                                                               ; ASSERT ptr=35
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=36
                                                               ; ASSERT zero 38:45
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=35
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=36
  [->>+<<]
>>
                                                               ; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=42
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=45
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=43
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=40
  [-[[-]>>>>+<<<<]]
; ============================================================ ; ; ; ; the carry out is bit 7 of that  and nothing
                                                               ; else
>>>>
                                                               ; ASSERT ptr=44
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 1 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 2 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 3 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 4 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 5 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 6 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 7 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
                                                               ; ASSERT ptr=38
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ============================================================ ; ; ; ; the sum is twice the halves plus the two low
                                                               ; bits
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=42
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=43
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=35
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 36:36
                                                               ; ASSERT zero 38:45

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=35
<                                                              ; the carry in is nought or one  so it takes the old
  [->>+<<]                                                     ; ; kernel
>>
                                                               ; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>]                                                   ; continued
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
<<<
                                                               ; ASSERT ptr=34
                                                               ; ASSERT zero 35:45

; ============================================================ ; ; ; byte 4
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<                                 ; the accumulator byte steps into the adder
                                                               ; ASSERT ptr=4
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<]                                                     ; continued
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>                                                 ; to the kernel's base  which is where a paste site
                                                               ; always stands
                                                               ; ASSERT ptr=35
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=36
                                                               ; ASSERT zero 38:45
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=35
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=36
  [->>+<<]
>>
                                                               ; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=42
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=45
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=43
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=40
  [-[[-]>>>>+<<<<]]
; ============================================================ ; ; ; ; the carry out is bit 7 of that  and nothing
                                                               ; else
>>>>
                                                               ; ASSERT ptr=44
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 1 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 2 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 3 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 4 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 5 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 6 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 7 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
                                                               ; ASSERT ptr=38
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ============================================================ ; ; ; ; the sum is twice the halves plus the two low
                                                               ; bits
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=42
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=43
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=35
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 36:36
                                                               ; ASSERT zero 38:45

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=35
<                                                              ; the carry in is nought or one  so it takes the old
  [->>+<<]                                                     ; ; kernel
>>
                                                               ; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>]                                                     ; continued
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
<<<
                                                               ; ASSERT ptr=34
                                                               ; ASSERT zero 35:45

; ============================================================ ; ; ; byte 5
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<                                  ; the accumulator byte steps into the adder
                                                               ; ASSERT ptr=5
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<]                                                       ; continued
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>>>>>>>>>>>>+<<<<<<<<<<<<<<]
>>>>>>>>>>>>>                                                  ; to the kernel's base  which is where a paste site
                                                               ; always stands
                                                               ; ASSERT ptr=35
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=36
                                                               ; ASSERT zero 38:45
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=35
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=36
  [->>+<<]
>>
                                                               ; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=42
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=45
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=43
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=40
  [-[[-]>>>>+<<<<]]
; ============================================================ ; ; ; ; the carry out is bit 7 of that  and nothing
                                                               ; else
>>>>
                                                               ; ASSERT ptr=44
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 1 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 2 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 3 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 4 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 5 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 6 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 7 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
                                                               ; ASSERT ptr=38
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ============================================================ ; ; ; ; the sum is twice the halves plus the two low
                                                               ; bits
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=42
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=43
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=35
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 36:36
                                                               ; ASSERT zero 38:45

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=35
<                                                              ; the carry in is nought or one  so it takes the old
  [->>+<<]                                                     ; ; kernel
>>
                                                               ; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>]                                                       ; continued
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
<<<
                                                               ; ASSERT ptr=34
                                                               ; ASSERT zero 35:45

; ============================================================ ; ; ; byte 6
<<<<<<<<<<<<<<<<<<<<<<<<<<<<                                   ; the accumulator byte steps into the adder
                                                               ; ASSERT ptr=6
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<]                                                         ; continued
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>>>>>>>>>>>+<<<<<<<<<<<<<]
>>>>>>>>>>>>                                                   ; to the kernel's base  which is where a paste site
                                                               ; always stands
                                                               ; ASSERT ptr=35
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=36
                                                               ; ASSERT zero 38:45
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=35
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=36
  [->>+<<]
>>
                                                               ; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=42
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=45
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=43
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=40
  [-[[-]>>>>+<<<<]]
; ============================================================ ; ; ; ; the carry out is bit 7 of that  and nothing
                                                               ; else
>>>>
                                                               ; ASSERT ptr=44
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 1 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 2 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 3 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 4 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 5 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 6 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 7 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
                                                               ; ASSERT ptr=38
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ============================================================ ; ; ; ; the sum is twice the halves plus the two low
                                                               ; bits
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=42
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=43
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=35
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 36:36
                                                               ; ASSERT zero 38:45

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=35
<                                                              ; the carry in is nought or one  so it takes the old
  [->>+<<]                                                     ; ; kernel
>>
                                                               ; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>]                                                         ; continued
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
<<<
                                                               ; ASSERT ptr=34
                                                               ; ASSERT zero 35:45

; ============================================================ ; ; ; byte 7
<<<<<<<<<<<<<<<<<<<<<<<<<<<                                    ; the accumulator byte steps into the adder
                                                               ; ASSERT ptr=7
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <]                                                           ; continued
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>>>>>>>>>>+<<<<<<<<<<<<]
>>>>>>>>>>>                                                    ; to the kernel's base  which is where a paste site
                                                               ; always stands
                                                               ; ASSERT ptr=35
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=36
                                                               ; ASSERT zero 38:45
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=35
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=36
  [->>+<<]
>>
                                                               ; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=42
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=45
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=43
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=40
  [-[[-]>>>>+<<<<]]
; ============================================================ ; ; ; ; the carry out is bit 7 of that  and nothing
                                                               ; else
>>>>
                                                               ; ASSERT ptr=44
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 1 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 2 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 3 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 4 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 5 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 6 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 7 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
                                                               ; ASSERT ptr=38
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ============================================================ ; ; ; ; the sum is twice the halves plus the two low
                                                               ; bits
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=42
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=43
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=35
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 36:36
                                                               ; ASSERT zero 38:45

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=35
<                                                              ; the carry in is nought or one  so it takes the old
  [->>+<<]                                                     ; ; kernel
>>
                                                               ; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >]                                                           ; continued
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
<<<
                                                               ; ASSERT ptr=34
                                                               ; ASSERT zero 35:45

; ============================================================ ; ; ; byte 8
<<<<<<<<<<<<<<<<<<<<<<<<<<                                     ; the accumulator byte steps into the adder
                                                               ; ASSERT ptr=8
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>>>>>>>>>+<<<<<<<<<<<]
>>>>>>>>>>                                                     ; to the kernel's base  which is where a paste site
                                                               ; always stands
                                                               ; ASSERT ptr=35
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=36
                                                               ; ASSERT zero 38:45
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=35
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=36
  [->>+<<]
>>
                                                               ; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=42
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=45
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=43
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=40
  [-[[-]>>>>+<<<<]]
; ============================================================ ; ; ; ; the carry out is bit 7 of that  and nothing
                                                               ; else
>>>>
                                                               ; ASSERT ptr=44
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 1 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 2 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 3 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 4 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 5 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 6 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 7 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
                                                               ; ASSERT ptr=38
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ============================================================ ; ; ; ; the sum is twice the halves plus the two low
                                                               ; bits
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=42
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=43
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=35
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 36:36
                                                               ; ASSERT zero 38:45

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=35
<                                                              ; the carry in is nought or one  so it takes the old
  [->>+<<]                                                     ; ; kernel
>>
                                                               ; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>>]
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
<<<
                                                               ; ASSERT ptr=34
                                                               ; ASSERT zero 35:45

; ============================================================ ; ; ; byte 9
<<<<<<<<<<<<<<<<<<<<<<<<<                                      ; the accumulator byte steps into the adder
                                                               ; ASSERT ptr=9
  [->>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>>>>>>>>+<<<<<<<<<<]
>>>>>>>>>                                                      ; to the kernel's base  which is where a paste site
                                                               ; always stands
                                                               ; ASSERT ptr=35
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=36
                                                               ; ASSERT zero 38:45
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=35
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=36
  [->>+<<]
>>
                                                               ; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=42
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=45
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=43
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=40
  [-[[-]>>>>+<<<<]]
; ============================================================ ; ; ; ; the carry out is bit 7 of that  and nothing
                                                               ; else
>>>>
                                                               ; ASSERT ptr=44
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 1 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 2 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 3 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 4 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 5 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 6 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 7 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
                                                               ; ASSERT ptr=38
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ============================================================ ; ; ; ; the sum is twice the halves plus the two low
                                                               ; bits
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=42
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=43
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=35
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 36:36
                                                               ; ASSERT zero 38:45

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=35
<                                                              ; the carry in is nought or one  so it takes the old
  [->>+<<]                                                     ; ; kernel
>>
                                                               ; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>]
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
<<<
                                                               ; ASSERT ptr=34
                                                               ; ASSERT zero 35:45

; ============================================================ ; ; ; byte 10
<<<<<<<<<<<<<<<<<<<<<<<<                                       ; the accumulator byte steps into the adder
                                                               ; ASSERT ptr=10
  [->>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>>>>>>>+<<<<<<<<<]
>>>>>>>>                                                       ; to the kernel's base  which is where a paste site
                                                               ; always stands
                                                               ; ASSERT ptr=35
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=36
                                                               ; ASSERT zero 38:45
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=35
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=36
  [->>+<<]
>>
                                                               ; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=42
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=45
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=43
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=40
  [-[[-]>>>>+<<<<]]
; ============================================================ ; ; ; ; the carry out is bit 7 of that  and nothing
                                                               ; else
>>>>
                                                               ; ASSERT ptr=44
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 1 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 2 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 3 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 4 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 5 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 6 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 7 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
                                                               ; ASSERT ptr=38
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ============================================================ ; ; ; ; the sum is twice the halves plus the two low
                                                               ; bits
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=42
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=43
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=35
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 36:36
                                                               ; ASSERT zero 38:45

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=35
<                                                              ; the carry in is nought or one  so it takes the old
  [->>+<<]                                                     ; ; kernel
>>
                                                               ; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>]
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
<<<
                                                               ; ASSERT ptr=34
                                                               ; ASSERT zero 35:45

; ============================================================ ; ; ; byte 11
<<<<<<<<<<<<<<<<<<<<<<<                                        ; the accumulator byte steps into the adder
                                                               ; ASSERT ptr=11
  [->>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>>>>>>+<<<<<<<<]
>>>>>>>                                                        ; to the kernel's base  which is where a paste site
                                                               ; always stands
                                                               ; ASSERT ptr=35
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=36
                                                               ; ASSERT zero 38:45
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=35
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=36
  [->>+<<]
>>
                                                               ; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=42
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=45
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=43
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=40
  [-[[-]>>>>+<<<<]]
; ============================================================ ; ; ; ; the carry out is bit 7 of that  and nothing
                                                               ; else
>>>>
                                                               ; ASSERT ptr=44
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 1 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 2 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 3 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 4 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 5 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 6 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 7 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
                                                               ; ASSERT ptr=38
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ============================================================ ; ; ; ; the sum is twice the halves plus the two low
                                                               ; bits
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=42
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=43
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=35
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 36:36
                                                               ; ASSERT zero 38:45

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=35
<                                                              ; the carry in is nought or one  so it takes the old
  [->>+<<]                                                     ; ; kernel
>>
                                                               ; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>]
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
<<<
                                                               ; ASSERT ptr=34
                                                               ; ASSERT zero 35:45

; ============================================================ ; ; ; byte 12
<<<<<<<<<<<<<<<<<<<<<<                                         ; the accumulator byte steps into the adder
                                                               ; ASSERT ptr=12
  [->>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>>>>>+<<<<<<<]
>>>>>>                                                         ; to the kernel's base  which is where a paste site
                                                               ; always stands
                                                               ; ASSERT ptr=35
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=36
                                                               ; ASSERT zero 38:45
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=35
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=36
  [->>+<<]
>>
                                                               ; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=42
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=45
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=43
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=40
  [-[[-]>>>>+<<<<]]
; ============================================================ ; ; ; ; the carry out is bit 7 of that  and nothing
                                                               ; else
>>>>
                                                               ; ASSERT ptr=44
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 1 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 2 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 3 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 4 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 5 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 6 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 7 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
                                                               ; ASSERT ptr=38
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ============================================================ ; ; ; ; the sum is twice the halves plus the two low
                                                               ; bits
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=42
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=43
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=35
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 36:36
                                                               ; ASSERT zero 38:45

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=35
<                                                              ; the carry in is nought or one  so it takes the old
  [->>+<<]                                                     ; ; kernel
>>
                                                               ; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>]
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
<<<
                                                               ; ASSERT ptr=34
                                                               ; ASSERT zero 35:45

; ============================================================ ; ; ; byte 13
<<<<<<<<<<<<<<<<<<<<<                                          ; the accumulator byte steps into the adder
                                                               ; ASSERT ptr=13
  [->>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>>>>+<<<<<<]
>>>>>                                                          ; to the kernel's base  which is where a paste site
                                                               ; always stands
                                                               ; ASSERT ptr=35
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=36
                                                               ; ASSERT zero 38:45
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=35
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=36
  [->>+<<]
>>
                                                               ; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=42
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=45
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=43
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=40
  [-[[-]>>>>+<<<<]]
; ============================================================ ; ; ; ; the carry out is bit 7 of that  and nothing
                                                               ; else
>>>>
                                                               ; ASSERT ptr=44
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 1 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 2 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 3 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 4 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 5 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 6 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 7 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
                                                               ; ASSERT ptr=38
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ============================================================ ; ; ; ; the sum is twice the halves plus the two low
                                                               ; bits
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=42
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=43
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=35
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 36:36
                                                               ; ASSERT zero 38:45

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=35
<                                                              ; the carry in is nought or one  so it takes the old
  [->>+<<]                                                     ; ; kernel
>>
                                                               ; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>]
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
<<<
                                                               ; ASSERT ptr=34
                                                               ; ASSERT zero 35:45

; ============================================================ ; ; ; byte 14
<<<<<<<<<<<<<<<<<<<<                                           ; the accumulator byte steps into the adder
                                                               ; ASSERT ptr=14
  [->>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>>>+<<<<<]
>>>>                                                           ; to the kernel's base  which is where a paste site
                                                               ; always stands
                                                               ; ASSERT ptr=35
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=36
                                                               ; ASSERT zero 38:45
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=35
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=36
  [->>+<<]
>>
                                                               ; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=42
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=45
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=43
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=40
  [-[[-]>>>>+<<<<]]
; ============================================================ ; ; ; ; the carry out is bit 7 of that  and nothing
                                                               ; else
>>>>
                                                               ; ASSERT ptr=44
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 1 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 2 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 3 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 4 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 5 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 6 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 7 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
                                                               ; ASSERT ptr=38
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ============================================================ ; ; ; ; the sum is twice the halves plus the two low
                                                               ; bits
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=42
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=43
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=35
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 36:36
                                                               ; ASSERT zero 38:45

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=35
<                                                              ; the carry in is nought or one  so it takes the old
  [->>+<<]                                                     ; ; kernel
>>
                                                               ; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>]
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
<<<
                                                               ; ASSERT ptr=34
                                                               ; ASSERT zero 35:45

; ============================================================ ; ; ; byte 15
<<<<<<<<<<<<<<<<<<<                                            ; the accumulator byte steps into the adder
                                                               ; ASSERT ptr=15
  [->>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>>+<<<<]
>>>                                                            ; to the kernel's base  which is where a paste site
                                                               ; always stands
                                                               ; ASSERT ptr=35
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=36
                                                               ; ASSERT zero 38:45
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=35
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=36
  [->>+<<]
>>
                                                               ; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=42
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=45
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=43
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=40
  [-[[-]>>>>+<<<<]]
; ============================================================ ; ; ; ; the carry out is bit 7 of that  and nothing
                                                               ; else
>>>>
                                                               ; ASSERT ptr=44
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 1 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 2 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 3 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 4 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 5 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 6 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 7 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
                                                               ; ASSERT ptr=38
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ============================================================ ; ; ; ; the sum is twice the halves plus the two low
                                                               ; bits
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=42
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=43
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=35
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 36:36
                                                               ; ASSERT zero 38:45

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=35
<                                                              ; the carry in is nought or one  so it takes the old
  [->>+<<]                                                     ; ; kernel
>>
                                                               ; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>]
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
<<<
                                                               ; ASSERT ptr=34
                                                               ; ASSERT zero 35:45

; ============================================================ ; ; ; byte 16
<<<<<<<<<<<<<<<<<<                                             ; the accumulator byte steps into the adder
                                                               ; ASSERT ptr=16
  [->>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<]
>>>>>>>>>>>>>>>>>                                              ; the addend byte follows it
  [->>>+<<<]
>>                                                             ; to the kernel's base  which is where a paste site
                                                               ; always stands
                                                               ; ASSERT ptr=35
  >                                                            ; walk in to this routine entry offset
                                                               ; the carry cell is NOT required to be clear: this
                                                               ; routine ADDS into it  and a wide adder may have put
                                                               ; something there; only the scratch must be clean;
                                                               ; ASSERT ptr=36
                                                               ; ASSERT zero 38:45
<                                                              ; to the accumulator
                                                               ; ASSERT ptr=35
  [->>>+<<<]                                                   ; the accumulator steps into the halving frame
>>>
                                                               ; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the accumulator's
                                                               ; low bit
>                                                              ; the half is kept
  [->>>+<<<]
>                                                              ; and the low bit joins the low bit sum
  [->>>+<<<]
<<<<                                                           ; the addend steps into the halving frame
                                                               ; ASSERT ptr=36
  [->>+<<]
>>
                                                               ; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving; the bit that falls off is the addend's low
                                                               ; bit
>                                                              ; the halves are added  and cannot overflow because
  [->>>+<<<]                                                   ; ; each is at most 127
>                                                              ; and the low bits are added  giving nought one or two
  [->>>+<<<]
>>                                                             ; the sum of halves is copied  because the carry test
                                                               ; consumes what it reads
                                                               ; ASSERT ptr=42
  [->>+>+<<<]
>>>                                                            ; the spare hands it straight back
                                                               ; ASSERT ptr=45
  [-<<<+>>>]
<<                                                             ; the low bit sum is copied the same way
                                                               ; ASSERT ptr=43
  [-<<<+>>>>>+<<]
>>
  [-<<+>>]
                                                               ; both low bits set is a carry into the halves; that is
                                                               ; the AND  and it is what the copy is spent on: two
                                                               ; means both  one or nought means not both
<<<<<
                                                               ; ASSERT ptr=40
  [-[[-]>>>>+<<<<]]
; ============================================================ ; ; ; ; the carry out is bit 7 of that  and nothing
                                                               ; else
>>>>
                                                               ; ASSERT ptr=44
  [-<<<<<<+>>>>>>]
<<<<<<
                                                               ; ASSERT ptr=38
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 1 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 2 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 3 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 4 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 5 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 6 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
  [->>>+<[-<+>>-<]>[-<+>]<<<]                                  ; halving 7 of seven; the bit that falls off is not
>>                                                             ; ; wanted
  [-]
<<
>
  [-<+>]
<
                                                               ; ASSERT ptr=38
  [-<+>]                                                       ; what is left is bit 7  which is the carry  and it is
                                                               ; ADDED into the carry cell
; ============================================================ ; ; ; ; the sum is twice the halves plus the two low
                                                               ; bits
>>>>                                                           ; The cell wraps at 256 and that is exactly the modulo
                                                               ; the sum wants;
                                                               ; ASSERT ptr=42
  [-<<<<<<<++>>>>>>>]
>
                                                               ; ASSERT ptr=43
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<                                                       ; home
                                                               ; ASSERT ptr=35
                                                               ; the addend is spent and every scratch cell is back at
                                                               ; nought; @0x00 holds the sum and @0x02 the carry  so
                                                               ; neither is claimed to be clear;
                                                               ; ASSERT zero 36:36
                                                               ; ASSERT zero 38:45

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=35
<                                                              ; the carry in is nought or one  so it takes the old
  [->>+<<]                                                     ; ; kernel
>>
                                                               ; ASSERT ptr=36
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
<                                                              ; the low byte of the sum goes back where it came from
  [-<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>]
>>                                                             ; and the carry out becomes the carry in for the next
  [-<<<+>>>]                                                   ; ; byte
<<<
                                                               ; ASSERT ptr=34
                                                               ; ASSERT zero 35:45

                                                               ; the carry out of the top byte is dropped  and cleared
                                                               ; so the frame is as empty as it was found
                                                               ; ASSERT ptr=34
  [-]
                                                               ; ASSERT zero 17:45

  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<                           ; walk back out to the routine base
                                                               ; ASSERT ptr=0

; ============================================================ ; ; did bit 130 come up
>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=16
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; the top byte steps into the halving frame
  >>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<]                                                       ; continued
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=75
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>                                                             ; bit 128 is worth one below the split
                                                               ; ASSERT ptr=77
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>>>>>]                                                   ; continued
<                                                              ; and the half is halved again
  [-<+>]
<
                                                               ; ASSERT ptr=75
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>                                                             ; bit 129 is worth two
                                                               ; ASSERT ptr=77
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<++>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>>>>>>]                                                  ; continued
                                                               ; what is left is bit 130  which is nought or one
                                                               ; because the value was below two to the hundred and
                                                               ; thirtieth before five was added to it
<
  [-<<<+>>>]
<<<
                                                               ; ASSERT ptr=73

; ============================================================ ; ; if it came up  the value had to be reduced and this
                                                               ; IS the answer
>                                                              ; the else arm is armed first  and the then arm disarms
  [-]                                                          ; ; it
  +
<
                                                               ; ASSERT ptr=73
[
  -
<<<<<<<<<<<<<<<<<                                              ; the saved copy is not wanted
                                                               ; ASSERT ptr=56
  [-]
>                                                              ; the next byte
  [-]
>                                                              ; the next byte
  [-]
>                                                              ; the next byte
  [-]
>                                                              ; the next byte
  [-]
>                                                              ; the next byte
  [-]
>                                                              ; the next byte
  [-]
>                                                              ; the next byte
  [-]
>                                                              ; the next byte
  [-]
>                                                              ; the next byte
  [-]
>                                                              ; the next byte
  [-]
>                                                              ; the next byte
  [-]
>                                                              ; the next byte
  [-]
>                                                              ; the next byte
  [-]
>                                                              ; the next byte
  [-]
>                                                              ; the next byte
  [-]
>                                                              ; the next byte
  [-]
>>                                                             ; disarm the else and go back to the flag
  -
<
]
; ============================================================ ; ; if it did not  the value is the copy from before
                                                               ; the
>                                                              ; ; five
                                                               ; ASSERT ptr=74
[
  -
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<                                               ; continued
                                                               ; ASSERT ptr=0
  [-]
>                                                              ; the next byte
  [-]
>                                                              ; the next byte
  [-]
>                                                              ; the next byte
  [-]
>                                                              ; the next byte
  [-]
>                                                              ; the next byte
  [-]
>                                                              ; the next byte
  [-]
>                                                              ; the next byte
  [-]
>                                                              ; the next byte
  [-]
>                                                              ; the next byte
  [-]
>                                                              ; the next byte
  [-]
>                                                              ; the next byte
  [-]
>                                                              ; the next byte
  [-]
>                                                              ; the next byte
  [-]
>                                                              ; the next byte
  [-]
>                                                              ; the next byte
  [-]
>                                                              ; the next byte
  [-]
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>                       ; the saved copy comes back
                                                               ; ASSERT ptr=56
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]   ; continued
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]   ; continued
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]   ; continued
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]   ; continued
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]   ; continued
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]   ; continued
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]   ; continued
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]   ; continued
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]   ; continued
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]   ; continued
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]   ; continued
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]   ; continued
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]   ; continued
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]   ; continued
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]   ; continued
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]   ; continued
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]   ; continued
>>                                                             ; back to the else flag
]
                                                               ; ASSERT ptr=74
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<                                               ; continued
                                                               ; ASSERT ptr=0
                                                               ; ASSERT zero 17:104
                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=0
                                                               ; ASSERT zero 17:124
; emit the product little endian
  .>.>.>.>.>.>.>.>.>.>.>.>.>.>.>.>.
