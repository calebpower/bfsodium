# bfsodium conventions

This document is the rulebook every `.bf` file in bfsodium obeys. Its job is to
make hand-written brainfuck **legible and reviewable** — the difference between
committing assembly and committing a binary blob. A reviewer cannot verify a
crypto routine's *correctness* by reading brainfuck (nobody can); that is the
job of the test suite (§8). What legibility buys is **intent and diff
comprehension**: a reviewer can see *which* block changed and read the contract
it claims to honour.

The code is AI-generated, but it is committed as brainfuck a human can follow,
and every committed `.bf` is expanded from a skeleton a person wrote (§6).

*(This file is Markdown, not brainfuck, so it uses normal punctuation freely.
The rule in §0 applies only to text inside `.bf` files.)*

---

## 0. The one rule that bites first: comments are code unless you are careful

brainfuck executes every one of these eight bytes wherever it appears,
including inside what you think is a comment:

```
> < + - . , [ ]
```

So a comment reading `QUARTER-ROUND` silently executes a `-`, a range written
`0x00..0x1F` executes two `.`, and — the one that bites hardest — **ordinary
English punctuation is code**: every comma and full stop in a sentence is a
live `,` or `.`.

Two mechanisms handle this, and **both** are required:

1. **`;` starts a comment to end of line** in the pinned interpreter
   (`tools/bfi`), so prose can be written naturally.
2. **Portability is enforced, because `;` is not standard brainfuck.** Another
   interpreter would execute that prose. `tools/bflint` compares the
   instruction stream *with `;` honoured* against the stream *with only command
   bytes kept*: they MUST be identical. A file that runs correctly only under
   our own interpreter is not brainfuck and fails the lint.

When writing comment prose:

- Use letters, digits, spaces, and this safe punctuation: `_ : = ; ! ? # @ * / ( ) { } | ~ ^ $ % &`
- Never `-` in a name — use `_` (`QUARTER_ROUND`, not `QUARTER-ROUND`).
- Never `.` — end sentences with `;` or nothing; ranges use a colon
  (`0x00:0x1F`), never `..`; write "2 point 4", never "2.4".
- Never `[` `]` — counts use braces (`state{16}`, not `state[16]`).
- Avoid commas; a double space reads fine as a pause.
- Section banners use `====`, never `----`.
- To *refer* to a command byte, name it: `PLUS MINUS LEFT RIGHT DOT COMMA OPEN
  CLOSE`.

`tools/bflint --fix` rewrites comment prose into the safe set, touching nothing
outside comments, so semantics cannot change. The KATs then prove the rewrite
was inert.

---

## 1. Machine model (frozen)

bfsodium targets one semantics profile, implemented by `tools/bfi.c`:

- **Cells** are unsigned 8-bit and **wrap mod 256**. We *rely* on the wrap as
  free modular byte arithmetic.
- **Tape** is unbounded to the right, zero-filled on first touch.
- **Cell 0 is the floor.** Moving left of it is a hard error (`bfi` exits 3).
- **`,` at end of input leaves the cell unchanged.** Primitives read an exact,
  known byte count (§7), so this is a safety net and never a control path.
- **`.` and `,` are raw bytes.** No newline or encoding translation, and
  **stdout is unbuffered** — a byte written by `.` reaches its destination
  before the next instruction runs. That matters to nothing here, because every
  primitive is one-shot, and it matters completely to anything holding a
  conversation with a bf program over a pipe.
- **`;` runs a comment to end of line.** The one convenience the pinned
  interpreter adds, neutralised by the portability lint (§0).
- Any byte outside the eight commands is a comment.
- `bfi` exits 4 when a declared contract is violated under `BFI_CONTRACTS=1`
  (§8, tier 5).

No other dialect features — no wide cells, no negative tape, no extra I/O. If a
program depends on anything outside this list, it is wrong.

---

## 2. Numbers on the tape

- A **32-bit word** is 4 consecutive cells, **little-endian**.
- A **bignum** is an array of base-256 limbs, little-endian, fixed length per
  primitive. Poly1305 uses 17 limbs; the files call this `136`.
- **Endianness is converted only at the I/O boundary** (§7), for formats that
  are big-endian on the wire such as SHA-256. Internally everything is
  little-endian, always, so there is one convention to hold in your head.

---

## 3. Tape map (the keystone of legibility)

Every `.bf` begins with a **tape map**: a comment header declaring what lives in
every cell region, relative to the file's home cell. brainfuck's unreadability
comes almost entirely from implicit cell positions; the tape map makes them
explicit.

```
; TAPE MAP  (home @0)
;   @0x000:0x02f  saved{48}  key{32} @0x000  ctr{4} @0x020  nonce{12} @0x024
;   @0x040:0x14f  blockkeep's frame; a keystream block comes back at @0x040
;   @0x1b0:0x1c0  r{17}    the clamped r  copied into absorb's slot each block
```

Addresses are hex and cell-granular, ranges joined with a colon. Each region
names a symbol, a count, a type, and a purpose. Layout is **static** per
primitive — fixed regions decided up front, no dynamic allocation and no stack.

---

## 4. Pointer discipline, and the interface that is checked

