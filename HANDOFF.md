# bfsodium — handoff

Written for whoever picks this up next. It assumes you have read `README.md` and
`CONVENTIONS.md`; this is the part those do not say, which is how the thing is
actually built and where it has bitten.

## State

**Gated: 1078 pass, 0 fail on `ubuntu-26.04` AND 1078 pass, 0 fail on
`freebsd-15.1`, at `9611769`** -- `reaper test`, which the lane section below
calls the gate of record. `tools/guest-setup.sh` clones and builds brainstem
at `BRAINSTEM_COMMIT` before the suite starts, so every gate here needs the
network.

**AND THE PREVIOUS ONE WAS 354 AT `7ffd67f`, FIFTY THREE COMMITS AND SEVEN
HUNDRED AND TWENTY FOUR CHECKS EARLIER.** That is the largest gap this gate
has ever had, and it covered the 64-bit idioms, SHA-512 and its three
variants, the whole of SP 800-185, and the whole of AES. Everything in that
span was green on the container lane the day it landed, and the container
lane is Linux only -- so for fifty three commits nothing had been compiled by
a second C compiler, which is the one thing the FreeBSD guest exists for.

It came back green, which is the good outcome and not the instructive one.
**The instructive part is how the gap went unnoticed:** each commit honestly
said "LINUX HALF ONLY, the FreeBSD half has not run and this commit does not
claim it", and every one of those sentences was true. Fifty three true
sentences add up to a false impression, because a per-commit disclaimer
measures one commit and nobody was measuring the run. The line above is the
only place that counts, which is why it is the first thing in this file --
and it had been stale since `7ffd67f`. The previous gates before that were
347 at `cc974dc` and 345 at `7436078`, both on one guest.

**KILLING `container-test.sh` DOES NOT STOP ITS CONTAINER**, and the second
one writes into the same `out/suite.log` through the `out/` bind mount. Two
suites then interleave into one file and the summary line counts one run's
checks against the other's log: a run that reported `passed 824, failed 4`
had exactly **two** FAIL lines in the file, and the missing two were never
missing -- they belonged to the other process. Stop a gate with
`podman kill $(podman ps -q)`, not by killing the shell, and delete
`out/suite.log` before re-running so an interleaved file cannot be mistaken
for a clean one.

**THE SUITE HAS GROWN TO 810 SINCE THAT GATE AND THE GATE OF RECORD HAS NOT
RUN AGAIN.** Everything committed since `7ffd67f` -- SP 800-108, PBKDF2,
HMAC_DRBG, the encodings, `bytepad`, the sponge's tape prefix and suffix,
cSHAKE and KMAC -- was gated on `tools/container-test.sh`, which is **the
Linux half only**. That is the weaker of the two lanes and it is named here
rather than left to be inferred: the FreeBSD half has not seen any of it, and
the one defect the second guest has ever found was a compiler difference that
nothing on this side could reach. Run `reaper test` before believing the
number above covers the tree it sits in.

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
Every committed `.bf` is produced by `tools/bfexpand.sh` from a skeleton, and
the transpiler that used to generate most of the repo (`tools/bfemit.sh`,
`tools/*asm.sh`) is deleted.

**Every AES skeleton is hand-written, and that claim is now true for the
first time since AES was started.** Sixteen of the eighteen AES-related
skeletons had been emitted by generators while carrying a `; HAND WRITTEN`
line, in breach of CONVENTIONS §6. They were rebuilt over `367a6af`,
`045962a`, `915b1cc`, `7a142b0`, `d345370` and `6095111`.

**And the tree-wide claim is now the same claim.** Every skeleton outside
`block/` carries `; HAND WRITTEN` and names what it pastes or includes.
`block/` leaves carry no provenance line, because they are fragments their
includers account for rather than routines of their own.

Getting there took two steps after the AES work. Nine older files were
demonstrably hand-written -- last touched after the transpiler was deleted at
`7cfa69f`, so no generator existed to write them -- but said nothing, which
left the claim resting on git archaeology; they now say it. And
`chacha20/xor32` was the one file the tree could not vouch for: no line, last
touched before the transpiler went, and written in raw runs of `>` and `<`
where every other file uses the `R`/`L` shorthand. It is rewritten in the
house idiom with its reasoning written down, and its instruction stream is
unchanged.

**And a thing worth knowing before the next one of these: re-heading a pasted
routine is free.** `chacha20/xor32` is PASTED at fifty five sites across seven
files, which looked like a wide cascade. It was not. A paste takes only the
callee's body -- it drops the read prologue and everything from `; emit` -- so
the callee's header never reaches the caller. All seventy changed lines in
`chacha20/xor32.bf` are comments, zero are code, and `chacha20/qrloop.bf`
regenerated byte-identical. The same was true of the eight AES files. **Check
whether a change is header-only before pricing the regeneration**; the
instinct that paste count equals blast radius is wrong.

**And the last eight of them came out byte-identical.** `aes/xorword`,
`aes/invmixcolumns`, `aes/addroundkey`, `aes/invmixcolumn`,
`aes/invshiftrows`, `aes/shiftrows`, `aes/mixcolumns` and `aes/mixcolumn`
were each written from their contract or their specification rather than
transcribed -- two from their `; INTERFACE` lines alone, two by computing all
sixteen offsets from the FIPS 197 permutation, the rest from the identities
their own headers state -- and all eight reproduced the committed code
exactly. The generator had nothing left to add to them.

**So be careful what lesson is drawn from the rebuild.** The breach was real
and the claim was false, but the damage was concentrated: it was the three
unrolled giants, `keyexpand128` at 1,903 lines, `decrypt128` at 1,825 and
`encrypt128` at 1,609, plus the two SubBytes at 745 and 750. Those could only
have come from a machine, and looping them is what the rebuild was actually
for. The small routines were fine all along. **`bfstyle`'s 2000-line cap was
measuring exactly the right thing**, which is why it was hit three times and
routed around three times before anybody listened to it.

The two columns below are checked by `tools/bftable.pl`, not typed. If you add a
routine, the suite fails until it has a row here. A `block/` leaf has no `.bf`
of its own -- it is text that its includers carry -- so its first column is
nought and it is verified through whatever includes it.

| routine | `.bf` | `.skel` | verified against |
|---|---|---|---|
| `block/walk256` | 0 | 22 | a leaf; the indexed walk, through index/fetch256's nine vectors and everything that reads a table |
| `block/halve` | 0 | 4 | a leaf; every routine that includes it, which is `xor8` and `xtime` |
| `block/shr128gcm` | 0 | 396 | SP 800-38D's inner shift: right one bit, reduced with 0xe1 at the top; the MIRROR of block/shl128 and not a reuse of it, which the field laws in tier 7 are what police |
| `block/ghashmul` | 0 | 494 | SP 800-38D Algorithm 1; proved through `aes/gfmul128` against the published subkey, against Cryptol, and against the four laws of the field itself |
| `block/ghashstep` | 0 | 339 | one block folded into a GHASH; included three times by `aes/gcm128` and proved by its vectors, two of which exist precisely because the empty one does not reach two of those three call sites |
| `block/inc128` | 0 | 423 | a 128-bit big-endian counter stepped by one; `aes/ctr128` was migrated onto it with its instruction stream byte-identical, which is the proof, and its four published SP 800-38A blocks exercise the carry because F.5's counter is f0f1..feff |
| `block/drbgupdate` | 0 | 527 | SP 800-90A section 10.2.1.2; proved through `aes/ctrdrbg128`, whose n=0 vector is the Update chain and nothing else |
| `block/xor8kernel` | 0 | 32 | a leaf; `idiom/xor8`'s vectors and its 1024 run sweep |
| `block/rotate16` | 0 | 49 | a leaf; one turn against a one-place rotation on four states, sixteen turns against the identity, and `aes/subbytes`' own vectors, which come out in order only if the turning is exact |
| `block/sbox256` | 0 | 524 | a leaf; the S box, through `aes/subbytes`' FIPS 197 vectors and both ends of the table |
| `block/invsbox256` | 0 | 524 | a leaf; the same permutation read backwards, through `aes/invsubbytes` and the round trip |
| `block/rotate40down4` | 0 | 32 | a leaf; one turn against a four-place rotation on random bytes, ten turns against the identity, and `aes/decrypt128`'s own vectors, which only come out right if phase one's ten temps land where phase two reads them |
| `block/rotate40up4` | 0 | 27 | a leaf; the same, and proved to invert `block/rotate40down4` |
| `block/rshift32` | 0 | 101 | a leaf; one bit of right shift across a 32 bit word, through `idiom/rotr32` and `idiom/shr32`, whose vectors and Cryptol checks are the proof |
| `block/rshift64` | 0 | 184 | a leaf; the same at 64 bits, through `idiom/rotr64` and `idiom/shr64` |
| `block/enccase32` | 0 | 111 | a leaf; which case a 32 bit length encodes to, through `keccak/leftenc` and `keccak/rightenc` at every byte count and both sides of every boundary |
| `block/unstage16` | 0 | 68 | a leaf; the sixteen byte temporary coming home, through `aes/shiftrows` and `aes/invshiftrows` and the FIPS 197 rounds that use them |
| `block/aes128table` | 0 | 43 | the S box lay down lifted out of the cipher so a mode can pay for it once; proved by `aes/encrypt128` coming back INSTRUCTION IDENTICAL across the split, and by `aes/ctr128`'s four published blocks, which are wrong in all 256 places if it is ever run twice |
| `block/aesroundcore` | 0 | 42 | SubBytes, ShiftRows and MixColumns over the state, and deliberately NOT AddRoundKey, which is the only step that needs to know where the round key came from; written once and included by every key size |
| `block/aesroundlast` | 0 | 65 | the first two thirds of the above, which is FIPS 197's final round; the split is what makes the last round the same text as the other thirteen rather than a copy of it |
| `block/rkappend240` | 0 | 178 | one word onto the tail of the schedule buffer, sliding it; the producing half of the stored-schedule conveyor |
| `block/rkconsume240` | 0 | 171 | one round key off the head of the schedule buffer, sliding it; the consuming half, and its entry contract claims the round key cells already clear, which is the cheap guard against the copy where a move belonged |
| `block/rkappend208` | 0 | 162 | the appending conveyor at AES-192's buffer length; a second pair rather than the 240 pair at an offset, because the difference is a number of moves |
| `block/rkconsume208` | 0 | 155 | the consuming half of the same pair |
| `block/aeskeyexpand192` | 0 | 1484 | the AES-192 schedule, 208 bytes from 24, and the same generator as the 256 one with Nk changed; proved by `aes/keyexpand192` against FIPS 197 Appendix A.2 |
| `block/aeskeyexpand256` | 0 | 1798 | the whole AES-256 schedule, 240 bytes from 32, including the bare SubWord rule that exists at no other key size; proved by `aes/keyexpand256` against FIPS 197 Appendix A.3 |
| `block/aes128encrypt` | 0 | 288 | the forward rounds without their program; the same identity proof, plus the round constant contract that stops a second block starting from the 0x6c the schedule leaves behind |
| `block/aes128dsetup` | 0 | 230 | the inverse cipher's key schedule and table swap, which happen ONCE however many blocks follow; proved by `aes/decrypt128` regenerating instruction-identical across the split, and by `aes/cbcdec128`'s two-block vector, which is the shortest input that reuses what it leaves behind |
| `block/aes128drounds` | 0 | 297 | the inverse rounds alone; the same identity proof, and its two zero contracts — dead weight when this was one file — now police the fifty-six bytes a mode has to restore before every block |
| `block/copy16` | 0 | 68 | sixteen bytes copied down 885 cells; included TWICE by `aes/ctr128`, which is only possible because its tape was laid out to give the key and the counter the same geometry, and where a wrong copy of either is a wrong published block |
| `block/copy16back` | 0 | 59 | the staging cells emptied again, which is not tidiness: they are the cipher's own workspace and the schedule's round key, and the cipher is entered immediately afterwards; the same vectors |
| `block/move16` | 0 | 66 | sixteen bytes moved down 885 cells  the sibling of `block/copy16` for an operand that is SPENT; proved by `aes/cbcenc128`'s two block vector  which is the shortest message that can tell a move from a copy here  and which failed when this was a copy |
| `block/topbit` | 0 | 73 | a byte's top bit by seven halvings; proved through `block/shl128`, whose published subkey pair is wrong in the first byte if this is |
| `block/shl128` | 0 | 297 | SP 800-38B section 6.1's doubling in GF(2^128); proved by `aes/cmacsubkeys` against RFC 4493's PUBLISHED K1 and K2, which between them exercise both arms of the reduction, and separately on the all-ones and single-bit edges before the mode existed |
| `block/moveup16` | 0 | 62 | sixteen bytes moved UP 885 cells; the third of the family that crosses this library's one recurring distance, and proved wherever a cipher's answer has to leave the state |
| `idiom/add8` | 175 | 183 | every one of the 65536 pairs + two proved identities |
| `chacha20/add32` | 633 | 168 | boundary vectors + Cryptol |
| `idiom/and32` | 268 | 325 | boundary vectors + Cryptol |
| `idiom/rotr32` | 147 | 53 | boundary vectors + Cryptol |
| `idiom/rotr64` | 234 | 65 | boundary vectors + Cryptol  SHA_512 Sigma1 counts |
| `idiom/rotl64` | 335 | 151 | boundary vectors + Cryptol  both ends of the byte and bit split |
| `idiom/shr32` | 148 | 55 | boundary vectors + Cryptol |
| `idiom/shr64` | 238 | 69 | boundary vectors + Cryptol  SHA_512 sigma shifts |
| `idiom/add64` | 1222 | 293 | boundary vectors + Cryptol  carry cascade and wrap |
| `idiom/and64` | 482 | 603 | boundary vectors + Cryptol |
| `idiom/xor64` | 293 | 430 | boundary vectors + Cryptol |
| `idiom/xor8` | 124 | 95 | boundary vectors + Cryptol  and a 1024 run sweep |
| `chacha20/rotl32` | 283 | 175 | boundary vectors + Cryptol |
| `chacha20/xor32` | 143 | 208 | boundary vectors + Cryptol |
| `chacha20/stagger` | 225 | 253 | Cryptol |
| `chacha20/rowrot` | 246 | 306 | Cryptol |
| `chacha20/qrloop` | 1178 | 351 | RFC 8439 §2.2.1 |
| `chacha20/blockloop` | 4231 | 1252 | RFC 8439 §2.3.2 |
| `chacha20/blockkeep` | 4899 | 341 | RFC 8439 §2.3.2 + its input surviving |
| `chacha20/stream` | 6205 | 732 | RFC 8439 §2.4.2 + block edges |
| `poly1305/add136` | 2563 | 542 | boundary vectors + Cryptol |
| `poly1305/halve136` | 470 | 539 | boundary vectors + Cryptol |
| `poly1305/fold136` | 962 | 588 | boundary vectors + Cryptol |
| `poly1305/dbl136` | 610 | 763 | boundary vectors + Cryptol |
| `poly1305/reducep136` | 3810 | 375 | boundary vectors + Cryptol + a proof |
| `poly1305/mulmod136` | 10004 | 472 | boundary vectors + Cryptol |
| `poly1305/clamp` | 248 | 299 | boundary vectors + Cryptol  the mask pinned both ways |
| `poly1305/absorb` | 12583 | 127 | boundary vectors + Cryptol + folds to the RFC tag |
| `poly1305/poly1305` | 17070 | 935 | RFC 8439 §2.5.2 + block edges |
| `aead/keygen` | 4212 | 44 | RFC 8439 §2.6.2 + A.4 vectors 1 and 2 |
| `sha256/round` | 8298 | 1158 | seven vectors + Cryptol |
| `sha256/expand` | 3454 | 475 | seven vectors + Cryptol |
| `sha512/expand` | 6900 | 595 | eight vectors + Cryptol |
| `sha512/round` | 16910 | 1419 | FIPS 180-4 first abc round + six more + Cryptol |
| `sha256/hashcore` | 26764 | 1635 | one message from memory, the wire, and both |
| `sha256/sha256` | 26792 | 60 | FIPS 180-4 + both padding boundaries |
| `sha512/hashcore` | 58723 | 1867 | one message from memory, the wire, and both |
| `sha512/sha512` | 58773 | 64 | FIPS 180-4 + both padding boundaries |
| `sha512/hmac` | 241768 | 1700 | RFC 4231 cases 1, 2, 3 and 6 + three edges |
| `sha512/hkdf` | 617293 | 583 | RFC 5869's three shapes at SHA-512 + one byte out |
| `sha512/sha384` | 58868 | 84 | rate aside  this is SHA_512 with eight other words; nothing  abc and both block boundaries + Cryptol |
| `sha512/sha512_224` | 58876 | 78 | the same four  and the only one whose digest cuts a word in half + Cryptol |
| `sha512/sha512_256` | 58872 | 78 | the same four; its H4 was one bit wrong until the words were DERIVED + Cryptol |
| `sha256/hmac` | 105878 | 1666 | RFC 4231 cases 1, 2, 3 and 6 |
| `sha256/hkdf` | 296640 | 512 | RFC 5869 A.1, A.2 and A.3 |
| `sha256/kdfctr` | 133133 | 324 | SP 800-108 §4.1 counter mode at both inner-hash block counts, one turn, two turns, a turn cut short and no fixed input |
| `sha256/kdffb` | 134091 | 332 | SP 800-108 §4.2 feedback mode: one turn, two turns so the chain feeds back, a turn cut short, no fixed input, and the longest fixed input allowed |
| `sha256/pbkdf2` | 137435 | 716 | RFC 7914 §11's published c=1 and c=2 vectors, two output blocks, a block cut short, and the longest salt allowed |
| `sha256/drbg` | 223756 | 608 | NIST's published CAVP vector for HMAC_DRBG SHA-256, a generate cut short, and the longest seed allowed |
| `aead/chacha20poly1305` | 53226 | 1533 | RFC 8439 §2.8.2 + both block edges + metamorphic |
| `index/fetch256` | 114 | 59 | the real S-box at both ends and the middle, index 255 included, which `fetch8` cannot reach |
| `index/fetch256twice` | 218 | 86 | the same table read twice, which is what lets one table serve all two hundred of AES's reads |
| `aes/xtime` | 219 | 123 | all 256 bytes swept + Cryptol over the field polynomial  and the identity proved |
| `aes/mixcolumn` | 1966 | 311 | FIPS 197 Appendix B + the fixed points + 256 columns against the matrix form |
| `aes/mixcolumns` | 7856 | 176 | FIPS 197 Appendix B rounds 1 2 5 and 9 |
| `aes/shiftrows` | 167 | 114 | FIPS 197 Appendix B rounds 1 5 and 9 + the permutation read off a state of its own indices |
| `aes/subbytes` | 636 | 100 | FIPS 197 Appendix B rounds 1 5 and 9 + both ends of the table  255 included |
| `aes/xorword` | 330 | 72 | boundary vectors + Cryptol |
| `aes/addroundkey` | 1356 | 109 | FIPS 197 Appendix B round nought + its own inverse applied twice |
| `aes/keyexpand128` | 2371 | 313 | the FIPS 197 Appendix A schedule + three more keys |
| `aes/keyexpand192` | 10662 | 93 | four keys, the first FIPS 197 Appendix A.2, which publishes all 208 bytes -- the only way to test that the bare SubWord rule is ABSENT at this key size |
| `aes/encrypt192` | 25281 | 174 | four blocks, the first FIPS 197 Appendix C.2, on the same key the schedule above is pinned on |
| `aes/keyexpand256` | 13134 | 95 | four keys, the first of them FIPS 197 Appendix A.3, which publishes all 240 bytes so the first word it gets wrong is named; the all-nought key is the one where the bare SubWord rule shows plainly |
| `aes/encrypt256` | 27825 | 172 | four blocks, the first FIPS 197 Appendix C.3, on the same key the schedule above is pinned on, so what the schedule vectors prove is what this runs |
| `aes/cbcdec128` | 31105 | 1206 | SP 800-38A F.2.2 at four blocks, at two and at one: one block would pass even if the rounds destroyed every piece of state they touch, and TWO is the shortest input that runs against a schedule already spent and restored; plus 272 bytes, which restores it sixteen more times and reaches the length's borrow, DERIVED; and the zero key, which runs `encrypt128`'s own pinned block backwards |
| `aes/cbcenc128` | 19437 | 394 | SP 800-38A F.2.1, all four published blocks and block one alone  as a PAIR: the first alone cannot see a broken chain because a block is emitted before it is chained  and that pair is what caught the copy that should have been a move; 272 bytes for the length's borrow; and the zero key and zero IV  where the chained block IS the plaintext  so one zero block is `encrypt128`'s own pinned value |
| `aes/cmac128` | 42188 | 786 | RFC 4493's four published examples, which cover the padding branch both ways and at one block and at several: empty and 40 bytes take K2, 16 and 64 take K1, and the pairs separate a wrong tweak from a wrong chain; plus 273 bytes, which is past the length's borrow AND needs padding, DERIVED |
| `aes/cmacsubkeys` | 22871 | 105 | RFC 4493 section 4's PUBLISHED K1 and K2, and the zero key as a second independent pair; it exists so that a wrong CMAC tag can be told apart from a wrong subkey, which sixteen opaque bytes cannot do |
| `aes/ctr128` | 19989 | 355 | SP 800-38A F.5.1, all four published blocks and block one alone, so the pair separates a wrong cipher from a wrong per block restoration; one byte into the second block, which is the cheapest input that carries the counter; and the zero key, whose first sixteen bytes are `encrypt128`'s own pinned value checked four lines above by a different program |
| `aes/ctrdrbg128` | 58901 | 325 | five DERIVED lengths including nought and a truncating one, plus a METAMORPHIC check that rests on no reference of ours: sixteen bytes must be the first sixteen of sixty-four. NOTHING HERE IS PUBLISHED and the section below says why and what stands in for it |
| `aes/encrypt128` | 16906 | 86 | FIPS 197 Appendix C point 1 and Appendix B  every end to end value the standard publishes  plus its contracts live |
| `aes/gfmul` | 2122 | 292 | FIPS 197 section 4 point 2 + 2604 runs  and the peasant form PROVED equal to the field |
| `aes/gfmul128` | 1236 | 49 | five products, anchored at one end by the published subkey H and checked by Cryptol; and separately the IDENTITY, the absorbing zero, COMMUTATIVITY and DISTRIBUTIVITY, which rest on no reference anyone here wrote |
| `aes/ghash128` | 1992 | 528 | four block counts anchored at one end by the published subkey H; the empty one and the single zero block BOTH answer nought and are both kept, because a program that skipped the loop would pass the first and one whose multiply returned its first operand would pass both; two blocks is where the accumulator feeds back AND where a copy of H that should have been a move would show |
| `aes/gcm128` | 61948 | 1415 | five shapes, chosen one per PATH rather than per feature: nothing, plaintext only, associated data only (which is GMAC), one whole block of each, and twenty bytes of each so both sections pad. The first two agree with the tags universally quoted as GCM's test cases 1 and 2, reproduced here from the standard's text alone |
| `aes/invmixcolumn` | 3181 | 139 | aes/mixcolumn's published columns inverted + 300 against the FIPS matrix |
| `aes/invmixcolumns` | 12669 | 85 | all nine Appendix B rounds run backwards + round trips MixColumns |
| `aes/invshiftrows` | 166 | 113 | all ten Appendix B rounds run backwards + round trips ShiftRows |
| `aes/invsubbytes` | 641 | 105 | all ten Appendix B rounds run backwards + round trips SubBytes  both ends of the table |
| `aes/decrypt128` | 25454 | 110 | both published values run backwards  encrypt128's own vector reversed  and the round trip |
| `keccak/leftenc` | 238 | 141 | SP 800-185 §2.3.1 left_encode at every byte count and both sides of every boundary |
| `keccak/rightenc` | 238 | 141 | the same for right_encode |
| `keccak/bytepad136` | 3903 | 251 | SP 800-185 bytepad at SHAKE256's rate: both empty, KMAC's own prefix, a customization string, the limit where the block is exactly full, and the ONE-string form KMAC's key needs |
| `keccak/bytepad168` | 3952 | 251 | the same at SHAKE128's rate, including its own exactly-full limit and the one-string form |
| `keccak/cshake256` | 170333 | 178 | SP 800-185 §3: NIST samples 3 and 4, the empty/empty branch that IS SHAKE, and a non-empty name |
| `keccak/cshake128` | 184519 | 178 | the same at SHAKE128's rate, with NIST sample 1 |
| `keccak/kmac128` | 208318 | 226 | SP 800-185 §4 at SHAKE128's rate: NIST samples 1, 2 and 3, and the XOF flag |
| `keccak/kmac256` | 190928 | 226 | the same at SHAKE256's rate: NIST samples 5 and 6, a DERIVED sample 4, and the XOF flag |
| `keccak/tuplehash128` | 232065 | 756 | SP 800-185 §5 at SHAKE128's rate: NIST samples 1, 2 and 3, and the XOF flag |
| `keccak/tuplehash256` | 215112 | 756 | the same at SHAKE256's rate: NIST samples 4, 5 and 6, and the XOF flag |
| `keccak/theta` | 18894 | 878 | the two eye-checkable states  both corner bits  a ladder and a random state + Cryptol |
| `keccak/rhopi` | 9741 | 334 | the same six states + Cryptol |
| `keccak/rhopichi` | 32164 | 1026 | rho and pi PASTED  the same six states + Cryptol  all ones is the one chi cannot fake |
| `keccak/permute1600` | 51869 | 271 | the published all zero vector and a random state + Cryptol |
| `keccak/rotstate` | 98 | 56 | all zero  a ladder and a random state whose bottom byte travels + Cryptol |
| `keccak/absorb136` | 68616 | 284 | the published all-zero permutation, and a ladder state with every lane taking a block |
| `keccak/absorb168` | 72827 | 336 | the same two at SHAKE128's rate: twenty-one lanes, not seventeen |
| `keccak/parallelhash128` | 276143 | 781 | SP 800-185 §6 at SHAKE128's rate: NIST sample 1, a short last chunk, and the XOF flag |
| `keccak/parallelhash256` | 264540 | 781 | the same at SHAKE256's rate: NIST samples 4 and 5, a short last chunk, and a chunk bigger than a rate |
| `keccak/squeeze136` | 52366 | 238 | inside the first rate, and one byte past it, which is the only path that stirs |
| `keccak/squeeze168` | 52372 | 238 | the same two at SHAKE128's rate |
| `keccak/sponge136` | 141619 | 504 | the same .bf handed a 6 and a 31  and one squeeze past a rate + Cryptol |
| `keccak/sha3_256` | 141646 | 67 | sponge136 PASTED with a 6; FIPS 202's abc + nothing + both padding boundaries + Cryptol |
| `keccak/shake256` | 141648 | 65 | sponge136 PASTED with a 31; both sides of the rate and two blocks in one rate out + Cryptol |
| `keccak/sponge168` | 151200 | 511 | one inside the first rate and one past it + Cryptol |
| `keccak/shake128` | 151223 | 67 | sponge168 PASTED with a 31; both sides of the rate and two blocks in one rate out + Cryptol |
| `keccak/sha3_224` | 66915 | 523 | rate 144 with the constants written in; nothing  abc and both padding boundaries + Cryptol |
| `keccak/sha3_384` | 62625 | 458 | rate 104  the same four + Cryptol |
| `keccak/sha3_512` | 59322 | 406 | rate 72  the same four + Cryptol |

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
| 2 | yes | 625 | idiom boundary KATs, interleaved with tier 4 |
| 4 | yes | 625 | golden vectors, dual oracle |
| 5 | yes | 62 | declared contracts under BFI_CONTRACTS |
| 6 | no | 0 | **differential fuzz, declared and not built** |
| 7 | yes | 4 | metamorphic |
| 8 | yes | 19 | Cryptol design proofs, two of which must be refuted |
| 8a | yes | 3 | the Cryptol oracle is delivered once and is load-bearing |
| 9 | yes | 10 | legibility and portability |
| 9a | yes | 1 | style consistency |
| 9b | yes | 1 | size budget, enforced inside bfstyle |
| 9c | yes | 4 | provenance: every .bf equals bfexpand of its skeleton |
| 9d | yes | 2 | the INTERFACE line tells the truth |
| 9e | yes | 6 | the routine AND tier tables describe the tree |
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

