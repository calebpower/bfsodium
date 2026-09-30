/*
 * bflint — the bfsodium legibility and portability checker (CONVENTIONS tier 9).
 *
 * Two problems this solves, both learned the hard way:
 *
 *  1. PORTABILITY. Our pinned interpreter treats ';' as a comment to end of
 *     line, so prose can contain commas and periods. Standard brainfuck has no
 *     such rule: every ',' and '.' in that prose is a live instruction. A file
 *     that only runs correctly under our own interpreter is not brainfuck. So
 *     the lint asks: with ';' comments stripped (our semantics) versus with
 *     only command bytes kept (canonical semantics), is the instruction stream
 *     IDENTICAL? If not, the file is non-portable and the offending lines are
 *     named. `--fix` rewrites the prose so it becomes portable.
 *
 *  2. LEGIBILITY. The conventions require a tape map, an IO header, and
 *     annotation rather than walls of unexplained command bytes.
 *
 * --fragment drops the second family and keeps the first. A block/ skeleton
 * is not a routine: it has no IO of its own and no tape of its own, because
 * it is a sequence of relative tokens that its includer places. Demanding a
 * TAPE MAP of it would be demanding a claim it is not in a position to make,
 * and the header would then be duplicated into the .bf at every include
 * site. The PORTABILITY rule still applies with full force -- a command byte
 * in a comment is a command byte wherever the comment ends up.
 *
 * Usage:
 *   bflint FILE...          check; exit 1 if any file fails
 *   bflint --fragment F...  check PORTABILITY only, for a block/ skeleton
 *   bflint --fix FILE...    rewrite comment prose in place to be portable
 *   bflint --selftest       prove the checker complains at broken input
 *
 * The --fix rewrite maps command bytes inside ';' comments to safe lookalikes:
 *   ,  -> (comma word)      .  -> (end of sentence, dropped or ';')
 *   -  -> _                 +  -> "plus"     < > -> "lt" "gt"     [ ] -> { }
 * It never touches bytes outside comments, so program semantics cannot change.
 */
#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static int is_cmd(int c) {
    return c=='>'||c=='<'||c=='+'||c=='-'||c=='.'||c==','||c=='['||c==']';
}

/* Replace a command byte appearing inside comment prose with safe text. */
static const char *safe_for(int c) {
    switch (c) {
        /* A prose comma is dropped OUTRIGHT rather than turned into a space.
         * A space would leave a double one, and in this project a double
         * space is punctuation -- CONVENTIONS says so, because a full stop
         * is an instruction and the double space is what ends a sentence
         * instead. Replacing a comma with one therefore reads as a sentence
         * break in the middle of a clause, which is worse than no comma. */
        case ',': return "";
        case '.': return ";";      /* sentence end: semicolon reads fine   */
        case '-': return "_";      /* hyphen in names                      */
        case '+': return " plus ";
        case '<': return " lt ";
        case '>': return " gt ";
        case '[': return "{";
        case ']': return "}";
    }
    return "";
}

/* Extract the instruction stream under a given comment policy. */
static char *stream(const char *src, size_t n, int honor_semicolons, size_t *out) {
    char *s = malloc(n + 1); size_t k = 0; int cmt = 0;
    for (size_t i = 0; i < n; i++) {
        int c = (unsigned char)src[i];
        if (honor_semicolons) {
            if (cmt) { if (c == '\n') cmt = 0; continue; }
            if (c == ';') { cmt = 1; continue; }
        }
        if (is_cmd(c)) s[k++] = (char)c;
    }
    s[k] = 0; *out = k; return s;
}

static char *slurp(const char *path, size_t *n) {
    FILE *f = fopen(path, "rb");
    if (!f) { perror(path); return NULL; }
    size_t cap = 1 << 16, len = 0; char *b = malloc(cap);
    int c;
    while ((c = fgetc(f)) != EOF) {
        if (len == cap) { cap <<= 1; b = realloc(b, cap); }
        b[len++] = (char)c;
    }
    fclose(f); b[len] = 0; *n = len; return b;
}

