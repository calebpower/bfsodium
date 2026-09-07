; bfsodium STORE8 : write into array{8} at a run time index
;
; HAND WRITTEN; the write counterpart of fetch8; together they are what a loop
; over an array needs  and what the library was unrolling to avoid;
;
; IO  in:  idx{1}  val{1}  data{8}      (10 bytes)
;     out: data{8} after the write       (8 bytes)
;
; TAPE MAP  (home @0)
;   the tape is groups of four cells for group g at @4g:
;     d = @4g     the datum
;     a = @4g plus 1   the walker: the remaining step count
;     b = @4g plus 2   the trail: marks a group the walker passed through
;     v = @4g plus 3   the value being carried out to its slot
;   @0x00:0x03  group 0   the walk never leaves it  so its trail stays clear
;                         and that is what stops the walk back
;   @0x04:0x07  group 1   where the walk starts
;   @0x08:0x27  groups 2 to 9  the eight data bytes  element k in group k plus 2
;
; The walk out carries the step count AND the value  dropping a trail; at the
; target the datum is cleared and the carried value takes its place; the walk
; back has nothing to bring  so it only follows the trail home  clearing it;

; read the index into the walker and add one  so a zero index still takes a step
  >>>>>
  ,
  +

; read the value into the carrier
  >>,

; read the eight data bytes into the datum cell of each group
  >,
  >>>>,
  >>>>,
  >>>>,
  >>>>,
  >>>>,
  >>>>,
  >>>>,

; back to the walker
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

; walk out: spend a step  carry the count and the value on  drop a trail
  [-[->>>>+<<<<]>>[->>>>+<<<<]<+>>>]

; at the target: clear the datum and let the carried value take its place
  <[-]>>>[-<<<+>>>]<<

; walk back: nothing to carry  just follow the trail home clearing it
  <<<[-<<<<]

; emit the array
  >>>>>>.
  >>>>.
  >>>>.
  >>>>.
  >>>>.
  >>>>.
  >>>>.
  >>>>.
