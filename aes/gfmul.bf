; bfsodium GFMUL : multiply two bytes in the AES field
;
; NOTE square brackets are brainfuck loops  so comments use braces for counts;
;
; HAND WRITTEN; aes/xtime is PASTED seven times and idiom/xor8 eight;
;
; INTERFACE entry=26 exit=0 footprint=0:29
; IO  in:  a{1} at @0x17  and  b{1} at @0x1a      (2 bytes)
;     out: the product{1} at @0x00                (1 byte)
;
; FIPS 197 section 4 point 2 : peasant multiplication over GF(2^8)  eight
; times round  and UNROLLED so that no counter is needed and every loop here
; is pointer balanced; That is what makes it pasteable;
;
;   for each of the eight bits of b  low first
;     if that bit is set  the product takes an exclusive or with a
;     a becomes xtime(a)  and b is halved
;
; THE BRANCH IS NOT A BRANCH; a paste cannot be made conditional  so the low
; bit GUARDS A COPY instead: a is copied into a scratch cell under a loop that
; runs the bit's own number of times  which is nought or one  and the
; exclusive or then runs unconditionally against nought or against a; That is
; the same trick aes/xtime uses for its reduction;
;
; THE EIGHTH XTIME IS NOT DONE because nothing would read it; that is thirty
; three thousand instructions saved out of four hundred thousand  which is the
; only optimization here and it is worth naming because the rest is the naive
; algorithm on purpose; It does mean the multiplicand survives the last turn
; and has to be CLEARED by hand at the end  which the contract at the foot of
; this file is what noticed;
;
; INVMIXCOLUMNS DOES NOT USE THIS  and it is worth saying so plainly so that
; nobody wires it up: multiplying by 9  11  13 and 14 the general way is
; sixteen of these per column  where the identity in aes/invmixcolumn is four
; xtimes and one aes/mixcolumn; This exists as the general primitive of the
; field  and because the cost of a general multiply had been ESTIMATED in
; three headers and never measured;
;
; THE ESTIMATE WAS LOW  as every estimate in this library has been; it was put
; at 450 thousand from the measured means of aes/xtime and idiom/xor8  and one
; multiply measures 581 thousand 610; The difference is the travel and the
; guarded copies  which is the same thing the block projection forgot twice;
;
; TAPE MAP  (home @0)
;   @0x00:0x15  the paste workspace; aes/xtime reaches 0 to 21 and idiom/xor8
;               reaches 0 to 16  and the PRODUCT comes to rest at @0x00
;   @0x16       acc   the product  accumulating
;   @0x17       a     the multiplicand  doubled each turn
;   @0x18       t     a guarded by the low bit  so nought or a
;   @0x19       g     the cell a copy hands its value back through
;   @0x1a       b     the multiplier  halved away to nought
;   @0x1b       bq    HALVE frame: b shifted right one
;   @0x1c       bl    HALVE frame: the low bit of b
;   @0x1d       bf    HALVE frame scratch  restored to nought

  >>>>>>>>>>>>>>>>>>>>>>>,>>>,                                 ; the multiplicand  then the multiplier three cells
                                                               ; above it
                                                               ; ASSERT ptr=26
                                                               ; ASSERT zero 0:21
  <<<<<<<<<<<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=0

; ============================================================ ; bit 0 of the multiplier
  >>>>>>>>>>>>>>>>>>>>>>>>>>                                   ; halve b  which leaves the quotient and the bit that
                                                               ; fell off
                                                               ; HALVE  the byte at this cell  with q t and f in the
                                                               ; three cells above it; q becomes it shifted right one
                                                               ; and t the bit that fell off; the pointer comes back
                                                               ; here; CONVENTIONS section 5 carries the vocabulary
                                                               ; entry;
  [->>>+<[-<+>>-<]>[-<+>]<<<]
  <<<<<<<<<<<<<<<<<<<<<<<<<<
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>[-<<<<<[->+>+<<]>>[-<<+>>]>>>]   ; the bit GUARDS a copy of a: nought or one turns of
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<                                 ; the loop
                                                               ; and the product takes an exclusive or with it  which
                                                               ; is the identity when the bit was clear
  >>>>>>>>>>>>>>>>>>>>>>[-<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>
  >>>>>>>>>]<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>[-   ; continued
  <<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>]<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<                                                 ; continued

                                                               ; ASSERT ptr=0
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
                                                               ; ASSERT ptr=15
<<                                                             ; the result comes home
                                                               ; ASSERT ptr=13
  [-<<<<<<<<<<<<<+>>>>>>>>>>>>>]
<<<<<<<<<<<<<
                                                               ; ASSERT ptr=0
                                                               ; ASSERT zero 1:16

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=0

  [->>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<]
  >>>>>>>>>>>>>>>>>>>>>>>[-<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>   ; a doubles in the field
  >>>>>>>>>>>>>>]<<<<<<<<<<<<<<<<<<<<<<<                       ; continued

                                                               ; ASSERT ptr=0
                                                               ; walk in to this routine entry offset

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
                                                               ; halving one of seven; the bit that falls off is not
                                                               ; wanted HALVE  the byte at this cell  with q t and f
                                                               ; in the three cells above it; q becomes it shifted
                                                               ; right one and t the bit that fell off; the pointer
                                                               ; comes back here; CONVENTIONS section 5 carries the
                                                               ; vocabulary entry;
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>
  [-]
