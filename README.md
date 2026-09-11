# bfsodium

A cryptography library written in brainfuck.

Yes, really. Post-quantum is on the roadmap. This is fine.

## What

bfsodium implements real, standards-conformant cryptographic primitives in
**legible, hand-structured brainfuck** — committed as reviewable source (the
difference between committing assembly and committing a binary blob), not
minified compiler output. It is pure computation: plain stdin/stdout, no
syscalls, randomness supplied as input, so every run is deterministic and
replayable.

Start with **[CONVENTIONS.md](CONVENTIONS.md)** — the rulebook every `.bf` file
obeys: the frozen machine model, tape maps, pointer discipline, the idiom
vocabulary, and the testing protocol (nine tiers, including a style-consistency
check and a legibility check). **[IDIOMS.md](IDIOMS.md)** is the
vocabulary itself: the handful of patterns everything is built from, each with
its tape contract.

## Status

**The whole v1 symmetric set works.** ChaCha20 matches RFC 8439 §2.4.2,
Poly1305 matches §2.5.2, the AEAD that combines them matches §2.8.2 —
ciphertext and tag both — SHA-256 matches FIPS 180-4 padding and all, and
HKDF-SHA-256 matches every vector in RFC 5869 Appendix A. In brainfuck,
checked against two independent oracles.

It is **correct, not safe**: brainfuck branches on data, so there is no
constant-time story and cannot be one, and nothing is zeroized. See
*Named non-goals* in CONVENTIONS.md. Do not encrypt anything you care about.

| | |
|---|---|
| [`idiom/add8.bf`](idiom/add8.bf) | add with carry, the kernel under everything |
| [`chacha20/add32.bf`](chacha20/add32.bf) | 32-bit little-endian add |
| [`chacha20/rotl32.bf`](chacha20/rotl32.bf) | rotate left by n |
| [`chacha20/xor32.bf`](chacha20/xor32.bf) | bitwise exclusive or |
| [`idiom/and32.bf`](idiom/and32.bf) | bitwise and |
| [`idiom/rotr32.bf`](idiom/rotr32.bf) | rotate right by n |
| [`idiom/shr32.bf`](idiom/shr32.bf) | shift right by n |
| [`chacha20/qrloop.bf`](chacha20/qrloop.bf) | the quarter round (RFC 8439 §2.2.1) |
| [`chacha20/blockloop.bf`](chacha20/blockloop.bf) | the block function (RFC 8439 §2.3.2) |
| [`chacha20/blockkeep.bf`](chacha20/blockkeep.bf) | the block, keeping the key and nonce |
| [`chacha20/stream.bf`](chacha20/stream.bf) | the stream cipher (RFC 8439 §2.4.2) |
| [`poly1305/add136.bf`](poly1305/add136.bf) | 17-byte addition |
| [`poly1305/halve136.bf`](poly1305/halve136.bf) | 17-byte shift-right-one |
| [`poly1305/fold136.bf`](poly1305/fold136.bf) | the modular fold, 2^130 = 5 |
| [`poly1305/reducep136.bf`](poly1305/reducep136.bf) | canonical reduction below p |
| [`poly1305/dbl136.bf`](poly1305/dbl136.bf) | 17-byte shift-left-one |
| [`poly1305/mulmod136.bf`](poly1305/mulmod136.bf) | multiply mod 2^130-5 |
| [`poly1305/clamp.bf`](poly1305/clamp.bf) | the r clamp (RFC 8439 §2.5) |
| [`poly1305/absorb.bf`](poly1305/absorb.bf) | one block: acc = (acc + blk) · r mod p |
| [`poly1305/poly1305.bf`](poly1305/poly1305.bf) | **the authenticator (RFC 8439 §2.5.2)** |
| [`aead/keygen.bf`](aead/keygen.bf) | the Poly1305 one-time key (RFC 8439 §2.6) |
| [`aead/chacha20poly1305.bf`](aead/chacha20poly1305.bf) | **the AEAD (RFC 8439 §2.8.2)** |
| [`sha256/round.bf`](sha256/round.bf) | one compression round |
| [`sha256/expand.bf`](sha256/expand.bf) | one message-schedule word |
| [`sha256/hashcore.bf`](sha256/hashcore.bf) | the hash, over memory then the wire |
| [`sha256/sha256.bf`](sha256/sha256.bf) | **SHA-256 (FIPS 180-4)** |
| [`sha256/hmac.bf`](sha256/hmac.bf) | HMAC-SHA-256 (RFC 2104) |
| [`sha256/hkdf.bf`](sha256/hkdf.bf) | **HKDF-SHA-256 (RFC 5869)** |

