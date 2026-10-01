; bfsodium KEYEXPAND128 : the AES_128 key schedule  176 bytes from 16
;
; NOTE square brackets are brainfuck loops  so comments use braces for counts;
;
; HAND WRITTEN; block/sbox256 and block/walk256 are INCLUDED  aes/xorword is
; PASTED four times  idiom/xor8 once and aes/xtime once;
;
; IO  in:  key{16}    (16 bytes)
;     out: w{176}     the eleven round keys  in order
;
; FIPS 197 section 5 point 2; Word i is w at i minus 4 xor temp  where temp is
; w at i minus 1  and every fourth word puts temp through RotWord then SubWord
; then an exclusive or with the round constant;
;
; THERE IS NO INTERFACE LINE AND THAT IS FORCED  for the reason aes/subbytes
; has none: the S box walk advances three cells a turn  so tools/bffoot cannot
; bound a footprint and tools/bfexpand will not paste it; This is a PROGRAM;
;
; ONE GROUP OF FOUR WORDS  WRITTEN ONCE  RUN TEN TIMES; the earlier cut of
; this file unrolled all forty words and ran to 1903 skeleton lines  which is
; past the size at which a person writes a file rather than generates one;
; The forty words are ten repetitions of the SAME four word group  so the
; group is written once and the loop runs it;
;
; FOUR STATIC SLOTS AND NO SHIFTING  AND THE LOOP DOES NOT COST THAT; The
; schedule only ever wants w at i minus 4 and w at i minus 1  so a four word
; window is enough; A ROLLING window would shift twelve bytes per word  which
; is four hundred and eighty moves over the forty words; The earlier cut
; avoided it by choosing the slot at generation time  arguing that word i
; lives in slot i mod 4 only because the words are unrolled;
;
; THAT ARGUMENT SURVIVES THE LOOP  because the slot pattern has period four
; and the body is one whole period: the first word of the body always writes
; slot 0 and reads its temp from slot 3  the second writes slot 1 and reads
; slot 0  and so on; Every slot is a fixed offset inside the body  so the
; window still never moves; SubBytes needed block/rotate16 because its
; sixteen bytes have no such period; the key schedule needs no conveyor;
;
; NO UNROLLED TAIL EITHER; all ten groups of the earlier cut were identical
; down to the byte  so the loop runs ten times and stops; The CIPHER's rounds
; are not identical  because round ten has no MixColumns  which is why
; aes/encrypt128 will need a tail where this does not;
;
; THE TABLE IS block/sbox256 NOW  AND THE LOOP IS FREE BECAUSE OF IT; the
; earlier cut wrote the S box as packed absolute runs of plus signs at 34
; thousand 193 instructions; block/sbox256 delta codes it against the previous
; entry  in whichever direction is shorter  for 17 thousand 149;
;
; THAT SAVING VERY NEARLY EXACTLY PAYS FOR THE LOOP; measured on the FIPS 197
; Appendix A key this file is 19 million 37 thousand 565 instructions against
; the unrolled cut's 19 million 35 thousand 884: plus 1 thousand 681  which is
; one hundredth of one percent; The table gives back about 17 thousand and the
; loop spends about as much walking to its counter and home  because the
; counter cannot live at cell 0 where the paste workspace lives  so it sits
; above the table and each of the ten turns pays 1636 instructions to reach it
; and return; Sixteen hundred fewer lines for no measurable cost;
;
; WHICH IS ALSO WHY THIS COMMIT CANNOT CLAIM IDENTICAL INSTRUCTION BYTES; the
; four word group below is the earlier cut's group verbatim  so the schedule
; arithmetic is unchanged to the byte; but the table is a different program
; for the same 256 constants  so the proof here is the VECTORS: FIPS 197
; Appendix A's published schedule and three more keys;
;
; THE ROUND CONSTANT IS DERIVED AND NOT TYPED; Rcon for round n is x to the n
; minus 1 in the field  so it starts at one and each round is aes/xtime of the
; last; Writing 01 02 04 08 10 20 40 80 1b 36 as ten constants would be ten
; more chances to make the mistake KMAC256 sample 4 already cost  and xtime is
; thirty three thousand instructions against the schedule's sixteen million;
;
; THE ANSWER IS EMITTED AS IT IS COMPUTED  four bytes at a time  so nothing
; holds a hundred and seventy six bytes and there is no buffer to size;
;
; TAPE MAP  (home @0)
;   @0x000:0x018  the paste workspace; aes/xorword reaches 0 to 24 and
;                 aes/xtime 0 to 21  so twenty five cells serve both  and
;                 every paste sits at this file's own zero
;   @0x019:0x028  window{16}  four slots of four bytes; slot s at 25 plus 4s
;   @0x029:0x02c  temp{4}     w at i minus 1  worked on in place
;   @0x02d        rcon        the round constant  one  then xtime of itself
;   @0x02e        g           the cell a copy hands its value back through
;   @0x02f:0x031  group 0 of the S box walk; ITS TRAIL IS NEVER SET  and the
;                 index arrives in its walker cell at @0x030
;   @0x032:0x331  groups 1 to 256  the S box; element k in group k plus one
;   @0x332        cnt    u8  groups still to do  starts at ten; IT SITS ABOVE
;                 THE TABLE and not at cell 0 because the paste workspace
;                 owns cell 0  so the loop cannot test there; the walk to it
;                 and back is 1636 instructions a turn  which against this
;                 file's sixteen million is not worth a cheaper home

; the key  the workspace stepped over first
; the key  the workspace stepped over first
  >>>>>>>>>>>>>>>>>>>>>>>>>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,
                                                               ; ASSERT ptr=40
                                                               ; ASSERT zero 0:24
                                                               ; ASSERT zero 41:817
  <<<<<<<<<<<<<<<                                              ; the first four words ARE the key  so they go out
                                                               ; unchanged
  .>.>.>.>.>.>.>.>.>.>.>.>.>.>.>.
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=0

