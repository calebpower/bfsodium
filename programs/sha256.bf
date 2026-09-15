; sha256_poke __ read stdin write the SHA_256 digest to stdout;
;
; cat something | brainstem __ bfi sha256_bf | hx
;
; A file containing nothing but the eight brainfuck instructions reads the
; bytes the shell handed the broker spawns an interpreter on
; sha256/sha256_bf feeds them to it and writes the thirty two byte digest
; back out; It is the ordinary Unix shape __ bytes in digest out __ and it is
; done entirely by a brainfuck program driving another brainfuck program;
;
; WHY THE MESSAGE IS BUFFERED AT ALL since it is the one surprising thing
; here; sha256_bf wants a two byte little_endian LENGTH before the message
; and the length of a stream is not known until the stream ends; So the bytes
; cannot simply be forwarded as they arrive: they have to be held somewhere
; until the count is known and then replayed behind it; A pipe cannot be
; rewound so that somewhere has to be storage this program controls;
;
; IT IS THE TAPE AND NOT A TEMPORARY FILE; An earlier version wrote the bytes
; to bfsha_tmp and let the filesystem do the counting __ stat reports the size
; and the low two bytes of that u64 are already the prefix format __ which was
; cheap and worked and was wrong in kind; It made a hashing program need a
; writable working directory a name nobody else was using and an unlink on
; every exit path including the refusals; Two of those had already gone wrong
; once; Every program written after this one would have inherited the same
; apparatus and a library of cipher suites is not a good place to be managing
; temporary files;
;
; HOW THE TAPE BUFFER WORKS because it is not simply " gt " in a loop; The tape
; holds each byte as a PAIR: a flag cell that is always one then the byte;
; The flag is what makes the buffer walkable; Brainfuck's only test is "is this
; cell zero" and the message may contain zero bytes __ any real file does __
; so a run of raw bytes cannot be traversed: the walk would stop dead in the
; middle of the data believing it had found the end; With a flag beside each
; byte "{ gt  gt }" runs out to the first free slot and "{ lt  lt }" runs back over data
; the loops never look at;
;
; THE COUNT IS KEPT AS THE BYTES ARRIVE in two cells low byte first which is
; already the order sha256_bf wants to read them in; A third cell catches the
; sixty five thousand five hundred and thirty sixth byte: the pair is a u16 and
; wraps so without that flag a larger input would hash its length modulo 65536
; and print a plausible wrong digest; It is refused instead;
;
; COST BECAUSE IT IS THE REAL LIMIT; sha256_bf is about 1_2 billion
; interpreter instructions per 64 byte block __ roughly two seconds; A
; kilobyte is half a minute; A megabyte is about nine hours; Hash small
; things; The buffer walk is quadratic in the message length and is noise
; against that: at the 65535 byte maximum it is some seconds against a hash
; measured in half hours;
;
; IO  in:  the bytes to hash on the broker's stdin any length to 65535
; out: the digest{32} raw on the broker's stdout
;
; A routine declares an INTERFACE here an entry and exit offset and a
; footprint because a routine is PASTED into a caller and those are what make
; that safe; A program is not pasted into anything __ it is the outermost
; thing there is __ so it has no interface to declare and the line is absent
; rather than empty;
;
; TAPE MAP
; cell 0 is the working cell: every EMIT and every READ uses it;
; cell 1 holds the status byte of a read which drives the fill loop;
; cell 2 is the fill loop's continue flag;
; cell 3 holds one byte in flight in the digest loop;
; cell 4 is the fill loop's branch flag;
; cells 5 and 6 hold the message length low byte first;
; cell 7 is the overflow flag: set when the length passes 65535;
; cells 8 9 and 10 are scratch for the counter's carry;
; cell 11 is the digest byte counter thirty two down to zero;
; cell 13 IS THE WALL: it is never written and "{ lt  lt }" comes to rest on it;
; Cells 12 and 14 are padding that keeps the flags on odd cells;
; cells 15 17 19 ;;; are the buffer's flag cells one per byte always one;
; cells 16 18 20 ;;; are the bytes themselves;
;
; INDENTATION IS LOAD BEARING; A comment indented by two or more spaces
; annotates the frame that follows it; a flush one like this is the file
; talking about itself; brainstem's tools/bsframe reads a skeleton by that
; rule;
;
; HANDLES ARE ALLOCATED BEFORE ANYTHING IS CLOSED deliberately; brainstem
; reuses the lowest free slot and bumps its generation so closing early would
; make every later handle carry a generation this file would have to track;
; Nothing here is closed until every handle exists;
;
; Frames transcribed by hand from brainstem's ABI_md sections 3 7_10 to 7_23;
;
; hello  op 01 len 10 magic "BSTM" want major 1 want MINOR 1 flags 0;
; Minor 1 because the spawn below sends an empty path which a 1_0 broker
; would refuse as INVAL halfway through the conversation; asking for it
; here turns that into a clean VERSION refusal at the handshake;
+.+++++++++.----------.+++++++++++++++++++++++++++++++++++++
  +++++++++++++++++++++++++++++.+++++++++++++++++.+.-------.   ; continued
  ----------------------------------------------------------   ; continued
  ------------------.-.+.-...                                  ; continued
