; bfsodium INVMIXCOLUMN : one column of the AES InvMixColumns step
;
; NOTE square brackets are brainfuck loops  so comments use braces for counts;
;
; HAND WRITTEN; idiom/xor8 is PASTED six times  aes/xtime four and
; aes/mixcolumn once;
;
; INTERFACE entry=25 exit=0 footprint=0:34
; IO  in:  a{4} at @0x16  one column  a0 first     (4 bytes)
;     out: b{4} at @0x16  the column unmixed       (4 bytes)
;
; FIPS 197 section 5 point 3 point 3 writes this as a multiply by a matrix of
; 0e 0b 0d 09 rotated  which is sixteen GENERAL field multiplies; aes/gfmul
; measures 581 thousand  so the matrix form is near nine and a half million a
; column; THIS MEASURES 1 MILLION 241 THOUSAND  which is better than seven
; times cheaper  and that multiple is built from an estimate of an assembly
; that does not exist  so read it as a floor;
;
; THE WHOLE STEP IS MixColumns WITH THE COLUMN PREPARED FIRST:
;
;   u is xtime(xtime(a0 xor a2))    v is xtime(xtime(a1 xor a3))
;   InvMixColumns(a) is MixColumns(a0 xor u  a1 xor v  a2 xor u  a3 xor v)
;
; and it is exact rather than close; Preparing the column multiplies it by 5
; and 4 in the right places  and 2 times 5 xor 1 times 4 is 14  3 times 5 xor
; 1 times 4 is 11  1 times 5 xor 2 times 4 is 13 and 1 times 5 xor 3 times 4
; is 9  which is the FIPS matrix row for row; spec/perm_cry proves it over all
; 2 to the 32 columns rather than sampling it;
;
; SO THE INVERSE REUSES THE FORWARD ROUTINE  which is the point: aes/mixcolumn
; is already pinned against FIPS 197 Appendix B and a sweep  and nothing here
; re_implements it;
;
; u AND v ARE EACH WANTED TWICE  so each is COPIED for its first use and MOVED
; for its second; idiom/xor8 spends its operands  and that rule has now cost
; this library three defects;
;
; TAPE MAP  (home @0)
;   @0x00:0x1f  aes/mixcolumn pasted at this file's own zero; its column goes
;               in at @0x16 to @0x19 and the answer comes back there; the
;               exclusive ors and the doublings above use the same cells
;   @0x16:0x19  a{4}  the column; THE ANSWER COMES BACK OVER IT
;   @0x20       u     xtime twice of a0 xor a2
;   @0x21       v     xtime twice of a1 xor a3
;   @0x22       g     the cell a copy hands its value back through

  >>>>>>>>>>>>>>>>>>>>>>,>,>,>,                                ; the column  the mixcolumn frame stepped over first
                                                               ; ASSERT ptr=25
                                                               ; ASSERT zero 0:21
                                                               ; ASSERT zero 32:34
  <<<<<<<<<<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=0

; ============================================================ ; the column is prepared  which is the whole of the
                                                               ; inverse
  >>>>>>>>>>>>>>>>>>>>>>[-<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>   ; u is xtime twice of a0 xor a2
  >>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<]>>>>>>>>>>>>[-<<<<<<<<<   ; continued
  <<<+>>>>>>>>>>>>]<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>   ; continued
  >>>>>>>>>>>>>>>>>[-<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>   ; continued
  >>>>>>>>>>>>>>>>+<<<<<<<<<<]>>>>>>>>>>[-<<<<<<<<<<+>>>>>>>   ; continued
  >>>]<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<                       ; continued

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

  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<]                                                   ; continued
                                                               ; ASSERT ptr=0
  >>>>>>>>>>>>>>>>>>>>>>>[-<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>   ; v is xtime twice of a1 xor a3
  >>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<]>>>>>>>>>>>[-<<<<<<<<<   ; continued
  <<+>>>>>>>>>>>]<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>   ; continued
  >>>>>>>>>>>>>>>>[-<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>   ; continued
  >>>>>>>>>>>>>>>>+<<<<<<<<<]>>>>>>>>>[-<<<<<<<<<+>>>>>>>>>]   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<                           ; continued

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

  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<]                                                 ; continued
                                                               ; ASSERT ptr=0
  >>>>>>>>>>>>>>>>>>>>>>[-<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>   ; a0 takes u  which is COPIED because a2 wants it too
  >>>>>>>>>]<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>>[-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>>>>>>>>>+<<]>>[-<<+>>]<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<                                                          ; continued

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
  >>>>>>>>>>>>>>>>>>>>>>>>[-<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>   ; a2 takes u  which is MOVED because nothing wants it
  >>>>>>>>>>>>>>>]<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>   ; after
  >>>>>>>>>>>>>>[-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>   ; continued
  >>>>>>>>>>>>>>>>>>>]<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<         ; continued

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

  [->>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<]
  >>>>>>>>>>>>>>>>>>>>>>>[-<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>   ; a1 takes v  copied for the same reason
  >>>>>>>>>>>>]<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>>>>>>>[-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>   ; continued
  >>>>>>>>>>>>>>>>>>>+<]>[-<+>]<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<                                                        ; continued

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

  [->>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<]
  >>>>>>>>>>>>>>>>>>>>>>>>>[-<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>   ; a3 takes v  and spends it
  >>>>>>>>>>>>>>>>>>]<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>   ; continued
  >>>>>>>>>>>>>>>>>>>[-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>   ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>]<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<                                                           ; continued

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

  [->>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<]
                                                               ; ASSERT ptr=0
                                                               ; ASSERT zero 32:34

