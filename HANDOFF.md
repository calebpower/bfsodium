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
| `idiom/shr32` | 121 | 133 | boundary vectors + Cryptol |
| `idiom/shr64` | 210 | 229 | boundary vectors + Cryptol  SHA_512 sigma shifts |
| `idiom/add64` | 1220 | 291 | boundary vectors + Cryptol  carry cascade and wrap |
| `idiom/and64` | 480 | 601 | boundary vectors + Cryptol |
| `idiom/xor64` | 290 | 427 | boundary vectors + Cryptol |
| `chacha20/rotl32` | 620 | 155 | boundary vectors + Cryptol |
| `chacha20/xor32` | 125 | 190 | boundary vectors + Cryptol |
| `chacha20/stagger` | 225 | 253 | Cryptol |
| `chacha20/rowrot` | 246 | 306 | Cryptol |
| `chacha20/qrloop` | 1547 | 351 | RFC 8439 §2.2.1 |
| `chacha20/blockloop` | 4608 | 1252 | RFC 8439 §2.3.2 |
| `chacha20/blockkeep` | 5271 | 341 | RFC 8439 §2.3.2 + its input surviving |
| `chacha20/stream` | 6552 | 711 | RFC 8439 §2.4.2 + block edges |
| `poly1305/add136` | 2563 | 542 | boundary vectors + Cryptol |
| `poly1305/halve136` | 470 | 539 | boundary vectors + Cryptol |
| `poly1305/fold136` | 2585 | 97 | boundary vectors + Cryptol |
| `poly1305/dbl136` | 610 | 763 | boundary vectors + Cryptol |
| `poly1305/reducep136` | 5495 | 375 | boundary vectors + Cryptol + a proof |
| `poly1305/mulmod136` | 18761 | 841 | boundary vectors + Cryptol |
| `poly1305/clamp` | 248 | 299 | boundary vectors + Cryptol  the mask pinned both ways |
| `poly1305/absorb` | 21305 | 127 | boundary vectors + Cryptol + folds to the RFC tag |
| `poly1305/poly1305` | 25845 | 935 | RFC 8439 §2.5.2 + block edges |
| `aead/keygen` | 4584 | 44 | RFC 8439 §2.6.2 + A.4 vectors 1 and 2 |
| `sha256/round` | 8154 | 1158 | seven vectors + Cryptol |
| `sha256/expand` | 3310 | 475 | seven vectors + Cryptol |
| `sha512/expand` | 6707 | 561 | eight vectors + Cryptol |
| `sha512/round` | 16706 | 1366 | FIPS 180-4 first abc round + six more + Cryptol |
| `sha256/hashcore` | 26476 | 1635 | one message from memory, the wire, and both |
| `sha256/sha256` | 26504 | 60 | FIPS 180-4 + both padding boundaries |
| `sha512/hashcore` | 57785 | 1791 | one message from memory, the wire, and both |
| `sha512/sha512` | 57853 | 64 | FIPS 180-4 + both padding boundaries |
| `sha512/hmac` | 233777 | 1868 | RFC 4231 cases 1, 2, 3 and 6 + three edges |
| `sha512/hkdf` | 537585 | 555 | RFC 5869's three shapes at SHA-512 + one byte out |
| `sha256/hmac` | 105014 | 1666 | RFC 4231 cases 1, 2, 3 and 6 |
| `sha256/hkdf` | 294912 | 512 | RFC 5869 A.1, A.2 and A.3 |
| `aead/chacha20poly1305` | 80299 | 1533 | RFC 8439 §2.8.2 + both block edges + metamorphic |

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
| 2 | yes | 242 | idiom boundary KATs, interleaved with tier 4 |
| 4 | yes | 242 | golden vectors, dual oracle |
| 5 | yes | 33 | declared contracts under BFI_CONTRACTS |
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

