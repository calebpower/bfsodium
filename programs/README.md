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
So `bflint`, `bfstyle` and the provenance tier cover a program exactly as they
cover a routine. What a program does *not* get is a Cryptol oracle, because
there is nothing here for Cryptol to say.

And the boundary enforces itself, which is why there is no lint for it: a
routine that emitted protocol frames would fail its own known-answer test,
because a KAT compares stdout and frames are extra bytes on stdout.

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
| `sha256-abc.poke` | hashes the fixed message `"abc"` by spawning `sha256/sha256.bf` through the broker | the FIPS 180-4 digest, end to end |

`sha256-abc` exists to prove the join and nothing more. Every routine here was
already verified and the broker was already gated across two kernels; what
nothing tested was that a program can take one routine's output and make it the
next one's input. It hashes a fixed message because doing it to a file the
caller names needs `open`, `stat`, a relay loop and a size guard, and the
chaining deserved to be proved before any of that was built on top of it.

**Cost, because it decides what is worth writing.** SHA-256 is about 1.2 billion
interpreter instructions per 64-byte block, roughly two seconds. A kilobyte is
half a minute and a megabyte is about nine hours. Programs here should hash
things measured in hundreds of bytes; see *Cost* in `HANDOFF.md`.
