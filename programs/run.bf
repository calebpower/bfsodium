; run_poke __ run any routine in this library named at run time;
;
; { printf '\011sha256_bf'; printf '\003\000abc'; } | brainstem __ bfi run_bf
;
; tools/bfrun_sh builds that prefix for you; see it before typing one by hand;
;
; WHAT THIS IS AND WHY IT IS NOT programs/sha256; That program presents an
; ORDINARY UNIX INTERFACE __ bytes in digest out __ and to do it it has to
; know sha256/sha256_bf's calling convention: buffer the stream count it and
; emit len{2} LE ahead of it; That knowledge is the whole of its value and the
; whole of why it cannot be generic; Every routine declares a different IO
; line: hmac wants a key and a message hkdf wants salt and ikm and info and a
; length the AEAD wants key and nonce and aad and plaintext;
;
; So this is the other half; THE CALLER DOES THE FRAMING and the runner is a
; pure relay: it reads a routine name spawns an interpreter on it pumps
; stdin into it and pumps its answer back out; It knows nothing about any
; routine and therefore works with all of them including ones not yet
; written;
;
; It is also SMALLER and has NO SIZE LIMIT and both follow from the same
; fact; programs/sha256 caps its input at 65535 bytes because IT supplies the
; u16 length prefix; nothing here supplies a length so nothing here has a
; u16 to overflow; There is no tape buffer either __ a relay never needs to
; see a byte twice;
;
; THE ONE REAL LIMITATION and it is a hang rather than a wrong answer; The
; relay is SEQUENTIAL: all of stdin goes into the routine then the routine's
; output comes back; If a routine writes as it reads __ aead/chacha20poly1305
; does sixteen bytes at a time __ and its output fills the pipe before its
; input is done the routine blocks writing while this program blocks writing
; and neither moves; The pipe is 64 KiB on both platforms so it takes an
; input that large to provoke which at two seconds per block is hours of
; work before it happens;
;
; The fix is poll op 0d which brainstem has: drive both directions from one
; poll rather than one after the other; It is not done here because it roughly
; doubles a file whose whole value is being small and because the failure it
; prevents ends in the broker's op timeout with a diagnosis rather than
; silently; When something needs it that is the change;
;
; A NAME LONGER THAN 226 BYTES declares a wrong frame length __ the length is
; 29 plus the name and this program does not carry the u16 into a second byte
; __ and the broker answers BADLEN and exits 70; It is loud and no routine
; filename is 226 bytes; A name containing a NUL breaks the walk that reads it
; and is a caller error for the same reason;
;
; IT ASKS FOR MINOR 1 because the spawn below sends a zero length path which
; brainstem 1_1 reads as "the interpreter the broker launched this program
; under"; Nothing here names an interpreter so nothing here can name the
; wrong one;
;
; IO  in:  namelen{1}  name{namelen}  then whatever the routine reads
; out: whatever the routine writes
;
; A routine declares an INTERFACE here because a routine is PASTED into a
; caller; A program is the outermost thing there is so it has none;
;
; TAPE MAP
; cell 0 is the working cell: every EMIT and every READ uses it;
; cell 1 holds the status byte of a read;
; cell 3 holds one byte in flight in the two relay loops;
; cell 4 is the branch flag: set before a read cleared by an END status;
; cell 5 holds the name length as the caller sent it;
; cell 6 counts that length down while the name is read;
; cell 7 is the spawn frame's low length byte 29 plus the name length;
; cell 8 is a relay loop's continue flag;
; cell 9 is scratch for the one piece of arithmetic here;
; cell 11 IS THE WALL: it is never written and "{ lt }" comes to rest on it;
; cells 12 upward hold the name one byte per cell; No flag cells are needed
; __ unlike programs/sha256's buffer __ because a FILENAME CANNOT
; CONTAIN A NUL so the bytes are their own walkable trail and a zero
; cell already means "past the end";
;
; INDENTATION IS LOAD BEARING; A comment indented by two or more spaces
; annotates the frame that follows it; a flush one is the file talking about
; itself;
;
; Frames transcribed by hand from brainstem's ABI_md sections 3 7_10 to 7_16;
;
+.+++++++++.----------.+++++++++++++++++++++++++++++++++++++   ; hello  op 01 len 10 want major 1 and MINOR 1 __ see
  +++++++++++++++++++++++++++++.+++++++++++++++++.+.-------.   ; above;
  ----------------------------------------------------------   ; continued
  ------------------.-.+.-...                                  ; continued