,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
  ,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,              ; continued
                                                               ; pipe  op 0e flags 0;  Handles 4 (read) and 5 (write):
                                                               ; this program writes the message into 5 and the child
                                                               ; reads it from 4;
[-]++++++++++++++.------------.--...
,,,,,,,,,,,
                                                               ; pipe again;  Handles 6 (read) and 7 (write): the
                                                               ; child writes the digest into 7 and this program reads
                                                               ; it from 6;
[-]++++++++++++++.------------.--...
,,,,,,,,,,,
                                                               ; spawn  op 0f len 0x26 = 38 __ three less than it was
                                                               ; which is the difference between a two byte empty path
                                                               ; and a five byte "bfi"; dir ffffffff meaning the
                                                               ; broker's working directory flags 0 nfdmap 2 nargv 2
                                                               ; nenv 0 reserved 0
[-]+++++++++++++++.+++++++++++++++++++++++.-----------------
  ---------------------.-....+..++..--..                       ; continued
                                                               ; the descriptor map: child fd 0 gets handle 4 child fd
                                                               ; 1 gets handle 7; ANY CHILD DESCRIPTOR NOT NAMED HERE
                                                               ; IS CLOSED so the child gets these two and nothing
                                                               ; else;
.++++.----...
+.++++++.-------...
                                                               ; THE PATH IS EMPTY meaning "the interpreter the broker
                                                               ; launched this program under" __ brainstem ABI 1_1
                                                               ; section 7_15; This file used to name "bfi" which was
                                                               ; the only name it could know and it was wrong the
                                                               ; moment anyone ran the broker with __interp pointing
                                                               ; elsewhere: the program went on spawning bfi while
                                                               ; running under something else;
..
                                                               ; argv: "bfi" "sha256_bf"; argv{0} stays a literal
                                                               ; because it is a LABEL the child sees not a name
                                                               ; anything resolves;  No environment at all: sha256_bf
                                                               ; reads an exact known byte count and never reads past
                                                               ; it so BFI_EOF cannot matter to it;
+++.---.++++++++++++++++++++++++++++++++++++++++++++++++++++
  ++++++++++++++++++++++++++++++++++++++++++++++.++++.+++.     ; continued
------------------------------------------------------------
  ------------------------------------.---------.+++++++++++   ; continued
  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   ; continued
  ++++++++++++++++++++++++++++++++++++++++++++++.-----------   ; continued
  .-------.-----------------------------------------------.+   ; continued
  ++.+.--------.++++++++++++++++++++++++++++++++++++++++++++   ; continued
  ++++++++.++++.                                               ; continued
,,,,,,,                                                        ; the reply is a process handle: 8
                                                               ; close the outer copies of the child's two ends;
                                                               ; Without this the child never sees end of input and
                                                               ; this program never sees end of file;