The worst brainfuck failure mode is a stray `>` or `<` that shifts every
subsequent cell reference, so one wrong character makes the whole file wrong and
every diff illegible. Three invariants prevent it:

1. **Routines are pointer-disciplined.** A routine declares where the pointer
   is when it starts and where it is when it ends, and a caller relies on both.
2. **Addressing is routine-local.** A routine reaches cells as offsets from its
   own base, never as absolute positions threaded in from far away.
3. **Scratch is zero-in, zero-out.** Every scratch cell is 0 on entry and
   restored to 0 before exit, so a routine may be pasted inside a loop.

This is declared in one line, and it is **checked**:

```
; INTERFACE entry=34 exit=34 footprint=0:39
```

`entry` is where the pointer sits when the read prologue ends; `exit` where it
sits when the body ends; `footprint` every cell the routine may touch, relative
to its own base. `tools/bffoot` proves all three against the instruction
stream.

**Do not edit an `INTERFACE` line to make a check pass.** The line is a claim
about the code and `bffoot` is the thing that stops it being a lie. It exists
because one was: `stagger` declared `0:67` while staging eight bytes through
64–71, which was invisible standalone and corrupted one word of every block
once pasted.

A caller uses the first two directly: it walks in `entry` cells before the
pasted body, and walks back `exit` cells afterwards to return to the routine's
own base. That is why both are declared rather than inferred.

A paste site **must** state the base its callee's zero lands on
(`@@ADD136@@ 0`). Omitting it is a hard error rather than a guess, because a
routine's contracts are written relative to its own base and have to be
rebased.

**Contracts are authored relative and committed absolute.** Write
`; ASSERT ptr=+24` and `; ASSERT zero +3:+10` in the skeleton, against the
routine's own base, so the same line stays true wherever the routine is pasted;
`bfexpand` resolves them to absolute cells on the way out. The committed
brainfuck must not carry the `+` notation, because `+` is an instruction and a
canonical interpreter with no `;` rule would execute every one of them.

Use them liberally, and especially `ASSERT zero` on a frame at entry and exit —
that is what makes a routine safe to paste inside a loop. §8 tier 5 is the
mechanism; this is the advice.

---

## 5. Idiom vocabulary

A small fixed vocabulary, so a reviewer learns the instruction set once and
then reads every block in its terms. This section is both the authoritative
list of what exists and the reference for each one. It used to be split between
here and an `IDIOMS.md`, which meant the list and the contracts could disagree
-- and they did, because the list here named `ROTR32`, `SHR32` and `AND32`
that the reference never described, while the reference described a lookup
table this section records as rejected.

Notation: cells are named by their offset from the block's anchor. Every idiom
is **pointer-neutral** -- it ends with the pointer where it started -- and
leaves every scratch cell it touched at zero, which is what lets blocks compose
by plain concatenation. Each contract states what it reads, what it writes,
what it consumes, and what scratch it borrows.

**Bitwise is computed, not table-backed.** An earlier plan materialised a
256x256 XOR table on the tape once at startup. It was **rejected** -- the
reasoning is under *Bitwise* below -- and nothing in the tree builds one. Byte
XOR is eight halvings; a table would cost 64 KiB of tape and an indexed read,
and indexed reads are the expensive thing here, not the arithmetic.

**Indexed addressing exists and is unused.** `index/fetch8`, `index/store8`
and `index/fetchword` are hand-written, verified, and reachable if a future
primitive genuinely needs a run-time index. Nothing has. Which brings us to:

**Conveyors, not indices.** Every loop in this repository brings the data to
the code rather than reaching for the data with an index. `blockloop` rotates
the ChaCha state so the four words a quarter round wants are always at the same
four cells. `mulmod136` carries its operands to a fixed work frame at cell
zero. `poly1305` lands each message byte on the top of the block and slides the
block down one, so a byte taken in round `k` comes to rest at `blk[k]` with no
index anywhere -- and a short block comes out right for free.

This is not an aesthetic preference. Indexed addressing on a tape costs pointer
travel proportional to distance, and the conveyor is usually both cheaper and
far easier to prove.

### Core

#### CLEAR — set a cell to zero
```
[-]
```
Consumes the cell. The workhorse for discarding a value you are done with (a
dropped carry, a spent counter).

#### MOVE — add a cell into another, emptying the source
```
x[- >>+ <<]          ; move x into the cell two to its right
```
*Reads and consumes* `x`; *adds into* the destination. The destination is
**added to**, not overwritten — clear it first if you need assignment. This is
the only primitive way to relocate a value in brainfuck; everything else is
built from it.

#### COPY — duplicate a cell, preserving the source
```
x[- >+ >>+ <<<]      ; x into dest and into a temp, x is now 0
>>> [-<<<+>>>]       ; put the temp back into x
```
*Reads* `x` (restored); *adds into* the destination; *borrows* one scratch cell
(restored to 0). brainfuck cannot read a cell without consuming it, so a copy is
always a move to two places followed by a move back. Every "preserve the
operand" step in the library is this.

#### ADD — add one cell into another, modulo 256
Same as MOVE. The mod-256 wrap is the machine's, not ours, and we rely on it
(§1).

---

### Control

