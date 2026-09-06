# bfsodium conventions

This document is the rulebook every `.bf` file in bfsodium obeys. Its job is to
make hand-structured brainfuck **legible and reviewable** — the difference
between committing assembly and committing a binary blob. A reviewer cannot
verify a crypto routine's *correctness* by reading brainfuck (nobody can); that
is the job of the test suite (§8). What legibility buys is **intent and diff
comprehension**: a reviewer can see *which* block changed and read the contract
it claims to honour. These conventions exist to make that possible.

The code is AI-generated, but it is committed as brainfuck a human can follow.

---

## 0. The one rule that bites first: comments are code unless you are careful

brainfuck executes every one of these eight bytes wherever it appears, including
inside what you think is a comment:

```
> < + - . , [ ]
```

So a comment reading `QUARTER-ROUND` silently executes a `-` (decrement), and a
range written `0x00..0x1F` executes two `.` (output). **Comment and
documentation text embedded in a `.bf` file MUST avoid all eight command
bytes.** In practice:

- Use letters, digits, spaces, and this safe punctuation only: `_ : = ; ! ? # @ * / ( ) { } | ~ ^ $ % &`
- Never use `-` in a comment — use `_` in names (`QUARTER_ROUND`, not `QUARTER-ROUND`).
- Never use `.` in a comment — the range separator is a colon (`0x00:0x1F`), never `..`; end sentences with `;` or nothing, not a period.
- When you must *refer* to a command byte in prose, name it: `PLUS MINUS LEFT RIGHT DOT COMMA OPEN CLOSE`.

Everything below is designed to be written with the safe set, so tape maps,
block headers, and idiom annotations can live directly in the source.

(This file is Markdown, not brainfuck, so it uses normal punctuation freely.
The rule applies only to text inside `.bf` files.)

---

## 1. Machine model (frozen)

bfsodium targets one interpreter with one semantics profile, implemented by
`tools/bfi.c` (the pinned reference; see also §8):

- **Cells** are unsigned 8-bit and **wrap mod 256**. We *rely* on the wrap as
  free modular-byte arithmetic.
- **Tape** is unbounded to the right, zero-filled on first touch.
- **Cell 0 is the floor.** Moving left of it is a hard error (`bfi` exits 3).
  bfsodium code never does this; the check turns a pointer-discipline slip into
  a loud failure instead of silent corruption.
- **`,` at end of input leaves the cell unchanged.** Primitives read an exact,
  known number of bytes (§7), so this is a safety net, never a control path.
- **`.` and `,` are raw bytes.** No newline or encoding translation.
- Any byte outside the eight commands is a comment (§0).

No other dialect features (no wide cells, no negative tape, no extra I/O) are
used. If a program depends on anything outside this list, it is wrong.

---

## 2. Numbers on the tape

- A **32-bit word** is 4 consecutive cells, **little-endian**: cell offset `+0`
  is the least-significant byte, `+3` the most-significant. All internal word
  math uses this layout.
- A **bignum** is an array of base-256 limbs, little-endian, least-significant
  limb first, fixed length per primitive.
- **Endianness is converted only at the I/O boundary** (§7) for formats that are
  big-endian on the wire (e.g. SHA-256). Internally, everything is
  little-endian, always, so there is exactly one convention to hold in your head.

---

## 3. Tape map (the keystone of legibility)

Every `.bf` file begins with a **tape map**: a comment header declaring what
lives in every cell region, relative to the file's home cell (normally cell 0).
brainfuck's unreadability comes almost entirely from implicit cell positions;
the tape map makes them explicit.

Notation (all operator-free per §0):

```
; TAPE MAP  (home @0)
;   @0x00:0x3F  state[16]   u32 LE   ; the 16 working words
;   @0x40:0x7F  init[16]    u32 LE   ; original state, for the final add
;   @0x80:0x83  ctr         u8       ; round/loop counters
;   @0x84:0x8B  t[8]        u8scratch ; scratch, zero on entry and exit
```

- Addresses are hex, **cell-granular**, ranges joined with a colon (`:`).
- Each region names a symbol, a count, a type (`u8`, `u32 LE`, `u8scratch`,
  ...), and a one-line purpose.
- Layout is **static** per primitive: fixed regions, decided up front. No
  dynamic allocation, no stack. Crypto state is fixed-size; static maps review
  cleanly.

---

## 4. Pointer discipline (what makes diffs local)

The single worst brainfuck failure mode is a stray `>`/`<` that shifts every
subsequent cell reference, so one wrong character makes the whole file wrong and
every diff illegible. Three invariants prevent it:

1. **Blocks are pointer-neutral.** A named block entered with the pointer at its
   declared anchor leaves the pointer at that same anchor. Composition is then
   just concatenation, and a change inside one block cannot shift another.
2. **Addressing is block-local.** A block reaches cells as offsets from its
   anchor, documented in the block contract — never as absolute tape positions
   threaded through from far away.
3. **Scratch is zero-in, zero-out.** Every scratch cell a block uses is 0 when
   the block starts and is restored to 0 before it ends. So any block may assume
   clean scratch, and no block leaks state into the next.

