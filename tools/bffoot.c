/*
 * bffoot — prove that a routine's declared INTERFACE tells the truth.
 *
 * Every bfsodium routine carries a line like
 *
 *   ; INTERFACE entry=63 exit=0 footprint=0:67
 *
 * and tools/bfexpand.sh pastes the routine into a caller on the strength of it:
 * the caller walks in `entry` cells, runs the body, and trusts that nothing
 * outside `footprint` was disturbed so it can park its own variables just past
 * the end. That makes the line load-bearing, and until this checker existed it
 * was only a comment.
 *
 * It lied once, expensively. stagger's row 2 rotates left by two, which is an
 * exchange of the row's two halves, and that exchange stages EIGHT bytes at a
 * time through temps at 64 to 71 -- while the file declared 0:67. Standalone
 * that is invisible, because 68 to 71 are free zeros; pasted into the block
 * function those four cells were the first word of the saved original state, so
 * one word of the block came out with the ASCII of "expa" added to it. The
 * arithmetic was perfect. The declaration was wrong.
 *
 * The check is a straight-line walk of the instruction stream:
 *
 *   - every loop body must be pointer balanced (our convention), which is what
 *     makes one walk enough: a balanced body visits the same cells however many
 *     times it runs. An unbalanced loop is not rejected as wrong -- the indexed
 *     addressing routines use one deliberately -- but its excursion cannot be
 *     bounded statically, so a file that declares a footprint AND contains one
 *     is reported rather than quietly passed;
 *   - the lowest and highest cells the pointer ever reaches must lie inside the
 *     declared footprint;
 *   - the pointer where the read prologue ends must equal `entry`, and the
 *     pointer where the body ends must equal `exit`.
 *
 * "Prologue" and "body" mean exactly what bfexpand.sh means by them, because
 * the point is to check the thing bfexpand relies on: the prologue is the run of
 * read lines (only ',' and '>') and the comments between them; the body is
 * everything from there to the "; emit" line; the rest is output. A routine with
 * command bytes BEFORE its prologue is also reported, since a paste would
 * silently drop them.
 *
 * Usage:
 *   bffoot FILE...      check; exit 1 if any file fails
 *   bffoot --selftest   feed it the four defects it exists to catch, and one
 *                       clean routine, and confirm it calls each correctly
 */
/* mkstemp and fdopen are POSIX, not ISO C. tests/run.sh compiles with
 * -std=c99, which on glibc defines __STRICT_ANSI__ and so hides both; the
 * compiler then assumed int returns, and from GCC 14 an implicit declaration
 * is an error rather than a warning, so the suite would not build at all on a
 * current Linux guest. FreeBSD headers expose them regardless, which is why
 * this only ever failed off the development host. Ask for POSIX explicitly.
 */
#define _POSIX_C_SOURCE 200809L

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static int is_cmd(int c) {
    return c=='>'||c=='<'||c=='+'||c=='-'||c=='.'||c==','||c=='['||c==']';
}

/* Which of bfexpand's three sections an instruction came from. */
enum { SEC_HEAD, SEC_PROLOGUE, SEC_BODY, SEC_EMIT };

struct Ins { char op; size_t line; int sec; };

/* A read line: only ',' and '>' outside the comment, and at least one ','. */
static int is_read_line(const char *s, size_t n) {
    int comma = 0;
    for (size_t i = 0; i < n; i++) {
        int c = (unsigned char)s[i];
        if (c == ' ' || c == '\t' || c == '\n' || c == '\r') continue;
        if (c == ',') { comma = 1; continue; }
        if (c == '>') continue;
        return 0;
    }
    return comma;
}

/* Read a file, keeping command bytes outside ';' comments, tagging each with
 * bfexpand's section, and picking up the INTERFACE line if there is one. */