/* --fix: rewrite command bytes that appear inside ';' comments. */
static int fix_file(const char *path) {
    size_t n; char *src = slurp(path, &n);
    if (!src) return 1;
    size_t cap = n * 8 + 16, k = 0; char *out = malloc(cap);
    int cmt = 0, changed = 0;
    for (size_t i = 0; i < n; i++) {
        int c = (unsigned char)src[i];
        if (!cmt && c == ';') cmt = 1;
        else if (cmt && c == '\n') cmt = 0;
        if (cmt && is_cmd(c)) {
            const char *rep;
            /* A FULL STOP BETWEEN TWO ALPHANUMERICS IS NOT A SENTENCE END.
             * It is a version, a section number or a filename -- 1.1, 7.15,
             * sha256.bf -- and turning those into 1;1 and sha256;bf hides
             * what they are. An underscore is what this project's prose
             * already uses for exactly that: the routines say FIPS 180_4 and
             * SHA_256 because their authors hit this by hand. Matching the
             * dialect a human would have written is the whole job of --fix. */
            if (c == '.' && i > 0 && i + 1 < n &&
                isalnum((unsigned char)src[i - 1]) &&
                isalnum((unsigned char)src[i + 1])) {
                rep = "_";
            } else {
                rep = safe_for(c);
            }
            size_t rl = strlen(rep);
            memcpy(out + k, rep, rl); k += rl; changed = 1;
        } else {
            out[k++] = (char)c;
        }
    }
    if (changed) {
        FILE *f = fopen(path, "wb");
        if (!f) { perror(path); free(src); free(out); return 1; }
        fwrite(out, 1, k, f); fclose(f);
        printf("FIXED %s (comment prose made portable)\n", path);
    } else {
        printf("clean %s (no comment operators)\n", path);
    }
    free(src); free(out);
    return 0;
}

static int check_mode(const char *path, int quiet, int fragment);
static int check_file(const char *path, int quiet) { return check_mode(path, quiet, 0); }
static int check_mode(const char *path, int quiet, int fragment) {
    size_t n; char *src = slurp(path, &n);
    if (!src) return 1;
    int bad = 0;

    /* A "; ASSERT" line in a SKELETON is a DIRECTIVE, not prose. bfexpand
     * rewrites "ptr=+2" into "ptr=2" on its way to the .bf, so the plus
     * sign never reaches a committed file -- but it is sitting in the
     * skeleton, and a plain portability scan reads it as a command byte in
     * a comment. That is how this check first ran: it failed 80 of 98
     * skeletons, every one of them correct. The lines are blanked here,
     * keeping their length so diagnostics still name the right line, and
     * the .bf lint sees the rewritten contract with full force. */
    if (fragment) {
        size_t i = 0;
        while (i < n) {
            size_t j = i;
            while (j < n && (src[j] == 32 || src[j] == 9)) j++;
            if (j < n && src[j] == 59 && strncmp(src + j + 1, " ASSERT", 7) == 0)
                while (i < n && src[i] != 10) src[i++] = 32;
            while (i < n && src[i] != 10) i++;
            if (i < n) i++;
        }
    }

    size_t a_len, b_len;
    char *ours  = stream(src, n, 1, &a_len);   /* ';' honored (bfi)        */
    char *canon = stream(src, n, 0, &b_len);   /* canonical brainfuck      */

    if (a_len != b_len || memcmp(ours, canon, a_len) != 0) {
        bad = 1;
        if (!quiet) {
            printf("FAIL %s: NOT PORTABLE -- comment prose contains command bytes\n", path);
            printf("     %zu instructions under bfi, %zu under canonical brainfuck\n", a_len, b_len);
            /* name the offending lines */
            size_t line = 1; int cmt = 0;
            for (size_t i = 0; i < n; i++) {
                int c = (unsigned char)src[i];
                if (c == '\n') { line++; cmt = 0; continue; }
                if (!cmt && c == ';') { cmt = 1; continue; }
                if (cmt && is_cmd(c)) {
                    printf("     line %zu: stray '%c' in comment\n", line, c);
                    while (i < n && src[i] != '\n') i++;
                    i--; /* loop's ++ lands on the newline */
                }
            }
            printf("     run: bflint --fix %s\n", path);
        }
    }

    /* Legibility floor: required headers. A fragment is exempt; see the top. */
    if (!fragment && !strstr(src, "TAPE MAP")) {
        bad = 1; if (!quiet) printf("FAIL %s: missing TAPE MAP header\n", path);
    }
    if (!fragment && !strstr(src, "IO ")) {
        bad = 1; if (!quiet) printf("FAIL %s: missing IO signature header\n", path);
    }

    /* Legibility floor: no unexplained wall of command bytes on one line.
     * A FRAGMENT is exempt: a skeleton's long lines are normal -- a 257 byte
     * read prologue is one line by design -- and tools/bflayout wraps them on
     * the way to the .bf, which is where this rule then bites. */
    if (!fragment)
    {
        size_t line = 1, run = 0; int cmt = 0;
        for (size_t i = 0; i <= n; i++) {
            int c = (i < n) ? (unsigned char)src[i] : '\n';
            if (c == '\n') {
                if (run > 96) {
                    bad = 1;
                    if (!quiet) printf("FAIL %s: line %zu has %zu unannotated command bytes (max 96)\n", path, line, run);
                }
                run = 0; cmt = 0; line++; continue;
            }
            if (!cmt && c == ';') { cmt = 1; continue; }
            if (!cmt && is_cmd(c)) run++;
        }
    }

    if (!bad && !quiet) printf("PASS %s\n", path);
    free(src); free(ours); free(canon);
    return bad;
}