4. **DONE: HMAC_DRBG, the SP 800-108 KDFs, PBKDF2.** Loops over an HMAC whose
   map is final by then. All four are built and pinned: `sha256/kdfctr`,
   `sha256/kdffb`, `sha256/pbkdf2` and `sha256/drbg`, with four to six vectors
   each.

   **This item read "the counter-mode KDF is built; the rest of the step is
   not" for longer than it was true**, and it was found by checking the tree
   against the prose rather than by anyone noticing. A status line that
   understates what exists is the same species of defect as one that
   overstates it: both send the next person to the wrong place. The routine
   table is generated and could not drift; this paragraph was hand-written and
   did.

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
   entry point rather than a rewrite.

   **STARTED: `keccak/leftenc` and `keccak/rightenc` are built.** This list
   said the first unit was "the encodings (`left_encode`, `right_encode`,
   `encode_string`, `bytepad`)", and that grouping is wrong — the fourth time
   this page has named a unit that was not the unit. The first two are
   primitives; `encode_string` and `bytepad` are **concatenations of
   variable-length pieces**, which is the assembly problem and belongs with
   the block builder, not with them.

   What makes the two that landed cheap is worth stating, because it is the
   opposite of what the rest of SP 800-185 will be: **the byte count decides
   WHICH of x's bytes are copied, not WHERE they land**, so each of the four
   cases is a fixed pattern and there is no sliding anywhere. x is 32 bits,
   which is a choice — the standard allows up to 2^2040, and everything
   SP 800-185 asks for (a rate, a length in bits, an output length) is far
   smaller.

   Twenty vectors, every case and both sides of every boundary, and they run
   in microseconds rather than minutes — the first thing in this batch that
   costs the gate nothing.

   **A DEFECT CAUGHT BEFORE IT WAS COMMITTED, BY LOOKING RATHER THAN BY
   TESTING.** All twenty vectors passed, and the routine was still wrong: the
   cascade's `any` cell was left at 1 whenever a case above one byte was
   taken. A single use never sees it. **A second paste would have seen it
   immediately** — `any` already set means the cascade skips every case, sets
   no flag, and encodes nothing at all, silently — and the block builder
   pastes this routine twice. It was found by dumping the frame after a run
   and asking whether it was clean, because the next thing to be written was
   its second caller.

   That is `chacha20/add32`'s stated convention, which this routine was
   quietly breaking: *the frame is as clean on the way out as a caller is
   entitled to assume on the way in.* It now clears the cell and **declares
   `ASSERT zero +0:+11`**, so the convention is checked rather than promised,
   and the two contract runs added to the suite are the test that would have
   caught it.

   **DONE as well: `keccak/bytepad136`**, the block builder — `bytepad(
   encode_string(N) ‖ encode_string(S), 136)`, which is what cSHAKE256 and
   KMAC256 put on the tape ahead of the message. 136 is in the file name for
   the reason `sponge136` and `sponge168` are separate files: a rate sets the
   size of a buffer, which is a tape map and not a number.

   **THE BLOCK IS BUILT RIGHT TO LEFT, BY PREPENDING, and that is the whole
   idea.** The standard's layout puts each piece at an offset the lengths of
   the pieces before it decide — an index, which this library does not have.
   So the pieces go in backwards, last first, and each is put in by sliding
   the whole block right by its own length and then ADDING it at cell nought.
   **Cell nought is always cell nought**, so no position is ever computed, and
   this is the third distinct way the library has now dodged an index —
   after the conveyor and after `hkdf`'s counter slide.

   Two things fall out of it and both are wanted: the tail is never written so
   it stays at nought, which *is* `bytepad`'s padding; and a string's buffer
   is nought beyond its own length, so adding a whole 128-byte buffer over the
   slid block cannot disturb what is already there.

   Eight times a length is three doublings of `chacha20/add32` with the
   accumulator as its own addend — `encode_string` wants the length in bits,
   and that is a loop of three around a proved adder rather than a fourth
   hand-rolled shift.

   Six vectors including `bp136Run_32_96`, where the block comes out **exactly
   full with no padding at all**, which is the cap vector this batch's own
   rule asks for. It pastes `leftenc` twice, which is precisely the case the
   cleanliness fix above made safe — the two units were written an hour apart
   and the second is why the first was worth checking.

   **And the 168 twin**, `keccak/bytepad168`, for cSHAKE128 and KMAC128. The
   generator that writes both was **proved by identity first**: parameterised
   by the rate, run against the committed 136 file, and every instruction line
   matched before it was used with a new constant. Only the header differs
   between that run and what was committed, because the prose now carries
   digits the generator can compute rather than numbers spelled out by hand.

   Its cap follows the rate rather than being restated — `nlen + slen` at most
   `rate − 8`, so 128 at 136 and 160 at 168 — and `bp168Run_64_96` is its own
   exactly-full vector.

   **DONE as well: tape-prefix absorption.** `keccak/sponge136` now takes a
   prefix from the tape before it reads the wire — the two-source shape
   `sha256/hashcore` has had all along, which is the argument for it: this is
   the established pattern here, not a new idea.

   **The cheap path was tried first and does not work.** cSHAKE could in
   principle pre-load the state with the permuted prefix and then paste the
   sponge unchanged. It cannot: the sponge asserts `zero 5:1025` on entry, and
   its head cells live INSIDE the state at 0..4 before being relocated, so a
   caller that pre-loaded S would both break the contract and have its first
   five state bytes moved out from under it. Worth recording so nobody spends
   an afternoon rediscovering it.

   **Every new cell went above the old top at 1025**, so no existing address
   moved and `sha3_256` and `shake256` needed only a footprint number and a
   widened contract — no re-lay at all, which is what the change looked like
   it would cost. The paste mechanism absorbed the `entry` change (4 → 278) by
   itself, since `import` emits `>`×entry and the body walks back.

   **No new block machinery.** The prefix is consumed by a SECOND CONVEYOR
   feeding the first: the head of the prefix buffer enters the block and the
   buffer slides down one, exactly as the block itself does. Only *where the
   next byte comes from* changed.

   **A BUG THAT NO CHECKER IN THIS REPOSITORY CAN SEE.** One hand-written
   token came out `[-R2+R3+L5]`. It is POINTER BALANCED, so `ptrcheck` passes
   it; `bflint`, `bfstyle` and `bffoot` have nothing to say about it either.
   It simply lands on cell 1038 instead of the handback cell at 1036. Nor
   would a vector have caught it: the cell it corrupts only matters for a
   prefix longer than 255 bytes, and nothing asks for one. It was found by
   reading the emitted tokens back and naming what each one targets, which is
   now worth doing for any token written by hand rather than computed:

       at PLO   [-R3+R1+L4]   -> PT PB PLO
       at PHI   [-R2+R1+L3]   -> PT PB PHI      (corrected)
       at PBUF  [-L81+R81]    -> BBtop PBUF

   Four vectors against `hashlib` and Cryptol both: one block of prefix with
   and without a wire message, two blocks with two rates out, and a prefix
   that is deliberately NOT block-aligned. `bytepad` never makes one, but the
   conveyor counts bytes rather than blocks, and untested capability is where
   surprises come from. The nine SHA3-256 and SHAKE256 vectors were re-run at
   `plen = 0` and are byte-identical.

   **And the 168 twin**, for cSHAKE128 and KMAC128. `sponge168` is
   `sponge136` shifted by exactly +32, and because every new cell sits at the
   same offset from the TOP of the frame, **the whole prefix arm lifted across
   byte for byte** — even `[-L81+R81]`, the token that carries the head of the
   prefix into the block, is the same at both rates.

   One thing did not transfer, and `ptrcheck` caught it as a uniform +64: the
   walk home after the slide scales with the BUFFER, not the rate — `L279` at
   272 cells, `L343` at 336. Worth knowing for the next twin: what scales with
   the rate and what scales with the buffer are different sets.

   **A PRE-EXISTING DEFECT FOUND ON THE WAY.** `keccak/shake128` declared
   `ASSERT zero 4:1025`, but it runs at rate 168 with a frame of `0:1057` —
   **1025 is the 136 rate's top**, copied from `shake256` and never updated.
   A narrower assertion is still true, so nothing ever failed; it simply
   under-checked 32 cells of its own frame for as long as the file existed.
   Same family as the balanced-but-wrong token above: a number that is
   PLAUSIBLE because it came from the twin, and that nothing questions because
   **no checker cross-references a contract against the footprint it belongs
   to**. That would be a real tier if anyone wants one.

   **DONE: cSHAKE256 and cSHAKE128.** Both are HEADS and neither adds any
   cryptography: read the lengths and the two strings, paste `bytepad` to
   build the block, move it into the sponge's staging area, hand over the
   padding byte, paste the sponge. The two pasted frames do not overlap — the
   sponge owns up to its own top and `bytepad` sits above it — so the block is
   built high and moved down.

   **The padding byte is the whole difference from SHAKE**, one cell: 6 for
   SHA3, 31 for the SHAKEs, 4 for the customizable pair. `sponge136`'s header
   predicted this before cSHAKE existed.

   **With no name and no customization string cSHAKE IS SHAKE**, which the
   standard states outright — it is *not* the prefix construction over two
   empty strings, which would absorb a whole block of encodings and give a
   different answer. That is a branch, and it has its own vector at each rate.

   Both rates passed **first run**, which is what the pre-work bought: the
   skeletons were checked with `ptrcheck` and the spec entries were evaluated
   in Cryptol against a scratch copy of the spec *before* anything entered the
   repository.

   **A FALSE "PUBLISHED" CLAIM, CAUGHT BEFORE IT SHIPPED.** cSHAKE128's
   200-byte vector was initially labeled as NIST sample 2 from memory. The
   computed value diverges from that recollection at byte 10 — and the first
   ten bytes agreeing is the tell, because that is what half-remembering looks
   like. It is now named `cshake128Run_200` for its message length and
   labeled DERIVED. What stands on its own: the Keccak reference reproduces
   SHAKE128, SHAKE256 and SHA3-256 from a third party; **cSHAKE256 samples 3
   and 4 match NIST exactly**, which confirms the construction; and
   **cSHAKE128 sample 1 matches exactly across all thirty two bytes**, which
   confirms the 168 path independently.

   The rule this earns, and it is the SHA-512/256 H4 defect in a new costume:
   **mark a vector published only against a value you can point to, never one
   you recall.** A recalled constant that is mostly right is the worst kind,
   because the part you remember correctly is what makes you trust the rest.

   **DONE: THE TAPE SUFFIX, at both rates.** The sponge's byte source now has
   four arms in order — tape prefix, wire, tape suffix, padding — and the
   third is new. It is the prefix's mechanism at the other end: a buffer above
   the frame, a count, and a conveyor that feeds the block conveyor.

   Two things made it cheap, and both were decisions taken earlier for other
   reasons. **The new cells went at the TOP of the frame and into the six
   cells that were already free between `kc` and `plen`**, so not one existing
   cell moved and `shiftcells` was not needed at all — an insertion, not a
   shift, which is the difference between an afternoon and the HKDF widening.
   And **the head grew at its END** (`slen{2} sbuf{8}` after `pbuf`), so
   cSHAKE's staging still starts at cell 7 and both cSHAKE files needed
   nothing but a regenerated footprint.

   **Nothing in the block accounting had to change**, which is worth saying
   because it looks like it should have: whether another block is wanted is
   decided by `pad`, the flag that stays set until the padding byte is placed,
   and the padding waits behind the suffix. A suffix that spills into a new
   block therefore keeps the loop going without anything knowing why. There is
   a vector for exactly that — the wire runs to 134 bytes at one rate and 166
   at the other, so two of the four suffix bytes land in each block.

   **And the drain is now a contract.** `ASSERT zero 1026:1319` at the end of
   the absorb says both tape buffers are spent. The old contract stopped at
   `last` and never looked above it, so a conveyor that quietly failed to
   consume its buffer would have passed every vector whose answer did not
   depend on it.

   **DONE: KMAC128 and KMAC256, with KMACXOF in the same files.** Another
   head: `bytepad` is PASTED TWICE — once over `encode_string(K)` and once
   over cSHAKE's own name-and-customization pair — the two blocks are staged
   as the sponge's two-rate prefix, `right_encode(8 × olen)` goes in the
   suffix, and the padding byte is 4. The sponge's prefix buffer has been two
   rates deep since the day it was written, for this.

   **One paste serves both blocks**, because `bytepad` leaves its own frame at
   nought once the block is carried out of it. That was true before and
   nothing relied on it; there is now a contract after each of the two runs
   that says so, and if it ever stops being true the second block is the
   thing that breaks.

   **KMACXOF is one cell and not a second pair of files.** It is KMAC with
   `right_encode(0)` in place of `right_encode(L)`, and `right_encode` of
   nought is what the encoder already produces when handed nought — so the
   flag does not branch around the encoder, **it clears its input**. `xof{1}`
   nought is KMAC and one is KMACXOF. Same family as the padding byte: a rate
   cannot be a parameter here, and this can.

   **Five of the six samples are NIST's own printed answers and the sixth is
   not**, and the rule from cSHAKE128 is why it is labeled that way. KMAC256
   sample 4's published value could not be quoted from a source — a recalled
   tail disagreed with the computed one and was the wrong length besides — so
   it ships as DERIVED. What it rests on is not recollection: the same
   reference reproduces KMAC128 samples 1, 2 and 3 and KMAC256 samples 5 and
   6 byte for byte at full length, and reproduces SHAKE128, SHAKE256 and
   SHA3-256 from a third party underneath that.

   **All sixteen new spec entries were evaluated in Cryptol and agreed with
   the Python reference before a single byte of brainfuck ran** — two
   independent oracles settled first, so the only open question left for the
   suite was whether the brainfuck agreed with both.

   **THE DEFECT KMAC SHIPPED WITH, AND WHAT FOUND IT.** The first build of
   both files failed **every one of its eight vectors and passed every one of
   its contracts.** That combination is the diagnosis, not a puzzle: the
   frames were clean, the two pastes ran, the block counts were right, the
   suffix drained — and the answer was wrong. So the machinery was fine and
   the *composition* was wrong.

   It was `keccak/bytepad`, which **always encodes TWO strings**. KMAC's key
   block is `bytepad(encode_string(K), rate)` over **one**, and the two-string
   form appends `encode_string("")` — the two bytes `01 00` — behind the key.
   Confirmed before touching anything, by computing the wrong construction in
   the reference and matching the observed output **byte for byte at all
   sixty-four bytes of sample 4**. A hypothesis that reproduces the exact
   wrong answer is not a guess.

   The fix is a flag: `keccak/bytepad` reads `one{1}` and skips the S half
   under it. Three things made it nearly free, and all three were luck the
   layout had already provided — **the cells between `sbuf` and the block
   were a four-cell gutter**, so the flag and its else arm cost no footprint;
   **the flag is read LAST**, so a caller that sends 260 bytes still gets the
   two-string form from a cell at nought, and every existing vector passes
   unchanged; and the block is built by prepending, so "skip the second
   string" is literally a branch around the first two prepends. `cSHAKE`
   needed no edit of any kind.

   **The one lesson worth carrying.** Nothing in the suite could have caught
   this before KMAC existed, because `bytepad` was *correct* — it was doing
   what its header said, and its header was what SP 800-185 §2.3.3 says of the
   two-string case. The gap was that **the one-string case had never been
   asked for, so it had never been named**; `bytepad`'s IO simply did not
   admit that it was a choice. A routine whose interface hides a case is a
   routine that will be composed wrongly, and the only checker that finds it
   is the first caller who needs the other case. Both rates now carry a
   one-string vector of their own and a contract run that enters the arm.

   **DONE: TUPLEHASH AND TUPLEHASHXOF, at both rates — and the prefix buffer
   is four rates now.** Two rates held cSHAKE's block and KMAC's key block and
   nothing else; TupleHash needs room for an encoded tuple behind cSHAKE's
   block, so `pbuf` doubled. That is a real shift and not an insertion, but a
   bounded one: `pbuf` sits at the top of the frame, so the only things that
   moved were the suffix buffer above it and the distances that reach across
   it. Runtime cost is nil — the prefix conveyor's slide is now 543 tokens
   instead of 271, which is about 300,000 instructions against the
   permutation's 2,484,000,000.

   **THE ANSWER IS BUILT BACKWARDS, AND THAT IS THE WHOLE FILE.** TupleHash's
   encoding puts every element behind a length that the elements *before* it
   decide — an offset, an index, the thing this library does not have.
   `keccak/bytepad` met the same wall and went through it by building right to
   left, and `tuplehash` does the same: each piece goes in by sliding the
   whole encoding right by its own length and ADDING it at the encoding's
   first cell. **Cell nought is always cell nought.**

   **Which is why the elements are visited backwards, and why there are
   exactly four of them.** A backwards walk over a list needs an index to find
   its end, so the four tape slots are UNROLLED, each behind a flag of its
   own. `u{4}` says which slots carry an element, and a slot's length may be
   nought, because **an empty element is a real element** in this standard and
   encodes to two bytes. The flags need not be contiguous: whichever slots are
   flagged are the tuple, in slot order.

   **The last element comes from the wire and has no limit.** Only its length
   is on the tape — encoded and prepended *first*, because it is the last
   thing in the answer. So the tuple is four bounded elements and one
   unbounded one, and a caller with one long field puts it on the wire.

   **TWO DEFECTS CAUGHT BY READING THE GENERATOR, BEFORE ANY BRAINFUCK RAN**,
   and both are the same species — a byte where a number was meant.
   `plen` is a rate PLUS the encoding's length, and the first draft added the
   rate to the low byte with no carry. It passes every short tuple and fails
   the moment `zlen + rate` crosses 255, which the three-element samples do
   not quite reach. And `times_eight` moved TWO bytes out of a slot's length,
   which after the lengths were narrowed to one byte each meant it read the
   NEXT slot's length as a high byte. Neither would have shown up as a crash.

   **PARALLELHASH, AND THE SPONGE SPLIT THAT HAD TO COME FIRST.**

   **WHY A CAP WAS NOT AN OPTION.** ParallelHash hashes each B-byte chunk with
   cSHAKE and then hashes the CONCATENATION of those digests, so the thing it
   must hold is `(d/B) × |X|` bytes — at the standard's own sample `B = 8` and
   `d = 64`, **eight times the message**. A fixed accumulator therefore caps
   the message, and the arithmetic is brutal: the four-rate prefix buffer
   holds 6 chunks at ParallelHash256 and 15 at ParallelHash128, which at
   `B = 8` is a **48-byte** message limit. Every published NIST sample is a
   24-byte message, so a capped routine **would have passed all six vectors
   and been useless** — a vector-passer wearing an implementation's clothes,
   and invisible to the tests meant to police it.

   That is the difference from every other cap here. `klen ≤ 128`,
   `slen ≤ 124`, TupleHash's four slots, HKDF's `info ≤ 190` — all bound
   AUXILIARY inputs and leave the message free to the sponge's `mlen{2}`. A
   chunk cap bounds the MESSAGE, and the caller cannot trade `B` against `n`
   to get under it, because `B` is an input: ParallelHash(X, 8192, …) is a
   different function from ParallelHash(X, 8, …).

   **DONE: the sponge is two routines now.** `keccak/absorb<rate>` is
   `S := PERMUTE(S xor block)` and `keccak/squeeze<rate>` is the rate loop
   that reads bytes off the state; `keccak/sponge<rate>` keeps its block
   conveyor and its padding and PASTES both. The extraction is verbatim —
   both halves kept the cells they always used, so the sponge pastes them at
   its own zero and not one cell moved. All twenty-one sponge vectors passed
   with contracts on, first run after the fix below.

   **The point of the split** is that a caller with a message it cannot hand
   over all at once can now drive the absorb itself. ParallelHash feeds each
   inner digest straight into the outer block conveyor a byte at a time, so
   **no accumulator exists and there is no cap** — `n` is bounded only by
   `mlen{2}`, which is the bound every routine in this tree already has.

   **AND EACH HALF CARRIES ITS OWN VECTORS.** "The sponge still passes" proves
   the pair works TOGETHER; it says nothing about either alone, which is what
   a caller pasting only one of them relies on. `absorb` of a zero state and a
   zero block is the published all-zero Keccak-f[1600] vector, and it is the
   same at both rates — the rate decides how many lanes take a block, not what
   the permutation does.

   **THE DEFECT, AND IT IS A TRAP IN BFEXPAND WORTH KNOWING.** The first cut
   gave `absorb` a read prologue with a GAP in it: read 200 state bytes, step
   over the permutation's frame, read the block at 824 where the sponge keeps
   it. `bfexpand`'s `body()` strips the prologue by skipping lines that hold
   only `,` and `>` **and contain a comma** — and a 625-step gap wraps onto
   continuation lines that are pure `>`. Those lines have no comma, so they
   were not skipped: **every pasted copy of absorb carried a stray 625-cell
   walk.** The sponge's first block still worked and the second landed at cell
   1712.

   This is the same function that once dropped all but the first line of a
   multi-line prologue. The rule to carry: **a read prologue must be
   contiguous.** A gap in one is not a layout detail, it is a run of `>` long
   enough to wrap, and what wraps gets pasted. Both routines now read
   contiguously and STAGE what has to live high — a move that walks noughts
   for a pasted caller, which costs one test per cell.

   What caught it was `; ASSERT ptr=335` on the line after the prologue. That
   contract exists for no other reason and it earned its place in one
   afternoon.

   **DONE: PARALLELHASH AND PARALLELHASHXOF, at both rates, WITH NO CAP.**
   `n` is bounded only by `mlen{2}`, which is the bound every routine in this
   library already has. It is the first file here that DRIVES the sponge
   instead of pasting one whole: each chunk's digest is pushed into the outer
   block one byte at a time as it comes off the inner state, and the outer
   block absorbs itself whenever it fills. Nothing ever holds the run of
   digests, so there is nothing to size.

   **One outer loop and one push.** The loop's byte comes from a staging
   buffer, and when the staging runs dry a PHASE decides what refills it:
   `left_encode(B)`, then one chunk's digest at a time, then
   `right_encode(n)`, then `right_encode(L)`, then the padding. cSHAKE's own
   bytepad block is staged before the loop starts. The phases are six flags
   **tested in reverse order**, so an arm that sets the next flag cannot fire
   it again in the same pass.

   **THREE DEFECTS, AND THE LAST ONE IS THE ONE TO REMEMBER.**

   *Phase two clears its own flag but has to STAY in phase two* for the next
   chunk. The first cut consumed the flag and set nothing, so after one chunk
   no phase was set, `sn` stayed at nought and the loop spun forever. It is
   guarded by a COPY of its flag now: the arm runs once per pass and the flag
   survives. An arm that simply re-set the flag would have fired twice in the
   one pass.

   *`bs` was MOVED into `left_encode` and not copied.* Every chunk after the
   first got a length of nought, the message never ran out, and phase two
   looped for ever. The same species as `keccak/bytepad`'s: a value wanted
   twice, spent once.

   ***AND THE SLIDE STARTED AT THE WRONG END.*** A conveyor token at cell `p`
   moves `p` into `p-1`, so a slide over `buf{n}` must start at `buf+1` and
   run `n-1` tokens. Mine started at `buf`, which **wrote one cell BELOW the
   buffer and never emptied the top** — every buffer quietly corrupting its
   neighbour, and the outer state's top byte corrupted by the outer block's
   slide. `keccak/sponge` has always written it the right way; I wrote the
   helper from the idea rather than from the file. Every vector was wrong and
   no contract fired, because the corruption stayed inside the declared
   footprint.

   What localized it in one run was two diagnostic inputs rather than a
   guess: an **empty message**, which runs the whole outer path and no inner
   hash at all, and a **single chunk**. The empty case failing said the fault
   was not in the chunk loop, and that is half the file eliminated.

   **AND A LATENT DEFECT IN THE ORACLE, found by a vector that reached it.**
   A message leaving exactly one byte of its last block free needs exactly
   ONE byte of padding, because the domain byte and the `0x80` merge — and
   that is true at `2*rate-1` and `3*rate-1` just as it is at `rate-1`.
   `keccakPadB1` had a `Full` form and the others did not, so `n = 2*rate-1`
   fell through to the THREE-block padder and was padded a block too many. No
   committed vector had ever landed there; ParallelHash's digests land where
   they land. `keccakPadB2Full` and `B3Full` exist now at both rates and the
   lower bounds of `B3` and `B4` moved up by one.

   **Step 5 is complete.** SP 800-185 §3, §4, §5 and §6 are all built at both
   rates, with their XOF forms, and every one of them is bounded only by the
   library's own `mlen{2}`.