[-]++++++++++++.--------.----.++++.----...
,,,
[-]++++++++++++.--------.----.+++++++.-------...
,,,
                                                               ; THE FILL: the broker's stdin handle 1 onto the tape
                                                               ; one byte at a time until end of file counting as it
                                                               ; goes;
;
                                                               ; The loop is driven by the STATUS byte of each read
                                                               ; not by a count; A read of one byte returns OK and
                                                               ; four bytes when there is a byte and END with a zero
                                                               ; length __ three bytes __ when there is not; Both
                                                               ; shapes begin with a status and a two byte length so
                                                               ; those three are always taken; only the data byte is
                                                               ; conditional which is what the branch flag is for;
;
                                                               ; THE STATUS CELL IS SET TO 1 BEFORE IT IS READ and
                                                               ; that is not decoration; '' at end of input leaves the
                                                               ; cell UNCHANGED under this interpreter's default so a
                                                               ; loop that cleared the cell first would read a stale
                                                               ; zero as OK and spin for ever the moment the broker
                                                               ; stopped answering; Presetting it to a non_zero value
                                                               ; makes "no reply at all" arrive as END which is the
                                                               ; only sane reading of it;
;
                                                               ; That is not hypothetical; The oversize guard below
                                                               ; exits brainstem answers and then closes this
                                                               ; program's stdin and the first version of this loop
                                                               ; span until a 1800 second timeout killed it __ with
                                                               ; the broker itself stuck in waitpid for a child that
                                                               ; was never going to finish; ANY brainstem client wants
                                                               ; this idiom; cell 2 is the continue flag: set it and
                                                               ; stand on it; The loop below runs while it holds and
                                                               ; only an END status clears it;
>>+
[
<<                                                             ; back to the working cell which is where every frame
                                                               ; is built
[-]++++++++++.--.--------.+.-...+.-...                         ; read  op 0a handle 1 one byte flags 0
                                                               ; cell 1 takes the status __ SET TO 1 FIRST so that no
                                                               ; reply at all which leaves a cell unchanged arrives as
                                                               ; END rather than as OK; Then cell 0 takes the two
                                                               ; length bytes and discards them: a one byte read
                                                               ; returns one byte or none and the status has already
                                                               ; said which;
>[-]+,<,,
                                                               ; cell 4 is the branch flag set to 1 on the way past;
                                                               ; the pointer comes back to rest on cell 1 the status
                                                               ; for the test below
>>>>+<<<
                                                               ; a non_zero status is END: clear the status the
                                                               ; continue flag in cell 2 so the outer loop stops and
                                                               ; the branch flag in cell 4 so the body below is
                                                               ; skipped;  Clearing the status first is what makes
                                                               ; this run once;
[[-]>[-]>>[-]<<<]
>>>                                                            ; stand on the branch flag
[
                                                               ; the status was OK so a data byte is still in the
                                                               ; pipe;  Walk out to the first free pair and let ''
                                                               ; land the byte STRAIGHT INTO IT: a comma writes
                                                               ; wherever the pointer is standing so the byte never
                                                               ; has to be carried across the tape;  Then flag the
                                                               ; pair and walk home;
>>>>>>>>>>>
[>>]
>,
<+
[<<]
                                                               ; the walk home rests on the wall cell 13;  From there
                                                               ; to cell 5 the low byte of the count and add one;
<<<<<<<<+
                                                               ; the carry;  Cell 5 is copied into cells 8 and 9 and
                                                               ; put back from 9 which leaves cell 8 holding the value
                                                               ; to test and cell 5 untouched __ brainfuck has no way
                                                               ; to ask whether a cell is zero without spending it;
[->>>+>+<<<<]
>>>>[-<<<<+>>>>]
>[-]+                                                          ; cell 10 is the carry flag: one unless cell 8 says the
                                                               ; low byte is non_zero
<<[[-]>>-<<]
>>
[
-                                                              ; the low byte wrapped so the high byte in cell 6 takes
                                                               ; the carry
<<<<+
                                                               ; and the same test again on the high byte: if IT
                                                               ; wrapped the length has passed 65535 and cell 7
                                                               ; remembers it;  That is the whole of the oversize
                                                               ; check __ there is no size to inspect because nothing
                                                               ; was written anywhere;
[->>+>+<<<]
>>>[-<<<+>>>]
>[-]+
<<[[-]>>-<<]
>>[-<<<+>>>]
]
<<<<<<[-]                                                      ; consume the branch flag which is what makes this an
                                                               ; if and not a loop
]
<<                                                             ; back to the continue flag where the outer loop
                                                               ; expects to test
]
                                                               ; THE REFUSAL AND WHY EVERYTHING AFTER IT IS GUARDED;
