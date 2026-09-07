; bfsodium HALVE136 : 17 byte little endian shift right one
;
; ASSEMBLED FILE: emitted by tools/polyasm using the shared emitter;
;
; IO  in:  x{17} LE      (17 bytes)
;     out: (x shifted right one){17} LE   (17 bytes)
;
; TAPE MAP  (home @0)
;   @0x00:0x10  x{17}  u8   the value  and the result  LSB at @0x00
;   @0x11       h      u8   HALVE frame: the byte being halved
;   @0x12       q      u8   HALVE frame: the quotient
;   @0x13       bit    u8   HALVE frame: this byte low bit
;   @0x14       f      u8   HALVE frame scratch  restored 0
;   @0x15       carry  u8   the bit coming down from the byte above
;
; Bytes are walked from the top down  because the bit leaving a byte enters
; the byte below it;

; read x  leaving the pointer on its last byte
  ,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,>,
; travel 16 cells left
  <<<<<<<<<<<<<<<<
; HALVE136 : @000 shifted right one  keeping the bit shifted out
; byte 16  the top byte first
; travel 16 cells right
  >>>>>>>>>>>>>>>>
; move byte 0 of @010 to @011
  [-
; travel 1 cells right
  >
  +
; travel 1 cells left
  <
  ]
; travel 1 cells right
  >
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
; move byte 0 of @012 to @010
  [-
; travel 2 cells left
  <<
  +
; travel 2 cells right
  >>
  ]
; travel 1 cells right
  >
; move byte 0 of @013 to @015
  [-
; travel 2 cells right
  >>
  +
; travel 2 cells left
  <<
  ]
; travel 19 cells left
  <<<<<<<<<<<<<<<<<<<
; byte 15  the top byte first
; travel 15 cells right
  >>>>>>>>>>>>>>>
; move byte 0 of @00f to @011
  [-
; travel 2 cells right
  >>
  +
; travel 2 cells left
  <<
  ]
; travel 2 cells right
  >>
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
; move byte 0 of @012 to @00f
  [-
; travel 3 cells left
  <<<
  +
; travel 3 cells right
  >>>
  ]
; travel 1 cells right
  >
; move byte 0 of @013 to @015
  [-
; travel 2 cells right
  >>
  +
; travel 2 cells left
  <<
  ]
; travel 19 cells left
  <<<<<<<<<<<<<<<<<<<
; byte 14  the top byte first
; travel 14 cells right
  >>>>>>>>>>>>>>
; move byte 0 of @00e to @011
  [-
; travel 3 cells right
  >>>
  +
; travel 3 cells left
  <<<
  ]
; travel 3 cells right
  >>>
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
; move byte 0 of @012 to @00e
  [-
; travel 4 cells left
  <<<<
  +
; travel 4 cells right
  >>>>
  ]
; travel 1 cells right
  >
; move byte 0 of @013 to @015
  [-
; travel 2 cells right
  >>
  +
; travel 2 cells left
  <<
  ]
; travel 19 cells left
  <<<<<<<<<<<<<<<<<<<
; byte 13  the top byte first
; travel 13 cells right
  >>>>>>>>>>>>>
; move byte 0 of @00d to @011
  [-
; travel 4 cells right
  >>>>
  +
; travel 4 cells left
  <<<<
  ]
; travel 4 cells right
  >>>>
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
; move byte 0 of @012 to @00d
  [-
; travel 5 cells left
  <<<<<
  +
; travel 5 cells right
  >>>>>
  ]
; travel 1 cells right
  >
; move byte 0 of @013 to @015
  [-
; travel 2 cells right
  >>
  +
; travel 2 cells left
  <<
  ]
; travel 19 cells left
  <<<<<<<<<<<<<<<<<<<
; byte 12  the top byte first
; travel 12 cells right
  >>>>>>>>>>>>
; move byte 0 of @00c to @011
  [-
; travel 5 cells right
  >>>>>
  +
; travel 5 cells left
  <<<<<
  ]
; travel 5 cells right
  >>>>>
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
; move byte 0 of @012 to @00c
  [-
; travel 6 cells left
  <<<<<<
  +
; travel 6 cells right
  >>>>>>
  ]
; travel 1 cells right
  >
; move byte 0 of @013 to @015
  [-
; travel 2 cells right
  >>
  +
; travel 2 cells left
  <<
  ]
; travel 19 cells left
  <<<<<<<<<<<<<<<<<<<
; byte 11  the top byte first
; travel 11 cells right
  >>>>>>>>>>>
