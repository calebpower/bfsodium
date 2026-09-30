; bfsodium MIXCOLUMN : one column of the AES MixColumns step
;
; NOTE square brackets are brainfuck loops  so comments use braces for counts;
;
; HAND WRITTEN; idiom/xor8 is PASTED fifteen times and aes/xtime four times;
;
; INTERFACE entry=25 exit=0 footprint=0:31
; IO  in:  a{4}   one column  a0 first      (4 bytes)
;     out: b{4}   the column mixed          (4 bytes)
;
; FIPS 197 section 5 point 1 point 3 writes this as a multiply by a fixed matrix whose
; entries are 02 03 01 01 rotated  which reads as sixteen field multiplies;
; It is the same map written four ways  and the cheap way to say it is
;
;   t is a0 xor a1 xor a2 xor a3
;   b_i is a_i xor t xor xtime(a_i xor a_j)   where j is i plus one modulo four
;
; THAT COSTS FOUR XTIMES AND FIFTEEN EXCLUSIVE ORS and no multiply at all;
; The matrix form would need the three multiply by two and the three multiply
; by three separately  which is eight xtimes and twelve exclusive ors  so the
; identity is not a flourish  it is most of the cost;
;
; AND IT IS PASTEABLE  which is the whole reason this comes first: it holds no
; index  so every loop in it is pointer balanced and tools/bffoot accepts it;
; The S box read cannot say that and never will  which is recorded at length
; in index/fetch256 and in HANDOFF;
;
; TAPE MAP  (home @0)
;   @0x00:0x15  the paste workspace; aes/xtime reaches 0 to 21 and idiom/xor8
;               reaches 0 to 16  so twenty two cells serve both  and every
;               paste sits at this file's own zero
;   @0x16:0x19  a0 a1 a2 a3  the column as read; THE ANSWERS COME BACK OVER
;               THEM  so a caller that pastes this gets its column mixed in
;               place and needs no second buffer
;   @0x1a       t    the exclusive or of all four
;   @0x1b:0x1e  x0 x1 x2 x3  each one xtime of a neighboring pair
;   @0x1f       g    the cell a copy hands its value back through
;
; THE ORDER IS FORCED BY WHAT IS STILL NEEDED; b_3 wants a_0  so every x_i is
; computed before any a_i is spent; After that each a_i is wanted once more
; and is MOVED rather than copied  which is why phase three is the cheap one;

  >>>>>>>>>>>>>>>>>>>>>>,>,>,>,                                ; the workspace is stepped over and the column read
                                                               ; above it
                                                               ; ASSERT ptr=25
                                                               ; ASSERT zero 0:21
                                                               ; ASSERT zero 26:31
<<<<<<<<<<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=0

; ============================================================ ; phase one : t is the exclusive or of all four
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
  [->>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<]     ; and back into t
                                                               ; ASSERT ptr=0
                                                               ; ASSERT zero 1:21

; ============================================================ ; phase two : x_i is xtime of a_i xor its neighbour
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
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<   ; that is x3
  <<<<<]                                                       ; continued
                                                               ; ASSERT ptr=0
                                                               ; ASSERT zero 1:21

; ============================================================ ; phase three : b_i is a_i xor t xor x_i
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
  [->>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<]       ; and it comes to rest where a3 was
                                                               ; ASSERT ptr=0
                                                               ; ASSERT zero 0:21
                                                               ; ASSERT zero 26:31

; emit
>>>>>>>>>>>>>>>>>>>>>>                                         ; the four bytes of the mixed column
  .>.>.>.