;
                                                               ; A brainfuck program cannot halt; 'exit' is a frame
                                                               ; not an instruction: brainstem answers it closes this
                                                               ; program's stdin and waits for the interpreter __ and
                                                               ; the interpreter runs straight on into whatever bytes
                                                               ; come next; So a refusal has to make the REST OF THE
                                                               ; FILE do nothing and the only way to say that is a
                                                               ; flag every later section stands inside;
;
                                                               ; Cell 2 finished with as the fill loop's continue flag
                                                               ; becomes that flag; It is set here and cleared by the
                                                               ; refusal and the whole of the rest of the program is
                                                               ; one loop on it that clears it at the end so it runs
                                                               ; once or not at all;
;
                                                               ; This is not tidiness; The replay below is driven by
                                                               ; the BUFFER not by a status so after a refusal it
                                                               ; would cheerfully emit one write frame per buffered
                                                               ; byte into a pipe nobody is reading fill it and block
                                                               ; for ever with the broker stuck in waitpid __ which is
                                                               ; exactly what it did; An earlier version of this
                                                               ; program had the same flaw and got away with it
                                                               ; because the only thing after ITS refusal was a
                                                               ; status_driven loop that saw end of input at once and
                                                               ; forty frames that fit in the pipe; Sixty five
                                                               ; thousand do not; cell 2 is the proceed flag
+
                                                               ; cell 7 is set only if the message will not fit in
                                                               ; sha256_bf's two byte length;  Hashing it anyway would
                                                               ; print a plausible wrong digest so refuse; There is
                                                               ; nothing to clean up: no file was made;
>>>>>
[
<<<<<[-]                                                       ; clear the proceed flag so nothing below this runs
<<                                                             ; back to the working cell to say so
[-]++.-.-.+.                                                   ; exit  op 02 len 1 code 1
,,,
>>>>>>>[-]                                                     ; clear cell 7 so this refuses once rather than for
                                                               ; ever
]
                                                               ; stand on the proceed flag: everything from here to
                                                               ; the end of the file is inside this loop
