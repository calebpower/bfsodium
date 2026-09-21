# bfsodium — handoff

Written for whoever picks this up next. It assumes you have read `README.md` and
`CONVENTIONS.md`; this is the part those do not say, which is how the thing is
actually built and where it has bitten.

## State

**Gated: 354 pass, 0 fail on `ubuntu-26.04` AND 354 pass, 0 fail on
`freebsd-15.1`, at `7ffd67f`** -- `reaper test`, which the lane section below
calls the gate of record. `tools/guest-setup.sh` clones and builds brainstem
at `BRAINSTEM_COMMIT` before the suite starts, so every gate here needs the
network. The previous gates were 347 at `cc974dc` and 345 at `7436078`, both
on one guest.

**THE FIRST RUN ON A SECOND PLATFORM, AND IT FOUND NOTHING.** That is worth
recording rather than passing over. The guest exists because five C programs
here had only ever seen gcc and `bfi` is the interpreter every correctness
claim rests on; clang compiled all five clean and every KAT agreed. A guest
that finds nothing on its first run has still moved something from *assumed*
to *measured*, and brainstem's `bcmp` trap is the reminder that the reverse
outcome was entirely available.

It also settled two things that could only be settled by running them:
`security/hs-cryptol` from ports really does satisfy `CRYPTOL_VERSION` -- the
version check in `guest-setup.sh` passed, so quarterly is still at 3.4.0 --
and tier 12 drives the pinned broker through `spawn`, `pipe`, `open`, `stat`
and `readdir` on FreeBSD, which is brainstem's primary platform and had never
been exercised from this side.

**TWO GUESTS, AND BOTH RUN ALL OF IT.** `ubuntu-26.04` and `freebsd-15.1`. No
tier declares a guest. For one commit tier 8 did, and `CONVENTIONS.md` §8.1
keeps the account because the reasoning was half right -- which is the
dangerous kind.

**The second guest exists for a second C compiler.** Five C programs live here
-- `bfi`, `hx`, `bflint`, `bfstyle`, `bffoot` -- and until that guest every
one had only ever seen gcc. `bfi` is the interpreter every correctness claim
in this library rests on. brainstem's `bcmp` trap is the argument in full:
clang rewrites `memcmp(a, b, n) != 0` into a different symbol and gcc does
not, and nothing runnable on the development host could have revealed it.

**THE MISTAKE, because it cost a gate run and is the kind that sounds like
analysis.** Tier 8 was taken off FreeBSD on two grounds. First, that a proof
is a statement over bitvectors and "for all 2^136 inputs" does not care which
kernel asked -- TRUE, and still true. Second, that Cryptol is therefore not
needed on that guest at all, because the dual oracle's values are pinned
literals -- FALSE. `tools/dkat.sh` runs `cryptol -b` ONCE PER VECTOR and
compares the brainfuck against what the spec computes, live. That is what
makes it a dual oracle rather than a table of numbers somebody once
generated. Tiers 2 and 4 are 157 checks and every one needs Cryptol.

I grepped `tests/run.sh` for `cryptol`, found three sites, none of them a KAT,
and wrote a sentence about the suite. `dkat.sh` is a different file. FreeBSD
answered with **156 failures in two tiers**, 190 pass against Ubuntu's 354.

`grep -rl cryptol tools/ tests/` answers that question in one command and was
not run. **"This dependency is only used by tier N" is a claim about the whole
suite, and the suite is more than one file.**

**Two more documented claims were wrong, and the three make a set.** One said
tier 12 gave this library a platform surface only FreeBSD could test; the
platform-dependent half is the BROKER, gated on both guests in its own
repository at the very commit this pins. The other said a FreeBSD guest was
impossible because Cryptol ships tarballs for Linux and macOS only -- true of
the GitHub release assets, false of FreeBSD, which has carried
`security/hs-cryptol` all along. **I checked what upstream published and
stopped there. A dependency is not only what its author publishes.**

**So Cryptol is installed on both guests**, from ports on FreeBSD, and the
version is VERIFIED against `CRYPTOL_VERSION` rather than trusted: `pkg`
installs whatever quarterly carries, quarterly rolls, and the day it carries
3.6.0 two guests would be proving things with two oracles while the pin
quietly meant nothing. `guest-setup.sh` fails the provision and says which of
the two to move.

Two things survive from the attempt: the summary names the platform, and tier
10 compares `.reaper.toml`'s guests against the `# GUEST` markers in
`guest-setup.sh` so a guest without a provisioning branch is a failure rather
than a guest that falls into whichever arm happens to match.

The lane and the commit are named because "the suite is 354 pass, 0 fail" is
not a fact, it is a measurement, and a measurement with neither of those is a
sentence that starts expiring the moment it is written. Update both together
or neither.

The v1 set CONVENTIONS section 9 asks for is complete: ChaCha20, Poly1305,
ChaCha20-Poly1305, SHA-256 and HKDF-SHA-256.
Every committed `.bf` is hand-written; nothing is generated by anything but
`tools/bfexpand.sh`, and the transpiler that used to generate most of the repo
(`tools/bfemit.sh`, `tools/*asm.sh`) is deleted.

The two columns below are checked by `tools/bftable.pl`, not typed. If you add a
routine, the suite fails until it has a row here.

| routine | `.bf` | `.skel` | verified against |
|---|---|---|---|
| `idiom/add8` | 175 | 183 | every one of the 65536 pairs + two proved identities |
| `chacha20/add32` | 631 | 166 | boundary vectors + Cryptol |
| `idiom/and32` | 268 | 325 | boundary vectors + Cryptol |
| `idiom/rotr32` | 120 | 131 | boundary vectors + Cryptol |
| `idiom/rotr64` | 206 | 225 | boundary vectors + Cryptol  SHA_512 Sigma1 counts |
| `idiom/rotl64` | 307 | 148 | boundary vectors + Cryptol  both ends of the byte and bit split |
| `idiom/shr32` | 121 | 133 | boundary vectors + Cryptol |
| `idiom/shr64` | 210 | 229 | boundary vectors + Cryptol  SHA_512 sigma shifts |
| `idiom/add64` | 1220 | 291 | boundary vectors + Cryptol  carry cascade and wrap |
| `idiom/and64` | 480 | 601 | boundary vectors + Cryptol |
| `idiom/xor64` | 290 | 427 | boundary vectors + Cryptol |
| `chacha20/rotl32` | 259 | 175 | boundary vectors + Cryptol |
| `chacha20/xor32` | 125 | 190 | boundary vectors + Cryptol |
| `chacha20/stagger` | 225 | 253 | Cryptol |
| `chacha20/rowrot` | 246 | 306 | Cryptol |
| `chacha20/qrloop` | 1154 | 351 | RFC 8439 §2.2.1 |
| `chacha20/blockloop` | 4207 | 1252 | RFC 8439 §2.3.2 |
| `chacha20/blockkeep` | 4875 | 341 | RFC 8439 §2.3.2 + its input surviving |
| `chacha20/stream` | 6156 | 711 | RFC 8439 §2.4.2 + block edges |
| `poly1305/add136` | 2563 | 542 | boundary vectors + Cryptol |
| `poly1305/halve136` | 470 | 539 | boundary vectors + Cryptol |
| `poly1305/fold136` | 962 | 588 | boundary vectors + Cryptol |
| `poly1305/dbl136` | 610 | 763 | boundary vectors + Cryptol |
| `poly1305/reducep136` | 3810 | 375 | boundary vectors + Cryptol + a proof |
| `poly1305/mulmod136` | 10004 | 472 | boundary vectors + Cryptol |
| `poly1305/clamp` | 248 | 299 | boundary vectors + Cryptol  the mask pinned both ways |
| `poly1305/absorb` | 12583 | 127 | boundary vectors + Cryptol + folds to the RFC tag |
| `poly1305/poly1305` | 17070 | 935 | RFC 8439 §2.5.2 + block edges |
| `aead/keygen` | 4188 | 44 | RFC 8439 §2.6.2 + A.4 vectors 1 and 2 |
| `sha256/round` | 8154 | 1158 | seven vectors + Cryptol |
| `sha256/expand` | 3310 | 475 | seven vectors + Cryptol |
| `sha512/expand` | 6750 | 595 | eight vectors + Cryptol |
| `sha512/round` | 16760 | 1419 | FIPS 180-4 first abc round + six more + Cryptol |
| `sha256/hashcore` | 26476 | 1635 | one message from memory, the wire, and both |
| `sha256/sha256` | 26504 | 60 | FIPS 180-4 + both padding boundaries |
| `sha512/hashcore` | 58423 | 1867 | one message from memory, the wire, and both |
| `sha512/sha512` | 58473 | 64 | FIPS 180-4 + both padding boundaries |
| `sha512/hmac` | 240868 | 1700 | RFC 4231 cases 1, 2, 3 and 6 + three edges |
| `sha512/hkdf` | 615493 | 583 | RFC 5869's three shapes at SHA-512 + one byte out |
| `sha512/sha384` | 58568 | 84 | rate aside  this is SHA_512 with eight other words; nothing  abc and both block boundaries + Cryptol |
| `sha512/sha512_224` | 58576 | 78 | the same four  and the only one whose digest cuts a word in half + Cryptol |
| `sha512/sha512_256` | 58572 | 78 | the same four; its H4 was one bit wrong until the words were DERIVED + Cryptol |
| `sha256/hmac` | 105014 | 1666 | RFC 4231 cases 1, 2, 3 and 6 |
| `sha256/hkdf` | 294912 | 512 | RFC 5869 A.1, A.2 and A.3 |
| `sha256/kdfctr` | 132269 | 324 | SP 800-108 §4.1 counter mode at both inner-hash block counts, one turn, two turns, a turn cut short and no fixed input |
| `sha256/kdffb` | 133227 | 332 | SP 800-108 §4.2 feedback mode: one turn, two turns so the chain feeds back, a turn cut short, no fixed input, and the longest fixed input allowed |
| `sha256/pbkdf2` | 136571 | 716 | RFC 7914 §11's published c=1 and c=2 vectors, two output blocks, a block cut short, and the longest salt allowed |
| `sha256/drbg` | 222028 | 608 | NIST's published CAVP vector for HMAC_DRBG SHA-256, a generate cut short, and the longest seed allowed |
| `aead/chacha20poly1305` | 53178 | 1533 | RFC 8439 §2.8.2 + both block edges + metamorphic |
| `keccak/theta` | 18769 | 878 | the two eye-checkable states  both corner bits  a ladder and a random state + Cryptol |
| `keccak/rhopi` | 9116 | 334 | the same six states + Cryptol |
| `keccak/rhopichi` | 31539 | 1026 | rho and pi PASTED  the same six states + Cryptol  all ones is the one chi cannot fake |
| `keccak/permute1600` | 51119 | 271 | the published all zero vector and a random state + Cryptol |
| `keccak/rotstate` | 98 | 56 | all zero  a ladder and a random state whose bottom byte travels + Cryptol |
| `keccak/sponge136` | 116892 | 717 | the same .bf handed a 6 and a 31  and one squeeze past a rate + Cryptol |
| `keccak/sha3_256` | 116866 | 57 | sponge136 PASTED with a 6; FIPS 202's abc + nothing + both padding boundaries + Cryptol |
| `keccak/shake256` | 116868 | 55 | sponge136 PASTED with a 31; both sides of the rate and two blocks in one rate out + Cryptol |
| `keccak/sponge168` | 120430 | 776 | one inside the first rate and one past it + Cryptol |
| `keccak/shake128` | 120402 | 58 | sponge168 PASTED with a 31; both sides of the rate and two blocks in one rate out + Cryptol |
| `keccak/sha3_224` | 66165 | 523 | rate 144 with the constants written in; nothing  abc and both padding boundaries + Cryptol |
| `keccak/sha3_384` | 61875 | 458 | rate 104  the same four + Cryptol |
| `keccak/sha3_512` | 58572 | 406 | rate 72  the same four + Cryptol |

