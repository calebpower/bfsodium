; bfsodium FETCH8 : read array{8} at a run time index
;
; HAND WRITTEN; This is the idiom the rest of the library was avoiding;
; brainfuck cannot compute a cell address  so every earlier composite unrolled
; its loops instead  which is why they grew to tens of thousands of lines; With
; this  a loop over an array can be written as a loop;
;
; IO  in:  idx{1}  data{8}      (9 bytes)
;     out: data at idx{1}       (1 byte)
;
; TAPE MAP  (home @0)
;   the tape is groups of three cells: (d  a  b) for group g at @3g @3g plus 1 @3g plus 2
;     d   the datum
;     a   the walker: carries the remaining step count out  and the value back
;     b   the trail: marks a group the walker passed through
;   @0x00:0x02  group 0   the walker's home; its trail is never set  which is
;                         what stops the walk back
;   @0x03:0x05  group 1   where the walk starts
;   @0x06:0x1d  groups 2 to 9  the eight data bytes  element k in group k plus 2
;
; The walk out carries a counter rightwards three cells at a time  dropping a
; trail behind it  and stops when the counter runs out; the datum there is
; copied into the walker; the walk back follows the trail home  clearing it;
; group 0's trail is never set  so the value comes to rest in group 0 and the
; pointer stops there;

; read the index into the walker and add one  so a zero index still takes a step
  >>>>
  ,
  +

; read the eight data bytes into the datum cell of each group
  >>,
  >>>,
  >>>,
  >>>,
  >>>,
  >>>,
  >>>,
  >>>,

; back to the walker
  <<<<<<<<<<<<<<<<<<<<<<<

; walk out: spend one step  carry what is left to the next group  drop a trail
  [-[->>>+<<<]>+<>>>]

; copy the datum here into the walker  restoring the datum from the trail cell
  <[->+>+<<]>>[-<<+>>]<

; walk back: hand the value down one group  then follow the trail if it is set
  [-<<<+>>>]<<[-<[-<<<+>>>]<<]

; the value came to rest in group 0
  <.
