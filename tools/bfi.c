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
 *   - a ';' starts a comment that runs to end of line: every byte up to the
 *     newline is ignored, command bytes included. This is what lets bfsodium
 *     write real prose (with commas and periods, which are otherwise the ','
 *     and '.' instructions) in tape maps and block contracts. Outside a
 *     comment, every byte that is not one of ><+-.,[] is still ignored.
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

    /* '.' must reach the far end before the program blocks on ','.
     *
     * With stdout to a terminal, C stdio is line buffered and nobody notices.
     * With stdout to a PIPE it is fully buffered, so nothing this program
     * writes leaves the process until the buffer fills or the program ends --
     * and the fflush below is the only flush, which happens after the last
     * instruction has run. A bfsodium primitive is one-shot and reads a known
     * byte count, so that has never mattered here.
     *
     * It matters the moment anything holds a conversation with a bf program
     * over a pipe: the request sits in this buffer, the far end blocks reading
     * a request that was never sent, this program blocks on ',' awaiting a
     * reply that cannot come, and the only symptom is a hang with no output
     * and no core. That is what happens today if you point a broker at bfi,
     * and it is not a defect anyone would find by reading the failure.
     *
     * Unbuffered is the fix. Line buffering is not: 0x0a is an ordinary data
     * byte here, not a terminator. The cost is one write(2) per '.', which is
     * invisible next to a primitive that spends millions of instructions
     * between them. */
    setvbuf(stdout, NULL, _IONBF, 0);

    FILE *f = fopen(argv[1], "rb");
    if (!f) { perror("bfi: open program"); return 2; }

    /* Contract assertions. A bfsodium routine states where the pointer must be
     * and which cells must be clear at a given point; those statements live in
     * comments, so a plain interpreter ignores them, and BFI_CONTRACTS makes
     * this one check them EVERY time execution reaches that point, which is
     * what turns an interface from a comment that might lie into a fact. */
    struct Assertion { int kind; size_t a, b; size_t line; };
    struct Assertion *asr = NULL; size_t nasr = 0, casr = 0;
    size_t *astart = NULL, *acount = NULL;
    size_t pend_first = 0, pend_n = 0;
    int contracts = (getenv("BFI_CONTRACTS") != NULL);

    /* Load the program, keeping only command bytes (everything else is comment). */
    size_t cap = 1u << 16, n = 0;
    char *prog = malloc(cap);
    size_t *srcline = malloc(cap * sizeof *srcline);   /* for diagnostics */
    astart = malloc(cap * sizeof *astart);
    acount = malloc(cap * sizeof *acount);
    if (!prog || !srcline || !astart || !acount) die("out of memory");
    int ch, in_comment = 0;
    size_t line = 1;
    char cbuf[512]; size_t clen = 0;
    while ((ch = fgetc(f)) != EOF) {
        if (ch == '\n') {
            if (in_comment) {
                cbuf[clen] = 0;
                /* "; ASSERT ptr=N" and "; ASSERT zero A:B" attach to the NEXT
                 * instruction, so they are checked wherever execution reaches
                 * it, including on every pass through a loop. */
                char *s = cbuf; while (*s == ' ') s++;
                if (strncmp(s, "ASSERT ", 7) == 0) {
                    s += 7; while (*s == ' ') s++;
                    struct Assertion na; na.line = line; na.a = na.b = 0; na.kind = -1;
                    if (strncmp(s, "ptr=", 4) == 0) { na.kind = 0; na.a = (size_t)strtoul(s + 4, NULL, 10); }
                    else if (strncmp(s, "zero ", 5) == 0) {
                        char *colon = strchr(s + 5, ':');
                        if (colon) { na.kind = 1; na.a = (size_t)strtoul(s + 5, NULL, 10);
                                     na.b = (size_t)strtoul(colon + 1, NULL, 10); }
                    }
                    if (na.kind >= 0) {
                        if (nasr == casr) { casr = casr ? casr * 2 : 64;
                                            asr = realloc(asr, casr * sizeof *asr);
                                            if (!asr) die("out of memory"); }
                        if (pend_n == 0) pend_first = nasr;
                        asr[nasr++] = na; pend_n++;
                    }
                }
            }
            clen = 0; line++; in_comment = 0; continue;
        }
        if (in_comment) { if (clen + 1 < sizeof cbuf) cbuf[clen++] = (char)ch; continue; }
        if (ch == ';') { in_comment = 1; clen = 0; continue; }
        if (ch=='>'||ch=='<'||ch=='+'||ch=='-'||ch=='.'||ch==','||ch=='['||ch==']') {
            if (n == cap) {
                cap <<= 1;
                prog = realloc(prog, cap);
                srcline = realloc(srcline, cap * sizeof *srcline);
                astart = realloc(astart, cap * sizeof *astart);
                acount = realloc(acount, cap * sizeof *acount);
                if (!prog || !srcline || !astart || !acount) die("out of memory");
            }
            srcline[n] = line;
            astart[n] = pend_first; acount[n] = pend_n; pend_first = 0; pend_n = 0;
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
    unsigned long long steps = 0;

    for (size_t ip = 0; ip < n; ip++) {
        steps++;
        if (contracts && acount[ip]) {
            for (size_t k = 0; k < acount[ip]; k++) {
                struct Assertion *A = &asr[astart[ip] + k];
                if (A->kind == 0 && p != A->a) {
                    fprintf(stderr, "bfi: %s:%zu: CONTRACT pointer is at %zu  expected %zu\n",
                            argv[1], A->line, p, A->a);
                    return 4;
                }
                if (A->kind == 1) {
                    for (size_t q = A->a; q <= A->b && q < tcap; q++)
                        if (tape[q]) {
                            fprintf(stderr, "bfi: %s:%zu: CONTRACT cell %zu should be clear  holds %u\n",
                                    argv[1], A->line, q, (unsigned)tape[q]);
                            return 4;
                        }
                }
            }
        }
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
                if (p == 0) { fprintf(stderr, "bfi: %s:%zu: pointer moved left of cell 0\n", argv[1], srcline[ip]); return 3; }
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

    if (getenv("BFI_COUNT")) fprintf(stderr, "bfi: %llu instructions executed\n", (unsigned long long)steps);
    fflush(stdout);
    free(tape); free(jump); free(prog);
    return 0;
}