,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
  ,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,              ; continued
                                                               ; pipe  op 0e flags 0;  Handles 4 (read) and 5 (write):
                                                               ; this program writes the routine's input into 5 and
                                                               ; the routine reads it from 4;
[-]++++++++++++++.------------.--...
,,,,,,,,,,,
                                                               ; pipe again;  Handles 6 (read) and 7 (write): the
                                                               ; routine writes its answer into 7 and this program
                                                               ; reads it from 6;
[-]++++++++++++++.------------.--...
,,,,,,,,,,,
[-]++++++++++.--.--------.+.-...+.-...                         ; read  op 0a handle 1 one byte: the name length;
                                                               ; cell 1 takes the status SET TO 1 FIRST so that no
                                                               ; reply at all arrives as END rather than as OK;  Then
                                                               ; cell 0 takes the two length bytes;
>[-]+,<,,
                                                               ; cell 4 is the branch flag set on the way past; the
                                                               ; pointer rests on the status for the test below
>>>>+<<<
                                                               ; a non_zero status means there was no input at all;
                                                               ; Clear the status and the branch flag which leaves the
                                                               ; name length at zero __ and a zero length name reaches
                                                               ; execve as an empty argument and fails loudly which is
                                                               ; the right answer to being handed nothing;
[[-]>>>[-]<<<]
>>>                                                            ; stand on the branch flag
[
>,                                                             ; cell 5 takes the name length then the branch flag is
                                                               ; consumed
<[-]
]
<<<<                                                           ; back to the working cell
                                                               ; cell 7 is the spawn frame's low length byte: 29 fixed
                                                               ; bytes plus the name; Twenty nine is dir{4} flags{2}
                                                               ; nfdmap{1} nargv{1} nenv{1} reserved{1} two descriptor
                                                               ; mappings at five each an empty path at two "bfi" at
                                                               ; five and the name's own two byte prefix;
>>>>>>>[-]+++++++++++++++++++++++++++++
                                                               ; add the name length keeping it: cell 5 goes to cells
                                                               ; 7 and 9 and cell 9 puts it back;  Brainfuck has no
                                                               ; way to read a cell without spending it;
<<[->>+>>+<<<<]
>>>>[-<<<<+>>>>]
<<<<[->+>>>+<<<<]                                              ; cell 6 takes a second copy to count down while the
                                                               ; name is read
>>>>[-<<<<+>>>>]
<<<                                                            ; stand on that countdown
[
<<<<<<                                                         ; back to the working cell
[-]++++++++++.--.--------.+.-...+.-...                         ; read  op 0a handle 1 one byte of the name
>[-]+,<,,
>>>>+<<<
                                                               ; an END here means the name was shorter than its
                                                               ; length said;  Clear the status the branch flag and
                                                               ; the countdown which ends this loop;
[[-]>>>[-]>>[-]<<<<<]
>>>                                                            ; stand on the branch flag
[
                                                               ; out to the name area on to the first cell not yet
                                                               ; written and let the comma land the byte straight
                                                               ; there __ a comma writes wherever the pointer stands
                                                               ; so the byte never has to be carried across the tape;
>>>>>>>>
[>]
,
                                                               ; home along the name itself;  The bytes are their own
                                                               ; trail: a filename has no NUL in it so "{ lt }" cannot
                                                               ; stop early and it comes to rest on the wall;
[<]
<<<<<-                                                         ; one byte done: count it off and consume the branch
                                                               ; flag
<<[-]
]
>>                                                             ; back to the countdown where the outer loop expects to
                                                               ; test
]
<<<<<<                                                         ; back to the working cell
                                                               ; spawn  op 0f;  The length is not a literal __ it is
                                                               ; cell 7 __ so the opcode the length and the payload
                                                               ; are emitted in three pieces;