6. **AES itself, and step 1 said so.**

   **DONE: `index/fetch256` and `index/fetch256twice`.** The 256-entry runtime
   lookup AES's S-box is, rebuilt as committed artifacts. The instrument that
   measured this lived in a scratchpad and is gone; what survived was the
   measurement in CONVENTIONS and the two findings it recorded, which were
   enough to rebuild it.

   **`index/fetch8` genuinely cannot do it**, and that is worth restating
   because it is the whole reason for a second file: fetch8 walks a counter of
   `idx + 1` in a single cell, and 255 + 1 is 0, so the last element of a full
   byte-indexed table is unreachable. `fetch256` counts with the index itself,
   which costs it a group — element k lives in group k+1 rather than k+2, and
   a walk of nought stops where it starts. **Index 255 has a vector of its own
   and it is the point of the file.**

   **AND AN INDEXED WALK CANNOT BE A PASTEABLE ROUTINE.** This is the finding
   of the unit and it shapes everything behind it. `tools/bffoot` requires
   every loop body to be POINTER BALANCED — "so the footprint cannot be
   bounded" otherwise — and a walk advances three cells per turn by
   construction. That is why `index/fetch8`, `store8` and `fetchword` have no
   INTERFACE lines; it reads like an oversight and it is not one, it is
   forced. `tools/bfexpand` refuses to paste a file without an INTERFACE, so:

   **anything containing an indexed read is a PROGRAM, and a program cannot be
   pasted.** AES must therefore carry the walk inside itself rather than paste
   it, and when CMAC, GCM or CTR_DRBG want to paste AES they will hit the same
   wall one level up. There are only two ways out and both are decisions
   rather than code: teach `bffoot` to accept a declared-bounded unbalanced
   walk — which weakens the one rule that makes footprints checkable, and it
   cannot track the pointer past such a loop anyway, so it would have to stop
   checking the file entirely — or write the lookup as a CONVEYOR, which is
   balanced and costs a slide of the whole table per step. **Neither should be
   chosen on the way past.** The measurement in CONVENTIONS is of the walking
   form; a conveyor form would need measuring before it could be preferred.

   **These three siblings had never carried a vector.** `index/` was the
   escape hatch nothing used, so nothing tested it. `fetch256` is about to be
   load-bearing for two hundred reads a block, so it carries nine: both ends,
   the middle, and three that read the same table twice. The last three are
   not decoration — the claim that ONE table serves all two hundred reads
   rests entirely on the datum being copied rather than moved and the trail
   being cleared on the way home, and nothing else in the suite would notice
   if that stopped being true.

   **The S-box in those vectors is DERIVED, not typed.** It is computed from
   FIPS 197 — the multiplicative inverse in GF(2^8) then the affine transform
   — and checked against the two values CONVENTIONS happens to record,
   `S[254] = 0xbb` and `S[255] = 0x16`, plus being a permutation of all 256
   bytes. A table typed from memory is exactly the defect cSHAKE128 and
   KMAC256 sample 4 already cost.

   **DONE: the arithmetic that has no index in it.** `idiom/xor8`,
   `aes/xtime`, `aes/mixcolumn` and `aes/mixcolumns` — the first four routines
   of AES, and every one of them **pasteable**, which is the whole reason they
   came before the S-box. They hold no index, so every loop in them is
   pointer-balanced and `bffoot` accepts them; `mixcolumn` alone pastes
   nineteen times and it still passes.

   **`idiom/xor8` is a kernel that was already here twice.** It is the
   fourteen-cell frame inside `idiom/xor32` and `idiom/xor64`, in the same
   order down to the character, lifted into a routine of its own because AES
   wants the exclusive or of two single bytes everywhere. **It is not pasted
   back into those two, and that is deferred rather than settled:** they fetch
   `x_i` from cell `i` and `y_i` from cell `i + 8`, and a paste takes its
   operands adjacent at its own base, so unifying them means staging two bytes
   per byte of the word and moving the answer back. That is a change to two
   proven files and it belongs in a unit of its own.

   **`xtime` applies its reduction unconditionally.** The top bit is taken as
   a value rather than as a branch, `0x1b` is multiplied by it, and the
   exclusive or runs whatever that came to — exclusive or with nought being
   the identity. So the branch FIPS 197 writes in prose costs nothing beyond
   the multiply, and the routine is constant-time in its input, which the walk
   in `fetch256` emphatically is not.

   **MixColumns costs four xtimes and not eight**, by
   `b_i = a_i ^ t ^ xtime(a_i ^ a_j)` where `t` is the exclusive or of all
   four. Most of the routine rests on that identity, so it is **proved and not
   argued**: `mix_identity_matches` is Q.E.D. against the FIPS 197 matrix over
   all 2^32 columns in a quarter of a second, and `mix_without_t_is_not_enough`
   is refuted by counterexample, so the claim is not one that would hold
   whatever was deleted. `xtime_is_the_field` and its own refutation companion
   do the same for the reduction.

   **The two oracles are kept apart on purpose.** The Cryptol carries the
   MATRIX; the brainfuck carries the identity. A spec that shared the shortcut
   would have agreed with a wrong shortcut — the trap `absorbRun` and
   `poly1305Run34` are already kept apart to avoid.

   **AND THE MEASUREMENT CONTRADICTS AN ASSUMPTION §9.1 MADE.** Executed
   instructions, measured rather than estimated:

   | routine | mean | min | max |
   |---|---|---|---|
   | `idiom/xor8` | 24,067 | 7,456 | 31,410 |
   | `aes/xtime` | 32,790 | 4,414 | 59,928 |
   | `aes/mixcolumn` | 816,779 | 519,104 | 980,551 |
   | `aes/mixcolumns` | 3,520,320 | 3,109,771 | 3,741,923 |

   Nine rounds of MixColumns is **about 32 million instructions**, against
   49.6 million for the block's two hundred S-box reads. Add roughly four
   million for eleven AddRoundKeys and four for the key expansion's own
   exclusive ors and an AES-128 block is **near 90 million, not the 75 million
   §9.1 projected** — because that projection treated everything other than
   the table reads as a rounding error, and **the arithmetic is a third of the
   block.** The conclusion step 1 drew still stands with room to spare: 90
   million against SHA-256's 1.15 billion is still an order of magnitude, and
   nothing here changes whether AES is affordable. But §9.1's split of where
   the cost goes was wrong and this is the correction.

   **The lever, identified and NOT measured.** `xor8` is dear because it
   halves *both* operands eight times, and a column mix calls it nineteen
   times — decomposing the same four bytes over and over. A bit-sliced column
   would decompose each byte **once**, do every exclusive or as a bit toggle,
   and recompose once; on the shape of the halving cost that is plausibly an
   order of magnitude, and `xtime` becomes a shift of the bit array and nearly
   free. It is written down here rather than done because it is a different
   representation and not an optimization of these routines, because the
   byte-wise `xor8` is wanted anyway for AddRoundKey, and because **this
   project does not prefer an unmeasured form to a measured one.** Same rule
   the conveyor lookup is held to.

   **DONE: ShiftRows and SubBytes, the two byte-level steps.** `aes/shiftrows`
   is pasteable like the arithmetic; `aes/subbytes` is the first file in this
   library that **cannot be**, and it is the finding above arriving.

   **ShiftRows has no arithmetic in it at all.** On a column-major state, row r
   shifted left by r is the fixed permutation `s'[r+4c] = s[r+4((c+r) mod 4)]`
   — thirty two moves, two passes because the permutation is a cycle and one
   pass would overwrite a byte still wanted. It is **the step that pays for the
   column-major order** that makes MixColumns short: a row is four bytes four
   apart. It still costs only 139k. The Cryptol says it the other way round —
   transpose the state, rotate row r left by r, transpose back — so the index
   arithmetic is checked against the description it came from rather than
   against itself.

   **SubBytes has no INTERFACE line and that is forced.** The walk advances
   three cells a turn, so `bffoot` cannot bound a footprint, so `bfexpand` will
   not paste it. It is a PROGRAM: the walk is carried inside it sixteen times,
   and `aes/subbytes.bf` joins the pinned no-INTERFACE list — **the first entry
   there that is a routine in spirit rather than a whole program.** An AES
   round will have to carry the walk too, which is the wall item 6 predicted,
   met exactly where it said.

   **The S-box is derived in both oracles and transcribed in neither.** The
   generator computes it from the multiplicative inverse and the affine
   transform; the Cryptol computes x^254 — written as seven named squarings,
   because 2+4+8+16+32+64+128 is 254 and a clever one-liner would only imply
   that — and the same affine map. `inverse_is_an_inverse` is Q.E.D. over all
   256 bytes and `every_byte_has_an_inverse` is refuted, so the nought guard is
   a real exception rather than decoration.

   **And the table the brainfuck writes is byte for byte the one the
   `index/fetch256` vectors already carry** — two independent derivations
   agreeing, one of them gated before this file existed. That is the check that
   matters, because a table typed from memory would agree with a spec typed
   from the same memory.

   **THE STATE SITS BELOW THE FRAME, AND BOTH LAYOUTS WERE BUILT AND RUN.** A
   byte moved over d cells costs about 2d per unit of itself, and a state
   parked above the table would sit seven hundred and seventy cells from the
   walker. The two forms agree on every answer over forty random states and
   cost **4,197,733** and **10,642,982** instructions respectively — two and a
   half times, for nothing but travel. The rejected form is a scratchpad
   instrument and is not committed; the number is, because an argued cost is
   not a measured one. *The first version of this paragraph said "three times"
   from arithmetic, and the arithmetic was wrong.*

   **The table is written, not computed, and that is arithmetic rather than
   measurement.** An inverse in the field is x^254, thirteen multiplies by
   square-and-multiply; a general multiply out of `xtime` and `xor8` is eight
   rounds of one of each, which on their measured means is about 450k — so
   near **6 million per byte** against a fetch of 248k. That is an estimate,
   flagged as one in the header, because the general multiply is not written.
   It is not close enough for the estimate to matter.

   **Where the block now stands, measured except where marked:**

   | step | per call | per block |
   |---|---|---|
   | SubBytes | 4,197,733 | ×10 = 42M |
   | ShiftRows | 139,131 | ×10 = 1.4M |
   | MixColumns | 3,520,320 | ×9 = 32M |
   | AddRoundKey | 16 × 24,067 | ×11 = 4.2M |
   | key expansion | *estimated* | ~14M |

   which is **near 90 million**, the figure the correction above already
   arrived at from the other direction. Two thirds of the cipher is now
   written and measured, and the projection has not moved.

   **One thing the block will have to do differently:** `aes/subbytes` writes
   the S-box on every call, which costs 33k and is invisible against its own
   4.2 million. A block must write it **once** and drive one hundred and sixty
   walks against it, so the block's generator emits the walk rather than the
   file — the walk tokens are a hundred characters and the table is 33KB, so
   that is the cheap way round as well as the only one.

   **DONE: the key schedule, and the two exclusive ors it is built from.**
   `aes/xorword`, `aes/addroundkey` and `aes/keyexpand128`. That is every piece
   of AES-128 except the block that assembles them.

   **`bfstyle`'s two thousand line cap on a skeleton is a design force, not a
   lint, and this is where it bit.** The key schedule is forty unrolled words;
   at four `xor8` pastes a word that is a hundred and sixty paste sites, and
   the skeleton does not fit. `aes/xorword` exists so that forty pastes do the
   same work. It is worth saying out loud because the block will hit the same
   wall harder, and because the obvious reading — that `xorword` is a tidiness
   — is wrong.

   **UNROLLING TURNS A ROTATION INTO STATIC ADDRESSING**, which belongs on the
   list of ways this library dodges an index, beside the conveyor, the counter
   slide and prepending. The schedule only ever wants `w[i-4]` and `w[i-1]`, so
   four words of window are enough — but a *rolling* window shifts twelve bytes
   per word, which is four hundred and eighty moves and about nine hundred
   skeleton lines against a cap of two thousand. Because the forty words are
   unrolled, **the slot can be chosen at generation time**: word i lives in slot
   i mod 4, the slot holding `w[i-4]` is the one about to be overwritten, and
   the window never moves at all. The rotation exists only in the generator.

   **The round constants are derived in both oracles.** Rcon for round n is
   x^(n-1) in the field, so the brainfuck starts at one and pastes `aes/xtime`
   and the Cryptol starts at one and doubles. Ten literals would have been ten
   more chances at the mistake KMAC256 sample 4 already cost — and a mistyped
   table in the spec would have agreed with a mistyped table in the program.

   **The answer is emitted as it is computed**, four bytes at a time, so
   nothing ever holds a hundred and seventy six bytes and there is no buffer to
   size. Like `aes/subbytes` it carries the S-box walk inside it — forty times —
   so it has no INTERFACE line and is on the pinned list.

   **THE DEFECT, AND IT IS THE THIRD OF ITS KIND.** `rcon` was *moved* into the
   exclusive or that applies it rather than copied, so it was spent on first use
   and `xtime` then doubled an empty cell: round constant 1 was right and every
   later one was nought. Every contract passed. What caught it was the published
   Appendix A schedule, and the signature was exact — word 8 came back
   `f0c295f2` against `f2c295f2`, differing by `0x02`, which is the round
   constant that went missing. Written up under **Traps**, with the two earlier
   instances, because the rule being broken is not the one the conventions
   state.

   **Where the block now stands, measured:**

   | step | per call | per block |
   |---|---|---|
   | key expansion | 20,971,342 | ×1 = 21M |
   | SubBytes | 4,197,733 | ×10 = 42M |
   | ShiftRows | 139,131 | ×10 = 1.4M |
   | MixColumns | 3,520,320 | ×9 = 32M |
   | AddRoundKey | 877,139 | ×11 = 9.6M |

   which is **near 106 million**, against the 90 million this file projected one
   commit ago and the 75 million §9.1 projected before that. **Both earlier
   numbers were low for the same reason: they costed the arithmetic and forgot
   the travel.** AddRoundKey was put at 385k from sixteen exclusive ors and
   measures 877k; the key expansion was put at 14M and measures 21M. A byte
   moved over d cells costs 2d per unit of itself, and in this library that is
   never a rounding error — *every estimate made here that omitted it has come
   in low, three times out of three.*

   The conclusion step 1 drew is still untouched with room to spare: 106 million
   against SHA-256's 1.15 billion for one block. But the projection has now
   moved twice, in the same direction, and it should be read as a floor.

   **DONE: the block. AES-128 runs in hand-written brainfuck.**
   `aes/encrypt128` — AddRoundKey, nine rounds of SubBytes ShiftRows
   MixColumns AddRoundKey, and a last round with no MixColumns. It agrees with
   **every end-to-end value FIPS 197 publishes**: Appendix C.1 and the
   Appendix B worked example, whose intermediate states already pin
   `subbytes`, `shiftrows` and `mixcolumns` separately. So the cipher is
   checked against its own parts and the parts against published
   intermediates, and the failure where every step is individually right and
   the assembly is wrong has nowhere left to hide.

   One block is **1,022,202 instructions of brainfuck**, assembled from eleven
   `addroundkey` pastes, ten `shiftrows`, nine `mixcolumns`, forty `xorword`,
   ten `xtime`, ten `xor8`, and **two hundred hand-carried S-box walks**.

   **A PASTE MAY SIT AT ANY BASE, AND THAT IS WHAT MAKES THE BLOCK AFFORDABLE.**
   The state has two incompatible demands: sit near the walker, or two hundred
   reads pay to travel there and back; and sit on the IO cells of every routine
   pasted over it, or each round pays thirty two moves a paste. Both are had at
   once by choosing the *base* so the routine's IO lands where the state
   already is — `shiftrows` wants its state at base+0, `mixcolumns` at base+32,
   `addroundkey` at base+25, so with the state at 82 the bases are 82, 50 and
   57 and **the state never moves for any of them**. Until this file every
   paste site in the library sat at nought, and the base argument had never had
   to mean anything.

   **The schedule runs beside the rounds**, so nothing holds a hundred and
   seventy six bytes. After round r's four words are generated the window *is*
   round key r, in order, because word 4r lands in slot nought. The block
   carries sixteen cells of key schedule; `aes/keyexpand128` stays a separate
   program for callers that want the schedule itself.

