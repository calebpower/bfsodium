; bfsodium MULMOD136 : multiply modulo p = 2^130 minus 5
;
; ASSEMBLED FILE: emitted by tools/polyasm using the shared emitter;
;
; IO  in:  a{17} LE  followed by  r{17} LE     (34 bytes)
;     out: (a times r mod p){17} LE            (17 bytes)
;
; TAPE MAP  (home @0)
;   @0x00:0x10  a{17}       u8   the accumulator  and the result
;   @0x11:0x21  r{17}       u8   the multiplier  consumed bit by bit
;   @0x22:0xda  scratch{185}     see mulmod_op in tools/bfemit
;
; There is no multiply instruction  so this is double and add over the bits of
; r  walked out of the bottom; a fold after every add and every doubling keeps
; both operands under 2^130 plus a little  so 17 bytes always suffice;
  ,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,
  >,>,>,
; travel 33 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; MULMOD : the accumulator times r  modulo 2^130 minus 5
; the accumulator moves into the running value  leaving room for the product
; move byte 0 of @000 to @022
  [-
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 34 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]>
; move byte 1 of @001 to @023
  [-
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 34 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]>
; move byte 2 of @002 to @024
  [-
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 34 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]>
; move byte 3 of @003 to @025
  [-
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 34 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]>
; move byte 4 of @004 to @026
  [-
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 34 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]>
; move byte 5 of @005 to @027
  [-
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 34 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]>
; move byte 6 of @006 to @028
  [-
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 34 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]>
; move byte 7 of @007 to @029
  [-
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 34 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]>
; move byte 8 of @008 to @02a
  [-
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 34 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]>
; move byte 9 of @009 to @02b
  [-
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 34 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]>
; move byte 10 of @00a to @02c
  [-
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 34 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]>
; move byte 11 of @00b to @02d
  [-
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 34 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]>
; move byte 12 of @00c to @02e
  [-
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 34 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]>
; move byte 13 of @00d to @02f
  [-
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 34 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]>
; move byte 14 of @00e to @030
  [-
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 34 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]>
; move byte 15 of @00f to @031
  [-
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 34 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]>
; move byte 16 of @010 to @032
  [-
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 34 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 16 cells left
  <<<<<<<<<<<<<<<<
; one step per bit of r  all 136 of them  since r is 17 bytes wide
; stopping at 128 would silently ignore any bits in the top byte
; travel 90 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>
; add 136
  ++++++++++++++++++++++++++++++++++++++++
  ++++++++++++++++++++++++++++++++++++++++
  ++++++++++++++++++++++++++++++++++++++++
  ++++++++++++++++
; travel 90 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<
; travel 90 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>
  [-
; travel 90 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<
; HALVE136 : @011 shifted right one  keeping the bit shifted out
; byte 16  the top byte first
; travel 33 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @021 to @055
  [-
; travel 52 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>
  +
; travel 52 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<
  ]
; travel 52 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>
; halve it  leaving the quotient and this byte's low bit
  [->>>+<[-<+>>-<]>[-<+>]<<<]
; travel 4 cells right
  >>>>
; a bit carried in from the byte above becomes the top bit here
  [-
; travel 3 cells left
  <<<
; add 128
  ++++++++++++++++++++++++++++++++++++++++
  ++++++++++++++++++++++++++++++++++++++++
  ++++++++++++++++++++++++++++++++++++++++
  ++++++++
; travel 3 cells right
  >>>
  ]
; travel 3 cells left
  <<<
; move byte 0 of @056 to @021
  [-
; travel 53 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<
  +
; travel 53 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>
  ]
; travel 1 cells right
  >
; move byte 0 of @057 to @059
  [-
; travel 2 cells right
  >>
  +
; travel 2 cells left
  <<
  ]
; travel 87 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<
; byte 15  the top byte first
; travel 32 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @020 to @055
  [-
; travel 53 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>
  +
; travel 53 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<
  ]
; travel 53 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>
; halve it  leaving the quotient and this byte's low bit
  [->>>+<[-<+>>-<]>[-<+>]<<<]
; travel 4 cells right
  >>>>
; a bit carried in from the byte above becomes the top bit here
  [-
; travel 3 cells left
  <<<
; add 128
  ++++++++++++++++++++++++++++++++++++++++
  ++++++++++++++++++++++++++++++++++++++++
  ++++++++++++++++++++++++++++++++++++++++
  ++++++++
; travel 3 cells right
  >>>
  ]
; travel 3 cells left
  <<<
; move byte 0 of @056 to @020
  [-
; travel 54 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
  +
; travel 54 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>
  ]
; travel 1 cells right
  >
; move byte 0 of @057 to @059
  [-
; travel 2 cells right
  >>
  +
; travel 2 cells left
  <<
  ]
; travel 87 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<
; byte 14  the top byte first
; travel 31 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @01f to @055
  [-
; travel 54 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>
  +
; travel 54 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
  ]
; travel 54 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>
; halve it  leaving the quotient and this byte's low bit
  [->>>+<[-<+>>-<]>[-<+>]<<<]
; travel 4 cells right
  >>>>
; a bit carried in from the byte above becomes the top bit here
  [-
; travel 3 cells left
  <<<
; add 128
  ++++++++++++++++++++++++++++++++++++++++
  ++++++++++++++++++++++++++++++++++++++++
  ++++++++++++++++++++++++++++++++++++++++
  ++++++++
; travel 3 cells right
  >>>
  ]
; travel 3 cells left
  <<<
; move byte 0 of @056 to @01f
  [-
; travel 55 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<
  +
; travel 55 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>
  ]
; travel 1 cells right
  >
; move byte 0 of @057 to @059
  [-
; travel 2 cells right
  >>
  +
; travel 2 cells left
  <<
  ]
; travel 87 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<
; byte 13  the top byte first
; travel 30 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @01e to @055
  [-
; travel 55 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>
  +
; travel 55 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<
  ]
; travel 55 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>
; halve it  leaving the quotient and this byte's low bit
  [->>>+<[-<+>>-<]>[-<+>]<<<]
; travel 4 cells right
  >>>>
; a bit carried in from the byte above becomes the top bit here
  [-
; travel 3 cells left
  <<<
; add 128
  ++++++++++++++++++++++++++++++++++++++++
  ++++++++++++++++++++++++++++++++++++++++
  ++++++++++++++++++++++++++++++++++++++++
  ++++++++
; travel 3 cells right
  >>>
  ]
; travel 3 cells left
  <<<
; move byte 0 of @056 to @01e
  [-
; travel 56 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<
  +
; travel 56 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>
  ]
; travel 1 cells right
  >
; move byte 0 of @057 to @059
  [-
; travel 2 cells right
  >>
  +
; travel 2 cells left
  <<
  ]
; travel 87 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<
; byte 12  the top byte first
; travel 29 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @01d to @055
  [-
; travel 56 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>
  +
; travel 56 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<
  ]
; travel 56 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>
; halve it  leaving the quotient and this byte's low bit
  [->>>+<[-<+>>-<]>[-<+>]<<<]
; travel 4 cells right
  >>>>
; a bit carried in from the byte above becomes the top bit here
  [-
; travel 3 cells left
  <<<
; add 128
  ++++++++++++++++++++++++++++++++++++++++
  ++++++++++++++++++++++++++++++++++++++++
  ++++++++++++++++++++++++++++++++++++++++
  ++++++++
; travel 3 cells right
  >>>
  ]
; travel 3 cells left
  <<<
; move byte 0 of @056 to @01d
  [-
; travel 57 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<
  +
; travel 57 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>
  ]
; travel 1 cells right
  >
; move byte 0 of @057 to @059
  [-
; travel 2 cells right
  >>
  +
; travel 2 cells left
  <<
  ]
; travel 87 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<
; byte 11  the top byte first
; travel 28 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @01c to @055
  [-
; travel 57 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>
  +
; travel 57 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<
  ]
; travel 57 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>
; halve it  leaving the quotient and this byte's low bit
  [->>>+<[-<+>>-<]>[-<+>]<<<]
; travel 4 cells right
  >>>>
; a bit carried in from the byte above becomes the top bit here
  [-
; travel 3 cells left
  <<<
; add 128
  ++++++++++++++++++++++++++++++++++++++++
  ++++++++++++++++++++++++++++++++++++++++
  ++++++++++++++++++++++++++++++++++++++++
  ++++++++
; travel 3 cells right
  >>>
  ]
; travel 3 cells left
  <<<
; move byte 0 of @056 to @01c
  [-
; travel 58 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<
  +
; travel 58 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>
  ]
; travel 1 cells right
  >
; move byte 0 of @057 to @059
  [-
; travel 2 cells right
  >>
  +
; travel 2 cells left
  <<
  ]
; travel 87 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<
; byte 10  the top byte first
; travel 27 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @01b to @055
  [-
; travel 58 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>
  +
; travel 58 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<
  ]
; travel 58 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>
; halve it  leaving the quotient and this byte's low bit
  [->>>+<[-<+>>-<]>[-<+>]<<<]
; travel 4 cells right
  >>>>
; a bit carried in from the byte above becomes the top bit here
  [-
; travel 3 cells left
  <<<
; add 128
  ++++++++++++++++++++++++++++++++++++++++
  ++++++++++++++++++++++++++++++++++++++++
  ++++++++++++++++++++++++++++++++++++++++
  ++++++++
; travel 3 cells right
  >>>
  ]
; travel 3 cells left
  <<<
; move byte 0 of @056 to @01b
  [-
; travel 59 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<
  +
; travel 59 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>
  ]
; travel 1 cells right
  >
; move byte 0 of @057 to @059
  [-
; travel 2 cells right
  >>
  +
; travel 2 cells left
  <<
  ]
; travel 87 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<
; byte 9  the top byte first
; travel 26 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @01a to @055
  [-
; travel 59 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>
  +
; travel 59 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<
  ]
; travel 59 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>
; halve it  leaving the quotient and this byte's low bit
  [->>>+<[-<+>>-<]>[-<+>]<<<]
; travel 4 cells right
  >>>>
; a bit carried in from the byte above becomes the top bit here
  [-
; travel 3 cells left
  <<<
; add 128
  ++++++++++++++++++++++++++++++++++++++++
  ++++++++++++++++++++++++++++++++++++++++
  ++++++++++++++++++++++++++++++++++++++++
  ++++++++
; travel 3 cells right
  >>>
  ]
; travel 3 cells left
  <<<
; move byte 0 of @056 to @01a
  [-
; travel 60 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<
  +
; travel 60 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>
  ]
; travel 1 cells right
  >
; move byte 0 of @057 to @059
  [-
; travel 2 cells right
  >>
  +
; travel 2 cells left
  <<
  ]
; travel 87 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<
; byte 8  the top byte first
; travel 25 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @019 to @055
  [-
; travel 60 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>
  +
; travel 60 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<
  ]
; travel 60 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>
; halve it  leaving the quotient and this byte's low bit
  [->>>+<[-<+>>-<]>[-<+>]<<<]
; travel 4 cells right
  >>>>
; a bit carried in from the byte above becomes the top bit here
  [-
; travel 3 cells left
  <<<
; add 128
  ++++++++++++++++++++++++++++++++++++++++
  ++++++++++++++++++++++++++++++++++++++++
  ++++++++++++++++++++++++++++++++++++++++
  ++++++++
; travel 3 cells right
  >>>
  ]
; travel 3 cells left
  <<<
; move byte 0 of @056 to @019
  [-
; travel 61 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<
  +
; travel 61 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>
  ]
; travel 1 cells right
  >
; move byte 0 of @057 to @059
  [-
; travel 2 cells right
  >>
  +
; travel 2 cells left
  <<
  ]
; travel 87 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<
; byte 7  the top byte first
; travel 24 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @018 to @055
  [-
; travel 61 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>
  +
; travel 61 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<
  ]
; travel 61 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>
; halve it  leaving the quotient and this byte's low bit
  [->>>+<[-<+>>-<]>[-<+>]<<<]
; travel 4 cells right
  >>>>
; a bit carried in from the byte above becomes the top bit here
  [-
; travel 3 cells left
  <<<
; add 128
  ++++++++++++++++++++++++++++++++++++++++
  ++++++++++++++++++++++++++++++++++++++++
  ++++++++++++++++++++++++++++++++++++++++
  ++++++++
; travel 3 cells right
  >>>
  ]
; travel 3 cells left
  <<<
; move byte 0 of @056 to @018
  [-
; travel 62 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<
  +
; travel 62 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 1 cells right
  >
; move byte 0 of @057 to @059
  [-
; travel 2 cells right
  >>
  +
; travel 2 cells left
  <<
  ]
; travel 87 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<
; byte 6  the top byte first
; travel 23 cells right
  >>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @017 to @055
  [-
; travel 62 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>
  +
; travel 62 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 62 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>
; halve it  leaving the quotient and this byte's low bit
  [->>>+<[-<+>>-<]>[-<+>]<<<]
; travel 4 cells right
  >>>>
; a bit carried in from the byte above becomes the top bit here
  [-
; travel 3 cells left
  <<<
; add 128
  ++++++++++++++++++++++++++++++++++++++++
  ++++++++++++++++++++++++++++++++++++++++
  ++++++++++++++++++++++++++++++++++++++++
  ++++++++
; travel 3 cells right
  >>>
  ]
; travel 3 cells left
  <<<
; move byte 0 of @056 to @017
  [-
; travel 63 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 63 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 1 cells right
  >
; move byte 0 of @057 to @059
  [-
; travel 2 cells right
  >>
  +
; travel 2 cells left
  <<
  ]
; travel 87 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<
; byte 5  the top byte first
; travel 22 cells right
  >>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @016 to @055
  [-
; travel 63 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 63 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 63 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
; halve it  leaving the quotient and this byte's low bit
  [->>>+<[-<+>>-<]>[-<+>]<<<]
; travel 4 cells right
  >>>>
; a bit carried in from the byte above becomes the top bit here
  [-
; travel 3 cells left
  <<<
; add 128
  ++++++++++++++++++++++++++++++++++++++++
  ++++++++++++++++++++++++++++++++++++++++
  ++++++++++++++++++++++++++++++++++++++++
  ++++++++
; travel 3 cells right
  >>>
  ]
; travel 3 cells left
  <<<
; move byte 0 of @056 to @016
  [-
; travel 64 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 64 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 1 cells right
  >
; move byte 0 of @057 to @059
  [-
; travel 2 cells right
  >>
  +
; travel 2 cells left
  <<
  ]
; travel 87 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<
; byte 4  the top byte first
; travel 21 cells right
  >>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @015 to @055
  [-
; travel 64 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 64 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 64 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>
; halve it  leaving the quotient and this byte's low bit
  [->>>+<[-<+>>-<]>[-<+>]<<<]
; travel 4 cells right
  >>>>
; a bit carried in from the byte above becomes the top bit here
  [-
; travel 3 cells left
  <<<
; add 128
  ++++++++++++++++++++++++++++++++++++++++
  ++++++++++++++++++++++++++++++++++++++++
  ++++++++++++++++++++++++++++++++++++++++
  ++++++++
; travel 3 cells right
  >>>
  ]
; travel 3 cells left
  <<<
; move byte 0 of @056 to @015
  [-
; travel 65 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 65 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 1 cells right
  >
; move byte 0 of @057 to @059
  [-
; travel 2 cells right
  >>
  +
; travel 2 cells left
  <<
  ]
; travel 87 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<
; byte 3  the top byte first
; travel 20 cells right
  >>>>>>>>>>>>>>>>>>>>
; move byte 0 of @014 to @055
  [-
; travel 65 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 65 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 65 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>
; halve it  leaving the quotient and this byte's low bit
  [->>>+<[-<+>>-<]>[-<+>]<<<]
; travel 4 cells right
  >>>>
; a bit carried in from the byte above becomes the top bit here
  [-
; travel 3 cells left
  <<<
; add 128
  ++++++++++++++++++++++++++++++++++++++++
  ++++++++++++++++++++++++++++++++++++++++
  ++++++++++++++++++++++++++++++++++++++++
  ++++++++
; travel 3 cells right
  >>>
  ]
; travel 3 cells left
  <<<
; move byte 0 of @056 to @014
  [-
; travel 66 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 66 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 1 cells right
  >
; move byte 0 of @057 to @059
  [-
; travel 2 cells right
  >>
  +
; travel 2 cells left
  <<
  ]
; travel 87 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<
; byte 2  the top byte first
; travel 19 cells right
  >>>>>>>>>>>>>>>>>>>
; move byte 0 of @013 to @055
  [-
; travel 66 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 66 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 66 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>
; halve it  leaving the quotient and this byte's low bit
  [->>>+<[-<+>>-<]>[-<+>]<<<]
; travel 4 cells right
  >>>>
; a bit carried in from the byte above becomes the top bit here
  [-
; travel 3 cells left
  <<<
; add 128
  ++++++++++++++++++++++++++++++++++++++++
  ++++++++++++++++++++++++++++++++++++++++
  ++++++++++++++++++++++++++++++++++++++++
  ++++++++
; travel 3 cells right
  >>>
  ]
; travel 3 cells left
  <<<
; move byte 0 of @056 to @013
  [-
; travel 67 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 67 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 1 cells right
  >
; move byte 0 of @057 to @059
  [-
; travel 2 cells right
  >>
  +
; travel 2 cells left
  <<
  ]
; travel 87 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<
; byte 1  the top byte first
; travel 18 cells right
  >>>>>>>>>>>>>>>>>>
; move byte 0 of @012 to @055
  [-
; travel 67 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 67 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 67 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>
; halve it  leaving the quotient and this byte's low bit
  [->>>+<[-<+>>-<]>[-<+>]<<<]
; travel 4 cells right
  >>>>
; a bit carried in from the byte above becomes the top bit here
  [-
; travel 3 cells left
  <<<
; add 128
  ++++++++++++++++++++++++++++++++++++++++
  ++++++++++++++++++++++++++++++++++++++++
  ++++++++++++++++++++++++++++++++++++++++
  ++++++++
; travel 3 cells right
  >>>
  ]
; travel 3 cells left
  <<<
; move byte 0 of @056 to @012
  [-
; travel 68 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 68 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 1 cells right
  >
; move byte 0 of @057 to @059
  [-
; travel 2 cells right
  >>
  +
; travel 2 cells left
  <<
  ]
; travel 87 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<
; byte 0  the top byte first
; travel 17 cells right
  >>>>>>>>>>>>>>>>>
; move byte 0 of @011 to @055
  [-
; travel 68 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 68 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 68 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>
; halve it  leaving the quotient and this byte's low bit
  [->>>+<[-<+>>-<]>[-<+>]<<<]
; travel 4 cells right
  >>>>
; a bit carried in from the byte above becomes the top bit here
  [-
; travel 3 cells left
  <<<
; add 128
  ++++++++++++++++++++++++++++++++++++++++
  ++++++++++++++++++++++++++++++++++++++++
  ++++++++++++++++++++++++++++++++++++++++
  ++++++++
; travel 3 cells right
  >>>
  ]
; travel 3 cells left
  <<<
; move byte 0 of @056 to @011
  [-
; travel 69 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 69 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 1 cells right
  >
; move byte 0 of @057 to @059
  [-
; travel 2 cells right
  >>
  +
; travel 2 cells left
  <<
  ]
; travel 87 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<
; when the bit shifted out was set  add the running value into the product
; travel 89 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>
  [
  [-]
; travel 89 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; copy byte 0 of @022 to @044 and to a temp
  [-
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 29 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 63 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<
  ]>
; copy byte 1 of @023 to @045 and to a temp
  [-
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 29 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 63 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<
  ]>
; copy byte 2 of @024 to @046 and to a temp
  [-
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 29 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 63 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<
  ]>
; copy byte 3 of @025 to @047 and to a temp
  [-
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 29 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 63 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<
  ]>
; copy byte 4 of @026 to @048 and to a temp
  [-
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 29 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 63 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<
  ]>
; copy byte 5 of @027 to @049 and to a temp
  [-
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 29 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 63 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<
  ]>
; copy byte 6 of @028 to @04a and to a temp
  [-
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 29 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 63 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<
  ]>
; copy byte 7 of @029 to @04b and to a temp
  [-
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 29 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 63 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<
  ]>
; copy byte 8 of @02a to @04c and to a temp
  [-
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 29 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 63 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<
  ]>
; copy byte 9 of @02b to @04d and to a temp
  [-
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 29 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 63 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<
  ]>
; copy byte 10 of @02c to @04e and to a temp
  [-
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 29 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 63 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<
  ]>
; copy byte 11 of @02d to @04f and to a temp
  [-
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 29 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 63 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<
  ]>
; copy byte 12 of @02e to @050 and to a temp
  [-
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 29 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 63 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<
  ]>
; copy byte 13 of @02f to @051 and to a temp
  [-
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 29 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 63 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<
  ]>
; copy byte 14 of @030 to @052 and to a temp
  [-
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 29 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 63 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<
  ]>
; copy byte 15 of @031 to @053 and to a temp
  [-
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 29 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 63 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<
  ]>
; copy byte 16 of @032 to @054 and to a temp
  [-
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 29 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 63 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<
  ]
; walk to the temps
; travel 47 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>
; put temp byte 0 back into @022
  [-
; travel 63 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 63 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
  ]>
; put temp byte 1 back into @023
  [-
; travel 63 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 63 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
  ]>
; put temp byte 2 back into @024
  [-
; travel 63 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 63 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
  ]>
; put temp byte 3 back into @025
  [-
; travel 63 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 63 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
  ]>
; put temp byte 4 back into @026
  [-
; travel 63 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 63 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
  ]>
; put temp byte 5 back into @027
  [-
; travel 63 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 63 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
  ]>
; put temp byte 6 back into @028
  [-
; travel 63 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 63 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
  ]>
; put temp byte 7 back into @029
  [-
; travel 63 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 63 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
  ]>
; put temp byte 8 back into @02a
  [-
; travel 63 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 63 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
  ]>
; put temp byte 9 back into @02b
  [-
; travel 63 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 63 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
  ]>
; put temp byte 10 back into @02c
  [-
; travel 63 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 63 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
  ]>
; put temp byte 11 back into @02d
  [-
; travel 63 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 63 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
  ]>
; put temp byte 12 back into @02e
  [-
; travel 63 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 63 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
  ]>
; put temp byte 13 back into @02f
  [-
; travel 63 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 63 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
  ]>
; put temp byte 14 back into @030
  [-
; travel 63 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 63 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
  ]>
; put temp byte 15 back into @031
  [-
; travel 63 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 63 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
  ]>
; put temp byte 16 back into @032
  [-
; travel 63 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 63 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 113 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; ADD136 : @033 gets @044  little endian
; byte 0
; travel 51 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>
; move byte 0 of @033 to @05c
  [-
; travel 41 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >
  +
; travel 41 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <
  ]
; travel 17 cells right
  >>>>>>>>>>>>>>>>>
; move byte 0 of @044 to @05d
  [-
; travel 25 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 25 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 25 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>
; add the addend byte into the accumulator byte
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; travel 2 cells left
  <<
; move byte 0 of @05b to @05d
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
; move byte 0 of @05c to @033
  [-
; travel 41 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <
  +
; travel 41 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >
  ]
; travel 2 cells right
  >>
; move byte 0 of @05e to @05b
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 94 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; byte 1
; travel 52 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>
; move byte 0 of @034 to @05c
  [-
; travel 40 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 40 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 17 cells right
  >>>>>>>>>>>>>>>>>
; move byte 0 of @045 to @05d
  [-
; travel 24 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 24 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 24 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>
; add the addend byte into the accumulator byte
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; travel 2 cells left
  <<
; move byte 0 of @05b to @05d
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
; move byte 0 of @05c to @034
  [-
; travel 40 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 40 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @05e to @05b
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 94 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; byte 2
; travel 53 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>
; move byte 0 of @035 to @05c
  [-
; travel 39 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 39 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 17 cells right
  >>>>>>>>>>>>>>>>>
; move byte 0 of @046 to @05d
  [-
; travel 23 cells right
  >>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 23 cells left
  <<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 23 cells right
  >>>>>>>>>>>>>>>>>>>>>>>
; add the addend byte into the accumulator byte
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; travel 2 cells left
  <<
; move byte 0 of @05b to @05d
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
; move byte 0 of @05c to @035
  [-
; travel 39 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 39 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @05e to @05b
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 94 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; byte 3
; travel 54 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>
; move byte 0 of @036 to @05c
  [-
; travel 38 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 38 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 17 cells right
  >>>>>>>>>>>>>>>>>
; move byte 0 of @047 to @05d
  [-
; travel 22 cells right
  >>>>>>>>>>>>>>>>>>>>>>
  +
; travel 22 cells left
  <<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 22 cells right
  >>>>>>>>>>>>>>>>>>>>>>
; add the addend byte into the accumulator byte
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; travel 2 cells left
  <<
; move byte 0 of @05b to @05d
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
; move byte 0 of @05c to @036
  [-
; travel 38 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 38 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @05e to @05b
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 94 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; byte 4
; travel 55 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>
; move byte 0 of @037 to @05c
  [-
; travel 37 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 37 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 17 cells right
  >>>>>>>>>>>>>>>>>
; move byte 0 of @048 to @05d
  [-
; travel 21 cells right
  >>>>>>>>>>>>>>>>>>>>>
  +
; travel 21 cells left
  <<<<<<<<<<<<<<<<<<<<<
  ]
; travel 21 cells right
  >>>>>>>>>>>>>>>>>>>>>
; add the addend byte into the accumulator byte
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; travel 2 cells left
  <<
; move byte 0 of @05b to @05d
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
; move byte 0 of @05c to @037
  [-
; travel 37 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 37 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @05e to @05b
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 94 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; byte 5
; travel 56 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>
; move byte 0 of @038 to @05c
  [-
; travel 36 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 36 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 17 cells right
  >>>>>>>>>>>>>>>>>
; move byte 0 of @049 to @05d
  [-
; travel 20 cells right
  >>>>>>>>>>>>>>>>>>>>
  +
; travel 20 cells left
  <<<<<<<<<<<<<<<<<<<<
  ]
; travel 20 cells right
  >>>>>>>>>>>>>>>>>>>>
; add the addend byte into the accumulator byte
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; travel 2 cells left
  <<
; move byte 0 of @05b to @05d
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
; move byte 0 of @05c to @038
  [-
; travel 36 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 36 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @05e to @05b
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 94 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; byte 6
; travel 57 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>
; move byte 0 of @039 to @05c
  [-
; travel 35 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 35 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 17 cells right
  >>>>>>>>>>>>>>>>>
; move byte 0 of @04a to @05d
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
; move byte 0 of @05b to @05d
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
; move byte 0 of @05c to @039
  [-
; travel 35 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 35 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @05e to @05b
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 94 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; byte 7
; travel 58 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>
; move byte 0 of @03a to @05c
  [-
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 34 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 17 cells right
  >>>>>>>>>>>>>>>>>
; move byte 0 of @04b to @05d
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
; move byte 0 of @05b to @05d
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
; move byte 0 of @05c to @03a
  [-
; travel 34 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @05e to @05b
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 94 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; byte 8
; travel 59 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>
; move byte 0 of @03b to @05c
  [-
; travel 33 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 33 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 17 cells right
  >>>>>>>>>>>>>>>>>
; move byte 0 of @04c to @05d
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
; move byte 0 of @05b to @05d
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
; move byte 0 of @05c to @03b
  [-
; travel 33 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 33 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @05e to @05b
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 94 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; byte 9
; travel 60 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>
; move byte 0 of @03c to @05c
  [-
; travel 32 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 32 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 17 cells right
  >>>>>>>>>>>>>>>>>
; move byte 0 of @04d to @05d
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
; move byte 0 of @05b to @05d
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
; move byte 0 of @05c to @03c
  [-
; travel 32 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 32 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @05e to @05b
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 94 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; byte 10
; travel 61 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @03d to @05c
  [-
; travel 31 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 31 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 17 cells right
  >>>>>>>>>>>>>>>>>
; move byte 0 of @04e to @05d
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
; move byte 0 of @05b to @05d
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
; move byte 0 of @05c to @03d
  [-
; travel 31 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 31 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @05e to @05b
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 94 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; byte 11
; travel 62 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @03e to @05c
  [-
; travel 30 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 30 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 17 cells right
  >>>>>>>>>>>>>>>>>
; move byte 0 of @04f to @05d
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
; move byte 0 of @05b to @05d
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
; move byte 0 of @05c to @03e
  [-
; travel 30 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 30 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @05e to @05b
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 94 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; byte 12
; travel 63 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @03f to @05c
  [-
; travel 29 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 29 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 17 cells right
  >>>>>>>>>>>>>>>>>
; move byte 0 of @050 to @05d
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
; move byte 0 of @05b to @05d
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
; move byte 0 of @05c to @03f
  [-
; travel 29 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 29 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @05e to @05b
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 94 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; byte 13
; travel 64 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @040 to @05c
  [-
; travel 28 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 28 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 17 cells right
  >>>>>>>>>>>>>>>>>
; move byte 0 of @051 to @05d
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
; move byte 0 of @05b to @05d
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
; move byte 0 of @05c to @040
  [-
; travel 28 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 28 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @05e to @05b
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 94 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; byte 14
; travel 65 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @041 to @05c
  [-
; travel 27 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 27 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 17 cells right
  >>>>>>>>>>>>>>>>>
; move byte 0 of @052 to @05d
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
; move byte 0 of @05b to @05d
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
; move byte 0 of @05c to @041
  [-
; travel 27 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 27 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @05e to @05b
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 94 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; byte 15
; travel 66 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @042 to @05c
  [-
; travel 26 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 26 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 17 cells right
  >>>>>>>>>>>>>>>>>
; move byte 0 of @053 to @05d
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
; move byte 0 of @05b to @05d
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
; move byte 0 of @05c to @042
  [-
; travel 26 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 26 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @05e to @05b
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 94 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; byte 16
; travel 67 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @043 to @05c
  [-
; travel 25 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 25 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 17 cells right
  >>>>>>>>>>>>>>>>>
; move byte 0 of @054 to @05d
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
; move byte 0 of @05b to @05d
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
; move byte 0 of @05c to @043
  [-
; travel 25 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 25 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @05e to @05b
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 94 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; drop the carry out of the top byte
; travel 91 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>
  [-]
; travel 91 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<
; FOLD : reduce using 2^130 = 5 modulo p
; the split is at bit 130  which is the top byte shifted right two
; travel 67 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @043 to @089
  [-
; travel 70 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 70 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 70 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; first halving  the low bit here is bit 128
  [->>>+<[-<+>>-<]>[-<+>]<<<]
; travel 2 cells right
  >>
; move byte 0 of @08b to @08e
  [-
; travel 3 cells right
  >>>
  +
; travel 3 cells left
  <<<
  ]
; travel 1 cells left
  <
; move byte 0 of @08a to @089
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
; move byte 0 of @08b to @08f
  [-
; travel 4 cells right
  >>>>
  +
; travel 4 cells left
  <<<<
  ]
; travel 1 cells left
  <
; move byte 0 of @08a to @090
  [-
; travel 6 cells right
  >>>>>>
  +
; travel 6 cells left
  <<<<<<
  ]
; travel 138 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<
; the top byte keeps only bits 128 and 129
; travel 142 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @08e to @043
  [-
; travel 75 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 75 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 1 cells right
  >
; bit 129 is worth two in the top byte
  [-
; travel 76 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ++
; travel 76 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 143 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<
; build 5H by adding H to a two byte buffer five times
; travel 144 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>
; copy byte 0 of @090 to @091 and to a temp
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
; put temp byte 0 back into @090
  [-
; travel 9 cells left
  <<<<<<<<<
  +
; travel 9 cells right
  >>>>>>>>>
  ]
; travel 153 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; ADD16 : @072 gets @091  little endian
; byte 0
; travel 114 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @072 to @094
  [-
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 34 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 31 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @091 to @095
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
; move byte 0 of @093 to @095
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
; move byte 0 of @094 to @072
  [-
; travel 34 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @096 to @093
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 150 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; byte 1
; travel 115 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @073 to @094
  [-
; travel 33 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 33 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 31 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @092 to @095
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
; move byte 0 of @093 to @095
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
; move byte 0 of @094 to @073
  [-
; travel 33 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 33 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @096 to @093
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 150 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; drop the carry out of the top byte
; travel 147 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>
  [-]
; travel 147 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<
; travel 144 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>
; copy byte 0 of @090 to @091 and to a temp
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
; put temp byte 0 back into @090
  [-
; travel 9 cells left
  <<<<<<<<<
  +
; travel 9 cells right
  >>>>>>>>>
  ]
; travel 153 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; ADD16 : @072 gets @091  little endian
; byte 0
; travel 114 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @072 to @094
  [-
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 34 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 31 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @091 to @095
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
; move byte 0 of @093 to @095
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
; move byte 0 of @094 to @072
  [-
; travel 34 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @096 to @093
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 150 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; byte 1
; travel 115 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @073 to @094
  [-
; travel 33 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 33 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 31 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @092 to @095
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
; move byte 0 of @093 to @095
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
; move byte 0 of @094 to @073
  [-
; travel 33 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 33 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @096 to @093
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 150 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; drop the carry out of the top byte
; travel 147 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>
  [-]
; travel 147 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<
; travel 144 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>
; copy byte 0 of @090 to @091 and to a temp
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
; put temp byte 0 back into @090
  [-
; travel 9 cells left
  <<<<<<<<<
  +
; travel 9 cells right
  >>>>>>>>>
  ]
; travel 153 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; ADD16 : @072 gets @091  little endian
; byte 0
; travel 114 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @072 to @094
  [-
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 34 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 31 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @091 to @095
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
; move byte 0 of @093 to @095
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
; move byte 0 of @094 to @072
  [-
; travel 34 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @096 to @093
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 150 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; byte 1
; travel 115 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @073 to @094
  [-
; travel 33 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 33 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 31 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @092 to @095
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
; move byte 0 of @093 to @095
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
; move byte 0 of @094 to @073
  [-
; travel 33 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 33 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @096 to @093
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 150 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; drop the carry out of the top byte
; travel 147 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>
  [-]
; travel 147 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<
; travel 144 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>
; copy byte 0 of @090 to @091 and to a temp
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
; put temp byte 0 back into @090
  [-
; travel 9 cells left
  <<<<<<<<<
  +
; travel 9 cells right
  >>>>>>>>>
  ]
; travel 153 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; ADD16 : @072 gets @091  little endian
; byte 0
; travel 114 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @072 to @094
  [-
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 34 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 31 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @091 to @095
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
; move byte 0 of @093 to @095
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
; move byte 0 of @094 to @072
  [-
; travel 34 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @096 to @093
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 150 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; byte 1
; travel 115 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @073 to @094
  [-
; travel 33 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 33 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 31 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @092 to @095
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
; move byte 0 of @093 to @095
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
; move byte 0 of @094 to @073
  [-
; travel 33 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 33 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @096 to @093
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 150 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; drop the carry out of the top byte
; travel 147 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>
  [-]
; travel 147 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<
; travel 144 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>
; copy byte 0 of @090 to @091 and to a temp
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
; put temp byte 0 back into @090
  [-
; travel 9 cells left
  <<<<<<<<<
  +
; travel 9 cells right
  >>>>>>>>>
  ]
; travel 153 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; ADD16 : @072 gets @091  little endian
; byte 0
; travel 114 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @072 to @094
  [-
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 34 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 31 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @091 to @095
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
; move byte 0 of @093 to @095
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
; move byte 0 of @094 to @072
  [-
; travel 34 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @096 to @093
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 150 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; byte 1
; travel 115 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @073 to @094
  [-
; travel 33 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 33 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 31 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @092 to @095
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
; move byte 0 of @093 to @095
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
; move byte 0 of @094 to @073
  [-
; travel 33 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 33 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @096 to @093
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 150 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; drop the carry out of the top byte
; travel 147 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>
  [-]
; travel 147 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<
; discard H now that 5H is built
; travel 144 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>
  [-]
; travel 144 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<
; add 5H back into the value
; ADD136 : @033 gets @072  little endian
; byte 0
; travel 51 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>
; move byte 0 of @033 to @084
  [-
; travel 81 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >
  +
; travel 81 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <
  ]
; travel 63 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @072 to @085
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
; move byte 0 of @083 to @085
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
; move byte 0 of @084 to @033
  [-
; travel 81 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <
  +
; travel 81 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >
  ]
; travel 2 cells right
  >>
; move byte 0 of @086 to @083
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 134 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; byte 1
; travel 52 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>
; move byte 0 of @034 to @084
  [-
; travel 80 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 80 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 63 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @073 to @085
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
; move byte 0 of @083 to @085
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
; move byte 0 of @084 to @034
  [-
; travel 80 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 80 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @086 to @083
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 134 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; byte 2
; travel 53 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>
; move byte 0 of @035 to @084
  [-
; travel 79 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 79 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 63 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @074 to @085
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
; move byte 0 of @083 to @085
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
; move byte 0 of @084 to @035
  [-
; travel 79 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 79 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @086 to @083
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 134 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; byte 3
; travel 54 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>
; move byte 0 of @036 to @084
  [-
; travel 78 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 78 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 63 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @075 to @085
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
; move byte 0 of @083 to @085
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
; move byte 0 of @084 to @036
  [-
; travel 78 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 78 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @086 to @083
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 134 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; byte 4
; travel 55 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>
; move byte 0 of @037 to @084
  [-
; travel 77 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 77 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 63 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @076 to @085
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
; move byte 0 of @083 to @085
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
; move byte 0 of @084 to @037
  [-
; travel 77 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 77 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @086 to @083
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 134 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; byte 5
; travel 56 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>
; move byte 0 of @038 to @084
  [-
; travel 76 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 76 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 63 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @077 to @085
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
; move byte 0 of @083 to @085
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
; move byte 0 of @084 to @038
  [-
; travel 76 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 76 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @086 to @083
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 134 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; byte 6
; travel 57 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>
; move byte 0 of @039 to @084
  [-
; travel 75 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 75 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 63 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @078 to @085
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
; move byte 0 of @083 to @085
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
; move byte 0 of @084 to @039
  [-
; travel 75 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 75 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @086 to @083
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 134 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; byte 7
; travel 58 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>
; move byte 0 of @03a to @084
  [-
; travel 74 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 74 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 63 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @079 to @085
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
; move byte 0 of @083 to @085
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
; move byte 0 of @084 to @03a
  [-
; travel 74 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 74 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @086 to @083
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 134 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; byte 8
; travel 59 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>
; move byte 0 of @03b to @084
  [-
; travel 73 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 73 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 63 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @07a to @085
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
; move byte 0 of @083 to @085
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
; move byte 0 of @084 to @03b
  [-
; travel 73 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 73 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @086 to @083
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 134 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; byte 9
; travel 60 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>
; move byte 0 of @03c to @084
  [-
; travel 72 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 72 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 63 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @07b to @085
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
; move byte 0 of @083 to @085
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
; move byte 0 of @084 to @03c
  [-
; travel 72 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 72 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @086 to @083
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 134 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; byte 10
; travel 61 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @03d to @084
  [-
; travel 71 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 71 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 63 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @07c to @085
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
; move byte 0 of @083 to @085
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
; move byte 0 of @084 to @03d
  [-
; travel 71 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 71 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @086 to @083
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 134 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; byte 11
; travel 62 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @03e to @084
  [-
; travel 70 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 70 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 63 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @07d to @085
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
; move byte 0 of @083 to @085
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
; move byte 0 of @084 to @03e
  [-
; travel 70 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 70 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @086 to @083
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 134 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; byte 12
; travel 63 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @03f to @084
  [-
; travel 69 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 69 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 63 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @07e to @085
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
; move byte 0 of @083 to @085
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
; move byte 0 of @084 to @03f
  [-
; travel 69 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 69 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @086 to @083
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 134 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; byte 13
; travel 64 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @040 to @084
  [-
; travel 68 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 68 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 63 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @07f to @085
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
; move byte 0 of @083 to @085
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
; move byte 0 of @084 to @040
  [-
; travel 68 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 68 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @086 to @083
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 134 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; byte 14
; travel 65 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @041 to @084
  [-
; travel 67 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 67 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 63 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @080 to @085
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
; move byte 0 of @083 to @085
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
; move byte 0 of @084 to @041
  [-
; travel 67 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 67 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @086 to @083
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 134 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; byte 15
; travel 66 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @042 to @084
  [-
; travel 66 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 66 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 63 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @081 to @085
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
; move byte 0 of @083 to @085
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
; move byte 0 of @084 to @042
  [-
; travel 66 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 66 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @086 to @083
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 134 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; byte 16
; travel 67 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @043 to @084
  [-
; travel 65 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 65 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 63 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @082 to @085
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
; move byte 0 of @083 to @085
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
; move byte 0 of @084 to @043
  [-
; travel 65 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 65 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @086 to @083
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 134 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; drop the carry out of the top byte
; travel 131 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>
  [-]
; travel 131 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<
; travel 89 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>
  ]
; travel 89 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<
; double the running value for the next bit  then fold it back down
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; copy byte 0 of @022 to @044 and to a temp
  [-
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 29 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 63 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<
  ]>
; copy byte 1 of @023 to @045 and to a temp
  [-
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 29 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 63 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<
  ]>
; copy byte 2 of @024 to @046 and to a temp
  [-
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 29 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 63 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<
  ]>
; copy byte 3 of @025 to @047 and to a temp
  [-
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 29 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 63 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<
  ]>
; copy byte 4 of @026 to @048 and to a temp
  [-
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 29 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 63 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<
  ]>
; copy byte 5 of @027 to @049 and to a temp
  [-
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 29 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 63 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<
  ]>
; copy byte 6 of @028 to @04a and to a temp
  [-
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 29 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 63 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<
  ]>
; copy byte 7 of @029 to @04b and to a temp
  [-
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 29 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 63 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<
  ]>
; copy byte 8 of @02a to @04c and to a temp
  [-
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 29 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 63 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<
  ]>
; copy byte 9 of @02b to @04d and to a temp
  [-
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 29 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 63 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<
  ]>
; copy byte 10 of @02c to @04e and to a temp
  [-
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 29 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 63 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<
  ]>
; copy byte 11 of @02d to @04f and to a temp
  [-
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 29 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 63 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<
  ]>
; copy byte 12 of @02e to @050 and to a temp
  [-
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 29 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 63 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<
  ]>
; copy byte 13 of @02f to @051 and to a temp
  [-
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 29 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 63 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<
  ]>
; copy byte 14 of @030 to @052 and to a temp
  [-
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 29 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 63 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<
  ]>
; copy byte 15 of @031 to @053 and to a temp
  [-
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 29 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 63 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<
  ]>
; copy byte 16 of @032 to @054 and to a temp
  [-
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 29 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 63 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<
  ]
; walk to the temps
; travel 47 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>
; put temp byte 0 back into @022
  [-
; travel 63 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 63 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
  ]>
; put temp byte 1 back into @023
  [-
; travel 63 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 63 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
  ]>
; put temp byte 2 back into @024
  [-
; travel 63 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 63 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
  ]>
; put temp byte 3 back into @025
  [-
; travel 63 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 63 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
  ]>
; put temp byte 4 back into @026
  [-
; travel 63 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 63 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
  ]>
; put temp byte 5 back into @027
  [-
; travel 63 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 63 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
  ]>
; put temp byte 6 back into @028
  [-
; travel 63 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 63 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
  ]>
; put temp byte 7 back into @029
  [-
; travel 63 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 63 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
  ]>
; put temp byte 8 back into @02a
  [-
; travel 63 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 63 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
  ]>
; put temp byte 9 back into @02b
  [-
; travel 63 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 63 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
  ]>
; put temp byte 10 back into @02c
  [-
; travel 63 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 63 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
  ]>
; put temp byte 11 back into @02d
  [-
; travel 63 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 63 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
  ]>
; put temp byte 12 back into @02e
  [-
; travel 63 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 63 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
  ]>
; put temp byte 13 back into @02f
  [-
; travel 63 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 63 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
  ]>
; put temp byte 14 back into @030
  [-
; travel 63 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 63 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
  ]>
; put temp byte 15 back into @031
  [-
; travel 63 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 63 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
  ]>
; put temp byte 16 back into @032
  [-
; travel 63 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 63 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 113 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; ADD136 : @022 gets @044  little endian
; byte 0
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @022 to @05c
  [-
; travel 58 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>
  +
; travel 58 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<
  ]
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @044 to @05d
  [-
; travel 25 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 25 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 25 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>
; add the addend byte into the accumulator byte
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; travel 2 cells left
  <<
; move byte 0 of @05b to @05d
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
; move byte 0 of @05c to @022
  [-
; travel 58 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<
  +
; travel 58 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @05e to @05b
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 94 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; byte 1
; travel 35 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @023 to @05c
  [-
; travel 57 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>
  +
; travel 57 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<
  ]
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @045 to @05d
  [-
; travel 24 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 24 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 24 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>
; add the addend byte into the accumulator byte
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; travel 2 cells left
  <<
; move byte 0 of @05b to @05d
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
; move byte 0 of @05c to @023
  [-
; travel 57 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<
  +
; travel 57 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @05e to @05b
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 94 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; byte 2
; travel 36 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @024 to @05c
  [-
; travel 56 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>
  +
; travel 56 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<
  ]
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @046 to @05d
  [-
; travel 23 cells right
  >>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 23 cells left
  <<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 23 cells right
  >>>>>>>>>>>>>>>>>>>>>>>
; add the addend byte into the accumulator byte
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; travel 2 cells left
  <<
; move byte 0 of @05b to @05d
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
; move byte 0 of @05c to @024
  [-
; travel 56 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<
  +
; travel 56 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @05e to @05b
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 94 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; byte 3
; travel 37 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @025 to @05c
  [-
; travel 55 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>
  +
; travel 55 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<
  ]
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @047 to @05d
  [-
; travel 22 cells right
  >>>>>>>>>>>>>>>>>>>>>>
  +
; travel 22 cells left
  <<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 22 cells right
  >>>>>>>>>>>>>>>>>>>>>>
; add the addend byte into the accumulator byte
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; travel 2 cells left
  <<
; move byte 0 of @05b to @05d
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
; move byte 0 of @05c to @025
  [-
; travel 55 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<
  +
; travel 55 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @05e to @05b
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 94 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; byte 4
; travel 38 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @026 to @05c
  [-
; travel 54 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>
  +
; travel 54 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
  ]
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @048 to @05d
  [-
; travel 21 cells right
  >>>>>>>>>>>>>>>>>>>>>
  +
; travel 21 cells left
  <<<<<<<<<<<<<<<<<<<<<
  ]
; travel 21 cells right
  >>>>>>>>>>>>>>>>>>>>>
; add the addend byte into the accumulator byte
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; travel 2 cells left
  <<
; move byte 0 of @05b to @05d
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
; move byte 0 of @05c to @026
  [-
; travel 54 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
  +
; travel 54 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @05e to @05b
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 94 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; byte 5
; travel 39 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @027 to @05c
  [-
; travel 53 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>
  +
; travel 53 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<
  ]
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @049 to @05d
  [-
; travel 20 cells right
  >>>>>>>>>>>>>>>>>>>>
  +
; travel 20 cells left
  <<<<<<<<<<<<<<<<<<<<
  ]
; travel 20 cells right
  >>>>>>>>>>>>>>>>>>>>
; add the addend byte into the accumulator byte
  [-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
; travel 2 cells left
  <<
; move byte 0 of @05b to @05d
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
; move byte 0 of @05c to @027
  [-
; travel 53 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<
  +
; travel 53 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @05e to @05b
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 94 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; byte 6
; travel 40 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @028 to @05c
  [-
; travel 52 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>
  +
; travel 52 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<
  ]
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @04a to @05d
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
; move byte 0 of @05b to @05d
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
; move byte 0 of @05c to @028
  [-
; travel 52 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<
  +
; travel 52 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @05e to @05b
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 94 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; byte 7
; travel 41 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >
; move byte 0 of @029 to @05c
  [-
; travel 51 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>
  +
; travel 51 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<
  ]
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @04b to @05d
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
; move byte 0 of @05b to @05d
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
; move byte 0 of @05c to @029
  [-
; travel 51 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<
  +
; travel 51 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @05e to @05b
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 94 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; byte 8
; travel 42 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>
; move byte 0 of @02a to @05c
  [-
; travel 50 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>
  +
; travel 50 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<
  ]
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @04c to @05d
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
; move byte 0 of @05b to @05d
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
; move byte 0 of @05c to @02a
  [-
; travel 50 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<
  +
; travel 50 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @05e to @05b
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 94 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; byte 9
; travel 43 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>
; move byte 0 of @02b to @05c
  [-
; travel 49 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>
  +
; travel 49 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<
  ]
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @04d to @05d
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
; move byte 0 of @05b to @05d
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
; move byte 0 of @05c to @02b
  [-
; travel 49 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<
  +
; travel 49 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @05e to @05b
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 94 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; byte 10
; travel 44 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>
; move byte 0 of @02c to @05c
  [-
; travel 48 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>
  +
; travel 48 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<
  ]
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @04e to @05d
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
; move byte 0 of @05b to @05d
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
; move byte 0 of @05c to @02c
  [-
; travel 48 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<
  +
; travel 48 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @05e to @05b
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 94 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; byte 11
; travel 45 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>
; move byte 0 of @02d to @05c
  [-
; travel 47 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>
  +
; travel 47 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<
  ]
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @04f to @05d
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
; move byte 0 of @05b to @05d
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
; move byte 0 of @05c to @02d
  [-
; travel 47 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<
  +
; travel 47 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @05e to @05b
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 94 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; byte 12
; travel 46 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>
; move byte 0 of @02e to @05c
  [-
; travel 46 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>
  +
; travel 46 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<
  ]
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @050 to @05d
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
; move byte 0 of @05b to @05d
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
; move byte 0 of @05c to @02e
  [-
; travel 46 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<
  +
; travel 46 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @05e to @05b
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 94 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; byte 13
; travel 47 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>
; move byte 0 of @02f to @05c
  [-
; travel 45 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>
  +
; travel 45 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<
  ]
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @051 to @05d
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
; move byte 0 of @05b to @05d
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
; move byte 0 of @05c to @02f
  [-
; travel 45 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<
  +
; travel 45 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @05e to @05b
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 94 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; byte 14
; travel 48 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>
; move byte 0 of @030 to @05c
  [-
; travel 44 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>
  +
; travel 44 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<
  ]
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @052 to @05d
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
; move byte 0 of @05b to @05d
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
; move byte 0 of @05c to @030
  [-
; travel 44 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<
  +
; travel 44 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @05e to @05b
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 94 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; byte 15
; travel 49 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>
; move byte 0 of @031 to @05c
  [-
; travel 43 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>
  +
; travel 43 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<
  ]
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @053 to @05d
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
; move byte 0 of @05b to @05d
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
; move byte 0 of @05c to @031
  [-
; travel 43 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<
  +
; travel 43 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @05e to @05b
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 94 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; byte 16
; travel 50 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>
; move byte 0 of @032 to @05c
  [-
; travel 42 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>
  +
; travel 42 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<
  ]
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @054 to @05d
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
; move byte 0 of @05b to @05d
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
; move byte 0 of @05c to @032
  [-
; travel 42 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<
  +
; travel 42 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>
  ]
; travel 2 cells right
  >>
; move byte 0 of @05e to @05b
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 94 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; drop the carry out of the top byte
; travel 91 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>
  [-]
; travel 91 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<
; FOLD : reduce using 2^130 = 5 modulo p
; the split is at bit 130  which is the top byte shifted right two
; travel 50 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>
; move byte 0 of @032 to @089
  [-
; travel 87 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>
  +
; travel 87 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<
  ]
; travel 87 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>
; first halving  the low bit here is bit 128
  [->>>+<[-<+>>-<]>[-<+>]<<<]
; travel 2 cells right
  >>
; move byte 0 of @08b to @08e
  [-
; travel 3 cells right
  >>>
  +
; travel 3 cells left
  <<<
  ]
; travel 1 cells left
  <
; move byte 0 of @08a to @089
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
; move byte 0 of @08b to @08f
  [-
; travel 4 cells right
  >>>>
  +
; travel 4 cells left
  <<<<
  ]
; travel 1 cells left
  <
; move byte 0 of @08a to @090
  [-
; travel 6 cells right
  >>>>>>
  +
; travel 6 cells left
  <<<<<<
  ]
; travel 138 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<
; the top byte keeps only bits 128 and 129
; travel 142 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @08e to @032
  [-
; travel 92 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<
  +
; travel 92 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>
  ]
; travel 1 cells right
  >
; bit 129 is worth two in the top byte
  [-
; travel 93 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<
  ++
; travel 93 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>
  ]
; travel 143 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<
; build 5H by adding H to a two byte buffer five times
; travel 144 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>
; copy byte 0 of @090 to @091 and to a temp
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
; put temp byte 0 back into @090
  [-
; travel 9 cells left
  <<<<<<<<<
  +
; travel 9 cells right
  >>>>>>>>>
  ]
; travel 153 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; ADD16 : @072 gets @091  little endian
; byte 0
; travel 114 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @072 to @094
  [-
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 34 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 31 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @091 to @095
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
; move byte 0 of @093 to @095
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
; move byte 0 of @094 to @072
  [-
; travel 34 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @096 to @093
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 150 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; byte 1
; travel 115 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @073 to @094
  [-
; travel 33 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 33 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 31 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @092 to @095
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
; move byte 0 of @093 to @095
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
; move byte 0 of @094 to @073
  [-
; travel 33 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 33 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @096 to @093
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 150 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; drop the carry out of the top byte
; travel 147 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>
  [-]
; travel 147 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<
; travel 144 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>
; copy byte 0 of @090 to @091 and to a temp
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
; put temp byte 0 back into @090
  [-
; travel 9 cells left
  <<<<<<<<<
  +
; travel 9 cells right
  >>>>>>>>>
  ]
; travel 153 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; ADD16 : @072 gets @091  little endian
; byte 0
; travel 114 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @072 to @094
  [-
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 34 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 31 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @091 to @095
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
; move byte 0 of @093 to @095
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
; move byte 0 of @094 to @072
  [-
; travel 34 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @096 to @093
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 150 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; byte 1
; travel 115 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @073 to @094
  [-
; travel 33 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 33 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 31 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @092 to @095
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
; move byte 0 of @093 to @095
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
; move byte 0 of @094 to @073
  [-
; travel 33 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 33 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @096 to @093
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 150 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; drop the carry out of the top byte
; travel 147 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>
  [-]
; travel 147 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<
; travel 144 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>
; copy byte 0 of @090 to @091 and to a temp
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
; put temp byte 0 back into @090
  [-
; travel 9 cells left
  <<<<<<<<<
  +
; travel 9 cells right
  >>>>>>>>>
  ]
; travel 153 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; ADD16 : @072 gets @091  little endian
; byte 0
; travel 114 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @072 to @094
  [-
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 34 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 31 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @091 to @095
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
; move byte 0 of @093 to @095
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
; move byte 0 of @094 to @072
  [-
; travel 34 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @096 to @093
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 150 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; byte 1
; travel 115 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @073 to @094
  [-
; travel 33 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 33 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 31 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @092 to @095
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
; move byte 0 of @093 to @095
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
; move byte 0 of @094 to @073
  [-
; travel 33 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 33 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @096 to @093
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 150 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; drop the carry out of the top byte
; travel 147 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>
  [-]
; travel 147 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<
; travel 144 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>
; copy byte 0 of @090 to @091 and to a temp
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
; put temp byte 0 back into @090
  [-
; travel 9 cells left
  <<<<<<<<<
  +
; travel 9 cells right
  >>>>>>>>>
  ]
; travel 153 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; ADD16 : @072 gets @091  little endian
; byte 0
; travel 114 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @072 to @094
  [-
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 34 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 31 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @091 to @095
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
; move byte 0 of @093 to @095
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
; move byte 0 of @094 to @072
  [-
; travel 34 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @096 to @093
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 150 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; byte 1
; travel 115 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @073 to @094
  [-
; travel 33 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 33 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 31 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @092 to @095
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
; move byte 0 of @093 to @095
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
; move byte 0 of @094 to @073
  [-
; travel 33 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 33 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @096 to @093
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 150 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; drop the carry out of the top byte
; travel 147 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>
  [-]
; travel 147 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<
; travel 144 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>
; copy byte 0 of @090 to @091 and to a temp
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
; put temp byte 0 back into @090
  [-
; travel 9 cells left
  <<<<<<<<<
  +
; travel 9 cells right
  >>>>>>>>>
  ]
; travel 153 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; ADD16 : @072 gets @091  little endian
; byte 0
; travel 114 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @072 to @094
  [-
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 34 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 31 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @091 to @095
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
; move byte 0 of @093 to @095
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
; move byte 0 of @094 to @072
  [-
; travel 34 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @096 to @093
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 150 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; byte 1
; travel 115 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @073 to @094
  [-
; travel 33 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 33 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 31 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @092 to @095
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
; move byte 0 of @093 to @095
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
; move byte 0 of @094 to @073
  [-
; travel 33 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 33 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @096 to @093
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 150 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; drop the carry out of the top byte
; travel 147 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>
  [-]
; travel 147 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<
; discard H now that 5H is built
; travel 144 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>
  [-]
; travel 144 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<
; add 5H back into the value
; ADD136 : @022 gets @072  little endian
; byte 0
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @022 to @084
  [-
; travel 98 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>
  +
; travel 98 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<
  ]
; travel 80 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @072 to @085
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
; move byte 0 of @083 to @085
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
; move byte 0 of @084 to @022
  [-
; travel 98 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<
  +
; travel 98 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @086 to @083
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 134 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; byte 1
; travel 35 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @023 to @084
  [-
; travel 97 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>
  +
; travel 97 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<
  ]
; travel 80 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @073 to @085
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
; move byte 0 of @083 to @085
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
; move byte 0 of @084 to @023
  [-
; travel 97 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<
  +
; travel 97 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @086 to @083
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 134 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; byte 2
; travel 36 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @024 to @084
  [-
; travel 96 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>
  +
; travel 96 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<
  ]
; travel 80 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @074 to @085
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
; move byte 0 of @083 to @085
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
; move byte 0 of @084 to @024
  [-
; travel 96 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<
  +
; travel 96 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @086 to @083
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 134 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; byte 3
; travel 37 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @025 to @084
  [-
; travel 95 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>
  +
; travel 95 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<
  ]
; travel 80 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @075 to @085
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
; move byte 0 of @083 to @085
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
; move byte 0 of @084 to @025
  [-
; travel 95 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<
  +
; travel 95 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @086 to @083
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 134 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; byte 4
; travel 38 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @026 to @084
  [-
; travel 94 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>
  +
; travel 94 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
  ]
; travel 80 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @076 to @085
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
; move byte 0 of @083 to @085
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
; move byte 0 of @084 to @026
  [-
; travel 94 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
  +
; travel 94 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @086 to @083
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 134 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; byte 5
; travel 39 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @027 to @084
  [-
; travel 93 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>
  +
; travel 93 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<
  ]
; travel 80 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @077 to @085
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
; move byte 0 of @083 to @085
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
; move byte 0 of @084 to @027
  [-
; travel 93 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<
  +
; travel 93 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @086 to @083
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 134 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; byte 6
; travel 40 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @028 to @084
  [-
; travel 92 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>
  +
; travel 92 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<
  ]
; travel 80 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @078 to @085
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
; move byte 0 of @083 to @085
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
; move byte 0 of @084 to @028
  [-
; travel 92 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<
  +
; travel 92 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @086 to @083
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 134 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; byte 7
; travel 41 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >
; move byte 0 of @029 to @084
  [-
; travel 91 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>
  +
; travel 91 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<
  ]
; travel 80 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @079 to @085
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
; move byte 0 of @083 to @085
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
; move byte 0 of @084 to @029
  [-
; travel 91 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<
  +
; travel 91 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @086 to @083
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 134 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; byte 8
; travel 42 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>
; move byte 0 of @02a to @084
  [-
; travel 90 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>
  +
; travel 90 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<
  ]
; travel 80 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @07a to @085
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
; move byte 0 of @083 to @085
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
; move byte 0 of @084 to @02a
  [-
; travel 90 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<
  +
; travel 90 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @086 to @083
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 134 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; byte 9
; travel 43 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>
; move byte 0 of @02b to @084
  [-
; travel 89 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>
  +
; travel 89 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<
  ]
; travel 80 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @07b to @085
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
; move byte 0 of @083 to @085
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
; move byte 0 of @084 to @02b
  [-
; travel 89 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<
  +
; travel 89 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @086 to @083
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 134 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; byte 10
; travel 44 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>
; move byte 0 of @02c to @084
  [-
; travel 88 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>
  +
; travel 88 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<
  ]
; travel 80 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @07c to @085
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
; move byte 0 of @083 to @085
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
; move byte 0 of @084 to @02c
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
; travel 2 cells right
  >>
; move byte 0 of @086 to @083
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 134 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; byte 11
; travel 45 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>
; move byte 0 of @02d to @084
  [-
; travel 87 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>
  +
; travel 87 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<
  ]
; travel 80 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @07d to @085
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
; move byte 0 of @083 to @085
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
; move byte 0 of @084 to @02d
  [-
; travel 87 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<
  +
; travel 87 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @086 to @083
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 134 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; byte 12
; travel 46 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>
; move byte 0 of @02e to @084
  [-
; travel 86 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>
  +
; travel 86 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<
  ]
; travel 80 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @07e to @085
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
; move byte 0 of @083 to @085
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
; move byte 0 of @084 to @02e
  [-
; travel 86 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<
  +
; travel 86 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @086 to @083
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 134 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; byte 13
; travel 47 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>
; move byte 0 of @02f to @084
  [-
; travel 85 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>
  +
; travel 85 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<
  ]
; travel 80 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @07f to @085
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
; move byte 0 of @083 to @085
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
; move byte 0 of @084 to @02f
  [-
; travel 85 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<
  +
; travel 85 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @086 to @083
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 134 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; byte 14
; travel 48 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>
; move byte 0 of @030 to @084
  [-
; travel 84 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>
  +
; travel 84 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<
  ]
; travel 80 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @080 to @085
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
; move byte 0 of @083 to @085
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
; move byte 0 of @084 to @030
  [-
; travel 84 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<
  +
; travel 84 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @086 to @083
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 134 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; byte 15
; travel 49 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>
; move byte 0 of @031 to @084
  [-
; travel 83 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>
  +
; travel 83 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<
  ]
; travel 80 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @081 to @085
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
; move byte 0 of @083 to @085
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
; move byte 0 of @084 to @031
  [-
; travel 83 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<
  +
; travel 83 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @086 to @083
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 134 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; byte 16
; travel 50 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>
; move byte 0 of @032 to @084
  [-
; travel 82 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>
  +
; travel 82 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<
  ]
; travel 80 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @082 to @085
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
; move byte 0 of @083 to @085
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
; move byte 0 of @084 to @032
  [-
; travel 82 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<
  +
; travel 82 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>
  ]
; travel 2 cells right
  >>
; move byte 0 of @086 to @083
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 134 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; drop the carry out of the top byte
; travel 131 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>
  [-]
; travel 131 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<
; travel 90 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>
  ]
; travel 90 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<
; the running value is spent  discard it
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  [-]
; travel 34 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; travel 35 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  [-]
; travel 35 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; travel 36 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  [-]
; travel 36 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; travel 37 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  [-]
; travel 37 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; travel 38 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  [-]
; travel 38 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; travel 39 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  [-]
; travel 39 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; travel 40 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  [-]
; travel 40 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; travel 41 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >
  [-]
; travel 41 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <
; travel 42 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>
  [-]
; travel 42 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<
; travel 43 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>
  [-]
; travel 43 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<
; travel 44 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>
  [-]
; travel 44 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<
; travel 45 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>
  [-]
; travel 45 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<
; travel 46 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>
  [-]
; travel 46 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<
; travel 47 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>
  [-]
; travel 47 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<
; travel 48 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>
  [-]
; travel 48 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<
; travel 49 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>
  [-]
; travel 49 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<
; travel 50 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>
  [-]
; travel 50 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<
; only now does the product need to be least  not merely congruent
; REDUCE : bring the value below p = 2^130 minus 5
; FOLD : reduce using 2^130 = 5 modulo p
; the split is at bit 130  which is the top byte shifted right two
; travel 67 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @043 to @089
  [-
; travel 70 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 70 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 70 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; first halving  the low bit here is bit 128
  [->>>+<[-<+>>-<]>[-<+>]<<<]
; travel 2 cells right
  >>
; move byte 0 of @08b to @08e
  [-
; travel 3 cells right
  >>>
  +
; travel 3 cells left
  <<<
  ]
; travel 1 cells left
  <
; move byte 0 of @08a to @089
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
; move byte 0 of @08b to @08f
  [-
; travel 4 cells right
  >>>>
  +
; travel 4 cells left
  <<<<
  ]
; travel 1 cells left
  <
; move byte 0 of @08a to @090
  [-
; travel 6 cells right
  >>>>>>
  +
; travel 6 cells left
  <<<<<<
  ]
; travel 138 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<
; the top byte keeps only bits 128 and 129
; travel 142 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @08e to @043
  [-
; travel 75 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 75 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 1 cells right
  >
; bit 129 is worth two in the top byte
  [-
; travel 76 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ++
; travel 76 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 143 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<
; build 5H by adding H to a two byte buffer five times
; travel 144 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>
; copy byte 0 of @090 to @091 and to a temp
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
; put temp byte 0 back into @090
  [-
; travel 9 cells left
  <<<<<<<<<
  +
; travel 9 cells right
  >>>>>>>>>
  ]
; travel 153 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; ADD16 : @072 gets @091  little endian
; byte 0
; travel 114 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @072 to @094
  [-
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 34 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 31 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @091 to @095
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
; move byte 0 of @093 to @095
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
; move byte 0 of @094 to @072
  [-
; travel 34 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @096 to @093
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 150 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; byte 1
; travel 115 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @073 to @094
  [-
; travel 33 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 33 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 31 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @092 to @095
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
; move byte 0 of @093 to @095
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
; move byte 0 of @094 to @073
  [-
; travel 33 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 33 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @096 to @093
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 150 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; drop the carry out of the top byte
; travel 147 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>
  [-]
; travel 147 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<
; travel 144 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>
; copy byte 0 of @090 to @091 and to a temp
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
; put temp byte 0 back into @090
  [-
; travel 9 cells left
  <<<<<<<<<
  +
; travel 9 cells right
  >>>>>>>>>
  ]
; travel 153 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; ADD16 : @072 gets @091  little endian
; byte 0
; travel 114 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @072 to @094
  [-
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 34 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 31 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @091 to @095
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
; move byte 0 of @093 to @095
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
; move byte 0 of @094 to @072
  [-
; travel 34 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @096 to @093
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 150 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; byte 1
; travel 115 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @073 to @094
  [-
; travel 33 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 33 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 31 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @092 to @095
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
; move byte 0 of @093 to @095
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
; move byte 0 of @094 to @073
  [-
; travel 33 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 33 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @096 to @093
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 150 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; drop the carry out of the top byte
; travel 147 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>
  [-]
; travel 147 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<
; travel 144 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>
; copy byte 0 of @090 to @091 and to a temp
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
; put temp byte 0 back into @090
  [-
; travel 9 cells left
  <<<<<<<<<
  +
; travel 9 cells right
  >>>>>>>>>
  ]
; travel 153 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; ADD16 : @072 gets @091  little endian
; byte 0
; travel 114 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @072 to @094
  [-
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 34 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 31 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @091 to @095
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
; move byte 0 of @093 to @095
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
; move byte 0 of @094 to @072
  [-
; travel 34 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @096 to @093
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 150 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; byte 1
; travel 115 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @073 to @094
  [-
; travel 33 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 33 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 31 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @092 to @095
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
; move byte 0 of @093 to @095
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
; move byte 0 of @094 to @073
  [-
; travel 33 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 33 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @096 to @093
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 150 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; drop the carry out of the top byte
; travel 147 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>
  [-]
; travel 147 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<
; travel 144 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>
; copy byte 0 of @090 to @091 and to a temp
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
; put temp byte 0 back into @090
  [-
; travel 9 cells left
  <<<<<<<<<
  +
; travel 9 cells right
  >>>>>>>>>
  ]
; travel 153 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; ADD16 : @072 gets @091  little endian
; byte 0
; travel 114 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @072 to @094
  [-
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 34 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 31 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @091 to @095
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
; move byte 0 of @093 to @095
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
; move byte 0 of @094 to @072
  [-
; travel 34 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @096 to @093
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 150 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; byte 1
; travel 115 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @073 to @094
  [-
; travel 33 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 33 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 31 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @092 to @095
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
; move byte 0 of @093 to @095
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
; move byte 0 of @094 to @073
  [-
; travel 33 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 33 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @096 to @093
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 150 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; drop the carry out of the top byte
; travel 147 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>
  [-]
; travel 147 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<
; travel 144 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>
; copy byte 0 of @090 to @091 and to a temp
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
; put temp byte 0 back into @090
  [-
; travel 9 cells left
  <<<<<<<<<
  +
; travel 9 cells right
  >>>>>>>>>
  ]
; travel 153 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; ADD16 : @072 gets @091  little endian
; byte 0
; travel 114 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @072 to @094
  [-
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 34 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 31 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @091 to @095
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
; move byte 0 of @093 to @095
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
; move byte 0 of @094 to @072
  [-
; travel 34 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @096 to @093
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 150 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; byte 1
; travel 115 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @073 to @094
  [-
; travel 33 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 33 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 31 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @092 to @095
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
; move byte 0 of @093 to @095
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
; move byte 0 of @094 to @073
  [-
; travel 33 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 33 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @096 to @093
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 150 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; drop the carry out of the top byte
; travel 147 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>
  [-]
; travel 147 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<
; discard H now that 5H is built
; travel 144 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>
  [-]
; travel 144 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<
; add 5H back into the value
; ADD136 : @033 gets @072  little endian
; byte 0
; travel 51 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>
; move byte 0 of @033 to @084
  [-
; travel 81 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >
  +
; travel 81 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <
  ]
; travel 63 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @072 to @085
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
; move byte 0 of @083 to @085
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
; move byte 0 of @084 to @033
  [-
; travel 81 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <
  +
; travel 81 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >
  ]
; travel 2 cells right
  >>
; move byte 0 of @086 to @083
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 134 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; byte 1
; travel 52 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>
; move byte 0 of @034 to @084
  [-
; travel 80 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 80 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 63 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @073 to @085
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
; move byte 0 of @083 to @085
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
; move byte 0 of @084 to @034
  [-
; travel 80 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 80 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @086 to @083
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 134 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; byte 2
; travel 53 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>
; move byte 0 of @035 to @084
  [-
; travel 79 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 79 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 63 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @074 to @085
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
; move byte 0 of @083 to @085
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
; move byte 0 of @084 to @035
  [-
; travel 79 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 79 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @086 to @083
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 134 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; byte 3
; travel 54 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>
; move byte 0 of @036 to @084
  [-
; travel 78 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 78 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 63 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @075 to @085
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
; move byte 0 of @083 to @085
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
; move byte 0 of @084 to @036
  [-
; travel 78 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 78 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @086 to @083
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 134 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; byte 4
; travel 55 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>
; move byte 0 of @037 to @084
  [-
; travel 77 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 77 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 63 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @076 to @085
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
; move byte 0 of @083 to @085
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
; move byte 0 of @084 to @037
  [-
; travel 77 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 77 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @086 to @083
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 134 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; byte 5
; travel 56 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>
; move byte 0 of @038 to @084
  [-
; travel 76 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 76 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 63 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @077 to @085
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
; move byte 0 of @083 to @085
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
; move byte 0 of @084 to @038
  [-
; travel 76 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 76 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @086 to @083
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 134 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; byte 6
; travel 57 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>
; move byte 0 of @039 to @084
  [-
; travel 75 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 75 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 63 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @078 to @085
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
; move byte 0 of @083 to @085
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
; move byte 0 of @084 to @039
  [-
; travel 75 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 75 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @086 to @083
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 134 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; byte 7
; travel 58 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>
; move byte 0 of @03a to @084
  [-
; travel 74 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 74 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 63 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @079 to @085
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
; move byte 0 of @083 to @085
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
; move byte 0 of @084 to @03a
  [-
; travel 74 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 74 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @086 to @083
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 134 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; byte 8
; travel 59 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>
; move byte 0 of @03b to @084
  [-
; travel 73 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 73 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 63 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @07a to @085
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
; move byte 0 of @083 to @085
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
; move byte 0 of @084 to @03b
  [-
; travel 73 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 73 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @086 to @083
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 134 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; byte 9
; travel 60 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>
; move byte 0 of @03c to @084
  [-
; travel 72 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 72 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 63 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @07b to @085
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
; move byte 0 of @083 to @085
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
; move byte 0 of @084 to @03c
  [-
; travel 72 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 72 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @086 to @083
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 134 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; byte 10
; travel 61 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @03d to @084
  [-
; travel 71 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 71 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 63 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @07c to @085
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
; move byte 0 of @083 to @085
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
; move byte 0 of @084 to @03d
  [-
; travel 71 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 71 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @086 to @083
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 134 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; byte 11
; travel 62 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @03e to @084
  [-
; travel 70 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 70 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 63 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @07d to @085
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
; move byte 0 of @083 to @085
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
; move byte 0 of @084 to @03e
  [-
; travel 70 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 70 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @086 to @083
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 134 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; byte 12
; travel 63 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @03f to @084
  [-
; travel 69 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 69 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 63 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @07e to @085
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
; move byte 0 of @083 to @085
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
; move byte 0 of @084 to @03f
  [-
; travel 69 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 69 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @086 to @083
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 134 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; byte 13
; travel 64 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @040 to @084
  [-
; travel 68 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 68 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 63 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @07f to @085
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
; move byte 0 of @083 to @085
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
; move byte 0 of @084 to @040
  [-
; travel 68 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 68 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @086 to @083
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 134 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; byte 14
; travel 65 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @041 to @084
  [-
; travel 67 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 67 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 63 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @080 to @085
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
; move byte 0 of @083 to @085
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
; move byte 0 of @084 to @041
  [-
; travel 67 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 67 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @086 to @083
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 134 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; byte 15
; travel 66 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @042 to @084
  [-
; travel 66 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 66 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 63 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @081 to @085
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
; move byte 0 of @083 to @085
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
; move byte 0 of @084 to @042
  [-
; travel 66 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 66 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @086 to @083
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 134 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; byte 16
; travel 67 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @043 to @084
  [-
; travel 65 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 65 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 63 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @082 to @085
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
; move byte 0 of @083 to @085
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
; move byte 0 of @084 to @043
  [-
; travel 65 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 65 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @086 to @083
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 134 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; drop the carry out of the top byte
; travel 131 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>
  [-]
; travel 131 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<
; FOLD : reduce using 2^130 = 5 modulo p
; the split is at bit 130  which is the top byte shifted right two
; travel 67 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @043 to @089
  [-
; travel 70 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 70 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 70 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; first halving  the low bit here is bit 128
  [->>>+<[-<+>>-<]>[-<+>]<<<]
; travel 2 cells right
  >>
; move byte 0 of @08b to @08e
  [-
; travel 3 cells right
  >>>
  +
; travel 3 cells left
  <<<
  ]
; travel 1 cells left
  <
; move byte 0 of @08a to @089
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
; move byte 0 of @08b to @08f
  [-
; travel 4 cells right
  >>>>
  +
; travel 4 cells left
  <<<<
  ]
; travel 1 cells left
  <
; move byte 0 of @08a to @090
  [-
; travel 6 cells right
  >>>>>>
  +
; travel 6 cells left
  <<<<<<
  ]
; travel 138 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<
; the top byte keeps only bits 128 and 129
; travel 142 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @08e to @043
  [-
; travel 75 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 75 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 1 cells right
  >
; bit 129 is worth two in the top byte
  [-
; travel 76 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ++
; travel 76 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 143 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<
; build 5H by adding H to a two byte buffer five times
; travel 144 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>
; copy byte 0 of @090 to @091 and to a temp
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
; put temp byte 0 back into @090
  [-
; travel 9 cells left
  <<<<<<<<<
  +
; travel 9 cells right
  >>>>>>>>>
  ]
; travel 153 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; ADD16 : @072 gets @091  little endian
; byte 0
; travel 114 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @072 to @094
  [-
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 34 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 31 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @091 to @095
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
; move byte 0 of @093 to @095
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
; move byte 0 of @094 to @072
  [-
; travel 34 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @096 to @093
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 150 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; byte 1
; travel 115 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @073 to @094
  [-
; travel 33 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 33 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 31 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @092 to @095
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
; move byte 0 of @093 to @095
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
; move byte 0 of @094 to @073
  [-
; travel 33 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 33 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @096 to @093
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 150 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; drop the carry out of the top byte
; travel 147 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>
  [-]
; travel 147 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<
; travel 144 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>
; copy byte 0 of @090 to @091 and to a temp
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
; put temp byte 0 back into @090
  [-
; travel 9 cells left
  <<<<<<<<<
  +
; travel 9 cells right
  >>>>>>>>>
  ]
; travel 153 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; ADD16 : @072 gets @091  little endian
; byte 0
; travel 114 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @072 to @094
  [-
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 34 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 31 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @091 to @095
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
; move byte 0 of @093 to @095
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
; move byte 0 of @094 to @072
  [-
; travel 34 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @096 to @093
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 150 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; byte 1
; travel 115 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @073 to @094
  [-
; travel 33 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 33 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 31 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @092 to @095
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
; move byte 0 of @093 to @095
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
; move byte 0 of @094 to @073
  [-
; travel 33 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 33 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @096 to @093
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 150 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; drop the carry out of the top byte
; travel 147 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>
  [-]
; travel 147 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<
; travel 144 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>
; copy byte 0 of @090 to @091 and to a temp
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
; put temp byte 0 back into @090
  [-
; travel 9 cells left
  <<<<<<<<<
  +
; travel 9 cells right
  >>>>>>>>>
  ]
; travel 153 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; ADD16 : @072 gets @091  little endian
; byte 0
; travel 114 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @072 to @094
  [-
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 34 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 31 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @091 to @095
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
; move byte 0 of @093 to @095
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
; move byte 0 of @094 to @072
  [-
; travel 34 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @096 to @093
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 150 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; byte 1
; travel 115 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @073 to @094
  [-
; travel 33 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 33 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 31 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @092 to @095
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
; move byte 0 of @093 to @095
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
; move byte 0 of @094 to @073
  [-
; travel 33 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 33 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @096 to @093
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 150 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; drop the carry out of the top byte
; travel 147 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>
  [-]
; travel 147 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<
; travel 144 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>
; copy byte 0 of @090 to @091 and to a temp
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
; put temp byte 0 back into @090
  [-
; travel 9 cells left
  <<<<<<<<<
  +
; travel 9 cells right
  >>>>>>>>>
  ]
; travel 153 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; ADD16 : @072 gets @091  little endian
; byte 0
; travel 114 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @072 to @094
  [-
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 34 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 31 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @091 to @095
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
; move byte 0 of @093 to @095
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
; move byte 0 of @094 to @072
  [-
; travel 34 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @096 to @093
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 150 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; byte 1
; travel 115 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @073 to @094
  [-
; travel 33 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 33 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 31 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @092 to @095
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
; move byte 0 of @093 to @095
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
; move byte 0 of @094 to @073
  [-
; travel 33 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 33 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @096 to @093
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 150 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; drop the carry out of the top byte
; travel 147 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>
  [-]
; travel 147 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<
; travel 144 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>
; copy byte 0 of @090 to @091 and to a temp
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
; put temp byte 0 back into @090
  [-
; travel 9 cells left
  <<<<<<<<<
  +
; travel 9 cells right
  >>>>>>>>>
  ]
; travel 153 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; ADD16 : @072 gets @091  little endian
; byte 0
; travel 114 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @072 to @094
  [-
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 34 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 31 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @091 to @095
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
; move byte 0 of @093 to @095
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
; move byte 0 of @094 to @072
  [-
; travel 34 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 34 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @096 to @093
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 150 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; byte 1
; travel 115 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @073 to @094
  [-
; travel 33 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 33 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 31 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @092 to @095
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
; move byte 0 of @093 to @095
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
; move byte 0 of @094 to @073
  [-
; travel 33 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 33 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @096 to @093
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 150 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; drop the carry out of the top byte
; travel 147 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>
  [-]
; travel 147 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<
; discard H now that 5H is built
; travel 144 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>
  [-]
; travel 144 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<
; add 5H back into the value
; ADD136 : @033 gets @072  little endian
; byte 0
; travel 51 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>
; move byte 0 of @033 to @084
  [-
; travel 81 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >
  +
; travel 81 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <
  ]
; travel 63 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @072 to @085
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
; move byte 0 of @083 to @085
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
; move byte 0 of @084 to @033
  [-
; travel 81 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <
  +
; travel 81 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >
  ]
; travel 2 cells right
  >>
; move byte 0 of @086 to @083
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 134 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; byte 1
; travel 52 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>
; move byte 0 of @034 to @084
  [-
; travel 80 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 80 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 63 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @073 to @085
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
; move byte 0 of @083 to @085
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
; move byte 0 of @084 to @034
  [-
; travel 80 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 80 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @086 to @083
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 134 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; byte 2
; travel 53 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>
; move byte 0 of @035 to @084
  [-
; travel 79 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 79 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 63 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @074 to @085
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
; move byte 0 of @083 to @085
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
; move byte 0 of @084 to @035
  [-
; travel 79 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 79 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @086 to @083
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 134 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; byte 3
; travel 54 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>
; move byte 0 of @036 to @084
  [-
; travel 78 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 78 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 63 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @075 to @085
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
; move byte 0 of @083 to @085
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
; move byte 0 of @084 to @036
  [-
; travel 78 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 78 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @086 to @083
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 134 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; byte 4
; travel 55 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>
; move byte 0 of @037 to @084
  [-
; travel 77 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 77 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 63 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @076 to @085
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
; move byte 0 of @083 to @085
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
; move byte 0 of @084 to @037
  [-
; travel 77 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 77 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @086 to @083
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 134 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; byte 5
; travel 56 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>
; move byte 0 of @038 to @084
  [-
; travel 76 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 76 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 63 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @077 to @085
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
; move byte 0 of @083 to @085
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
; move byte 0 of @084 to @038
  [-
; travel 76 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 76 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @086 to @083
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 134 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; byte 6
; travel 57 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>
; move byte 0 of @039 to @084
  [-
; travel 75 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 75 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 63 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @078 to @085
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
; move byte 0 of @083 to @085
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
; move byte 0 of @084 to @039
  [-
; travel 75 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 75 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @086 to @083
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 134 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; byte 7
; travel 58 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>
; move byte 0 of @03a to @084
  [-
; travel 74 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 74 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 63 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @079 to @085
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
; move byte 0 of @083 to @085
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
; move byte 0 of @084 to @03a
  [-
; travel 74 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 74 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @086 to @083
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 134 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; byte 8
; travel 59 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>
; move byte 0 of @03b to @084
  [-
; travel 73 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 73 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 63 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @07a to @085
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
; move byte 0 of @083 to @085
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
; move byte 0 of @084 to @03b
  [-
; travel 73 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 73 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @086 to @083
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 134 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; byte 9
; travel 60 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>
; move byte 0 of @03c to @084
  [-
; travel 72 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 72 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 63 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @07b to @085
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
; move byte 0 of @083 to @085
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
; move byte 0 of @084 to @03c
  [-
; travel 72 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 72 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @086 to @083
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 134 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; byte 10
; travel 61 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @03d to @084
  [-
; travel 71 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 71 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 63 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @07c to @085
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
; move byte 0 of @083 to @085
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
; move byte 0 of @084 to @03d
  [-
; travel 71 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 71 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @086 to @083
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 134 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; byte 11
; travel 62 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @03e to @084
  [-
; travel 70 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 70 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 63 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @07d to @085
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
; move byte 0 of @083 to @085
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
; move byte 0 of @084 to @03e
  [-
; travel 70 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 70 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @086 to @083
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 134 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; byte 12
; travel 63 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @03f to @084
  [-
; travel 69 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 69 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 63 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @07e to @085
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
; move byte 0 of @083 to @085
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
; move byte 0 of @084 to @03f
  [-
; travel 69 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 69 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @086 to @083
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 134 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; byte 13
; travel 64 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @040 to @084
  [-
; travel 68 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 68 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 63 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @07f to @085
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
; move byte 0 of @083 to @085
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
; move byte 0 of @084 to @040
  [-
; travel 68 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 68 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @086 to @083
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 134 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; byte 14
; travel 65 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @041 to @084
  [-
; travel 67 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 67 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 63 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @080 to @085
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
; move byte 0 of @083 to @085
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
; move byte 0 of @084 to @041
  [-
; travel 67 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 67 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @086 to @083
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 134 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; byte 15
; travel 66 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @042 to @084
  [-
; travel 66 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 66 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 63 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @081 to @085
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
; move byte 0 of @083 to @085
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
; move byte 0 of @084 to @042
  [-
; travel 66 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 66 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @086 to @083
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 134 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; byte 16
; travel 67 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @043 to @084
  [-
; travel 65 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 65 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<
  ]
; travel 63 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @082 to @085
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
; move byte 0 of @083 to @085
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
; move byte 0 of @084 to @043
  [-
; travel 65 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 65 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @086 to @083
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 134 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; drop the carry out of the top byte
; travel 131 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>
  [-]
; travel 131 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<
; copy the value and add five to it  to test whether it reaches p
; travel 51 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>
; copy byte 0 of @033 to @09a and to a temp
  [-
; travel 103 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 31 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 134 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
  ]>
; copy byte 1 of @034 to @09b and to a temp
  [-
; travel 103 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 31 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 134 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
  ]>
; copy byte 2 of @035 to @09c and to a temp
  [-
; travel 103 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 31 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 134 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
  ]>
; copy byte 3 of @036 to @09d and to a temp
  [-
; travel 103 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 31 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 134 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
  ]>
; copy byte 4 of @037 to @09e and to a temp
  [-
; travel 103 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 31 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 134 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
  ]>
; copy byte 5 of @038 to @09f and to a temp
  [-
; travel 103 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 31 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 134 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
  ]>
; copy byte 6 of @039 to @0a0 and to a temp
  [-
; travel 103 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 31 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 134 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
  ]>
; copy byte 7 of @03a to @0a1 and to a temp
  [-
; travel 103 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 31 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 134 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
  ]>
; copy byte 8 of @03b to @0a2 and to a temp
  [-
; travel 103 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 31 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 134 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
  ]>
; copy byte 9 of @03c to @0a3 and to a temp
  [-
; travel 103 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 31 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 134 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
  ]>
; copy byte 10 of @03d to @0a4 and to a temp
  [-
; travel 103 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 31 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 134 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
  ]>
; copy byte 11 of @03e to @0a5 and to a temp
  [-
; travel 103 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 31 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 134 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
  ]>
; copy byte 12 of @03f to @0a6 and to a temp
  [-
; travel 103 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 31 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 134 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
  ]>
; copy byte 13 of @040 to @0a7 and to a temp
  [-
; travel 103 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 31 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 134 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
  ]>
; copy byte 14 of @041 to @0a8 and to a temp
  [-
; travel 103 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 31 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 134 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
  ]>
; copy byte 15 of @042 to @0a9 and to a temp
  [-
; travel 103 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 31 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 134 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
  ]>
; copy byte 16 of @043 to @0aa and to a temp
  [-
; travel 103 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 31 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  +
; travel 134 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
  ]
; walk to the temps
; travel 118 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; put temp byte 0 back into @033
  [-
; travel 134 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
  +
; travel 134 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>
  ]>
; put temp byte 1 back into @034
  [-
; travel 134 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
  +
; travel 134 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>
  ]>
; put temp byte 2 back into @035
  [-
; travel 134 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
  +
; travel 134 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>
  ]>
; put temp byte 3 back into @036
  [-
; travel 134 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
  +
; travel 134 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>
  ]>
; put temp byte 4 back into @037
  [-
; travel 134 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
  +
; travel 134 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>
  ]>
; put temp byte 5 back into @038
  [-
; travel 134 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
  +
; travel 134 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>
  ]>
; put temp byte 6 back into @039
  [-
; travel 134 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
  +
; travel 134 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>
  ]>
; put temp byte 7 back into @03a
  [-
; travel 134 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
  +
; travel 134 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>
  ]>
; put temp byte 8 back into @03b
  [-
; travel 134 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
  +
; travel 134 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>
  ]>
; put temp byte 9 back into @03c
  [-
; travel 134 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
  +
; travel 134 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>
  ]>
; put temp byte 10 back into @03d
  [-
; travel 134 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
  +
; travel 134 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>
  ]>
; put temp byte 11 back into @03e
  [-
; travel 134 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
  +
; travel 134 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>
  ]>
; put temp byte 12 back into @03f
  [-
; travel 134 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
  +
; travel 134 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>
  ]>
; put temp byte 13 back into @040
  [-
; travel 134 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
  +
; travel 134 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>
  ]>
; put temp byte 14 back into @041
  [-
; travel 134 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
  +
; travel 134 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>
  ]>
; put temp byte 15 back into @042
  [-
; travel 134 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
  +
; travel 134 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>
  ]>
; put temp byte 16 back into @043
  [-
; travel 134 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
  +
; travel 134 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>
  ]
; travel 201 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <
; travel 202 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>
; add 5
  +++++
; travel 202 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<
; ADD136 : @09a gets @0ca  little endian
; byte 0
; travel 154 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @09a to @0ac
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
; move byte 0 of @0ca to @0ad
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
; move byte 0 of @0ab to @0ad
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
; move byte 0 of @0ac to @09a
  [-
; travel 18 cells left
  <<<<<<<<<<<<<<<<<<
  +
; travel 18 cells right
  >>>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @0ae to @0ab
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 174 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; byte 1
; travel 155 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @09b to @0ac
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
; move byte 0 of @0cb to @0ad
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
; move byte 0 of @0ab to @0ad
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
; move byte 0 of @0ac to @09b
  [-
; travel 17 cells left
  <<<<<<<<<<<<<<<<<
  +
; travel 17 cells right
  >>>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @0ae to @0ab
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 174 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; byte 2
; travel 156 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @09c to @0ac
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
; move byte 0 of @0cc to @0ad
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
; move byte 0 of @0ab to @0ad
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
; move byte 0 of @0ac to @09c
  [-
; travel 16 cells left
  <<<<<<<<<<<<<<<<
  +
; travel 16 cells right
  >>>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @0ae to @0ab
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 174 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; byte 3
; travel 157 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @09d to @0ac
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
; move byte 0 of @0cd to @0ad
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
; move byte 0 of @0ab to @0ad
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
; move byte 0 of @0ac to @09d
  [-
; travel 15 cells left
  <<<<<<<<<<<<<<<
  +
; travel 15 cells right
  >>>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @0ae to @0ab
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 174 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; byte 4
; travel 158 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @09e to @0ac
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
; move byte 0 of @0ce to @0ad
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
; move byte 0 of @0ab to @0ad
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
; move byte 0 of @0ac to @09e
  [-
; travel 14 cells left
  <<<<<<<<<<<<<<
  +
; travel 14 cells right
  >>>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @0ae to @0ab
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 174 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; byte 5
; travel 159 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @09f to @0ac
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
; move byte 0 of @0cf to @0ad
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
; move byte 0 of @0ab to @0ad
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
; move byte 0 of @0ac to @09f
  [-
; travel 13 cells left
  <<<<<<<<<<<<<
  +
; travel 13 cells right
  >>>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @0ae to @0ab
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 174 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; byte 6
; travel 160 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @0a0 to @0ac
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
; move byte 0 of @0d0 to @0ad
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
; move byte 0 of @0ab to @0ad
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
; move byte 0 of @0ac to @0a0
  [-
; travel 12 cells left
  <<<<<<<<<<<<
  +
; travel 12 cells right
  >>>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @0ae to @0ab
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 174 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; byte 7
; travel 161 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >
; move byte 0 of @0a1 to @0ac
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
; move byte 0 of @0d1 to @0ad
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
; move byte 0 of @0ab to @0ad
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
; move byte 0 of @0ac to @0a1
  [-
; travel 11 cells left
  <<<<<<<<<<<
  +
; travel 11 cells right
  >>>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @0ae to @0ab
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 174 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; byte 8
; travel 162 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>
; move byte 0 of @0a2 to @0ac
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
; move byte 0 of @0d2 to @0ad
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
; move byte 0 of @0ab to @0ad
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
; move byte 0 of @0ac to @0a2
  [-
; travel 10 cells left
  <<<<<<<<<<
  +
; travel 10 cells right
  >>>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @0ae to @0ab
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 174 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; byte 9
; travel 163 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>
; move byte 0 of @0a3 to @0ac
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
; move byte 0 of @0d3 to @0ad
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
; move byte 0 of @0ab to @0ad
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
; move byte 0 of @0ac to @0a3
  [-
; travel 9 cells left
  <<<<<<<<<
  +
; travel 9 cells right
  >>>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @0ae to @0ab
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 174 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; byte 10
; travel 164 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>
; move byte 0 of @0a4 to @0ac
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
; move byte 0 of @0d4 to @0ad
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
; move byte 0 of @0ab to @0ad
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
; move byte 0 of @0ac to @0a4
  [-
; travel 8 cells left
  <<<<<<<<
  +
; travel 8 cells right
  >>>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @0ae to @0ab
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 174 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; byte 11
; travel 165 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>
; move byte 0 of @0a5 to @0ac
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
; move byte 0 of @0d5 to @0ad
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
; move byte 0 of @0ab to @0ad
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
; move byte 0 of @0ac to @0a5
  [-
; travel 7 cells left
  <<<<<<<
  +
; travel 7 cells right
  >>>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @0ae to @0ab
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 174 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; byte 12
; travel 166 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>
; move byte 0 of @0a6 to @0ac
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
; move byte 0 of @0d6 to @0ad
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
; move byte 0 of @0ab to @0ad
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
; move byte 0 of @0ac to @0a6
  [-
; travel 6 cells left
  <<<<<<
  +
; travel 6 cells right
  >>>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @0ae to @0ab
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 174 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; byte 13
; travel 167 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>
; move byte 0 of @0a7 to @0ac
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
; move byte 0 of @0d7 to @0ad
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
; move byte 0 of @0ab to @0ad
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
; move byte 0 of @0ac to @0a7
  [-
; travel 5 cells left
  <<<<<
  +
; travel 5 cells right
  >>>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @0ae to @0ab
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 174 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; byte 14
; travel 168 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>
; move byte 0 of @0a8 to @0ac
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
; move byte 0 of @0d8 to @0ad
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
; move byte 0 of @0ab to @0ad
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
; move byte 0 of @0ac to @0a8
  [-
; travel 4 cells left
  <<<<
  +
; travel 4 cells right
  >>>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @0ae to @0ab
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 174 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; byte 15
; travel 169 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>
; move byte 0 of @0a9 to @0ac
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
; move byte 0 of @0d9 to @0ad
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
; move byte 0 of @0ab to @0ad
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
; move byte 0 of @0ac to @0a9
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 2 cells right
  >>
; move byte 0 of @0ae to @0ab
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 174 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; byte 16
; travel 170 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>
; move byte 0 of @0aa to @0ac
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
; move byte 0 of @0da to @0ad
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
; move byte 0 of @0ab to @0ad
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
; move byte 0 of @0ac to @0aa
  [-
; travel 2 cells left
  <<
  +
; travel 2 cells right
  >>
  ]
; travel 2 cells right
  >>
; move byte 0 of @0ae to @0ab
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 174 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; drop the carry out of the top byte
; travel 171 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>
  [-]
; travel 171 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<
; split the sum's top byte  bit 130 tells us whether x was at least p
; travel 170 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>
; move byte 0 of @0aa to @0b1
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
; move byte 0 of @0b3 to @0b6
  [-
; travel 3 cells right
  >>>
  +
; travel 3 cells left
  <<<
  ]
; travel 1 cells left
  <
; move byte 0 of @0b2 to @0b1
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
; move byte 0 of @0b3 to @0b7
  [-
; travel 4 cells right
  >>>>
  +
; travel 4 cells left
  <<<<
  ]
; travel 1 cells left
  <
; move byte 0 of @0b2 to @0b8
  [-
; travel 6 cells right
  >>>>>>
  +
; travel 6 cells left
  <<<<<<
  ]
; travel 178 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<
; put the two low bits back  so the sum has bit 130 cleared
; travel 182 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @0b6 to @0aa
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
; travel 183 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<
; if the sum crossed bit 130  the value was at least p  so take the sum
; travel 184 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>
  [
  [-]
; travel 184 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<
; travel 51 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>
  [-]
; travel 51 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<
; travel 52 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>
  [-]
; travel 52 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<
; travel 53 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>
  [-]
; travel 53 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<
; travel 54 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>
  [-]
; travel 54 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<
; travel 55 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>
  [-]
; travel 55 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<
; travel 56 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>
  [-]
; travel 56 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<
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
; travel 154 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; move byte 0 of @09a to @033
  [-
; travel 103 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 103 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
  ]>
; move byte 1 of @09b to @034
  [-
; travel 103 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 103 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
  ]>
; move byte 2 of @09c to @035
  [-
; travel 103 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 103 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
  ]>
; move byte 3 of @09d to @036
  [-
; travel 103 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 103 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
  ]>
; move byte 4 of @09e to @037
  [-
; travel 103 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 103 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
  ]>
; move byte 5 of @09f to @038
  [-
; travel 103 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 103 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
  ]>
; move byte 6 of @0a0 to @039
  [-
; travel 103 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 103 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
  ]>
; move byte 7 of @0a1 to @03a
  [-
; travel 103 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 103 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
  ]>
; move byte 8 of @0a2 to @03b
  [-
; travel 103 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 103 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
  ]>
; move byte 9 of @0a3 to @03c
  [-
; travel 103 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 103 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
  ]>
; move byte 10 of @0a4 to @03d
  [-
; travel 103 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 103 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
  ]>
; move byte 11 of @0a5 to @03e
  [-
; travel 103 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 103 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
  ]>
; move byte 12 of @0a6 to @03f
  [-
; travel 103 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 103 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
  ]>
; move byte 13 of @0a7 to @040
  [-
; travel 103 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 103 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
  ]>
; move byte 14 of @0a8 to @041
  [-
; travel 103 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 103 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
  ]>
; move byte 15 of @0a9 to @042
  [-
; travel 103 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 103 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
  ]>
; move byte 16 of @0aa to @043
  [-
; travel 103 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<
  +
; travel 103 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>
  ]
; travel 14 cells right
  >>>>>>>>>>>>>>
  ]
; travel 184 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<
; discard the trial sum  it is already empty when it was taken
; travel 154 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  [-]
; travel 154 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; travel 155 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  [-]
; travel 155 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; travel 156 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  [-]
; travel 156 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; travel 157 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  [-]
; travel 157 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; travel 158 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  [-]
; travel 158 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; travel 159 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  [-]
; travel 159 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; travel 160 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  [-]
; travel 160 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; travel 161 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >
  [-]
; travel 161 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <
; travel 162 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>
  [-]
; travel 162 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<
; travel 163 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>
  [-]
; travel 163 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<
; travel 164 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>
  [-]
; travel 164 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<
; travel 165 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>
  [-]
; travel 165 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<
; travel 166 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>
  [-]
; travel 166 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<
; travel 167 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>
  [-]
; travel 167 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<
; travel 168 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>
  [-]
; travel 168 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<
; travel 169 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>
  [-]
; travel 169 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<
; travel 170 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>
  [-]
; travel 170 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<
; travel 51 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>
; move byte 0 of @033 to @000
  [-
; travel 51 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<
  +
; travel 51 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>
  ]>
; move byte 1 of @034 to @001
  [-
; travel 51 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<
  +
; travel 51 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>
  ]>
; move byte 2 of @035 to @002
  [-
; travel 51 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<
  +
; travel 51 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>
  ]>
; move byte 3 of @036 to @003
  [-
; travel 51 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<
  +
; travel 51 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>
  ]>
; move byte 4 of @037 to @004
  [-
; travel 51 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<
  +
; travel 51 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>
  ]>
; move byte 5 of @038 to @005
  [-
; travel 51 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<
  +
; travel 51 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>
  ]>
; move byte 6 of @039 to @006
  [-
; travel 51 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<
  +
; travel 51 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>
  ]>
; move byte 7 of @03a to @007
  [-
; travel 51 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<
  +
; travel 51 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>
  ]>
; move byte 8 of @03b to @008
  [-
; travel 51 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<
  +
; travel 51 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>
  ]>
; move byte 9 of @03c to @009
  [-
; travel 51 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<
  +
; travel 51 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>
  ]>
; move byte 10 of @03d to @00a
  [-
; travel 51 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<
  +
; travel 51 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>
  ]>
; move byte 11 of @03e to @00b
  [-
; travel 51 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<
  +
; travel 51 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>
  ]>
; move byte 12 of @03f to @00c
  [-
; travel 51 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<
  +
; travel 51 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>
  ]>
; move byte 13 of @040 to @00d
  [-
; travel 51 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<
  +
; travel 51 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>
  ]>
; move byte 14 of @041 to @00e
  [-
; travel 51 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<
  +
; travel 51 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>
  ]>
; move byte 15 of @042 to @00f
  [-
; travel 51 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<
  +
; travel 51 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>
  ]>
; move byte 16 of @043 to @010
  [-
; travel 51 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<
  +
; travel 51 cells right
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  >>>>>>>>>>>
  ]
; travel 67 cells left
  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  <<<<<<<<<<<<<<<<<<<<<<<<<<<

; emit the product little endian
  .>.>.>.>.>.>.>.>.>.>.>.>.>.>.>.>.
