; bfsodium ROWROT : rotate each row of a ChaCha20 state left by one word
;
; HAND WRITTEN; this is the move that makes the block function need no indexed
; access at all: with every row rotated left by one between quarter rounds  all
; four column quarter rounds land on the same four words  words 0 4 8 and 12;
; four rotations return each row to where it started;
;
; INTERFACE entry=63 exit=0 footprint=0:67
;
; IO  in:  state{64}   sixteen words of four little endian bytes  row major
;     out: state{64}   each row rotated left by one word
;
; TAPE MAP  (home @0)
;   @0x00:0x3f  state{16}  u32 LE  four rows of four words
;   @0x40:0x43  temp{4}    u8      one word  while its row rotates around it
;
; A row is four consecutive words; rotating it left by one means the first word
; steps aside  the other three slide down  and the one that stepped aside comes
; back as the last;

  ,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,                            ; read the state
                                                               ; continued
  >,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,
                                                               ; continued
  >,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,
                                                               ; continued
  >,>,>,>,>,>,>,>,>,>,>,>,>,>,>,
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; to the start of the state
  <<<                                                          ; continued
                                                               ; ASSERT ptr=0
; ==== row at @00 ====
                                                               ; ASSERT ptr=0
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; the first word steps aside into the temp
  >>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<]                                             ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<]                                             ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<]                                             ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; continued
  <<<<<<<<<<<<<<<]                                             ; continued
>                                                              ; the other three words each slide down one word
  [-<<<<+>>>>]
>                                                              ; the next byte
  [-<<<<+>>>>]
>                                                              ; the next byte
  [-<<<<+>>>>]
>                                                              ; the next byte
  [-<<<<+>>>>]
>                                                              ; the next byte
  [-<<<<+>>>>]
>                                                              ; the next byte
  [-<<<<+>>>>]
>                                                              ; the next byte
  [-<<<<+>>>>]
>                                                              ; the next byte
  [-<<<<+>>>>]
>                                                              ; the next byte
  [-<<<<+>>>>]
>                                                              ; the next byte
  [-<<<<+>>>>]
>                                                              ; the next byte
  [-<<<<+>>>>]
>                                                              ; the next byte
  [-<<<<+>>>>]
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>              ; the temp becomes the last word
                                                               ; ASSERT ptr=64
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]           ; continued
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]           ; continued
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]           ; continued
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]           ; continued
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; back to the start of the state
  <<<<<<<                                                      ; continued
                                                               ; ASSERT ptr=0
; ==== row at @10 ====
>>>>>>>>>>>>>>>>                                               ; to this row
                                                               ; ASSERT ptr=16
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<   ; the first word steps aside into the temp
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]                   ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]                   ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]                   ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]                   ; continued
>                                                              ; the other three words each slide down one word
  [-<<<<+>>>>]
>                                                              ; the next byte
  [-<<<<+>>>>]
>                                                              ; the next byte
  [-<<<<+>>>>]
>                                                              ; the next byte
  [-<<<<+>>>>]
>                                                              ; the next byte
  [-<<<<+>>>>]
>                                                              ; the next byte
  [-<<<<+>>>>]
>                                                              ; the next byte
  [-<<<<+>>>>]
>                                                              ; the next byte
  [-<<<<+>>>>]
>                                                              ; the next byte
  [-<<<<+>>>>]
>                                                              ; the next byte
  [-<<<<+>>>>]
>                                                              ; the next byte
  [-<<<<+>>>>]
>                                                              ; the next byte
  [-<<<<+>>>>]
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>                              ; the temp becomes the last word
                                                               ; ASSERT ptr=64
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>]                                           ; continued
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>]                                           ; continued
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>]                                           ; continued
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>]                                           ; continued
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; back to the start of the state
  <<<<<<<                                                      ; continued
                                                               ; ASSERT ptr=0
; ==== row at @20 ====
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>                               ; to this row
                                                               ; ASSERT ptr=32
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<   ; the first word steps aside into the temp
  <<<<<<<<<]                                                   ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<]                                                   ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<]                                                   ; continued
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<]                                                   ; continued
>                                                              ; the other three words each slide down one word
  [-<<<<+>>>>]
>                                                              ; the next byte
  [-<<<<+>>>>]
>                                                              ; the next byte
  [-<<<<+>>>>]
>                                                              ; the next byte
  [-<<<<+>>>>]
>                                                              ; the next byte
  [-<<<<+>>>>]
>                                                              ; the next byte
  [-<<<<+>>>>]
>                                                              ; the next byte
  [-<<<<+>>>>]
>                                                              ; the next byte
  [-<<<<+>>>>]
>                                                              ; the next byte
  [-<<<<+>>>>]
>                                                              ; the next byte
  [-<<<<+>>>>]
>                                                              ; the next byte
  [-<<<<+>>>>]
>                                                              ; the next byte
  [-<<<<+>>>>]
>>>>>>>>>>>>>>>>>                                              ; the temp becomes the last word
                                                               ; ASSERT ptr=64
  [-<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>]
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>]
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>]
>                                                              ; the next byte
  [-<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>]
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; back to the start of the state
  <<<<<<<                                                      ; continued
                                                               ; ASSERT ptr=0
; ==== row at @30 ====
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>               ; to this row
                                                               ; ASSERT ptr=48
  [->>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<]                         ; the first word steps aside into the temp
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<]
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<]
>                                                              ; the next byte
  [->>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<]
>                                                              ; the other three words each slide down one word
  [-<<<<+>>>>]
>                                                              ; the next byte
  [-<<<<+>>>>]
>                                                              ; the next byte
  [-<<<<+>>>>]
>                                                              ; the next byte
  [-<<<<+>>>>]
>                                                              ; the next byte
  [-<<<<+>>>>]
>                                                              ; the next byte
  [-<<<<+>>>>]
>                                                              ; the next byte
  [-<<<<+>>>>]
>                                                              ; the next byte
  [-<<<<+>>>>]
>                                                              ; the next byte
  [-<<<<+>>>>]
>                                                              ; the next byte
  [-<<<<+>>>>]
>                                                              ; the next byte
  [-<<<<+>>>>]
>                                                              ; the next byte
  [-<<<<+>>>>]
>                                                              ; the temp becomes the last word
                                                               ; ASSERT ptr=64
  [-<<<<+>>>>]
>                                                              ; the next byte
  [-<<<<+>>>>]
>                                                              ; the next byte
  [-<<<<+>>>>]
>                                                              ; the next byte
  [-<<<<+>>>>]
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   ; back to the start of the state
  <<<<<<<                                                      ; continued
                                                               ; ASSERT ptr=0

; emit the rotated state
  .>.>.>.>.>.>.>.>.>.>.>.>.>.>.>.>.
                                                               ; continued
  >.>.>.>.>.>.>.>.>.>.>.>.>.>.>.>.
                                                               ; continued
  >.>.>.>.>.>.>.>.>.>.>.>.>.>.>.>.
                                                               ; continued
  >.>.>.>.>.>.>.>.>.>.>.>.>.>.>.