`aead/chacha20poly1305` is interleaved, not staged: sixteen bytes are
encrypted, written out and folded into the tag, then the next sixteen. Nothing
buffers the ciphertext, so the tape does not grow with the message — which is
the whole point, since the AEAD that was never committed reached 903k lines by
unrolling over it. The skeleton is 1533 lines against the 2000 budget.

Its one simplification worth knowing: `mac_data` is padded to a multiple of
sixteen at *every* stage, so **every** Poly1305 block is full and the appended
ONE always sits at `blk{16}`. None of `poly1305.skel`'s flag-driven partial
block machinery is needed, and padding is just landing a nought when the input
has run out — the conveyor gives it for free.

`chacha20/blockkeep`, `poly1305/clamp` and `poly1305/absorb` are the pieces the
AEAD needed and that used to be reachable only from inside another file. All
three are pasted rather than copied, so there is one source for each.

`poly1305/absorb` is the step every block takes -- `acc := (acc + blk) * r
mod p` -- and is now the only place the multiply lives; `poly1305` pastes it
rather than carrying its own copy, and the AEAD will paste the same file. Its
frame sits past everything `poly1305` keeps, so the glue at the paste site only
has to hand it three operands and take the accumulator back.

`index/` holds three indexed-addressing routines (`fetch8`, `store8`,
`fetchword`) that nothing currently uses. They work and they are the escape
hatch if a future primitive genuinely needs a run-time index — but see
*Conveyors, not indices* below, because so far nothing has.

### Which tiers are actually built

`CONVENTIONS.md` section 8 says which tiers the project **requires** and why.
This table says which of them **exist**, and `tools/bftier.pl` checks it
against `tests/run.sh` rather than anyone typing it. The two were one table
until tier 6 sat in it in the same voice as the tiers that ran, and a reader
seeing that beside a green suite concluded there was fuzz coverage.

`run.sh lines` counts SOURCE lines, not checks: a loop over thirty files is one
line. `manual` means a practice rather than an automated check, and such a tier
must have no marker in the suite at all.

| tier | built | run.sh lines | what it is |
|---|---|---|---|
| 1 | yes | 7 | interpreter self-test |
| 2 | yes | 350 | idiom boundary KATs, interleaved with tier 4 |
| 4 | yes | 350 | golden vectors, dual oracle |
| 5 | yes | 50 | declared contracts under BFI_CONTRACTS |
| 6 | no | 0 | **differential fuzz, declared and not built** |
| 7 | yes | 2 | metamorphic |
| 8 | yes | 8 | Cryptol design proofs, two of which must be refuted |
| 9 | yes | 6 | legibility and portability |
| 9a | yes | 1 | style consistency |
| 9b | yes | 1 | size budget, enforced inside bfstyle |
| 9c | yes | 4 | provenance: every .bf equals bfexpand of its skeleton |
| 9d | yes | 2 | the INTERFACE line tells the truth |
| 9e | yes | 2 | the routine AND tier tables describe the tree |
| 10 | yes | 2 | one definition of the toolchain, and the declared guests |
| 11 | manual | 0 | mutation, a discipline rather than a check |
| 12 | yes | 14 | composition: a program chains routines through the broker |

## What is next

### The order, and why this one

Agreed with the owner rather than inferred, and written down because **this
list has twice named a change that was wrong** — item 2 asked to specialise a
caller when the cost was a callee entered with an empty operand, and item 3
asked for `rotr32` with complementary counts when rebuilding ROTL32 on the
byte-turn identity was worth ten times more. Both were one measurement from
the right answer. An order without its reasoning is how that happens; here is
the reasoning.

1. **DONE: the AES measurement says yes.** A 256-entry fetch is **248,084
   instructions** averaged over a uniform index with the real S-box as its
   data; AES-128 wants 200 of them per block, which is 50 million, and the
   rest of a block brings it to roughly 75 million against SHA-256's 1.15
   billion. **An AES-128 block is about an order of magnitude cheaper than a
   SHA-256 block.** §9.1 carries the full result and the two side findings —
   that `index/fetch8` cannot reach a 256th element, and that the cost is
   driven as much by the datum as by the index.

   It went first because it was **the only item whose outcome was unknown**,
   and a bad number would have taken AES, CMAC, GCM, GMAC and CTR_DRBG off the
   plan together. It did not, so step 6 stands and the tier behind it is open.

2. **DONE: SHA-384, SHA-512/224 and SHA-512/256.** And **this step was not as
   cheap as this list said it was**, which is the third time that has happened
   here. "The same core, a different IV, a truncation" is true of the
   ALGORITHM; in the code the IV lived inside `sha512/hashcore`, which HMAC
   and HKDF both paste, so the variants needed the core parameterised.

   The obvious parameterisation was rejected after it was costed: a 64-byte
   IV-delta buffer grows `hashcore`'s footprint past `0:1859`, and `hmac512`
   parks `kpad{128}` at `@0x950` — **four cells above where hashcore's frame
   ends** — so it would have cascaded into re-laying `hmac512` and then
   `hkdf512`. What landed instead is **one cell**: a flag at `@0x21a`, nought
   meaning "write SHA-512's words" and one meaning "the caller wrote H". No
   footprint change, `sha512`, `hmac512` and `hkdf512` untouched, and each
   variant's initial words live in that variant's own head where they belong.
   The flag is deliberately not spent, which is what makes HMAC-SHA-384 a
   head-only change later.

   **The defect worth keeping:** SHA-512/256's H4 was typed from memory with
   one bit wrong — `…effe2` for `…effe3`. SHA-384 and SHA-512/224 passed, so
   the mechanism was right and only the constant was not. The spec now DERIVES
   all three from FIPS 180-4's own rule rather than transcribing them, and the
   derivation is self-checking: the same code reproduces SHA-512 itself.

3. **DONE: HKDF-SHA-512's info cap, sixty three bytes to 190.** And it took
   **four** widenings rather than the one this list predicted, because each
   buffer in the chain became the binding limit the moment the one below it
   moved — and two of the four were **run lengths, not buffers**, which no
   cell-insertion transformer can find for you:

   - `sha512/hashcore`'s prefix buffer, **256 → 448** cells, by inserting 192
     at hashcore-relative 260 — **and the slide that consumes it, 255 → 447
     steps**, without which the new cells never reach the head and every
     prefix over 256 silently reads noughts past that point. Inserting cells
     is mechanical; noticing that a *run length* was a buffer length in
     disguise is not, and this change turned up two of those. The buffer
     widening on its own moved the cap from 63 to **64** — one byte.
   - `sha512/hmac`'s copy of the message prefix into that buffer, a run of
     **128 move tokens grown to 256**. No cell moved: the run simply stopped
     at the halfway mark of an `mbuf` that was always 256 wide, and the map's
     "at most 128" was describing the run rather than the buffer.
   - `sha512/hkdf`'s own temp that hands `info` back after the copy, **64 →
     192** cells, by inserting 128 at hkdf-relative 4016, with its four
     `info` copy runs grown to 192 tokens and their following walks corrected.

   190 is where it stops for a structural reason worth keeping: T is 64 bytes,
   the counter is one, and `hmac`'s `mbuf` is 256, so 64 + 190 + 1 = 255 is
   one short of it — which is exactly the slide count the counter placement
   already used.

   **The insertion is done by a transformer, not by hand.**
   `scratchpad/shiftcells.py` rewrites every distance that straddles a
   boundary and leaves every distance that does not, and it is proved by
   identity: run it with K = 0 and the file must come back byte for byte.

   **Two defects, and the second cost the afternoon.**

   The first is the transformer's: it left `@@PASTE@@ base` lines alone, and a
   paste base is an address like any other. It is silent at run time because
   the pasted *code* is base relative — only the `ASSERT` contracts
   `tools/bfexpand` rebases by it are wrong — so the vectors pass and the
   contract tier is the only thing that fails. The rule it now carries is a
   three way one, and the third case is the interesting one: if the boundary
   falls INSIDE the callee's footprint then the callee was itself shifted at
   `B - base`, its body already carries the extra cells, and its base must
   stay. `@@HASHCORE512@@ 520` inside `hmac` and `@@HMAC512@@ 784` inside
   `hkdf` are both that case, and the tool now says so on stderr.

   The second was not a defect in any tool. **Six `.bf` files were never
   regenerated after their skeletons were shifted**, so `hkdf`'s shifted code
   was pasted onto an unshifted `hmac`. Every measurement aimed at the
   transformer was aimed at the wrong artifact, and every distance it had
   rewritten was correct. See the trap under "Traps that have actually
   bitten".

