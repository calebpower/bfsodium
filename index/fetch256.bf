; bfsodium FETCH256 : read table{256} at a run time index
;
; NOTE square brackets are brainfuck loops  so comments use braces for counts;
;
; HAND WRITTEN; the 256 entry lookup AES's S box is  and the one index/fetch8
; CANNOT DO: fetch8 walks a counter of idx plus one in a single cell  and 255
; plus one is nought  so the last element of a full byte indexed table is
; unreachable; This counts with the INDEX ITSELF  which costs one group:
; element k lives in group k plus one rather than k plus two  and a walk of
; nought stops where it starts;
;
; IO  in:  idx{1}  table{256}      (257 bytes)
;     out: table at idx{1}          (1 byte)
;
; THIS IS A PROGRAM AND NOT A PASTEABLE ROUTINE  and that is forced rather
; than chosen; tools/bffoot requires every loop body to be POINTER BALANCED so
; that a footprint can be bounded  and a walk advances three cells per turn by
; construction; index/fetch8 has no INTERFACE line for the same reason; So
; anything that wants this lookup inside it must carry the walk itself  and
; that is a real constraint on where AES can be pasted from;
;
; THE COST IS O(INDEX) AND THAT IS THE POINT OF MEASURING IT; a 256 entry
; fetch is 248084 instructions averaged over a uniform index with the real S
; box as its data  which is 2368 at the cheapest index and 787159 at the
; dearest; AES_128 wants two hundred of them per block  which is fifty
; million against SHA_256's one thousand one hundred and forty five million
; for one block; The AES section of CONVENTIONS carries the full measurement;
;
; AND THE COST IS DRIVEN AS MUCH BY THE DATUM AS BY THE INDEX  because the
; walk home carries the value back one group at a time; index 254 costs
; 726763 and index 255 only 348112  not because 255 is nearer but because
; the S box holds 0xbb at 254 and 0x16 at 255;
;
; TAPE MAP  (home @0)
;   the tape is groups of three cells  (d a b) for group g at @3g and the two
;   after it:
;     d   the datum
;     a   the walker: carries the remaining step count out  and the value back
;     b   the trail: marks a group the walker passed through
;   @0x000:0x002  group 0   the walker's home; ITS TRAIL IS NEVER SET  which
;                           is what stops the walk back; the index arrives in
;                           its walker cell and the answer comes to rest there
;   @0x003:0x302  groups 1 to 256  the table; element k in group k plus one

  >,>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>   ; read the index  then the table  element k into group
  >>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>   ; k plus one
  ,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>   ; continued
  >>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>   ; continued
  ,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>   ; continued
  >>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>   ; continued
  ,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>   ; continued
  >>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>   ; continued
  ,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>   ; continued
  >>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>   ; continued
  ,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>   ; continued
  >>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>   ; continued
  ,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>   ; continued
  >>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>   ; continued
  ,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>   ; continued
  >>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>   ; continued
  ,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>   ; continued
  >>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,                      ; continued
                                                               ; ASSERT ptr=768
                                                               ; the index steps down to the walk's first group  which
                                                               ; is three cells and free
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
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
  <<<<<<<<<<<                                                  ; continued
                                                               ; ASSERT ptr=1
  [->>>+<<<]
>>>
                                                               ; ASSERT ptr=4
                                                               ; THE INDEXED WALK  entered at group 1's walker with
                                                               ; the index in it; the tape is groups of three  (d a b)
                                                               ; and the answer comes to rest in group 0's walker; the
                                                               ; caller owns the two lines that put the index there
                                                               ; and its own contract  because a pointer assertion
                                                               ; belongs to the file being assembled;
;
                                                               ; THIS IS WHY AES CANNOT BE PASTED; the walk advances
                                                               ; three cells a turn  so no loop here is pointer
                                                               ; balanced  so tools/bffoot will not bound it and
                                                               ; tools/bfexpand will not paste a file holding it; an
                                                               ; INCLUDE does not care and that is the whole reason
                                                               ; this is a block; the walk out: spend one step  carry
                                                               ; what is left to the next group  drop a trail  and
                                                               ; step on; a walk of nought stops where it starts
  [-[->>>+<<<]>+<>>>]
                                                               ; the datum is COPIED into the walker and put back from
                                                               ; the trail cell  which is nought in this group because
                                                               ; the walk stopped before setting it; that is what
                                                               ; leaves the table fit to be read again
  <[->+>+<<]>>[-<<+>>]<
                                                               ; the walk back: hand the value down one group  then
                                                               ; follow the trail while it is set  clearing it; group
                                                               ; 0's trail is never set and that is what stops the
                                                               ; walk
  [-<<<+>>>]<<[-<[-<<<+>>>]<<]
  <                                                            ; and the value has come to rest in group 0's walker
                                                               ; ASSERT ptr=1

; emit  the datum  which is the whole of the answer
  .
