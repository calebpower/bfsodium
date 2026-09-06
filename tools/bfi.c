/*
 * bfi.c — the pinned reference brainfuck interpreter for bfsodium.
 *
 * bfsodium's crypto is written in brainfuck, so "what does this program mean?"
 * must have exactly one answer. This interpreter *is* that answer: the frozen
 * semantics profile every bfsodium primitive is written against and every KAT
 * is run through. It is deliberately tiny and dependency-free (C99) so it is
 * itself reviewable.
 *
 * Frozen semantics (see CONVENTIONS.md):
 *   - cells are unsigned 8-bit and wrap mod 256 (relied upon as byte arithmetic);
 *   - the tape is unbounded to the right, grown on demand and zero-filled;
 *   - moving left of cell 0 is a hard error (bfsodium code never does this) —
 *     surfacing it catches pointer-discipline bugs instead of hiding them;
 *   - ',' at end-of-input leaves the current cell UNCHANGED (primitives read an
 *     exact, known byte count, so this never fires mid-input);
 *   - '.' and ',' are raw bytes — no newline translation, no encoding;
 *   - every byte that is not one of ><+-.,[] is a comment and ignored.
 *
 * Usage:  bfi program.bf < input > output
 * Exit:   0 ok; 2 usage/parse/OOM; 3 pointer moved left of cell 0.
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static void die(const char *msg) { fprintf(stderr, "bfi: %s\n", msg); exit(2); }

int main(int argc, char **argv) {
    if (argc != 2) { fprintf(stderr, "usage: %s program.bf\n", argv[0]); return 2; }

    FILE *f = fopen(argv[1], "rb");
    if (!f) { perror("bfi: open program"); return 2; }

    /* Load the program, keeping only command bytes (everything else is comment). */
    size_t cap = 1u << 16, n = 0;
    char *prog = malloc(cap);
    if (!prog) die("out of memory");
    int ch;
    while ((ch = fgetc(f)) != EOF) {
        if (ch=='>'||ch=='<'||ch=='+'||ch=='-'||ch=='.'||ch==','||ch=='['||ch==']') {
            if (n == cap) { cap <<= 1; prog = realloc(prog, cap); if (!prog) die("out of memory"); }
            prog[n++] = (char)ch;
        }
    }
    fclose(f);

    /* Precompute matching-bracket jumps so loops are O(1) to skip. */
    size_t *jump = malloc(n * sizeof *jump);
    size_t *stk  = malloc(n * sizeof *stk);
    if ((n && !jump) || (n && !stk)) die("out of memory");
    size_t sp = 0;
    for (size_t i = 0; i < n; i++) {
        if (prog[i] == '[') stk[sp++] = i;
        else if (prog[i] == ']') {
            if (sp == 0) die("unmatched ]");
            size_t o = stk[--sp];
            jump[o] = i; jump[i] = o;
        }
    }
    if (sp != 0) die("unmatched [");
    free(stk);

    /* Tape: unbounded to the right, grown on demand and zero-filled. */
    size_t tcap = 1u << 16;
    unsigned char *tape = calloc(tcap, 1);
    if (!tape) die("out of memory");
    size_t p = 0;

    for (size_t ip = 0; ip < n; ip++) {
        switch (prog[ip]) {
            case '>':
                if (++p == tcap) {
                    size_t old = tcap; tcap <<= 1;
                    unsigned char *t = realloc(tape, tcap);
                    if (!t) die("out of memory (tape)");
                    tape = t; memset(tape + old, 0, tcap - old);
                }
                break;
            case '<':
                if (p == 0) { fprintf(stderr, "bfi: pointer moved left of cell 0\n"); return 3; }
                --p;
                break;
            case '+': tape[p]++; break;            /* wraps mod 256 */
            case '-': tape[p]--; break;            /* wraps mod 256 */
            case '.': putchar(tape[p]); break;
            case ',': { int in = getchar(); if (in != EOF) tape[p] = (unsigned char)in; } break;
            case '[': if (tape[p] == 0) ip = jump[ip]; break;
            case ']': if (tape[p] != 0) ip = jump[ip]; break;
        }
    }

    fflush(stdout);
    free(tape); free(jump); free(prog);
    return 0;
}