Each block carries a **contract** comment (operator-free) stating its anchor,
what it reads, what it writes, and which scratch it borrows:

```
;;; BLOCK add32  in: ptr@a  reads a@0x00:0x03 b@0x04:0x07  writes a (a = a plus b mod 2^32)  scratch t@0x84 (restored 0)  out: ptr@a
```

---

## 5. Idiom pseudo-ISA

We write in a small, fixed vocabulary of named idioms so a reviewer learns the
"instruction set" once and then reads blocks in its terms. Canonical brainfuck
implementations and exact pointer contracts live in `IDIOMS.md`; this is the
authoritative list of what exists and what each guarantees. Every idiom is
pointer-neutral unless its name says otherwise.

Core:

- `CLEAR c`        — set cell `c` to 0.
- `MOVE s -> d`    — add `s` into `d`, leaving `s` = 0 (destructive).
- `COPY s -> d`    — set `d` = `s`, `s` preserved (uses one scratch cell).
- `ADD s -> d`     — `d = d plus s mod 256`, `s` preserved.
- `IF c { ... }`   — run body once if `c` is nonzero (body must be pointer-neutral).
- `IFELSE c { ... } { ... }` — two-armed conditional.

Word / crypto layer (built on the core; contracts in `IDIOMS.md`):

- `ADD32 a += b`   — 32-bit add-with-carry across 4 LE cells.
- `XOR8 d ^= s`    — byte XOR via the lookup table (§6-tables).
- `XOR32 d ^= s`   — four `XOR8`.
- `ROTL32 w, n`    — rotate a 32-bit word left by `n` (free byte-rotate for
  multiples of 8, plus a sub-byte shift/OR for the remainder).

**Indexed table lookup** (the crux idiom, contract in `IDIOMS.md`): fetch
`table[i]` by travelling the pointer a computed offset to the entry, copying it
out, and travelling home — pointer-neutral. This is how all table-backed ops
(starting with XOR) read their tables.

---

## 6. Structure, formatting, and tables

**Sections.** Blocks are delimited by operator-free header comments so they are
scannable and greppable:

```
;;; QUARTER_ROUND a b c d
    ... brainfuck ...
;;; END QUARTER_ROUND
```

**Formatting.**
- Indent the body inside every `[ ]` by two spaces; matching brackets line up.
- One logical operation (or one idiom invocation) per line, with an
  operator-free comment naming it.
- Keep raw command runs short and annotated; a bare wall of `+`/`>` with no
  comment is a review failure, not a style nit.

**Fixed rounds are counter-driven loops,** not unrolled. A round body is written
once and repeated under a cell counter (e.g. ChaCha20 = 10 iterations of a
doubleround). Round bodies that need per-round constants read them by
`Indexed table lookup`; where the counter only repeats (ChaCha20), no indexing
is needed.

**Bitwise is table-backed.** brainfuck has no native bitwise op. A 256x256
byte-XOR table is materialised on the tape **once at startup**, built by a small
bit-decomposition routine (the only place bit-decomposition is used); every
runtime XOR is then an `Indexed table lookup`. AND/NOT/other tables are added
only when a later primitive needs them, each built once and documented in its
file's tape map.

---

## 7. I/O contract (a primitive's signature over stdio)

bfsodium is pure computation: **plain stdin/stdout, no syscalls, no P1 broker.**
Randomness, when a future primitive needs it, is supplied as input bytes, never
generated — which keeps every run deterministic and replayable.

Each primitive is **one-shot**: it reads an exact, documented input layout from
stdin, then writes an exact output layout to stdout. Each file's header states
its signature in operator-free notation, e.g.:

```
; IO  in:  key[32] ++ nonce[12] ++ counter[4 LE]     (48 bytes)
;     out: keystream[64]
```

Byte counts are exact and fixed (or length-prefixed where a primitive is
variable-length); a primitive never relies on EOF to know when to stop.

---

## 8. Testing protocol

