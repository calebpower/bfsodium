# bfsodium idioms

The vocabulary every `.bf` file is written in. A reviewer who learns these once
can read any block in the library, because blocks are annotated in their terms
(see [CONVENTIONS.md](CONVENTIONS.md) §5).

Notation: cells are named by their offset from the block's anchor. Every idiom
below is **pointer-neutral** — it ends with the pointer where it started — and
leaves every scratch cell it touched at zero, which is what lets blocks compose
by plain concatenation.

Each idiom's tape contract is stated as: what it reads, what it writes, what it
consumes, and what scratch it borrows.

---

## Core

### CLEAR — set a cell to zero
```
[-]
```
Consumes the cell. The workhorse for discarding a value you are done with (a
dropped carry, a spent counter).

### MOVE — add a cell into another, emptying the source
```
x[- >>+ <<]          ; move x into the cell two to its right
```
*Reads and consumes* `x`; *adds into* the destination. The destination is
**added to**, not overwritten — clear it first if you need assignment. This is
the only primitive way to relocate a value in brainfuck; everything else is
built from it.

### COPY — duplicate a cell, preserving the source
```
x[- >+ >>+ <<<]      ; x into dest and into a temp, x is now 0
>>> [-<<<+>>>]       ; put the temp back into x
```
*Reads* `x` (restored); *adds into* the destination; *borrows* one scratch cell
(restored to 0). brainfuck cannot read a cell without consuming it, so a copy is
always a move to two places followed by a move back. Every "preserve the
operand" step in the library is this.

### ADD — add one cell into another, modulo 256
Same as MOVE. The mod-256 wrap is the machine's, not ours, and we rely on it
(CONVENTIONS §1).

---

## Control

### IFZERO — set a flag when a value is zero
```
>+<                  ; assume zero: flag := 1
[ >-< [-] ]          ; if the value is nonzero, clear the flag and the value
```
Tests a value without a comparison instruction, which brainfuck does not have.
The trick throughout the library: **assume, then undo**. Set the answer
tentatively, then let a loop that only runs when the value is nonzero take it
back. Verified at 0, 1, 0x80 and 0xff.

### TOGGLE — flip a 0/1 cell
```
>+<                  ; f := 1
[->-<]               ; if t was 1: t := 0 and f := 0
>[-<+>]<             ; if f survived: t := 1
```
*Reads and writes* `t` (which must be 0 or 1); *borrows* `f` at `t+1`
(restored). Used by XOR8: toggling once per set bit computes parity, which is
exactly exclusive or.

---

## Arithmetic

### ADD8 — add with carry
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

### ADD32 — 32-bit little-endian add
Four ADD8 byte blocks, LSB first, each adding the addend byte and then the
carry from the byte below, with the carry out kept for the next byte. The carry
out of byte 3 is dropped (the sum is modulo 2^32). Shipped as
[`chacha20/add32.bf`](chacha20/add32.bf).

### HALVE — shift right one, with the low bit
With the value at the anchor, `q` at `+1`, `t` at `+2`, `f` at `+3`:
```
[->>>+<[-<+>>-<]>[-<+>]<<<]
```
*Consumes* the value; *writes* `q` (the value shifted right one) and `t` (its
low bit); *borrows* `f` (restored). Counts the value down, toggling `t` each
step and bumping `q` every second step. This is the only bit-extraction
primitive in the library — XOR8 is built entirely from it.

### DOUBLE — shift left one, with the high bit
COPY the value, then ADD8 it to itself: `x + x` is exactly `2x` modulo 256 with
the carry equal to bit 7. Cheaper than seven HALVEs, and it reuses a kernel that
is already proven. Used by ROTL32.

---

## Bitwise

brainfuck has no bitwise instruction.

**Why not a lookup table.** The original plan was a 256-by-256 XOR table. That
is the wrong shape here: the table would sit tens of thousands of cells from the
working frame, and since the only way to reach a cell is to walk to it, every
lookup would pay that distance twice. Building the table costs more still. Bit
decomposition keeps every access within a handful of cells of the frame.

### XOR8 — byte exclusive or
Eight steps. Each HALVEs both operands to get their low bits, TOGGLEs a flag
once per set low bit (so the flag ends as the exclusive or), adds the running
bit weight into the result when the flag is set, and doubles the weight.
Shipped inside [`chacha20/xor32.bf`](chacha20/xor32.bf).

### XOR32
Four XOR8 blocks over the byte pairs.

### ROTL32 — rotate left by n
`n` single-bit rotations under a counter. One bit rotation DOUBLEs all four
bytes and feeds each carry into the next byte cyclically; a doubled byte is
even, so adding the neighbour's carry bit cannot overflow and no second carry
pass is needed. Shipped as [`chacha20/rotl32.bf`](chacha20/rotl32.bf).

---

## Composition

brainfuck has no subroutines, so a composite primitive physically contains its
parts. Because brainfuck code is **position-independent** — a block that only
moves relative to where it starts behaves identically wherever it is placed — a
proven body can be reused verbatim at a different base rather than retyped at
new offsets. [`tools/qrasm.sh`](tools/qrasm.sh) does exactly this for the
ChaCha20 quarter round: it splices in the bodies of add32, xor32 and rotl32 and
adds glue that moves words into a shared workspace and back.

The glue obeys one rule, the same one CONVENTIONS §4 requires of hand-written
blocks: **every operation is entered with the pointer at cell 0 and leaves it at
cell 0.** Operations then compose by concatenation.
