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

**ChaCha20 works, end to end.** The stream cipher matches RFC 8439 §2.4.2 — a
real, standards-conformant cipher, in brainfuck, checked against two
independent oracles.

| | |
|---|---|
| [`chacha20/add32.bf`](chacha20/add32.bf) | 32-bit little-endian add |
| [`chacha20/rotl32.bf`](chacha20/rotl32.bf) | rotate left by n |
| [`chacha20/xor32.bf`](chacha20/xor32.bf) | bitwise exclusive or |
| [`chacha20/quarterround.bf`](chacha20/quarterround.bf) | the quarter round (RFC 8439 §2.2.1) |
| [`chacha20/block.bf`](chacha20/block.bf) | the block function (RFC 8439 §2.3.2) |
| [`chacha20/stream.bf`](chacha20/stream.bf) | the stream cipher (RFC 8439 §2.4.2) |

Next: Poly1305, then the ChaCha20-Poly1305 AEAD, then SHA-256 and
HKDF-SHA-256. Keccak and
the ML-KEM / ML-DSA lattice math are the later mountain.

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