<<
>
  [-<+>]
<
                                                               ; halving two of seven; the bit that falls off is not
                                                               ; wanted HALVE  the byte at this cell  with q t and f
                                                               ; in the three cells above it; q becomes it shifted
                                                               ; right one and t the bit that fell off; the pointer
                                                               ; comes back here; CONVENTIONS section 5 carries the
                                                               ; vocabulary entry;
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>
  [-]
<<
>
  [-<+>]
<
                                                               ; halving three of seven; the bit that falls off is not
                                                               ; wanted HALVE  the byte at this cell  with q t and f
                                                               ; in the three cells above it; q becomes it shifted
                                                               ; right one and t the bit that fell off; the pointer
                                                               ; comes back here; CONVENTIONS section 5 carries the
                                                               ; vocabulary entry;
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>
  [-]
<<
>
  [-<+>]
<
                                                               ; halving four of seven; the bit that falls off is not
                                                               ; wanted HALVE  the byte at this cell  with q t and f
                                                               ; in the three cells above it; q becomes it shifted
                                                               ; right one and t the bit that fell off; the pointer
                                                               ; comes back here; CONVENTIONS section 5 carries the
                                                               ; vocabulary entry;
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>
  [-]
<<
>
  [-<+>]
<
                                                               ; halving five of seven; the bit that falls off is not
                                                               ; wanted HALVE  the byte at this cell  with q t and f
                                                               ; in the three cells above it; q becomes it shifted
                                                               ; right one and t the bit that fell off; the pointer
                                                               ; comes back here; CONVENTIONS section 5 carries the
                                                               ; vocabulary entry;
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>
  [-]
<<
>
  [-<+>]
<
                                                               ; halving six of seven; the bit that falls off is not
                                                               ; wanted HALVE  the byte at this cell  with q t and f
                                                               ; in the three cells above it; q becomes it shifted
                                                               ; right one and t the bit that fell off; the pointer
                                                               ; comes back here; CONVENTIONS section 5 carries the
                                                               ; vocabulary entry;
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>
  [-]
<<
>
  [-<+>]
<
                                                               ; halving seven of seven; the bit that falls off is not
                                                               ; wanted HALVE  the byte at this cell  with q t and f
                                                               ; in the three cells above it; q becomes it shifted
                                                               ; right one and t the bit that fell off; the pointer
                                                               ; comes back here; CONVENTIONS section 5 carries the
                                                               ; vocabulary entry;
  [->>>+<[-<+>>-<]>[-<+>]<<<]
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
; ============================================================ ; ; ; eight bit steps
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

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=0

  [->>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<]
  >>>>>>>>>>>>>>>>>>>>>>>>>>>[-<+>]<<<<<<<<<<<<<<<<<<<<<<<<<   ; b becomes its own quotient
  <<                                                           ; continued
                                                               ; ASSERT ptr=0

; ============================================================ ; bit 1 of the multiplier
  >>>>>>>>>>>>>>>>>>>>>>>>>>                                   ; halve b  which leaves the quotient and the bit that
                                                               ; fell off
                                                               ; HALVE  the byte at this cell  with q t and f in the
                                                               ; three cells above it; q becomes it shifted right one
                                                               ; and t the bit that fell off; the pointer comes back
                                                               ; here; CONVENTIONS section 5 carries the vocabulary
                                                               ; entry;
  [->>>+<[-<+>>-<]>[-<+>]<<<]
  <<<<<<<<<<<<<<<<<<<<<<<<<<
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>[-<<<<<[->+>+<<]>>[-<<+>>]>>>]   ; the bit GUARDS a copy of a: nought or one turns of
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<                                 ; the loop
                                                               ; and the product takes an exclusive or with it  which
                                                               ; is the identity when the bit was clear
  >>>>>>>>>>>>>>>>>>>>>>[-<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>
  >>>>>>>>>]<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>[-   ; continued
  <<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>]<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<                                                 ; continued

                                                               ; ASSERT ptr=0
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
                                                               ; ASSERT ptr=15
<<                                                             ; the result comes home
                                                               ; ASSERT ptr=13
  [-<<<<<<<<<<<<<+>>>>>>>>>>>>>]
<<<<<<<<<<<<<
                                                               ; ASSERT ptr=0
                                                               ; ASSERT zero 1:16

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=0

  [->>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<]
  >>>>>>>>>>>>>>>>>>>>>>>[-<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>   ; a doubles in the field
  >>>>>>>>>>>>>>]<<<<<<<<<<<<<<<<<<<<<<<                       ; continued

                                                               ; ASSERT ptr=0
                                                               ; walk in to this routine entry offset

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
                                                               ; halving one of seven; the bit that falls off is not
                                                               ; wanted HALVE  the byte at this cell  with q t and f
                                                               ; in the three cells above it; q becomes it shifted
                                                               ; right one and t the bit that fell off; the pointer
                                                               ; comes back here; CONVENTIONS section 5 carries the
                                                               ; vocabulary entry;
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>
  [-]