[-]+++++++++++++++.
>>>>>>>.<<<<<<<
[-].                                                           ; the length's high byte which is always zero: see the
                                                               ; note on 226 above
                                                               ; dir ffffffff meaning the broker's working directory
                                                               ; flags 0 nfdmap 2 nargv 2 nenv 0 reserved 0
-....+..++..--..
                                                               ; the descriptor map: child fd 0 gets handle 4 child fd
                                                               ; 1 gets handle 7; ANY CHILD DESCRIPTOR NOT NAMED HERE
                                                               ; IS CLOSED;
.++++.----...
+.++++++.-------...
                                                               ; THE PATH IS EMPTY: the interpreter the broker
                                                               ; launched this program under;  ABI_md section 7_15
                                                               ; added at 1_1;
..
+++.---.++++++++++++++++++++++++++++++++++++++++++++++++++++   ; argv{0} is the label "bfi" which nothing resolves
  ++++++++++++++++++++++++++++++++++++++++++++++.++++.+++.     ; continued
>>>>>.<<<<<                                                    ; argv{1} is the name and its u16 prefix is the length
                                                               ; from cell 5
[-].
>>>>>>>>>>>>[.>]<[<]<<<<<<<<<<<                                ; then the name itself out of the tape and home again
,,,,,,,                                                        ; the reply is a process handle: 8
                                                               ; close the outer copies of the child's two ends;
                                                               ; Without this the routine never sees end of input and
                                                               ; this program never sees end of file;
[-]++++++++++++.--------.----.++++.----...
,,,
[-]++++++++++++.--------.----.+++++++.-------...
,,,
                                                               ; THE FIRST RELAY: the broker's stdin handle 1 into the
                                                               ; routine's stdin handle 5 one byte at a time until end
                                                               ; of file;  Nothing is stored: a relay never needs to
                                                               ; see a byte twice which is the whole difference
                                                               ; between this file and programs/sha256; cell 8 is the
                                                               ; continue flag: set it and stand on it
>>>>>>>>+
[
<<<<<<<<
[-]++++++++++.--.--------.+.-...+.-...
>[-]+,<,,
>>>>+<<<
                                                               ; a non_zero status is END: clear the status the
                                                               ; continue flag and the branch flag and this loop is
                                                               ; done
[[-]>>>[-]>>>>[-]<<<<<<<]
>>>
[
<,<<<                                                          ; the status was OK so a data byte is pending: cell 3
                                                               ; takes it
[-]+++++++++++.----.-------.+++++.-----.....                   ; write  op 0b handle 5 flags 0 that byte
>>>.<<<
                                                               ; THE REPLY IS DRAINED BY ITS DECLARED LENGTH not by an
                                                               ; assumed one and that is not fussiness; A write that
                                                               ; succeeds replies with nwritten{2}; a write that FAILS
                                                               ; replies with no payload at all because ABI rule I6
                                                               ; says an error response never carries one; A plain
                                                               ; "READ 5" therefore swallows the next reply's first
                                                               ; two bytes the first time a write fails and every
                                                               ; frame after that is shifted __ the desync the ABI
                                                               ; names as the realistic catastrophic failure worse
                                                               ; than a deadlock because it is silent;
;
                                                               ; It is reachable: kill the routine and the very next
                                                               ; write to its stdin is PIPE 07 with an empty payload;
                                                               ; Reading the length and consuming exactly that many
                                                               ; bytes is correct for both shapes and for every
                                                               ; status; cell 1 takes the status preset so that no
                                                               ; reply at all is not a false OK
>[-]+,
>>>>>>>>[-],                                                   ; cell 9 takes the low length byte cell 0 takes the
                                                               ; high one and drops it
<<<<<<<<<,
>>>>>>>>>                                                      ; then exactly that many payload bytes into the working
                                                               ; cell
[-<<<<<<<<<,>>>>>>>>>]
<<<<<<<<<
>>>>[-]                                                        ; consume the branch flag
]
>>>>                                                           ; back to the continue flag
]
<<<<<<<<                                                       ; back to the working cell
[-]++++++++++++.--------.----.+++++.-----...                   ; close handle 5 so the routine sees end of input and
                                                               ; gets to work