#### IFZERO — set a flag when a value is zero
```
>+<                  ; assume zero: flag := 1
[ >-< [-] ]          ; if the value is nonzero, clear the flag and the value
```
Tests a value without a comparison instruction, which brainfuck does not have.
The trick throughout the library: **assume, then undo**. Set the answer
tentatively, then let a loop that only runs when the value is nonzero take it
back. Verified at 0, 1, 0x80 and 0xff.

#### TOGGLE — flip a 0/1 cell
```
>+<                  ; f := 1
[->-<]               ; if t was 1: t := 0 and f := 0
>[-<+>]<             ; if f survived: t := 1
```
*Reads and writes* `t` (which must be 0 or 1); *borrows* `f` at `t+1`
(restored). Used by XOR8: toggling once per set bit computes parity, which is
exactly exclusive or.

---

### Arithmetic

#### ADD8 — add with carry
```
y[- x+ [t0+ t1+ <-] t0[x t1 restore] c+ [c- ...] ]
```
The shipped form, with `y` at the anchor, `x` at `y-1`, `c` at `y+1`, and
scratch `t0 t1` at `y+2 y+3`:
```
[-<+[>>>+>+<<<<-]>>>[<<<+>>>-]<+>>[<<->>[-]]<<<]
```
*Consumes* `y`; *adds into* `x` modulo 256; *adds the carry into* `c`;
*borrows* `t0 t1` (restored). For each unit of `y` it bumps `x`, then detects
whether `x` has just wrapped to zero by the IFZERO trick — bump `c`
tentatively, take it back unless the copy was zero. A byte sum is at most 511,
so `x` wraps at most once and `c` gains at most 1.

Verified: `18+52`, `255+1`, `255+255`, `128+128`, `0+0`, `0+255`.

#### ADD32 — 32-bit little-endian add
Four ADD8 byte blocks, LSB first, each adding the addend byte and then the
carry from the byte below, with the carry out kept for the next byte. The carry
out of byte 3 is dropped (the sum is modulo 2^32). Shipped as
[`chacha20/add32.bf`](chacha20/add32.bf).

#### HALVE — shift right one, with the low bit
With the value at the anchor, `q` at `+1`, `t` at `+2`, `f` at `+3`:
```
[->>>+<[-<+>>-<]>[-<+>]<<<]
```
*Consumes* the value; *writes* `q` (the value shifted right one) and `t` (its
low bit); *borrows* `f` (restored). Counts the value down, toggling `t` each
step and bumping `q` every second step. This is the only bit-extraction
primitive in the library — XOR8 is built entirely from it.

#### DOUBLE — shift left one, with the high bit
COPY the value, then ADD8 it to itself: `x + x` is exactly `2x` modulo 256 with
the carry equal to bit 7. Cheaper than seven HALVEs, and it reuses a kernel that
is already proven. Used by ROTL32.

---

### Bitwise

brainfuck has no bitwise instruction.

**Why not a lookup table.** The original plan was a 256-by-256 XOR table. That
is the wrong shape here: the table would sit tens of thousands of cells from the
working frame, and since the only way to reach a cell is to walk to it, every
lookup would pay that distance twice. Building the table costs more still. Bit
decomposition keeps every access within a handful of cells of the frame.

#### XOR8 — byte exclusive or
Eight steps. Each HALVEs both operands to get their low bits, TOGGLEs a flag
once per set low bit (so the flag ends as the exclusive or), adds the running
bit weight into the result when the flag is set, and doubles the weight.
Shipped inside [`chacha20/xor32.bf`](chacha20/xor32.bf).

#### XOR32
Four XOR8 blocks over the byte pairs.

#### ROTL32 — rotate left by n
`n` single-bit rotations under a counter. One bit rotation DOUBLEs all four
bytes and feeds each carry into the next byte cyclically; a doubled byte is
even, so adding the neighbour's carry bit cannot overflow and no second carry
pass is needed. Shipped as [`chacha20/rotl32.bf`](chacha20/rotl32.bf).

#### ROTL64 — rotate left by n, *without ever shifting left*
The direction brainfuck is bad at, built out of the direction it is good at.
`rotl(w, 8q+s) = rotl(w, 8(q+1))` then `rotr(w, 8-s)`: a rotation by a whole
multiple of eight is a rotation of whole BYTES, which costs two instructions
per unit of a byte's value, and what is left is a right rotation of one to
eight bits, which is `rotr64` pasted once. So no byte is ever doubled and the
adder is never entered. `q+1` is deliberately **not** reduced modulo eight —
turning an eight-byte word left by eight whole bytes returns it to itself, so
`q = 7` costs eight cheap turns instead of a comparison. Shipped as
[`idiom/rotl64.bf`](idiom/rotl64.bf); measured at 78 thousand to 685 thousand
instructions against `rotr64`'s 4.3 million for a left rotation by one.

---

### Composition

brainfuck has no subroutines, so a composite primitive physically contains its
parts. Because brainfuck code is **position-independent** — a block that only
moves relative to where it starts behaves identically wherever it is placed — a
proven body can be reused verbatim at a different base rather than retyped at
new offsets.