4. **HMAC_DRBG, the SP 800-108 KDFs, PBKDF2.** Loops over an HMAC whose map is
   final by then. **The counter-mode KDF is built**; the rest of the step is
   not.

   `sha256/kdfctr` is SP 800-108r1 §4.1 over HMAC-SHA-256. It is the simplest
   shape in this whole list and worth saying why: the counter goes FIRST, so
   it lands at a fixed cell and **nothing has to be placed by sliding** — the
   thing that makes `hkdf`'s expand half hard is that its counter belongs
   after T and info, whose combined length is only known at run time. A turn
   here is: write the two lengths hmac spends, copy the key and the fixed
   input in (keeping a copy of each), step in, read the mac back reversed,
   hand the copies back, write out as much as is owed.

   **The counter width is fixed at 32 bits and that is a design decision, not
   a default.** SP 800-108 allows 8, 16, 24 or 32. A width chosen at run time
   would put the fixed input at a cell whose address the width decides, and
   this library has no index — it would have to be placed by sliding, which is
   exactly the cost the arrangement avoids. Same shape as the rate rule:
   *a counter width cannot be a parameter in brainfuck; a counter value can.*

   **THE COST, AND THE COMPARISON THAT NEARLY WENT IN WRONG.** A turn is
   **6,491,404,005** instructions, derived from two measured points — one turn
   at 6,511,669,225 and two at 13,003,073,230, each with its output checked
   against its vector in the same run. Against a bare HMAC-SHA-256 measured at
   5,149,095,299 that looks like **26% carriage**, and that number is
   meaningless: the 5.1 billion was measured with an EIGHT byte message and a
   turn here hashes SIXTY FOUR. Measured again at the same message length the
   bare HMAC is **6,465,441,658**, so the carriage is **25,962,347 — four
   tenths of one per cent**. Two buffer round trips and an emit loop cost
   almost nothing beside the hash they feed. The lesson is the one §9.1
   already states in capitals, in a new costume: *a cost comparison between
   two runs with different inputs is a number about nothing.*

   Worth keeping from the same pair: **HMAC-SHA-256 costs 26% more for a 64
   byte message than an 8 byte one**, which is a block boundary and not a
   surprise, but it means any future "X costs N times an HMAC" claim has to
   say which HMAC.

   **DONE as well: feedback mode**, SP 800-108r1 §4.2, as `sha256/kdffb`.
   This list said it would be "the same file with the previous K in the
   message, so a head change rather than a new routine", and that was wrong in
   the way this list is usually wrong — right about the algorithm, wrong about
   the code. The message gains a 32-byte K(i−1) prefix, `mplen` changes, and
   the mac has to land in **two** places rather than one, so a mode flag would
   have put branches around most of the body. It is its own file.

   What carried over unchanged is the thing that matters: **all three parts of
   the message have fixed lengths** — a 32-byte block, a 4-byte counter, then
   the fixed input — so all three land at cells the map names and nothing is
   placed by sliding. That is why feedback mode came in at 332 skeleton lines
   against counter mode's 324.

   **The IV is always present and always 32 bytes**, declared rather than
   defaulted. An empty IV is allowed by the standard and would make the FIRST
   turn structurally different from every later one, with the fixed input at
   offset 4 rather than 36 — the exact special case the arrangement exists to
   avoid. In ACVP terms that is `supportsEmptyIv: false`, a capability you
   decline, not a conformance failure.

   **A side result worth keeping.** `kdfFbRun_32_156_32` sits at the cap, so
   its PRF message is 192 bytes — and that is **the first thing in this tree
   to exercise `sha256/hmac` at its documented maximum**. It passes, which
   means the SHA-256 family's `mplen ≤ 192` is a real claim and not a
   transcribed one. The SHA-512 twin of that claim was false until the prefix
   slide was grown under step 3, and nothing would have caught it there either
   if no vector had ever gone near the limit. **Put a vector at every cap you
   write down.**

   **DONE as well: PBKDF2**, RFC 8018 §5.2, as `sha256/pbkdf2`, and it is the
   first of the three that is not cheap. The two SP 800-108 files were easy
   because their counters come first; RFC 8018 fixes the order the other way,
   so `U(1)`'s message is salt-then-counter and the four counter bytes belong
   at an address only known at run time. **So this one uses `hkdf`'s slide**,
   for `hkdf`'s reason. It is cheap here for a reason worth keeping: the slide
   happens once per OUTPUT BLOCK and the hash happens `c` times per block, so
   at any iteration count a caller would really choose it is not measurable.

   **One subtraction is an addition.** The iteration count comes down by one
   each turn, and a 32-bit borrow written out by hand would have been a fourth
   hand-rolled carry. `chacha20/add32` drops its final carry, so **adding
   0xffffffff is subtracting one** — two adder frames and no cascade.

   **THE DEFECT WORTH KEEPING, and the vector that earned its place.**
   `mplen` is written at the end of every iteration to set up the next one.
   On the LAST iteration there is no next one, so a 32 was left behind that no
   hash ever spent, and the next output block added `saltlen + 4` on top of
   it. Block 1 was right and block 2 hashed a 40-byte message instead of an
   8-byte one.

   **Neither published vector could see it.** `c=1` and `c=2` at 32 bytes out
   are single-block, and a single block never builds a second message. Only
   `pbkdf2Run_8_4_1_64` — two output blocks — reaches the state, and it is the
   one that failed. The cause was then confirmed by arithmetic rather than by
   a plausible story: `HMAC(P, salt ‖ INT(2) ‖ 32 noughts)` reproduces the
   wrong bytes exactly. The fix clears `mplen` at the head of each block.

   The general shape is worth naming, because nothing in the tier list looks
   for it: **a value written for the next pass of an inner loop outlives the
   loop, and the outer loop inherits it.** Any routine with a loop inside a
   loop can have it, and only a vector that runs the outer loop twice can see
   it.

   **The cost, measured.** c = 1 at 32 bytes out is **5,136,901,190** and
   c = 2 is **10,340,650,909**, each with its output checked against its
   vector in the same run, so **an iteration is 5,203,749,719**. RFC 6070's
   c = 4096 is therefore ~2.1 × 10¹³, which is days — the "days" in this
   file's earlier estimate is now a derivation from two measurements rather
   than a guess.

   **DONE, and step 4 is closed: HMAC_DRBG**, SP 800-90A §10.1.2, as
   `sha256/drbg`, in the profile with no reseed, no prediction resistance and
   no additional input.

   **Two pastes and not ten, and that is what shaped the file.** A paste of
   `sha256/hmac` is ~6.8 MB of committed brainfuck, and instantiate plus one
   128-byte generate is ten calls of it — 68 MB written out. So every call had
   to go inside a loop, and what makes that possible is that **every call is
   one of two kinds**: a *K step* (message `V ‖ tag ‖ [seed]`, answer replaces
   K) or a *V step* (message `V`, answer replaces V). Update is a K step and a
   V step, twice over when it has data; a generate is a run of V steps that
   are written out, then one more pair.

   **Instantiate is the zeroth generate.** Update over the seed and the Update
   that ends a generate are the *same* pair loop, so the instantiate runs as a
   pass of the generate loop that makes no output. That is what gets the pair
   loop to one copy; the alternative was two copies and therefore three
   pastes.

   **The pair loop needs no comparison anywhere.** It counts down from two, so
   after the loop's own decrement the counter is 1 on the K step and 0 on the
   V step, and a copy of it *is* the flag.

   **THE DEFECT, AND WHY IT IS THE SECOND OF ITS FAMILY.** All three vectors
   failed and no hypothesis about the algorithm fitted the wrong bytes, so the
   state was read out instead. That needed a new instrument: a dumper keyed on
   a **source line** rather than an instruction count, because `hmac` carries
   thousands of contracts of its own and a hit count cannot reach past the
   first call. The state at each hash said it plainly:

   ```
   pair hash 1   K 0000…0000   V 0101…0101      the correct start
   pair hash 2   K cec81077…   V 0101…0101      k1 exactly right
   pair hash 3   K 161ce7c6…   V 0101…0101      V never changed
   ```

   The V step had written its answer to K. The flag saying which step this is
   was copied from the half counter by a token that **adds**, and was never
   cleared, so the 1 the K step left standing made the V step look like
   another K step. One clearing token fixed it — and it also fixed a
   *contract* failure on a different vector, which had looked like a second,
   unrelated bug: the mis-flagged V step was building a 192-byte K-step
   message and leaving `hashcore`'s prefix buffer inconsistent. One cause, two
   symptoms.

   **This is the same family as `pbkdf2`'s leftover `mplen` one commit
   earlier: a cell written by accumulation rather than assignment keeps what
   was there.** There it survived a loop nesting; here it survived one turn of
   a single loop. In this library **a copy is always an add**, so the rule is
   the plain one — *clear the destination unless the adding is the point* —
   and it is worth more than either bug, because neither tier looks for it and
   both bugs were invisible to every static check the repository has.

   **PBKDF2 stays gated at c = 1 and c = 2**:
   at 6.5 billion instructions an iteration, RFC 6070's c = 4096 is 21
   trillion, which is days. The loop is the same code at any c, so the routine
   is provable and the count is not; that has to be said in its header rather
   than discovered by whoever runs the suite. HMAC_DRBG is about seven HMAC
   calls for instantiate plus one generate, so roughly 45 billion, or five
   minutes a vector — affordable but it will be the slowest thing in the
   suite.

5. **cSHAKE, KMAC, TupleHash and ParallelHash** — SP 800-185. Last of the
   known work, because it is the largest and the only one with a design
   question in it, so it gets the slot where a surprise costs least.

   **It is not "the same sponge with a different padding byte", which is what
   this document said before anyone looked.** cSHAKE is
   `KECCAK[rate](bytepad(encode_string(N) ‖ encode_string(S), rate) ‖ X ‖ 00, L)`:
   the message is a PREFIX ON THE TAPE followed by X on the wire, and
   `sponge136` absorbs only from the wire. KMAC adds a tape SUFFIX,
   `right_encode(L)`, after the wire message.

   The saving grace is that **`bytepad` pads to a multiple of the rate by
   definition**, so a prefix is always a whole number of blocks and the sponge
   never has to interleave tape and wire inside one block. It absorbs k whole
   blocks from the tape and then enters the existing loop unchanged — a new
   entry point rather than a rewrite. Four units: the encodings
   (`left_encode`, `right_encode`, `encode_string`, `bytepad`), tape-prefix
   absorption, then cSHAKE, then KMAC and the two hashes.

6. **AES itself, if and only if step 1 says so.**

**DELIBERATELY DEFERRED, AND NOT FORGOTTEN:** tier 6 (item 6 below), a lane
for BoneMesh's three `bf/` checks, a scheduled pin bump, brainstem's
`tools/bfj.c`, and two documentation contradictions — `CONVENTIONS.md` §9's
"`v1.0.0` waits on it" against this file, both now superseded by the owner's
own answer recorded under item 1. They are cleanup, they are agreed to come
after step 6, and the two coverage gaps among them are the honest priorities
of that batch rather than the doc fixes.

**THAT QUESTION IS ANSWERED, AND THE ANSWER IS NO.** It used to read "does
BoneMesh use cSHAKE or KMAC anywhere?", with the ordering above assuming not.
BoneMesh's own source names neither, nor TupleHash nor ParallelHash: every
match in that tree is inside a `vendor/` directory, which is a third-party
crate carrying its own SP 800-185 code and not a caller. **Step 5 stays where
it is.**

Worth recording from the same sweep, and worth being careful how.
BoneMesh names `chacha20` and `poly1305` most, then `sha256`, `ed25519`,
`hkdf`, `x25519`, `sha512`, `hmac`, `ml-kem`, and — already — `shake256`,
`shake128` and `sha3_256`. Everything on that list is built here except
ML-KEM and the two curves, which is step 12.

**That tells you when a tenant is unblocked. It does not tell you what this
library is for**, and the distinction is the reason this paragraph is worded
twice. CONVENTIONS §9.1 already settles it: *the ambition is every
NIST-approved algorithm*. **BoneMesh is a tenant, not the specification.** So
a sweep like this may reorder work that was going to happen anyway, and it may
never be the reason something is or is not built; the deferred cleanup batch
does not become less important because no tenant is waiting on it, and
SP 800-185 does not become optional because this one is not.

The §9 reference to the BoneMesh corpus is consistent with that and should not
be read against it: that corpus is a **conformance target**, a way of showing
the symmetric set is sufficient rather than merely complete. Being tested by a
consumer is not the same as being scoped by one.