<<
>
  [-<+>]
<
                                                               ; halving two of seven; the bit that falls off is not
                                                               ; wanted HALVE  the byte at this cell  with q t and f
                                                               ; in the three cells above it; q becomes it shifted
                                                               ; right one and t the bit that fell off; the pointer
                                                               ; comes back here; CONVENTIONS section 5 carries the
                                                               ; vocabulary entry;
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>
  [-]
<<
>
  [-<+>]
<
                                                               ; halving three of seven; the bit that falls off is not
                                                               ; wanted HALVE  the byte at this cell  with q t and f
                                                               ; in the three cells above it; q becomes it shifted
                                                               ; right one and t the bit that fell off; the pointer
                                                               ; comes back here; CONVENTIONS section 5 carries the
                                                               ; vocabulary entry;
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>
  [-]
<<
>
  [-<+>]
<
                                                               ; halving four of seven; the bit that falls off is not
                                                               ; wanted HALVE  the byte at this cell  with q t and f
                                                               ; in the three cells above it; q becomes it shifted
                                                               ; right one and t the bit that fell off; the pointer
                                                               ; comes back here; CONVENTIONS section 5 carries the
                                                               ; vocabulary entry;
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>
  [-]
<<
>
  [-<+>]
<
                                                               ; halving five of seven; the bit that falls off is not
                                                               ; wanted HALVE  the byte at this cell  with q t and f
                                                               ; in the three cells above it; q becomes it shifted
                                                               ; right one and t the bit that fell off; the pointer
                                                               ; comes back here; CONVENTIONS section 5 carries the
                                                               ; vocabulary entry;
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>
  [-]
<<
>
  [-<+>]
<
                                                               ; halving six of seven; the bit that falls off is not
                                                               ; wanted HALVE  the byte at this cell  with q t and f
                                                               ; in the three cells above it; q becomes it shifted
                                                               ; right one and t the bit that fell off; the pointer
                                                               ; comes back here; CONVENTIONS section 5 carries the
                                                               ; vocabulary entry;
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>
  [-]
<<
>
  [-<+>]
<
                                                               ; halving seven of seven; the bit that falls off is not
                                                               ; wanted HALVE  the byte at this cell  with q t and f
                                                               ; in the three cells above it; q becomes it shifted
                                                               ; right one and t the bit that fell off; the pointer
                                                               ; comes back here; CONVENTIONS section 5 carries the
                                                               ; vocabulary entry;
  [->>>+<[-<+>>-<]>[-<+>]<<<]
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
; ============================================================ ; ; ; eight bit steps
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

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=0

  [->>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<]
  >>>>>>>>>>>>>>>>>>>>>>>>>>>[-<+>]<<<<<<<<<<<<<<<<<<<<<<<<<   ; b becomes its own quotient
  <<                                                           ; continued
                                                               ; ASSERT ptr=0

; ============================================================ ; bit 2 of the multiplier
  >>>>>>>>>>>>>>>>>>>>>>>>>>                                   ; halve b  which leaves the quotient and the bit that
                                                               ; fell off
                                                               ; HALVE  the byte at this cell  with q t and f in the
                                                               ; three cells above it; q becomes it shifted right one
                                                               ; and t the bit that fell off; the pointer comes back
                                                               ; here; CONVENTIONS section 5 carries the vocabulary
                                                               ; entry;
  [->>>+<[-<+>>-<]>[-<+>]<<<]
  <<<<<<<<<<<<<<<<<<<<<<<<<<
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>[-<<<<<[->+>+<<]>>[-<<+>>]>>>]   ; the bit GUARDS a copy of a: nought or one turns of
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<                                 ; the loop
                                                               ; and the product takes an exclusive or with it  which
                                                               ; is the identity when the bit was clear
  >>>>>>>>>>>>>>>>>>>>>>[-<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>
  >>>>>>>>>]<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>[-   ; continued
  <<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>]<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<                                                 ; continued

                                                               ; ASSERT ptr=0
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
                                                               ; ASSERT ptr=15
<<                                                             ; the result comes home
                                                               ; ASSERT ptr=13
  [-<<<<<<<<<<<<<+>>>>>>>>>>>>>]
<<<<<<<<<<<<<
                                                               ; ASSERT ptr=0
                                                               ; ASSERT zero 1:16

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=0

  [->>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<]
  >>>>>>>>>>>>>>>>>>>>>>>[-<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>   ; a doubles in the field
  >>>>>>>>>>>>>>]<<<<<<<<<<<<<<<<<<<<<<<                       ; continued

                                                               ; ASSERT ptr=0
                                                               ; walk in to this routine entry offset

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
                                                               ; halving one of seven; the bit that falls off is not
                                                               ; wanted HALVE  the byte at this cell  with q t and f
                                                               ; in the three cells above it; q becomes it shifted
                                                               ; right one and t the bit that fell off; the pointer
                                                               ; comes back here; CONVENTIONS section 5 carries the
                                                               ; vocabulary entry;
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>
  [-]
