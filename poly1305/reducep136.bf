; bfsodium REDUCEP136 : bring a 17 byte value below p = 2^130 minus 5
;
; ASSEMBLED FILE: emitted by tools/polyasm using the shared emitter;
;
; IO  in:  x{17} LE      (17 bytes)
;     out: (x mod p){17} LE   (17 bytes)
;
; TAPE MAP  (home @0)
;   @0x00:0x10  x{17}      u8   the value  and the result
;   @0x11:0x79  scratch{105}    see reducep_op in tools/bfemit
;
; Two folds bring any 17 byte value below 2^130; only the five values between
; p and 2^130 then remain  and for those x minus p is x plus 5 minus 2^130;
  ,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,
; travel 16 cells left
  <<<<<<<<<<<<<<<<
; REDUCE : bring the value below p = 2^130 minus 5
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
; copy the value and add five to it  to test whether it reaches p
; copy byte 0 of @000 to @039 and to a temp
  [-
; travel 57 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>
  +
; travel 31 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 88 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<
  ]>
; copy byte 1 of @001 to @03a and to a temp
  [-
; travel 57 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>
  +
; travel 31 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 88 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<
  ]>
; copy byte 2 of @002 to @03b and to a temp
  [-
; travel 57 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>
  +
; travel 31 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 88 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<
  ]>
; copy byte 3 of @003 to @03c and to a temp
  [-
; travel 57 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>
  +
; travel 31 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 88 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<
  ]>
; copy byte 4 of @004 to @03d and to a temp
  [-
; travel 57 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>
  +
; travel 31 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 88 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<
  ]>
; copy byte 5 of @005 to @03e and to a temp
  [-
; travel 57 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>
  +
; travel 31 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 88 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<
  ]>
; copy byte 6 of @006 to @03f and to a temp
  [-
; travel 57 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>
  +
; travel 31 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 88 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<
  ]>
; copy byte 7 of @007 to @040 and to a temp
  [-
; travel 57 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>
  +
; travel 31 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 88 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<
  ]>
; copy byte 8 of @008 to @041 and to a temp
  [-
; travel 57 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>
  +
; travel 31 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 88 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<
  ]>
; copy byte 9 of @009 to @042 and to a temp
  [-
; travel 57 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>
  +
; travel 31 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 88 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<
  ]>
; copy byte 10 of @00a to @043 and to a temp
  [-
; travel 57 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>
  +
; travel 31 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 88 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<
  ]>
; copy byte 11 of @00b to @044 and to a temp
  [-
; travel 57 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>
  +
; travel 31 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 88 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<
  ]>
; copy byte 12 of @00c to @045 and to a temp
  [-
; travel 57 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>
  +
; travel 31 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 88 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<
  ]>
; copy byte 13 of @00d to @046 and to a temp
  [-
; travel 57 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>
  +
; travel 31 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 88 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<
  ]>
; copy byte 14 of @00e to @047 and to a temp
  [-
; travel 57 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>
  +
; travel 31 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 88 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<
  ]>
; copy byte 15 of @00f to @048 and to a temp
  [-
; travel 57 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>
  +
; travel 31 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 88 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<
  ]>
; copy byte 16 of @010 to @049 and to a temp
  [-
; travel 57 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>
  +
; travel 31 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 88 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<
  ]
; walk to the temps
; travel 72 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; put temp byte 0 back into @000
  [-
; travel 88 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<
  +
; travel 88 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>
  ]>
; put temp byte 1 back into @001
  [-
; travel 88 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<
  +
; travel 88 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>
  ]>
; put temp byte 2 back into @002
  [-
; travel 88 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<
  +
; travel 88 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>
  ]>
; put temp byte 3 back into @003
  [-
; travel 88 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<
  +
; travel 88 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>
  ]>
; put temp byte 4 back into @004
  [-
; travel 88 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<
  +
; travel 88 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>
  ]>
; put temp byte 5 back into @005
  [-
; travel 88 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<
  +
; travel 88 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>
  ]>
; put temp byte 6 back into @006
  [-
; travel 88 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<
  +
; travel 88 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>
  ]>
; put temp byte 7 back into @007
  [-
; travel 88 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<
  +
; travel 88 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>
  ]>
; put temp byte 8 back into @008
  [-
; travel 88 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<
  +
; travel 88 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>
  ]>
; put temp byte 9 back into @009
  [-
; travel 88 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<
  +
; travel 88 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>
  ]>
; put temp byte 10 back into @00a
  [-
; travel 88 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<
  +
; travel 88 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>
  ]>