; ============================================================ ; and then it is simply MixColumns

                                                               ; ASSERT ptr=0
  >>>>>>>>>>>>>>>>>>>>>>>>>                                    ; walk in to this routine entry offset
                                                               ; above it
                                                               ; ASSERT ptr=25
                                                               ; ASSERT zero 0:21
                                                               ; ASSERT zero 26:31
<<<<<<<<<<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=0

; ============================================================ ; ; phase one : t is the exclusive or of all four
>>>>>>>>>>>>>>>>>>>>>>                                         ; a0 into the first operand
  [-<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<
  <<<<<<]                                                      ; continued
>>>>>>>>>
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
>>>>>>>>>>>>>>>>>>>>>>>                                        ; a1 into the second
  [-<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<
  <<<<]                                                        ; continued
>>>>>>>>
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
                                                               ; a0 xor a1
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
  [->>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<]     ; and that is the start of t
>>>>>>>>>>>>>>>>>>>>>>>>>>                                     ; t so far into the first operand
  [-<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>]
<<<<<<<<<<<<<<<<<<<<<<<<<<
>>>>>>>>>>>>>>>>>>>>>>>>                                       ; a2 into the second
  [-<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<
  <<<<]                                                        ; continued
>>>>>>>
  [-<<<<<<<+>>>>>>>]
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
                                                               ; t xor a2
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
  [->>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<]     ; and back into t
>>>>>>>>>>>>>>>>>>>>>>>>>>                                     ; t so far into the first operand
  [-<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>]
<<<<<<<<<<<<<<<<<<<<<<<<<<
>>>>>>>>>>>>>>>>>>>>>>>>>                                      ; a3 into the second
  [-<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<
  <<<<]                                                        ; continued
>>>>>>
  [-<<<<<<+>>>>>>]
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
                                                               ; t xor a3
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
  [->>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<]     ; and back into t
                                                               ; ASSERT ptr=0
                                                               ; ASSERT zero 1:21

; ============================================================ ; ; phase two : x_i is xtime of a_i xor its neighbour
                                                               ; EVERY ONE OF THEM IS COMPUTED BEFORE ANY a_i IS SPENT
                                                               ; because b_3 wants a_0 and a_0 would otherwise be gone
                                                               ; by then a0 into the first operand
>>>>>>>>>>>>>>>>>>>>>>
  [-<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<
  <<<<<<]                                                      ; continued
>>>>>>>>>
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
>>>>>>>>>>>>>>>>>>>>>>>                                        ; a1 into the second
  [-<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<
  <<<<]                                                        ; continued
>>>>>>>>
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
                                                               ; a0 xor a1  which lands where xtime wants its input
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
                                                               ; and multiplied by x in the field
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
; ============================================================ ; ; ; ; eight bit steps
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
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<]   ; that is x0
>>>>>>>>>>>>>>>>>>>>>>>                                        ; a1 into the first operand
  [-<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<
  <<<<<<]                                                      ; continued
>>>>>>>>
  [-<<<<<<<<+>>>>>>>>]
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
>>>>>>>>>>>>>>>>>>>>>>>>                                       ; a2 into the second
  [-<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<
  <<<<]                                                        ; continued
>>>>>>>
  [-<<<<<<<+>>>>>>>]
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
                                                               ; a1 xor a2  which lands where xtime wants its input
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
                                                               ; and multiplied by x in the field
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
; ============================================================ ; ; ; ; eight bit steps
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
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; that is x1
  <]                                                           ; continued
>>>>>>>>>>>>>>>>>>>>>>>>                                       ; a2 into the first operand
  [-<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<
  <<<<<<]                                                      ; continued
