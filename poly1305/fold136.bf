; bfsodium FOLD136 : one Poly1305 reduction step  using 2^130 = 5 modulo p
;
; ASSEMBLED FILE: emitted by tools/polyasm using the shared emitter;
;
; IO  in:  x{17} LE                     (17 bytes)
;     out: (L plus 5H){17} LE           (17 bytes)  where x = L plus H times 2^130
;
; TAPE MAP  (home @0)
;   @0x00:0x10  x{17}     u8   the value  and the result
;   @0x11:0x38  scratch{40}    the fold workspace; see fold_op in tools/bfemit
;
; The split is at bit 130  and 130 is 128 plus 2  so the part above the split
; is simply the top byte shifted right two and no multi byte shift is needed;
  ,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,
; travel 16 cells left
  <<<<<<<<<<<<<<<<
; FOLD : reduce using 2^130 = 5 modulo p
; the split is at bit 130  which is the top byte shifted right two
; travel 16 cells right
  >>>>>>>>>>>>>>>>
; move byte 0 of @010 to @028
  [-
; travel 24 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 24 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 24 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>
; first halving  the low bit here is bit 128
  [->>>+<[-<+>>-<]>[-<+>]<<<]
; travel 2 cells right
  >>
; move byte 0 of @02a to @02d
  [-
; travel 3 cells right
  >>>
  +
; travel 3 cells left
  <<<
  ]
; travel 1 cells left
  <
; move byte 0 of @029 to @028
  [-
; travel 1 cells left
  <
  +
; travel 1 cells right
  >
  ]
; travel 1 cells left
  <
; second halving  the low bit here is bit 129
  [->>>+<[-<+>>-<]>[-<+>]<<<]
; travel 2 cells right
  >>
; move byte 0 of @02a to @02e
  [-
; travel 4 cells right
  >>>>
  +
; travel 4 cells left
  <<<<
  ]
; travel 1 cells left
  <
; move byte 0 of @029 to @02f
  [-
; travel 6 cells right
  >>>>>>
  +
; travel 6 cells left
  <<<<<<
  ]
; travel 41 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <
; the top byte keeps only bits 128 and 129
; travel 45 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>
; move byte 0 of @02d to @010
  [-
; travel 29 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 29 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 1 cells right
  >
; bit 129 is worth two in the top byte
  [-
; travel 30 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ++
; travel 30 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 46 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<
; build 5H by adding H to a two byte buffer five times
; travel 47 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>
; copy byte 0 of @02f to @030 and to a temp
  [-
; travel 1 cells right
  >
  +
; travel 8 cells right
  >>>>>>>>
  +
; travel 9 cells left
  <<<<<<<<<
  ]
; walk to the temps
; travel 9 cells right
  >>>>>>>>>
; put temp byte 0 back into @02f
  [-
; travel 9 cells left
  <<<<<<<<<
  +
; travel 9 cells right
  >>>>>>>>>
  ]
; travel 56 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<
; ADD16 : @011 gets @030  little endian
; byte 0
; travel 17 cells right
  >>>>>>>>>>>>>>>>>
; move byte 0 of @011 to @033
  [-
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 34 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 31 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @030 to @034
  [-
; travel 4 cells right
  >>>>
  +
; travel 4 cells left
  <<<<
  ]
; travel 4 cells right
  >>>>
; add the addend byte into the accumulator byte
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; travel 2 cells left
  <<
; move byte 0 of @032 to @034
  [-
; travel 2 cells right
  >>
  +
; travel 2 cells left
  <<
  ]
; travel 2 cells right
  >>
; add the carry coming in from the byte below
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; travel 1 cells left
  <
; move byte 0 of @033 to @011
  [-
; travel 34 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @035 to @032
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 53 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<
; byte 1
; travel 18 cells right
  >>>>>>>>>>>>>>>>>>
; move byte 0 of @012 to @033
  [-
; travel 33 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 33 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 31 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @031 to @034
  [-
; travel 3 cells right
  >>>
  +
; travel 3 cells left
  <<<
  ]
; travel 3 cells right
  >>>
; add the addend byte into the accumulator byte
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; travel 2 cells left
  <<
; move byte 0 of @032 to @034
  [-
; travel 2 cells right
  >>
  +
; travel 2 cells left
  <<
  ]
; travel 2 cells right
  >>
; add the carry coming in from the byte below
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; travel 1 cells left
  <
; move byte 0 of @033 to @012
  [-
; travel 33 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 33 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @035 to @032
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 53 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<
; drop the carry out of the top byte
; travel 50 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>
  [-]
; travel 50 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<
; travel 47 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>
; copy byte 0 of @02f to @030 and to a temp
  [-
; travel 1 cells right
  >
  +
; travel 8 cells right
  >>>>>>>>
  +
; travel 9 cells left
  <<<<<<<<<
  ]
; walk to the temps
; travel 9 cells right
  >>>>>>>>>
; put temp byte 0 back into @02f
  [-
; travel 9 cells left
  <<<<<<<<<
  +
; travel 9 cells right
  >>>>>>>>>
  ]
; travel 56 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<
; ADD16 : @011 gets @030  little endian
; byte 0
; travel 17 cells right
  >>>>>>>>>>>>>>>>>
; move byte 0 of @011 to @033
  [-
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 34 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 31 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @030 to @034
  [-
; travel 4 cells right
  >>>>
  +
; travel 4 cells left
  <<<<
  ]
; travel 4 cells right
  >>>>
; add the addend byte into the accumulator byte
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; travel 2 cells left
  <<
; move byte 0 of @032 to @034
  [-
; travel 2 cells right
  >>
  +
; travel 2 cells left
  <<
  ]
; travel 2 cells right
  >>
; add the carry coming in from the byte below
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; travel 1 cells left
  <
; move byte 0 of @033 to @011
  [-
; travel 34 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @035 to @032
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 53 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<
; byte 1
; travel 18 cells right
  >>>>>>>>>>>>>>>>>>
; move byte 0 of @012 to @033
  [-
; travel 33 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 33 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 31 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @031 to @034
  [-
; travel 3 cells right
  >>>
  +
; travel 3 cells left
  <<<
  ]
; travel 3 cells right
  >>>
; add the addend byte into the accumulator byte
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; travel 2 cells left
  <<
; move byte 0 of @032 to @034
  [-
; travel 2 cells right
  >>
  +
; travel 2 cells left
  <<
  ]
; travel 2 cells right
  >>
; add the carry coming in from the byte below
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; travel 1 cells left
  <
; move byte 0 of @033 to @012
  [-
; travel 33 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 33 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @035 to @032
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 53 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<
; drop the carry out of the top byte
; travel 50 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>
  [-]
; travel 50 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<
; travel 47 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>
; copy byte 0 of @02f to @030 and to a temp
  [-
; travel 1 cells right
  >
  +
; travel 8 cells right
  >>>>>>>>
  +
; travel 9 cells left
  <<<<<<<<<
  ]
; walk to the temps
; travel 9 cells right
  >>>>>>>>>
; put temp byte 0 back into @02f
  [-
; travel 9 cells left
  <<<<<<<<<
  +
; travel 9 cells right
  >>>>>>>>>
  ]
; travel 56 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<
; ADD16 : @011 gets @030  little endian
; byte 0
; travel 17 cells right
  >>>>>>>>>>>>>>>>>
; move byte 0 of @011 to @033
  [-
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 34 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 31 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @030 to @034
  [-
; travel 4 cells right
  >>>>
  +
; travel 4 cells left
  <<<<
  ]
; travel 4 cells right
  >>>>
; add the addend byte into the accumulator byte
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; travel 2 cells left
  <<
; move byte 0 of @032 to @034
  [-
; travel 2 cells right
  >>
  +
; travel 2 cells left
  <<
  ]
; travel 2 cells right
  >>
; add the carry coming in from the byte below
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; travel 1 cells left
  <
; move byte 0 of @033 to @011
  [-
; travel 34 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @035 to @032
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 53 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<
; byte 1
; travel 18 cells right
  >>>>>>>>>>>>>>>>>>
; move byte 0 of @012 to @033
  [-
; travel 33 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 33 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 31 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @031 to @034
  [-
; travel 3 cells right
  >>>
  +
; travel 3 cells left
  <<<
  ]
; travel 3 cells right
  >>>
; add the addend byte into the accumulator byte
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; travel 2 cells left
  <<
; move byte 0 of @032 to @034
  [-
; travel 2 cells right
  >>
  +
; travel 2 cells left
  <<
  ]
; travel 2 cells right
  >>
; add the carry coming in from the byte below
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; travel 1 cells left
  <
; move byte 0 of @033 to @012
  [-
; travel 33 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 33 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @035 to @032
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 53 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<
; drop the carry out of the top byte
; travel 50 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>
  [-]
; travel 50 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<
; travel 47 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>
; copy byte 0 of @02f to @030 and to a temp
  [-
; travel 1 cells right
  >
  +
; travel 8 cells right
  >>>>>>>>
  +
; travel 9 cells left
  <<<<<<<<<
  ]
; walk to the temps
; travel 9 cells right
  >>>>>>>>>
; put temp byte 0 back into @02f
  [-
; travel 9 cells left
  <<<<<<<<<
  +
; travel 9 cells right
  >>>>>>>>>
  ]
; travel 56 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<
; ADD16 : @011 gets @030  little endian
; byte 0
; travel 17 cells right
  >>>>>>>>>>>>>>>>>
; move byte 0 of @011 to @033
  [-
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 34 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 31 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @030 to @034
  [-
; travel 4 cells right
  >>>>
  +
; travel 4 cells left
  <<<<
  ]
; travel 4 cells right
  >>>>
; add the addend byte into the accumulator byte
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; travel 2 cells left
  <<
; move byte 0 of @032 to @034
  [-
; travel 2 cells right
  >>
  +
; travel 2 cells left
  <<
  ]
; travel 2 cells right
  >>
; add the carry coming in from the byte below
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; travel 1 cells left
  <
; move byte 0 of @033 to @011
  [-
; travel 34 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @035 to @032
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 53 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<
; byte 1
; travel 18 cells right
  >>>>>>>>>>>>>>>>>>
; move byte 0 of @012 to @033
  [-
; travel 33 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 33 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 31 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @031 to @034
  [-
; travel 3 cells right
  >>>
  +
; travel 3 cells left
  <<<
  ]
; travel 3 cells right
  >>>
; add the addend byte into the accumulator byte
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; travel 2 cells left
  <<
; move byte 0 of @032 to @034
  [-
; travel 2 cells right
  >>
  +
; travel 2 cells left
  <<
  ]
; travel 2 cells right
  >>
; add the carry coming in from the byte below
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; travel 1 cells left
  <
; move byte 0 of @033 to @012
  [-
; travel 33 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 33 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @035 to @032
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 53 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<
; drop the carry out of the top byte
; travel 50 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>
  [-]
; travel 50 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<
; travel 47 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>
; copy byte 0 of @02f to @030 and to a temp
  [-
; travel 1 cells right
  >
  +
; travel 8 cells right
  >>>>>>>>
  +
; travel 9 cells left
  <<<<<<<<<
  ]
; walk to the temps
; travel 9 cells right
  >>>>>>>>>
; put temp byte 0 back into @02f
  [-
; travel 9 cells left
  <<<<<<<<<
  +
; travel 9 cells right
  >>>>>>>>>
  ]
; travel 56 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<
; ADD16 : @011 gets @030  little endian
; byte 0
; travel 17 cells right
  >>>>>>>>>>>>>>>>>
; move byte 0 of @011 to @033
  [-
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 34 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 31 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @030 to @034
  [-
; travel 4 cells right
  >>>>
  +
; travel 4 cells left
  <<<<
  ]
; travel 4 cells right
  >>>>
; add the addend byte into the accumulator byte
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; travel 2 cells left
  <<
; move byte 0 of @032 to @034
  [-
; travel 2 cells right
  >>
  +
; travel 2 cells left
  <<
  ]
; travel 2 cells right
  >>
; add the carry coming in from the byte below
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; travel 1 cells left
  <
; move byte 0 of @033 to @011
  [-
; travel 34 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @035 to @032
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 53 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<
; byte 1
; travel 18 cells right
  >>>>>>>>>>>>>>>>>>
; move byte 0 of @012 to @033
  [-
; travel 33 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 33 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 31 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @031 to @034
  [-
; travel 3 cells right
  >>>
  +
; travel 3 cells left
  <<<
  ]
; travel 3 cells right
  >>>
; add the addend byte into the accumulator byte
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; travel 2 cells left
  <<
; move byte 0 of @032 to @034
  [-
; travel 2 cells right
  >>
  +
; travel 2 cells left
  <<
  ]
; travel 2 cells right
  >>
; add the carry coming in from the byte below
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; travel 1 cells left
  <
; move byte 0 of @033 to @012
  [-
; travel 33 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 33 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @035 to @032
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 53 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<
; drop the carry out of the top byte
; travel 50 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>
  [-]
; travel 50 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<
; discard H now that 5H is built
; travel 47 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>
  [-]
; travel 47 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<
; add 5H back into the value
; ADD136 : @000 gets @011  little endian
; byte 0
; move byte 0 of @000 to @023
  [-
; travel 35 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 35 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 17 cells right
  >>>>>>>>>>>>>>>>>
; move byte 0 of @011 to @024
  [-
; travel 19 cells right
  >>>>>>>>>>>>>>>>>>>
  +
; travel 19 cells left
  <<<<<<<<<<<<<<<<<<<
  ]
; travel 19 cells right
  >>>>>>>>>>>>>>>>>>>
; add the addend byte into the accumulator byte
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; travel 2 cells left
  <<
; move byte 0 of @022 to @024
  [-
; travel 2 cells right
  >>
  +
; travel 2 cells left
  <<
  ]
; travel 2 cells right
  >>
; add the carry coming in from the byte below
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; travel 1 cells left
  <
; move byte 0 of @023 to @000
  [-
; travel 35 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 35 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @025 to @022
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 37 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; byte 1
; travel 1 cells right
  >
; move byte 0 of @001 to @023
  [-
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 34 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 17 cells right
  >>>>>>>>>>>>>>>>>
; move byte 0 of @012 to @024
  [-
; travel 18 cells right
  >>>>>>>>>>>>>>>>>>
  +
; travel 18 cells left
  <<<<<<<<<<<<<<<<<<
  ]
; travel 18 cells right
  >>>>>>>>>>>>>>>>>>
; add the addend byte into the accumulator byte
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; travel 2 cells left
  <<
; move byte 0 of @022 to @024
  [-
; travel 2 cells right
  >>
  +
; travel 2 cells left
  <<
  ]
; travel 2 cells right
  >>
; add the carry coming in from the byte below
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; travel 1 cells left
  <
; move byte 0 of @023 to @001
  [-
; travel 34 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @025 to @022
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 37 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; byte 2
; travel 2 cells right
  >>
; move byte 0 of @002 to @023
  [-
; travel 33 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 33 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 17 cells right
  >>>>>>>>>>>>>>>>>
; move byte 0 of @013 to @024
  [-
; travel 17 cells right
  >>>>>>>>>>>>>>>>>
  +
; travel 17 cells left
  <<<<<<<<<<<<<<<<<
  ]
; travel 17 cells right
  >>>>>>>>>>>>>>>>>
; add the addend byte into the accumulator byte
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; travel 2 cells left
  <<
; move byte 0 of @022 to @024
  [-
; travel 2 cells right
  >>
  +
; travel 2 cells left
  <<
  ]
; travel 2 cells right
  >>
; add the carry coming in from the byte below
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; travel 1 cells left
  <
; move byte 0 of @023 to @002
  [-
; travel 33 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 33 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @025 to @022
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 37 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; byte 3
; travel 3 cells right
  >>>
; move byte 0 of @003 to @023
  [-
; travel 32 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 32 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 17 cells right
  >>>>>>>>>>>>>>>>>
; move byte 0 of @014 to @024
  [-
; travel 16 cells right
  >>>>>>>>>>>>>>>>
  +
; travel 16 cells left
  <<<<<<<<<<<<<<<<
  ]
; travel 16 cells right
  >>>>>>>>>>>>>>>>
; add the addend byte into the accumulator byte
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; travel 2 cells left
  <<
; move byte 0 of @022 to @024
  [-
; travel 2 cells right
  >>
  +
; travel 2 cells left
  <<
  ]
; travel 2 cells right
  >>
; add the carry coming in from the byte below
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; travel 1 cells left
  <
; move byte 0 of @023 to @003
  [-
; travel 32 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 32 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @025 to @022
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 37 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; byte 4
; travel 4 cells right
  >>>>
; move byte 0 of @004 to @023
  [-
; travel 31 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 31 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 17 cells right
  >>>>>>>>>>>>>>>>>
; move byte 0 of @015 to @024
  [-
; travel 15 cells right
  >>>>>>>>>>>>>>>
  +
; travel 15 cells left
  <<<<<<<<<<<<<<<
  ]
; travel 15 cells right
  >>>>>>>>>>>>>>>
; add the addend byte into the accumulator byte
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; travel 2 cells left
  <<
; move byte 0 of @022 to @024
  [-
; travel 2 cells right
  >>
  +
; travel 2 cells left
  <<
  ]
; travel 2 cells right
  >>
; add the carry coming in from the byte below
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; travel 1 cells left
  <
; move byte 0 of @023 to @004
  [-
; travel 31 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 31 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @025 to @022
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 37 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; byte 5
; travel 5 cells right
  >>>>>
; move byte 0 of @005 to @023
  [-
; travel 30 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 30 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 17 cells right
  >>>>>>>>>>>>>>>>>
; move byte 0 of @016 to @024
  [-
; travel 14 cells right
  >>>>>>>>>>>>>>
  +
; travel 14 cells left
  <<<<<<<<<<<<<<
  ]
; travel 14 cells right
  >>>>>>>>>>>>>>
; add the addend byte into the accumulator byte
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; travel 2 cells left
  <<
; move byte 0 of @022 to @024
  [-
; travel 2 cells right
  >>
  +
; travel 2 cells left
  <<
  ]
; travel 2 cells right
  >>
; add the carry coming in from the byte below
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; travel 1 cells left
  <
; move byte 0 of @023 to @005
  [-
; travel 30 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 30 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @025 to @022
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 37 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; byte 6
; travel 6 cells right
  >>>>>>
; move byte 0 of @006 to @023
  [-
; travel 29 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 29 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 17 cells right
  >>>>>>>>>>>>>>>>>
; move byte 0 of @017 to @024
  [-
; travel 13 cells right
  >>>>>>>>>>>>>
  +
; travel 13 cells left
  <<<<<<<<<<<<<
  ]
; travel 13 cells right
  >>>>>>>>>>>>>
; add the addend byte into the accumulator byte
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; travel 2 cells left
  <<
; move byte 0 of @022 to @024
  [-
; travel 2 cells right
  >>
  +
; travel 2 cells left
  <<
  ]
; travel 2 cells right
  >>
; add the carry coming in from the byte below
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; travel 1 cells left
  <
; move byte 0 of @023 to @006
  [-
; travel 29 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 29 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @025 to @022
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 37 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; byte 7
; travel 7 cells right
  >>>>>>>
; move byte 0 of @007 to @023
  [-
; travel 28 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 28 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 17 cells right
  >>>>>>>>>>>>>>>>>
; move byte 0 of @018 to @024
  [-
; travel 12 cells right
  >>>>>>>>>>>>
  +
; travel 12 cells left
  <<<<<<<<<<<<
  ]
; travel 12 cells right
  >>>>>>>>>>>>
; add the addend byte into the accumulator byte
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; travel 2 cells left
  <<
; move byte 0 of @022 to @024
  [-
; travel 2 cells right
  >>
  +
; travel 2 cells left
  <<
  ]
; travel 2 cells right
  >>
; add the carry coming in from the byte below
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; travel 1 cells left
  <
; move byte 0 of @023 to @007
  [-
; travel 28 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 28 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @025 to @022
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 37 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; byte 8
; travel 8 cells right
  >>>>>>>>
; move byte 0 of @008 to @023
  [-
; travel 27 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 27 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 17 cells right
  >>>>>>>>>>>>>>>>>
; move byte 0 of @019 to @024
  [-
; travel 11 cells right
  >>>>>>>>>>>
  +
; travel 11 cells left
  <<<<<<<<<<<
  ]
; travel 11 cells right
  >>>>>>>>>>>
; add the addend byte into the accumulator byte
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; travel 2 cells left
  <<
; move byte 0 of @022 to @024
  [-
; travel 2 cells right
  >>
  +
; travel 2 cells left
  <<
  ]
; travel 2 cells right
  >>
; add the carry coming in from the byte below
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; travel 1 cells left
  <
; move byte 0 of @023 to @008
  [-
; travel 27 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 27 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @025 to @022
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 37 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; byte 9
; travel 9 cells right
  >>>>>>>>>
; move byte 0 of @009 to @023
  [-
; travel 26 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 26 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 17 cells right
  >>>>>>>>>>>>>>>>>
; move byte 0 of @01a to @024
  [-
; travel 10 cells right
  >>>>>>>>>>
  +
; travel 10 cells left
  <<<<<<<<<<
  ]
; travel 10 cells right
  >>>>>>>>>>
; add the addend byte into the accumulator byte
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; travel 2 cells left
  <<
; move byte 0 of @022 to @024
  [-
; travel 2 cells right
  >>
  +
; travel 2 cells left
  <<
  ]
; travel 2 cells right
  >>
; add the carry coming in from the byte below
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; travel 1 cells left
  <
; move byte 0 of @023 to @009
  [-
; travel 26 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 26 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @025 to @022
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 37 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; byte 10
; travel 10 cells right
  >>>>>>>>>>
; move byte 0 of @00a to @023
  [-
; travel 25 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 25 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 17 cells right
  >>>>>>>>>>>>>>>>>
; move byte 0 of @01b to @024
  [-
; travel 9 cells right
  >>>>>>>>>
  +
; travel 9 cells left
  <<<<<<<<<
  ]
; travel 9 cells right
  >>>>>>>>>
; add the addend byte into the accumulator byte
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; travel 2 cells left
  <<
; move byte 0 of @022 to @024
  [-
; travel 2 cells right
  >>
  +
; travel 2 cells left
  <<
  ]
; travel 2 cells right
  >>
; add the carry coming in from the byte below
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; travel 1 cells left
  <
; move byte 0 of @023 to @00a
  [-
; travel 25 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 25 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @025 to @022
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 37 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; byte 11
; travel 11 cells right
  >>>>>>>>>>>
; move byte 0 of @00b to @023
  [-
; travel 24 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 24 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 17 cells right
  >>>>>>>>>>>>>>>>>
; move byte 0 of @01c to @024
  [-
; travel 8 cells right
  >>>>>>>>
  +
; travel 8 cells left
  <<<<<<<<
  ]
; travel 8 cells right
  >>>>>>>>
; add the addend byte into the accumulator byte
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; travel 2 cells left
  <<
; move byte 0 of @022 to @024
  [-
; travel 2 cells right
  >>
  +
; travel 2 cells left
  <<
  ]
; travel 2 cells right
  >>
; add the carry coming in from the byte below
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; travel 1 cells left
  <
; move byte 0 of @023 to @00b
  [-
; travel 24 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 24 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @025 to @022
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 37 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; byte 12
; travel 12 cells right
  >>>>>>>>>>>>
; move byte 0 of @00c to @023
  [-
; travel 23 cells right
  >>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 23 cells left
  <<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 17 cells right
  >>>>>>>>>>>>>>>>>
; move byte 0 of @01d to @024
  [-
; travel 7 cells right
  >>>>>>>
  +
; travel 7 cells left
  <<<<<<<
  ]
; travel 7 cells right
  >>>>>>>
; add the addend byte into the accumulator byte
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; travel 2 cells left
  <<
; move byte 0 of @022 to @024
  [-
; travel 2 cells right
  >>
  +
; travel 2 cells left
  <<
  ]
; travel 2 cells right
  >>
; add the carry coming in from the byte below
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; travel 1 cells left
  <
; move byte 0 of @023 to @00c
  [-
; travel 23 cells left
  <<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 23 cells right
  >>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @025 to @022
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 37 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; byte 13
; travel 13 cells right
  >>>>>>>>>>>>>
; move byte 0 of @00d to @023
  [-
; travel 22 cells right
  >>>>>>>>>>>>>>>>>>>>>>
  +
; travel 22 cells left
  <<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 17 cells right
  >>>>>>>>>>>>>>>>>
; move byte 0 of @01e to @024
  [-
; travel 6 cells right
  >>>>>>
  +
; travel 6 cells left
  <<<<<<
  ]
; travel 6 cells right
  >>>>>>
; add the addend byte into the accumulator byte
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; travel 2 cells left
  <<
; move byte 0 of @022 to @024
  [-
; travel 2 cells right
  >>
  +
; travel 2 cells left
  <<
  ]
; travel 2 cells right
  >>
; add the carry coming in from the byte below
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; travel 1 cells left
  <
; move byte 0 of @023 to @00d
  [-
; travel 22 cells left
  <<<<<<<<<<<<<<<<<<<<<<
  +
; travel 22 cells right
  >>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @025 to @022
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 37 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; byte 14
; travel 14 cells right
  >>>>>>>>>>>>>>
; move byte 0 of @00e to @023
  [-
; travel 21 cells right
  >>>>>>>>>>>>>>>>>>>>>
  +
; travel 21 cells left
  <<<<<<<<<<<<<<<<<<<<<
  ]
; travel 17 cells right
  >>>>>>>>>>>>>>>>>
; move byte 0 of @01f to @024
  [-
; travel 5 cells right
  >>>>>
  +
; travel 5 cells left
  <<<<<
  ]
; travel 5 cells right
  >>>>>
; add the addend byte into the accumulator byte
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; travel 2 cells left
  <<
; move byte 0 of @022 to @024
  [-
; travel 2 cells right
  >>
  +
; travel 2 cells left
  <<
  ]
; travel 2 cells right
  >>
; add the carry coming in from the byte below
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; travel 1 cells left
  <
; move byte 0 of @023 to @00e
  [-
; travel 21 cells left
  <<<<<<<<<<<<<<<<<<<<<
  +
; travel 21 cells right
  >>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @025 to @022
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 37 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; byte 15
; travel 15 cells right
  >>>>>>>>>>>>>>>
; move byte 0 of @00f to @023
  [-
; travel 20 cells right
  >>>>>>>>>>>>>>>>>>>>
  +
; travel 20 cells left
  <<<<<<<<<<<<<<<<<<<<
  ]
; travel 17 cells right
  >>>>>>>>>>>>>>>>>
; move byte 0 of @020 to @024
  [-
; travel 4 cells right
  >>>>
  +
; travel 4 cells left
  <<<<
  ]
; travel 4 cells right
  >>>>
; add the addend byte into the accumulator byte
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; travel 2 cells left
  <<
; move byte 0 of @022 to @024
  [-
; travel 2 cells right
  >>
  +
; travel 2 cells left
  <<
  ]
; travel 2 cells right
  >>
; add the carry coming in from the byte below
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; travel 1 cells left
  <
; move byte 0 of @023 to @00f
  [-
; travel 20 cells left
  <<<<<<<<<<<<<<<<<<<<
  +
; travel 20 cells right
  >>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @025 to @022
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 37 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; byte 16
; travel 16 cells right
  >>>>>>>>>>>>>>>>
; move byte 0 of @010 to @023
  [-
; travel 19 cells right
  >>>>>>>>>>>>>>>>>>>
  +
; travel 19 cells left
  <<<<<<<<<<<<<<<<<<<
  ]
; travel 17 cells right
  >>>>>>>>>>>>>>>>>
; move byte 0 of @021 to @024
  [-
; travel 3 cells right
  >>>
  +
; travel 3 cells left
  <<<
  ]
; travel 3 cells right
  >>>
; add the addend byte into the accumulator byte
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; travel 2 cells left
  <<
; move byte 0 of @022 to @024
  [-
; travel 2 cells right
  >>
  +
; travel 2 cells left
  <<
  ]
; travel 2 cells right
  >>
; add the carry coming in from the byte below
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; travel 1 cells left
  <
; move byte 0 of @023 to @010
  [-
; travel 19 cells left
  <<<<<<<<<<<<<<<<<<<
  +
; travel 19 cells right
  >>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @025 to @022
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 37 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; drop the carry out of the top byte
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  [-]
; travel 34 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

; emit the folded value little endian
  .>.>.>.>.>.>.>.>.>.>.>.>.>.>.>.>.