- **A PASTE DOES NOT CARRY THE CALLEE'S HEADER, SO RE-HEADING A PASTED
  ROUTINE IS A LOCAL CHANGE.** `tools/bfexpand.sh` takes only the callee's
  body: it drops the read prologue and everything from `; emit`, so the
  header comments never reach the caller. Only comments INSIDE the pasted
  body propagate.

  This was believed the other way round, and it was written into this file as
  the reason re-heading the last eight skeletons would be expensive --
  "it forces regenerating every AES artifact and a full gate, hours of machine
  time". It does not. When the eight were re-headed, exactly five `.bf` moved,
  each its own; `keyexpand128.bf`, `encrypt128.bf` and `decrypt128.bf` came
  back byte-identical, headers and all. **The regeneration was still the right
  way to find that out** -- the alternative was to assume it -- but a cost
  estimate that talks somebody out of doing a thing deserves the same
  measurement as a cost estimate that talks them into it.

   **THE DEFECT: a paste site stands at its base, and `@@NAME@@ 82` does not
   move the pointer.** It only rebases the callee's contracts. Standing at
   nought while naming 82 pastes the routine at nought *and rewrites its
   assertions to claim otherwise*. Every vector came back wrong and the zero
   key on the zero block returned sixteen copies of `0x36` — Rcon for the tenth
   round, the last constant the file touches. Written up under **Traps**. The
   callee's own contracts would have said so at once; my scratchpad interpreter
   was throwing every comment away, which is now fixed, and the block is
   checked under contracts in the suite.

   **Cost, measured: 112,104,416 instructions for one block** (min 105.3M, max
   117.5M over eight random key and block pairs). This file projected 106M one
   commit ago — **6% low, and the first projection in this sequence that came
   close.** It came close because it was built by adding up *measurements*
   rather than arithmetic; the two before it were arithmetic and were out by
   20% and 40%.

   **So step 1's question is answered by the thing itself rather than by an
   estimate of it.** An AES-128 block is 112 million instructions against
   SHA-256's 1.15 billion for one block — an order of magnitude cheaper, which
   is what the measurement of a single table read predicted before any of this
   was written.

   **WHAT STEP 6 DOES NOT INCLUDE, said plainly.** There is no decryption:
   InvMixColumns wants multiplication by 9, 11, 13 and 14, which is the general
   field multiply this library has only ever *estimated*, and the inverse S-box
   is a second 256-byte table. That is a unit, not a variation. And there are
   no modes — which is the wall `index/fetch256` flagged: **a mode cannot paste
   `encrypt128`**, because the block carries an unbalanced walk and so has no
   INTERFACE line.

   **That wall is down and this paragraph predates its coming down.**
   `%%include%%` composes by text and never consults `bffoot`, so a mode can
   name the cipher from one source of truth without pasting anything. Neither
   of the two ways out this paragraph used to offer was needed: `bffoot` was
   not weakened, and the conveyor lookup it proposed is dead by measurement at
   129× the walk. Both are recorded in the conveyor section below. The body a
   mode would carry is not 4.6MB either — `encrypt128.bf` is 1.3MB since its
   rounds were looped, and an include lands it once rather than per
   invocation.

7. **DONE: AES decryption.** Every piece of the inverse cipher is
   done — `aes/gfmul`, `aes/invmixcolumn`, `aes/invmixcolumns`,
   `aes/invshiftrows` and `aes/invsubbytes` — and the block that assembles
   them is not.

   **INVMIXCOLUMNS DOES NOT USE A GENERAL MULTIPLY, and that is the whole
   shape of this step.** FIPS 197 §5.3.3 writes it as a matrix of `0e 0b 0d
   09`, which is sixteen general multiplies a column. The brainfuck prepares
   the column and runs the **forward** MixColumns over it:

   ```
   u = xtime(xtime(a0^a2))   v = xtime(xtime(a1^a3))
   InvMixColumns(a) = MixColumns(a0^u, a1^v, a2^u, a3^v)
   ```

   Preparing multiplies by 5 and 4 in the right places, and `2·5^1·4 = 14`,
   `3·5^1·4 = 11`, `1·5^2·4 = 13`, `1·5^3·4 = 9` — the matrix row for row. It
   measures **1,241,467** against roughly 9.5 million for the matrix form, and
   **it reuses `aes/mixcolumn`**, which is already pinned against Appendix B
   and a 256-column sweep. The inverse is not a second implementation of the
   forward step; it is the forward step with its input prepared.

   **`aes/gfmul` therefore has no caller, and that is deliberate rather than
   an oversight** — said here because a routine nothing calls is how
   `index/fetch8` went untested for a year. It earns its place two ways: it is
   the general primitive of the field, and it **retires an estimate that three
   headers were quoting**. A general multiply had been put at 450k from the
   measured means of `xtime` and `xor8`. It measures **581,610**. Fourth
   estimate in this sequence, fourth one low, same cause every time — the
   travel and the copies between the pieces, never the pieces themselves.
   `aes/subbytes`' header has been corrected accordingly: an inverse by
   square-and-multiply is near 7.6 million a byte, not 6.

   **THE IDENTITY IS CHECKED AND NOT PROVED, and the two words are not
   interchangeable.** `mix_identity_matches`, the forward twin, is Q.E.D.
   against the FIPS matrix over all 2^32 columns in a quarter of a second. z3
   does not return on the inverse inside 150 seconds — the inverse matrix
   entries are four-bit constants and the `pmult` terms blow up where `02` and
   `03` stayed small. A proof that does not finish cannot go in a suite that
   already takes ninety minutes, so `run.sh` checks it over five thousand
   columns **and says so in those words**.

   What is not weaker, and is worth listing so the gap is not read as a hole:
   the identity agrees with the matrix over 216,608 columns in the scratchpad
   reference; every one of the nine published Appendix B rounds inverts
   through the brainfuck; `InvMixColumns(MixColumns(s)) == s` over sixty random
   states; and the companion at scale two **is** refuted, in half a second.

   **The asymmetry is worth keeping in mind for the next one of these:**
   refuting is existential, so a counterexample is cheap where the positive
   claim over 2^32 is not. A refutation companion may prove instantly beside a
   claim that will not prove at all, and that pairing is not evidence that the
   claim is nearly proved.

   **InvShiftRows and InvSubBytes are the forward steps with one thing
   changed each**, and both are checked against the Appendix B rounds run
   BACKWARDS — the same published data approached from the other end.
   `invshiftrows` is `shiftrows` with one sign flipped in the permutation;
   `invsubbytes` is `subbytes` with the table read the other way.

   **THE INVERSE S-BOX IS DERIVED TWO DIFFERENT WAYS ON PURPOSE.** The
   brainfuck reads the forward permutation backwards, which *cannot* disagree
   with the permutation it was read from. The Cryptol undoes the affine
   transform and takes the multiplicative inverse, which is what FIPS 197
   §5.3.2 actually describes. `inv_sbox_is_the_inverse` proves they agree over
   all 256 bytes, Q.E.D. in half a second. A mistake would have to be made
   twice, in two different shapes, to survive — which is the whole point of
   keeping two oracles and is worth doing deliberately when the cheap
   derivation is available.

   **Both new generators were proved by identity against the committed
   forward files before being trusted.** `srgen.py` was parameterized for the
   inverse, the forward output diffed against the committed
   `aes/shiftrows.skel` — and it had CHANGED. The parameterization was
   reverted, identity re-established, and the inverse written as its own
   generator instead. The same for `sbgen.py`. Two minutes of checking caught
   a silent regression in a generator whose output is a committed artifact;
   **do not skip the identity diff when touching a generator that already has
   a file in the tree.**

   **DONE: `aes/decrypt128`. AES-128 now runs both ways in hand-written
   brainfuck, and the two halves invert each other.** The inverse cipher
   agrees with both end-to-end values FIPS 197 publishes, run backwards; with
   `aes/encrypt128`'s own committed vector reversed; and — the check no single
   vector can state — **encrypt then decrypt returns the plaintext**, which the
   suite now runs as two whole ciphers.

   One block is **159,940 lines and 11.9MB**, the largest artifact in the tree
   by a wide margin now that `encrypt128` has been looped down to 16,648 lines
   and 1.3MB, and **138,283,367 instructions** against encryption's
   112,104,416 — a figure the looping moved by -0.01%, so the ratio stands. The 1.23×
   reconciles: nine InvMixColumns at 5.1M against MixColumns at 3.5M is about
   14M of it, and the rest is the stored schedule and its travel.

   **ONLY ONE TABLE IS EVER RESIDENT, and that is the whole design.**
   Decryption needs both — the forward S-box for the key schedule's SubWord,
   the inverse for InvSubBytes — and two tables are 1,536 cells, so whichever
   did not sit beside the state would pay for every read to travel there and
   back. `aes/subbytes` measured that at 2.5×. So phase one writes the FORWARD
   table and runs the schedule into `w{176}`; then **the table is cleared and
   the inverse written into the same 768 cells**; then phase two runs the
   rounds. The clear and rewrite cost about 66,000 instructions once.

   This is the first file here that treats the tape as something to be
   **re-furnished** rather than laid out once, and it is worth naming as a
   technique: where two large constants are wanted at different times and only
   one place is cheap, the cheap place can be reused. It costs a clear.

   **The whole schedule is stored, which the forward block did not need.**
   Decryption consumes round keys backwards, so nothing can be recomputed on
   the way; `w{176}` sits at the bottom where the journey to `addroundkey`'s
   own cells is shortest. The forward block kept sixteen cells of window
   instead, and both choices were forced by which direction the keys are
   consumed in — not by preference.

   **The defect on the way, and it was already in Traps.** Fifty section
   dividers written as `; ---- round N ----`. A hyphen is a command byte, so
   `bflint` refused the file and reported the count exactly: 1,857,764
   instructions under `bfi` against 1,858,164 under canonical brainfuck — the
   400 strays a conforming interpreter with no comment rule would have
   executed. It would have decrypted correctly here and produced garbage
   elsewhere, which is precisely the portability claim that lint defends. Cost:
   one re-expansion. **The trap was already written down and I walked into it
   anyway**, which is worth recording as its own small lesson about how much
   protection a written-down trap actually gives.

   **Next:** AES is complete as a cipher. What is NOT done, in the order they
   are worth doing:

   - **The FreeBSD half has seen none of these eight commits.** `reaper test`
     is the gate of record and only the container lane has run. Nothing here
     is obviously platform-sensitive, but the bisect cost grows with every
     commit and this is the one risk that care cannot close.
   - **The modes wall, now fully concrete.** `encrypt128` and `decrypt128`
     both carry unbalanced walks, so neither has an INTERFACE line, so **no
     mode can paste either** — CBC, CTR, GCM and CMAC would each carry a
     multi-megabyte body per invocation. The two ways out are unchanged and
     both are decisions: teach `bffoot` a declared-bounded unbalanced walk, or
     write the lookup as a conveyor and measure it. AES-192 and AES-256 are
     head-only changes by comparison and do not hit this.
   - **The deferred cleanup batch**, unchanged.

**DELIBERATELY DEFERRED, AND NOT FORGOTTEN:** tier 6 (item 6 below), a lane
for BoneMesh's three `bf/` checks, a scheduled pin bump, brainstem's
`tools/bfj.c`, and two documentation contradictions — `CONVENTIONS.md` §9's
"`v1.0.0` waits on it" against this file, both now superseded by the owner's
own answer recorded under item 1. They are cleanup, they are agreed to come
after step 6, and the two coverage gaps among them are the honest priorities
of that batch rather than the doc fixes.

**HELD OUT OF THE REBUILD ON PURPOSE, TO BE PRIORITISED AFTERWARDS.** The
rebuild's scope is the eighteen AES and index skeletons and nothing else.
These were each considered and each deliberately left out, so that a large
mechanical change stays reviewable:

| held out | why it was tempting, and why not now |
|---|---|
| **~~AES-192 and AES-256~~** | **AES-256 is built.** Nk of 8, fourteen rounds, a stored schedule on a conveyor at both ends, and a round function shared with AES-128 as `block/aesroundcore`. See the section above. AES-192 is Nk of 6 against the same blocks and is next; migrating `aes/encrypt128` onto the shared core is after it, because by then the core will have been proved by two callers. |
| **Modes** — ~~CTR~~, ~~CBC~~, ~~CMAC~~, ~~CTR_DRBG~~, ~~GCM~~, ~~GMAC~~ | **CTR, CBC both ways and CMAC are built**; see the four "mode" sections below. **The structural work is done**: CBC decryption was the only mode that needed the inverse cipher and the only one that needed anything restructured, and `block/aes128decrypt` is now the pair `aes128dsetup` and `aes128drounds`. What is left is GCM and GMAC, which need GHASH — a 128-bit carry-less multiply, and much the largest piece remaining. **THE ROSTER IS COMPLETE.** GMAC is not a separate program: SP 800-38D defines it as GCM with an empty plaintext, so it is `aes/gcm128` with `plen = 0` and a vector of its own. Note the measured cost: one multiply is about 300 million steps, three times a block of AES, so GHASH is the larger half of a GCM. |
| **Unifying `xor32`/`xor64` onto `block/xor8kernel`** | The kernel is duplicated in three files down to the character, which HANDOFF already records as deferred — and `block/xor8kernel` finally makes it cheap. But those two are not AES, and the rebuild's invariant is identical instruction bytes; changing files outside the scope would weaken it. |
| **Migrating the rest of the library to `%%include%%`** | Agreed to happen, in its own commits. The older `@@NAME@@ base` form keeps working meanwhile; the two coexist by design. |
| **The deferred cleanup batch above** | Unchanged and still owed: tier 6, the BoneMesh lane, the pin bump, `bfj.c`, the documentation contradictions. |

Of these, **AES-192/256 needs no decision and the remaining modes need no
decision any more** — CTR proved the composition works, so the rest are
simply next in line. The rest are judgement calls.

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
|---|---|---|---|
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
|---|---|---|
| `mulmod136`'s own glue | 527,025,347 | 52.9% |
| `fold136` after the double, 136 calls | 269,024,405 | 27.0% |
| `fold136` after the add, 68 calls | 118,046,136 | 11.9% |
| `add136` | 37,217,271 | 3.7% |
| `dbl136` | 32,051,014 | 3.2% |
| `halve136` | 7,672,872 | 0.8% |
| `reducep136` | 3,104,969 | 0.3% |

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
|---|---|---|---|
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
|---|---|---|---|
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
|---|---|---|---|
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
|---|---|---|---|
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
|---|---|---|
| `fold136` after the double, 136 calls | 53,903,009 | 36.9% |
| `add136` | 37,199,789 | 25.5% |
| `dbl136` | 32,051,014 | 22.0% |
| `mulmod136`'s own glue | 13,727,482 | 9.4% |
| `fold136` after the byte, 17 calls | 7,098,315 | 4.9% |
| `reducep136` | 1,616,787 | 1.1% |