; move byte 0 of @00b to @011
  [-
; travel 6 cells right
  >>>>>>
  +
; travel 6 cells left
  <<<<<<
  ]
; travel 6 cells right
  >>>>>>
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
; move byte 0 of @012 to @00b
  [-
; travel 7 cells left
  <<<<<<<
  +
; travel 7 cells right
  >>>>>>>
  ]
; travel 1 cells right
  >
; move byte 0 of @013 to @015
  [-
; travel 2 cells right
  >>
  +
; travel 2 cells left
  <<
  ]
; travel 19 cells left
  <<<<<<<<<<<<<<<<<<<
; byte 10  the top byte first
; travel 10 cells right
  >>>>>>>>>>
; move byte 0 of @00a to @011
  [-
; travel 7 cells right
  >>>>>>>
  +
; travel 7 cells left
  <<<<<<<
  ]
; travel 7 cells right
  >>>>>>>
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
; move byte 0 of @012 to @00a
  [-
; travel 8 cells left
  <<<<<<<<
  +
; travel 8 cells right
  >>>>>>>>
  ]
; travel 1 cells right
  >
; move byte 0 of @013 to @015
  [-
; travel 2 cells right
  >>
  +
; travel 2 cells left
  <<
  ]
; travel 19 cells left
  <<<<<<<<<<<<<<<<<<<
; byte 9  the top byte first
; travel 9 cells right
  >>>>>>>>>
; move byte 0 of @009 to @011
  [-
; travel 8 cells right
  >>>>>>>>
  +
; travel 8 cells left
  <<<<<<<<
  ]
; travel 8 cells right
  >>>>>>>>
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
; move byte 0 of @012 to @009
  [-
; travel 9 cells left
  <<<<<<<<<
  +
; travel 9 cells right
  >>>>>>>>>
  ]
; travel 1 cells right
  >
; move byte 0 of @013 to @015
  [-
; travel 2 cells right
  >>
  +
; travel 2 cells left
  <<
  ]
; travel 19 cells left
  <<<<<<<<<<<<<<<<<<<
; byte 8  the top byte first
; travel 8 cells right
  >>>>>>>>
; move byte 0 of @008 to @011
  [-
; travel 9 cells right
  >>>>>>>>>
  +
; travel 9 cells left
  <<<<<<<<<
  ]
; travel 9 cells right
  >>>>>>>>>
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
; move byte 0 of @012 to @008
  [-
; travel 10 cells left
  <<<<<<<<<<
  +
; travel 10 cells right
  >>>>>>>>>>
  ]
; travel 1 cells right
  >
; move byte 0 of @013 to @015
  [-
; travel 2 cells right
  >>
  +
; travel 2 cells left
  <<
  ]
; travel 19 cells left
  <<<<<<<<<<<<<<<<<<<
; byte 7  the top byte first
; travel 7 cells right
  >>>>>>>
; move byte 0 of @007 to @011
  [-
; travel 10 cells right
  >>>>>>>>>>
  +
; travel 10 cells left
  <<<<<<<<<<
  ]
; travel 10 cells right
  >>>>>>>>>>
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
; move byte 0 of @012 to @007
  [-
; travel 11 cells left
  <<<<<<<<<<<
  +
; travel 11 cells right
  >>>>>>>>>>>
  ]
; travel 1 cells right
  >
; move byte 0 of @013 to @015
  [-
; travel 2 cells right
  >>
  +
; travel 2 cells left
  <<
  ]
; travel 19 cells left
  <<<<<<<<<<<<<<<<<<<
; byte 6  the top byte first
; travel 6 cells right
  >>>>>>
; move byte 0 of @006 to @011
  [-
; travel 11 cells right
  >>>>>>>>>>>
  +
; travel 11 cells left
  <<<<<<<<<<<
  ]
; travel 11 cells right
  >>>>>>>>>>>
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
; move byte 0 of @012 to @006
  [-
; travel 12 cells left
  <<<<<<<<<<<<
  +
; travel 12 cells right
  >>>>>>>>>>>>
  ]
; travel 1 cells right
  >
; move byte 0 of @013 to @015
  [-
; travel 2 cells right
  >>
  +
; travel 2 cells left
  <<
  ]
; travel 19 cells left
  <<<<<<<<<<<<<<<<<<<
; byte 5  the top byte first
; travel 5 cells right
  >>>>>
; move byte 0 of @005 to @011
  [-
; travel 12 cells right
  >>>>>>>>>>>>
  +
; travel 12 cells left
  <<<<<<<<<<<<
  ]