; ============================================================ ; the S box is written into the tape  one datum per
                                                               ; group
                                                               ; block/sbox256 lands its first datum where the pointer
                                                               ; stands and its last at 765 cells further on
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                                                               ; ASSERT ptr=50
                                                               ; S the AES S box  two hundred and fifty six entries
                                                               ; one to a line laid out for the stride three walk:
                                                               ; datum  walker  trail  so each entry is followed by a
                                                               ; step of three; the caller walks in to the first datum
                                                               ; and back out from the last;
;
                                                               ; FIPS 197 section 5 point 1 point 1; DERIVED and not
                                                               ; typed  and the form is the one sha256/hashcore uses
                                                               ; for its round constants: a comment naming the value
                                                               ; then a delta coded run  shorter direction  which
                                                               ; leans on the cell wrapping at 256 and halves the
                                                               ; cost;
;
                                                               ; It is the multiplicative inverse in GF(2^8) then an
                                                               ; affine transform; block/invsbox256 is the same
                                                               ; permutation read backwards; S of 0x00 is 0x63
  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  +++++++++++++++++++++++++++++++++++++++++>>>                 ; continued
  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   ; S of 0x01 is 0x7c
  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   ; continued
  ++++++++>>>                                                  ; continued
  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   ; S of 0x02 is 0x77
  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   ; continued
  +++>>>                                                       ; continued
  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   ; S of 0x03 is 0x7b
  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   ; continued
  +++++++>>>                                                   ; continued
  -------------->>>                                            ; S of 0x04 is 0xf2
  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   ; S of 0x05 is 0x6b
  +++++++++++++++++++++++++++++++++++++++++++++++++>>>         ; continued
  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   ; S of 0x06 is 0x6f
  +++++++++++++++++++++++++++++++++++++++++++++++++++++>>>     ; continued
  ----------------------------------------------------------   ; S of 0x07 is 0xc5
  ->>>                                                         ; continued
  ++++++++++++++++++++++++++++++++++++++++++++++++>>>          ; S of 0x08 is 0x30
  +>>>                                                         ; S of 0x09 is 0x01
  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   ; S of 0x0a is 0x67
  +++++++++++++++++++++++++++++++++++++++++++++>>>             ; continued
  +++++++++++++++++++++++++++++++++++++++++++>>>               ; S of 0x0b is 0x2b
  -->>>                                                        ; S of 0x0c is 0xfe
  ----------------------------------------->>>                 ; S of 0x0d is 0xd7
  ----------------------------------------------------------   ; S of 0x0e is 0xab
  --------------------------->>>                               ; continued
  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   ; S of 0x0f is 0x76
  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   ; continued
  ++>>>                                                        ; continued
  ------------------------------------------------------>>>    ; S of 0x10 is 0xca
  ----------------------------------------------------------   ; S of 0x11 is 0x82
  ----------------------------------------------------------   ; continued
  ---------->>>                                                ; continued
  ------------------------------------------------------->>>   ; S of 0x12 is 0xc9
  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   ; S of 0x13 is 0x7d
  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   ; continued
  +++++++++>>>                                                 ; continued
  ------>>>                                                    ; S of 0x14 is 0xfa
  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   ; S of 0x15 is 0x59
  +++++++++++++++++++++++++++++++>>>                           ; continued
  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   ; S of 0x16 is 0x47
  +++++++++++++>>>                                             ; continued
  ---------------->>>                                          ; S of 0x17 is 0xf0
  ----------------------------------------------------------   ; S of 0x18 is 0xad
  ------------------------->>>                                 ; continued
  -------------------------------------------->>>              ; S of 0x19 is 0xd4
  ----------------------------------------------------------   ; S of 0x1a is 0xa2
  ------------------------------------>>>                      ; continued
  ----------------------------------------------------------   ; S of 0x1b is 0xaf
  ----------------------->>>                                   ; continued
  ----------------------------------------------------------   ; S of 0x1c is 0x9c
  ------------------------------------------>>>                ; continued
  ----------------------------------------------------------   ; S of 0x1d is 0xa4
  ---------------------------------->>>                        ; continued
  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   ; S of 0x1e is 0x72
  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++>>   ; continued
  >                                                            ; continued
  ----------------------------------------------------------   ; S of 0x1f is 0xc0
  ------>>>                                                    ; continued
  ----------------------------------------------------------   ; S of 0x20 is 0xb7
  --------------->>>                                           ; continued
  --->>>                                                       ; S of 0x21 is 0xfd
  ----------------------------------------------------------   ; S of 0x22 is 0x93
  --------------------------------------------------->>>       ; continued
  ++++++++++++++++++++++++++++++++++++++>>>                    ; S of 0x23 is 0x26
  ++++++++++++++++++++++++++++++++++++++++++++++++++++++>>>    ; S of 0x24 is 0x36
  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   ; S of 0x25 is 0x3f
  +++++>>>                                                     ; continued
  --------->>>                                                 ; S of 0x26 is 0xf7
  ---------------------------------------------------->>>      ; S of 0x27 is 0xcc
  ++++++++++++++++++++++++++++++++++++++++++++++++++++>>>      ; S of 0x28 is 0x34
  ----------------------------------------------------------   ; S of 0x29 is 0xa5
  --------------------------------->>>                         ; continued
  --------------------------->>>                               ; S of 0x2a is 0xe5
  --------------->>>                                           ; S of 0x2b is 0xf1
  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   ; S of 0x2c is 0x71
  +++++++++++++++++++++++++++++++++++++++++++++++++++++++>>>   ; continued
  ---------------------------------------->>>                  ; S of 0x2d is 0xd8
  +++++++++++++++++++++++++++++++++++++++++++++++++>>>         ; S of 0x2e is 0x31
  +++++++++++++++++++++>>>                                     ; S of 0x2f is 0x15
  ++++>>>                                                      ; S of 0x30 is 0x04
  --------------------------------------------------------->   ; S of 0x31 is 0xc7
  >>                                                           ; continued
  +++++++++++++++++++++++++++++++++++>>>                       ; S of 0x32 is 0x23
  ----------------------------------------------------------   ; S of 0x33 is 0xc3
  --->>>                                                       ; continued
  ++++++++++++++++++++++++>>>                                  ; S of 0x34 is 0x18
  ----------------------------------------------------------   ; S of 0x35 is 0x96
  ------------------------------------------------>>>          ; continued
  +++++>>>                                                     ; S of 0x36 is 0x05
  ----------------------------------------------------------   ; S of 0x37 is 0x9a
  -------------------------------------------->>>              ; continued
  +++++++>>>                                                   ; S of 0x38 is 0x07
  ++++++++++++++++++>>>                                        ; S of 0x39 is 0x12
  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   ; S of 0x3a is 0x80
  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   ; continued
  ++++++++++++>>>                                              ; continued
  ------------------------------>>>                            ; S of 0x3b is 0xe2
  --------------------->>>                                     ; S of 0x3c is 0xeb
  +++++++++++++++++++++++++++++++++++++++>>>                   ; S of 0x3d is 0x27
  ----------------------------------------------------------   ; S of 0x3e is 0xb2
  -------------------->>>                                      ; continued
  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   ; S of 0x3f is 0x75
  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   ; continued
  +>>>                                                         ; continued
  +++++++++>>>                                                 ; S of 0x40 is 0x09
  ----------------------------------------------------------   ; S of 0x41 is 0x83
  ----------------------------------------------------------   ; continued
  --------->>>                                                 ; continued
  ++++++++++++++++++++++++++++++++++++++++++++>>>              ; S of 0x42 is 0x2c
  ++++++++++++++++++++++++++>>>                                ; S of 0x43 is 0x1a
  +++++++++++++++++++++++++++>>>                               ; S of 0x44 is 0x1b
  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   ; S of 0x45 is 0x6e
  ++++++++++++++++++++++++++++++++++++++++++++++++++++>>>      ; continued
  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   ; S of 0x46 is 0x5a
  ++++++++++++++++++++++++++++++++>>>                          ; continued
  ----------------------------------------------------------   ; S of 0x47 is 0xa0
  -------------------------------------->>>                    ; continued
  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   ; S of 0x48 is 0x52
  ++++++++++++++++++++++++>>>                                  ; continued
  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   ; S of 0x49 is 0x3b
  +>>>                                                         ; continued
  ------------------------------------------>>>                ; S of 0x4a is 0xd6
  ----------------------------------------------------------   ; S of 0x4b is 0xb3
  ------------------->>>                                       ; continued
  +++++++++++++++++++++++++++++++++++++++++>>>                 ; S of 0x4c is 0x29
  ----------------------------->>>                             ; S of 0x4d is 0xe3
  +++++++++++++++++++++++++++++++++++++++++++++++>>>           ; S of 0x4e is 0x2f
  ----------------------------------------------------------   ; S of 0x4f is 0x84
  ----------------------------------------------------------   ; continued
  -------->>>                                                  ; continued
  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   ; S of 0x50 is 0x53
  +++++++++++++++++++++++++>>>                                 ; continued
  ----------------------------------------------->>>           ; S of 0x51 is 0xd1
  >>>                                                          ; S of 0x52 is 0x00
  ------------------->>>                                       ; S of 0x53 is 0xed
  ++++++++++++++++++++++++++++++++>>>                          ; S of 0x54 is 0x20
  ---->>>                                                      ; S of 0x55 is 0xfc
  ----------------------------------------------------------   ; S of 0x56 is 0xb1
  --------------------->>>                                     ; continued
  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   ; S of 0x57 is 0x5b
  +++++++++++++++++++++++++++++++++>>>                         ; continued
  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   ; S of 0x58 is 0x6a
  ++++++++++++++++++++++++++++++++++++++++++++++++>>>          ; continued
  ----------------------------------------------------->>>     ; S of 0x59 is 0xcb
  ----------------------------------------------------------   ; S of 0x5a is 0xbe
  -------->>>                                                  ; continued
  +++++++++++++++++++++++++++++++++++++++++++++++++++++++++>   ; S of 0x5b is 0x39
  >>                                                           ; continued
  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   ; S of 0x5c is 0x4a
  ++++++++++++++++>>>                                          ; continued
  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   ; S of 0x5d is 0x4c
  ++++++++++++++++++>>>                                        ; continued
  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   ; S of 0x5e is 0x58
  ++++++++++++++++++++++++++++++>>>                            ; continued
  ------------------------------------------------->>>         ; S of 0x5f is 0xcf
  ------------------------------------------------>>>          ; S of 0x60 is 0xd0
  ----------------->>>                                         ; S of 0x61 is 0xef
  ----------------------------------------------------------   ; S of 0x62 is 0xaa
  ---------------------------->>>                              ; continued
  ----->>>                                                     ; S of 0x63 is 0xfb
  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   ; S of 0x64 is 0x43
  +++++++++>>>                                                 ; continued
  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   ; S of 0x65 is 0x4d
  +++++++++++++++++++>>>                                       ; continued
  +++++++++++++++++++++++++++++++++++++++++++++++++++>>>       ; S of 0x66 is 0x33
  ----------------------------------------------------------   ; S of 0x67 is 0x85
  ----------------------------------------------------------   ; continued
  ------->>>                                                   ; continued
  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   ; S of 0x68 is 0x45
  +++++++++++>>>                                               ; continued
  ------->>>                                                   ; S of 0x69 is 0xf9
  ++>>>                                                        ; S of 0x6a is 0x02
  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   ; S of 0x6b is 0x7f
  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   ; continued
  +++++++++++>>>                                               ; continued
  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   ; S of 0x6c is 0x50
  ++++++++++++++++++++++>>>                                    ; continued
  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   ; S of 0x6d is 0x3c
  ++>>>                                                        ; continued
  ----------------------------------------------------------   ; S of 0x6e is 0x9f
  --------------------------------------->>>                   ; continued
  ----------------------------------------------------------   ; S of 0x6f is 0xa8
  ------------------------------>>>                            ; continued
  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   ; S of 0x70 is 0x51
  +++++++++++++++++++++++>>>                                   ; continued
  ----------------------------------------------------------   ; S of 0x71 is 0xa3
  ----------------------------------->>>                       ; continued
  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   ; S of 0x72 is 0x40
  ++++++>>>                                                    ; continued
  ----------------------------------------------------------   ; S of 0x73 is 0x8f
  ------------------------------------------------------->>>   ; continued
  ----------------------------------------------------------   ; S of 0x74 is 0x92
  ---------------------------------------------------->>>      ; continued
  ----------------------------------------------------------   ; S of 0x75 is 0x9d
  ----------------------------------------->>>                 ; continued
  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++>>   ; S of 0x76 is 0x38
  >                                                            ; continued
  ----------->>>                                               ; S of 0x77 is 0xf5
  ----------------------------------------------------------   ; S of 0x78 is 0xbc
  ---------->>>                                                ; continued
  ----------------------------------------------------------   ; S of 0x79 is 0xb6
  ---------------->>>                                          ; continued
  -------------------------------------->>>                    ; S of 0x7a is 0xda
  +++++++++++++++++++++++++++++++++>>>                         ; S of 0x7b is 0x21
  ++++++++++++++++>>>                                          ; S of 0x7c is 0x10
  ->>>                                                         ; S of 0x7d is 0xff
  ------------->>>                                             ; S of 0x7e is 0xf3
  ---------------------------------------------->>>            ; S of 0x7f is 0xd2
  --------------------------------------------------->>>       ; S of 0x80 is 0xcd
  ++++++++++++>>>                                              ; S of 0x81 is 0x0c
  +++++++++++++++++++>>>                                       ; S of 0x82 is 0x13
  -------------------->>>                                      ; S of 0x83 is 0xec
  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   ; S of 0x84 is 0x5f
  +++++++++++++++++++++++++++++++++++++>>>                     ; continued
  ----------------------------------------------------------   ; S of 0x85 is 0x97
  ----------------------------------------------->>>           ; continued
  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   ; S of 0x86 is 0x44
  ++++++++++>>>                                                ; continued
  +++++++++++++++++++++++>>>                                   ; S of 0x87 is 0x17
  ----------------------------------------------------------   ; S of 0x88 is 0xc4
  -->>>                                                        ; continued
  ----------------------------------------------------------   ; S of 0x89 is 0xa7
  ------------------------------->>>                           ; continued
  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   ; S of 0x8a is 0x7e
  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   ; continued
  ++++++++++>>>                                                ; continued
  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   ; S of 0x8b is 0x3d
  +++>>>                                                       ; continued
  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   ; S of 0x8c is 0x64
  ++++++++++++++++++++++++++++++++++++++++++>>>                ; continued
  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   ; S of 0x8d is 0x5d
  +++++++++++++++++++++++++++++++++++>>>                       ; continued
  +++++++++++++++++++++++++>>>                                 ; S of 0x8e is 0x19
  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   ; S of 0x8f is 0x73
  +++++++++++++++++++++++++++++++++++++++++++++++++++++++++>   ; continued
  >>                                                           ; continued
  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   ; S of 0x90 is 0x60
  ++++++++++++++++++++++++++++++++++++++>>>                    ; continued
  ----------------------------------------------------------   ; S of 0x91 is 0x81
  ----------------------------------------------------------   ; continued
  ----------->>>                                               ; continued
  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   ; S of 0x92 is 0x4f
  +++++++++++++++++++++>>>                                     ; continued
  ------------------------------------>>>                      ; S of 0x93 is 0xdc
  ++++++++++++++++++++++++++++++++++>>>                        ; S of 0x94 is 0x22
  ++++++++++++++++++++++++++++++++++++++++++>>>                ; S of 0x95 is 0x2a
  ----------------------------------------------------------   ; S of 0x96 is 0x90
  ------------------------------------------------------>>>    ; continued
  ----------------------------------------------------------   ; S of 0x97 is 0x88
  ----------------------------------------------------------   ; continued
  ---->>>                                                      ; continued
  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   ; S of 0x98 is 0x46
  ++++++++++++>>>                                              ; continued
  ------------------>>>                                        ; S of 0x99 is 0xee
  ----------------------------------------------------------   ; S of 0x9a is 0xb8
  -------------->>>                                            ; continued
  ++++++++++++++++++++>>>                                      ; S of 0x9b is 0x14
  ---------------------------------->>>                        ; S of 0x9c is 0xde
  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   ; S of 0x9d is 0x5e
  ++++++++++++++++++++++++++++++++++++>>>                      ; continued
  +++++++++++>>>                                               ; S of 0x9e is 0x0b
  ------------------------------------->>>                     ; S of 0x9f is 0xdb
  -------------------------------->>>                          ; S of 0xa0 is 0xe0
  ++++++++++++++++++++++++++++++++++++++++++++++++++>>>        ; S of 0xa1 is 0x32
  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   ; S of 0xa2 is 0x3a
  >>>                                                          ; continued
  ++++++++++>>>                                                ; S of 0xa3 is 0x0a
  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   ; S of 0xa4 is 0x49
  +++++++++++++++>>>                                           ; continued
  ++++++>>>                                                    ; S of 0xa5 is 0x06
  ++++++++++++++++++++++++++++++++++++>>>                      ; S of 0xa6 is 0x24
  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   ; S of 0xa7 is 0x5c
  ++++++++++++++++++++++++++++++++++>>>                        ; continued
  ----------------------------------------------------------   ; S of 0xa8 is 0xc2
  ---->>>                                                      ; continued
  --------------------------------------------->>>             ; S of 0xa9 is 0xd3
  ----------------------------------------------------------   ; S of 0xaa is 0xac
  -------------------------->>>                                ; continued
  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   ; S of 0xab is 0x62
  ++++++++++++++++++++++++++++++++++++++++>>>                  ; continued
  ----------------------------------------------------------   ; S of 0xac is 0x91
  ----------------------------------------------------->>>     ; continued
  ----------------------------------------------------------   ; S of 0xad is 0x95
  ------------------------------------------------->>>         ; continued
  ---------------------------->>>                              ; S of 0xae is 0xe4
  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   ; S of 0xaf is 0x79
  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   ; continued
  +++++>>>                                                     ; continued
  ------------------------->>>                                 ; S of 0xb0 is 0xe7
  -------------------------------------------------------->>   ; S of 0xb1 is 0xc8
  >                                                            ; continued
  +++++++++++++++++++++++++++++++++++++++++++++++++++++++>>>   ; S of 0xb2 is 0x37
  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   ; S of 0xb3 is 0x6d
  +++++++++++++++++++++++++++++++++++++++++++++++++++>>>       ; continued
  ----------------------------------------------------------   ; S of 0xb4 is 0x8d
  --------------------------------------------------------->   ; continued
  >>                                                           ; continued
  ------------------------------------------->>>               ; S of 0xb5 is 0xd5
  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   ; S of 0xb6 is 0x4e
  ++++++++++++++++++++>>>                                      ; continued
  ----------------------------------------------------------   ; S of 0xb7 is 0xa9
  ----------------------------->>>                             ; continued
  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   ; S of 0xb8 is 0x6c
  ++++++++++++++++++++++++++++++++++++++++++++++++++>>>        ; continued
  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   ; S of 0xb9 is 0x56
  ++++++++++++++++++++++++++++>>>                              ; continued
  ------------>>>                                              ; S of 0xba is 0xf4
  ---------------------->>>                                    ; S of 0xbb is 0xea
  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   ; S of 0xbc is 0x65
  +++++++++++++++++++++++++++++++++++++++++++>>>               ; continued
  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   ; S of 0xbd is 0x7a
  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   ; continued
  ++++++>>>                                                    ; continued
  ----------------------------------------------------------   ; S of 0xbe is 0xae
  ------------------------>>>                                  ; continued
  ++++++++>>>                                                  ; S of 0xbf is 0x08
  ----------------------------------------------------------   ; S of 0xc0 is 0xba
  ------------>>>                                              ; continued
  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   ; S of 0xc1 is 0x78
  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   ; continued
  ++++>>>                                                      ; continued
  +++++++++++++++++++++++++++++++++++++>>>                     ; S of 0xc2 is 0x25
  ++++++++++++++++++++++++++++++++++++++++++++++>>>            ; S of 0xc3 is 0x2e
  ++++++++++++++++++++++++++++>>>                              ; S of 0xc4 is 0x1c
  ----------------------------------------------------------   ; S of 0xc5 is 0xa6
  -------------------------------->>>                          ; continued
  ----------------------------------------------------------   ; S of 0xc6 is 0xb4
  ------------------>>>                                        ; continued
  ----------------------------------------------------------   ; S of 0xc7 is 0xc6
  >>>                                                          ; continued
  ------------------------>>>                                  ; S of 0xc8 is 0xe8
  ----------------------------------->>>                       ; S of 0xc9 is 0xdd
  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   ; S of 0xca is 0x74
  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   ; continued
  >>>                                                          ; continued
  +++++++++++++++++++++++++++++++>>>                           ; S of 0xcb is 0x1f
  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   ; S of 0xcc is 0x4b
  +++++++++++++++++>>>                                         ; continued
  ----------------------------------------------------------   ; S of 0xcd is 0xbd
  --------->>>                                                 ; continued
  ----------------------------------------------------------   ; S of 0xce is 0x8b
  ----------------------------------------------------------   ; continued
  ->>>                                                         ; continued
  ----------------------------------------------------------   ; S of 0xcf is 0x8a
  ----------------------------------------------------------   ; continued
  -->>>                                                        ; continued
  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   ; S of 0xd0 is 0x70
  ++++++++++++++++++++++++++++++++++++++++++++++++++++++>>>    ; continued
  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   ; S of 0xd1 is 0x3e
  ++++>>>                                                      ; continued
  ----------------------------------------------------------   ; S of 0xd2 is 0xb5
  ----------------->>>                                         ; continued
  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   ; S of 0xd3 is 0x66
  ++++++++++++++++++++++++++++++++++++++++++++>>>              ; continued
  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   ; S of 0xd4 is 0x48
  ++++++++++++++>>>                                            ; continued
  +++>>>                                                       ; S of 0xd5 is 0x03
  ---------->>>                                                ; S of 0xd6 is 0xf6
  ++++++++++++++>>>                                            ; S of 0xd7 is 0x0e
  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   ; S of 0xd8 is 0x61
  +++++++++++++++++++++++++++++++++++++++>>>                   ; continued
  +++++++++++++++++++++++++++++++++++++++++++++++++++++>>>     ; S of 0xd9 is 0x35
  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   ; S of 0xda is 0x57
  +++++++++++++++++++++++++++++>>>                             ; continued
  ----------------------------------------------------------   ; S of 0xdb is 0xb9
  ------------->>>                                             ; continued
  ----------------------------------------------------------   ; S of 0xdc is 0x86
  ----------------------------------------------------------   ; continued
  ------>>>                                                    ; continued
  ----------------------------------------------------------   ; S of 0xdd is 0xc1
  ----->>>                                                     ; continued
  +++++++++++++++++++++++++++++>>>                             ; S of 0xde is 0x1d
  ----------------------------------------------------------   ; S of 0xdf is 0x9e
  ---------------------------------------->>>                  ; continued
  ------------------------------->>>                           ; S of 0xe0 is 0xe1
  -------->>>                                                  ; S of 0xe1 is 0xf8
  ----------------------------------------------------------   ; S of 0xe2 is 0x98
  ---------------------------------------------->>>            ; continued
  +++++++++++++++++>>>                                         ; S of 0xe3 is 0x11
  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   ; S of 0xe4 is 0x69
  +++++++++++++++++++++++++++++++++++++++++++++++>>>           ; continued
  --------------------------------------->>>                   ; S of 0xe5 is 0xd9
  ----------------------------------------------------------   ; S of 0xe6 is 0x8e
  -------------------------------------------------------->>   ; continued
  >                                                            ; continued
  ----------------------------------------------------------   ; S of 0xe7 is 0x94
  -------------------------------------------------->>>        ; continued
  ----------------------------------------------------------   ; S of 0xe8 is 0x9b
  ------------------------------------------->>>               ; continued
  ++++++++++++++++++++++++++++++>>>                            ; S of 0xe9 is 0x1e
  ----------------------------------------------------------   ; S of 0xea is 0x87
  ----------------------------------------------------------   ; continued
  ----->>>                                                     ; continued
  ----------------------->>>                                   ; S of 0xeb is 0xe9
  -------------------------------------------------->>>        ; S of 0xec is 0xce
  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   ; S of 0xed is 0x55
  +++++++++++++++++++++++++++>>>                               ; continued
  ++++++++++++++++++++++++++++++++++++++++>>>                  ; S of 0xee is 0x28
  --------------------------------->>>                         ; S of 0xef is 0xdf
  ----------------------------------------------------------   ; S of 0xf0 is 0x8c
  ----------------------------------------------------------   ; continued
  >>>                                                          ; continued
  ----------------------------------------------------------   ; S of 0xf1 is 0xa1
  ------------------------------------->>>                     ; continued
  ----------------------------------------------------------   ; S of 0xf2 is 0x89
  ----------------------------------------------------------   ; continued
  --->>>                                                       ; continued
  +++++++++++++>>>                                             ; S of 0xf3 is 0x0d
  ----------------------------------------------------------   ; S of 0xf4 is 0xbf
  ------->>>                                                   ; continued
  -------------------------->>>                                ; S of 0xf5 is 0xe6
  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   ; S of 0xf6 is 0x42
  ++++++++>>>                                                  ; continued
  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   ; S of 0xf7 is 0x68
  ++++++++++++++++++++++++++++++++++++++++++++++>>>            ; continued
  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   ; S of 0xf8 is 0x41
  +++++++>>>                                                   ; continued
  ----------------------------------------------------------   ; S of 0xf9 is 0x99
  --------------------------------------------->>>             ; continued
  +++++++++++++++++++++++++++++++++++++++++++++>>>             ; S of 0xfa is 0x2d
  +++++++++++++++>>>                                           ; S of 0xfb is 0x0f
  ----------------------------------------------------------   ; S of 0xfc is 0xb0
  ---------------------->>>                                    ; continued
  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   ; S of 0xfd is 0x54
  ++++++++++++++++++++++++++>>>                                ; continued
  ----------------------------------------------------------   ; S of 0xfe is 0xbb
  ----------->>>                                               ; continued
  ++++++++++++++++++++++                                       ; S of 0xff is 0x16
                                                               ; ASSERT ptr=815
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<                                             ; continued
                                                               ; ASSERT ptr=45
  +                                                            ; the round constant starts at one

  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; ten groups of four words
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>>>>>>>>>>>>>>>                                          ; continued
                                                               ; ASSERT ptr=818
  ++++++++++
  [-
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<                                                       ; continued
                                                               ; ASSERT ptr=0

; ============================================================ ; ONE GROUP OF FOUR WORDS  run ten times
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>[->>>>+>>>>>+<<<<<<<<
  <]>>>>>>>>>[-<<<<<<<<<+>>>>>>>>>]<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<                                        ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>[->>>>+>>>>+<<<<<<<<
  ]>>>>>>>>[-<<<<<<<<+>>>>>>>>]<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<                                            ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>[->>>>+>>>+<<<<<<<]
  >>>>>>>[-<<<<<<<+>>>>>>>]<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<                                                ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>[->>>>+>>+<<<<<<]>
  >>>>>[-<<<<<<+>>>>>>]<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<                                                    ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>[->>>>>+<<<<<]<<<   ; RotWord: the four bytes turn left by one
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<                       ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>[-<+>]<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<                             ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>[-<+>]<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<                           ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>[-<+>]<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<                         ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>[-<<+>>]<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<                   ; continued
                                                               ; SubWord: each of them through the S box  the walk
                                                               ; carried here because it cannot be pasted
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>[->>>>>>>+<<<<<<<
  ]<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<                   ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  [->>>+<<<]
>>>
  [-[->>>+<<<]>+<>>>]
  <[->+>+<<]>>[-<<+>>]<
  [-<<<+>>>]<<[-<[-<<<+>>>]<<]
  <
                                                               ; ASSERT ptr=48
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>[-<<<<<<<+
  >>>>>>>]<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<     ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>[->>>>>>+<<<<<<]
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<                   ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  [->>>+<<<]
>>>
  [-[->>>+<<<]>+<>>>]
  <[->+>+<<]>>[-<<+>>]<
  [-<<<+>>>]<<[-<[-<<<+>>>]<<]
  <
                                                               ; ASSERT ptr=48
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>[-<<<<<<+>
  >>>>>]<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<       ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>[->>>>>+<<<<<]<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<                   ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  [->>>+<<<]
>>>
  [-[->>>+<<<]>+<>>>]
  <[->+>+<<]>>[-<<+>>]<
  [-<<<+>>>]<<[-<[-<<<+>>>]<<]
  <
                                                               ; ASSERT ptr=48
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>[-<<<<<+>>
  >>>]<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<         ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>[->>>>+<<<<]<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<                   ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  [->>>+<<<]
>>>
  [-[->>>+<<<]>+<>>>]
  <[->+>+<<]>>[-<<+>>]<
  [-<<<+>>>]<<[-<[-<<<+>>>]<<]
  <
                                                               ; ASSERT ptr=48
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>[-<<<<+>>>
  >]<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<           ; continued
                                                               ; the round constant goes into the first byte only  and
                                                               ; it is COPIED: it is wanted again to make the next one
                                                               ; and a move would spend it
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>[-<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>>>>]<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<           ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>[-<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>>>>>>>>>>>>>>>+<]>[-<+>]<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<                                            ; continued
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
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<]                                 ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>[-<<<<<<<<<<<   ; and the constant becomes the next one  which is xtime
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>   ; of it
  >>>>>>>>>>>>>>>>>>>>>>]<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<                                                   ; continued
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
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]                         ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>[-<<<<<<<<+>>>>>>>>]<<<<<<<<<<<<<   ; the new word is w at i minus 4 against temp
  <<<<<<<<<<<<                                                 ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>[-<<<<<<<<+>>>>>>>>]<<<<<<<<<<<<
  <<<<<<<<<<<<<<                                               ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>[-<<<<<<<<+>>>>>>>>]<<<<<<<<<<<
  <<<<<<<<<<<<<<<<                                             ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>[-<<<<<<<<+>>>>>>>>]<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<                                           ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>[-<<<<<<<<<<<<<<<
  <<<<<+>>>>>>>>>>>>>>>>>>>>]<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<                                                   ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>[-<<<<<<<<<<<<<<
  <<<<<<+>>>>>>>>>>>>>>>>>>>>]<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<                                                 ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>[-<<<<<<<<<<<<<
  <<<<<<<+>>>>>>>>>>>>>>>>>>>>]<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<                                               ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>[-<<<<<<<<<<<<
  <<<<<<<<+>>>>>>>>>>>>>>>>>>>>]<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<                                             ; continued
                                                               ; ASSERT ptr=0
  >>>>>>>>>>>>>>>>>>>>>>>>                                     ; walk in to this routine entry offset
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
  [->>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<]
                                                               ; ASSERT zero 0:16
                                                               ; ASSERT zero 21:24

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=0
  >>>>>>>>>>>>>>>>>                                            ; out it goes  and into the slot it came from
  .>.>.>.
  <<<<<<<<<<<<<<<<<<<<
  >>>>>>>>>>>>>>>>>[->>>>>>>>+<<<<<<<<]<<<<<<<<<<<<<<<<<
  >>>>>>>>>>>>>>>>>>[->>>>>>>>+<<<<<<<<]<<<<<<<<<<<<<<<<<<
  >>>>>>>>>>>>>>>>>>>[->>>>>>>>+<<<<<<<<]<<<<<<<<<<<<<<<<<<<
  >>>>>>>>>>>>>>>>>>>>[->>>>>>>>+<<<<<<<<]<<<<<<<<<<<<<<<<<<
  <<                                                           ; continued
                                                               ; ASSERT ptr=0