That is everything CONVENTIONS.md lists as v1. Keccak and the ML-KEM / ML-DSA
lattice math are the later mountain.

Run the suite with `sh tests/run.sh` (needs a C compiler and
[Cryptol](https://cryptol.net); `reaper test` provisions both). Where the
reaper site is out of reach, `sh tools/container-test.sh` runs the same suite in
a container — see *Running the suite* in [HANDOFF.md](HANDOFF.md), including
why that is the fallback and not the gate.

## What it can and cannot do

The limits below are interface facts, not implementation details — they are
what you hit first, and none of them are bugs.

**Input sizes are capped by the length prefixes.**

- Every variable-length primitive takes `len{2} LE`, so **65535 bytes is the
  maximum** message, plaintext or AAD. SHA-256 cannot hash a 64 KiB-plus file.
- `hmac` and `hkdf` take fixed **256-byte buffers** for the key, salt, IKM and
  info. Longer inputs do not fit the interface.

**Every primitive is one-shot.**

- There is no streaming or incremental form. You cannot feed a hash in chunks,
  and there is no session or context to carry between runs.
- The AEAD **seals only**. Opening is proved as a metamorphic property, not
  exposed as a callable entry point.
- Randomness is never generated. Where a primitive needs entropy it is supplied
  as input bytes, which is what keeps every run replayable.

**It is slow, and the numbers are the point rather than an apology.** Costs are
in `bfi` instructions, which are machine independent; the wall times are from a
modern x86-64 at roughly 750 million instructions a second.

| | instructions | wall |
|---|---|---|
| SHA-256 of 48 bytes | 1.2 billion | 2 s |
| AEAD, 32-byte AAD and 14-byte plaintext | 5.2 billion | 6 s |
| HKDF, 64-byte output | ≈22 billion | ≈29 s |
| AEAD, the full RFC 8439 §2.8.2 vector | 11.6 billion | — |

**Not present at all:** any public-key primitive — no X25519, no signatures, no
key exchange. No post-quantum anything; ML-KEM, ML-DSA and Keccak are deferred,
see *Scope and roadmap* in CONVENTIONS.md. No AES, SHA-3 or BLAKE. No encoding
helpers — no hex, base64 or JSON canonicalization.

**Not proven**, and named here rather than left to be discovered:

- **Differential fuzz is declared and not built.** There is documented
  precedent it would find things: every `mulmod136` vector shared a blind spot
  at bit 129, so a loop stopping one turn short passed all of them.
- **Sufficiency.** The v1 set is *complete* as CONVENTIONS §9 defines it.
  Nothing has yet shown it is *enough* for the downstream target.

## Correctness

Every primitive is checked against **two independent oracles** — the published
standard test vectors and a bit-precise [Cryptol](https://cryptol.net)
specification — and every assertion is **mutation-checked** (break the code,
watch the test fail, restore). Tests run through the pinned reference
interpreter `tools/bfi.c` and are gated as a
[reaper](https://github.com/axonibyte/reaper) tenant following its
`docs/testing-methodology.md`.

## Name

An homage to libsodium's *name*. bfsodium is **not** affiliated with, endorsed
by, or derived from libsodium, and uses none of its code.

## License

MIT. See [LICENSE](LICENSE).