static struct Ins *load(const char *path, size_t *n,
                        long *entry, long *xit, long *lo, long *hi, int *have) {
    FILE *f = fopen(path, "rb");
    if (!f) { fprintf(stderr, "bffoot: %s: cannot open\n", path); return NULL; }
    size_t cap = 1u << 12, k = 0;
    struct Ins *ins = malloc(cap * sizeof *ins);
    if (!ins) { fclose(f); return NULL; }
    char line[4096]; size_t lno = 0;
    int sec = SEC_HEAD, pre = 0;
    *have = 0;
    while (fgets(line, sizeof line, f)) {
        lno++;
        char *semi = strchr(line, ';');
        if (semi) {
            const char *m = strstr(semi, "INTERFACE");
            if (m && !*have) {
                const char *e = strstr(m, "entry="), *x = strstr(m, "exit=");
                const char *fp = strstr(m, "footprint=");
                if (e && x && fp) {
                    char *end;
                    *entry = strtol(e + 6, NULL, 10);
                    *xit   = strtol(x + 5, NULL, 10);
                    *lo    = strtol(fp + 10, &end, 10);
                    *hi    = (*end == ':') ? strtol(end + 1, NULL, 10) : -1;
                    *have  = 1;
                }
            }
        }
        size_t upto = semi ? (size_t)(semi - line) : strlen(line);
        int is_comment_only = semi && upto == strspn(line, " \t");

        if (sec == SEC_HEAD && is_read_line(line, upto)) { sec = SEC_PROLOGUE; pre = 1; }
        else if (sec == SEC_PROLOGUE && pre) {
            if (is_read_line(line, upto) || is_comment_only) { /* still reading */ }
            else { sec = SEC_BODY; pre = 0; }
        }
        if (sec == SEC_BODY && strncmp(line, "; emit", 6) == 0) sec = SEC_EMIT;

        for (size_t i = 0; i < upto; i++) {
            if (!is_cmd((unsigned char)line[i])) continue;
            if (k == cap) { cap <<= 1; ins = realloc(ins, cap * sizeof *ins);
                            if (!ins) { fclose(f); return NULL; } }
            ins[k].op = line[i]; ins[k].line = lno; ins[k].sec = sec; k++;
        }
    }
    fclose(f);
    *n = k;
    return ins;
}

/* Returns 0 clean, 1 failed, and prints every finding. */
static int check(const char *path, int quiet) {
    size_t n; long d_entry = 0, d_exit = 0, d_lo = 0, d_hi = 0; int have = 0;
    struct Ins *ins = load(path, &n, &d_entry, &d_exit, &d_lo, &d_hi, &have);
    if (!ins) return 1;
    if (!have) {
        if (!quiet) printf("bffoot: %s: no INTERFACE line, not a pasteable routine\n", path);
        free(ins); return 0;
    }

    long *stk = malloc((n + 1) * sizeof *stk);
    long p = 0, seen_lo = 0, seen_hi = 0, sp = 0;
    long entry = -1, xit = -1;
    int fail = 0, head = 0;

    for (size_t i = 0; i < n; i++) {
        if (ins[i].sec == SEC_HEAD && !head) {
            printf("%s:%zu: a command byte before the read prologue; a paste "
                   "starts at the prologue and would silently drop it\n",
                   path, ins[i].line);
            fail = 1; head = 1;
        }
        /* The prologue ends, and the body ends, at the last instruction of each. */
        if (entry < 0 && ins[i].sec > SEC_PROLOGUE) entry = p;
        if (xit   < 0 && ins[i].sec > SEC_BODY)     xit   = p;
        switch (ins[i].op) {
            case '>': p++; if (p > seen_hi) seen_hi = p; break;
            case '<': p--; if (p < seen_lo) seen_lo = p;
                      if (p < 0) {
                          printf("%s:%zu: pointer moves left of cell 0\n", path, ins[i].line);
                          fail = 1;
                      }
                      break;
            case '[': stk[sp++] = p; break;
            case ']':
                if (sp == 0) { printf("%s:%zu: unmatched ]\n", path, ins[i].line); fail = 1; break; }
                if (stk[--sp] != p) {
                    printf("%s:%zu: loop body is not pointer balanced "
                           "(enters at %ld, leaves at %ld) so the footprint "
                           "cannot be bounded\n", path, ins[i].line, stk[sp], p);
                    fail = 1;
                }
                break;
        }
    }
    if (sp != 0) { printf("%s: unmatched [\n", path); fail = 1; }

    if (seen_hi > d_hi) {
        printf("%s: touches cell %ld but declares footprint %ld:%ld -- a caller "
               "that parks a variable at %ld would be silently corrupted\n",
               path, seen_hi, d_lo, d_hi, d_hi + 1);
        fail = 1;
    }
    if (seen_lo < d_lo) {
        printf("%s: touches cell %ld but declares footprint %ld:%ld\n",
               path, seen_lo, d_lo, d_hi);
        fail = 1;
    }
    if (entry < 0) { printf("%s: no body follows the read prologue\n", path); fail = 1; }
    else if (entry != d_entry) {
        printf("%s: the read prologue ends at cell %ld but entry=%ld is declared\n",
               path, entry, d_entry);
        fail = 1;
    }
    if (xit < 0) { printf("%s: no \"; emit\" line, so the body has no end\n", path); fail = 1; }
    else if (xit != d_exit) {
        printf("%s: the body ends at cell %ld but exit=%ld is declared\n",
               path, xit, d_exit);
        fail = 1;
    }

    if (!fail && !quiet)
        printf("bffoot: %s: entry=%ld exit=%ld footprint=%ld:%ld  (reaches %ld:%ld)\n",
               path, d_entry, d_exit, d_lo, d_hi, seen_lo, seen_hi);
    free(stk); free(ins);
    return fail;
}

