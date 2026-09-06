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
vocabulary, and the testing protocol.

## Status

Early. v1 targets the symmetric set (ChaCha20, Poly1305, ChaCha20-Poly1305,
SHA-256, HKDF-SHA-256); **ChaCha20 is first**. Keccak and the ML-KEM / ML-DSA
lattice math are the later mountain.

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