That splicing is done by [`tools/bfexpand.sh`](tools/bfexpand.sh), from a
`@@NAME@@ base` directive in a skeleton. It pastes the callee's body and
rebases its `ASSERT` lines, and it does nothing else: it chooses no layout,
computes no offset from a name, and generates no loop. The glue that moves
words into a shared workspace and back is written by hand, in the skeleton,
beside the paste.

It used to be done by a transpiler — `tools/qrasm.sh` and its siblings, which
assembled the quarter round out of add32, xor32 and rotl32. They are **deleted**,
along with everything they generated, and §6 records why: the
project came off the rails by drifting into code generation, and the size
budget exists to keep it from happening again.

The glue obeys one rule, the same one §4 requires of every routine:
**a routine declares where the pointer enters and where it leaves, and
`tools/bffoot` proves both against the instruction stream.** Operations then
compose by concatenation.

---

## 6. How a file is written, and what it looks like

**There are two artifacts per routine and they have different jobs.**

- **`x.skel` is what a person writes.** It uses `Rn`/`Ln` for pointer runs and
  `@@NAME@@ base` to paste another routine, and it puts each annotation on the
  line *above* its operation, because that is the order you think in.
- **`x.bf` is what is committed and what every check judges.** Brainfuck down
  the left, English down the right.

`tools/bfexpand.sh` turns the first into the second, expanding `Rn`/`Ln`
literally, pasting routine bodies, rebasing `ASSERT` lines, and piping the
result through `tools/bflayout.pl`, which moves annotations into the right-hand
column and wraps long remarks.

**`bfexpand` is not a compiler.** It chooses no tape layout, computes no offset
from a symbolic name, and generates no loop. Every offset in a skeleton is a
number the author worked out and wrote down. Keep it that way: the project came
off the rails once by drifting into a transpiler, and the size budget in
`bfstyle` exists because of it.

`sh tools/rebuild.sh` expands every skeleton **to a fixpoint**. A skeleton
pastes a callee's body, so a callee must be expanded before its callers or the
caller embeds a stale copy.

**A `.bf` is never hand-edited.** The suite regenerates every one from its
skeleton and compares byte for byte. If you find yourself editing a `.bf`, you
are editing the wrong file.

### Formatting, as `bfstyle` enforces it

- A file opens with a comment, and carries an `IO` section then a `TAPE MAP`
  section, in that order.
- **A trailing annotation on a code line starts at exactly column 64.** A
  standalone annotation starts at column 0; a wrapped continuation starts at
  column 64. Nothing sits anywhere else.
- **No run of more than 12 code lines without an annotation**, so no block goes
  unexplained. `bflint` separately caps a single line at 96 command bytes — no
  wall of command bytes on one line.
- Indent the body inside every `[ ]`; matching brackets line up.
- Section banners are operator-free header comments, so they are greppable.

**Fixed rounds are counter-driven loops, not unrolled.** A round body is written
once and repeated under a cell counter. Unrolling is the thing the size budget
exists to prevent.

---

## 7. I/O contract (a primitive's signature over stdio)

bfsodium is pure computation: **plain stdin/stdout, no syscalls, no broker.**
Randomness, when a future primitive needs it, is supplied as input bytes, never
generated — which keeps every run deterministic and replayable.

This is a boundary, not an absence. Reaching the operating system from a
brainfuck program is a *separate component* — `brainstem`, which speaks a byte
protocol over the same two instructions and turns it into syscalls. bfsodium
must never depend on it, so that a bfsodium primitive runs under any
interpreter, with or without a broker on the other end of the pipe.

Each primitive is **one-shot**: it reads an exact, documented input layout from
stdin, then writes an exact output layout to stdout.

```
; IO  in:  key{32}  nonce{12}  alen{2} LE  aad{alen}  plen{2} LE  pt{plen}
;     out: ciphertext{plen}  tag{16}
```

Byte counts are exact and fixed, or length-prefixed with `{2} LE` where a
primitive is variable-length. **A primitive never relies on EOF to know when to
stop**, and both lengths are read before the bytes they count.

---

## 8. Testing protocol

bfsodium subscribes to reaper's `docs/testing-methodology.md`: a portfolio of
oracles, each earning its place by a defect no cheaper tier can catch. The rules
are non-negotiable:

- **Two oracles for the claim that matters.** A primitive's output is checked
  against **both** the published vector **and** an independent computation by
  the Cryptol specification in `spec/`. Both must agree byte for byte. Where a
  standard gives no vector, the pin is a regression guard and Cryptol is the
  oracle. Twice the dual oracle has caught *the author* rather than the
  brainfuck: an expected value worked out by hand was wrong and Cryptol said so.
  **Do not pin a value you computed in your head.**
- **Mutation-check every assertion.** Break the thing it covers, confirm the
  test fails, restore. A test never observed failing is unmeasured. This has
  repeatedly found that a test proved nothing — see the three surviving
  mutations recorded in `HANDOFF.md`.
- **Self-test the oracle.** Every checker has a `--selftest` that feeds it the
  defects it exists to catch, run **before** any real file is checked.
- **A property that cannot fail is not evidence.** Where a proof asserts
  something holds, a companion must be *refuted*, so the first is not a claim
  that would hold whatever you deleted.