; ============================================================ ; word 5 : slot 1 takes it  temp comes from slot 0
  >>>>>>>>>>>>>>>>>>>>>>>>>[->>>>>>>>>>>>>>>>+>>>>>+<<<<<<<<
  <<<<<<<<<<<<<]>>>>>>>>>>>>>>>>>>>>>[-<<<<<<<<<<<<<<<<<<<<<   ; continued
  +>>>>>>>>>>>>>>>>>>>>>]<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<                                                  ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>[->>>>>>>>>>>>>>>>+>>>>+<<<<<<<<
  <<<<<<<<<<<<]>>>>>>>>>>>>>>>>>>>>[-<<<<<<<<<<<<<<<<<<<<+>>   ; continued
  >>>>>>>>>>>>>>>>>>]<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<                                                      ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>[->>>>>>>>>>>>>>>>+>>>+<<<<<<<<
  <<<<<<<<<<<]>>>>>>>>>>>>>>>>>>>[-<<<<<<<<<<<<<<<<<<<+>>>>>   ; continued
  >>>>>>>>>>>>>>]<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<                                                          ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>[->>>>>>>>>>>>>>>>+>>+<<<<<<<<
  <<<<<<<<<<]>>>>>>>>>>>>>>>>>>[-<<<<<<<<<<<<<<<<<<+>>>>>>>>   ; continued
  >>>>>>>>>>]<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<    ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>[-<<<<<<<<<<<<+>>>>>>>>>>>>]<   ; the new word is w at i minus 4 against temp
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<                                 ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>[-<<<<<<<<<<<<+>>>>>>>>>>>>]
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<                               ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>[-<<<<<<<<<<<<+>>>>>>>>>>>>
  ]<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<                             ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>[-<<<<<<<<<<<<+>>>>>>>>>>>
  >]<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<                           ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>[-<<<<<<<<<<<<<<<
  <<<<<+>>>>>>>>>>>>>>>>>>>>]<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<                                                   ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>[-<<<<<<<<<<<<<<
  <<<<<<+>>>>>>>>>>>>>>>>>>>>]<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<                                                 ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>[-<<<<<<<<<<<<<
  <<<<<<<+>>>>>>>>>>>>>>>>>>>>]<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<                                               ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>[-<<<<<<<<<<<<
  <<<<<<<<+>>>>>>>>>>>>>>>>>>>>]<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<                                             ; continued
                                                               ; ASSERT ptr=0
  >>>>>>>>>>>>>>>>>>>>>>>>                                     ; walk in to this routine entry offset
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
  [->>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<]
                                                               ; ASSERT zero 0:16
                                                               ; ASSERT zero 21:24

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=0
  >>>>>>>>>>>>>>>>>                                            ; out it goes  and into the slot it came from
  .>.>.>.
  <<<<<<<<<<<<<<<<<<<<
  >>>>>>>>>>>>>>>>>[->>>>>>>>>>>>+<<<<<<<<<<<<]<<<<<<<<<<<<<
  <<<<                                                         ; continued
  >>>>>>>>>>>>>>>>>>[->>>>>>>>>>>>+<<<<<<<<<<<<]<<<<<<<<<<<<
  <<<<<<                                                       ; continued
  >>>>>>>>>>>>>>>>>>>[->>>>>>>>>>>>+<<<<<<<<<<<<]<<<<<<<<<<<
  <<<<<<<<                                                     ; continued
  >>>>>>>>>>>>>>>>>>>>[->>>>>>>>>>>>+<<<<<<<<<<<<]<<<<<<<<<<
  <<<<<<<<<<                                                   ; continued
                                                               ; ASSERT ptr=0