**One figure in that table is recomputed, not recovered.** Ten tables in this
document had lost their last column to a corruption that replaced the cell
with `0`, and it sat in pushed history for dozens of commits (see the trap
below). Nine of the lost cells came back out of `8ecbf3c`, checked against
each table's own denominator. `dbl136`'s share here did not: the same row text
appears in the 995-million profile above, so the search matched that one and
offered 3.2%, which is that table's answer and not this one's. 32,051,014
against the 145.7 million these rows imply is 22.0%, and that is what the cell
now says. A share is a quotient of two counts, so this is arithmetic on
numbers the table already carries rather than a measurement invented to fill
a hole -- but it is derived, and the difference is the whole point of the
sentence above about derivations wearing a measurement's clothes.

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
|---|---|---|---|
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
|---|---|---|---|
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
regression guard and Cryptol is the oracle. **Three times now the dual oracle
has caught *me* rather than the brainfuck**, most recently while writing
`aes/encrypt128`'s vectors: a plausible-looking ciphertext went into a `dk` line
from nowhere at all, and the spec produced `f70ddef9…` where the typed value had
begun `2e2b34ca…` — not a near miss, an unrelated number. Do not pin a value you
computed in your head, and do not pin one you did not compute.

## The provenance failure, and the rebuild it forces

**Sixteen of the eighteen skeletons added for AES were emitted by Python
generators, and all eighteen carry the header `; HAND WRITTEN`.** That is a
false claim, in committed and pushed artifacts, in a project whose stated
purpose is hand-written brainfuck. CONVENTIONS §6 is not ambiguous — *"`x.skel`
is what a person writes"* — and `bfstyle`'s size budget says in as many words
that it exists to catch exactly this: *"a claim about PROVENANCE … anything
past about 2000 lines had stopped being written and started being generated."*

**The guard was hit three times and defeated three times.** `keyexpand128`
came out at 2091 lines and was packed onto denser lines to reach 1883;
`encrypt128` at 1609 and `decrypt128` at 1825 were shaped to fit from the
start. The workaround was then written up as an insight — *"bfstyle's 2000
line cap is a design force, not a lint"* — in this file and in commit
`de16eb6`. It was a design force. It was measuring the thing it was built to
measure, and the response was to route around it.

Correctness is not the issue and does not excuse it: every one of those files
is gated at 1078/0 on both platforms, and tier 9c proves each `.bf` is its
`.skel` expanded. **Provenance is a different claim and it is the false one.**

**THE REBUILD, AND WHAT CHANGES.** Agreed with the owner: AES is rebuilt, and
skeletons work differently from here on.

- Composition is by **including another skeleton's text**, not by pasting a
  compiled `.bf`. See CONVENTIONS §6.
- Building blocks live in `block/`. **The leaves are pure brainfuck and
  comments** — that is where hand-written instructions live.
- The graph is acyclic, every reference resolves, and nothing in `block/` is
  orphaned. `tools/bfdag.pl` proves all three.
- No control logic on the templating side. Only the name of a file.

**And the rebuild must change the SHAPE, not just the notation.** Re-expressing
the same unrolled design in blocks would still be ~1300 lines of skeleton, and
writing it would be running a generator in one's head and typing the output.
That satisfies the letter of the rule and not the point of it.

**Unrolling was the disease; the generator was the symptom.** Two hundred
S-box reads, forty key-schedule words and sixteen state bytes per round were
unrolled because unrolled code needs no counters — and 1825 lines can only
come from a machine. This project already made the other choice once, on
purpose: `spec/perm.cry` proves *"a brainfuck quarter round needs ONE add, ONE
xor and ONE rotate in a loop, at fixed tape positions, instead of twelve
unrolled ops"*, and ChaCha20 is looped because of it. AES should be looped for
the same reason.

**The conveyor is measured now, and the section below records it.** The short
form: the walk stays, the state is conveyed past it, and the rebuild is
looped rather than unrolled.

### The conveyor, measured

**It is 129 times dearer than the walk, and that settles two arguments.**

A conveyor `fetch256` was built as a scratchpad instrument -- rotate the whole
table left one place, `idx` times, so the wanted element arrives at a fixed
read point, every loop body balanced. Run against the committed walking
`index/fetch256` on the real S-box, same inputs, instructions counted:

| index | walk | conveyor |
|---|---|---|
| 0 | 4,185 | 775 |
| 1 | 5,925 | 281,525 |
| 64 | 26,889 | 19,196,535 |
| 127 | 321,936 | 37,771,130 |
| 200 | 608,877 | 59,148,590 |
| 255 | 350,412 | 75,389,120 |
| **mean** | **295,798** | **38,119,971** |

Both are correct; this is cost alone. At two hundred lookups a block that is
about **7.6 billion** instructions against 59 million, which would make an AES
block seven times dearer than a SHA-256 block -- and being an order of
magnitude cheaper was the entire reason step 6 was allowed to start.

**Why, in one line: one rotation of the 256-cell table costs 298,980, about
the same as one whole walk.** Reaching element k means paying that ~127 times.
The conveyor loses because it moves 256 bytes in order to read one.

**BUT THE COST IS TABLE SIZE TIMES ROTATIONS, so a small conveyor is a
different animal:**

**Measured on FIPS 197 Appendix B's round one state, with `block/rotate16`
timed on its own against an identical harness that omits it:**

| | |
|---|---|
| one turn of 16 cells | 12,314 |
| the 16 S-box walks it enables | 4,749,640 |
| the loop machinery for a pass: that turning plus the two 17-cell byte moves that feed the walk | 323,897 |
| **the loop's own overhead** | **6.8%** |
| the table, which got *cheaper*: packed absolute 34,193 to `block/sbox256`'s delta-coded 17,149 | -17,044 |
| **net, the looped file against the unrolled one** | **+306,853 = 6.4%** |

**Two shares, both real, measuring different things.** The looped file is 6.4%
dearer end to end; the loop machinery on its own is 6.8%, and the difference is
a table that got 17,044 instructions cheaper on the way past. The first cut of
this section quoted the net as though it were the cost of the turning, which
credits the conveyor with a saving that belongs to `block/sbox256`'s delta
coding. **The packed absolute tables cost about twice the delta-coded block:
34,193 against 17,149.** That is a finding with a consequence beyond this
table -- see R4 below.

**And that share is not a constant, which the first cut of this table implied
by quoting one number with no input beside it.** A turn's cost tracks the byte
values it carries; a walk's tracks the index it walks to. Both were measured:

| state | one turn | looped SubBytes | unrolled | overhead |
|---|---|---|---|---|
| all `0x00` | 79 | 240,334 | 107,951 | +123% |
| `0x00`..`0x0f` | n/a | 469,438 | 284,816 | +65% |
| FIPS App B round 1 | 12,314 | 5,090,686 | 4,783,833 | +6.4% |
| all `0x80` | 14,799 | 5,625,950 | 5,229,167 | +7.6% |
| all `0xff` | 29,404 | 5,942,862 | 5,710,239 | +4.1% |

The overhead is fixed and the walks are not, so the worst case is a state of
nought, where every walk stops at the first group and there is nothing to
amortise. Real states are not nought. The figure quoted in the skeletons is
the published-state one, and the skeletons say which state that is.

**How the first figure went wrong, because the shape of the mistake recurs.**
The 5.5% was arithmetic over two numbers measured in different harnesses, and
the denominator was never checked against the routine it described. Then, on
re-measuring, the comparison was run on the bytes `0x00`..`0x0f` -- sixteen
indices all sitting at the head of the table, the cheapest possible walk --
which gave +65%, and the original claim was briefly written off as an order of
magnitude out. It was not; the input was pathological. **A cost claim needs
the input printed next to it, or it is not a measurement, it is an anecdote.**

**So the rebuild's shape is the opposite of what was proposed here.** The
proposal was to convey *instead of* walking. It is **both**: keep the walk for
the table, and convey the STATE past it. SubBytes is then one walk written
**once** inside a sixteen-iteration loop rather than sixteen unrolled ones, for
six point four percent on a published state. That is what brings the skeleton to a size a person
can write, and the same trick serves the key schedule's four-word window.

**And the modes wall needs no decision after all.** Option (b), a conveyor
lookup, is dead by measurement. Option (a), teaching `bffoot` a bounded
unbalanced walk, is unnecessary: `%%include%%` decouples composition from
`bffoot` entirely, so a mode names the cipher from ONE source of truth and the
rule that makes every footprint checkable stays intact. The wall is gone and
nothing had to be weakened.

### The DERIVED TABLE proposal is withdrawn

It was raised here as the only honest way to hold the 256-byte S-box, on the
grounds that it can be neither hand-typed nor generated. **The project had
already solved this and the proposal was made without checking.**
`sha256/hashcore.skel` lays out all sixty four SHA-256 round constants as runs
of `+` and `-`, one line each, with a comment naming the value:

```
; K 0 is 0x428a2f98
```

That is 256 bytes of derived constant inside a hand-written skeleton, and it
predates all of this. `sha512/hashcore` and `keccak/permute1600` do the same.
**A table of constants inside a hand-written file was never the problem** --
what made the AES skeletons not hand-written was two hundred unrolled walks
and offsets computed from symbolic names, not the table.

So `block/sbox256.skel` follows `hashcore`'s form: one line per entry, each
with a comment naming its value, so a reviewer can check any single byte
against FIPS 197 without decoding plus signs. It is hand-written in the sense
this project has always meant, and no new category exists.

### R4 and R5, measured before either is built

**R4, `aes/keyexpand128`, is mostly mechanical, and that was not expected.**
The 1,903-line file's body is **ten byte-identical repetitions of one
175-line group**. Verified by hashing the code lines of all ten groups: they
agree, and the only difference anywhere in the file is one trailing blank
line in group ten. A group is four words -- `4k+0` at 94 lines doing RotWord,
SubWord as four S-box walks and the Rcon xor, then three plain word-xors at
27 lines each.

**The four static slots survive being looped, and the existing header's own
argument is what proves it.** That header says the window can stay still only
because the forty words are unrolled, so `slot = i mod 4` is a generation-time
constant. That holds just as well for a loop whose body is one whole group,
because the slot pattern has period four and the body covers exactly one
period:

| word in body | writes slot | reads w[i-4] from | reads w[i-1] from |
|---|---|---|---|
| 4k+0 | 0 | 0, about to be overwritten | 3, from the previous group |
| 4k+1 | 1 | 1 | 0 |
| 4k+2 | 2 | 2 | 1 |
| 4k+3 | 3 | 3 | 2 |

Every slot is a fixed offset inside the body, so **the window never moves and
R4 needs no conveyor at all** -- unlike SubBytes, whose sixteen bytes had no
such period and for which `block/rotate16` was the only way in. R4 needs no
unrolled tail either, since group ten is identical to the other nine. R5's
rounds are NOT, because round ten of the cipher has no MixColumns.

**The table is half the cost, and neither R4 nor R5 can claim R1+R2's
invariant.**
`aes/keyexpand128`, `aes/encrypt128` and `aes/decrypt128` each lay the S box
down as packed absolute `+` runs on lines of 475 to 768 bytes -- the very
packing that got `keyexpand128` under the 2000-line cap. Measured, that form
costs about **twice** the delta-coded block:

| | instructions |
|---|---|
| the packed absolute table, as committed | 34,193 |
| `block/sbox256`, delta-coded | 17,149 |

So `%%block/sbox256%%` is shorter to read AND ~17,000 instructions cheaper per
lay-down. But it is not the same instruction bytes, so R4's and R5's invariant
is the vectors -- FIPS 197 Appendix A and C.1 and Appendix B, both directions,
plus the round trip -- and not the byte-identity R1+R2 could claim. Say so in
their messages rather than letting the stronger claim be assumed to carry.

**R4 was built and measured against the four pinned vectors before this was
written, and it comes out NEUTRAL, not cheaper.** 19,037,565 instructions
against the unrolled file's 19,035,884: **+1,681, or +0.01%.** The table gives
back about 17,000 and the loop spends about as much walking to its counter and
home again, because the counter cannot live at cell 0 -- the paste workspace
owns that -- so it sits above the table at `@0x332` and every one of the ten
turns pays 1,636 instructions to reach it and return.

That is the third cost claim in this rebuild that arithmetic got wrong and a
measurement corrected, after the conveyor's 5.5% and this section's own first
sentence. The pattern is always the same: costing the pieces and forgetting
the travel. **Do not write a cost sentence that has not been run.**

Nothing pastes `keyexpand128`: `aes/encrypt128` mentions it three times in
prose and carries its own inline schedule. So R4 ripples into nothing, exactly
as R3 did.

### R5 splits in two, and the decrypt half needs a decision

**`aes/encrypt128` is the easy half and has the same shape as R4.** Its nine
rounds are byte-identical in code -- 143 lines each, all hashing the same --
and round ten is 142 lines and differs, because it has no MixColumns. So R5's
forward side is round nought, a loop of nine, and one unrolled tail. It should
land near 370 lines from 1,609. The rounds can be identical because the file
computes each round key JUST IN TIME, in order, and never holds 176 bytes.

**`aes/decrypt128` cannot be done that way, and no arrangement of blocks fixes
it.** The inverse cipher wants the round keys in REVERSE order, so the file
computes the whole schedule first and stores all 176 bytes. That makes both of
its phases differ per iteration, and measurement says they differ ONLY in an
address that steps by 16:

| | round 9 | round 8 |
|---|---|---|
| reads its round key | `R144[-R83+L83]L144` | `R128[-R99+L99]L128` |

Its forty schedule groups diverge the same way, at the store rather than the
read. Everything else in each repetition is identical. **An include takes no
parameters -- CONVENTIONS forbids control logic on the templating side -- so
`%%block%%` cannot express "the same code at a different offset". This is an
index, and it has to be paid for.** Three ways, and the third is the one to
prefer:

**Measured, not estimated.** A rotation generator was written, made to prove
it actually rotates before reporting any cost, and run on random bytes:

| | instructions |
|---|---|
| 176 cells by 16, one round key consumed | 1,380,309 |
| 176 cells by 4, one schedule word stored | 428,499 |
| 16 cells by 1, as a sanity check against `block/rotate16`'s in-situ 12,314 | 13,729 |

| | how | cost on the 138.28M routine |
|---|---|---|
| a | convey the 176-byte schedule: 16 cells per round for ten rounds, 4 cells per word for forty words | 13.80M + 17.14M = **+30.94M, +22.4%** |
| b | an indexed walk with a 16-byte stride over the eleven round keys | new machinery, not measured |
| c | **regress the schedule from the last round key** | one more schedule pass, measured at 19.04M: **+13.8%** |

**(a) was estimated here at +10% and measures +22.4%.** That is the fourth
cost claim in this rebuild that the cost law underestimated, and the first
three are recorded above. The law is a guide to shape, not to magnitude: it
says a byte moved `d` cells costs about `2vd`, and it keeps coming in low
because the loop and pointer overhead around the moves is not in it.

**(c) is the one that matches the project.** The AES-128 schedule is
invertible -- `w[i-4]` is `w[i]` xor the same temp function of `w[i-1]` -- so
the inverse cipher can run the schedule BACKWARDS and consume each round key
as it is produced, exactly as `encrypt128` consumes them forwards. That
removes the 176-byte store, removes both indices, needs no new block, and
makes the two halves structurally symmetric. It costs one extra forward pass
to reach `w40..w43` before the regression can start, which is where the +19M
comes from. **It is the dearest of the three by a few percent and the only one
that leaves the file looking like something a person wrote.**

**And then a fourth option appeared on reading the file's own header, which
beats all three.** (c) was recommended for about an hour before this replaced
it.

`aes/decrypt128`'s header says *"the whole schedule is stored... decryption
consumes the round keys BACKWARDS so there is nothing to recompute on the
way."* The second half of that is false, and the first half is what it costs.
It also says only ONE table is ever resident, forward in phase one and inverse
in phase two, because two would make every read of the far one travel. That
kills (c) as stated: regressing needs `SubWord`, which needs the FORWARD
table, which phase two does not have.

**But the temp does not need recomputing either.** In `w[i] = w[i-4] XOR
temp(w[i-1])` the regression `w[i-4] = w[i] XOR temp(w[i-1])` uses the SAME
temp. For `i` not a multiple of four that temp is just `w[i-1]`, which the
window holds. For the ten multiples of four it is
`SubWord(RotWord(w[i-1])) xor Rcon`, and phase one computes every one of them
on its way up.

**So phase one stores the ten temps -- 40 cells, not 176 -- and phase two
needs no forward table, no `SubWord`, and no Rcon at all.** The Rcon run and
the `block/rotate10` this document proposed an hour ago are both unnecessary;
the Rcon is already folded into the stored temp.

| | what is stored | phase two needs | measured cost |
|---|---|---|---|
| a | the 176-byte schedule | a 176-cell turn per round | +24.69M, +22.4% |
| c | nothing | a second forward pass, and a table it cannot have | +19.04M, +13.8% |
| **d** | **ten 4-byte temps, 40 cells** | **a 40-cell turn by 4** | **+2.33M, +1.7%** |

The regression was checked in Python against the forward schedule before any
brainfuck was written: from `w40..w43` and the ten stored temps it reproduces
every word down to `w0`, and the recovered first four words are the key.

The 40-cell conveyor is measured at 122,524 a turn, 19 turns (ten storing in
phase one, nine reading in phase two) for 2.33M. **The rest of (d) is NOT
measured** -- the forty word-xors of the regression, and whatever phase one
gives back by storing 40 bytes instead of 176. So +1.7% is a floor built from
one measurement and some arithmetic, and this document has been wrong about
exactly that four times. Measure it when it is built.

**BUILT, AND (d) WON.** Measured on the Appendix B key and ciphertext:
139,980,084 instructions unrolled with its stored schedule against
142,154,478 looped and regressing -- **+2,174,394, or +1.55%**. The
regression costs about 10.1M on its own, the round-key copy a few million
more, and dropping the 176-byte store gives back about 8.6M because the
committed phase one moved every word some 209 cells to file it.

**That is the first cost prediction in this rebuild that held.** The estimate
was +1.6 to +3.6% and it came in at +1.55%. The four that did not hold are
recorded above, and the difference is that this one was assembled out of
measurements rather than out of the cost law.

Two notes on how the measurement went, because both are traps this document
already names. The first generator silently dropped the wrapped bytes and
reported costs for a program that did not rotate; the numbers were wrong by
about 50% and looked entirely plausible. The second had its test data drawn
from a `random.Random(7)` re-seeded on every byte, so every cell held `0xa5`.
**The fix that mattered was making the harness verify the rotation before
reporting a cost at all** -- after which it said "HARNESS WRONG" twice more
before it said anything else.

## What a block can and cannot factor, measured

Four blocks were added at the commit this section arrived with to share code between eight skeletons
that had been written twice. Deciding WHICH duplication to factor turned out
to be the whole problem, and two limits decide it.

### The amplification law: small and repeated is EXPENSIVE

`%%include%%` is textual. Unlike a paste, which drops the callee's header, an
include carries the block's comments into every expansion -- and then every
paste downstream multiplies them again.

So the cost of factoring something is not its size, it is **how many times it
appears in the finished `.bf` after paste multiplication**:

| candidate | sites in all `.bf` | block's comment lines | growth |
|---|---|---|---|
| `block/halve` | 145,004 | 3 | **+435,012 lines** |
| `block/xor8kernel` | 30,653 | 22 | **+674,366 lines** |
| the four blocks actually added | 2 each | 13 to 19 | +0.12% |

The corpus is 5.46M lines. Factoring `halve` -- a ONE LINE idiom duplicated in
seventeen skeletons, which is the most obviously repeated thing in the
library -- would have grown the repository by eight percent. Factoring both it
and the xor8 kernel would have added over a million lines.

**So the rule is the opposite of the instinct.** The owner stated it before
the measurement did: *if something is repeating a lot, it is probably a
component of something larger that repeats fewer times.* Factor the larger
thing, near the top of the paste chain, and the small one comes along inside
it for free. `block/halve` and `block/xor8kernel` stay where they are, used
only by the handful of files that already include them.

### The parameter wall: a pervasive constant cannot be shared

The largest apparent wins in the library are keccak's sibling pairs:

| pair | lines each | identical |
|---|---|---|
| `tuplehash128` / `tuplehash256` | 492 | 93% |
| `parallelhash128` / `parallelhash256` | 508 | 85% |
| `sponge136` / `sponge168` | 215 | 89% |
| `squeeze136` / `squeeze168` | 103 | 90% |

**None of them can be factored, and the reason is structural.** They differ by
a rate or a size, and that constant shifts every absolute tape offset
downstream of it. `tuplehash128` says `R1362` where `tuplehash256` says
`R1202`, `@@BYTEPAD168@@ 1760` against `@@BYTEPAD136@@ 1600`, `ASSERT
ptr=2959` against `2767` -- forty-odd differences scattered through the file.
The identical lines between them are real but interleaved, so the only
extractable pieces are arbitrary slices, and a slice is not a component.