- **Never weaken a test to pass.** No skips, no narrowed scopes. Every
  narrowing needs a stated reason covering exactly what it narrows.
- **The pinned interpreter is the reference.** All tests run through
  `tools/bfi`, whose own semantics are smoke-tested first.

The checkers, at a glance. Each answers one question and no other, which is
what keeps them independently self-testable:

| tool | question it answers |
|---|---|
| `bfi` | what does this program mean (the pinned semantics), and does it honour its contracts |
| `bflint` | is this portable brainfuck, and is it annotated at all |
| `bfstyle` | is the style the same across every file, and was this file written or generated |
| `bffoot` | does the `INTERFACE` line tell the truth |
| `dkat.sh` | does the brainfuck match both the pinned vector and the Cryptol spec |
| `rebuild.sh` | expand every skeleton in an order that respects the pastes |
| `bftable.pl` | does `HANDOFF.md`'s routine table still describe the tree |
| `bftier.pl` | does `HANDOFF.md`'s tier status table still describe the suite |

Tiers, as they apply here. The KAT tiers inspect **output**, so they are
deliberately paired with tiers that inspect **the oracle** and **internal
structure**.

| Tier | Question it answers | How |
|---|---|---|
| 1 interpreter self-test | Is the oracle of record itself correct? | `tools/bfi` on core ops, nested loops, tape growth, wrap both ways, bracket matching, EOF-unchanged, left-of-0, and that a written byte reaches a pipe before the program ends. Everything trusts `bfi`, so `bfi` must be trustworthy — and the last of those was false for most of this project's life, invisible to every other check because they all read output after the process had exited. |
| 2 idiom boundary KAT | Do the building blocks hold at the edges? | Each idiom at its boundaries: full carry cascade, top-bit wrap, rotate by 0 and by 31, empty and one and many. Catches edge bugs a whole-primitive KAT masks. `add8` is checked exhaustively over all 65536 pairs, because it is cheap enough to be. |
| 4 golden vector, dual oracle | Does the primitive match the standard, exactly? | Published vectors through `bfi`, required to match **both** the vector **and** the Cryptol spec, byte for byte. `tools/dkat.sh` is the harness. |
| 5 declared contracts | Does the code obey the interface composition depends on? | `; ASSERT ptr=N` and `; ASSERT zero A:B` are comments, so a plain interpreter ignores them and portability is untouched; `BFI_CONTRACTS=1` checks them **every** time execution reaches that point, including on every pass through a loop. This turns an interface from a comment that might lie into a checked fact, and it catches what the output tiers cannot: a pointer off its anchor, scratch that was not clean on entry, a routine entered at the wrong offset. **These have found more defects than the vectors have.** |
| 6 differential fuzz | Do untried inputs diverge from the spec? | **DECLARED AND NOT BUILT.** Random inputs, bf against Cryptol, seed printed and replayable. Affordable for the cheap primitives and not for the composites. It is listed here because its absence is a gap and not a decision — **do not let this row read as coverage.** |
| 7 metamorphic | Do reference-free invariants hold? | Checks needing no oracle: the AEAD ciphertext is the stream cipher at counter one; encrypting the ciphertext again returns the plaintext. Independent of whether the spec is right. |
| 8 design proofs | Is the structure itself sound, over all inputs? | Cryptol `:prove` over the design, not the bytes: the looped quarter round equals the quarter round, one fold suffices for `reducep136`, the adders carry and sum identities. Each is paired with a companion that must be **refuted**. Runs on both guests; see §8.1 for the commit where it briefly did not. |
| 9 legibility and portability | Can a human read this, and is it really brainfuck? | `tools/bflint` proves the instruction stream with `;` honoured is identical to the stream with only command bytes kept, and enforces the legibility floor: a tape map and an IO header, operator-free prose, no wall of command bytes on one line. Self-tested against minified and header-less input. |
| 9a style consistency | Is the style the same across every source file? | `tools/bfstyle`: a title then `IO` then `TAPE MAP`; a trailing annotation at exactly column 64 and a standalone one at column 0; **no run of more than 12 code lines without an annotation**. This tier exists because style silently drifted and **no other tier could see it** — every other tier checks what the code computes, not how it reads. |
| 9b size budget | Is this file short enough that a person would actually read it? | `bfstyle` fails any file over 2000 lines, counting the **skeleton** where one exists. Added after the composites drifted to 42k lines, 66k, and — in an AEAD never committed — 903k, every one of which passed all the other checks. The exemption is sound only because the suite separately proves every `.bf` equals `bfexpand` of its skeleton byte for byte; the two halves are one check and removing either reopens the hole. |
| 9c provenance | Is the committed brainfuck what its skeleton says? | Every `.bf` compared byte for byte against `bfexpand` of its `.skel`, and `bfexpand`'s own refusals tested: a paste site with no base is an error, an unknown routine is an error. |
| 9d the interface tells the truth | Does the `INTERFACE` line describe the code? | `tools/bffoot` proves entry, exit and footprint against the instruction stream (§4). The set of files that declare no `INTERFACE` is pinned, so a new routine that forgets the line fails rather than passing silently. |
| 9e the documents describe the tree | Are the two machine-checked tables still true? | `tools/bftable.pl` checks `HANDOFF.md`'s routine table against the tree, added after eighteen of its thirty rows were found wrong. `tools/bftier.pl` checks its tier status table against `tests/run.sh`, added after tier 6 sat in a combined table in the same voice as the tiers that ran, so a reader took a green suite as evidence of fuzz coverage that did not exist. **This section says what is REQUIRED; that table says what is BUILT.** Keeping those in one column is what drifted. A number nobody verifies is not documentation, it is a rumour. |
| 10 one definition of the toolchain | Do all three lanes test the same thing? | The suite reads every lane definition — `Containerfile`, `.reaper.toml`, `container-test.sh` and each GitHub workflow — strips its comments, and fails if any carries an `apt-get` or a Cryptol version of its own, or stops calling `guest-setup.sh`. A second definition is how a lane starts passing what the gate would fail — silently, because a container with a different z3 still runs every test and still says PASS. Comments are stripped first because the sibling project's version of this check failed on the comment explaining the ban, and a check that punishes its own documentation teaches the next person to delete it. |
| 11 mutation | Would the suite catch the bug it claims to? | Break each nontrivial block, confirm the relevant tier fails, restore. |
| 12 composition | Do these routines actually compose? | A **program** in `programs/` sequences routines by spawning them through the P1 broker, and the suite runs it end to end against a published vector. Every tier above checks one routine in isolation; this is the only one that checks the JOIN, which is the claim a library makes by calling itself a library. The broker and the expander come from the brainstem checkout `guest-setup.sh` pins, and a missing one FAILS rather than skipping. |