0. **The 64-bit set and SHA-512 are done.** `idiom/add64`, `rotr64`, `shr64`,
   `xor64` and `and64` are built and gated, and on them SHA-512, HMAC-SHA-512
   and HKDF-SHA-512. That is the whole of CONVENTIONS §9.1 tier A's SHA-512
   line and the HMAC and HKDF rows over it; SHA-384 and both SHA-512/t are the
   same core with a different IV and a truncation, and HMAC_DRBG, the SP 800-108
   KDFs and PBKDF2 are loops over an HMAC that now exists at both widths.

   Two things to know before touching them:

   - **HKDF-SHA-512's info is capped at 63 bytes** and the cap is arithmetic,
     not arbitrary: the expand message is T(64) ‖ info ‖ counter(1), and
     `sha512/hmac` takes at most 128 bytes from memory because
     `sha512/hashcore`'s prefix buffer is 256 and the pad block takes half.
     Raising it means widening that buffer, which moves every cell above it in
     hashcore, hmac and hkdf. `sha256/hkdf` has the same cap at 192 for the
     same reason. This is the one limit in the set that a real caller might
     hit — a TLS 1.3 `HkdfLabel` with a 48-byte context does not fit.
   - **An eight byte move may not be written the way sha256/* writes a four
     byte one.** Fifteen consecutive code lines with no annotation is what it
     comes to, and `bfstyle` rule 4 refuses thirteen. The step to the next byte
     goes on the same line as the move it follows; that is also what keeps
     `sha512/round.skel` under the size budget.

   **Keccak is the next keystone** and CONVENTIONS §9.1 tier B says why: it
   unlocks SHA3-224/256/384/512, SHAKE128/256, cSHAKE, KMAC, TupleHash and
   ParallelHash, and the post-quantum tier behind it. It needs no new idiom —
   theta and chi are exclusive or and and over 64-bit lanes, rho is nothing but
   64-bit rotations, and a NOT is an exclusive or with all ones — so it is a
   5×5 lane state, twenty four rounds and the sponge, and nothing that has to
   be invented first.

1. **v1 is done.** CONVENTIONS §9 lists ChaCha20, Poly1305, the AEAD, SHA-256
   and HKDF-SHA-256, and all five are in. The next real target named there is
   the BoneMesh corpus — `keyschedule.json`, `transport-frame.json` — which is
   what the symmetric set was chosen to cover; nobody has checked bfsodium's
   output against it yet, and that is the thing that would prove the set is
   actually sufficient rather than merely complete.

   **THE MACHINERY IS BUILT AND WHAT REMAINS IS THE CORPUS.** This item used
   to say the next step was a program that hashes a caller-named FILE, and
   that it would need `open`, `stat`, a relay loop and a guard over 64 KiB.
   All of that happened, and then half of it was deleted again:

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

   So the harness for the corpus check exists and is gated on both guests.
   **What is left is the corpus**: nine sequenced calls against BoneMesh's
   vectors rather than one, which is a fixture-writing job rather than a
   capability one.

   The original reasoning, kept because it is why the directory exists: the
   corpus check is nine sequenced calls, and what was unproven was the
   SEQUENCING rather than any one call. bfsodium gates every routine against
   Cryptol and the RFCs, brainstem gates the broker across two kernels, and
   **nothing anywhere tests the seam between them** — that a brainfuck
   program can take one primitive's OUTPUT and make it the next primitive's
   INPUT, with no shell in the middle. That is the capability the whole
   three-phase scheme was designed around and the one nobody has shown.

   It matters to this repository in particular, because a library's claim is
   not "each routine is correct" — it is "these compose". Composition here
   is currently source-level pasting through `bfexpand`. Composition at
   RUNTIME, one program driving several, is a different claim and an untested
   one.

   **v1.0.0 waits on this.** Tagging a library whose composition story has
   never been run end to end would be tagging on faith, and nothing about the
   version number is urgent.

   It is ONE piece of work with the corpus check rather than two, since the
   harness is the same harness.

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

2. **A cheaper `mulmod136`, if Poly1305's speed matters.** It is 987 million
   instructions and the adder is no longer where that goes; see *Cost*. 136
   turns each paying two folds is the shape to attack.

3. **`qrloop` could paste `rotr32`** with the counts 16, 20, 24, 25 instead of
   `rotl32` with 16, 12, 8, 7, for about 2.4× on ChaCha's rotations. Four
   constants and one paste name; see *Cost*.

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

| primitive | instructions | wall |
|---|---|---|
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
17-byte carry of the operands to and from the work frame. `fold136` at 818
thousand times 272 calls is already 222 million of `mulmod136`'s 987 million.

So do not reach for the adder again here. The next real win for Poly1305 is a
**better multiply** — fewer than 136 turns, or a reduction that does not fold
twice a turn — not a faster byte add. Measure it before building it; that
advice has now been earned twice.

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

