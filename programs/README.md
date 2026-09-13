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

### The temporary file, which is the one surprising thing

`sha256/sha256.bf` wants a two byte little-endian **length** before the
message, and the length of a stream is not known until the stream ends. The
alternative is buffering every byte on the tape and counting them in sixteen
bits, which is real arithmetic and a great deal of pointer discipline.

Writing them to a file instead lets the filesystem do the counting. `stat`
reports the size, and **the low two bytes of that u64 are already exactly the
prefix format** — little-endian, same width — so they are copied byte for byte
with no arithmetic anywhere in the program. The file is unlinked before exit.

A file larger than 65535 bytes is **refused**, not hashed wrongly: only the low
two bytes can reach the routine, so a larger one would hash its length modulo
65536 and print a plausible, wrong digest. The six high bytes are checked and
the program exits 1 if any is set.

**Verified at the boundary**, which is the only place a limit means anything:

| input | | |
|---|---|---|
| 65535 bytes | exit 0, correct digest | 30 minutes, 1024 blocks |
| 65536 bytes | exit 1, no output, temp removed | 7 seconds |

Neither is in the suite. The refusal is seven seconds but needs a 64 KiB
fixture, and the acceptance is half an hour; the three lengths tier 12 does run
are chosen to cover the relay loop's boundary and the length prefix instead.
This table is the record that somebody checked.

The refusal case is also what found brainstem's `spawn` deadlock — it hung for
fifteen minutes rather than exiting — so it has earned its keep once already.

### Cost, because it decides what is worth writing

SHA-256 is about 1.2 billion interpreter instructions per 64 byte block,
roughly **two seconds**. Measured end to end through the broker:

| input | wall |
|---|---|
| empty | ~2 s |
| 3 bytes | ~1 s |
| 100 bytes | ~4 s |
| 1000 bytes | ~27 s |

A megabyte would be about nine hours. Hash small things; see *Cost* in
`HANDOFF.md`.