<<<<<
[
<<                                                             ; back to the working cell
                                                               ; write  op 0b handle 5 flags 0 the two length bytes __
                                                               ; sha256_bf's prefix which is the count this program
                                                               ; has been keeping all along;
[-]+++++++++++.---.--------.+++++.-----.....
>>>>>.>.<<<<<<                                                 ; emitted from cells 5 and 6 low byte first which is
                                                               ; the order it wants
                                                               ; THE REPLY IS DRAINED BY ITS DECLARED LENGTH not by an
                                                               ; assumed one; A write that succeeds replies with
                                                               ; nwritten{2}; a write that FAILS replies with no
                                                               ; payload at all because ABI rule I6 says an error
                                                               ; response never carries one; A plain "READ 5"
                                                               ; therefore swallows the next reply's first two bytes
                                                               ; the first time a write fails and every frame after
                                                               ; that is shifted __ the silent desync the ABI names as
                                                               ; the realistic catastrophic failure; It is reachable
                                                               ; here: if sha256_bf is missing the child dies at exec
                                                               ; and the very next write to its stdin is PIPE 07 with
                                                               ; no payload;
>[-]+,
>>>>>>>>[-],
<<<<<<<<<,
>>>>>>>>>
[-<<<<<<<<<,>>>>>>>>>]
<<<<<<<<<
                                                               ; THE REPLAY: the buffer pair by pair into the child's
                                                               ; stdin handle 5;
;
                                                               ; This loop CONSUMES the buffer and it has to leave a
                                                               ; way home; The frame header is emitted at the flag
                                                               ; cell which destroys the flag; the reply is read into
                                                               ; the byte cell which destroys the byte; So each pair
                                                               ; is rebuilt as it is passed: the flag is left at zero
                                                               ; and the BYTE cell is set to one turning the trail of
                                                               ; flags into a trail of bytes running the other way;
                                                               ; Without it the pointer would finish an unknown
                                                               ; distance from home with nothing to walk back over;
>>>>>>>>>>>>>>>
[
                                                               ; write  op 0b handle 5 flags 0 one byte;  This is
                                                               ; emitted AT the flag cell and so clears it which is
                                                               ; exactly what the trail above wants;
[-]+++++++++++.----.-------.+++++.-----.....
                                                               ; the header is literal and the byte is not so the byte
                                                               ; goes out from the pair's own second cell with raw
                                                               ; brainfuck
>.
                                                               ; THE REPLY IS DRAINED BY ITS DECLARED LENGTH HERE TOO
                                                               ; and it has to be done IN PLACE: the pointer is
                                                               ; halfway along the buffer so the fixed cells the other
                                                               ; two drains use are an unknown distance away; The pair
                                                               ; itself is the scratch; The flag cell has already been
                                                               ; spent by the EMIT above and is holding zero so it can
                                                               ; take the length; the byte cell has already been sent
                                                               ; and can take everything else; the status discarded __
                                                               ; a failed write here means the child is gone and the
                                                               ; loop below will drain the rest of the buffer into a
                                                               ; closed pipe and finish which is the right shape for a
                                                               ; child that died
,
<[-],                                                          ; the low length byte into the flag cell the high one
                                                               ; discarded
>,
<                                                              ; then exactly that many payload bytes
[->,<]
>
[-]+                                                           ; lay the trail: this cell is now the walkable one
>                                                              ; on to the next pair's flag which is what the loop
                                                               ; tests
]
<[<<]<<<<<<<<<<<<<<                                            ; home along the trail of bytes to cell 14 then to the
                                                               ; working cell
[-]++++++++++++.--------.----.+++++.-----...                   ; close handle 5 so the child sees end of input
,,,
                                                               ; THE DIGEST thirty two bytes one at a time from handle
                                                               ; 6 to handle 2;
;
                                                               ; A read of ONE byte is the only read from a stream
                                                               ; that is deterministic: it blocks until there is a
                                                               ; byte and then returns exactly it; The first of these
                                                               ; is where the child's work is waited on because it
                                                               ; writes nothing until it has hashed; cell 11 counts
                                                               ; the digest down from thirty two AND the status is
                                                               ; checked as well; It used to be counted alone on the
                                                               ; grounds that the length was known and a miscount
                                                               ; would desync rather than truncate __ which was true
                                                               ; of a child that runs and false of one that does not;
                                                               ; With sha256_bf missing the interpreter cannot exec it
                                                               ; handle 6 answers END with an empty payload and a loop
                                                               ; that read a data byte anyway blocked for a fourth
                                                               ; byte that was never coming; That is the desync it was
                                                               ; trying to avoid arrived at from the other side;
;
                                                               ; Keeping BOTH is what is wanted; The count still says
                                                               ; how many bytes a digest has so a short answer comes
                                                               ; out short and visibly wrong rather than being waited
                                                               ; on for ever; the status says when to stop asking;
>>>>>>>>>>>++++++++++++++++++++++++++++++++
[
<<<<<<<<<<<                                                    ; back to the working cell
[-]++++++++++.--.--------.++++++.------...+.-...               ; read  op 0a handle 6 one byte flags 0
>[-]+,<,,                                                      ; cell 1 takes the status preset so that no reply at
                                                               ; all reads as END
>>>>+<<<                                                       ; cell 4 is the branch flag set on the way past
                                                               ; an END means the child stopped early: clear the
                                                               ; status the branch flag and the counter which ends the
                                                               ; loop without a byte to write
[[-]>>>[-]>>>>>>>[-]<<<<<<<<<<]
>>>                                                            ; stand on the branch flag
[
<,<<<                                                          ; cell 3 takes the digest byte then back to the working
                                                               ; cell
[-]+++++++++++.----.-------.++.--.....                         ; write  op 0b handle 2 __ the broker's stdout __ flags
                                                               ; 0 one byte
; emit it from cell 3 the header above having been literal
>>>.<<<
                                                               ; THE REPLY IS DRAINED BY ITS DECLARED LENGTH not by an
                                                               ; assumed one; A write that succeeds replies with
                                                               ; nwritten{2}; a write that FAILS replies with no
                                                               ; payload at all because ABI rule I6 says an error
                                                               ; response never carries one; A plain "READ 5"
                                                               ; therefore swallows the next reply's first two bytes
                                                               ; the first time a write fails and every frame after
                                                               ; that is shifted __ the silent desync the ABI names as
                                                               ; the realistic catastrophic failure; It is reachable
                                                               ; here: if sha256_bf is missing the child dies at exec
                                                               ; and the very next write to its stdin is PIPE 07 with
                                                               ; no payload;
>[-]+,
>>>>>>>>[-],
<<<<<<<<<,
>>>>>>>>>
[-<<<<<<<<<,>>>>>>>>>]
<<<<<<<<<
                                                               ; ONE BYTE DONE: count cell 11 down INSIDE the branch
                                                               ; not outside it; A decrement that also ran on the END
                                                               ; path took the counter from nought to 255 and the loop
                                                               ; never ended __ a live spin rather than a block so the
                                                               ; broker's op timeout never fired either and only the
                                                               ; outer wall clock stopped it;
>>>>>>>>>>>-
<<<<<<<[-]                                                     ; then consume the branch flag which is what makes this
                                                               ; an if
]
>>>>>>>                                                        ; stand on the counter where the outer loop expects to
                                                               ; test
]
<<<<<<<<<<<                                                    ; back to the working cell
                                                               ; wait  op 10 handle 8 flags 0 __ blocking;  The reply
                                                               ; is status two length bytes then state{1} code{1}
                                                               ; signal{1} reserved{1};
;
                                                               ; THE CHILD'S EXIT CODE BECOMES THIS PROGRAM'S; Run
                                                               ; this in a directory with no sha256_bf in it: the
                                                               ; interpreter cannot exec it the child exits 127
                                                               ; nothing is hashed __ and a program that reported
                                                               ; success there would be indistinguishable from one
                                                               ; that hashed correctly into something that swallowed
                                                               ; the output;
;
                                                               ; The shell sees 1 rather than 127 because brainstem
                                                               ; collapses any nonzero program exit into its own small
                                                               ; pinned set so that 70 and 71 keep meaning what they
                                                               ; say; The distinction that survives is the one worth
                                                               ; having;
[-]++++++++++++++++.----------.------.++++++++.--------.....
,,,,
                                                               ; cell 3 takes the code; the state byte before it and
                                                               ; the two after tell a caller nothing it does not
                                                               ; already have
>>>,<<<
,,
                                                               ; close everything still open: the digest pipe and the
                                                               ; process handle; Closing a process handle stops
                                                               ; tracking the child; it does not kill it;
[-]++++++++++++.--------.----.++++++.------...
,,,
[-]++++++++++++.--------.----.++++++++.--------...
,,,
[-]++.-.-.                                                     ; exit  op 02 len 1 and the code is the child's own out
                                                               ; of cell 3
>>>.<<<
,,,
                                                               ; consume the proceed flag which is what makes the
                                                               ; block above run once rather than for ever
>>[-]
]