; put temp byte 11 back into @00b
  [-
; travel 88 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<
  +
; travel 88 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>
  ]>
; put temp byte 12 back into @00c
  [-
; travel 88 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<
  +
; travel 88 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>
  ]>
; put temp byte 13 back into @00d
  [-
; travel 88 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<
  +
; travel 88 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>
  ]>
; put temp byte 14 back into @00e
  [-
; travel 88 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<
  +
; travel 88 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>
  ]>
; put temp byte 15 back into @00f
  [-
; travel 88 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<
  +
; travel 88 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>
  ]>
; put temp byte 16 back into @010
  [-
; travel 88 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<
  +
; travel 88 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>
  ]
; travel 104 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<
; travel 105 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>
; add 5
  +++++
; travel 105 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<
; ADD136 : @039 gets @069  little endian
; byte 0
; travel 57 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>
; move byte 0 of @039 to @04b
  [-
; travel 18 cells right
  >>>>>>>>>>>>>>>>>>
  +
; travel 18 cells left
  <<<<<<<<<<<<<<<<<<
  ]
; travel 48 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>
; move byte 0 of @069 to @04c
  [-
; travel 29 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 29 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 29 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; add the addend byte into the accumulator byte
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; travel 2 cells left
  <<
; move byte 0 of @04a to @04c
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
; move byte 0 of @04b to @039
  [-
; travel 18 cells left
  <<<<<<<<<<<<<<<<<<
  +
; travel 18 cells right
  >>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @04d to @04a
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 77 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; byte 1
; travel 58 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>
; move byte 0 of @03a to @04b
  [-
; travel 17 cells right
  >>>>>>>>>>>>>>>>>
  +
; travel 17 cells left
  <<<<<<<<<<<<<<<<<
  ]
; travel 48 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>
; move byte 0 of @06a to @04c
  [-
; travel 30 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 30 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 30 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; add the addend byte into the accumulator byte
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; travel 2 cells left
  <<
; move byte 0 of @04a to @04c
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
; move byte 0 of @04b to @03a
  [-
; travel 17 cells left
  <<<<<<<<<<<<<<<<<
  +
; travel 17 cells right
  >>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @04d to @04a
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 77 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; byte 2
; travel 59 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>
; move byte 0 of @03b to @04b
  [-
; travel 16 cells right
  >>>>>>>>>>>>>>>>
  +
; travel 16 cells left
  <<<<<<<<<<<<<<<<
  ]
; travel 48 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>
; move byte 0 of @06b to @04c
  [-
; travel 31 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 31 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 31 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; add the addend byte into the accumulator byte
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; travel 2 cells left
  <<
; move byte 0 of @04a to @04c
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
; move byte 0 of @04b to @03b
  [-
; travel 16 cells left
  <<<<<<<<<<<<<<<<
  +
; travel 16 cells right
  >>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @04d to @04a
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 77 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; byte 3
; travel 60 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>
; move byte 0 of @03c to @04b
  [-
; travel 15 cells right
  >>>>>>>>>>>>>>>
  +
; travel 15 cells left
  <<<<<<<<<<<<<<<
  ]
; travel 48 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>
; move byte 0 of @06c to @04c
  [-
; travel 32 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 32 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 32 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; add the addend byte into the accumulator byte
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; travel 2 cells left
  <<
; move byte 0 of @04a to @04c
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
; move byte 0 of @04b to @03c
  [-
; travel 15 cells left
  <<<<<<<<<<<<<<<
  +
; travel 15 cells right
  >>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @04d to @04a
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 77 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; byte 4
; travel 61 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @03d to @04b
  [-
; travel 14 cells right
  >>>>>>>>>>>>>>
  +
; travel 14 cells left
  <<<<<<<<<<<<<<
  ]
; travel 48 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>
; move byte 0 of @06d to @04c
  [-
; travel 33 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 33 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 33 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; add the addend byte into the accumulator byte
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; travel 2 cells left
  <<
; move byte 0 of @04a to @04c
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
; move byte 0 of @04b to @03d
  [-
; travel 14 cells left
  <<<<<<<<<<<<<<
  +
; travel 14 cells right
  >>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @04d to @04a
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 77 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; byte 5
; travel 62 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @03e to @04b
  [-
; travel 13 cells right
  >>>>>>>>>>>>>
  +
; travel 13 cells left
  <<<<<<<<<<<<<
  ]
; travel 48 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>
; move byte 0 of @06e to @04c
  [-
; travel 34 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 34 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; add the addend byte into the accumulator byte
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; travel 2 cells left
  <<
; move byte 0 of @04a to @04c
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
; move byte 0 of @04b to @03e
  [-
; travel 13 cells left
  <<<<<<<<<<<<<
  +
; travel 13 cells right
  >>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @04d to @04a
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 77 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; byte 6
; travel 63 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @03f to @04b
  [-
; travel 12 cells right
  >>>>>>>>>>>>
  +
; travel 12 cells left
  <<<<<<<<<<<<
  ]
; travel 48 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>
; move byte 0 of @06f to @04c
  [-
; travel 35 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 35 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 35 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; add the addend byte into the accumulator byte
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; travel 2 cells left
  <<
; move byte 0 of @04a to @04c
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
; move byte 0 of @04b to @03f
  [-
; travel 12 cells left
  <<<<<<<<<<<<
  +
; travel 12 cells right
  >>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @04d to @04a
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 77 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; byte 7
; travel 64 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @040 to @04b
  [-
; travel 11 cells right
  >>>>>>>>>>>
  +
; travel 11 cells left
  <<<<<<<<<<<
  ]
; travel 48 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>
; move byte 0 of @070 to @04c
  [-
; travel 36 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 36 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 36 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; add the addend byte into the accumulator byte
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; travel 2 cells left
  <<
; move byte 0 of @04a to @04c
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
; move byte 0 of @04b to @040
  [-
; travel 11 cells left
  <<<<<<<<<<<
  +
; travel 11 cells right
  >>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @04d to @04a
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 77 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; byte 8
; travel 65 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @041 to @04b
  [-
; travel 10 cells right
  >>>>>>>>>>
  +
; travel 10 cells left
  <<<<<<<<<<
  ]
; travel 48 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>
; move byte 0 of @071 to @04c
  [-
; travel 37 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 37 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 37 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; add the addend byte into the accumulator byte
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; travel 2 cells left
  <<
; move byte 0 of @04a to @04c
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
; move byte 0 of @04b to @041
  [-
; travel 10 cells left
  <<<<<<<<<<
  +
; travel 10 cells right
  >>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @04d to @04a
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 77 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; byte 9
; travel 66 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @042 to @04b
  [-
; travel 9 cells right
  >>>>>>>>>
  +
; travel 9 cells left
  <<<<<<<<<
  ]
; travel 48 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>
; move byte 0 of @072 to @04c
  [-
; travel 38 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 38 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 38 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; add the addend byte into the accumulator byte
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; travel 2 cells left
  <<
; move byte 0 of @04a to @04c
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
; move byte 0 of @04b to @042
  [-
; travel 9 cells left
  <<<<<<<<<
  +
; travel 9 cells right
  >>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @04d to @04a
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 77 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; byte 10
; travel 67 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @043 to @04b
  [-
; travel 8 cells right
  >>>>>>>>
  +
; travel 8 cells left
  <<<<<<<<
  ]
; travel 48 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>
; move byte 0 of @073 to @04c
  [-
; travel 39 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 39 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 39 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; add the addend byte into the accumulator byte
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; travel 2 cells left
  <<
; move byte 0 of @04a to @04c
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
; move byte 0 of @04b to @043
  [-
; travel 8 cells left
  <<<<<<<<
  +
; travel 8 cells right
  >>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @04d to @04a
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 77 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; byte 11
; travel 68 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @044 to @04b
  [-
; travel 7 cells right
  >>>>>>>
  +
; travel 7 cells left
  <<<<<<<
  ]
; travel 48 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>
; move byte 0 of @074 to @04c
  [-
; travel 40 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 40 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 40 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; add the addend byte into the accumulator byte
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; travel 2 cells left
  <<
; move byte 0 of @04a to @04c
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
; move byte 0 of @04b to @044
  [-
; travel 7 cells left
  <<<<<<<
  +
; travel 7 cells right
  >>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @04d to @04a
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 77 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; byte 12
; travel 69 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @045 to @04b
  [-
; travel 6 cells right
  >>>>>>
  +
; travel 6 cells left
  <<<<<<
  ]
; travel 48 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>
; move byte 0 of @075 to @04c
  [-
; travel 41 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <
  +
; travel 41 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >
  ]
; travel 41 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <
; add the addend byte into the accumulator byte
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; travel 2 cells left
  <<
; move byte 0 of @04a to @04c
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
; move byte 0 of @04b to @045
  [-
; travel 6 cells left
  <<<<<<
  +
; travel 6 cells right
  >>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @04d to @04a
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 77 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; byte 13
; travel 70 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @046 to @04b
  [-
; travel 5 cells right
  >>>>>
  +
; travel 5 cells left
  <<<<<
  ]
; travel 48 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>
; move byte 0 of @076 to @04c
  [-
; travel 42 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<
  +
; travel 42 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>
  ]
; travel 42 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<
; add the addend byte into the accumulator byte
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; travel 2 cells left
  <<
; move byte 0 of @04a to @04c
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
; move byte 0 of @04b to @046
  [-
; travel 5 cells left
  <<<<<
  +
; travel 5 cells right
  >>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @04d to @04a
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 77 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; byte 14
; travel 71 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @047 to @04b
  [-
; travel 4 cells right
  >>>>
  +
; travel 4 cells left
  <<<<
  ]
; travel 48 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>
; move byte 0 of @077 to @04c
  [-
; travel 43 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<
  +
; travel 43 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>
  ]
; travel 43 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<
; add the addend byte into the accumulator byte
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; travel 2 cells left
  <<
; move byte 0 of @04a to @04c
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
; move byte 0 of @04b to @047
  [-
; travel 4 cells left
  <<<<
  +
; travel 4 cells right
  >>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @04d to @04a
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 77 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; byte 15
; travel 72 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @048 to @04b
  [-
; travel 3 cells right
  >>>
  +
; travel 3 cells left
  <<<
  ]
; travel 48 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>
; move byte 0 of @078 to @04c
  [-
; travel 44 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<
  +
; travel 44 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>
  ]
; travel 44 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<
; add the addend byte into the accumulator byte
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; travel 2 cells left
  <<
; move byte 0 of @04a to @04c
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
; move byte 0 of @04b to @048
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @04d to @04a
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 77 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; byte 16
; travel 73 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @049 to @04b
  [-
; travel 2 cells right
  >>
  +
; travel 2 cells left
  <<
  ]
; travel 48 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>
; move byte 0 of @079 to @04c
  [-
; travel 45 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<
  +
; travel 45 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>
  ]
; travel 45 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<
; add the addend byte into the accumulator byte
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; travel 2 cells left
  <<
; move byte 0 of @04a to @04c
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
; move byte 0 of @04b to @049
  [-
; travel 2 cells left
  <<
  +
; travel 2 cells right
  >>
  ]
; travel 2 cells right
  >>
; move byte 0 of @04d to @04a
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 77 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; drop the carry out of the top byte
; travel 74 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  [-]
; travel 74 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; split the sum's top byte  bit 130 tells us whether x was at least p
; travel 73 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @049 to @050
  [-
; travel 7 cells right
  >>>>>>>
  +
; travel 7 cells left
  <<<<<<<
  ]
; travel 7 cells right
  >>>>>>>
  [->>>+<[-<+>>-<]>[-<+>]<<<]
; travel 2 cells right
  >>
; move byte 0 of @052 to @055
  [-
; travel 3 cells right
  >>>
  +
; travel 3 cells left
  <<<
  ]
; travel 1 cells left
  <
; move byte 0 of @051 to @050
  [-
; travel 1 cells left
  <
  +
; travel 1 cells right
  >
  ]
; travel 1 cells left
  <
  [->>>+<[-<+>>-<]>[-<+>]<<<]
; travel 2 cells right
  >>
; move byte 0 of @052 to @056
  [-
; travel 4 cells right
  >>>>
  +
; travel 4 cells left
  <<<<
  ]
; travel 1 cells left
  <
; move byte 0 of @051 to @057
  [-
; travel 6 cells right
  >>>>>>
  +
; travel 6 cells left
  <<<<<<
  ]
; travel 81 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <
; put the two low bits back  so the sum has bit 130 cleared
; travel 85 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>
; move byte 0 of @055 to @049
  [-
; travel 12 cells left
  <<<<<<<<<<<<
  +
; travel 12 cells right
  >>>>>>>>>>>>
  ]
; travel 1 cells right
  >
  [-
; travel 13 cells left
  <<<<<<<<<<<<<
  ++
; travel 13 cells right
  >>>>>>>>>>>>>
  ]
; travel 86 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<
; if the sum crossed bit 130  the value was at least p  so take the sum
; travel 87 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>
  [
  [-]
; travel 87 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<
  [-]
; travel 1 cells right
  >
  [-]
; travel 1 cells left
  <
; travel 2 cells right
  >>
  [-]
; travel 2 cells left
  <<
; travel 3 cells right
  >>>
  [-]
; travel 3 cells left
  <<<
; travel 4 cells right
  >>>>
  [-]
; travel 4 cells left
  <<<<
; travel 5 cells right
  >>>>>
  [-]
; travel 5 cells left
  <<<<<
; travel 6 cells right
  >>>>>>
  [-]
; travel 6 cells left
  <<<<<<
; travel 7 cells right
  >>>>>>>
  [-]
; travel 7 cells left
  <<<<<<<
; travel 8 cells right
  >>>>>>>>
  [-]
; travel 8 cells left
  <<<<<<<<
; travel 9 cells right
  >>>>>>>>>
  [-]
; travel 9 cells left
  <<<<<<<<<
; travel 10 cells right
  >>>>>>>>>>
  [-]
; travel 10 cells left
  <<<<<<<<<<
; travel 11 cells right
  >>>>>>>>>>>
  [-]
; travel 11 cells left
  <<<<<<<<<<<
; travel 12 cells right
  >>>>>>>>>>>>
  [-]
; travel 12 cells left
  <<<<<<<<<<<<
; travel 13 cells right
  >>>>>>>>>>>>>
  [-]
; travel 13 cells left
  <<<<<<<<<<<<<
; travel 14 cells right
  >>>>>>>>>>>>>>
  [-]
; travel 14 cells left
  <<<<<<<<<<<<<<
; travel 15 cells right
  >>>>>>>>>>>>>>>
  [-]
; travel 15 cells left
  <<<<<<<<<<<<<<<
; travel 16 cells right
  >>>>>>>>>>>>>>>>
  [-]
; travel 16 cells left
  <<<<<<<<<<<<<<<<
; travel 57 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>
; move byte 0 of @039 to @000
  [-
; travel 57 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<
  +
; travel 57 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>
  ]>
; move byte 1 of @03a to @001
  [-
; travel 57 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<
  +
; travel 57 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>
  ]>
; move byte 2 of @03b to @002
  [-
; travel 57 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<
  +
; travel 57 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>
  ]>
; move byte 3 of @03c to @003
  [-
; travel 57 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<
  +
; travel 57 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>
  ]>
; move byte 4 of @03d to @004
  [-
; travel 57 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<
  +
; travel 57 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>
  ]>
; move byte 5 of @03e to @005
  [-
; travel 57 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<
  +
; travel 57 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>
  ]>
; move byte 6 of @03f to @006
  [-
; travel 57 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<
  +
; travel 57 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>
  ]>
; move byte 7 of @040 to @007
  [-
; travel 57 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<
  +
; travel 57 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>
  ]>
; move byte 8 of @041 to @008
  [-
; travel 57 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<
  +
; travel 57 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>
  ]>
; move byte 9 of @042 to @009
  [-
; travel 57 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<
  +
; travel 57 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>
  ]>
; move byte 10 of @043 to @00a
  [-
; travel 57 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<
  +
; travel 57 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>
  ]>
; move byte 11 of @044 to @00b
  [-
; travel 57 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<
  +
; travel 57 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>
  ]>
; move byte 12 of @045 to @00c
  [-
; travel 57 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<
  +
; travel 57 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>
  ]>
; move byte 13 of @046 to @00d
  [-
; travel 57 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<
  +
; travel 57 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>
  ]>
; move byte 14 of @047 to @00e
  [-
; travel 57 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<
  +
; travel 57 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>
  ]>
; move byte 15 of @048 to @00f
  [-
; travel 57 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<
  +
; travel 57 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>
  ]>
; move byte 16 of @049 to @010
  [-
; travel 57 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<
  +
; travel 57 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>
  ]
; travel 14 cells right
  >>>>>>>>>>>>>>
  ]
; travel 87 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<
; discard the trial sum  it is already empty when it was taken
; travel 57 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>
  [-]
; travel 57 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<
; travel 58 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>
  [-]
; travel 58 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<
; travel 59 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>
  [-]
; travel 59 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<
; travel 60 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>
  [-]
; travel 60 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<
; travel 61 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>
  [-]
; travel 61 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<
; travel 62 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>
  [-]
; travel 62 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<
; travel 63 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
  [-]
; travel 63 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<
; travel 64 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>
  [-]
; travel 64 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<
; travel 65 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>
  [-]
; travel 65 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<
; travel 66 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>
  [-]
; travel 66 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<
; travel 67 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>
  [-]
; travel 67 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<
; travel 68 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>
  [-]
; travel 68 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<
; travel 69 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  [-]
; travel 69 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; travel 70 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  [-]
; travel 70 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; travel 71 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  [-]
; travel 71 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; travel 72 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  [-]
; travel 72 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; travel 73 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  [-]
; travel 73 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

; emit the reduced value little endian
  .>.>.>.>.>.>.>.>.>.>.>.>.>.>.>.>.