; ============================================================ ; word 6 : slot 2 takes it  temp comes from slot 1
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>[->>>>>>>>>>>>+>>>>>+<<<<<<<<
  <<<<<<<<<]>>>>>>>>>>>>>>>>>[-<<<<<<<<<<<<<<<<<+>>>>>>>>>>>   ; continued
  >>>>>>]<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<        ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>[->>>>>>>>>>>>+>>>>+<<<<<<<<
  <<<<<<<<]>>>>>>>>>>>>>>>>[-<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>   ; continued
  >>]<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<            ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>[->>>>>>>>>>>>+>>>+<<<<<<<<
  <<<<<<<]>>>>>>>>>>>>>>>[-<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>]<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<                ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>[->>>>>>>>>>>>+>>+<<<<<<<<
  <<<<<<]>>>>>>>>>>>>>>[-<<<<<<<<<<<<<<+>>>>>>>>>>>>>>]<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<                    ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>[-<<<<<<<<<<<<<<<<+>>>>>>   ; the new word is w at i minus 4 against temp
  >>>>>>>>>>]<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<                 ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>[-<<<<<<<<<<<<<<<<+>>>>>
  >>>>>>>>>>>]<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<               ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>[-<<<<<<<<<<<<<<<<+>>>>
  >>>>>>>>>>>>]<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<             ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>[-<<<<<<<<<<<<<<<<+>>>
  >>>>>>>>>>>>>]<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<           ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>[-<<<<<<<<<<<<<<<
  <<<<<+>>>>>>>>>>>>>>>>>>>>]<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<                                                   ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>[-<<<<<<<<<<<<<<
  <<<<<<+>>>>>>>>>>>>>>>>>>>>]<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<                                                 ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>[-<<<<<<<<<<<<<
  <<<<<<<+>>>>>>>>>>>>>>>>>>>>]<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<                                               ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>[-<<<<<<<<<<<<
  <<<<<<<<+>>>>>>>>>>>>>>>>>>>>]<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<                                             ; continued
                                                               ; ASSERT ptr=0
  >>>>>>>>>>>>>>>>>>>>>>>>                                     ; walk in to this routine entry offset
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
  [->>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<]
                                                               ; ASSERT zero 0:16
                                                               ; ASSERT zero 21:24

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=0
  >>>>>>>>>>>>>>>>>                                            ; out it goes  and into the slot it came from
  .>.>.>.
  <<<<<<<<<<<<<<<<<<<<
  >>>>>>>>>>>>>>>>>[->>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<]<<<<<
  <<<<<<<<<<<<                                                 ; continued
  >>>>>>>>>>>>>>>>>>[->>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<]<<<<
  <<<<<<<<<<<<<<                                               ; continued
  >>>>>>>>>>>>>>>>>>>[->>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<]<<<
  <<<<<<<<<<<<<<<<                                             ; continued
  >>>>>>>>>>>>>>>>>>>>[->>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<]<<
  <<<<<<<<<<<<<<<<<<                                           ; continued
                                                               ; ASSERT ptr=0