,,,
                                                               ; THE SECOND RELAY: the routine's stdout handle 6 into
                                                               ; the broker's stdout handle 2 until the routine closes
                                                               ; it;  The first read here is where the routine's work
                                                               ; is waited on because a routine that reads all its
                                                               ; input before computing writes nothing until it has
                                                               ; finished;
>>>>>>>>+
[
<<<<<<<<
[-]++++++++++.--.--------.++++++.------...+.-...
>[-]+,<,,
>>>>+<<<
[[-]>>>[-]>>>>[-]<<<<<<<]
>>>
[
<,<<<
[-]+++++++++++.----.-------.++.--.....                         ; write  op 0b handle 2 __ the broker's stdout __ flags
                                                               ; 0 one byte
>>>.<<<
                                                               ; THE REPLY IS DRAINED BY ITS DECLARED LENGTH not by an
                                                               ; assumed one and that is not fussiness; A write that
                                                               ; succeeds replies with nwritten{2}; a write that FAILS
                                                               ; replies with no payload at all because ABI rule I6
                                                               ; says an error response never carries one; A plain
                                                               ; "READ 5" therefore swallows the next reply's first
                                                               ; two bytes the first time a write fails and every
                                                               ; frame after that is shifted __ the desync the ABI
                                                               ; names as the realistic catastrophic failure worse
                                                               ; than a deadlock because it is silent;
;
                                                               ; It is reachable: kill the routine and the very next
                                                               ; write to its stdin is PIPE 07 with an empty payload;
                                                               ; Reading the length and consuming exactly that many
                                                               ; bytes is correct for both shapes and for every
                                                               ; status; cell 1 takes the status preset so that no
                                                               ; reply at all is not a false OK
>[-]+,
>>>>>>>>[-],                                                   ; cell 9 takes the low length byte cell 0 takes the
                                                               ; high one and drops it
<<<<<<<<<,
>>>>>>>>>                                                      ; then exactly that many payload bytes into the working
                                                               ; cell
[-<<<<<<<<<,>>>>>>>>>]
<<<<<<<<<
>>>>[-]
]
>>>>
]
<<<<<<<<
                                                               ; wait  op 10 handle 8 flags 0 __ blocking;  The reply
                                                               ; is status two length bytes then state{1} code{1}
                                                               ; signal{1} reserved{1};
;
                                                               ; THE ROUTINE'S EXIT CODE BECOMES THIS PROGRAM'S which
                                                               ; is the difference between a runner and a pipe; Ask
                                                               ; for a routine that is not there: the interpreter
                                                               ; cannot exec it the child exits 127 and this program
                                                               ; exits 127 rather than reporting a success with no
                                                               ; output __ which is what a runner that ignored the
                                                               ; code would do and is indistinguishable from a routine
                                                               ; that correctly produced nothing;
;
                                                               ; THE SHELL SEES 1 NOT 127 and that is the broker's
                                                               ; contract rather than a loss here; brainstem's own
                                                               ; exit codes are a small pinned set __ 0 1 2 70 71 72
                                                               ; __ and src/broker_c collapses any nonzero program
                                                               ; exit to 1 so that 70 and 71 keep meaning what they
                                                               ; say; The distinction that survives is the one worth
                                                               ; having: the routine failed;
[-]++++++++++++++++.----------.------.++++++++.--------.....
,,,,
                                                               ; cell 3 takes the code; the state byte before it and
                                                               ; the two after are of no use to a caller that already
                                                               ; has the code
>>>,<<<
,,
                                                               ; close the pipe end and the process handle;  Closing a
                                                               ; process handle stops tracking the child; it does not
                                                               ; kill it;
[-]++++++++++++.--------.----.++++++.------...
,,,
[-]++++++++++++.--------.----.++++++++.--------...
,,,
[-]++.-.-.                                                     ; exit  op 02 len 1 and the code is the routine's own
                                                               ; out of cell 3
>>>.<<<
,,,
