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

A paste site **must** state the base its callee's zero lands on
(`@@ADD136@@ 0`). Omitting it is a hard error rather than a guess, because a
routine's contracts are written relative to its own base and have to be
rebased.

---

## 5. Idiom vocabulary

A small fixed vocabulary so a reviewer learns the instruction set once. Exact
brainfuck and pointer contracts live in `IDIOMS.md`; this is the authoritative
list of what exists.

Core: `CLEAR`, `MOVE` (destructive add into the destination), `COPY`,
`ADD`, `IF`, `IFELSE`, `HALVE`, `DOUBLE`.

Word layer: `ADD32`, `XOR32`, `ROTL32`, `ROTR32`, `SHR32`, `AND32`.

**Bitwise is computed, not table-backed.** An earlier plan materialised a
256×256 XOR table on the tape once at startup. It was **rejected** — see
`IDIOMS.md` — and nothing in the tree builds one. Byte XOR is eight halvings; a
table would cost 64 KiB of tape and an indexed read, and indexed reads are the
expensive thing here, not the arithmetic.

**Indexed addressing exists and is unused.** `index/fetch8`, `index/store8` and
`index/fetchword` are hand-written, verified, and reachable if a future
primitive genuinely needs a run-time index. Nothing has. Which brings us to:

**Conveyors, not indices.** Every loop in this repository brings the data to the
code rather than reaching for the data with an index. `blockloop` rotates the
ChaCha state so the four words a quarter round wants are always at the same four
cells. `mulmod136` carries its operands to a fixed work frame at cell zero.
`poly1305` lands each message byte on the top of the block and slides the block
down one, so a byte taken in round `k` comes to rest at `blk[k]` with no index
anywhere — and a short block comes out right for free.

This is not an aesthetic preference. Indexed addressing on a tape costs pointer
travel proportional to distance, and the conveyor is usually both cheaper and
far easier to prove.

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
| 8 design proofs | Is the structure itself sound, over all inputs? | Cryptol `:prove` over the design, not the bytes: the looped quarter round equals the quarter round, one fold suffices for `reducep136`, the adder's carry and sum identities. Each is paired with a companion that must be **refuted**. |
| 9 legibility and portability | Can a human read this, and is it really brainfuck? | `tools/bflint` proves the instruction stream with `;` honoured is identical to the stream with only command bytes kept, and enforces the legibility floor: a tape map and an IO header, operator-free prose, no wall of command bytes on one line. Self-tested against minified and header-less input. |
| 9a style consistency | Is the style the same across every source file? | `tools/bfstyle`: a title then `IO` then `TAPE MAP`; a trailing annotation at exactly column 64 and a standalone one at column 0; **no run of more than 12 code lines without an annotation**. This tier exists because style silently drifted and **no other tier could see it** — every other tier checks what the code computes, not how it reads. |
| 9b size budget | Is this file short enough that a person would actually read it? | `bfstyle` fails any file over 2000 lines, counting the **skeleton** where one exists. Added after the composites drifted to 42k lines, 66k, and — in an AEAD never committed — 903k, every one of which passed all the other checks. The exemption is sound only because the suite separately proves every `.bf` equals `bfexpand` of its skeleton byte for byte; the two halves are one check and removing either reopens the hole. |
| 9c provenance | Is the committed brainfuck what its skeleton says? | Every `.bf` compared byte for byte against `bfexpand` of its `.skel`, and `bfexpand`'s own refusals tested: a paste site with no base is an error, an unknown routine is an error. |
| 9d the interface tells the truth | Does the `INTERFACE` line describe the code? | `tools/bffoot` proves entry, exit and footprint against the instruction stream (§4). The set of files that declare no `INTERFACE` is pinned, so a new routine that forgets the line fails rather than passing silently. |
| 9e the documents describe the tree | Is the routine table still true? | `tools/bftable.pl` checks `HANDOFF.md`'s table against the tree. Added after eighteen of its thirty rows were found wrong: a number nobody verifies is not documentation, it is a rumour. |
| 10 one definition of the toolchain | Do the two lanes test the same thing? | The suite greps the `Containerfile` to prove it installs nothing of its own and calls `guest-setup.sh --toolchain`. A second definition is how a fallback lane starts passing what the gate would fail — silently, because a container with a different z3 still runs every test and still says PASS. |
| 11 mutation | Would the suite catch the bug it claims to? | Break each nontrivial block, confirm the relevant tier fails, restore. |

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

---

## 9. Scope and roadmap

**v1 — the symmetric set. Complete.**

ChaCha20 (RFC 8439), Poly1305, ChaCha20-Poly1305, SHA-256 with HMAC, and
HKDF-SHA-256. All five are in, hand-written, and gated.

**What v1 does not yet have:**

1. **Proof that the set is sufficient.** The downstream target is the BoneMesh
   shared corpus — `keyschedule.json`, `transport-frame.json` — and nothing has
   ever been checked against it. That is the thing that would show the set is
   sufficient rather than merely complete.
2. **Tier 6.** Declared above, not built.
3. Cheaper `mulmod136`, and `qrloop` pasting `rotr32` rather than `rotl32`,
   both recorded with measurements in `HANDOFF.md`. Neither is needed; both are
   written down so the next person does not rediscover them.

**Later — the mountain:** Keccak and SHAKE, then the NTT and sampling for ML-KEM
and ML-DSA. **Post-quantum is explicitly out of scope** and stays out until the
questions above are answered.