; ============================================================ ; word 7 : slot 3 takes it  temp comes from slot 2
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>[->>>>>>>>+>>>>>+<<<<<<<<
  <<<<<]>>>>>>>>>>>>>[-<<<<<<<<<<<<<+>>>>>>>>>>>>>]<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<                        ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>[->>>>>>>>+>>>>+<<<<<<<<
  <<<<]>>>>>>>>>>>>[-<<<<<<<<<<<<+>>>>>>>>>>>>]<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<                            ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>[->>>>>>>>+>>>+<<<<<<<<
  <<<]>>>>>>>>>>>[-<<<<<<<<<<<+>>>>>>>>>>>]<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<                                ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>[->>>>>>>>+>>+<<<<<<<<
  <<]>>>>>>>>>>[-<<<<<<<<<<+>>>>>>>>>>]<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<                                    ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>[-<<<<<<<<<<<<<<<<<<<   ; the new word is w at i minus 4 against temp
  <+>>>>>>>>>>>>>>>>>>>>]<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<                                                           ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>[-<<<<<<<<<<<<<<<<<<
  <<+>>>>>>>>>>>>>>>>>>>>]<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<                                                         ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>[-<<<<<<<<<<<<<<<<<
  <<<+>>>>>>>>>>>>>>>>>>>>]<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<                                                       ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>[-<<<<<<<<<<<<<<<<
  <<<<+>>>>>>>>>>>>>>>>>>>>]<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<                                                     ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>[-<<<<<<<<<<<<<<<
  <<<<<+>>>>>>>>>>>>>>>>>>>>]<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<                                                   ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>[-<<<<<<<<<<<<<<
  <<<<<<+>>>>>>>>>>>>>>>>>>>>]<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<                                                 ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>[-<<<<<<<<<<<<<
  <<<<<<<+>>>>>>>>>>>>>>>>>>>>]<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<                                               ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>[-<<<<<<<<<<<<
  <<<<<<<<+>>>>>>>>>>>>>>>>>>>>]<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<                                             ; continued
                                                               ; ASSERT ptr=0
  >>>>>>>>>>>>>>>>>>>>>>>>                                     ; walk in to this routine entry offset
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
  [->>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<]
                                                               ; ASSERT zero 0:16
                                                               ; ASSERT zero 21:24

                                                               ; walk back out to the routine base

                                                               ; ASSERT ptr=0
  >>>>>>>>>>>>>>>>>                                            ; out it goes  and into the slot it came from
  .>.>.>.
  <<<<<<<<<<<<<<<<<<<<
  >>>>>>>>>>>>>>>>>[->>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<
  <<]<<<<<<<<<<<<<<<<<                                         ; continued
  >>>>>>>>>>>>>>>>>>[->>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<
  <<<]<<<<<<<<<<<<<<<<<<                                       ; continued
  >>>>>>>>>>>>>>>>>>>[->>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<
  <<<<]<<<<<<<<<<<<<<<<<<<                                     ; continued
  >>>>>>>>>>>>>>>>>>>>[->>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<
  <<<<<]<<<<<<<<<<<<<<<<<<<<                                   ; continued
                                                               ; ASSERT ptr=0

  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
  >>>>>>                                                       ; continued
  ]
                                                               ; ASSERT ptr=818
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<                                                       ; continued
                                                               ; ASSERT ptr=0
                                                               ; ASSERT zero 0:24
                                                               ; ASSERT zero 41:44

; emit
                                                               ; every byte went out as it was computed  above
