; bfsodium XORWORD : the exclusive or of two four byte words
;
; NOTE square brackets are brainfuck loops  so comments use braces for counts;
;
; HAND WRITTEN; idiom/xor8 is PASTED four times;
;
; INTERFACE entry=24 exit=0 footprint=0:24
; IO  in:  a{4}  b{4}      (8 bytes)
;     out: (a xor b){4}    (4 bytes)
;
; AES IS FULL OF THIS; a word is the unit the key expansion works in  and
; AddRoundKey is four of these; It exists so that a caller pastes FOUR of them
; where it would otherwise paste sixteen exclusive ors  which matters because
; bfstyle caps a skeleton at two thousand lines and the key expansion is forty
; unrolled words;
;
; THE ANSWER COMES BACK OVER a  so a caller that pastes this gets its word
; replaced in place and needs no second buffer;
;
; TAPE MAP  (home @0)
;   @0x00:0x10  idiom/xor8 pasted at this file's own zero; its two operands go
;               in at @0x01 and @0x02 and its answer comes back at @0x00
;   @0x11:0x14  a{4}  first word; THE ANSWER COMES BACK HERE
;   @0x15:0x18  b{4}  second word  spent

  >>>>>>>>>>>>>>>>>,>,>,>,>,>,>,>,                             ; the two words  the workspace stepped over first
                                                               ; ASSERT ptr=24
                                                               ; ASSERT zero 0:16
  <<<<<<<<<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=0
  >>>>>>>>>>>>>>>>>[-<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>]<<<<<   ; byte 0 of each word
  <<<<<<<<<<<<                                                 ; continued
  >>>>>>>>>>>>>>>>>>>>>[-<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>
  >>>>]<<<<<<<<<<<<<<<<<<<<<                                   ; continued
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
  [->>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<]
  >>>>>>>>>>>>>>>>>>[-<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>]<<   ; byte 1 of each word
  <<<<<<<<<<<<<<<<                                             ; continued
  >>>>>>>>>>>>>>>>>>>>>>[-<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>
  >>>>>>>]<<<<<<<<<<<<<<<<<<<<<<                               ; continued
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
  [->>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<]
  >>>>>>>>>>>>>>>>>>>[-<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>   ; byte 2 of each word
  ]<<<<<<<<<<<<<<<<<<<                                         ; continued
  >>>>>>>>>>>>>>>>>>>>>>>[-<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>
  >>>>>>>>>>]<<<<<<<<<<<<<<<<<<<<<<<                           ; continued
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
  [->>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<]
  >>>>>>>>>>>>>>>>>>>>[-<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>   ; byte 3 of each word
  >>>]<<<<<<<<<<<<<<<<<<<<                                     ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>[-<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>
  >>>>>>>>>>>>>]<<<<<<<<<<<<<<<<<<<<<<<<                       ; continued
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
  [->>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<]
                                                               ; ASSERT zero 0:16
                                                               ; ASSERT zero 21:24

; emit
  >>>>>>>>>>>>>>>>>                                            ; the four bytes of the answer
  .>.>.>.