<<
>
  [-<+>]
<
                                                               ; halving two of seven; the bit that falls off is not
                                                               ; wanted HALVE  the byte at this cell  with q t and f
                                                               ; in the three cells above it; q becomes it shifted
                                                               ; right one and t the bit that fell off; the pointer
                                                               ; comes back here; CONVENTIONS section 5 carries the
                                                               ; vocabulary entry;
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>
  [-]
<<
>
  [-<+>]
<
                                                               ; halving three of seven; the bit that falls off is not
                                                               ; wanted HALVE  the byte at this cell  with q t and f
                                                               ; in the three cells above it; q becomes it shifted
                                                               ; right one and t the bit that fell off; the pointer
                                                               ; comes back here; CONVENTIONS section 5 carries the
                                                               ; vocabulary entry;
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>
  [-]
<<
>
  [-<+>]
<
                                                               ; halving four of seven; the bit that falls off is not
                                                               ; wanted HALVE  the byte at this cell  with q t and f
                                                               ; in the three cells above it; q becomes it shifted
                                                               ; right one and t the bit that fell off; the pointer
                                                               ; comes back here; CONVENTIONS section 5 carries the
                                                               ; vocabulary entry;
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>
  [-]
<<
>
  [-<+>]
<
                                                               ; halving five of seven; the bit that falls off is not
                                                               ; wanted HALVE  the byte at this cell  with q t and f
                                                               ; in the three cells above it; q becomes it shifted
                                                               ; right one and t the bit that fell off; the pointer
                                                               ; comes back here; CONVENTIONS section 5 carries the
                                                               ; vocabulary entry;
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>
  [-]
<<
>
  [-<+>]
<
                                                               ; halving six of seven; the bit that falls off is not
                                                               ; wanted HALVE  the byte at this cell  with q t and f
                                                               ; in the three cells above it; q becomes it shifted
                                                               ; right one and t the bit that fell off; the pointer
                                                               ; comes back here; CONVENTIONS section 5 carries the
                                                               ; vocabulary entry;
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>
  [-]
<<
>
  [-<+>]
<
                                                               ; halving seven of seven; the bit that falls off is not
                                                               ; wanted HALVE  the byte at this cell  with q t and f
                                                               ; in the three cells above it; q becomes it shifted
                                                               ; right one and t the bit that fell off; the pointer
                                                               ; comes back here; CONVENTIONS section 5 carries the
                                                               ; vocabulary entry;
  [->>>+<[-<+>>-<]>[-<+>]<<<]
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
; ============================================================ ; ; ; eight bit steps
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

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=0

  [->>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<]
  >>>>>>>>>>>>>>>>>>>>>>>>>>>[-<+>]<<<<<<<<<<<<<<<<<<<<<<<<<   ; b becomes its own quotient
  <<                                                           ; continued
                                                               ; ASSERT ptr=0

; ============================================================ ; bit 3 of the multiplier
  >>>>>>>>>>>>>>>>>>>>>>>>>>                                   ; halve b  which leaves the quotient and the bit that
                                                               ; fell off
                                                               ; HALVE  the byte at this cell  with q t and f in the
                                                               ; three cells above it; q becomes it shifted right one
                                                               ; and t the bit that fell off; the pointer comes back
                                                               ; here; CONVENTIONS section 5 carries the vocabulary
                                                               ; entry;
  [->>>+<[-<+>>-<]>[-<+>]<<<]
  <<<<<<<<<<<<<<<<<<<<<<<<<<
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>[-<<<<<[->+>+<<]>>[-<<+>>]>>>]   ; the bit GUARDS a copy of a: nought or one turns of
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<                                 ; the loop
                                                               ; and the product takes an exclusive or with it  which
                                                               ; is the identity when the bit was clear
  >>>>>>>>>>>>>>>>>>>>>>[-<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>
  >>>>>>>>>]<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>[-   ; continued
  <<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>]<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<                                                 ; continued

                                                               ; ASSERT ptr=0
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
                                                               ; ASSERT ptr=15
<<                                                             ; the result comes home
                                                               ; ASSERT ptr=13
  [-<<<<<<<<<<<<<+>>>>>>>>>>>>>]
<<<<<<<<<<<<<
                                                               ; ASSERT ptr=0
                                                               ; ASSERT zero 1:16

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=0

  [->>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<]
  >>>>>>>>>>>>>>>>>>>>>>>[-<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>   ; a doubles in the field
  >>>>>>>>>>>>>>]<<<<<<<<<<<<<<<<<<<<<<<                       ; continued

                                                               ; ASSERT ptr=0
                                                               ; walk in to this routine entry offset

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
                                                               ; halving one of seven; the bit that falls off is not
                                                               ; wanted HALVE  the byte at this cell  with q t and f
                                                               ; in the three cells above it; q becomes it shifted
                                                               ; right one and t the bit that fell off; the pointer
                                                               ; comes back here; CONVENTIONS section 5 carries the
                                                               ; vocabulary entry;
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>
  [-]
<<
>
  [-<+>]