; travel 12 cells right
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
; move byte 0 of @012 to @005
  [-
; travel 13 cells left
  <<<<<<<<<<<<<
  +
; travel 13 cells right
  >>>>>>>>>>>>>
  ]
; travel 1 cells right
  >
; move byte 0 of @013 to @015
  [-
; travel 2 cells right
  >>
  +
; travel 2 cells left
  <<
  ]
; travel 19 cells left
  <<<<<<<<<<<<<<<<<<<
; byte 4  the top byte first
; travel 4 cells right
  >>>>
; move byte 0 of @004 to @011
  [-
; travel 13 cells right
  >>>>>>>>>>>>>
  +
; travel 13 cells left
  <<<<<<<<<<<<<
  ]
; travel 13 cells right
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
; move byte 0 of @012 to @004
  [-
; travel 14 cells left
  <<<<<<<<<<<<<<
  +
; travel 14 cells right
  >>>>>>>>>>>>>>
  ]
; travel 1 cells right
  >
; move byte 0 of @013 to @015
  [-
; travel 2 cells right
  >>
  +
; travel 2 cells left
  <<
  ]
; travel 19 cells left
  <<<<<<<<<<<<<<<<<<<
; byte 3  the top byte first
; travel 3 cells right
  >>>
; move byte 0 of @003 to @011
  [-
; travel 14 cells right
  >>>>>>>>>>>>>>
  +
; travel 14 cells left
  <<<<<<<<<<<<<<
  ]
; travel 14 cells right
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
; move byte 0 of @012 to @003
  [-
; travel 15 cells left
  <<<<<<<<<<<<<<<
  +
; travel 15 cells right
  >>>>>>>>>>>>>>>
  ]
; travel 1 cells right
  >
; move byte 0 of @013 to @015
  [-
; travel 2 cells right
  >>
  +
; travel 2 cells left
  <<
  ]
; travel 19 cells left
  <<<<<<<<<<<<<<<<<<<
; byte 2  the top byte first
; travel 2 cells right
  >>
; move byte 0 of @002 to @011
  [-
; travel 15 cells right
  >>>>>>>>>>>>>>>
  +
; travel 15 cells left
  <<<<<<<<<<<<<<<
  ]
; travel 15 cells right
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
; move byte 0 of @012 to @002
  [-
; travel 16 cells left
  <<<<<<<<<<<<<<<<
  +
; travel 16 cells right
  >>>>>>>>>>>>>>>>
  ]
; travel 1 cells right
  >
; move byte 0 of @013 to @015
  [-
; travel 2 cells right
  >>
  +
; travel 2 cells left
  <<
  ]
; travel 19 cells left
  <<<<<<<<<<<<<<<<<<<
; byte 1  the top byte first
; travel 1 cells right
  >
; move byte 0 of @001 to @011
  [-
; travel 16 cells right
  >>>>>>>>>>>>>>>>
  +
; travel 16 cells left
  <<<<<<<<<<<<<<<<
  ]
; travel 16 cells right
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
; move byte 0 of @012 to @001
  [-
; travel 17 cells left
  <<<<<<<<<<<<<<<<<
  +
; travel 17 cells right
  >>>>>>>>>>>>>>>>>
  ]
; travel 1 cells right
  >
; move byte 0 of @013 to @015
  [-
; travel 2 cells right
  >>
  +
; travel 2 cells left
  <<
  ]
; travel 19 cells left
  <<<<<<<<<<<<<<<<<<<
; byte 0  the top byte first
; move byte 0 of @000 to @011
  [-
; travel 17 cells right
  >>>>>>>>>>>>>>>>>
  +
; travel 17 cells left
  <<<<<<<<<<<<<<<<<
  ]
; travel 17 cells right
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
; move byte 0 of @012 to @000
  [-
; travel 18 cells left
  <<<<<<<<<<<<<<<<<<
  +
; travel 18 cells right
  >>>>>>>>>>>>>>>>>>
  ]
; travel 1 cells right
  >
; move byte 0 of @013 to @015
  [-
; travel 2 cells right
  >>
  +
; travel 2 cells left
  <<
  ]
; travel 19 cells left
  <<<<<<<<<<<<<<<<<<<
; discard the bit shifted out of the bottom byte
; travel 21 cells right
  >>>>>>>>>>>>>>>>>>>>>
  [-]
; travel 21 cells left
  <<<<<<<<<<<<<<<<<<<<<

; emit the shifted value little endian
  .>.>.>.>.>.>.>.>.>.>.>.>.>.>.>.>.