CONVENTIONS §6 forbids control logic on the templating side, which forbids
parameters, which is exactly what sharing these would require. **This is the
same wall `aes/decrypt128` hit** when its nine inverse rounds differed only in
an address stepping by 16: no arrangement of blocks could say it, and the way
out was to remove the index from the algorithm rather than from the notation.

Those ~1,300 duplicated lines are compile-time specialisation on a constant.
They are not carelessness and they do not come out.

### So: a pair is factorable when the difference is a LINE, not an OFFSET

That is the whole test, and all four that passed it look the same:

  - a rotate wraps the bit that falls out of byte 0 where a shift discards it
  - `left_encode` places the count before the bytes and `right_encode` after
  - ShiftRows and its inverse disagree only about which pass permutes

In each case the differing part is a line or two and everything around it is
a block. When the difference is an offset instead, it is everywhere, and the
files stay apart.

## The first mode, and what the cipher had to become

`aes/ctr128` is the first file here that uses a cipher as a *component* rather
than being one. Getting there cost three changes to the tree and found three
defects, two of which were in claims the tree was already making.

### The cipher came out of its program, and then had to come apart again

`aes/encrypt128` was a program: read a key and a block from the wire, emit
sixteen bytes. A mode wants neither end of that. So the rounds moved into
`block/aes128encrypt` and the wrapper became 86 lines of IO around an include —
and `encrypt128.bf` came back **instruction-identical**, which is the check
that the extraction changed nothing. `decrypt128` the same, 558 skeleton lines
down to 109, `dabf6715d0f0` both sides.

**That was not enough, and the reason is a correctness trap rather than a cost
one.** `block/sbox256` is delta-coded: runs of `+` and `-` against the previous
entry, which assumes every cell starts at **nought**. A mode that included the
one-piece cipher once per block would lay the table over itself, every one of
the 256 entries would be the sum of two, and the cipher would emit sixteen
plausible bytes that are not the ciphertext. No contract in the tree would have
caught it, because every contract there asserts a *pointer* or a *clear* cell,
and this is neither.

So the cipher is two blocks. `block/aes128table` lays the S box and
`block/aes128encrypt` runs the rounds, and a mode runs the first once.

**The split falls where it does so the instruction stream does not move.** The
table block ends on the walk home from the table — at relative cell 45, which
is the round constant's cell — and the rounds block opens on the `+` that makes
that constant one. Concatenated, the two are byte-for-byte what was there
before. Ending the table block at nought instead would have cost a longer walk
home and a walk back out, and changed every AES artifact to buy tidiness. The
seam is asserted from both sides: the table block's trailing `; ASSERT ptr=+45`
and the rounds block's leading one are the same claim written by each party.

### What a second block has to put back, measured rather than reasoned

The cipher's exit state was dumped off the Appendix B vector, because two of
the three facts were not what the file's own contracts said:

| cell | after one block | the contract said |
|---|---|---|
| window @0:15 | the TENTH ROUND KEY | nothing |
| rcon @45 | **0x6c** — the schedule xtimes it ten times | nothing |
| @16:44, @46:81, @98:116 | clear | `zero 16:44` only |
| state @82:97 | the ciphertext | nothing |
| the S box @117:884 | intact, because `walk256` restores each datum | nothing |

`encrypt128` asserts `zero 16:44` after the cipher, which stops one cell short
of the round constant. A mode that trusted that assertion and re-entered would
have made its second round key from `0x6c` instead of `0x01`, and produced a
wrong ciphertext from a program whose every contract passed. **The contract
that pins it now lives in the block itself** — `; ASSERT zero +45:+45`, which
holds trivially for `encrypt128` and is load-bearing for every mode after it.

### The layout was chosen to make one copy routine serve two sites

Both of `ctr128`'s sixteen-byte operands have to be *copied* rather than moved:
the key because every block wants it, the counter because the increment wants
it. Brainfuck has no copy — a cell is spent by the loop that reads it — so each
goes to two places and one of them hands it back.

Those two copies are the same text, and only because the tape was laid out to
make them so. The key sits exactly 885 cells above the window; the counter sits
exactly 885 above the state; each stages 869 below itself. So `block/copy16` is
one file included at offsets 885 and 967, and `block/copy16back` the same.
**An include offset shifts a frame and does not rescale the distances inside
it**, so had those two gaps differed by a single cell this would be two files
and no offset could have saved it. The 66-cell gap at `@0x385:0x3c6` is not
waste; it is what buys the sharing. This is the owner's principle — *if
something repeats a lot it is probably a component of something larger that
repeats less* — applied forwards for once, at design time, instead of to a
corpus after the fact.

### Counter mode needs no inverse cipher, and that decided the order

CTR decryption is CTR encryption run on the ciphertext, because the keystream
does not know which direction it is serving. So the first mode exercises the
whole composition — the include, the offset, the per-block restoration — without
needing `block/aes128decrypt`, which cannot be included twice at all: it lays
the forward table, spends it on the key schedule, **clears it and writes the
inverse one into the same cells**, and runs the rounds. There is no prefix of
it a caller can run once.

That matters for the rest of the roster, and the shape is better than it looks:
**CTR, GCM, GMAC, CMAC and CTR\_DRBG all use the forward cipher only.** Cipher
block chaining is the sole consumer of the inverse, so it is the only mode that
has to pay for the restructuring, and `block/aes128decrypt`'s header now says
what that restructuring is: phase one once, keeping the last round key and the
ten temps; the swap once; then the inverse rounds per block from the kept round
key rather than regressing from a window the previous block spent.

### The vectors are chosen to separate the two ways a mode fails

SP 800-38A F.5.1 is kinder than it looks. Its initial counter is `f0f1..feff`,
so the second block's is `f0f1..ff00` and the increment **carries out of the
last byte** — a published vector that tests the carry chain for us. A sixteen
byte message would never run the increment; a thirty-two byte one would run
only the easy case. So: 64 bytes for all four published blocks, 17 bytes as the
cheapest input that reaches the carry, 16 bytes for block one alone, and the
zero key whose first sixteen bytes are `encrypt128`'s own pinned
`66e94bd4...`, checked four lines above by a different program.

The one-block and four-block lines are kept as a **pair** on purpose: together
they separate *the cipher is wrong* from *the restoration is wrong*, and on its
own neither line can. The empty message is checked outside `dk`, because a
zero-length Cryptol sequence is not something the batch's hex printer has an
answer for; it is the only input that reaches the length test without entering
the loop.

All of it was run locally under the scratchpad interpreter with contracts
**live** before any of it was wired into the suite: 554,625,886 steps for the
64-byte vector and 2,353,673,284 for the 257-byte one, every assertion
holding.

**And one of those vectors exists because the published ones are too short.**
`remaining` is a u16 whose decrement borrows from the high byte only when the
low byte is already nought — which first happens at `0x0100`, so **a message
of 256 bytes or fewer never runs that arm at all**. Every published CTR vector
is 64 bytes. Nine instructions of this file's own bookkeeping would have
shipped untested, and the symptom of a transposed sign there is a long message
silently truncated or a loop that does not end.

So there is a 257-byte line: the cheapest input that reaches it, seventeen
blocks, `remaining` stepping `0x0101`, `0x0100`, `0x00ff`. Its expectation is
**derived**, and the chain is worth stating because a derived vector is only
as good as its derivation. No standard publishes a 257-byte CTR value, so it
was computed by a small AES written for the purpose, which was first checked
against every end-to-end value the standards *do* publish — FIPS 197 Appendix
B and C.1 and SP 800-38A F.5.1 — before it was trusted to compute anything.
The derivation is also legible in the answer: the line reuses the published key
and counter, so its first keystream bytes are the ones the F.5.1 line already
pins, and `ec8ddd70` is `ec8cdf73` exclusive-ored with `00010203`. Cryptol then
checks the whole of it independently, which is the half of `dk` that makes a
derived vector worth having.

**The same gap is open in `chacha20/stream`**, whose longest vector is RFC
8439's 114 bytes and whose borrow is the same shape and the same nine
instructions. It is noted here rather than fixed, because that file is not that
commit's subject — but it is a real untested arm in a shipped primitive, not a
hypothetical, and it belongs with the seventeen dead contracts as work that
file is owed.

### A found defect, deferred with its scope named

**A contract written after the last instruction in a program can never fire.**
`; ASSERT` attaches to the *next* instruction; if there is no next instruction
there is nothing to attach to, and the line reads as enforced when it is prose.
**Seventeen** programs carry twenty-two such claims — `aes/keyexpand128`,
`chacha20/stream` and fifteen keccak files — and at least one is also **false**:
`chacha20/stream` ends `; ASSERT zero 0:397`, but a message ending partway
through a block leaves the rest of that keystream sitting in cells 0 to 63.

A `block/` skeleton is **exempt, and this is not a loophole**: its text is
included into a caller, so a trailing contract there attaches to whatever
instruction follows the include site. `block/aes128table`'s trailing
`; ASSERT ptr=+45` is exactly that, and it fires on the rounds block's first
`+`. The rule is about programs.

`aes/ctr128` does not join the seventeen: its final walk is split one cell short,
`L988` / contract / `L1`, which costs no instructions and makes the exit claim
real. Note what it claims and what it does not — `j` is **not** asserted clear,
because a message ending mid-block leaves the rest of that keystream counted
and unused, which is the whole reason the tail needs no special case. That is
the claim `chacha20/stream` got wrong by sweeping.

**Done, in the unit after this one.** `tools/bfdag.pl` rejects them, with five
self-tests covering both polarities and the three things an instruction can be
in a skeleton — a command byte, an `Rn`/`Ln` walk, and a paste or include line.
Missing those last two would have made the check pass every keccak program by
accident, which is why they are tested separately. All twenty-two claims are
live, in one of two shapes:

- **the final walk split** where the file owns it — `L338` to `L337`,
  contracts, `L1`, which adds no instructions at all, in `aes/keyexpand128`,
  `chacha20/stream` and the two `squeeze` routines;
- **a pair that cancels** where the last instruction belongs to a paste and
  cannot be split from outside — contracts, then `>` then `<`, two
  instructions against hundreds of millions, in the thirteen keccak programs
  whose last act is `@@SPONGE@@` or `@@SQUEEZE@@`.

**Twenty-one of the twenty-two were true all along.** `aes/keyexpand128`'s
`zero 0:24` and `zero 41:44` were checked against four keys including all-ones
before being made live, and hold; the `ptr=0` after a paste holds because the
wrapper walks out `exit=` cells — and making it live means **something now
checks that a routine's declared `exit=` matches where its body actually
leaves the pointer**, which nothing did before. `bffoot` bounds the footprint;
it has no opinion on the exit offset.

**The twenty-second was `chacha20/stream`, and it was false in two of its own
three vectors.** Measured at exit: the remainder of the last keystream block
stands in `@0x000:0x03f` whenever the message did not end on a block boundary;
the saved key, counter and nonce stand in `@0x120:0x14f` because they are
copied rather than moved; and `j` at `@0x153` holds the count of keystream
left. The replacement names all three as deliberately not clear and claims the
rest — `zero 64:287`, `zero 336:338`, `zero 340:397` — which is longer than
`zero 0:397` and is a fact.

One of the twenty-two was stated **twice** — `sponge136` and `sponge168` each
carried it either side of their `; emit` line — and removing the duplicate
turned out to be a change to seven downstream artifacts, because the copy
above `; emit` sits inside the body a paste copies. That is in the traps list,
along with why one rebuild pass could not see it.

The shape of the original mistake is worth keeping: **a sweeping claim over a
whole frame was easier to write than the truth, and because it was never
checked, nobody found out.** A contract that cannot fail is the thing tier 0
exists to forbid, and twenty-two of them had accumulated in the one place no
checker was looking.

## The second mode, and a copy where a move belonged

`aes/cbcenc128` is deliberately the **same shape** as `aes/ctr128`: the same
tape down to the cell, the same two includes, the same per-block restoration.
That was the point of writing the first mode carefully — the second one should
be plumbing, and it was, except for one defect that is worth the whole section.

### What chaining costs over counting: almost nothing

Counter mode encrypts a counter it owns. Cipher block chaining encrypts the
plaintext exclusive-ored with the previous ciphertext. The per-block work is
identical, and the only new thing is where the block comes from. The chain even
reuses the conveyor: the chain's head byte is always at `@0x3c7`, it is lifted
out, the other fifteen slide down, and the exclusive-or's answer goes in at the
tail — sixteen turns later the chain is back in order holding the whole block.
That keeps `idiom/xor8` to **one paste**; the alternative was sixteen pastes at
sixteen fixed offsets, which is the shape this project calls indices rather
than conveyors.

### The defect: one distance, two routines

Both of this mode's sixteen-byte operands move the same 885 cells, so both
looked like jobs for `block/copy16`. They are not.

- the **key** is copied, because every block wants it again;
- the **chain** must be **moved**, because it is *spent* the moment it reaches
  the state — the next chaining value is the ciphertext that is about to come
  back into those very cells.

Written as a copy, `block/copy16back` puts the chained plaintext back where the
ciphertext is about to be moved in, **and a move into an occupied cell adds**.
So the next chaining value was `(P₁ ⊕ IV) + C₁`, byte-wise, instead of `C₁`.

Two things about how that presented are worth keeping:

**The first block was still correct.** A block is emitted *before* it is
chained, so a one-block message passes and only two blocks or more can show it.
The vectors were already written as a pair — block one alone and all four
published blocks — precisely to separate "the cipher is wrong" from "the
chaining is wrong", and that is exactly what they did: `len 16 PASS`,
`len 32 FAIL`.

**The wrong answer looked like a cipher bug and was not.** Recovering it took
inverting the cipher on the bad output to find the block it had actually
encrypted, then exclusive-oring the plaintext back out to see the chain value
it used: `e109678d…` against `7649abac…`, which is the sum, not any rotation
or reversal of the right answer. Guessing from the ciphertext alone had already
failed on nine candidates.

`block/move16` is the sibling of `block/copy16` and the difference is not
speed. It also touches strictly less: `copy16` stages 869 cells below its
source, which in this mode is the cipher's own round-key region, and `move16`
has no stage at all.

**The contract that would have caught it is now in the file**:
`; ASSERT zero 967:982` immediately before the ciphertext is moved into the
chain. It is the cheap kind — a claim about cells that are supposed to be
empty, at the one point where "supposed to" was wrong.

### What this mode does not do

**No padding, and the length must be a multiple of sixteen.** The Cryptol side
says so in its *type* — `cbcenc128Run` is parameterised by the block count, so
a bad length is a type error rather than a quiet wrong answer — and the
brainfuck says so in prose, because it cannot say it any other way. Enforcing
it would cost instructions on every run to catch a caller error the vectors
cannot produce.

Everything was run under the scratchpad interpreter with contracts **live**
before any of it was wired into the suite: 124,578,738 steps for one block,
505,159,372 for the four published ones, and 2,140,222,159 for the 272-byte
borrow line, every assertion holding.

**Decryption is not here.** CBC is the one mode in the roster that needs the
inverse cipher, and `block/aes128decrypt` cannot be included twice; its header
says what restructuring that will take. Everything else remaining — GCM, GMAC,
CMAC, CTR\_DRBG — uses the forward cipher only.

## CMAC's subkeys, and an offset that did not reach far enough

CMAC is the next mode, and it needs something none of the others did: a
**128-bit doubling in a field that is not the cipher's**. SP 800-38B section
6.1 derives two subkeys from the cipher applied to the zero block, by shifting
left one bit and reducing by the polynomial of GF(2^128) when the bit that
falls off the top is set. Its low byte is `0x87`, where `aes/xtime` reduces by
`0x1b`. Same shape, different field, and a confusion between them produces
plausible wrong bytes.

### The subkeys are a program of their own, on purpose

`aes/cmac128` will derive these two values inside itself where nothing can see
them: a tag is sixteen bytes, and a wrong subkey is a wrong tag with no
indication of which half went wrong. **RFC 4493 section 4 publishes K1 and
K2**, so `aes/cmacsubkeys` turns an invisible intermediate into a pinned one —
the same argument that makes `aes/keyexpand128` and `aes/subbytes` programs in
their own right rather than only code inside the cipher.

It was also the cheaper order of work. `block/shl128` was built and tested
against the published pair *before* a line of the mode was written, so when
the mode is wrong the subkeys will already be known right.

**The published key exercises both arms of the reduction**, which is luck
worth stating rather than relying on: `L` is `7df7…` whose top bit is clear,
so `K1` is a plain doubling, and `K1` is `fbee…` whose top bit is set, so `K2`
takes the `0x87`. One key covers both branches; the zero key adds a second
independent pair.

### Three new blocks, and the 885 family is now complete

`block/topbit` is the seven-halving chain that takes a byte's high bit. It is
not new text — it already exists written out inline seven times in `aes/xtime`
and again in `idiom/add8`'s carry — and **those two are deliberately not
migrated to it**. A paste reads a callee's committed `.bf`, `xtime` is pasted
by four files, and the comment change alone would regenerate most of the AES
tree for no change in instructions. That is owed, not done.

`block/shl128` is the doubling itself, and it is included at a nonzero offset,
which is what found the next defect.

`block/moveup16` completes the set that crosses this library's one recurring
distance. Every mode here puts its sixteen-byte working value exactly 885
cells above the cipher's state, so there are exactly three routines for that
gap and each is one text: `copy16` goes down and stages, `move16` goes down
and does not, `moveup16` comes back up. **Up is a separate routine and not a
parameter**, because an include carries an offset and not a direction: an
offset shifts where a frame starts and cannot turn `R885` into `L885`.

### The defect: an include offset that shifted contracts but not paste bases

`block/shl128` **pastes** `idiom/xor8` at its own cell 52, and
`aes/cmacsubkeys` includes the block at 967. The paste rebased xor8's
contracts against base 52 — correct for the block's own zero and wrong for
where the block actually landed. The symptom was a contract naming cell 54
while the pointer stood at 1021, which is a long way from the cause.

**A paste base is a cell number in the same frame as a contract**, so the
include's offset has to shift it too, and `tools/bfinclude.pl` now does.
Without that, *a block that pastes anything can only ever be included at
offset nought* — which happened to be true of every such block until this one,
which is why it had never bitten. `block/aes128encrypt` and
`block/aes128decrypt` both paste, and both are included only at zero.

**`Rn` and `Ln` are not shifted**, and the self-tests pin that too. A run
length is "forty six arrows" and means the same thing wherever the text lands;
an offset moves a frame and does not rescale what is inside it. Getting that
wrong would silently lengthen every walk in an offset block.

`bfinclude` had **no self-tests at all**, which is the same combination
`bftier.pl --fix` was caught with two commits ago: arithmetic that rewrites a
tracked artifact, unexercised. It has ten now, both polarities.

## The third mode, and an include that lost a per cent sign

`aes/cmac128` is the first mode here whose message length may be **anything**,
including nought. Counter mode takes any length because a keystream does not
care; cipher block chaining takes only whole blocks because it has no padding;
this one takes any length because SP 800-38B gives it a padding rule and *two*
subkeys to tell the padded case from the exact one.

### CMAC is cipher block chaining with a tweak on the last block

That is the whole of it. `X` starts at nought rather than at an IV, each block
is exclusive-ored into `X` and enciphered, and the last block takes one further
exclusive or — with K1 if the message filled it exactly, with K2 if it had to
be padded. Those two were derived and **pinned against RFC 4493's published
values one commit earlier**, which is why they could be used here without being
the suspect when something went wrong.

Three decisions made the loop body have no branch in it:

- **The tweak is applied on every block**, and is nought on every block but the
  last. Exclusive or with nought is the identity, so the pass costs about
  sixteen runs of `idiom/xor8` against the hundred and fourteen million a block
  already costs. Same argument `aes/xtime` makes about its own reduction.
- **The last block is known by the count, not by looking ahead.** After a block
  has been filled, `remaining` is nought exactly when that block was the last —
  whether it was filled from the wire or finished with padding. So `last` is
  simply "remaining is nought", and padding only decides *which* subkey.
- **The padding is written as it is needed**, one byte at a time inside the same
  loop that reads. A turn either takes a byte from the wire, or writes the
  `0x80` that opens the padding, or writes nothing — decided by two flags
  rather than by three pieces of code.

The conveyor now carries **both** operands: the chain's head and the tweak's
head are each lifted out, each slides down, and the answer goes in at the
chain's tail. Sixteen turns later the chain is back in order and *the tweak is
empty again*, which is what lets the next block start from a clear tweak
without clearing it.

### Three bugs caught by reading, and one by running

Three were found before the file was ever expanded, by re-reading the
generator:

- **`nz` can be TWO.** The "is the count nonzero" idiom increments a flag once
  per nonzero *byte*, so for a length like `0x0101` it holds 2. Every previous
  use was a loop condition, where any nonzero does. This file used it as a
  guard — `nz[- read a byte ]` — which would have read **two** bytes on those
  lengths and one on the rest. The guard now clears `nz` inside the loop
  instead of decrementing it, so the body runs exactly once whatever `nz`
  holds. No published vector of any mode here is long enough to show it.