<
                                                               ; halving two of seven; the bit that falls off is not
                                                               ; wanted HALVE  the byte at this cell  with q t and f
                                                               ; in the three cells above it; q becomes it shifted
                                                               ; right one and t the bit that fell off; the pointer
                                                               ; comes back here; CONVENTIONS section 5 carries the
                                                               ; vocabulary entry;
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>
  [-]
<<
>
  [-<+>]
<
                                                               ; halving three of seven; the bit that falls off is not
                                                               ; wanted HALVE  the byte at this cell  with q t and f
                                                               ; in the three cells above it; q becomes it shifted
                                                               ; right one and t the bit that fell off; the pointer
                                                               ; comes back here; CONVENTIONS section 5 carries the
                                                               ; vocabulary entry;
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>
  [-]
<<
>
  [-<+>]
<
                                                               ; halving four of seven; the bit that falls off is not
                                                               ; wanted HALVE  the byte at this cell  with q t and f
                                                               ; in the three cells above it; q becomes it shifted
                                                               ; right one and t the bit that fell off; the pointer
                                                               ; comes back here; CONVENTIONS section 5 carries the
                                                               ; vocabulary entry;
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>
  [-]
<<
>
  [-<+>]
<
                                                               ; halving five of seven; the bit that falls off is not
                                                               ; wanted HALVE  the byte at this cell  with q t and f
                                                               ; in the three cells above it; q becomes it shifted
                                                               ; right one and t the bit that fell off; the pointer
                                                               ; comes back here; CONVENTIONS section 5 carries the
                                                               ; vocabulary entry;
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>
  [-]
<<
>
  [-<+>]
<
                                                               ; halving six of seven; the bit that falls off is not
                                                               ; wanted HALVE  the byte at this cell  with q t and f
                                                               ; in the three cells above it; q becomes it shifted
                                                               ; right one and t the bit that fell off; the pointer
                                                               ; comes back here; CONVENTIONS section 5 carries the
                                                               ; vocabulary entry;
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>
  [-]
<<
>
  [-<+>]
<
                                                               ; halving seven of seven; the bit that falls off is not
                                                               ; wanted HALVE  the byte at this cell  with q t and f
                                                               ; in the three cells above it; q becomes it shifted
                                                               ; right one and t the bit that fell off; the pointer
                                                               ; comes back here; CONVENTIONS section 5 carries the
                                                               ; vocabulary entry;
  [->>>+<[-<+>>-<]>[-<+>]<<<]
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
; ============================================================ ; ; ; eight bit steps
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

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=0

  [->>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<]
  >>>>>>>>>>>>>>>>>>>>>>>>>>>[-<+>]<<<<<<<<<<<<<<<<<<<<<<<<<   ; b becomes its own quotient
  <<                                                           ; continued
                                                               ; ASSERT ptr=0

; ============================================================ ; bit 4 of the multiplier
  >>>>>>>>>>>>>>>>>>>>>>>>>>                                   ; halve b  which leaves the quotient and the bit that
                                                               ; fell off
                                                               ; HALVE  the byte at this cell  with q t and f in the
                                                               ; three cells above it; q becomes it shifted right one
                                                               ; and t the bit that fell off; the pointer comes back
                                                               ; here; CONVENTIONS section 5 carries the vocabulary
                                                               ; entry;
  [->>>+<[-<+>>-<]>[-<+>]<<<]
  <<<<<<<<<<<<<<<<<<<<<<<<<<
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>[-<<<<<[->+>+<<]>>[-<<+>>]>>>]   ; the bit GUARDS a copy of a: nought or one turns of
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<                                 ; the loop
                                                               ; and the product takes an exclusive or with it  which
                                                               ; is the identity when the bit was clear
  >>>>>>>>>>>>>>>>>>>>>>[-<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>
  >>>>>>>>>]<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>[-   ; continued
  <<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>]<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<                                                 ; continued

                                                               ; ASSERT ptr=0
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
                                                               ; ASSERT ptr=15
<<                                                             ; the result comes home
                                                               ; ASSERT ptr=13
  [-<<<<<<<<<<<<<+>>>>>>>>>>>>>]
<<<<<<<<<<<<<
                                                               ; ASSERT ptr=0
                                                               ; ASSERT zero 1:16

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=0

  [->>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<]
  >>>>>>>>>>>>>>>>>>>>>>>[-<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>   ; a doubles in the field
  >>>>>>>>>>>>>>]<<<<<<<<<<<<<<<<<<<<<<<                       ; continued

                                                               ; ASSERT ptr=0
                                                               ; walk in to this routine entry offset

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
                                                               ; halving one of seven; the bit that falls off is not
                                                               ; wanted HALVE  the byte at this cell  with q t and f
                                                               ; in the three cells above it; q becomes it shifted
                                                               ; right one and t the bit that fell off; the pointer
                                                               ; comes back here; CONVENTIONS section 5 carries the
                                                               ; vocabulary entry;
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>
  [-]
<<
>
  [-<+>]
