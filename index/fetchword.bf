; bfsodium FETCHWORD : read one 32 bit word from a 16 word state at a run time
; index
;
; HAND WRITTEN; this is what the looped quarter round stands on; a ChaCha state
; is sixteen words and the quarter round touches four of them chosen from a
; table  so the words have to be reachable by an index that is not known when
; the program is written;
;
; IO  in:  idx{1}  state{64}     (65 bytes; the state is 16 words of 4 LE bytes)
;     out: state word at idx{4}  (4 bytes)
;
; TAPE MAP  (home @0)
;   the tape is groups of TEN cells for group g at @10g:
;     d0 d1 d2 d3 = @10g:@10g plus 3   the four bytes of the word
;     a           = @10g plus 4        the walker: the remaining step count
;     b           = @10g plus 5        the trail  and a scratch cell at the target
;     v0 v1 v2 v3 = @10g plus 6:plus 9 the carriers  which bring the word home
;   @0x00:0x09  group 0    where the word comes to rest; its trail is never set
;   @0x0a:0x13  group 1    where the walk starts
;   @0x14:0xb3  groups 2 to 17   the sixteen state words  word k in group k plus 2
;
; Four carriers ride along beside the walker  because a word is four bytes and
; they must all come back together; the trail cell doubles as the scratch that
; lets each byte be copied without being consumed;

; read the index into the walker and add one  so a zero index still takes a step
  >>>>>>>>>>>>>>
  ,
  +

; read the sixteen words into the datum cells of groups 2 to 17
  >>>>>>
  ,>,>,>,
  >>>>>>>
; next word
  ,>,>,>,
  >>>>>>>
; next word
  ,>,>,>,
  >>>>>>>
; next word
  ,>,>,>,
  >>>>>>>
; next word
  ,>,>,>,
  >>>>>>>
; next word
  ,>,>,>,
  >>>>>>>
; next word
  ,>,>,>,
  >>>>>>>
; next word
  ,>,>,>,
  >>>>>>>
; next word
  ,>,>,>,
  >>>>>>>
; next word
  ,>,>,>,
  >>>>>>>
; next word
  ,>,>,>,
  >>>>>>>
; next word
  ,>,>,>,
  >>>>>>>
; next word
  ,>,>,>,
  >>>>>>>
; next word
  ,>,>,>,
  >>>>>>>
; next word
  ,>,>,>,
  >>>>>>>
; next word
  ,>,>,>,

; back to the walker  which is 159 cells below the last byte read
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

; walk out: spend a step  carry what is left ten cells on  drop a trail
  [-[->>>>>>>>>>+<<<<<<<<<<]>+<>>>>>>>>>>]

; load the four bytes into the carriers  each copied through the trail cell
; and put straight back  so the state is not disturbed
; byte 0
  <<<<
  [->>>>>>+<+<<<<<]
  >>>>>[-<<<<<+>>>>>]<<<<<
; byte 1
  >
  [->>>>>>+<<+<<<<]
  >>>>[-<<<<+>>>>]<<<<
; byte 2
  >
  [->>>>>>+<<<+<<<]
  >>>[-<<<+>>>]<<<
; byte 3
  >
  [->>>>>>+<<<<+<<]
  >>[-<<+>>]<<
; back to the walker
  >

; walk back: hand all four carriers down one group  then follow the trail
  >>[-<<<<<<<<<<+>>>>>>>>>>]
  >[-<<<<<<<<<<+>>>>>>>>>>]
  >[-<<<<<<<<<<+>>>>>>>>>>]
  >[-<<<<<<<<<<+>>>>>>>>>>]
; step down to the trail of the group below
  <<<<<<<<<<<<<<
  [
; hand the carriers down another group
  ->
  [-<<<<<<<<<<+>>>>>>>>>>]
  >[-<<<<<<<<<<+>>>>>>>>>>]
  >[-<<<<<<<<<<+>>>>>>>>>>]
  >[-<<<<<<<<<<+>>>>>>>>>>]
; step down to the trail of the group below
  <<<<<<<<<<<<<<
  ]

; the word came to rest in group 0
  >.>.>.>.