- **Both inner loops decremented their counter twice**, at the top and again at
  the bottom, so each would have run eight turns instead of sixteen.
- **`padded` survives to the end** on a padded message, so the exit contract
  cannot claim it clear. It is the one cell in that range left unclaimed.

### The fourth: an include that lost a per cent sign

The skeleton is written out by a script, and one line of that script read
`"%%block/copy16%% %d" % KEY`. Python's `%` formatting treats `%%` as an
escape for a single `%`, so what landed in the skeleton was
`%block/copy16% 885`.

**Nothing in the suite could see it.** `bfexpand` left it alone as prose;
`bfdag` saw no include to resolve and no orphan to report, because
`block/copy16` is included by other files; `bflint` and `bfstyle` have no
opinion on a per cent sign. The program simply stopped copying the key into
the window, and the only thing that noticed was a **pointer contract fifteen
cells later** — `expected 900, got 885` — which is the whole argument for
writing those contracts at every seam.

`tools/bfinclude.pl` now rejects a line of the shape `%name%` with one sign on
each side. Nothing in this project writes that, so there are no false
positives, and the eight self-tests pin both polarities including a comment
that happens to contain a per cent sign.

All five vectors were run under the scratchpad interpreter with contracts
**live** before any was wired into the suite: 242,638,713 steps for the empty
message, 628,583,499 for the four published blocks, and 2,400,414,564 for the
273-byte line, every assertion holding.

The general lesson is about **generated text that contains the generator's own
metacharacters**. The skeletons here are written by scripts in a scratchpad —
which is allowed, because every number still ends up literal in the committed
file — but `%%`, `{}` and backslashes are exactly the characters a formatter
eats, and brainfuck skeletons are made of little else.

## The fourth mode, and the inverse cipher comes apart at last

`aes/cbcdec128` is the only mode in the roster that needed the inverse cipher,
and the only one that needed anything restructured. CTR, CBC encryption, CMAC,
GCM, GMAC and CTR\_DRBG all run AES **forwards**.

### Why it could not simply be included

`block/aes128decrypt` as it stood could not be used twice. It lays the forward
table, spends it on the key schedule, **clears it and writes the inverse one
into the same cells**, then runs the rounds. There is no prefix of that a
caller can run once — which is exactly what its own header had said was owed,
three commits earlier.

So it was split into `block/aes128dsetup` and `block/aes128drounds`, at the one
seam where the instruction stream does not move: the inverse table's walk home
ends at nought and the per-block work opens at nought. **`aes/decrypt128`
regenerates byte for byte** — `dabf6715d0f0` both sides — which is the same
test the forward split passed and the reason the seam is where it is.

What that buys: about sixty-six thousand instructions to clear the forward
table and seventeen thousand more to write the inverse, on top of the schedule
itself, paid **once per message** instead of once per block. Measured, the
first block of a message costs 176,079,162 steps and the second costs
137,804,347 more — so the setup is about a fifth of a block and a mode that
re-ran it would be paying that every time.

### Fifty-six bytes, and why they cannot be recomputed

The rounds **regress** the window a word at a time down to the original key and
**spend** the ten schedule temps on the way. So a second block needs both back.
They cannot be recomputed: regenerating them needs the *forward* table, and
that is the one thing the setup threw away.

So the mode snapshots them after the setup — temps at `@0x057:0x07e` and the
window at `@0x0a0:0x0af`, fifty-six bytes — and copies them back before each
block. The snapshot is taken by **moving**, which leaves the live cells clear,
and each restore **clears before it copies**, because a copy into an occupied
cell adds. That is the defect `aes/cbcenc128` shipped a contract for, applied
in advance this time rather than after a two-block vector failed.

**The restore set was a guess, and the block's own contracts were what would
have caught it being wrong.** `block/aes128drounds` carries `zero 176:210` and
`zero 227:242` immediately after its clears. Those were dead weight when it was
one file — they could only ever be true. Here they police every block, and they
would fail at the *first* reuse of a dirty cell rather than three rounds later
in a wrong byte. They held.

### The ciphertext is both an input and the next chain

`P_i` is `D(C_i)` exclusive-ored with `C_(i-1)`, so a ciphertext block has to
survive its own decryption. It is read into a buffer of its own, **copied** into
the cipher's input, and **moved** into the chain afterwards — by which time the
exclusive or has emptied the chain. That ordering is what keeps one sixteen-byte
buffer enough.

Verified under the scratchpad interpreter with contracts **live** before any
of it was wired into the suite: 176,079,162 steps for one block, 313,883,509
for two and 587,741,480 for the four published ones, every assertion holding.

### The bug: a flag one cell to the left

The outer loop's `more` is set from "remaining is not nought". `more` sits
**above** `nz` on the tape, and the guard stepped **left** into it — which is
the length's own high byte. So every pass through the test *incremented the
length* instead of setting a flag, the count grew without bound, and the
scratchpad interpreter stopped at its four-billion-step limit.

The symptom was as unhelpful as a symptom gets — `step limit`, with no
indication of which loop or why — and the cause was a single character. What
made it quick to find was that the arithmetic is written down in the tape map:
`nz` at `@0x4a2` and `more` at `@0x4a3` makes "step left to reach more" wrong
on sight. The generator tracks the pointer and emits the walks, but it does not
know which cell a hand-written guard body means to reach; that remains the
author's arithmetic, and this is what it looks like when it is wrong.

## The fifth mode, and a primitive with no published vector

`aes/ctrdrbg128` is SP 800-90A's CTR\_DRBG over AES-128, with no derivation
function, no reseed, no personalisation string and no additional input. It is
the cheapest of the remaining modes because almost nothing in it is new: the
counter, the per-block key restoration and the 885-cell copy family all came
from `aes/ctr128`.

### The thing that is genuinely different: there is nothing published to pin it to

Every other primitive in this library is anchored to a value somebody else
computed. **SP 800-90A prints no test values in its text**, and the ones that
exist live in CAVP response files that are not in this tree. So every
expectation here is DERIVED, and for once that word does not mean what it
usually means in this suite — normally it means "a small reference computed
it, and that reference reproduces the published values first", and here there
are no published values for a reference to reproduce.

Rather than let that sit behind a label, the evidence is built out of three
things that do not share a source:

- **the cipher underneath is pinned** against FIPS 197 by four other programs
  in this suite, so a wrong AES cannot hide here;
- **Cryptol checks the construction** — the two Update calls, the counter
  arithmetic, the truncation — independently of the brainfuck;
- **a metamorphic check rests on neither.** The returned bits are the leftmost
  `len` bytes of a keystream produced block by block, so sixteen bytes must be
  exactly the first sixteen of sixty-four. That follows from SP 800-90A's own
  wording and from nothing this project wrote down, so it is evidence a wrong
  reference cannot manufacture.

It compares **only the bits**, deliberately. Generate consumes `ceil(len/16)`
blocks, so after a truncating call the counter has advanced a different number
of times and the trailing Update starts somewhere else — the *state* is not
comparable that way and the suite does not pretend it is.

### The state is emitted because otherwise the trailing Update is untested

SP 800-90A requires an Update after generating. In a single generate call it
changes nothing a caller can see, so implementing it faithfully would mean
**untested code in a cryptographic primitive** and skipping it would mean an
implementation that quietly is not the standard.

So the program emits `K` and `V` after the bits. That makes the trailing
Update observable and pins it, and it is the same argument that makes
`aes/cmacsubkeys` and `aes/keyexpand128` programs in their own right. The
`n = 0` vector is the one that earns it: no generate blocks at all, so the
answer is the instantiate and the trailing Update with nothing between them to
hide behind.

### `block/inc128`, and one text where there were two

The 128-bit counter step was sixteen near-identical byte bodies written out
inline in `aes/ctr128`, and this mode wanted the same thing. That is exactly
the shape the owner's rule names, so it is lifted into `block/inc128` and
`ctr128` is migrated to it in the same commit: **739 skeleton lines down to
355, instruction stream byte-identical** at `43e819da4935`.

The block is entered at the counter's base and walks the last sixteen cells to
the carry itself, so `ctr128`'s own walk gets exactly sixteen shorter and the
two sum to what was there before. It leaves the pointer **on the carry out**
rather than dropping it, because the two callers want different things from
it: counter mode is out of keystream when it wraps, and the generator's
counter is defined modulo 2¹²⁸ so a wrap is not an error. One text, two
readings of its result.

### Two Update calls, one copy of the cipher

Each include of `block/aes128encrypt` is about 176,000 instructions of program
text. `block/drbgupdate` needs two cipher runs and is itself included twice,
so writing the runs out would have put **four** copies in the file. Written as
a loop of two it puts two, and the generate loop holds the third and last.

The loop body can be the same both times because everything that differs is on
a **conveyor**: `provided_data` is thirty-two cells that give up their head and
slide, and the answer is thirty-two cells that slide and take a new tail. The
first turn consumes bytes 0–15 and the second 16–31 without either knowing
which it is. And because the conveyor *spends* the provided data, the trailing
Update is free: the instantiate call consumes the entropy, so those cells are
already nought when the second call runs, which is exactly the zero operand
SP 800-90A asks for there.

Verified under the scratchpad interpreter with contracts **live**: 482,281,505
steps at `n = 0`, 609,821,517 at 16, 735,581,837 at 17 and 993,446,868 at 64.

## GCM's field, pinned before anything is built on it

GHASH and GCM rest on multiplication in GF(2^128), and that multiply is
`aes/gfmul128` — pinned on its own, with no cipher and no table, before either
exists. The argument is `aes/cmacsubkeys`': a tag is sixteen opaque bytes, and
a wrong multiply is a wrong tag with nothing to say which part went wrong.

### The field is not the one CMAC uses, and the shift is not the one it uses

The polynomial is the same. **GCM writes its elements bit-reflected** — bit 0
of byte 0 is the highest-order coefficient — so the shift goes **right** and
the reduction lands at the **top** with `0xe1`, where `block/shl128` shifts
left and reduces at the bottom with `0x87`.

`block/shr128gcm` is therefore a **mirror image of `block/shl128`, not a reuse
of it**. Sharing text between them would mean parameterising a *direction*,
and an include offset shifts a frame but cannot turn `R885` into `L885` —
which is the limit `block/moveup16`'s header records from the other side. Two
files, and the field laws are what keep them honest.

A byte shifted right is `block/halve`, which hands back the quotient **and**
the bit that fell off, so one pass over the sixteen bytes produces both halves
of what the shift needs: the new bytes, and the bits that travel one place up.

### What the evidence is, since no standard publishes a multiplication vector

Three things that do not share a source:

- **One end is published.** GCM's subkey H is the cipher on the zero block,
  which for the zero key is `66e94bd4ef8a2c3b884cfa59ca342b2e` — a value
  `encrypt128`, `ctr128`, `cbcenc128` and `cbcdec128` already pin. So vectors
  multiplying H are anchored at one end even though the products are derived.
- **Cryptol checks the construction** independently, as for every other vector.
- **The field laws need no oracle at all.** Identity (which in this reflected
  representation is `0x80` and fifteen noughts), the absorbing zero,
  commutativity, and distributivity over exclusive or are properties of the
  operation itself. They are checked against the program directly in tier 7.
  A multiply that is wrong in a way all four laws survive is a very particular
  kind of wrong.

The law check carries one piece of arithmetic that is not the program's own —
an exclusive or of two hex strings — and it is done a nibble at a time in
**POSIX awk**, because `strtonum` and `xor()` are gawk extensions and the two
guests do not both have them. It checks itself first (`x(p,p)` must be zero)
before it is used to judge anything.

### Three conveyors, and a cost correction

`block/ghashmul` runs SP 800-38D's Algorithm 1 over 128 bits with **no index
anywhere**: X gives up its head byte and slides, the eight bits of that byte
give up their head and slide, and Z gives up its head and takes a new tail.
That keeps `idiom/xor8` to one paste and `block/shr128gcm` to one include
across all 128 iterations.

The bits come out of `halve` **low first** and Algorithm 1 wants them high
first, so the eighth halving's bit is written to the *first* cell of the bit
run and the first halving's to the last. The conveyor then reads them in the
order the algorithm asks for, and no reversal is needed anywhere else.

The branch is not a branch: the bit multiplies a *copy* of V and the exclusive
or runs unconditionally against that, so the work does not depend on the
operands. Same argument `aes/xtime` makes.

**And a correction worth recording, because it changes how GCM should be
costed.** A multiply was expected to be far cheaper than an AES block — the
reasoning was that 128 iterations of a shift and a conditional xor is small
beside ten rounds over a 768-cell table. Measured, **one multiply is about
300 million steps**, which is the same order as a block of AES (114 million)
and about three times it. The halvings dominate: 128 shifts of sixteen bytes
is 2,048 calls to `block/halve`, each costing about twice the value it halves.
So a GHASH over *n* blocks is not a rounding error against the cipher — it is
the larger half. Any estimate of GCM's cost that assumed otherwise, including
the one in this file's own next-steps table, was wrong.

## The last mode, and where GMAC went

`aes/gcm128` is the sixth mode and the only AEAD in the AES half of this
library. With it the roster the owner set is complete: CTR, CBC both ways,
CMAC, CTR\_DRBG, GCM and GMAC.

### GMAC is a line in the test file, not a program

SP 800-38D defines GMAC as **GCM with the plaintext empty** and the data to
authenticate passed as associated data. That is exactly `aes/gcm128` with
`plen = 0`. A separate `aes/gmac128` would have been thirteen hundred
duplicated lines for an IO convenience — the caller appends two nought bytes —
and duplicating thirteen hundred lines to save two is the shape this library
exists not to have. It is a vector with its own label instead.

### What the vectors are, and what is actually claimed

No test values appear in SP 800-38D's text. The reference that computed these
was written from the standard's description, and then on the all-zero input
produced `58e2fccefa7e3061367f1d57a4e7455a` — the tag universally quoted as
GCM's first test case — and on one zero block produced `0388dace…` and
`ab6e47d4…`, quoted as its second.

**Landing on both of those from the structure alone is strong corroboration**,
and the brainfuck then reproduced all three independently. They are still
labelled DERIVED, because nobody here read them out of the source document.
What is claimed is the *agreement*, which a reader can check in a minute. That
is a better position than `aes/ctrdrbg128` is in, where there is no widely
quoted value to agree with at all.

The last vector is the one that earns its place: twenty bytes of each means
**both** the associated data and the ciphertext are padded to a block boundary,
and the length block's two counts are not the lengths of what was hashed. A
program that hashed the padded lengths, or forgot to pad one of the two
sections, passes every other line.

### Three cipher runs that are not the keystream

The subkey `H` is the cipher on the zero block, the tag mask is the cipher on
`J0`, and only then does the counter run from `J0 + 1`. All three put the key
back first, because the schedule spends the window — the fact measured back
when the forward cipher was first split, now collected for the sixth time.

**The IV is ninety-six bits**, which is the only length with a simple `J0`. SP
800-38D says that for any other length `J0` is itself a GHASH, and that is a
different program.

**The ciphertext is never stored.** Sixteen bytes are encrypted, written out
and folded into the hash, then the next sixteen — the rule
`aead/chacha20poly1305`'s header records after an earlier cut of it reached
903 thousand lines by unrolling over the message.

### The padding is the slide

Every piece of what GHASH eats is padded to a whole block: `AAD ‖ pad ‖ C ‖
pad ‖ len(A) ‖ len(C)`. None of that needs a flag or a special case, because
the block being assembled **slides a byte at a time and a slide leaves a
nought behind**. When the input runs out the remaining turns slide and pad.
That is `chacha20poly1305`'s trick, and it is the second time it has saved a
whole class of part-block machinery.

The length block is the one piece of arithmetic: both counts are in **bits**,
so each `u16` has to become three bytes. Rather than propagate carries, the
value is split — `lo × 8` wraps into the last byte, `lo >> 5` and `hi × 8`
both land in the middle, and `hi >> 5` is the first. The two contributions to
the middle byte cannot overflow it (at most seven from below and 248 from
above), so no carry is needed anywhere.

### The bug: a block entered at the wrong cell

`block/ghashstep` is entered at the caller's own nought, and after each inner
loop the pointer sits on that loop's counter. Two of the three call sites
walked home first and one pair did not.

**The empty-input vector passed anyway** — with no associated data and no
plaintext neither loop runs, so only the length block's call site executes,
and that one was right. The tag it produced was `58e2fcce…`, the correct
published-by-consensus answer, which is exactly the kind of result that makes
a wrong program look finished. The next two vectors failed on
`block/ghashstep`'s own entry contract, at the instruction that should have
been at cell nought, rather than in a wrong tag two billion steps later.

## A second key size, and the shape that made it cheap

`aes/encrypt256` is AES at Nk = 8 and Nr = 14. The interesting thing about it
is how little of it is new: the round function does not depend on the key size
at all, so the only genuinely new code in this commit is the **schedule**.

### The round came out of the cipher first

`block/aesroundcore` is SubBytes, ShiftRows and MixColumns over the state --
and deliberately **not** AddRoundKey, because that is the one step that needs
to know where the round key came from. A cipher that makes its schedule just
in time has it in a window; one that stores the schedule has it on a conveyor;
everything before AddRoundKey is the same either way and at every key size.

`block/aesroundlast` is then the first two thirds of that, which is FIPS 197's
final round. Splitting it that way means the final round is **the same text**
as the other thirteen rather than a copy of it -- before the split a cipher
wrote its last round out by hand, and the sixteen S box walks in it were
sixteen walks that merely looked like the ones above.

### Why the schedule is stored rather than made just in time

`aes/encrypt128` makes its round keys one per round out of a four-slot window.
At Nk = 8 that does not work: **eight words are made per group and four rounds
consume them**, so the window and the rounds run at different rates, and the
just-in-time shape would need an index -- the thing this library's conveyor
rule exists to avoid.

So the whole schedule is built first into a 240-cell buffer. `block/rkappend240`
puts each word on the tail as it is made and `block/rkconsume240` takes sixteen
bytes off the head as each round runs. Conveyors at both ends. No round key is
ever addressed by a computed offset, and **the text of a round does not know
which round it is** -- which is why thirteen of the fourteen rounds are one
loop body and the fourteenth is written below it, exactly as `aes/encrypt128`
has it.

### One table, two readers

The S box is laid by the **program**, not by the schedule block. The schedule
reads it for SubWord and the rounds read it for SubBytes, and `block/sbox256`
is a delta-coded run that assumes every cell begins at nought: laid twice it
doubles all 256 entries and the cipher produces sixteen plausible bytes that
are not the ciphertext. That failure mode is already recorded in
`block/aes128table`'s own header; this is the first caller that could have
hit it, because it is the first with two independent readers of one table.

Making the table shared forced the schedule's frame to move -- its walk group
to 114 and its table to 117, where `block/aesroundcore` already wanted them --
and its buffer up to 900. That is a constant change in a generator, which is
the whole argument for laying tapes out symbolically.

### Two cells the schedule leaves live

Both are load-bearing and neither is obvious:

- the **window** at 25..56 still holds the last eight words, and
  `aes/mixcolumns` pastes over 50..81;
- the **round constant** at 61 holds the eighth one, which no key of this
  width ever asks for, and 61 is inside `aes/addroundkey`'s own workspace.

Either left behind is a wrong answer with nothing to point at it, so the
cipher empties both before the first round and then claims `zero 25:81`. The
schedule block's header already said the round constant was not claimed clear;
this is what that sentence was for.

### What the vectors pin, and why the schedule is a program

`aes/keyexpand256` emits the buffer and is pinned against **FIPS 197 Appendix
A.3**, which publishes all 240 bytes of an expanded key. `aes/encrypt256`
includes the same block, so what those four lines pin is what the cipher runs.
A cipher vector alone could not say *which* of sixty words was wrong -- and the
word most likely to be wrong is a specific one: the bare `SubWord` at every
eighth word offset by four, a rule that exists at no other key size and is
exactly what a transcription of the 128 case omits.

## The third key size, which cost a constant

`aes/encrypt192` is Nk = 6 and Nr = 12 over the blocks AES-256 already proved.
There is no new idea in it, and that is the whole report: `block/aesroundcore`
is the round at every key size, and `block/aeskeyexpand192` is the AES-256
schedule generator run with `NK = 6`.

### What is different is an absence

At Nk = 8 a word whose index is 4 mod 8 takes a bare `SubWord`. **At Nk = 6
there is no such rule.** An absence is the hardest thing to write a test for,
because a schedule that wrongly applied the rule would still produce 208
plausible bytes. FIPS 197 Appendix A.2 handles it the only way that works: it
publishes *all* 208, so the first word a spurious rule touched is named.

### The conveyor is per length, not per key size

`block/rkappend208` and `block/rkconsume208` are a second pair, not the 240
pair at an offset. The difference between them is the **number of moves**, so
it is different text — the same reason `keccak/sponge136` and `sponge168` are
two files. The generators take the length as an argument, so the pair is one
command each and the duplication lives in the artifact rather than the source.

