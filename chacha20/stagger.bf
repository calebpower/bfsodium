; bfsodium STAGGER : rotate row r of a ChaCha20 state left by r
;
; HAND WRITTEN; this is what turns the diagonal round into another column
; round: with the rows staggered by nought one two three  the four diagonal
; quarter rounds land on the same four words the column ones did  so the
; quarter round is pasted once and never reached through an index;
; applying a stagger four times is the identity  which is how it is undone;
;
; INTERFACE entry=0 exit=0 footprint=0:67
;
; IO  in:  state{64}   sixteen words of four little endian bytes  row major
;     out: state{64}   row r rotated left by r
;
; TAPE MAP  (home @0)
;   @0x00:0x3f  state{16}  u32 LE  four rows of four words
;   @0x40:0x43  temp{4}    u8      a word in transit
;
; Row 0 does not move; row 1 rotates left one  the same shape as rowrot;
; row 2 rotates left two  which is an exchange of the row's two halves;
; row 3 rotates left three  which is a rotate RIGHT by one  so its last word
; steps aside and the others slide up  walked from the top so nothing is
; overwritten before it has moved;
; read the state
  ,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,
; continued
  >,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,
; continued
  >,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,
; continued
  >,>,>,>,>,>,>,>,>,>,>,>,>,>,>,
; to the start of the state
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<
; ASSERT ptr=0

; ==== row 1 rotates left one ====
>>>>>>>>>>>>>>>>
; ASSERT ptr=16
; the first word steps aside
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<]
; the next byte
>
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<]
; the next byte
>
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<]
; the next byte
>
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<]
; the other three slide down
>
  [-<<<<+>>>>]
; the next byte
>
  [-<<<<+>>>>]
; the next byte
>
  [-<<<<+>>>>]
; the next byte
>
  [-<<<<+>>>>]
; the next byte
>
  [-<<<<+>>>>]
; the next byte
>
  [-<<<<+>>>>]
; the next byte
>
  [-<<<<+>>>>]
; the next byte
>
  [-<<<<+>>>>]
; the next byte
>
  [-<<<<+>>>>]
; the next byte
>
  [-<<<<+>>>>]
; the next byte
>
  [-<<<<+>>>>]
; the next byte
>
  [-<<<<+>>>>]
; the temp becomes the last word
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ASSERT ptr=64
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]
; the next byte
>
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]
; the next byte
>
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]
; the next byte
>
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<
; ASSERT ptr=0

; ==== row 2 rotates left two  its halves change places ====
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ASSERT ptr=32
; byte 0 of the half exchange
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>
  [-<<<<<<<<+>>>>>>>>]
>>>>>>>>>>>>>>>>>>>>>>>>
  [-<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>]
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
>
; byte 1 of the half exchange
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>
  [-<<<<<<<<+>>>>>>>>]
>>>>>>>>>>>>>>>>>>>>>>>>
  [-<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>]
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
>
; byte 2 of the half exchange
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>
  [-<<<<<<<<+>>>>>>>>]
>>>>>>>>>>>>>>>>>>>>>>>>
  [-<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>]
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
>
; byte 3 of the half exchange
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>
  [-<<<<<<<<+>>>>>>>>]
>>>>>>>>>>>>>>>>>>>>>>>>
  [-<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>]
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
>
; byte 4 of the half exchange
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>
  [-<<<<<<<<+>>>>>>>>]
>>>>>>>>>>>>>>>>>>>>>>>>
  [-<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>]
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
>
; byte 5 of the half exchange
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>
  [-<<<<<<<<+>>>>>>>>]
>>>>>>>>>>>>>>>>>>>>>>>>
  [-<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>]
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
>
; byte 6 of the half exchange
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>
  [-<<<<<<<<+>>>>>>>>]
>>>>>>>>>>>>>>>>>>>>>>>>
  [-<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>]
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
>
; byte 7 of the half exchange
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]
>>>>>>>>
  [-<<<<<<<<+>>>>>>>>]
>>>>>>>>>>>>>>>>>>>>>>>>
  [-<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>]
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; ASSERT ptr=0

; ==== row 3 rotates left three  which is a rotate right by one ====
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>
; ASSERT ptr=60
; the LAST word steps aside
  [->>>>+<<<<]
; the next byte
>
  [->>>>+<<<<]
; the next byte
>
  [->>>>+<<<<]
; the next byte
>
  [->>>>+<<<<]
; the other three slide up  walked from the top so nothing is overwritten
<<<<
  [->>>>+<<<<]
; the byte below
<
  [->>>>+<<<<]
; the byte below
<
  [->>>>+<<<<]
; the byte below
<
  [->>>>+<<<<]
; the byte below
<
  [->>>>+<<<<]
; the byte below
<
  [->>>>+<<<<]
; the byte below
<
  [->>>>+<<<<]
; the byte below
<
  [->>>>+<<<<]
; the byte below
<
  [->>>>+<<<<]
; the byte below
<
  [->>>>+<<<<]
; the byte below
<
  [->>>>+<<<<]
; the byte below
<
  [->>>>+<<<<]
; ASSERT ptr=48
; the temp becomes the first word
>>>>>>>>>>>>>>>>
; ASSERT ptr=64
  [-<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>]
; the next byte
>
  [-<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>]
; the next byte
>
  [-<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>]
; the next byte
>
  [-<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>]
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<
; ASSERT ptr=0

; emit the staggered state
  .>.>.>.>.>.>.>.>.>.>.>.>.>.>.>.>.
; continued
  >.>.>.>.>.>.>.>.>.>.>.>.>.>.>.>.
; continued
  >.>.>.>.>.>.>.>.>.>.>.>.>.>.>.>.
; continued
  >.>.>.>.>.>.>.>.>.>.>.>.>.>.>.
