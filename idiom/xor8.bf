; bfsodium XOR8 : bitwise exclusive or of two bytes
;
; NOTE square brackets are brainfuck loops  so comments use braces for counts;
;
; HAND WRITTEN; This is the kernel that already lives inside idiom/xor32 and
; idiom/xor64  lifted into a routine of its own because AES wants the exclusive
; or of two SINGLE bytes everywhere: AddRoundKey is sixteen of them  a round of
; MixColumns is dozens  and the key expansion is more;
;
; INTERFACE entry=2 exit=0 footprint=0:16
; IO  in:  x{1}  y{1}      (2 bytes)
;     out: (x xor y){1}    (1 byte)
;
; TAPE MAP  (home @0)
;   @0x00  r    u8  the result  and the cell the answer comes to rest in
;   @0x01  x    u8  first operand   staged into a
;   @0x02  y    u8  second operand  staged into b
;   @0x03  a    u8  left byte   halved away to nought
;   @0x04  qa   u8  a shifted right one
;   @0x05  pa   u8  low bit of a
;   @0x06  fa   u8  scratch  restored to nought
;   @0x07  b    u8  right byte  halved away to nought
;   @0x08  qb   u8  b shifted right one
;   @0x09  pb   u8  low bit of b
;   @0x0a  fb   u8  scratch  restored to nought
;   @0x0b  t    u8  the exclusive or of the two low bits
;   @0x0c  ft   u8  scratch  restored to nought
;   @0x0d  res  u8  the result byte  accumulating
;   @0x0e  p    u8  the weight of the bit in hand  one two four ; one twenty
;                   eight
;   @0x0f  cnt  u8  bits remaining  starts at eight
;   @0x10  tmp  u8  scratch  restored to nought
;
; THE FRAME IS THE ONE xor32 AND xor64 USE  in the same order down to the
; character: a qa pa fa b qb pb fb t ft res p cnt tmp; Only the three journeys
; that reach outside it differ  namely fetching x  fetching y and storing the
; result  and here all three are short because the operands are adjacent;
;
; AND IT IS NOT PASTED INTO THOSE TWO  which is deferred rather than settled;
; They fetch x_i from cell i and y_i from cell i plus eight  and a paste takes
; its operands ADJACENT at its own base  so unifying them means staging two
; bytes per byte of the word and moving the answer back; That is a change to
; two proven files and it belongs in a unit of its own  not on the way past;
;
; brainfuck has no bitwise instruction  so both bytes are decomposed; A lookup
; table was the original plan for the whole family and is the wrong shape  for
; the reason CONVENTIONS records: the table sits tens of thousands of cells
; from the frame and every read pays that distance in pointer travel;
;
; HALVE is the workhorse: for a cell at k with q at k plus 1  t at k plus 2 and
; f at k plus 3  it leaves q equal to the value shifted right one and t equal
; to the low bit  by counting down and toggling t on each step; This runs it
; eight times on each byte  toggles t once per set low bit  so t ends as the
; exclusive or of that bit pair  then adds the weight in hand into res when t
; is set  and doubles the weight for the next bit;
;
; THE COST DOES NOT DEPEND ON THE OPERANDS beyond their size: eight bit steps
; whatever they hold  each halving costing about the value being halved;

  >,>,                                                         ; read the two operands  leaving the result cell clear
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
; ============================================================ ; eight bit steps
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

; emit
  .                                                            ; the exclusive or  which is the whole of the answer