/* Self-test: the checker must complain at input a broken file would produce. */
static int selftest(void) {
    const char *tmp = "/tmp/bflint_selftest.bf";
    int fails = 0;

    /* (a) non-portable: a period inside comment prose */
    FILE *f = fopen(tmp, "wb");
    fputs("; TAPE MAP @0x00 x\n; IO in: none\n; a sentence. with a period\n+++\n", f);
    fclose(f);
    if (check_file(tmp, 1) == 0) { printf("SELFTEST FAIL: missed non-portable comment\n"); fails++; }
    else printf("selftest ok: caught non-portable comment prose\n");

    /* (b) missing headers */
    f = fopen(tmp, "wb"); fputs("+++[->+<]\n", f); fclose(f);
    if (check_file(tmp, 1) == 0) { printf("SELFTEST FAIL: missed missing headers\n"); fails++; }
    else printf("selftest ok: caught missing TAPE MAP and IO headers\n");

    /* (c) wall of command bytes */
    f = fopen(tmp, "wb");
    fputs("; TAPE MAP @0x00 x\n; IO in: none\n", f);
    for (int i = 0; i < 200; i++) fputc('+', f);
    fputc('\n', f); fclose(f);
    if (check_file(tmp, 1) == 0) { printf("SELFTEST FAIL: missed command wall\n"); fails++; }
    else printf("selftest ok: caught unannotated command wall\n");

    /* (d) a good file must PASS (no false positives) */
    f = fopen(tmp, "wb");
    fputs("; TAPE MAP  (home @0)\n;   @0x00  x  u8  a value\n; IO  in: one byte  out: one byte\n,        ; read\n.        ; write\n", f);
    fclose(f);
    if (check_file(tmp, 1) != 0) { printf("SELFTEST FAIL: false positive on a good file\n"); fails++; }
    else printf("selftest ok: clean file passes\n");

    /* (e) a FRAGMENT has no headers and that is not a fault. A block/ file
     * is a sequence of relative tokens, not a routine, so it has no IO and
     * no tape of its own to describe. */
    f = fopen(tmp, "wb"); fputs("; a block  all relative\n  [->>>+<<<]\n", f); fclose(f);
    if (check_mode(tmp, 1, 1) != 0) { printf("SELFTEST FAIL: fragment rejected for having no headers\n"); fails++; }
    else printf("selftest ok: a fragment needs no TAPE MAP\n");

    /* (f) but PORTABILITY still binds a fragment, and harder: a command
     * byte in a block comment lands in every file that includes it. */
    f = fopen(tmp, "wb"); fputs("; a block  with a comma, in the prose\n  [->>>+<<<]\n", f); fclose(f);
    if (check_mode(tmp, 1, 1) == 0) { printf("SELFTEST FAIL: fragment allowed a command byte in a comment\n"); fails++; }
    else printf("selftest ok: a fragment is still held to portability\n");

    /* (g) and the exemption must not leak: without --fragment the headers
     * are still required, or a routine could drop them by accident. */
    f = fopen(tmp, "wb"); fputs("; a block  all relative\n  [->>>+<<<]\n", f); fclose(f);
    if (check_mode(tmp, 1, 0) == 0) { printf("SELFTEST FAIL: headers no longer required without --fragment\n"); fails++; }
    else printf("selftest ok: the fragment exemption does not leak\n");

    /* (h) a relative contract is a DIRECTIVE and its plus sign is notation.
     * bfexpand rewrites "ptr=+2" to "ptr=2" before it reaches any .bf. */
    f = fopen(tmp, "wb"); fputs("; ASSERT ptr=+2\n; ASSERT zero +0:+9\n  [-]\n", f); fclose(f);
    if (check_mode(tmp, 1, 1) != 0) { printf("SELFTEST FAIL: a relative ASSERT was read as prose\n"); fails++; }
    else printf("selftest ok: a relative ASSERT is a directive\n");

    /* (i) but a plus sign in REAL prose is still caught, in a fragment. */
    f = fopen(tmp, "wb"); fputs("; two + two\n  [-]\n", f); fclose(f);
    if (check_mode(tmp, 1, 1) == 0) { printf("SELFTEST FAIL: a plus sign in fragment prose was allowed\n"); fails++; }
    else printf("selftest ok: a plus sign in prose is still caught\n");
    remove(tmp);
    if (fails) { printf("SELFTEST FAILED (%d)\n", fails); return 1; }
    printf("SELFTEST PASSED\n");
    return 0;
}

int main(int argc, char **argv) {
    if (argc < 2) { fprintf(stderr, "usage: %s [--fix|--selftest] FILE...\n", argv[0]); return 2; }
    if (strcmp(argv[1], "--selftest") == 0) return selftest();
    int fix  = (strcmp(argv[1], "--fix") == 0);
    int frag = (strcmp(argv[1], "--fragment") == 0);
    int start = (fix || frag) ? 2 : 1, bad = 0;
    for (int i = start; i < argc; i++)
        bad |= fix ? fix_file(argv[i]) : check_mode(argv[i], 0, frag);
    return bad ? 1 : 0;
}