<
                                                               ; halving two of seven; the bit that falls off is not
                                                               ; wanted HALVE  the byte at this cell  with q t and f
                                                               ; in the three cells above it; q becomes it shifted
                                                               ; right one and t the bit that fell off; the pointer
                                                               ; comes back here; CONVENTIONS section 5 carries the
                                                               ; vocabulary entry;
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>
  [-]
<<
>
  [-<+>]
<
                                                               ; halving three of seven; the bit that falls off is not
                                                               ; wanted HALVE  the byte at this cell  with q t and f
                                                               ; in the three cells above it; q becomes it shifted
                                                               ; right one and t the bit that fell off; the pointer
                                                               ; comes back here; CONVENTIONS section 5 carries the
                                                               ; vocabulary entry;
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>
  [-]
<<
>
  [-<+>]
<
                                                               ; halving four of seven; the bit that falls off is not
                                                               ; wanted HALVE  the byte at this cell  with q t and f
                                                               ; in the three cells above it; q becomes it shifted
                                                               ; right one and t the bit that fell off; the pointer
                                                               ; comes back here; CONVENTIONS section 5 carries the
                                                               ; vocabulary entry;
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>
  [-]
<<
>
  [-<+>]
<
                                                               ; halving five of seven; the bit that falls off is not
                                                               ; wanted HALVE  the byte at this cell  with q t and f
                                                               ; in the three cells above it; q becomes it shifted
                                                               ; right one and t the bit that fell off; the pointer
                                                               ; comes back here; CONVENTIONS section 5 carries the
                                                               ; vocabulary entry;
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>
  [-]
<<
>
  [-<+>]
<
                                                               ; halving six of seven; the bit that falls off is not
                                                               ; wanted HALVE  the byte at this cell  with q t and f
                                                               ; in the three cells above it; q becomes it shifted
                                                               ; right one and t the bit that fell off; the pointer
                                                               ; comes back here; CONVENTIONS section 5 carries the
                                                               ; vocabulary entry;
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>
  [-]
<<
>
  [-<+>]
<
                                                               ; halving seven of seven; the bit that falls off is not
                                                               ; wanted HALVE  the byte at this cell  with q t and f
                                                               ; in the three cells above it; q becomes it shifted
                                                               ; right one and t the bit that fell off; the pointer
                                                               ; comes back here; CONVENTIONS section 5 carries the
                                                               ; vocabulary entry;
  [->>>+<[-<+>>-<]>[-<+>]<<<]
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
; ============================================================ ; ; ; eight bit steps
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

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=0

  [->>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<]
  >>>>>>>>>>>>>>>>>>>>>>>>>>>[-<+>]<<<<<<<<<<<<<<<<<<<<<<<<<   ; b becomes its own quotient
  <<                                                           ; continued
                                                               ; ASSERT ptr=0

; ============================================================ ; bit 5 of the multiplier
  >>>>>>>>>>>>>>>>>>>>>>>>>>                                   ; halve b  which leaves the quotient and the bit that
                                                               ; fell off
                                                               ; HALVE  the byte at this cell  with q t and f in the
                                                               ; three cells above it; q becomes it shifted right one
                                                               ; and t the bit that fell off; the pointer comes back
                                                               ; here; CONVENTIONS section 5 carries the vocabulary
                                                               ; entry;
  [->>>+<[-<+>>-<]>[-<+>]<<<]
  <<<<<<<<<<<<<<<<<<<<<<<<<<
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>[-<<<<<[->+>+<<]>>[-<<+>>]>>>]   ; the bit GUARDS a copy of a: nought or one turns of
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<                                 ; the loop
                                                               ; and the product takes an exclusive or with it  which
                                                               ; is the identity when the bit was clear
  >>>>>>>>>>>>>>>>>>>>>>[-<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>
  >>>>>>>>>]<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>[-   ; continued
  <<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>]<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<                                                 ; continued

                                                               ; ASSERT ptr=0
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
                                                               ; ASSERT ptr=15
<<                                                             ; the result comes home
                                                               ; ASSERT ptr=13
  [-<<<<<<<<<<<<<+>>>>>>>>>>>>>]
<<<<<<<<<<<<<
                                                               ; ASSERT ptr=0
                                                               ; ASSERT zero 1:16

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=0

  [->>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<]
  >>>>>>>>>>>>>>>>>>>>>>>[-<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>   ; a doubles in the field
  >>>>>>>>>>>>>>]<<<<<<<<<<<<<<<<<<<<<<<                       ; continued

                                                               ; ASSERT ptr=0
                                                               ; walk in to this routine entry offset

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
                                                               ; halving one of seven; the bit that falls off is not
                                                               ; wanted HALVE  the byte at this cell  with q t and f
                                                               ; in the three cells above it; q becomes it shifted
                                                               ; right one and t the bit that fell off; the pointer
                                                               ; comes back here; CONVENTIONS section 5 carries the
                                                               ; vocabulary entry;
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>
  [-]
<<
>
  [-<+>]
<
                                                               ; halving two of seven; the bit that falls off is not
                                                               ; wanted HALVE  the byte at this cell  with q t and f
                                                               ; in the three cells above it; q becomes it shifted
                                                               ; right one and t the bit that fell off; the pointer
                                                               ; comes back here; CONVENTIONS section 5 carries the
                                                               ; vocabulary entry;
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>
  [-]