**Named non-goals** (what we do NOT prove):

- **Constant-time or side-channel resistance.** brainfuck branches on data, the
  interpreter is not constant-time, and this is a stunt library. No timing
  claim, no timing test. Do not use bfsodium where side channels matter.
- **Sufficiency.** The v1 set is *complete* as §9 defines it. Whether it is
  *enough* for the downstream target is a separate question and is not yet
  answered by anything in this suite.
- **reaper tiers that do not apply**, named rather than silently skipped:
  concurrency (single-threaded pure computation); simulated-users and
  live-browser (no stateful service, no UI). reaper's human-evidence tier is
  *not* skipped — it is adapted into tier 9, since "can a human read this" is
  this project's whole reason to exist.

The tenant is wired in `/.reaper.toml`; **`reaper test` is the gate of record.**
`sh tools/container-test.sh` is a fallback for a host that cannot reach the
reaper site, running the same suite with nothing skipped — but a pass there has
not proved the change on the machine of record.

### 8.1 Two guests, and both run all of it

**`reaper test` runs `ubuntu-26.04` and `freebsd-15.1`, and both run every
tier.** No tier declares a guest. This section exists because for one commit
one did, and the reasoning that put it there is worth keeping — it was half
right, which is the dangerous kind.

**The second guest exists for a second C compiler.** Five C programs live
here — `bfi`, `hx`, `bflint`, `bfstyle`, `bffoot` — and until `freebsd-15.1`
every one had only ever been compiled by gcc. `bfi` is the interpreter every
correctness claim in this library rests on. The sibling project's `bcmp` trap
is the argument in full: clang rewrites `memcmp(a, b, n) != 0` into a
different symbol and gcc does not, and that was a defect nothing runnable on
the development host could reveal.

**What was proposed, and why half of it was right.** Tier 8 was taken off
FreeBSD on the grounds that a proof is a statement over bitvectors — *for all
x, `reduceTail (foldOnce x) == x % p136`* — and quantifying over 2¹³⁶ inputs
does not care which kernel asked. **That part is true and remains true.**
Running those eight twice buys almost nothing, and if Cryptol were expensive
to have on a guest it would be a real argument.

**What was wrong.** The second half of the claim was that Cryptol is therefore
not needed on that guest at all, because the dual oracle's values are pinned
literals. They are not. **`tools/dkat.sh` runs `cryptol -b` once per vector**
and compares the brainfuck against what the spec computes, live — which is
precisely what makes it a dual oracle rather than a table of numbers somebody
once generated. Tiers 2 and 4 are 157 checks and every one of them needs
Cryptol at run time.

The belief came from grepping `tests/run.sh` for `cryptol`, finding three
sites, none of them a KAT, and concluding something about the suite. `dkat.sh`
is a different file. FreeBSD answered with **156 failures in two tiers**,
which is what a plausible sentence looks like once a machine reads it.

**So Cryptol is installed on both guests** — `security/hs-cryptol` from ports,
quarterly, which carries 3.4.0. Once it is there, running tier 8 costs eight
z3 invocations rather than a Haskell toolchain, and at that price an exception
is not worth its own documentation.

**The pin is verified rather than trusted.** `pkg` installs whatever its branch
carries and quarterly rolls; the day it carries 3.6.0, two guests would be
proving things with two different oracles and `CRYPTOL_VERSION` would have
quietly stopped meaning anything. `guest-setup.sh` compares the installed
version against the pin and fails the provision if they differ, saying which
of the two to move.