/* ------------------------------------------------------------------ */
/* A checker that never fires is indistinguishable from a clean corpus, so
 * prove it fires: each case below is a routine with one defect deliberately
 * put back, modelled on the real ones. */

struct Case { const char *name; const char *body; int want_fail; };

static int selftest(void) {
    static const struct Case cases[] = {
        { "clean",
          "; INTERFACE entry=2 exit=0 footprint=0:5\n"
          "  ,>,>\n"                     /* prologue ends at 2 */
          "<<\n"
          "[->>>>>+<<<<<]\n"             /* reaches 5, balanced */
          "; emit\n"
          ".\n", 0 },
        { "prologue split over lines",
          "; INTERFACE entry=4 exit=0 footprint=0:5\n"
          "  ,>,>\n"
          "; continued\n"
          "  ,>,>\n"                     /* the rowrot shape: entry is 4, not 2 */
          "<<<<\n"
          "; emit\n"
          ".\n", 0 },
        { "footprint understated",
          "; INTERFACE entry=2 exit=0 footprint=0:5\n"
          "  ,>,>\n"
          "<<\n"
          "[->>>>>>+<<<<<<]\n"           /* reaches 6: the stagger defect */
          "; emit\n"
          ".\n", 1 },
        { "loop not pointer balanced",
          "; INTERFACE entry=2 exit=0 footprint=0:5\n"
          "  ,>,>\n"
          "<<\n"
          "[->>]\n"                      /* a walk: cannot be bounded */
          "<<\n"
          "; emit\n"
          ".\n", 1 },
        { "entry misdeclared",
          "; INTERFACE entry=3 exit=0 footprint=0:5\n"
          "  ,>,>\n"
          "<<\n"
          "; emit\n"
          ".\n", 1 },
        { "exit misdeclared",
          "; INTERFACE entry=2 exit=4 footprint=0:5\n"
          "  ,>,>\n"
          "<<\n"
          "; emit\n"
          ".\n", 1 },
        { "command bytes before the prologue",
          "; INTERFACE entry=2 exit=0 footprint=0:5\n"
          "+++\n"                        /* a paste would drop this */
          "  ,>,>\n"
          "<<\n"
          "; emit\n"
          ".\n", 1 },
        { "comment prose is not code",
          "; INTERFACE entry=2 exit=0 footprint=0:5\n"
          "; this line has a comma, a period. and >>>>>>>> arrows\n"
          "  ,>,>\n"
          "<<\n"
          "; emit\n"
          ".\n", 0 },
    };
    int bad = 0;
    for (size_t i = 0; i < sizeof cases / sizeof *cases; i++) {
        char path[] = "/tmp/bffoot-selftest-XXXXXX";
        int fd = mkstemp(path);
        if (fd < 0) { perror("mkstemp"); return 1; }
        FILE *f = fdopen(fd, "w");
        fputs(cases[i].body, f);
        fclose(f);
        printf("--- %s (expect %s)\n", cases[i].name,
               cases[i].want_fail ? "a complaint" : "silence");
        int got = check(path, 1);
        remove(path);
        if (got != cases[i].want_fail) {
            printf("SELFTEST FAIL: %s -> %d, wanted %d\n",
                   cases[i].name, got, cases[i].want_fail);
            bad = 1;
        }
    }
    printf(bad ? "bffoot --selftest: FAILED\n" : "bffoot --selftest: ok\n");
    return bad;
}

int main(int argc, char **argv) {
    if (argc == 2 && strcmp(argv[1], "--selftest") == 0) return selftest();
    if (argc < 2) { fprintf(stderr, "usage: %s FILE... | --selftest\n", argv[0]); return 2; }
    int fail = 0;
    for (int i = 1; i < argc; i++) fail |= check(argv[i], 0);
    return fail;
}
