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

**The ChaCha20-Poly1305 AEAD works.** The stream cipher matches RFC 8439
§2.4.2, the authenticator matches §2.5.2, and the AEAD that combines them
matches §2.8.2 — ciphertext and tag both — in brainfuck, checked against two
independent oracles.

It is **correct, not safe**: brainfuck branches on data, so there is no
constant-time story and cannot be one, and nothing is zeroized. See
*Named non-goals* in CONVENTIONS.md. Do not encrypt anything you care about.

| | |
|---|---|
| [`chacha20/add32.bf`](chacha20/add32.bf) | 32-bit little-endian add |
| [`chacha20/rotl32.bf`](chacha20/rotl32.bf) | rotate left by n |
| [`chacha20/xor32.bf`](chacha20/xor32.bf) | bitwise exclusive or |
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

Next: SHA-256, then HKDF-SHA-256. Keccak and the ML-KEM / ML-DSA lattice math
are the later mountain.

Run the suite with `sh tests/run.sh` (needs a C compiler and
[Cryptol](https://cryptol.net); `reaper test` provisions both).

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
