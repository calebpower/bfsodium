; bfsodium SHIFTROWS : row r of the state cyclically shifted left by r
;
; NOTE square brackets are brainfuck loops  so comments use braces for counts;
;
; HAND WRITTEN; nothing is pasted; this step has no arithmetic in it at all;
;
; INTERFACE entry=15 exit=0 footprint=0:31
; IO  in:  state{16}   column major  as FIPS 197 numbers it   (16 bytes)
;     out: state{16}   the same sixteen cells  rows shifted
;
; FIPS 197 section 5 point 1 point 2; The state is COLUMN MAJOR  so byte
; r plus 4c is row r of column c  and the whole step is the fixed permutation
;
;   s' at r plus 4c  is  s at r plus 4 times ((c plus r) mod 4)
;
; which is THIRTY TWO MOVES AND NO ARITHMETIC; Row nought does not move  and
; the permutation says so by itself rather than by a special case;
;
; THIS IS THE STEP THAT PAYS FOR THE COLUMN MAJOR ORDER that makes MixColumns
; short: a row is four bytes FOUR APART  so every one of these moves travels
; where a column move would not have to; It is still the cheapest step in the
; cipher  because moving a byte over d cells costs about 2d per unit of it and
; nothing here travels more than fifteen cells;
;
; AND IT IS PASTEABLE  like the arithmetic and unlike SubBytes: there is no
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
>>>>>                                                          ; row 1 column 0 takes the byte from column 1
  [->>>>>>>>>>>>+<<<<<<<<<<<<]
<<<<<
>>>>>>>>>>                                                     ; row 2 column 0 takes the byte from column 2
  [->>>>>>>>+<<<<<<<<]
<<<<<<<<<<
>>>>>>>>>>>>>>>                                                ; row 3 column 0 takes the byte from column 3
  [->>>>+<<<<]
<<<<<<<<<<<<<<<
>>>>                                                           ; row 0 column 1 takes the byte from column 1
  [->>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<]
<<<<
>>>>>>>>>                                                      ; row 1 column 1 takes the byte from column 2
  [->>>>>>>>>>>>+<<<<<<<<<<<<]
<<<<<<<<<
>>>>>>>>>>>>>>                                                 ; row 2 column 1 takes the byte from column 3
  [->>>>>>>>+<<<<<<<<]
<<<<<<<<<<<<<<
>>>                                                            ; row 3 column 1 takes the byte from column 0
  [->>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<]
<<<
>>>>>>>>                                                       ; row 0 column 2 takes the byte from column 2
  [->>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<]
<<<<<<<<
>>>>>>>>>>>>>                                                  ; row 1 column 2 takes the byte from column 3
  [->>>>>>>>>>>>+<<<<<<<<<<<<]
<<<<<<<<<<<<<
>>                                                             ; row 2 column 2 takes the byte from column 0
  [->>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<]
<<
>>>>>>>                                                        ; row 3 column 2 takes the byte from column 1
  [->>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<]
<<<<<<<
>>>>>>>>>>>>                                                   ; row 0 column 3 takes the byte from column 3
  [->>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<]
<<<<<<<<<<<<
>                                                              ; row 1 column 3 takes the byte from column 0
  [->>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <]                                                           ; continued
<
>>>>>>                                                         ; row 2 column 3 takes the byte from column 1
  [->>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<]
<<<<<<
>>>>>>>>>>>                                                    ; row 3 column 3 takes the byte from column 2
  [->>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<]
<<<<<<<<<<<
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