>>>>>>>
  [-<<<<<<<+>>>>>>>]
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
>>>>>>>>>>>>>>>>>>>>>>>>>                                      ; a3 into the second
  [-<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<
  <<<<]                                                        ; continued
>>>>>>
  [-<<<<<<+>>>>>>]
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
                                                               ; a2 xor a3  which lands where xtime wants its input
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
                                                               ; and multiplied by x in the field
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
; ============================================================ ; ; ; ; eight bit steps
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
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<   ; that is x2
  <<<]                                                         ; continued
>>>>>>>>>>>>>>>>>>>>>>>>>                                      ; a3 into the first operand
  [-<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+
  <<<<<<]                                                      ; continued
>>>>>>
  [-<<<<<<+>>>>>>]
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
>>>>>>>>>>>>>>>>>>>>>>                                         ; a0 into the second
  [-<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<
  <<<<]                                                        ; continued
>>>>>>>>>
  [-<<<<<<<<<+>>>>>>>>>]
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
                                                               ; a3 xor a0  which lands where xtime wants its input
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
                                                               ; and multiplied by x in the field
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
; ============================================================ ; ; ; ; eight bit steps
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
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<   ; that is x3
  <<<<<]                                                       ; continued
                                                               ; ASSERT ptr=0
                                                               ; ASSERT zero 1:21

; ============================================================ ; ; phase three : b_i is a_i xor t xor x_i
                                                               ; each a_i is wanted once more  so it is MOVED and not
                                                               ; copied  and the last use of t moves it too a0 is
                                                               ; spent into the first operand
>>>>>>>>>>>>>>>>>>>>>>
  [-<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>]
<<<<<<<<<<<<<<<<<<<<<<
>>>>>>>>>>>>>>>>>>>>>>>>>>                                     ; and a copy of t into the second
  [-<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<
  <<<<]                                                        ; continued
>>>>>
  [-<<<<<+>>>>>]
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
                                                               ; a0 xor t
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
  [->+<]                                                       ; that becomes the first operand of the second one
>>>>>>>>>>>>>>>>>>>>>>>>>>>                                    ; and x0 the second
  [-<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>]
<<<<<<<<<<<<<<<<<<<<<<<<<<<
                                                               ; which is b0
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
  [->>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<]             ; and it comes to rest where a0 was
>>>>>>>>>>>>>>>>>>>>>>>                                        ; a1 is spent into the first operand
  [-<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>]
<<<<<<<<<<<<<<<<<<<<<<<
>>>>>>>>>>>>>>>>>>>>>>>>>>                                     ; and a copy of t into the second
  [-<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<
  <<<<]                                                        ; continued
>>>>>
  [-<<<<<+>>>>>]
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
                                                               ; a1 xor t
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
  [->+<]                                                       ; that becomes the first operand of the second one
>>>>>>>>>>>>>>>>>>>>>>>>>>>>                                   ; and x1 the second
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>]
<<<<<<<<<<<<<<<<<<<<<<<<<<<<
                                                               ; which is b1
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
  [->>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<]           ; and it comes to rest where a1 was
>>>>>>>>>>>>>>>>>>>>>>>>                                       ; a2 is spent into the first operand
  [-<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>]
<<<<<<<<<<<<<<<<<<<<<<<<
>>>>>>>>>>>>>>>>>>>>>>>>>>                                     ; and a copy of t into the second
  [-<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<
  <<<<]                                                        ; continued
>>>>>
  [-<<<<<+>>>>>]
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
                                                               ; a2 xor t
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
  [->+<]                                                       ; that becomes the first operand of the second one
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>                                  ; and x2 the second
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>>]
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
                                                               ; which is b2
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
  [->>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<]         ; and it comes to rest where a2 was
>>>>>>>>>>>>>>>>>>>>>>>>>                                      ; a3 is spent into the first operand
  [-<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>]
<<<<<<<<<<<<<<<<<<<<<<<<<
>>>>>>>>>>>>>>>>>>>>>>>>>>                                     ; and t itself  which is wanted no more
  [-<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>]
<<<<<<<<<<<<<<<<<<<<<<<<<<
                                                               ; a3 xor t
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
  [->+<]                                                       ; that becomes the first operand of the second one
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>                                 ; and x3 the second
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >]                                                           ; continued
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
                                                               ; which is b3
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
  [->>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<]       ; and it comes to rest where a3 was
                                                               ; ASSERT ptr=0
                                                               ; ASSERT zero 0:21
                                                               ; ASSERT zero 26:31

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=0


; emit
  >>>>>>>>>>>>>>>>>>>>>>                                       ; the four bytes of the unmixed column
  .>.>.>.