**Two things survive from the attempt.** The summary names the platform, which
went in to make an asymmetric run legible and is worth keeping regardless — a
count with no platform beside it is a number nobody can check. And the
`# GUEST` markers in `guest-setup.sh` are now compared against
`.reaper.toml`'s guest list by tier 10, so adding a guest without a
provisioning branch is a failure rather than a guest that falls into whichever
arm happens to match.

**The general lesson, since it cost a gate run.** *"This dependency is only
used by tier N"* is a claim about the whole suite, and the suite is more than
one file. It is checkable — `grep -rl cryptol tools/ tests/` answers it in one
command — and it was not checked.

## 9. Scope and roadmap

**v1 — the symmetric set. Complete.**

ChaCha20 (RFC 8439), Poly1305, ChaCha20-Poly1305, SHA-256 with HMAC, and
HKDF-SHA-256. All five are in, hand-written, and gated on two guests.

**What v1 does not yet have:**

1. **Proof that the set is sufficient.** The downstream target is the BoneMesh
   shared corpus — `keyschedule.json`, `transport-frame.json` — and nothing has
   ever been checked against it. That is the thing that would show the set is
   sufficient rather than merely complete. **`v1.0.0` waits on it.** The harness
   no longer does: `programs/run.bf` drives any routine named at run time and
   `tools/bfrun.sh` frames it, so what remains is the corpus rather than the
   machinery.
2. **Tier 6.** Declared in §8, not built. The only `no` in the status table.
3. Cheaper `mulmod136`, and `qrloop` pasting `rotr32` rather than `rotl32`,
   both recorded with measurements in `HANDOFF.md`. Neither is needed; both are
   written down so the next person does not rediscover them.

---

### 9.1 The NIST wish list

**The ambition is every NIST-approved algorithm.** This is a wish list and not
a plan: nothing here is scheduled, and the ordering is the useful part. It is
written down because the *dependency order* is most of the value — and because
"all of NIST" as one undifferentiated pile is how a roadmap becomes
demoralising rather than useful.

**The anchor for every cost below** is the one measurement this library has:
`sha256` of "abc" is **1,180,129,364 instructions in about two seconds** under
`bfi`, so roughly **570 million instructions per second**. Any number here
without that behind it is a guess and is labelled as one.

**And the per-algorithm cost is not the brainfuck.** It is the Cryptol spec and
the published vectors, because §8's dual oracle is what makes an addition
trustworthy, and `tools/dkat.sh` runs Cryptol *once per vector*. Budget that
first.

#### Tier A — no new mathematics

Everything here follows from what is already built plus one new idiom set, and
this is where to start.

| target | needs | note |
|---|---|---|
| SHA-224 | nothing new | SHA-256 with a different IV and a truncation |
| SHA-384, SHA-512, SHA-512/224, SHA-512/256 | `add64`, `rotr64`, `shr64`, `xor64`, `and64` — all five built | **SHA-512 itself is now built**; SHA-384 and both SHA-512/t are the same core with a different IV and a truncation |
| HMAC over each of the above | nothing new | FIPS 198-1; **HMAC-SHA-512 is built** |
| HKDF over each | nothing new | RFC 5869; **HKDF-SHA-512 is built**, with info capped at 63 bytes — see the note in its header |
| HMAC_DRBG | nothing new | SP 800-90A; nearly free given HMAC-SHA-256 |
| SP 800-108 KDFs (counter, feedback) | nothing new | loops over HMAC |
| PBKDF2 | nothing new | SP 800-132; a counted loop over HMAC |

About fifteen approved algorithms, no new mathematics, and the 64-bit idiom set
is reusable for everything after it.

#### Tier B — two keystones, each unlocking a family

**AES (FIPS 197)** unlocks CMAC (SP 800-38B), GCM and GMAC (38D), CTR_DRBG
(90A), CCM (38C), XTS (38E) and KW/KWP (38F) — around ten further approved
constructions from one primitive.

**`index/fetch8`, `store8` and `fetchword` were written for this.** They are in
the tree, nothing uses them, and `HANDOFF.md` calls them *"the escape hatch if
a future primitive genuinely needs a run-time index — but so far nothing has."*
AES's S-box is a 256-entry runtime lookup. It is the primitive those routines
were anticipating.

**MEASURE THE LOOKUP BEFORE COMMITTING TO AES.** On paper an AES-128 block
should cost *less* than SHA-256's two seconds — ten rounds of table lookups
against sixty-four rounds of 32-bit arithmetic. But an indexed read in
brainfuck is **O(index)**, which is the exact cost *"conveyors, not indices"*
(§5) exists to avoid: one S-box lookup may be up to 256 steps of walking, and
there are 160 of them per block. That is a day's work to measure and it
de-risks the whole of this tier. Do not write AES first and find out.

**Keccak-f[1600] (FIPS 202)** unlocks SHA3-224/256/384/512, SHAKE128/256, KMAC,
cSHAKE, TupleHash and ParallelHash — and it is a hard prerequisite for every
post-quantum standard, since ML-KEM and ML-DSA both sample from SHAKE. It wants
the 64-bit idioms from tier A, a 5×5 lane state, and twenty-four rounds of
theta/rho/pi/chi/iota. Large but extremely regular.