A caveat on the method, so nobody over-reads it either way: this is a grep of
identifier and comment text, so it says what BoneMesh MENTIONS, not what its
wire format requires. It is good enough to close a question about ordering and
not good enough to plan step 12 from.

0. **The 64-bit set and SHA-512 are done.** `idiom/add64`, `rotr64`, `shr64`,
   `xor64` and `and64` are built and gated, and on them SHA-512, HMAC-SHA-512
   and HKDF-SHA-512. That is the whole of CONVENTIONS §9.1 tier A's SHA-512
   line and the HMAC and HKDF rows over it; SHA-384 and both SHA-512/t are the
   same core with a different IV and a truncation, and HMAC_DRBG, the SP 800-108
   KDFs and PBKDF2 are loops over an HMAC that now exists at both widths.

   Two things to know before touching them:

   - **HKDF-SHA-512's info is capped at 190 bytes**, raised from 63, and the
     cap is arithmetic rather than arbitrary: the expand message is
     T(64) ‖ info ‖ counter(1) and `sha512/hmac`'s `mbuf` is 256, so
     64 + 190 + 1 = 255 is one short of it. A TLS 1.3 `HkdfLabel` with a
     48-byte context now fits with room to spare. `sha256/hkdf` has the same
     limit by the same arithmetic at 192, its T being half the size, and it
     did not need raising.
   - **An eight byte move may not be written the way sha256/* writes a four
     byte one.** Fifteen consecutive code lines with no annotation is what it
     comes to, and `bfstyle` rule 4 refuses thirteen. The step to the next byte
     goes on the same line as the move it follows; that is also what keeps
     `sha512/round.skel` under the size budget.

   **Keccak is being built and CONVENTIONS §9.1 tier B says why** it is the
   keystone: it unlocks SHA3-224/256/384/512, SHAKE128/256, cSHAKE, KMAC,
   TupleHash and ParallelHash, and the post-quantum tier behind it. θ and χ are
   exclusive or and and over 64-bit lanes, a NOT is an exclusive or with all
   ones, and ρ is nothing but 64-bit rotations — so it is a 5×5 lane state,
   twenty four rounds and the sponge.

   **THE PERMUTATION IS IN.** `keccak/theta`, `keccak/rhopi`,
   `keccak/rhopichi` and `keccak/permute1600`. Each was checked against a
   reference Keccak that agrees with a third party's SHA3-256 and SHAKE128,
   and then against Cryptol, so every step has three independent witnesses
   rather than two. A round is θ then ρπχ, both **in place on cells 0 to 199**,
   and `permute1600` computes the published permutation of the all-zero state,
   `e7dde140798f25f18a47c033f9ccd584...`, in **2,483,822,414 instructions** —
   about four seconds, a fifth of the AEAD, twice SHA-256 of one block. It was
   3,939,144,956 when it was first built and the Cost section below is where
   the difference went.

   **WHY ρπ AND χ ARE ONE FILE**, since the rest of this library splits as far
   as it can: χ's input is the array π writes, which lives high on the tape, so
   a χ of its own would have to read two hundred bytes into cells three hundred
   upward. A read prologue may contain nothing but commas and steps, and
   `bffoot` refuses a routine whose prologue is preceded by any other command
   byte — because a paste begins at the prologue and would silently drop what
   came before it. Joining the two removes the question and, more usefully,
   makes the round in place: two pastes at the same base, nothing carried
   between them.

   `keccak/rhopi` is still a routine of its own — it reads at nought and has no
   such problem — and **`rhopichi` PASTES it rather than carrying a copy**,
   which matters and was nearly got wrong: the first version of `rhopichi` was
   built by concatenating the two skeletons' text, which put ρπ's twenty five
   journeys in two files that nothing would keep in step. A composite contains
   its parts by paste (§5), and tier 9c only proves a `.bf` matches its own
   skeleton, so a copied body is a divergence no tier would catch. χ alone is
   covered by `rhopichi`'s vectors and by having been checked on its own
   against the reference before the two were joined.

   **ι is inline in `permute1600` rather than a routine**, because it is one
   exclusive or of lane nought and because the constant it wants comes from
   that file's own table. And the table was far cheaper to write than
   `sha512/hashcore`'s K: a Keccak round constant has bits only at positions
   one less than a power of two, so only bytes 0, 1, 3 and 7 of a lane are
   ever anything but nought and most of those are 128 — twenty four blocks of
   at most four numbers, each read straight out of Appendix A. There is no
   index, so the constant in hand is always the lowest eight cells of the
   table and the rest slides down when it is spent.

   **AND THE SPONGE IS IN, AS SHA3-256 AND SHAKE256.** `keccak/sponge136`
   absorbs at rate 136 — which is exactly seventeen lanes, so a block is
   seventeen entries of `xor64` rather than a hundred and thirty six byte
   exclusive ors — pads by FIPS 202's rule, and squeezes as many bytes as it is
   asked for. `keccak/sha3_256` and `keccak/shake256` are two heads over it,
   each about fifty five skeleton lines, that hand it a padding byte and a
   length. SHA3-256 agrees with a third party on ten lengths across three block
   boundaries and with Cryptol on the four the suite keeps; SHAKE256 agrees with
   a third party on a sweep of eight message lengths against eight output
   lengths, and with Cryptol on the five the suite keeps. A block is about four
   billion instructions, essentially all of it the permutation: the conveyor
   that fills the block costs about five million, the absorb twenty five, and
   one whole turn of the state to squeeze a rate thirty six — together about
   one percent.

   **THE RATE CANNOT BE A PARAMETER AND THE PADDING BYTE CAN**, and that is the
   whole reason `sponge136` exists as a file of its own rather than SHAKE256
   being a second copy of SHA3-256. A rate sets how many lanes the absorb
   touches and how far every one of its twenty one journeys runs; a journey of a
   computed length needs an index, and there is none. A padding byte is one cell
   of data, so it comes in on the wire and the head writes it. **So the shape of
   this family is one sponge per rate and one head per function**: rate 136
   carries SHA3-256 and SHAKE256 today and cSHAKE256 and KMAC256 later, all of
   them the same `.bf` handed 6, 31 or 4.

   **AND THE PROOF THAT THE PARAMETER IS REAL IS TWO VECTORS ON ONE FILE.**
   `keccak/sponge136.bf` handed a 6 answers `a7ffc6f8…`, which is SHA3-256 of
   nothing, and handed a 31 answers `46b9dd2b…`, which is SHAKE256 of nothing.
   One program, two standard functions, no branch between them.

   **SHA3-256 WAS RELAID ONTO THE SPONGE RATHER THAN LEFT ALONE**, and its four
   existing vectors passing unchanged is what proves the relay. The alternative
   was writing SHAKE256 as a copy of it, which would have put the block loop,
   the conveyor, the padding rule and seventeen hand-derived lane journeys in
   two files that nothing would keep in step — the same divergence `rhopichi`
   nearly shipped, and one no tier can see, because tier 9c only proves a
   `.bf` matches its own skeleton. **It cost 0.87 per cent**: SHA3-256 of
   `abc` was 4,265,326,951 instructions and is now 4,302,466,302, the
   difference being one full turn of the state that a fixed thirty two byte
   emit did not need.

   **THE SQUEEZE NEEDS NO INDEX EITHER, AND THAT IS `keccak/rotstate`.** The
   byte about to go out is always the BOTTOM cell of the state, and the state
   turns over one cell at a time to bring the next one down. Two hundred turns
   put it back exactly as the permutation left it, so a rate is squeezed by
   turning the state over all two hundred of its cells and sending a byte out on
   as many of the first hundred and thirty six as are still owed. A turn is about
   a hundred and eighty thousand instructions on average bytes and three hundred
   and sixty thousand on a state of all ones; two hundred of them is thirty six
   million, which is why the conveyor is the cheap half of a squeeze and the
   permutation is the dear one. **And the stir comes after a rate rather than
   before it**, under a test of whether anything is still owed, so a caller who
   asks for a rate or less pays for no permutation beyond the absorb's.

   **ONE DEFECT WORTH THE SPACE, because no single-block vector can see it.**
   The first version added the padding's top bit to the last byte of EVERY
   block instead of the last byte of the LAST block. Everything up to 135 bytes
   passed — with one block, the only block *is* the last one — and everything
   from 136 failed. The block in which the padding byte was placed is the last
   block by definition, so placing it now sets a flag and the bit is added
   under that flag. **A vector at a multiple of the rate is not optional for
   any sponge.**

   **AND SHAKE128 IS IN, AS `keccak/sponge168` AND `keccak/shake128`.** Rate
   168 is twenty one lanes, so it is a sponge file of its own, and the map is
   `sponge136`'s shifted by exactly 32 above the block — which is not a
   coincidence but the thing that made the file cheap. The block starts at cell
   824 in both, so it ENDS 32 cells higher at rate 168, and the flag cluster
   was put 32 cells higher to match. **Every walk between the TOP of the block
   and a flag cell therefore has the same distance in both files**: `R57`,
   `L57`, `R49`, `L61`, `R61` and the `L64` that carries the padding byte are
   all unchanged. Only two walks touch the BOTTOM of the block and had to
   move, plus the twenty one lane journeys, the slide, the count and the
   asserts. The five formulas the lane journeys come from were checked by
   generating `sponge136`'s seventeen from them and diffing against the
   committed skeleton: 222 lines, no differences. That is why `sponge168`
   answered `7f9c2ba4…` the first time it was run.

   **A RATE OF 168 IS THE CHEAPER SPONGE PER BYTE**, and it is worth knowing
   before anyone reaches for SHAKE256 by default: a permutation costs what it
   costs regardless of the rate, so SHAKE128 absorbs 168 bytes and squeezes
   168 bytes per permutation where SHAKE256 does 136. About a quarter cheaper
   per byte, for no reason but the number. **And SHAKE128 is the one ML-KEM
   actually calls**, since its matrix sampling is a SHAKE128 squeeze of a few
   hundred bytes per entry.

   **AND SHA3-224, SHA3-384 AND SHA3-512 CLOSE THE FAMILY** — rates 144, 104
   and 72, so eighteen, thirteen and nine lanes. Each is ONE FILE rather than
   a sponge and a head, and the rule that decides which is the one already
   stated: a rate gets a sponge of its own, and a rate shared by more than one
   function gets heads over it as well. Rate 136 carries SHA3-256 and SHAKE256
   (and cSHAKE256 and KMAC256 later) so it has a sponge and heads; rate 168
   carries SHAKE128 and the same pair at 128, so it has one too. **These three
   rates have exactly one function each in the whole of FIPS 202**, so the
   sponge and the head are the same file and both constants are written into
   it.

   **And none of them has a squeeze loop**, because 28, 48 and 64 bytes are
   each under their own rate: the digest is the front of the state and is
   emitted where it lies. `sponge136` pays one whole turn of the state to
   serve a length it does not know in advance; these do not have to. That is
   the same 0.87 per cent SHA3-256 pays for sharing, looked at from the other
   side.

   All three were right the first time they were run, which is worth
   attributing rather than enjoying: `scratchpad/sha3gen.py` emits the body
   from a rate and a digest length, and it was first run at rate 136 with a
   digest of 32 and diffed against the SHA3-256 that had been hand-written
   before the sponge was split out — identical, 435 lines. Only then were the
   other three rates asked for. Twenty one lengths against a third party
   across every block boundary, no failures.

   **THIS ITEM USED TO SAY "IT NEEDS NO NEW IDIOM" AND THAT WAS WRONG**, which
   is worth keeping rather than quietly fixing, because the way it was wrong is
   the project's own recurring lesson. ρ's rotations are to the LEFT and by up
   to 62, and `idiom/rotr64` rotates right, so a left rotation by `r` is a
   right rotation by `64-r` — sixty three single-bit steps in the worst case,
   at about sixty thousand instructions each. The twenty five offsets FIPS 202
   gives ρ cost **58.5 million a round, 1.40 billion per permutation**, on the
   rotations alone. That is more than the whole AEAD and it would have made the
   tier look closed.

   **`idiom/rotl64` is the new idiom, and it never shifts left.** A rotation by
   `8q+s` is a rotation by `8(q+1)` — whole BYTES, which is just which cell a
   byte is copied into — followed by a right rotation of `8-s` bits, which is
   one pasted `rotr64`. Nothing doubles, so the adder is never entered. The
   same twenty five offsets cost **9.5 million a round, 229 million per
   permutation, 6.1× less**, which puts a whole Keccak permutation on the order
   of a billion instructions: the same order as SHA-256 of ONE block, and about
   a tenth of the AEAD. Affordable.

   One measured improvement is left in it and is deliberately not taken: when
   `s` is nought the answer needs no bit rotation at all, and the uniform
   formula spends eight steps where nought would do. That is `n` = 0, 8 and 56
   among ρ's offsets, 1.80 million of the 9.5, so about 4% of a permutation for
   the cost of a branch and an else arm. Written down rather than built.

1. **Done, and struck: the corpus check was never this repository's to write.**
   v1's set is in — CONVENTIONS §9 lists ChaCha20, Poly1305, the AEAD, SHA-256
   and HKDF-SHA-256 — and the BoneMesh corpus has been checked against it.
   It was checked in **BoneMesh**, by `bf/keyschedule.poke`, which holds the
   transcript hash and the chaining key on its own tape and spawns an
   interpreter on the right routine for each of the nine steps. Its own header
   makes the claim this item was reaching for: *no shell in the middle*.

   **THE ITEM WAS WRONG ABOUT OWNERSHIP AND CONTRADICTED ITS OWN TABLE**, which
   is why it is struck rather than quietly edited. The ownership table further
   down says BoneMesh owns the conformance vectors, *beside five other
   implementations* — and then this item asked bfsodium to write the fixture
   anyway. A corpus is a compatibility artifact belonging to the protocol that
   froze it; P2 is for algorithmic implementations, and a `keyschedule.json`
   is not an algorithm. The reasoning below is kept because the DIRECTION it
   argues — infrastructure must not know its consumers — is right and was only
   applied one repository short: brainstem must not know bfsodium, and equally
   bfsodium must not know BMX.

   **v1.0.0 no longer waits on THIS.** It waited on the composition story
   being run end to end, and it has been. When that join was finally run
   against a CURRENT bfsodium rather than a pinned one it turned out to be
   broken — BoneMesh resolved `hkdf.bf` by basename, and this repository had
   grown a `sha512` family with five colliding basenames, so the consumer had
   been handed HKDF-SHA-512 while its own transcript said SHA256. That was
   BoneMesh's to fix and BoneMesh has fixed it, by naming routines the way
   this repository names them. Worth knowing here for one reason only: **a
   directory name in this tree is part of the interface**, and adding a family
   whose basenames repeat an existing one is a change a consumer can feel.

   What the tag waits on now is the owner's call and not a technical one:
   **P3 and the post-quantum tier**. It is not held by anything here.

   What the machinery below bought is still real, and still lives here,
   because a runner that drives any routine by name is a general capability
   rather than a BMX one:

   - `programs/sha256.poke` reads the broker's stdin, buffers the message on
     the TAPE as flag/byte pairs, counts it in two cells, and spawns an
     interpreter on `sha256/sha256.bf` through the broker. It hashed a 27,430
     byte JPEG against `sha256sum` in 764 seconds. There is no `open` and no
     `stat` in it: the temporary file those were for is gone, and with it the
     writable working directory it needed.
   - `programs/run.poke` is the generic form — it takes a routine's NAME at
     run time, relays stdin into it and its answer back out, and therefore
     drives every routine in the tree including ones not yet written. The
     caller does the framing, so it has no length prefix to overflow and no
     size limit. `tools/bfrun.sh` writes the one byte of name length.
   - Tier 12 runs three routines with nothing in common through the runner,
     because one would show that it works and three show it is not secretly
     about SHA-256.

   So the harness is here, gated on both guests, and general: `run.poke` drives
   a routine named at run time, which is a capability rather than a fixture.
   The nine-call corpus fixture built on that kind of harness lives in
   BoneMesh, where its vectors do.

   The original reasoning, kept because it is why the directory exists: what
   was unproven was the SEQUENCING rather than any one call. bfsodium gates
   every routine against Cryptol and the RFCs, brainstem gates the broker
   across two kernels, and **nothing tested the seam between them** — that a
   brainfuck program can take one primitive's OUTPUT and make it the next
   primitive's INPUT, with no shell in the middle. That was the capability the
   whole three-phase scheme was designed around and the one nobody had shown.
   It has been shown; see `bonemesh/bf/keyschedule.poke`.

   It mattered to this repository in particular, because a library's claim is
   not "each routine is correct" — it is "these compose". Composition here is
   source-level pasting through `bfexpand`. Composition at RUNTIME, one
   program driving several, is a different claim, and the thing worth keeping
   in mind is that **it is now proved by a consumer rather than by us**. That
   is the correct direction and also a standing risk: if BoneMesh ever drops
   that fixture, this library loses its only runtime composition evidence and
   would need its own. `programs/` and tier 12 are what make that cheap to
   rebuild.

   The tagging argument that used to sit here — *tagging a library whose
   composition story has never been run end to end would be tagging on faith*
   — is answered rather than abandoned. The story has been run; it was run one
   repository over.

   **And the cost is affordable, which was not obvious and is now measured.**
   `sha256` is about **1.15 billion instructions, roughly two seconds** under
   `bfi` — 1.7 times `blockloop` and a tenth of the AEAD's 11.58 billion.
   A program that hashes, takes the digest and hashes again costs about four
   seconds, which a gate can carry without argument. See *Cost* below.

   **WHERE IT LIVES IS SETTLED: a `programs/` directory here.** The earlier
   note called it an open question and offered brainstem as the answer. That
   was wrong, symmetrically: it avoided contradicting this repository's
   boundary by contradicting brainstem's. brainstem is a general broker whose
   README says the indirection through an external interpreter is what makes
   it indifferent to what is on the far end, and vendoring a crypto routine
   into its fixtures would make its corpus domain-specific for the first time.
   There will be other brainfuck libraries that want chaining and have nothing
   to do with cryptography.

   **The principle is dependency direction.** Infrastructure must not know its
   consumers; a consumer knowing its infrastructure is ordinary. brainstem
   knowing about bfsodium is backwards. bfsodium knowing about brainstem is
   a library using a broker, which is what the broker is for.

   ### routines and programs

   | | a routine | a program |
   |---|---|---|
   | what it does | computes | does something, which needs the world |
   | I/O | plain stdin to stdout, one operation | sequences several, through a broker |
   | oracle | Cryptol, and a KAT | a KAT, end to end |
   | lives in | `chacha20/`, `poly1305/`, `sha256/`, `aead/`, `idiom/`, `index/` | `programs/` |

   **THE LINE IS DRAWN BY CRYPTOL AND THAT IS NOT A WEAKNESS, IT IS THE
   DEFINITION.** Can this thing be specified in Cryptol? Then it is a routine.
   Can it not? Then it is a program. Cryptol describes functions, and a
   sequence of I/O is not a function, so the question separates the two kinds
   exactly and without anyone exercising judgment.

   Read it as *in principle*, not *in practice*. A pure routine nobody has
   written a spec for yet is still a routine; otherwise the criterion would
   reclassify things as the tree's Cryptol coverage changed, which is the
   opposite of a definition.

   **The rulebook line is amended, not deleted.** CONVENTIONS says bfsodium is
   pure computation with plain stdin/stdout, no syscalls and no P1 broker.
   What that protects is the ROUTINES: purity is what makes them checkable
   against Cryptol, runnable under any conforming interpreter, and usable as
   KAT targets. It was never a claim about what else may live in the tree.

   **And the fence enforces itself**, which is the part worth keeping. A
   routine that emitted protocol frames would fail its own KAT, because a KAT
   compares stdout and frames are extra bytes on stdout. No new lint is
   needed. What is needed is only that the existing tiers keep pointing at the
   routine directories and not at `programs/`.

   Everything else still applies to a program, and this matters: **a program
   is still standard brainfuck.** It does not stop being brainfuck by speaking
   a protocol -- that is the whole thesis of brainstem -- so `bflint`,
   `bfstyle` and the provenance tier cover it exactly as they cover a routine.

   ### what that leaves each repository owning

   | | owns |
   |---|---|
   | bfsodium `programs/` | the composition, because composing is this library's own claim |
   | BoneMesh `interop/check-keyschedule-bf.sh` | the conformance vectors, beside five other implementations |
   | brainstem | neither; it stays a general broker |

   Each repository tests its own claim. brainstem's is that a program can
   drive a program, already proved by `bf/proc/drive.poke`. This one's is that
   its primitives compose. BoneMesh's is that an implementation agrees with
   the corpus.

   **The cost of it**, stated because it is not free: the gate will need a
   broker present to run a `programs/` tier. `tools/guest-setup.sh` now pins
   one by commit -- see `BRAINSTEM_COMMIT` there, and the note beside it about
   what the pin turning into a TAG will mean.

2. **Done, and struck: the fold no longer enters the seventeen byte adder.**
   This item asked for a *second* fold, specialised to the value a doubling
   leaves behind, with its own vectors and its own Cryptol entry. It was not
   needed. The profile said the cost was `fold136` entering `add136`, and
   `add136` is seventeen entries of `add8` — and `add8` costs about fourteen
   thousand instructions *whatever its addend is*, because nearly all of it is
   the seven halvings that find bit 7 of the **accumulator**. Fifteen of those
   seventeen entries were spending fourteen thousand instructions to add
   **nothing**: five times H is at most 315, which is two bytes.

   So `fold136` now adds its two bytes with two entries of `add8` and lets the
   carry out of the second one ripple, and a ripple through a byte that is not
   255 costs one instruction. Same function, same vectors, same Cryptol entry,
   **no new file at all** — and it is faster for every caller rather than only
   after a doubling. `mulmod136` went from 145,361,714 to 89,473,525.

   **The lesson for the list itself:** the item named the *caller* as the thing
   to specialise when the cost was in a *callee* being entered with an empty
   operand. The measurement that settled it took one line profile. Read the
   profile before believing the item, including the ones written here.

3. **Done, and struck: ROTL32 no longer rotates left.** This item was right
   that the rotation was the cost and wrong about the fix. Pasting `rotr32`
   with the complementary counts would have been four constants and one paste
   name, and worth 2.25×. Rebuilding ROTL32 on the same identity `idiom/rotl64`
   uses — whole BYTE turns, which are only moves, then one right rotation of
   fewer than eight bits — was worth **22×** and left `qrloop` untouched,
   because the interface did not move.

   **And it earns the branch `rotl64` declines.** `rotl64` spends eight bit
   steps where nought would do when `s = 0`, and records that as 4% not worth
   an else arm. ChaCha's counts are 16, 12, 8 and 7 and *two* of them have
   `s = 0`, so the same branch saves sixteen of twenty-one bit steps here. The
   same idiom, the opposite call, and the difference is entirely in who is
   calling it.

4. **PQC is not next, and it is not out of scope for ever.** The long-term
   target is the NIST-recommended set, which since FIPS 203 and 204 includes
   ML-KEM and ML-DSA. Keccak and NTT are a later mountain rather than a closed
   door, and this item used to say "explicitly out of scope", which was
   stronger than intended.
   Worth restating precisely, because the BoneMesh corpus in item 1 invites
   the wrong inference: those vectors need **no** post-quantum anything, since
   `ss_dh` and `ss_kem` arrive as inputs and the suite name in the protocol
   string is only a label absorbed into the transcript hash. Passing them
   proves the symmetric set is sufficient for BoneMesh's symmetric half. A
   BoneMesh *node* needs six primitive roles and bfsodium has two — the other
   four are ML-DSA-65, ML-DSA-87, ML-KEM-768 with X25519, and an RFC 8785 JCS
   canonicaliser, which is not even cryptography.

5. **Done, and struck.** `CONVENTIONS.md` has been rewritten to describe the
   project as built, `IDIOMS.md` is folded into its section 5 so the
   vocabulary and the list of it can no longer disagree, and the gap this
   item was reduced to — *nothing checks that the tier table still matches
   `tests/run.sh`* — is closed: `tools/bftier.pl` exists, has a self test, and
   runs in the suite beside `bftable.pl`.

   It is left here rather than deleted because of HOW it was found. The tool
   landed in the same commit that wrote this paragraph asking for it, and the
   paragraph stood for six commits afterwards describing a hole that was
   already filled. Nobody reads their own "what is next" list after writing
   it, which is the argument for the two tables above being checked by a tool
   and not by a reader: eighteen of thirty rows were wrong in the one table
   nobody was checking, and this list is a table nobody is checking either.

6. **Tier 6, differential fuzz, is still declared and still absent.** It is
   affordable for the cheap primitives — `add32`, `xor32`, `rotl32`, `add136`,
   `halve136`, `dbl136`, `fold136`, `clamp` — and not for the composites, where
   the cheapest AEAD input already costs two ChaCha blocks. Building it for the
   cheap half is real work that nobody has done; do not let its absence pass as
   coverage.

## Running the suite

There are three lanes and they are not equals. **`reaper test` is the gate of
record**; a change is not judged until it has been green there. The other two
run the same `tests/run.sh` with nothing skipped, and neither is a second
opinion about whether a change may land.

    reaper up && reaper test        # the gate
    sh tools/container-test.sh      # the fallback, for a host that cannot reach the site
    .github/workflows/suite.yml     # CI, on every pull request

The CI lane is the newest and the weakest claim of the three, not because it
runs less — it runs exactly the same suite in `ubuntu:26.04`, the same image
the Containerfile pins and the same userland reaper provisions — but because a
green tick on a pull request is the easiest thing in the world to mistake for
a verdict. The job prints what it did and did not prove as its last step, for
that reason.

**All three run `tools/guest-setup.sh` and none of them installs anything of
its own.** That is one rule with one check behind it: the suite reads every
lane definition, strips its comments, and fails if any of them carries an
`apt-get` or a Cryptol version, or stops calling `guest-setup.sh`. The check
used to look only at the `Containerfile`; adding a third lane without widening
it would have left a file that could quietly define a second toolchain, which
is the precise failure the check exists to prevent.

**A cold guest costs a provisioning round.** Whenever the guest has been torn
down, the first `reaper test` after `reaper up` re-runs `guest-setup.sh` in
full: an apt transaction and a pinned Cryptol tarball fetched from GitHub.
Budget for that. There is no useful partial gate before it finishes, because
tiers 4 and 8 are both Cryptol and the suite refuses to degrade to a single
oracle.

This paragraph used to assert the guest *was* torn down, as a standing fact.
That is the wrong kind of thing for a document to claim: it is true or false by
the minute, nothing checks it, and it was false for some time before anyone
noticed. Guest state belongs to `reaper list`, not here.

Both lanes run `tools/guest-setup.sh`, and that is the only definition of the
toolchain anywhere in this repository. reaper calls it with no argument;
`Containerfile` calls it with `--toolchain` so the slow half becomes a cached
image layer, and `container-test.sh` calls it with `--build` against the tree
under test. If the Containerfile ever grows its own `apt-get` line or its own
Cryptol version there are two definitions, and the fallback begins passing what
the gate would fail — silently, since a container with a different z3 still runs
every test and still says PASS. `tests/run.sh` checks for that.

The container lane mounts the tree read only and copies it to scratch inside the
container. Host-built binaries are deleted from the copy before `--build` runs,
for the reason `.reaper.toml` gives for excluding them from its sync: a
FreeBSD-built `bfi` looks present to the rebuild and then fails to exec. It also
means nothing can leave a Linux ELF binary in a checkout you are editing from
Windows.

`.gitattributes` refuses line-ending conversion repo-wide. That is not
housekeeping: a CRLF checkout breaks all thirty of the byte-for-byte
`bfexpand` comparisons at once while leaving `bflint` green, because `\r` is not
a brainfuck command byte.

## Where the rules live

Six sections used to sit here restating `CONVENTIONS.md` in a narrative voice:
the build model, the calling convention, contracts, conveyors, the checkers and
the size budget. That split was by REGISTER rather than by subject, so every
subject had two homes, and two homes is the whole mechanism by which a fact
drifts. They are gone; the rules are in one place and this document holds only
what changes.

| if you want | read |
|---|---|
| how a file is written, skeleton to committed brainfuck | CONVENTIONS section 6 |
| the calling convention, INTERFACE, paste bases, ASSERT authoring | section 4 |
| the idiom vocabulary and each tape contract | section 5 |
| conveyors, and why indexed addressing is avoided | section 5 |
| what each checker is for | section 8 |
| the size budget and why it counts the skeleton | section 8 tier 9b |
| which tiers are required, and the defect that bought each | section 8 |

What stayed here is the fast-moving half: state, the two machine-checked
tables, measurements, and the things that have gone wrong.

## Cost, and where it goes

Everything expensive in this library is the byte adder, and there are now two
of them.

**Measured whole-primitive costs**, for choosing what a gate can carry. These
are `BFI_COUNT=1` under the pinned interpreter, and each was taken from a run
whose output was checked against its KAT in the same command — see the trap
about that below.

| primitive | instructions | 0 |
| --- | --- | 0 |
| `sha256` of the empty message | 1,145,948,360 | ~2 s |
| `sha256` of "abc" | 1,180,129,364 | ~2 s |

The AEAD's 11.58 billion is in the migration table below and has no wall time
here on purpose: it was never timed, and dividing one number by another is a
derivation wearing a measurement's clothes.

SHA-256 was absent from every table here until M7 of the sibling project
needed it, and the guess everybody would have made — that it is expensive,
since its routine is 7509 lines — is wrong by an order of magnitude in the
comfortable direction. It is a tenth of the AEAD and 1.7 times `blockloop`.

The **old kernel** detects the carry by testing whether the accumulator has
just wrapped, once per unit of the addend, and that test costs a copy of the
accumulator. So its cost is the **product** of the two bytes: about three
quarters of a million instructions at 255 plus 255. It is still the right
choice when one operand is 0 or 1, where the product is tiny, and that is
exactly where it is kept — adding a carry in.

**`idiom/add8`** does not watch for the carry at all. It computes it once, as
bit 7 of `(x>>1) + (y>>1) + (both low bits set)`, and rebuilds the sum from the
same two halves. Its cost does not depend on the operands: about 20 thousand
instructions, nearly all of it the seven halvings that extract bit 7. So it is
far faster than the old kernel for the operands that actually occur and far
slower for very small ones.

**Measure before you assume where the adder hurts.** ADD8 is the bottleneck,
but not where it looks. `add32` costs only about 230 thousand instructions, and
migrating it moved `blockloop` from 5.9 to 5.5 billion — nothing. The real cost
was `rotl32`, at 20 million a call, because one bit of rotation DOUBLEs four
bytes and DOUBLE is `ADD8(x, x)`. Migrating that took `blockloop` to 686
million. Same kernel, a caller nobody had counted.

| | before | after | |
| ---|--- | --- | 0 |
| `ADD8` at 255 plus 255 | 750,977 | 40,796 | 18× |
| `add32` max plus max | 3,070,694 | 229,973 | 13× |
| `rotl32` by 16 | 19,981,909 | 1,433,049 | 14× |
| **`blockloop`** | ≈5.9 billion (18 s) | 686 million (1.4 s) | **9×** |
| `add136` worst case | 12,695,192 | 1,352,910 | 9.4× |
| `fold136` max | 1,193,069 | 817,802 | 1.5× |
| `reducep136` max | 1,232,781 | 860,034 | 1.4× |
| `mulmod136` large | 1,155,893,395 | 987,082,567 | 1.2× |
| AEAD, RFC §2.8.2 | 13.12 billion | 11.58 billion | 1.13× |

**And now the same lesson a second time, in the other direction.** Migrating
`add136` bought 9.4× on the adder itself and only **1.13×** on the AEAD, across
four files that had to be re-laid. Poly1305's cost is not the adder: it is
`mulmod136`'s 136 turns, each paying two `fold136` calls, a `dbl136` and a
17-byte carry of the operands to and from the work frame.

So do not reach for the adder again here. The next real win for Poly1305 is a
**better multiply** — fewer than 136 turns, or a reduction that does not fold
twice a turn — not a faster byte add. Measure it before building it; that
advice has now been earned twice.

**And measured, this is where `mulmod136`'s 996 million actually went.** With a
step counter per source line and the paste sites marked, on the large vector:

| | instructions | share |
| --- | --- | 0 |
| `mulmod136`'s own glue | 527,025,347 | 52.9% |
| `fold136` after the double, 136 calls | 269,024,405 | 27.0% |
| `fold136` after the add, 68 calls | 118,046,136 | 11.9% |
| `add136` | 37,217,271 | 0 |
| `dbl136` | 32,051,014 | 0 |
| `halve136` | 7,672,872 | 0 |
| `reducep136` | 3,104,969 | 0 |

Two things in that table were not what anyone had written down. **The glue is
the biggest line** — the 17-byte carries in and out of the work frame, and
shifting `b` down one bit, cost more than every kernel put together, because a
move `[-R220+L220]` costs about 2×220 instructions PER UNIT of the byte's
value. And **818 thousand was never `fold136`'s worst case**: that vector is
all `0xff`, whose first add wraps the accumulator down to small bytes and makes
the remaining four adds cheap. On mid-range bytes the old file cost 2.14
million.

**What was done about the folds, and what it bought.** `fold136` spent FIVE
whole 17-byte adds to place a number that never exceeds two bytes — five times
63 is 315. It now builds `4H` and `H` side by side, adds those two bytes with
`add8`, and enters `add136` ONCE with the sum as the addend's low byte and the
carry as its high byte. `4H` cannot wrap, because four times 63 is 252, so the
one carry `add8` computes is the only carry in the file.

| | before | after | |
| ---|--- | --- | 0 |
| `fold136` on mid-range bytes | 2,143,729 | 449,517 | 4.8× |
| `fold136` all `0xff` | 817,802 | 635,880 | 1.3× |
| `reducep136` max | 860,034 | 678,112 | 1.3× |
| **`mulmod136` large** | 987,082,567 | 675,977,009 | **1.46×** |
| **AEAD, RFC §2.8.2** | 11,584,909,050 | 8,587,084,818 | **1.35×** |

It also cost nothing in tape: `add8`'s frame is pasted INSIDE the addend's
unused tail, so the footprint went DOWN, from 0:52 to 0:50.

**Then the glue itself, and it needed no new algorithm either.** A paste site
names the base its routine runs at, and every site is its own copy of the code,
so `mulmod136` was re-laid with the fold and the double over `t` pasted AT `t`
and the add, the fold and the final reduction over `acc` pasted AT `acc`. There
is no work frame and nothing is carried to one. `b` is walked a BYTE at a time,
slid down one place every eight turns, and only the byte in hand is halved, so
the 117 million spent shifting seventeen bytes right one bit per turn is gone.
The nested shape — seventeen bytes of eight bits rather than 136 flat — also
pays for itself: `acc` is folded ONCE PER BYTE instead of once per set bit,
which is sound because eight turns can each add a `t` under 2^130 + 315, so
`acc` stays under 2^134 between folds and seventeen bytes hold 2^136.

One move survives inside the loop and it is worth saying why: `add136` spends
its addend, so `t` is COPIED into the addend slot and put straight back from
the cell that kept it, before the adder is entered. That is 34 cells out and 17
back rather than 220 each way, and the cell that keeps it is `add136`'s own
carry frame, which is why the putting back happens first.

| | before | after | |
| ---|--- | --- | 0 |
| `mulmod136` large | 675,977,009 | 145,361,714 | 4.65× |
| **`mulmod136` large, against the original** | 987,082,567 | 145,361,714 | **6.79×** |
| `AEAD, RFC §2.8.2` | 8,587,084,818 | 3,581,010,128 | 2.40× |
| **AEAD, against the original** | 11,584,909,050 | 3,581,010,128 | **3.24×** |

**AND THE FOLD STOPPED ENTERING THE SEVENTEEN BYTE ADDER, which was the last
big thing in Poly1305 and was not where item 2 said it was.** `fold136` adds
five times H to the value, and five times sixty three is 315 — **two bytes**.
It was doing that with `add136`, which is seventeen entries of `add8`, and
`add8` costs about fourteen thousand instructions *whatever its addend is*,
because nearly all of it is the seven halvings that find bit 7 of the
**accumulator**. Fifteen of those seventeen entries were spending fourteen
thousand instructions to add nothing.

So it now adds the two bytes it has with two entries of `add8` and lets the
carry out of the second one ripple through the remaining fifteen. **A ripple
through a byte that is not 255 costs one instruction**, and the carry reaches
byte two at all only when byte one was 255.

| | before | after | |
| ---|--- | --- | 0 |
| `fold136`, all ones | 635,880 | 116,020 | 5.5× |
| `fold136`, a value with no short bytes | 436,942 | 125,114 | 3.5× |
| `mulmod136`, the large vector | 145,361,714 | 89,473,525 | 1.62× |
| `poly1305`, RFC §2.5.2 | 431,714,708 | 264,557,017 | 1.63× |
| **AEAD, RFC §2.8.2** | 3,581,010,128 | 3,047,476,642 | **1.18×** |

**AND THEN THE ROTATION, which was more than half of ChaCha and the same
lesson a fourth time.** `ROTL32` did `n` single-bit rotations under a counter,
and one bit of rotation DOUBLEs four bytes — and a DOUBLE is `ADD8`. It is now
built on exactly the identity `idiom/rotl64` uses: `rotl(w, 8q+s)` is
`rotl(w, 8(q+1))`, which is whole BYTE turns and therefore only moves,
followed by `rotr(w, 8−s)`, which is one pasted `ROTR32`. Nothing is doubled
anywhere in the file.

| | before | after | |
| ---|--- | --- | 0 |
| `rotl32` by 16 | 2,636,189 | 40,002 | 66× |
| `rotl32` by 12 | 1,948,789 | 189,304 | 10× |
| `rotl32` by 8 | 1,316,645 | 21,835 | 60× |
| `rotl32` by 7 | 1,170,108 | 61,765 | 19× |
| ChaCha's four counts together | 7,071,731 | 312,906 | 22.6× |
| `qrloop`, one quarter round | 6,641,647 | 2,236,329 | 2.97× |
| **`blockloop`, RFC §2.3.2** | 686,380,403 | 331,136,996 | **2.07×** |
| **AEAD, RFC §2.8.2** | 3,047,476,642 | 1,937,080,043 | **1.57×** |

**It earns the branch `rotl64` declines, and that is the interesting part.**
`rotl64` spends eight bit steps where nought would do when `s = 0`, and
HANDOFF records that as about 4% of a permutation, not worth an else arm.
ChaCha's four counts are 16, 12, 8 and 7 — **two of them have `s = 0`** — so
the same branch saves sixteen of the twenty-one bit steps a quarter round
would otherwise pay. Same idiom, opposite call, and the difference is entirely
in who is calling it. Whether `rotl64` should now take the branch too is a
measurement nobody has made: Keccak's twenty-five offsets include three with
`s = 0`, so the answer is probably still no.

**`qrloop` did not change at all.** `ROTL32`'s interface — `w{4}` then `n{1}`,
`entry=4 exit=4 footprint=0:19` — is the same to the cell, so the caller that
keeps the four counts in a table and turns it by one each step never noticed.
That is the argument for the `INTERFACE` line being a contract rather than a
comment, made by a file that replaced its entire body.

**Where the AEAD's cost now is.** It began at 13.12 billion and is at 1.94,
which is 6.8× over five changes, none of which touched an algorithm. The four
that mattered were: the adder (`add8`, 1.13×), `mulmod136`'s re-lay (3.24×),
`fold136` leaving the seventeen-byte adder (1.18×), and this (1.57×). **Every
one of them was found by a profile and none by reading the code.**

**The first draft of the ripple was wrong in a way worth writing down.** Each
level was `[c ... set c ... ]` — a loop that sets its own condition, so it ran
again on the *same* byte, carried into it twice, and then stopped. Four of the
seven committed vectors caught it immediately. The fix is that the carry out
is set in a *different* cell inside the loop and moved into `c` after it.
**A brainfuck `[` used as an `if` must not touch the cell it tested.**

**And the shape of Poly1305's remaining cost has changed.** `mulmod136`'s 89
million is now roughly: `dbl136` 32 million (36%), the top-level `add136` 18
million (20%), and the rest spread. `dbl136` is next if anyone wants more, and
it is not the adder — it is already halving-based. Its cost is the *copy*: each
byte is taken twice over a distance of up to 23 cells, which is 46 instructions
per unit of the byte, and the frame cannot come closer while the value occupies
cells 0 to 16. Measure before building, as ever.

Its footprint fell from 0:286 to 0:124, which is why `absorb` is now 0:141
rather than 0:303 and `poly1305` 0:555 rather than 0:717. The callers' own
offsets were NOT re-laid to close the gap that leaves: those distances are
correct as they stand, and `poly1305`'s per-block moves are a rounding error
beside the multiply. If someone wants them, `[-L303+R303]` appearing 17 times
in `poly1305.skel` is where to start.

**And the profile again, after all of it.** The same run, now 146 million:

| | instructions | share |
| --- | --- | 0 |
| `fold136` after the double, 136 calls | 53,903,009 | 36.9% |
| `add136` | 37,199,789 | 0 |
| `dbl136` | 32,051,014 | 0 |
| `mulmod136`'s own glue | 13,727,482 | 9.4% |
| `fold136` after the byte, 17 calls | 7,098,315 | 4.9% |
| `reducep136` | 1,616,787 | 0 |

The glue is 9.4% where it was 52.9%, and the next item is visible without
guessing: **the fold after the double does not need a general fold.** `t` stays
under 2^130 + 315, so doubling it can only put 0, 1 or 2 above bit 130 — five
times which is at most 10. A general `fold136` spends a whole 17 byte add to
place that; adding at most ten to the low byte and letting the carry die where
it dies would turn 54 million into something near one. That wants its own
routine and its own vectors, which is why it is not in this change.

**And a third time, from the other end: shifting right is far cheaper than
shifting left.** `rotl32` shifts left by DOUBLING, and doubling a byte is an
addition, so it pays the adder four times per bit. `idiom/rotr32` shifts right
by HALVE, a plain countdown, at about a fifth of the cost per bit:

| | left | right | |
| ---|--- | --- | 0 |
| ChaCha's ROTL 16 | 1,433,049 | ROTR 16: 320,371 | 4.5× |
| ChaCha's ROTL 12 | 1,171,833 | ROTR 20: 375,597 | 3.1× |
| ChaCha's ROTL 8 | 718,685 | ROTR 24: 478,955 | 1.5× |
| ChaCha's ROTL 7 | 686,149 | ROTR 25: 492,069 | 1.4× |

Every one of ChaCha's four rotations is cheaper done rightward, **even the ones
that need far more steps that way** — ROTR 25 beats ROTL 7. So `qrloop` could
paste `rotr32` with the counts 16, 20, 24, 25 instead of `rotl32` with 16, 12,
8, 7, and take roughly 2.4× on its rotations for a change of four constants and
one paste name. It is not done: nothing in ChaCha needed it, the existing
vectors would be the whole of the proof, and it is a change to verified code
that no one asked for. It is written down here so the next person does not have
to rediscover it.

`dbl136` still exists for the same reason as before: doubling a 17-byte value
is a shift and costs about half a million, where an `add136` asked to do a
shift's job costs 1.35 million. If something is unexpectedly slow, look for that.

**AND ONE MEASUREMENT THAT WAS TAKEN BEFORE ANYTHING WAS BUILT, which is the
shape the other four should have had.** §9.1 had demanded, in capitals, that
the AES S-box lookup be measured before AES was committed to. It now has been,
with `scratchpad/fetch256.bf` — `index/fetch8`'s walk, which is a LOOP and so
does not grow with the table, over 256 groups instead of 8.

| | instructions |
|---|---|
| a 256-entry fetch, cheapest index | 2,368 |
| a 256-entry fetch, mean over a uniform index | **248,084** |
| a 256-entry fetch, dearest index | 787,159 |
| 200 of them, which is an AES-128 block's SubBytes and key expansion | 50 million |
| a whole AES-128 block, derived from the above plus measured byte operations | ≈75 million |
| SHA-256 of one block, for scale | 1,145,948,360 |

**The feared cost is real and small enough.** An indexed read is O(index) and
this project has avoided one since its first commit; two hundred of them come
to a fifteenth of a SHA-256 block.

**The two findings worth more than the number.** `index/fetch8` cannot address
a 256-entry table at all — its counter is `idx + 1` in one cell and 255 + 1
wraps to nought, so the last element of a byte-indexed table is unreachable,
which is exactly the table AES needs. And the cost depends on the DATUM as
much as the index, because the walk home carries the value back a group at a
time: index 254 costs 726,763 and index 255 costs 348,112, because
`S[254] = 0xbb` and `S[255] = 0x16`.

**The instrument was validated before it was believed** — all 256 indices
against a known table, and then two fetches from one table to prove the trail
is cleared and the datum restored, since one table has to serve all two
hundred reads. A measurement from an unvalidated instrument is a number with
no provenance.

**AND THE SAME LESSON A THIRD TIME, ON KECCAK — where the glue was not 37 per
cent of the cost but eighty.** A line profile of `theta` on a random state put
**76%** of its 61 million instructions in lanes travelling to a frame and back,
and of `rhopichi`'s 118 million, **86%**. The arithmetic — fifty `xor64`s,
twenty-five `and64`s and thirty `rotl64`s a round — is about a fifth of a round
and was never worth touching.

**So the optimisation was the MAP, and not one instruction of arithmetic
changed.** A byte moved over `d` cells costs two instructions per cell per unit
of the byte, so a lane's journey costs twice its distance, eight times over.
The state occupies cells 0..199 and cannot move, so every frame was packed as
close above it as it would go.

| | before | after | |
| ---|--- | --- | 0 |
| `theta` transport, per unit of byte value | 47,600 | 32,700 | 1.46× |
| `theta`, a random state | 60,962,481 | 46,787,857 | 1.30× |
| `rhopi` + `chi` transport | 99,200 | 45,300 | 2.19× |
| `rhopi`, a random state | 28,054,192 | 24,687,832 | 1.14× |
| `rhopichi`, a random state | 118,020,255 | 64,755,239 | 1.82× |
| **`permute1600`, the all-zero vector** | 3,939,144,956 | 2,483,822,414 | **1.59×** |
| SHA3-256 of "abc" | 4,302,466,302 | 2,733,053,886 | 1.57× |

**Two changes did it, and the second is the one worth remembering.**

**θ got two holding lanes instead of one.** A copy from `s` to `e` keeping `s`
must visit `e` AND the holding lane and come back, so it costs twice the *span*
of those three cells. A lane coming UP out of the state wants its holding lane
BELOW the frame; C and D coming DOWN to the frame want one ABOVE it. One cell
cannot be both, and a second costs eight cells.

**χ stopped fetching from B and fetches from a row instead.** Each lane of B is
wanted three times — once in its own place and once by each of the two outputs
below it in the row — so a flat χ made seventy-five journeys the length of the
tape and seventy-five more handing the lanes back. A row of B is five lanes at
one stride, which is forty CONSECUTIVE cells, so the whole row moves down to a
work buffer beside the frames in **a single run of forty tokens**, and B is
emptied as it goes rather than cleared afterwards. Ten long journeys a row
where there were thirty. B dropped from cell 400 to cell 328 at the same time,
which is worth 3,600 of the 53,900.

**The layout was chosen by arithmetic, not by eye.** Every journey in both
files is a formula in the map, so the total was written as a function of the
map and every packing of the blocks enumerated. θ's best packing is 0.69 of the
committed one and χ's 0.46 — and between the best ordering and the worst there
is a factor of two, which is more than any amount of staring would have found.

**THE GENERATORS WERE PROVED BEFORE THEY WERE USED, and that is the part to
copy.** `thetagen.py`, `rhopigen.py` and `chigen.py` in the scratchpad each
emit a file's body from its map. Each was first run with the **committed** map
and diffed against the committed skeleton: identical, line for line, all three
— 801, 286 and 893 lines. Only then was the map changed. That is what makes a
hundred and fifty re-derived distances a safe afternoon rather than a hunt for
one wrong number among them, and it is the same trick as the normalised
code-stream diff that found the HMAC defects, used forwards instead of
backwards. `rhopigen` goes one further: it derives π's destinations and ρ's
offsets from FIPS 202's rules rather than transcribing the table, and the
proof that the rules were read right is that it reproduces the file that was
transcribed by hand.

**What is left in Keccak, measured and not taken.** The glue is now about 65%
of a round rather than 80%, and the floor — every lane reaching a frame at cell
200 and coming back, four legs — is about 20,800 per unit against θ's 32,700.
Closing that gap needs the state itself to move, which no map can do.

The per-vector timeout in `tests/run.sh` is 900 s.

## Working discipline

**A move ADDS; empty the destination first.** Three of HKDF's four defects
were that one sentence, and each announced itself the same way: a wrong byte
that is the SUM of two right ones. `0x3c + 0xb2 = 0xee` was an output cell
written out but not emptied before the buffer slid over it; `0x3c + 0x34 =
0x70` was `T` holding the previous round when the new one landed. If a value is
wrong and its first byte looks like two correct bytes added, stop reading the
logic and look for a destination nobody cleared.

**A routine that is entered twice must clean up after itself.** `hashcore`
writes its constant table by adding to the cells, so a second entry doubled it;
`hmac` copies the padded key rather than spending it, so a second entry added
the new key to the old. Both were found by pasting the routine twice in a
scratch file and checking the second answer, which is a five line test and
worth writing before the caller that needs it.

**Mutation-check every new assertion.** Break the thing it covers, confirm the
test fails, restore. This is not ceremony — it has repeatedly found that a test
proved nothing:

- A surviving mutation in `halve136` showed the top byte's carry-add was
  **unreachable**; it is deleted.
- A surviving mutation in `reducep136` showed the **second fold was
  unreachable**. That is now `one_fold_suffices` in `spec/perm.cry`, proved
  Q.E.D. by Cryptol over all 2¹³⁶ inputs, with a companion property that must be
  *refuted* so the claim is not one that would hold whatever you deleted.
- A surviving mutation in `mulmod136` showed every existing vector had `b`'s top
  set bit at 129, so a loop stopping at 135 turns instead of 136 passed
  everything — the exact shape of a bug this routine had once before.

**Two oracles.** `tools/dkat.sh` requires the brainfuck to equal both a pinned
vector and the Cryptol spec. Where the RFC gives no vector, the pin is a
regression guard and Cryptol is the oracle. Twice now the dual oracle has caught
*me* rather than the brainfuck: an expected value I worked out by hand was wrong
and Cryptol said so. Do not pin a value you computed in your head.

## Traps that have actually bitten

- **A `.bf` THAT STILL MATCHES `HEAD` WHILE ITS `.skel` DOES NOT IS THE BUG.**
  Raising HKDF's info cap meant inserting cells into `sha512/hashcore`,
  `hmac`, `hkdf` and the four heads. The skeletons were transformed and the
  transform was right. Only `hkdf.bf` was regenerated, so `hkdf`'s shifted
  code was pasted onto an **unshifted** `hmac`, and HKDF returned garbage for
  every info length including nought.

  What made it expensive is that **every symptom pointed at the transformer**.
  The pointer contracts all passed, because a pointer walk inside one file is
  self consistent whether or not its callee agrees. The suspected free gap was
  measured and found genuinely free. A second, real defect was found and fixed
  in the transformer along the way — paste bases were not being relocated —
  and fixing it changed nothing, which should itself have been the signal.

  What settled it in one command was dumping the tape at a named contract in
  both builds and diffing them **under the shift map**: the tapes came back
  *identical*, not shifted, which no transformer bug can produce. The
  regenerated program was not running the shifted code at all.

  `git status` says this in one line, and `git diff --quiet HEAD -- FILE.bf`
  per file says it more precisely. **Regenerate before measuring**, and when a
  measurement makes no sense, ask what artifact it actually ran.

- **A COST MEASUREMENT WITH UNVERIFIED INPUT IS A NUMBER ABOUT NOTHING.** The
  first attempt at SHA-256's cost came back at **198 billion instructions**,
  seventeen times the AEAD, and it was nearly written into two repositories as
  the reason a chaining program could not be gated.

  It was wrong by a factor of 173. `tools/hx` decodes with **`-r`**, not with
  `-d`; `-d` is not the decode flag and the tool encoded instead, so the
  program was fed twenty bytes of the ASCII of the hex rather than the five
  bytes meant. Its first two bytes are a length prefix, so it hashed an
  enormous message and the count was real — just not of the thing being
  asked about.

  **The number was plausible**, which is the whole danger. SHA-256's routine
  is 7509 lines, the largest in the tree, so an enormous count confirmed what
  anyone would have assumed. A measurement that agrees with your prior is the
  one to check hardest.

  What caught it was checking the input encoding by hand. What SHOULD have
  caught it, and now does, is measuring and verifying in the same command: the
  rows above were each taken from a run whose digest was compared to its KAT
  in the same breath as its instruction count. A run that produces the wrong
  answer is not a measurement of the right workload, and there is no reason to
  ever separate the two.


- **Prose is code.** A `.` or `,` or `-` in a comment is an instruction under
  canonical brainfuck. `tools/bflint` compares the `bfi` instruction stream
  against the canonical one and catches it. Sentences end with `;`, section
  banners use `====` and not `----`, and "2.4" is written "2 point 4".
- **A routine pasted in a loop must be re-entrant.** `qrloop` built its rotation
  table by adding to whatever was already there, so the second of eight calls
  rotated by 32, 24, 16, 14. Clear your frame on the way out and assert it clear
  on the way in.
- **A declared footprint can be wrong.** `stagger` said `0:67` while its row-2
  half-exchange staged eight bytes through 64–71. Invisible standalone; pasted
  into the block function those four cells were the saved original state and one
  word of every block came out with the ASCII of `"expa"` added to it. Every
  other tier passed. `bffoot` exists because of this.
- **Read prologues span lines.** `bfexpand` once took only the first line of one
  and pasted 47 stray `,>` pairs into a caller.
- **A `.bf` is never hand-edited.** The suite regenerates every one from its
  skeleton and compares byte for byte. If you find yourself editing a `.bf`, you
  are editing the wrong file.
- **`sh` has no locals.** A helper using `$i` silently truncated a caller's loop
  once. Prefix helper variables.
- **Do not `git add -A` without looking.** A `reaper` run artifact got committed
  that way once.