<<
>
  [-<+>]
<
                                                               ; halving three of seven; the bit that falls off is not
                                                               ; wanted HALVE  the byte at this cell  with q t and f
                                                               ; in the three cells above it; q becomes it shifted
                                                               ; right one and t the bit that fell off; the pointer
                                                               ; comes back here; CONVENTIONS section 5 carries the
                                                               ; vocabulary entry;
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>
  [-]
<<
>
  [-<+>]
<
                                                               ; halving four of seven; the bit that falls off is not
                                                               ; wanted HALVE  the byte at this cell  with q t and f
                                                               ; in the three cells above it; q becomes it shifted
                                                               ; right one and t the bit that fell off; the pointer
                                                               ; comes back here; CONVENTIONS section 5 carries the
                                                               ; vocabulary entry;
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>
  [-]
<<
>
  [-<+>]
<
                                                               ; halving five of seven; the bit that falls off is not
                                                               ; wanted HALVE  the byte at this cell  with q t and f
                                                               ; in the three cells above it; q becomes it shifted
                                                               ; right one and t the bit that fell off; the pointer
                                                               ; comes back here; CONVENTIONS section 5 carries the
                                                               ; vocabulary entry;
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>
  [-]
<<
>
  [-<+>]
<
                                                               ; halving six of seven; the bit that falls off is not
                                                               ; wanted HALVE  the byte at this cell  with q t and f
                                                               ; in the three cells above it; q becomes it shifted
                                                               ; right one and t the bit that fell off; the pointer
                                                               ; comes back here; CONVENTIONS section 5 carries the
                                                               ; vocabulary entry;
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>
  [-]
<<
>
  [-<+>]
<
                                                               ; halving seven of seven; the bit that falls off is not
                                                               ; wanted HALVE  the byte at this cell  with q t and f
                                                               ; in the three cells above it; q becomes it shifted
                                                               ; right one and t the bit that fell off; the pointer
                                                               ; comes back here; CONVENTIONS section 5 carries the
                                                               ; vocabulary entry;
  [->>>+<[-<+>>-<]>[-<+>]<<<]
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
; ============================================================ ; ; ; eight bit steps
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

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=0

  [->>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<]
  >>>>>>>>>>>>>>>>>>>>>>>>>>>[-<+>]<<<<<<<<<<<<<<<<<<<<<<<<<   ; b becomes its own quotient
  <<                                                           ; continued
                                                               ; ASSERT ptr=0

; ============================================================ ; bit 6 of the multiplier
  >>>>>>>>>>>>>>>>>>>>>>>>>>                                   ; halve b  which leaves the quotient and the bit that
                                                               ; fell off
                                                               ; HALVE  the byte at this cell  with q t and f in the
                                                               ; three cells above it; q becomes it shifted right one
                                                               ; and t the bit that fell off; the pointer comes back
                                                               ; here; CONVENTIONS section 5 carries the vocabulary
                                                               ; entry;
  [->>>+<[-<+>>-<]>[-<+>]<<<]
  <<<<<<<<<<<<<<<<<<<<<<<<<<
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>[-<<<<<[->+>+<<]>>[-<<+>>]>>>]   ; the bit GUARDS a copy of a: nought or one turns of
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<                                 ; the loop
                                                               ; and the product takes an exclusive or with it  which
                                                               ; is the identity when the bit was clear
  >>>>>>>>>>>>>>>>>>>>>>[-<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>
  >>>>>>>>>]<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>[-   ; continued
  <<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>]<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<                                                 ; continued

                                                               ; ASSERT ptr=0
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
                                                               ; ASSERT ptr=15
<<                                                             ; the result comes home
                                                               ; ASSERT ptr=13
  [-<<<<<<<<<<<<<+>>>>>>>>>>>>>]
<<<<<<<<<<<<<
                                                               ; ASSERT ptr=0
                                                               ; ASSERT zero 1:16

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=0

  [->>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<]
  >>>>>>>>>>>>>>>>>>>>>>>[-<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>   ; a doubles in the field
  >>>>>>>>>>>>>>]<<<<<<<<<<<<<<<<<<<<<<<                       ; continued

                                                               ; ASSERT ptr=0
                                                               ; walk in to this routine entry offset

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
                                                               ; halving one of seven; the bit that falls off is not
                                                               ; wanted HALVE  the byte at this cell  with q t and f
                                                               ; in the three cells above it; q becomes it shifted
                                                               ; right one and t the bit that fell off; the pointer
                                                               ; comes back here; CONVENTIONS section 5 carries the
                                                               ; vocabulary entry;
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>
  [-]
<<
>
  [-<+>]
<
                                                               ; halving two of seven; the bit that falls off is not
                                                               ; wanted HALVE  the byte at this cell  with q t and f
                                                               ; in the three cells above it; q becomes it shifted
                                                               ; right one and t the bit that fell off; the pointer
                                                               ; comes back here; CONVENTIONS section 5 carries the
                                                               ; vocabulary entry;
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>
  [-]
