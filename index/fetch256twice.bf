; bfsodium FETCH256TWICE : read table{256} at a run time index
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
; IO  in:  idx{1}  table{256}  jdx{1}     (258 bytes)
;          the second index comes LAST  because a read prologue
;          may only ever move right
;     out: table at idx{1}  then table at jdx{1}   (2 bytes)
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
;   @0x303        jdx     the second index  parked clear of the table
;
; THIS FILE EXISTS TO PROVE ONE PROPERTY: that a table survives being read and
; can be read again; The datum is COPIED and not moved  and the trail is
; cleared on the way home  so the table comes out of a fetch exactly as it
; went in; That is what lets ONE table serve all two hundred of AES's reads
; rather than being rebuilt for each  and it is worth a file of its own
; because nothing else here would notice if it stopped being true;

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
  >>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,                  ; continued
                                                               ; ASSERT ptr=771
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
  <<<<<<<<<<<<<<                                               ; continued
                                                               ; ASSERT ptr=1
  [->>>+<<<]
>>>
                                                               ; ASSERT ptr=4
                                                               ; the walk out: spend one step  carry what is left to
                                                               ; the next group  drop a trail  and step on; a walk of
                                                               ; nought stops here
  [-[->>>+<<<]>+<>>>]
                                                               ; the datum is COPIED into the walker and put back from
                                                               ; the trail cell  which is nought in this group because
                                                               ; the walk stopped before setting it; that is what
                                                               ; leaves the table as it was
  <[->+>+<<]>>[-<<+>>]<
                                                               ; the walk back: hand the value down one group  then
                                                               ; follow the trail while it is set  clearing it; group
                                                               ; 0's is never set
  [-<<<+>>>]<<[-<[-<<<+>>>]<<]
  <                                                            ; and the value has come to rest in group 0's walker
                                                               ; ASSERT ptr=1
; emit the first answer  and then read the table AGAIN with the
  .                                                            ; second index  which is the whole point of this file
  [-]
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
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
  >>>>>>>>>>>>>>                                               ; continued
                                                               ; ASSERT ptr=771
  [-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
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
  <<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   ; continued
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
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]                         ; continued
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
  <<<<<<<<<<<<<<                                               ; continued
                                                               ; ASSERT ptr=1
  [->>>+<<<]                                                   ; and steps down to the walk's first group  as the
                                                               ; first one did
>>>
                                                               ; the walk out a second time  over a table that must be
                                                               ; untouched
                                                               ; ASSERT ptr=4
  [-[->>>+<<<]>+<>>>]
  <[->+>+<<]>>[-<<+>>]<
  [-<<<+>>>]<<[-<[-<<<+>>>]<<]
  <
                                                               ; ASSERT ptr=1

; emit  the second answer; the first went out above  because a
  .                                                            ; second walk needs its walker cell back