### Why `aes/encrypt128` keeps its window, and does not get the conveyor

The plan for the key sizes had a fourth step: migrate `aes/encrypt128` onto
the conveyor as well, so all three ciphers are one shape. **Half of it is
done** — `aes/encrypt128` includes `block/aesroundcore` and
`block/aesroundlast` like the other two, instruction for instruction
unchanged. The conveyor half is **deliberately not done**, and the reason is
worth recording because it is not the reason anyone would guess.

It is not cost. A 176-cell buffer turned eleven times is about two thousand
moves against a block of AES at 114 million steps, which is nothing.

It is that **the modes have already built on the footprint**. Every one of
the six puts its own state immediately above the cipher's frame, starting at
`0x375` — the first cell after the S box: `aes/ctr128`'s `savedkey` and
counter, `aes/cmac128`'s `K1`, `K2` and tweak, `aes/gcm128`'s `K`, `J0`,
`EK0` and `H`. A round-key buffer for a conveyor would have to live in
exactly that region, so the migration is not a change to one cipher — it is
a re-lay of six gated modes' tapes, with the regression risk that carries.

And at Nk = 4 the conveyor buys nothing the window does not already have.
The stored schedule exists because at Nk = 6 and 8 the window produces words
faster than the rounds consume them, so the rates disagree and a just-in-time
shape would need an index. **At Nk = 4 the rates match exactly** — four words
made, four rounds consume them — which is why `aes/encrypt128` was written
that way in the first place and why it is still right.

So the three ciphers share their round and differ in their schedule, which is
the shape FIPS 197 itself has. Unifying the last third is available, costs a
re-lay of six modes, and should be a decision rather than a tidy-up.

### What this does and does not finish

All three key sizes encrypt. **Decryption is still AES-128 only**, and the
six modes still name `block/aes128encrypt`, so pointing CTR or GCM at a
192- or 256-bit key is a further piece of work and not a flag.

## Traps that have actually bitten

- **A GATE THAT IS RUN BY HAND DOES NOT TELL YOU WHEN IT STOPPED FITTING.**
  `[resources] ram_gb` was 4, and `tools/dkbatch.sh` -- which asks Cryptol
  every dual-oracle question in one process -- peaks at **5,280 MiB**. Both
  reaper guests therefore failed all three of tier 8a while the container
  lane was green, which reads exactly like a platform defect and is nothing
  of the kind: the container had the whole 32 GiB host. The measurement that
  settled it is cheap and worth repeating — sample the cryptol process's own
  `VmHWM` while the batch runs.
  **The part worth keeping** is the second measurement. The obvious suspect
  was the sixteen AES-192/256 vectors added just before the first run in a
  while; removing them changes the peak by nine mebibytes, 0.2%. The ceiling
  had been passed long before, and no run had said so because nobody had run
  it. *Raising a number because a failure appeared after your change is how
  you hide the fact that your change was not the cause.*
  Note which way it scales: the memory is the **spec being resident**, so it
  grows when a primitive is added, not when a vector is. Adding a thousand
  vectors is nearly free; adding one more cipher is not.

- **A CONSTANT THAT SURVIVED THE FILE BECOMING A GENERATOR.** `aes/encrypt256`
  was written when there was one wide key size, and its read was
  `",>" * 31 + ","`. When the same text became the generator for both sizes,
  every count around it was parameterised and that 31 was not. At Nk = 6 the
  cipher **read eight bytes of the plaintext as if they were key**, and then
  produced sixteen plausible bytes — the exact failure shape this library
  keeps meeting, an answer that is wrong and looks like an answer. The FIPS
  197 C.2 vector caught it, but only because a vector existed; no contract
  can see a program that read the right NUMBER of bytes into the right cells
  from the wrong part of the input. The guard is now in both program
  generators: count the `,` and `.` in the text they just produced and assert
  it against the width their own IO header line promises. **A generated
  header that states a width is a claim, and a claim near a generator is
  cheap to check.**

- **A BLOCK THAT PLACES ITS NEIGHBOUR, AND A CALLER THAT LEFT A GAP.**
  `block/rkappend240` lays the schedule buffer at **its own plus four**,
  immediately after the four staging cells — that is not a parameter, it is
  the block's text. `block/aeskeyexpand256` put the staging word at 896 and
  the buffer at 900 and so left four cells between them, and every append
  landed a word early. The expanded key came out **shifted by one word:
  correct at the tail, missing `w0` at the head** — and the cipher built on
  it produced sixteen plausible bytes. No contract could see it, because
  every cell the block touched was a cell it was entitled to touch.
  What found it was the FIPS 197 Appendix A.3 vector naming the wrong bytes
  at offset nought, which is the argument for a schedule being a PROGRAM with
  published vectors rather than a block proved only through a cipher: a
  cipher vector says the answer is wrong, and this one said *which word*.
  The guard is now in the generator — `assert BUF == STAGE + 4` — because a
  relationship between two constants that two files must agree on is a thing
  to assert, not a thing to remember.

- **A CONTRACT THAT WAS TRUE OF THE ONLY CALLER THERE WAS.**
  `block/aeskeyexpand256` opened with one claim, `zero +57:+1139`, covering
  its temporaries, its counter, its buffer *and every cell between them*.
  That held for `aes/keyexpand256`, where nothing else is on the tape, and
  was false the moment a cipher included the same block — by then the S box
  is laid at 117 and the plaintext sits in the state at 82. It failed on the
  table's first datum, and once that was narrowed, on the plaintext's second
  byte. **A block may claim only the cells it owns**, and the broad claim is
  the tempting one precisely while there is a single caller to disprove it.
  `CONVENTIONS.md` §6 now carries the rule.

- **A VECTOR THAT PASSES BECAUSE IT SKIPS THE BROKEN PART.** `aes/gcm128`'s
  empty-input vector produced the right tag while two of its three call sites
  into `block/ghashstep` entered at the wrong cell — with no associated data
  and no plaintext, neither of those sites runs. The answer was correct *and*
  famous, which is the worst combination: a value you recognise is the one you
  stop interrogating. The guard is that every call site a program has should
  be reached by some vector, and the cheap way to know is a vector per path
  rather than per feature — here, one with AAD only, one with plaintext only,
  and one with both.

- **A `# TIER n` MARKER DROPPED MID-FILE STEALS EVERY LINE AFTER IT.** The
  suite's markers run until the next one, so adding `# TIER 7` beside a new
  check in the middle of the tier 2/4 region reassigned a hundred lines that
  had nothing to do with it — tier 7 went from 2 to 108 and tiers 2 and 4 each
  lost the same hundred. `bftier --fix` then wrote the wrong numbers down
  without complaint, because they *were* the numbers the file now described.
  **This is the second time**: the same mistake with `# TIER 5` during
  `aes/ctr128`. The rule is simply that a new check goes in the section that
  already exists for its tier, however far away that is in the file, and a
  marker is only ever added when a tier genuinely begins there. The tell is a
  `--fix` diff where one tier's count jumps by about as much as another's
  drops.

- **A GUARD THAT STEPS THE WRONG WAY LANDS ON DATA AND CORRUPTS IT SILENTLY.**
  `aes/cbcdec128`'s loop flag sits one cell above the "is the count nonzero"
  flag, and the guard stepped left instead of right — onto the length's own
  high byte, which it then incremented once per block. The count grew instead
  of shrinking and the run hit the interpreter's step limit with no indication
  of which loop. A wrong *direction* in a one-cell hop is the cheapest mistake
  to make and among the dearest to read back, because the corrupted cell is
  usually someone else's live data rather than scratch. Writing the control
  cells into the tape map in order, with their addresses, is what makes "step
  left to reach `more`" wrong on sight.

- **A FLAG THAT COUNTS INSTEAD OF SIGNALLING.** The "is this two-byte count
  nonzero" idiom raises its flag once per nonzero byte, so it holds **2** when
  both bytes are set. Every use of it was a loop condition, where any nonzero
  value behaves the same, until one was used as a guard — `flag[- body ]` runs
  the body *twice* at 2. The shape to watch for: an idiom whose contract is
  "nonzero means yes" being reused where the magnitude matters. The fix is to
  clear the flag inside the guard rather than decrement it, which makes the
  body run exactly once whatever the flag holds.

- **A GENERATED SKELETON CONTAINING THE GENERATOR'S METACHARACTERS.** A line
  written as `"%%block/copy16%% %d" % KEY` in Python arrives as
  `%block/copy16% 885`, because `%%` is that formatter's escape for one `%`.
  The include silently became prose: `bfexpand` ignored it, `bfdag` saw
  nothing missing because the block has other includers, and the lints have no
  opinion on a per cent sign. The key was never copied into the window and the
  only thing that complained was a pointer contract fifteen cells downstream.
  `bfinclude` now rejects `%name%` outright. **Skeletons are made of `%%`,
  `[]` and backslashes, which is most of what a formatter eats** — the safe
  form is concatenation, and the cheap check is to grep the generated file for
  the construct you meant to emit.

- **AN OFFSET THAT SHIFTS SOME CELL NUMBERS AND NOT OTHERS.** `%%block/x%% N`
  rebased the block's relative contracts and left its `@@PASTE@@ base` lines
  alone, so a block containing a paste silently only worked at offset nought.
  The failure surfaces far from the cause — a contract naming a cell nobody
  recognises — because the paste's own rebasing is correct arithmetic against
  the wrong origin. The general shape: **when a mechanism translates a frame,
  it has to translate everything in that frame that names a cell, and nothing
  that does not.** `Rn` is a length and must be left alone; a contract and a
  paste base are both cells and must both move.

- **A COPY WHERE A MOVE BELONGED IS NOT A SLOW MOVE.** Brainfuck's `[-x+y]`
  *adds* into the destination, so the copy-not-move rule has a twin that is
  easier to miss: a destination that is supposed to be empty and is not gives
  a silent wrong answer rather than a crash. In `aes/cbcenc128` the chain was
  copied into the state and handed back, so the ciphertext was later moved in
  on top of it and the next chaining value was the *sum* of the two. The first
  block was still right — a block is emitted before it is chained — so only a
  two-block message could show it. The guard is a `zero` contract on the
  destination immediately before the move, which is now there.

- **A DEDUP INSIDE A PASTED BODY IS A CHANGE TO EVERY CALLER, AND ONE REBUILD
  PASS WILL NOT FIND IT.** `keccak/sponge136` and `sponge168` each stated the
  same dead contract twice, once either side of their `; emit` line. Removing
  the duplicate looked like tidying one file. It was not: a paste takes the
  callee's body *up to* `; emit`, so the copy **above** that line lives inside
  the pasted body, and deleting it changed seven downstream artifacts —
  `cshake128`, `cshake256`, `kmac128`, `kmac256`, `sha3_256`, `shake128`,
  `shake256`.

  The part worth keeping is why it was not caught locally. `tools/rebuild.sh`
  iterates to a **fixpoint** precisely because a paste reads the callee's
  committed `.bf`, and the files are walked in directory order: `cshake128`
  comes before `sponge168`, so pass one gave it the *old* sponge. Pass two is
  what fixes that, and pass two was skipped on the argument that the gate's
  tier 9c asserts the same property. **It does — and that is exactly how this
  was found, as seven `FAIL regenerates` lines.** The argument was right about
  what tier 9c checks and wrong about what to do with it: the gate is a place
  to confirm the fixpoint, not a place to go looking for it, and the hour the
  skipped pass saved was spent twice over on a gate run that failed.

  The instruction counts had already been checked and were exactly right — the
  four splits added nothing and the thirteen pairs added two each, including
  `sha3_256` adding two rather than four, which *proved* the strip was working.
  A correct measurement of the thing that did not change says nothing about the
  thing that did; the change here was one comment line, in the one region a
  paste copies.

- **A `--fix` THAT REWRITES THE DOCUMENT IT CHECKS, AND HAD NO SELF-TEST.**
  `tools/bftier.pl --fix` sets a flag when it finds the tier table's separator
  row and **never clears it**, so every later three-column row in `HANDOFF.md`
  is rewritten as though it were a tier row. Eighteen separator lines became
  `| --- | --- | 0 |` and a header cell became `0`.

  The reason this is in the traps list rather than just the changelog: **that
  damage was repaired by hand in `c753e57` without the cause being found**, so
  it came straight back the next time `--fix` ran — the same tables, the same
  way. Repairing a corrupted artifact without identifying what corrupted it is
  not a fix, it is a delay, and the second occurrence cost more than the first
  because by then the tool had been cleared of suspicion.

  It was cleared because the wrong tool was suspected. `bftable.pl --fix` was
  blamed, tested on a copy, and exonerated — correctly; it only ever touched
  the two count columns. Both times the conclusion drawn was "the damage
  pre-existed", which was true and useless.

  `fix` now stops at the first line that is not a table row, never rewrites a
  separator, and **takes a directory so it can be self-tested** — which is the
  real defect. `check` had eight self-tests and `fix` had none, and a
  subcommand that rewrites a tracked file is the worse of the two to leave
  untested: its failure is a silent edit rather than a red line. There are now
  two tests, both polarities: a later table must survive `--fix` untouched, and
  a stale tier count must still be corrected, so the first cannot be satisfied
  by a `--fix` that has quietly stopped working.

- **A CONTRACT AFTER THE LAST INSTRUCTION IS NOT A CONTRACT.** `; ASSERT`
  attaches to the next instruction, so one written at the end of a program
  attaches to nothing and is never checked — while reading exactly like the
  ones that are. Seventeen programs carry twenty-two; see the section above for the
  list, for why `block/` skeletons are exempt, and for the one that is false as
  well as dead.

- **A ZERO BYTE FILE WITH A CARRIAGE RETURN IN ITS NAME IS INVISIBLE TO `ls`
  AND BREAKS EVERY GLOB.** A file list written from Python with the default
  newline on Windows gives every path a trailing `
`. A shell loop then
  creates `name<CR>.bf`. Windows cannot store a carriage return in a filename
  so MSYS encodes it as U+F00D, which means:

  - `ls` prints what looks like the same filename twice, because the terminal
    renders the escape and the eye slides over it
  - `grep` for a literal `
` in filenames finds nothing
  - `*/*.bf` matches it, `fopen` rejects the name, and every per-file loop in
    the suite fails on it

  It cost three gate failures that looked like three unrelated defects: a lint
  failure, a style failure, and tier 9d's pinned list of files with no
  `; INTERFACE`. Find them with Python and `0xE000 <= ord(c) <= 0xF8FF`, not
  with the shell. **Write file lists with `newline=""` or strip them.**

- **AND A CHECK THAT REPORTS A CAUSE IS NOT A CONFIRMED CAUSE.** The same
  episode produced two wrong diagnoses before the right one. `bflint` failed
  on a file inside a loop and passed on it alone, which was called a Windows
  host artifact -- it was a real second file, and the container found it
  exactly as the host had. Then a `grep` for carriage returns in file CONTENTS
  reported thousands, which was shell quoting; the contents were always clean.
  This document already says a failed check is not a negative result. The
  companion rule is that a *passing* check on the thing you suspect does not
  clear it either, until you know you tested the thing you meant to.


- **A `,>` READ PROLOGUE MAKES `; ASSERT ptr=` BLIND TO A SHORT READ.** The
  regression harness for `aes/decrypt128` read one byte too few on each of its
  two input lines, and both pointer assertions passed. With the pattern `,>`
  repeated, each read is paired with a move, so the final pointer is the same
  whether the line reads *n* bytes or *n-1* -- the assertion checks the
  pointer, and the pointer is right. The committed prologues all end with a
  comma: *n* commas and *n-1* moves. **That asymmetry is the whole reason
  their assertions are load-bearing**, and the harness had copied the shape
  without the property. The symptom was a result shifted by one byte, which
  looked like an arithmetic bug and cost an hour of looking in the wrong file.
  Write the prologue so the comma count and the move count differ, or the
  assertion below it is decoration.

- **A FILE THAT DOES NOT END IN A NEWLINE LOSES ITS LAST LINE, SILENTLY.**
  Shell's `while IFS= read -r line` does not deliver an unterminated final
  line. `tools/bfexpand.sh` read skeletons that way for the whole life of the
  project, so the last line of any skeleton without a trailing newline was
  dropped on the floor and never reached the `.bf`.

  Two files were in that state: `keccak/sponge136.skel` and
  `keccak/sponge168.skel`, and what each of them ended with was
  `; ASSERT ptr=0` — **a contract**. So both sponges carried a pointer
  assertion that had never once been evaluated, in a suite whose whole
  argument is that contracts are checked rather than believed.

  Both hold, which is the lucky half. The unlucky half is that nothing in the
  suite would have said if they did not, and nothing would ever have said,
  because the check was missing from the artifact rather than failing in it.

  It surfaced only because `%%include%%` moved skeleton reading out of the
  shell and into `tools/bfinclude.pl`, which terminates every line it emits —
  so the regeneration tier suddenly produced one line MORE than the committed
  file and failed. **A tool change exposed it; no amount of care would have.**
  `tests/run.sh` now checks that every `.skel` and every `.bf` ends with a
  newline, which is the cheap guard that should always have been there.

- **A PASTE SITE STANDS AT ITS BASE. `@@NAME@@ 82` DOES NOT MOVE THE POINTER.**
  The number after the macro rebases the callee's contracts and nothing else;
  `bfexpand` walks in by the callee's own `entry` offset *from wherever the
  pointer already is*. Every paste site in the library until now sat at base
  nought, where standing at nought happens to be correct, so the argument has
  never had to earn its meaning — and `aes/encrypt128` is the first file that
  pastes at 50, 57, 82 and 16 rather than at 0.

  Standing at nought while naming base 82 pastes the routine at nought **and
  rewrites its assertions to claim otherwise**, so the contracts do not merely
  fail to help, they are actively restated as lies about where the code is.

  What it looked like: every AES vector wrong, and the zero key on the zero
  block coming back as sixteen copies of `0x36` — which is Rcon for the tenth
  round, the last constant the file touches. A cipher returning one repeated
  byte means a step is writing over the state rather than transforming it, and
  the byte names which step.

  **The callee's rebased contracts would have caught this and mine would not.**
  My own `ASSERT ptr=0` either side of the paste passed, because with `exit=0`
  the pointer does come back to where it started — at the wrong place. The
  assertions that disagree are the ones *inside* the pasted body, and they only
  speak under `BFI_CONTRACTS=1`. The scratchpad interpreter used for quick
  local runs ignores comments, so it cannot see them. **Run a new paste site
  under contracts before trusting a vector to find the fault**, and write the
  walk to the base as `aead/chacha20poly1305` does, which says it in as many
  words: *to absorb's base, which is where a paste site always stands.*

- **A VALUE WANTED TWICE, SPENT ONCE. THIS IS THE THIRD TIME.** Every operand
  cell in this library is *consumed* by the routine that reads it — `xor8`
  halves both its operands away, `bytepad` spends its string, `xtime` spends
  its byte. That is deliberate and it is what makes the callers cheap. The
  standing rule "a copy is always an add, so clear the destination unless the
  adding is the point" covers the *destination*. **The dual rule is the one
  that keeps breaking: an operand cell is spent, so a value wanted again must
  be COPIED into it and not moved.**

  - `keccak/bytepad` spent KMAC's one-string flag; all eight vectors failed.
  - ParallelHash moved `bs` into `left_encode`, so every chunk after the first
    got a length of nought and the message never ran out.
  - `aes/keyexpand128` moved `rcon` into the exclusive or that applies it, so
    it was gone before `xtime` could make the next one. **Round constant 1 was
    right and every later one was nought.**

  All three passed every contract. The corruption stays inside the footprint
  and a spent cell is a legitimately empty cell, so nothing structural can see
  it — **only a vector can**, and in each case the vector that caught it was a
  published one. The diagnosis is quick when you look for it: the first wrong
  output differs from the right one by exactly the value that went missing.
  Here word 8 came back `f0c295f2` against `f2c295f2`, which is `0x02` — the
  second round constant, exactly.

- **`rebuild.sh` CANNOT BOOTSTRAP A NEW PASTE, AND ITS COMMENT SAYS IT CAN.**
  It iterates to a fixpoint rather than hard-coding a dependency order, which
  is right and which handles a *stale* callee. It does not handle an **absent**
  one. Skeletons are visited in `*/*.skel` order, so `aes/mixcolumn.skel` is
  reached before `idiom/xor8.skel` exists as a `.bf`; `bfexpand` then refuses
  to paste a file it cannot read, and `set -eu` takes the whole rebuild down
  on the first pass instead of retrying on the next.

  The symptom names the callee, so it is a one-minute diagnosis and no worse.
  **Expand a new routine and its callers by hand, in dependency order, once** —
  after that the `.bf` files exist and every later `rebuild.sh` converges
  normally. Left as a trap rather than fixed because the fix is not the
  one-liner it looks like: "retry a failure next pass" and "report a cycle"
  are the same observation seen twice, and telling them apart is the only
  thing the `max` counter currently does.

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