<<
>
  [-<+>]
<
                                                               ; halving three of seven; the bit that falls off is not
                                                               ; wanted HALVE  the byte at this cell  with q t and f
                                                               ; in the three cells above it; q becomes it shifted
                                                               ; right one and t the bit that fell off; the pointer
                                                               ; comes back here; CONVENTIONS section 5 carries the
                                                               ; vocabulary entry;
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>
  [-]
<<
>
  [-<+>]
<
                                                               ; halving four of seven; the bit that falls off is not
                                                               ; wanted HALVE  the byte at this cell  with q t and f
                                                               ; in the three cells above it; q becomes it shifted
                                                               ; right one and t the bit that fell off; the pointer
                                                               ; comes back here; CONVENTIONS section 5 carries the
                                                               ; vocabulary entry;
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>
  [-]
<<
>
  [-<+>]
<
                                                               ; halving five of seven; the bit that falls off is not
                                                               ; wanted HALVE  the byte at this cell  with q t and f
                                                               ; in the three cells above it; q becomes it shifted
                                                               ; right one and t the bit that fell off; the pointer
                                                               ; comes back here; CONVENTIONS section 5 carries the
                                                               ; vocabulary entry;
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>
  [-]
<<
>
  [-<+>]
<
                                                               ; halving six of seven; the bit that falls off is not
                                                               ; wanted HALVE  the byte at this cell  with q t and f
                                                               ; in the three cells above it; q becomes it shifted
                                                               ; right one and t the bit that fell off; the pointer
                                                               ; comes back here; CONVENTIONS section 5 carries the
                                                               ; vocabulary entry;
  [->>>+<[-<+>>-<]>[-<+>]<<<]
>>
  [-]
<<
>
  [-<+>]
<
                                                               ; halving seven of seven; the bit that falls off is not
                                                               ; wanted HALVE  the byte at this cell  with q t and f
                                                               ; in the three cells above it; q becomes it shifted
                                                               ; right one and t the bit that fell off; the pointer
                                                               ; comes back here; CONVENTIONS section 5 carries the
                                                               ; vocabulary entry;
  [->>>+<[-<+>>-<]>[-<+>]<<<]
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
; ============================================================ ; ; ; eight bit steps
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

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=0

  [->>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<]
  >>>>>>>>>>>>>>>>>>>>>>>>>>>[-<+>]<<<<<<<<<<<<<<<<<<<<<<<<<   ; b becomes its own quotient
  <<                                                           ; continued
                                                               ; ASSERT ptr=0

; ============================================================ ; bit 7 of the multiplier
  >>>>>>>>>>>>>>>>>>>>>>>>>>                                   ; halve b  which leaves the quotient and the bit that
                                                               ; fell off
                                                               ; HALVE  the byte at this cell  with q t and f in the
                                                               ; three cells above it; q becomes it shifted right one
                                                               ; and t the bit that fell off; the pointer comes back
                                                               ; here; CONVENTIONS section 5 carries the vocabulary
                                                               ; entry;
  [->>>+<[-<+>>-<]>[-<+>]<<<]
  <<<<<<<<<<<<<<<<<<<<<<<<<<
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>[-<<<<<[->+>+<<]>>[-<<+>>]>>>]   ; the bit GUARDS a copy of a: nought or one turns of
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<                                 ; the loop
                                                               ; and the product takes an exclusive or with it  which
                                                               ; is the identity when the bit was clear
  >>>>>>>>>>>>>>>>>>>>>>[-<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>
  >>>>>>>>>]<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>[-   ; continued
  <<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>]<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<                                                 ; continued

                                                               ; ASSERT ptr=0
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
                                                               ; ASSERT ptr=15
<<                                                             ; the result comes home
                                                               ; ASSERT ptr=13
  [-<<<<<<<<<<<<<+>>>>>>>>>>>>>]
<<<<<<<<<<<<<
                                                               ; ASSERT ptr=0
                                                               ; ASSERT zero 1:16

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=0

  [->>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<]
                                                               ; and the eighth doubling is not done  nothing would
                                                               ; read it b becomes its own quotient
  >>>>>>>>>>>>>>>>>>>>>>>>>>>[-<+>]<<<<<<<<<<<<<<<<<<<<<<<<<
  <<                                                           ; continued
                                                               ; ASSERT ptr=0

                                                               ; THE MULTIPLICAND IS STILL THERE because the eighth
                                                               ; doubling was skipped  and a routine must hand its
                                                               ; frame back clear or a second paste at the same base
                                                               ; moves its own a into a dirty cell  which adds rather
                                                               ; than sets; Clearing it costs at most 255
  >>>>>>>>>>>>>>>>>>>>>>>[-]<<<<<<<<<<<<<<<<<<<<<<<
  >>>>>>>>>>>>>>>>>>>>>>[-<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>   ; the product comes home
  >>>>>>>>>>>]<<<<<<<<<<<<<<<<<<<<<<                           ; continued
                                                               ; ASSERT ptr=0
                                                               ; ASSERT zero 1:29

; emit
  .                                                            ; the product  which is the whole of the answer
