; bfsodium INVSHIFTROWS : row r of the state cyclically shifted RIGHT by r
;
; NOTE square brackets are brainfuck loops  so comments use braces for counts;
;
; HAND WRITTEN; nothing is pasted; this step has no arithmetic in it at all;
;
; INTERFACE entry=15 exit=0 footprint=0:31
; IO  in:  state{16}   column major  as FIPS 197 numbers it   (16 bytes)
;     out: state{16}   the same sixteen cells  rows shifted back
;
; FIPS 197 section 5 point 3 point 1; The state is COLUMN MAJOR  so byte
; r plus 4c is row r of column c  and the whole step is the fixed permutation
;
;   s' at r plus 4c  is  s at r plus 4 times ((c minus r) mod 4)
;
; which is aes/shiftrows with the sign of r turned round  and nothing else;
; Row nought does not move  and the permutation says so by itself rather than
; by a special case;
;
; IT IS ITS OWN STEP AND NOT A LOOP OVER shiftrows; the two differ only in
; that one subtraction  so writing one in terms of the other would cost a
; level of indirection to save sixteen lines;
;
; AND IT IS PASTEABLE  like the arithmetic and unlike InvSubBytes: there is no
; index anywhere  so every loop is pointer balanced;
;
; TAPE MAP  (home @0)
;   @0x00:0x0f  state{16}  column major; the answers come back over it
;   @0x10:0x1f  tmp{16}    the state in its new order  then spent back down
;
; TWO PASSES AND NOT ONE  because the permutation is a cycle and a single pass
; would overwrite a byte still wanted; The first pass moves each source to its
; destination IN THE TEMPORARY  which is a bijection so every source is read
; exactly once  and the second moves the temporary home over the empty state;

  ,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,                              ; the state  column major
                                                               ; ASSERT ptr=15
                                                               ; ASSERT zero 16:31
<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=0

; ============================================================ ; pass one : each byte to its new place  in the
                                                               ; temporary
  [->>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<]                         ; row 0 column 0 takes the byte from column 0
>>>>>>>>>>>>>                                                  ; row 1 column 0 takes the byte from column 3
  [->>>>+<<<<]
<<<<<<<<<<<<<
>>>>>>>>>>                                                     ; row 2 column 0 takes the byte from column 2
  [->>>>>>>>+<<<<<<<<]
<<<<<<<<<<
>>>>>>>                                                        ; row 3 column 0 takes the byte from column 1
  [->>>>>>>>>>>>+<<<<<<<<<<<<]
<<<<<<<
>>>>                                                           ; row 0 column 1 takes the byte from column 1
  [->>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<]
<<<<
>                                                              ; row 1 column 1 takes the byte from column 0
  [->>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<]
<
>>>>>>>>>>>>>>                                                 ; row 2 column 1 takes the byte from column 3
  [->>>>>>>>+<<<<<<<<]
<<<<<<<<<<<<<<
>>>>>>>>>>>                                                    ; row 3 column 1 takes the byte from column 2
  [->>>>>>>>>>>>+<<<<<<<<<<<<]
<<<<<<<<<<<
>>>>>>>>                                                       ; row 0 column 2 takes the byte from column 2
  [->>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<]
<<<<<<<<
>>>>>                                                          ; row 1 column 2 takes the byte from column 1
  [->>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<]
<<<<<
>>                                                             ; row 2 column 2 takes the byte from column 0
  [->>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<]
<<
>>>>>>>>>>>>>>>                                                ; row 3 column 2 takes the byte from column 3
  [->>>>>>>>>>>>+<<<<<<<<<<<<]
<<<<<<<<<<<<<<<
>>>>>>>>>>>>                                                   ; row 0 column 3 takes the byte from column 3
  [->>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<]
<<<<<<<<<<<<
>>>>>>>>>                                                      ; row 1 column 3 takes the byte from column 2
  [->>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<]
<<<<<<<<<
>>>>>>                                                         ; row 2 column 3 takes the byte from column 1
  [->>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<]
<<<<<<
>>>                                                            ; row 3 column 3 takes the byte from column 0
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <]                                                           ; continued
<<<
                                                               ; ASSERT ptr=0
                                                               ; ASSERT zero 0:15

; ============================================================ ; pass two : the temporary comes home over the empty
                                                               ; state
>>>>>>>>>>>>>>>>                                               ; column 0
  [-<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>]
<<<<<<<<<<<<<<<<
>>>>>>>>>>>>>>>>>
  [-<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>]
<<<<<<<<<<<<<<<<<
>>>>>>>>>>>>>>>>>>
  [-<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>]
<<<<<<<<<<<<<<<<<<
>>>>>>>>>>>>>>>>>>>
  [-<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>]
<<<<<<<<<<<<<<<<<<<
>>>>>>>>>>>>>>>>>>>>                                           ; column 1
  [-<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>]
<<<<<<<<<<<<<<<<<<<<
>>>>>>>>>>>>>>>>>>>>>
  [-<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>]
<<<<<<<<<<<<<<<<<<<<<
>>>>>>>>>>>>>>>>>>>>>>
  [-<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>]
<<<<<<<<<<<<<<<<<<<<<<
>>>>>>>>>>>>>>>>>>>>>>>
  [-<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>]
<<<<<<<<<<<<<<<<<<<<<<<
>>>>>>>>>>>>>>>>>>>>>>>>                                       ; column 2
  [-<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>]
<<<<<<<<<<<<<<<<<<<<<<<<
>>>>>>>>>>>>>>>>>>>>>>>>>
  [-<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>]
<<<<<<<<<<<<<<<<<<<<<<<<<
>>>>>>>>>>>>>>>>>>>>>>>>>>
  [-<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>]
<<<<<<<<<<<<<<<<<<<<<<<<<<
>>>>>>>>>>>>>>>>>>>>>>>>>>>
  [-<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>]
<<<<<<<<<<<<<<<<<<<<<<<<<<<
>>>>>>>>>>>>>>>>>>>>>>>>>>>>                                   ; column 3
  [-<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>]
<<<<<<<<<<<<<<<<<<<<<<<<<<<<
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  [-<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>]
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  [-<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>]
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  [-<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>]
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
                                                               ; ASSERT ptr=0
                                                               ; ASSERT zero 16:31

; emit
  .>.>.>.>.>.>.>.>.>.>.>.>.>.>.>.                              ; the sixteen bytes of the state  in the order they
                                                               ; were read