**Keccak-f[1600] IS BUILT.** `keccak/theta` and `keccak/rhopichi` are a round,
both working in place on the same two hundred cells, and `keccak/permute1600`
is the twenty-four-round loop with ι inline and FIPS 202's round constants
written out as plusses. It computes the published permutation of the all-zero
state in **3.94 billion instructions** — a third of the AEAD, about three times
SHA-256 of one block. Affordable, and not yet optimised: the profile will say
where, and the lesson from `mulmod136` is that it will say *the glue*.

**A Keccak round constant is unusually cheap to write down**, which is worth
knowing before anyone reaches for the linear feedback register that generates
them: the constants have bits only at positions one less than a power of two,
so only bytes 0, 1, 3 and 7 of a lane are ever anything but zero, and most of
those are 128. The whole table is twenty-four blocks of at most four numbers.

What is left of the tier is the **sponge**: SHAKE128 and SHAKE256 at rates 168
and 136, then SHA3-224/256/384/512 as the same sponge with a different pad
byte and a different squeeze length.

**The rotation was the piece that decided whether any of it was affordable.**
ρ is twenty-five 64-bit rotations a round, six hundred per permutation, and its
offsets run up to 62. Done with `rotr64` — a left rotation
by `r` being a right rotation by `64-r` — that is **1.40 billion instructions
on ρ alone**, per permutation, which would have made Keccak cost more than the
whole AEAD. `idiom/rotl64` (§5) does the same twenty-five for **9.5 million a
round, 229 million per permutation, 6.1× less**, by turning whole bytes instead
of shifting. Measure the rotation before costing the permutation; the naive
figure is the one that would have made this tier look closed.

**Both keystones will strain the 2000-line skeleton budget** (§8 tier 9b). The
paste discipline has to carry more weight, or the budget needs a reasoned
exception — not a silent one.

#### Tier C — the hybrid handshake, after Keccak and not before

ML-KEM (FIPS 203), ML-DSA (204), SLH-DSA (205). **Cheaper than X25519 in this
cost model, which inverts the usual intuition.** ML-KEM's arithmetic is all mod
q = 3329, a 13 bit modulus, so a modular multiply is a TWO LIMB multiply
against 25519's thirty two; the work is thousands of cheap butterflies rather
than thousands of expensive big-integer multiplies. More tractable than it
sounds:
small moduli, no bignums, mostly NTT butterflies over Z_q. **Blocked on
Keccak**, because the sampling is SHAKE.

#### X25519 is IN scope, and this section used to say otherwise

**This is a correction.** An earlier version of §9.1 put RSA, ECDSA, ECDH and
EdDSA out of scope together, on the grounds that `poly1305/mulmod136` is cheap
only because 2¹³⁰−5 has a special form and *"that trick does not transfer"*.

It does not transfer to RSA, and it does not transfer to the NIST P-curves.
**It transfers exactly to Curve25519**, whose prime is 2²⁵⁵−19 — the same
pseudo-Mersenne shape, reduced the same way, by multiplying the high half by a
small constant and adding. X25519 is not "elliptic curve, therefore new
mathematics"; it is `mulmod136` with more limbs and a Montgomery ladder around
it. Lumping it in with RSA was a category error, and the whole point of the
`mulmod136` sentence was that the *form of the prime* decides the cost — which
should have pointed straight at 25519 rather than away from it.

**The cost is the real obstacle, and it is measurable rather than unknown.**
`mulmod136` is **987,082,567 instructions** for a 17-limb multiply. The 25519
field is 32 limbs at one byte each, and partial products go as the square of
the limb count, so a multiply is roughly 3.5× that — about **3.5 billion**. A
Montgomery ladder is 255 steps of some ten field multiplications, so a single
scalar multiplication is on the order of **9 × 10¹² instructions, about four
hours** at the measured 570 million per second. A handshake needs one or two.

That is slow and it is not a reason to decline: this library's claim has never
been speed. It *is* a reason to write the cheaper `mulmod136` first — already
recorded as an open item — since every saving there multiplies by 2550.

**RSA and the NIST P-curves stay out**, for the reason the old text gave: their
moduli have no exploitable form, so they need Montgomery or Barrett reduction,
which really is new mathematics here. And RSA-2048 modexp is two thousand
squarings of two-thousand-bit numbers, which is a different order of problem
again.

#### Out of scope, with the reason — RSA and the NIST P-curves

**RSA (PKCS#1), ECDSA and ECDH over P-256/384/521 are out of scope, and this
is a decision rather than an omission.** The blocker is general modular
multiplication.

`poly1305/mulmod136` is 18,761 lines and works because 2¹³⁰−5 has a special
form that makes reduction cheap. A general 256-bit or 2048-bit modmul needs
Montgomery or Barrett reduction, which is new
mathematics for this library rather than a bigger version of something it has.

And the arithmetic does not fit the cost model. RSA-2048 modexp is roughly two
thousand squarings of two-thousand-bit numbers; P-256 scalar multiplication is
roughly two hundred and fifty-six point operations, each several 256-bit
modmuls. At 570 million instructions per second that is plausibly **hours per
operation** — a guess, and one nobody should refine without first measuring a
single general modmul.

It is written here rather than left off the list because *"not yet"* and *"not
without new mathematics and a different cost model"* are different statements,
and a reader deserves the second one.
