# programs

**A routine computes. A program does something.**

Everything else in this repository is a routine: it reads its input on stdin,
writes its output on stdout, performs one operation, and can be checked against
a Cryptol specification and a known-answer test. That purity is what makes a
routine portable to any conforming interpreter and verifiable by two oracles,
and `CONVENTIONS.md` protects it in as many words — *bfsodium is pure
computation: plain stdin/stdout, no syscalls, no P1 broker.*

The things in this directory are not that. A program **sequences** routines: it
opens a file, spawns an interpreter on a routine, feeds it bytes, reads the
answer back and passes it on. It cannot do any of that with `,` and `.` alone,
so it speaks a byte protocol to a broker — [brainstem](https://github.com/calebpower/brainstem),
which is P1 of the same three-phase scheme this library is P2 of.

## The line, and it draws itself

**Can this thing be specified in Cryptol? Then it is a routine. Can it not?
Then it is a program.**

Cryptol describes functions. A sequence of I/O is not a function, so the
question separates the two kinds exactly, and nobody has to exercise judgment
about which directory a file belongs in.

Read it as *in principle*, not *in practice*. A pure routine nobody has written
a spec for yet is still a routine — otherwise the line would move every time
the tree's Cryptol coverage changed, which is the opposite of a definition.

**A program is still standard brainfuck.** It does not stop being brainfuck by
speaking a protocol; that is the entire thesis brainstem exists to demonstrate.
What a program does *not* get is a Cryptol oracle, because there is nothing
here for Cryptol to say.

And the boundary enforces itself, which is why there is no lint for it: a
routine that emitted protocol frames would fail its own known-answer test,
because a KAT compares stdout and frames are extra bytes on stdout.

### Two legibility rules, because there are two portability claims

This is the part that surprised me and is worth stating plainly: **the routine
tiers do not run on `programs/`.**

A routine is COMMENTED brainfuck — a title, an `IO` line, a `TAPE MAP`,
annotations at column 64, no run of more than twelve code lines without one.
That floor is this project's central promise and `bflint` and `bfstyle`
enforce it.

A program is BARE brainfuck: nothing but the eight instructions. It has to be,
because it must run under **any** conforming interpreter, and `;` comments are
an extension of the pinned one. Demanding the routine floor of a program would
demand comments that break the program's own claim.

So `programs/` is covered by tier 12 instead, where brainstem's `bsbf` proves
bareness directly — the mechanical form of the claim the whole scheme rests
on. Its legibility lives where a routine's does: in the skeleton. Nothing is
uncovered; the coverage follows the artifact's portability claim rather than
its directory.

## `.poke`, not `.skel`

The two skeleton formats in this project's world are siblings in philosophy and
unrelated in syntax. A program is written as a `.poke`.

| | `.skel` (routines) | `.poke` (programs) |
|---|---|---|
| expanded by | `tools/bfexpand.sh` | brainstem's `tools/bfgen.sh` |
| directives | `Rn` / `Ln`, `@@NAME@@` | `EMIT <hex>`, `READ n`, `LOOP` / `END` |
| mechanises | tape arithmetic | protocol frames |
| saves you | counting a run of forty six arrows; remembering that `add32` wants base plus 8 while `rotl32` wants base plus 4 | counting the 143 `+` characters it takes to emit `0x8f` |

Both refuse to be compilers, for the same reason and in almost the same words.
`bfexpand` chooses no tape layout and computes no offset from a name.
`bfgen` knows no op names, no lengths and no frame construction, and has no
path into brainstem's `ABI.md` — **every hex byte in every skeleton here is a
number a person read out of that specification and typed.** If a program built
its requests with the same encoder the broker parses them with, a byte-order
bug would be invisible to every test either project has. brainstem's suite
enforces that by grepping its own expander for op names and opcodes.

So: **mechanise the drudgery, never the knowledge.** Twice, independently,
because they are two different drudgeries.

### The one rule that is easy to miss

**Indentation is load bearing in a `.poke`.** A comment indented by two or more
spaces annotates the frame that follows it. A flush comment is the file talking
about itself. brainstem's `tools/bsframe skeleton` reads a skeleton by that
rule in order to check that the prose above each frame describes the bytes
below it, so an indented `TAPE MAP` arrives as though it described the
handshake.

## Where the expander comes from

There is no copy of `bfgen.sh` in this repository, deliberately. Two copies of
an expander are two things that can disagree about what a `.poke` means.
`tools/guest-setup.sh` clones brainstem at `BRAINSTEM_COMMIT` and builds it, and
the suite uses the expander and the broker from that checkout.

**That pin is also a progress marker.** While it names a SHA, this library
tracks a moving dependency. The day it names a *tag* is the day v1.0.0 is close
— because a library depending on an untagged commit of its infrastructure is
not one anybody should depend on either.

## What is here

| program | does | oracle |
|---|---|---|
| `sha256.poke` | reads stdin, writes the SHA-256 digest to stdout | FIPS 180-4, end to end, at three lengths |
| `run.poke` | runs **any** routine, named at run time | three routines with nothing in common |

## Two shapes, and the difference is who does the framing

**An adapter** hides one routine's calling convention behind an ordinary Unix
interface. `sha256.poke` is one: `cat file | … | hx`, no framing, no length —
and to manage that it must know that `sha256/sha256.bf` wants `len{2} LE`
first, must buffer the stream to count it, and must therefore cap the input at
65535. *The friendly interface is precisely the part that cannot be generic*,
because every routine's `IO` line is different.

**A runner** does the opposite: the caller frames the input exactly as the
routine's own header specifies, and the program is a pure relay. It knows
nothing about any routine, which is why it works with all of them — including
ones not yet written.

```sh
printf '\003\000abc' | sh tools/bfrun.sh sha256.bf | ./tools/hx
printf '\007\005'    | sh tools/bfrun.sh add8.bf   | ./tools/hx   # 7+5 -> 0c00
```

`tools/bfrun.sh` exists to write one byte for you — `run.bf` reads a name
length before the name, and typing an octal escape and counting characters is
wrong once in twenty and looks like a broken routine when it is.

Because nothing here supplies a length, **the runner has no size limit** and
no tape buffer: a relay never needs to see a byte twice. It is also smaller
than the adapter.

Its one real limitation is a hang rather than a wrong answer. The relay is
**sequential** — all of stdin into the routine, then the routine's answer
back — so a routine that writes as it reads, as `aead/chacha20poly1305` does,
can fill the 64 KiB pipe before its input is finished and deadlock against
itself. `poll` (op `0d`) is the fix and brainstem has it; it is not done
because it roughly doubles a file whose whole value is being small, and
because the failure ends in the broker's op timeout with a diagnosis.

```sh
cat something | sh tools/bfprog.sh programs/sha256.bf | ./tools/hx
sh tools/bfprog.sh programs/sha256.bf < something > digest.bin
```

Bytes in, digest out, the ordinary Unix shape — done entirely by a brainfuck
program driving another brainfuck program. `tools/bfprog.sh` is the supported
way to run one; a routine is `bfi routine.bf < input` and a program cannot be,
which is most of what makes it a program.

**A program takes no input filename, and could not usefully take one.** Its
bytes arrive on the *broker's* stdin, which it reads sequentially and never
seeks, so a filename would be a second spelling of a redirect — and the only
spelling of the two that cannot be a pipe.

**And it does not name its interpreter either.** `sha256.poke` used to emit
`03 00 62 66 69` — the string `bfi` — because that was the only name it could
know, which made it wrong the moment anybody ran `brainstem --interp`
something else: the program went on spawning `bfi` while running under
another interpreter. brainstem **1.1** gives a zero length `spawn` path the
meaning *the interpreter the broker launched you under*, so the program now
sends `00 00` and cannot be wrong about it. It asks for minor 1 in its
handshake, which turns an older broker into a clean refusal at the handshake
rather than an `INVAL` from `spawn` mid-conversation.

That is also why the pin moved. It cost 217 bytes of committed brainfuck,
downward: `0x62` is ninety eight `+` characters from a cleared cell, and there
is now one `bfi` in the file rather than two.

### The buffer, which is the one surprising thing

`sha256/sha256.bf` wants a two byte little-endian **length** before the
message, and the length of a stream is not known until the stream ends. So the
bytes cannot be forwarded as they arrive: they have to be held until the count
is known and then replayed behind it. A pipe cannot be rewound, so the program
has to hold them itself.

**It holds them on the tape, and this is not simply `,>` in a loop.**
Brainfuck's only test is *is this cell zero*, and a real message contains zero
bytes — so a run of raw bytes cannot be walked back over: the walk would stop
dead in the middle of the data believing it had found the end. Each byte is
therefore stored as a **pair**, a flag cell that is always one followed by the
byte, and `[>>]` runs out to the first free slot while `[<<]` runs home, over
data the loops never look at.

The count is kept in two cells as the bytes arrive, low byte first, which is
already the order the routine reads them in. A third cell catches the 65536th
byte: the pair is a `u16` and wraps, so without it a larger input would hash
its length modulo 65536 and print a plausible, wrong digest. It is **refused**
instead, exit 1 and no output.

The walk is quadratic in the message length and is noise against the hash — at
the 65535 byte maximum it is about twenty seconds, against thirty minutes of
hashing.

#### It used to be a temporary file

Writing the bytes to `bfsha.tmp` and letting `stat` report the size was cheaper
— the low two bytes of a little-endian `u64` size are already the prefix
format, so it cost no arithmetic at all — and it was wrong in kind. It made a
*hashing program* require a writable working directory, a filename nobody else
was using, and an `unlink` on every exit path including the refusals. Two of
those had already gone wrong once. Every program written after this one would
have inherited the apparatus, and a library of cipher suites is a bad place to
be managing temporary files.

**Verified at the boundary**, which is the only place a limit means anything:

| input | | |
|---|---|---|
| 65535 bytes | exit 0, correct digest | 1862 s, 1024 blocks |
| 65536 bytes | exit 1, no output | 23 seconds, nearly all of it the buffer walk |

Neither is in the suite: the refusal needs a 64 KiB fixture and the acceptance
is half an hour. The lengths tier 12 does run are chosen to cover the fill
loop's boundary and the length prefix instead. This table is the record that
somebody checked.

The refusal case has now earned its keep twice. It found brainstem's `spawn`
deadlock, by hanging for fifteen minutes rather than exiting. And it found the
defect below, which nothing smaller could have.

#### A program cannot halt, so a refusal has to be a flag

`exit` is a frame, not an instruction. brainstem answers it, closes the
program's stdin and waits for the interpreter — and **the interpreter runs
straight on into whatever bytes come next**. So everything after a refusal has
to be made not to run, and the only way to say that in brainfuck is a flag the
rest of the file stands inside.

The replay is driven by the *buffer*, not by a read status. Without the flag it
emitted one write frame per buffered byte into a pipe nobody was reading,
filled it, and blocked for ever with the broker stuck in `waitpid`. The
temporary-file version had the same flaw and got away with it, because the only
thing after its refusal was a status-driven loop that saw end of input at once,
and forty frames that fit in the pipe. Sixty five thousand do not.

### Cost, because it decides what is worth writing

SHA-256 is about 1.2 billion interpreter instructions per 64 byte block,
roughly **two seconds**. Measured end to end through the broker:

| input | wall |
|---|---|
| empty | ~2 s |
| 3 bytes | ~1 s |
| 100 bytes | ~4 s |
| 1000 bytes | ~27 s |
| 2048 bytes | 58 s |
| 27430 bytes, a JPEG | 764 s |

A megabyte would be about nine hours. Hash small things; see *Cost* in
`HANDOFF.md`.

The JPEG row is the same file the temporary-file version hashed in 812 s, so
moving the buffer onto the tape made it **faster**, which was not the reason
for doing it and is worth recording anyway. The quadratic walk costs about
three and a half seconds at that length; the second relay loop it replaced cost
27430 reads out of the file and 27430 writes into the pipe, and those were
worth more than the walk. The two only cross somewhere past the 65535 byte
ceiling, which is to say never.