bfsodium subscribes to reaper's `docs/testing-methodology.md`
(https://github.com/axonibyte/reaper): a **portfolio of oracles**, each earning
its place by a defect no cheaper tier can catch. The rules are non-negotiable:

- **Two oracles for the claim that matters.** A primitive's output is checked
  against **both** the published standard test vectors (e.g. RFC 8439) **and** an
  independent computation by the **Cryptol** specification (`spec/*.cry`), whose
  `[32]`-word arithmetic is exact and whose properties can themselves be
  `:prove`-checked. Both must agree with the brainfuck, byte-for-byte.
- **Mutation-check every assertion (revert-and-rediscover).** For each
  nontrivial block, break it (flip a rotation constant, drop the final
  state-add, corrupt one table entry), confirm a KAT fails, then restore. A test
  never observed failing is unmeasured.
- **Self-test the oracle.** Feed the checker output a *broken* primitive would
  produce and confirm it complains.
- **Determinism and replay.** The differential-fuzz tier (random inputs compared
  bf-vs-Cryptol) prints its seed and accepts it back through the environment; a
  replay reproduces the sequence exactly.
- **Never weaken a test to pass.** No skips, no narrowed scopes, no lowered
  comparisons. Every narrowing needs a stated reason covering exactly what it
  narrows.
- **The pinned interpreter is the reference.** All tests run through `tools/bfi`
  (§1). Its own semantics are smoke-tested (Hello World, binary echo,
  EOF-unchanged, left-of-0).

Tiers, as they apply here. Each earns its place by a defect no cheaper tier
can see; the KAT/fuzz tiers inspect **output**, so they are deliberately paired
with tiers that inspect **the oracle** and **internal structure**:

| Tier | Question it answers | How |
|---|---|---|
| 1 interpreter self-test | Is the oracle-of-record itself correct? | `tools/bfi` exercised on core ops, nested loops, tape growth, wrap (255 to 0 and 0 to 255), bracket matching, EOF-unchanged, left-of-0. Everything trusts `bfi`, so `bfi` must be trustworthy. |
| 2 idiom boundary KAT | Do the building blocks hold at the edges? | Each idiom tested at its boundaries: `ADD32` full carry cascade (0xFFFFFFFF plus 1), `ROTL32` by 0/8/16/31, indexed lookup at index 0/mid/255, empty/one/many. Catches edge bugs a single whole-primitive KAT masks. |
| 3 table integrity | Was the build-once table built right? | After the XOR table is materialised, verify every one of the 65536 entries equals the computed value. Localises a table bug versus an algorithm bug. |
| 4 golden-vector KAT (dual oracle) | Does the primitive match the standard, exactly? | Published standard vectors (RFC/NIST) through `bfi`, required to match **both** the vector **and** the Cryptol spec, byte-for-byte. |
| 5 convention invariants | Does the code obey the conventions composition depends on? | An instrumented `bfi` asserts, at annotated checkpoints, that the pointer is at its declared anchor and scratch regions are zero; and after any primitive, scratch is clean and the pointer is home. Catches dirty-scratch / off-anchor bugs that pass every output-only tier but break under composition. (Lightweight now: post-run scratch-and-pointer check; fuller per-checkpoint form via the instrumented interpreter as primitives start composing.) |
| 6 differential fuzz | Do untried inputs diverge from the spec? | Random inputs, bf output versus Cryptol output; seed printed and replayable through the environment. |
| 7 metamorphic / property | Do reference-free invariants hold? | Checks that need no oracle: keystream-XOR involution (decrypt of encrypt is identity), distinct block per counter, stream-versus-block-function agreement. Independent of whether the spec is right. |
| 8 mutation (revert-and-rediscover) | Would the suite catch the bug it claims to? | Break each nontrivial block, confirm the relevant tier fails, restore. |
| 9 legibility | Can a human reasonably read this, within brainfuck's limits? | Two parts. (a) `tools/bflint` mechanically enforces the objective conventions: every file carries a tape-map and an IO header; prose lines (those starting with `;`) are operator-free; no un-annotated run of command bytes exceeds the budget; loop bodies are indented to bracket depth; block contracts are present and their BEGIN/END are balanced. Self-tested by feeding it minified / header-less / command-wall input and confirming it complains. (b) Human evidence (reaper tier 11, adapted from UI to source): a brainfuck-literate reviewer confirms a sampled block is followable from its contract **and that the contract and comments accurately predict the tested behaviour** — a comment that lies fails this tier, a defect no code-versus-spec tier can catch and the sharpest risk when code and comments are both machine-generated. The linter proves convention-conformance, legibility's necessary floor; it cannot prove "understandable," so both parts are required. |

**Named non-goals** (what we do NOT prove):

- **Constant-time / side-channel resistance.** brainfuck branches on data (the
  `[` `]` loops), the interpreter is not constant-time, and this is a stunt
  library. We make no timing claim and run no timing test. Do not use bfsodium
  where side channels matter.
- **reaper tiers that do not apply here**, named rather than silently skipped:
  concurrency (bfsodium is single-threaded pure computation); simulated-users
  and live-browser tiers (there is no stateful service or UI). reaper's
  human-evidence tier is *not* skipped — it is adapted into the legibility tier
  (tier 9), since "can a human read this" is this project's whole reason to
  exist.

The tenant is wired in `/.reaper.toml`; `reaper test` is the gate.

---

## 9. Scope and roadmap

**v1 — the symmetric set,** in order:

1. ChaCha20 (RFC 8439) — first; establishes every convention here.
2. Poly1305.
3. ChaCha20-Poly1305 AEAD.
4. SHA-256.
5. HKDF-SHA-256.

**Later — the mountain:** Keccak / SHAKE, then the NTT and sampling for ML-KEM
and ML-DSA. Out of scope until the symmetric set is done and the conventions
have proven themselves.

**Downstream target:** bfsodium's outputs must eventually match the BoneMesh
shared corpus (`keyschedule.json`, `transport-frame.json`, ...) byte-for-byte,
so the symmetric set is chosen to cover BoneMesh's handshake/transport needs.
