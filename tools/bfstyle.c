/*
 * bfstyle — the bfsodium style-consistency checker (CONVENTIONS tier 3,
 * source-as-data). It answers one question: "is the style the same across
 * every source file?"
 *
 * This exists because style drifted without anyone noticing. The hand-written
 * primitives annotated operations with a trailing comment on the code line,
 * while the assembled files put the annotation on its own line above the code
 * (which is the only form that works when a single pointer move is chunked
 * across several lines). Both were readable; together they were inconsistent,
 * and nothing in the suite could see it, because every other tier looks at
 * what the code COMPUTES, not at how it READS.
 *
 * The canonical style, enforced here:
 *   1. The file opens with a comment, and carries an "IO " section and a
 *      "TAPE MAP" section, in that order.
 *   2. An annotation on a code line sits in the annotation column, so that
 *      brainfuck reads straight down the left and English straight down the
 *      right. A chunked multi-line operation carries one on each of its lines,
 *      which is what made this form workable at all.
 *   3. A standalone annotation -- header, tape map row, section banner, or a
 *      contract that binds to the next instruction -- starts at column 0. An
 *      annotation that wrapped starts at the annotation column.
 *   4. No run of more than MAXRUN consecutive code lines without an
 *      annotation, so no block goes unexplained.
 *   5. No more than MAXLINES lines -- counted on the sibling .skel when there
 *      is one, because that is the file a person writes; see the note at
 *      MAXLINES for why that is not a loophole.
 *
 * Usage:
 *   bfstyle FILE...        check; exit 1 if any file diverges
 *   bfstyle --report FILE... print each file's fingerprint (no pass/fail)
 *   bfstyle --selftest     prove the checker complains at divergent input
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* The column an annotation starts in. tools/bflayout.pl lays the files out
 * to this column; the number is written again HERE, deliberately, rather than
 * shared. A checker that read its expectation from the thing it checks would
 * agree with itself whatever either did. If the two ever disagree, one of them
 * changed without the other, and that is exactly what should be reported. */
#define STYLECOL 64

#define MAXRUN 12

/* The budget was never a claim about 2000 lines. It was a claim about
 * PROVENANCE, measured with the only signal available when it was written: at
 * that point 0.19% of the committed brainfuck was hand-written and one
 * generated file ran to 903,110 lines, and nothing in the suite could tell a
 * written file from a generated one. Size stood in for that, on the reasoning
 * that anything past about 2000 lines had stopped being written and started
 * being generated.
 *
 * There is a direct signal now, so the budget follows the file a person
 * actually writes. A composite is inherently long: blockloop.bf is 4,209 lines
 * because qrloop, rowrot and stagger are spliced into it bodily, and no amount
 * of care would bring it under, while blockloop.skel -- what I wrote, and what
 * I would edit -- is 1,247. Budgeting the .bf there measures the splice, not
 * the writing.
 *
 * So a .bf with a sibling .skel is budgeted on the .skel. A .bf WITHOUT one
 * gets no exemption and no provenance, which is what keeps the rule biting on
 * transpiler output: mulmod136.bf and poly1305.bf have no skeleton and still
 * fail, at 15,826 and 27,811 lines.
 *
 * This is only sound because tests/run.sh separately proves that every .bf
 * equals bfexpand of its skeleton BYTE FOR BYTE, globbing every directory so
 * none can slip the net. Without that, a one line skeleton dropped beside a
 * generated file would buy an exemption it had not earned. The two are one
 * check in two halves; neither is worth much alone, and removing either
 * reopens the hole this budget exists to close.
 *
 * Rules 1 to 4 apply to the committed .bf in every case. Nothing about the
 * brainfuck's readability is traded away here -- rule 4, the cap on
 * unannotated runs, is what actually forbids a wall of command bytes, and it
 * still reads the .bf. */
#define MAXLINES 2000

static int is_cmd(int c) {
    return c=='>'||c=='<'||c=='+'||c=='-'||c=='.'||c==','||c=='['||c==']';
}

/* Count the lines of PATH, or -1 if it cannot be opened. */
static long count_lines(const char *path) {
    FILE *h = fopen(path, "rb");
    if (!h) return -1;
    long n = 0; int c, last = '\n';
    while ((c = fgetc(h)) != EOF) { if (c == '\n') n++; last = c; }
    if (last != '\n') n++;            /* a final line with no newline still counts */
    fclose(h);
    return n;
}

/* The file the budget applies to: a sibling .skel if there is one, else the
 * file itself. Writes the chosen path into buf. */
static const char *budget_target(const char *path, char *buf, size_t cap) {
    const char *dot = strrchr(path, '.');
    if (dot && strcmp(dot, ".bf") == 0) {
        size_t stem = (size_t)(dot - path);
        if (stem + sizeof ".skel" <= cap) {
            memcpy(buf, path, stem);
            memcpy(buf + stem, ".skel", sizeof ".skel");
            FILE *h = fopen(buf, "rb");
            if (h) { fclose(h); return buf; }
        }
    }
    return path;
}

struct fp { int has_title, io_line, map_line, trailing, badcomment, longrun, code, cmt; };

static int scan(const char *path, struct fp *f, int quiet) {
    FILE *fh = fopen(path, "rb");
    if (!fh) { perror(path); return 1; }
    memset(f, 0, sizeof *f);
    f->io_line = f->map_line = -1;

    char line[8192];
    int lineno = 0, run = 0, seen_nonblank = 0, bad = 0;
    while (fgets(line, sizeof line, fh)) {
        lineno++;
        char *p = line;
        while (*p == ' ' || *p == '\t') p++;
        int blank = (*p == '\n' || *p == '\r' || *p == '\0');
        if (blank) continue;

        int is_comment = (*p == ';');

        if (!seen_nonblank) {
            seen_nonblank = 1;
            f->has_title = is_comment;
            if (!is_comment && !quiet)
                printf("FAIL %s:%d: file does not open with a comment\n", path, lineno);
            if (!is_comment) bad = 1;
        }

        char *semi = strchr(line, ';');

        if (is_comment) {
            f->cmt++;
            run = 0;
            /* rule 3: a standalone annotation -- a header, a tape map row, a
             * section banner, a contract -- starts at column 0. An annotation
             * that ran past the width and wrapped down the right hand column
             * starts at the annotation column. Nothing sits anywhere else. */
            long col = p - line;
            if (col != 0 && col != STYLECOL - 1) {
                f->badcomment++;
                if (!quiet) printf("FAIL %s:%d: annotation starts at column %ld; a standalone one starts at\n"
                                   "     column 1 and a wrapped one at column %d\n",
                                   path, lineno, col + 1, STYLECOL);
                bad = 1;
            }
            if (f->io_line < 0 && strstr(line, "IO ")) f->io_line = lineno;
            if (f->map_line < 0 && strstr(line, "TAPE MAP")) f->map_line = lineno;
        } else {
            int has_cmd = 0;
            for (char *q = line; *q && (!semi || q < semi); q++)
                if (is_cmd((unsigned char)*q)) { has_cmd = 1; break; }
            /* rule 2: an annotation on a code line sits in the annotation
             * column, so that brainfuck reads straight down the left and
             * English straight down the right. */
            if (semi) {
                long col = semi - line;
                if (col != STYLECOL - 1) {
                    f->trailing++;
                    if (!quiet) printf("FAIL %s:%d: annotation is at column %ld  not %d; the right hand\n"
                                       "     column has to line up or there is no column to read\n",
                                       path, lineno, col + 1, STYLECOL);
                    bad = 1;
                }
                run = 0;   /* the line explains itself */
            }
            if (has_cmd) { f->code++; run++; }
            if (run > MAXRUN) {
                f->longrun++;
                if (!quiet) printf("FAIL %s:%d: %d code lines with no annotation (max %d)\n", path, lineno, run, MAXRUN);
                bad = 1;
                run = 0;   /* report once per offending block */
            }
        }
    }
    fclose(fh);

    /* The budget measures the hand-written file: a sibling .skel if there is
     * one, otherwise this file. Which one was measured is always printed, so
     * an exemption can never be silent. */
    char tbuf[4096];
    const char *target = budget_target(path, tbuf, sizeof tbuf);
    long tlines = (target == path) ? lineno : count_lines(target);
    if (tlines > MAXLINES) {
        bad = 1;
        if (!quiet) {
            if (target == path)
                printf("FAIL %s: %ld lines exceeds the %d line budget  and there is no\n"
                       "     skeleton beside it  so this is generated output rather than\n"
                       "     brainfuck a person wrote\n", path, tlines, MAXLINES);
            else
                printf("FAIL %s: its skeleton %s is %ld lines  which exceeds the %d line\n"
                       "     budget; the expansion may be long but the writing may not be\n",
                       path, target, tlines, MAXLINES);
        }
    }
    if (f->io_line < 0) { if (!quiet) printf("FAIL %s: no IO section\n", path); bad = 1; }
    if (f->map_line < 0) { if (!quiet) printf("FAIL %s: no TAPE MAP section\n", path); bad = 1; }
    if (f->io_line > 0 && f->map_line > 0 && f->io_line > f->map_line) {
        if (!quiet) printf("FAIL %s: IO section comes after TAPE MAP; the order is IO then TAPE MAP\n", path);
        bad = 1;
    }
    return bad;
}

static int selftest(void) {
    const char *tmp = "/tmp/bfstyle_selftest.bf";
    int fails = 0;
    struct fp f;
    FILE *h;

    /* a good file passes */
    h = fopen(tmp, "wb");
    fputs("; title\n; IO  in: one byte  out: one byte\n; TAPE MAP  (home @0)\n;   @0x00  x  u8\n; read\n  ,\n; write\n  .\n", h);
    fclose(h);
    if (scan(tmp, &f, 1) != 0) { printf("SELFTEST FAIL: good file rejected\n"); fails++; }
    else printf("selftest ok: canonical file passes\n");

    /* a column is only a column if everything lines up, so an annotation that
     * sits anywhere else is caught */
    h = fopen(tmp, "wb");
    fputs("; title\n; IO  in: none\n; TAPE MAP\n  ,   ; read a byte\n", h);
    fclose(h);
    if (scan(tmp, &f, 1) == 0) { printf("SELFTEST FAIL: missed an annotation off the column\n"); fails++; }
    else printf("selftest ok: caught an annotation off the column\n");

    /* and one ON the column passes, so the rule is a position and not a ban */
    char pad[STYLECOL + 32];
    memset(pad, ' ', sizeof pad);
    memcpy(pad, "  ,", 3);
    memcpy(pad + STYLECOL - 1, "; read a byte\n", sizeof "; read a byte\n");
    h = fopen(tmp, "wb");
    fputs("; title\n; IO  in: none\n; TAPE MAP\n", h); fputs(pad, h);
    fclose(h);
    if (scan(tmp, &f, 1) != 0) { printf("SELFTEST FAIL: an annotation on the column was rejected\n"); fails++; }
    else printf("selftest ok: an annotation on the column passes\n");

    /* a standalone annotation indented to no particular column is caught */
    h = fopen(tmp, "wb");
    fputs("; title\n; IO  in: none\n; TAPE MAP\n   ; an indented note\n  ,\n", h);
    fclose(h);
    if (scan(tmp, &f, 1) == 0) { printf("SELFTEST FAIL: missed an indented annotation\n"); fails++; }
    else printf("selftest ok: caught an indented annotation\n");

    /* but an annotation that WRAPPED down the column is not indented, it is
     * aligned, and it passes */
    memset(pad, ' ', sizeof pad);
    memcpy(pad + STYLECOL - 1, "; and the rest of the remark\n", sizeof "; and the rest of the remark\n");
    h = fopen(tmp, "wb");
    fputs("; title\n; IO  in: none\n; TAPE MAP\n", h); fputs(pad, h); fputs("  ,\n", h);
    fclose(h);
    if (scan(tmp, &f, 1) != 0) { printf("SELFTEST FAIL: a wrapped annotation was rejected\n"); fails++; }
    else printf("selftest ok: a wrapped annotation on the column passes\n");

    /* missing sections are caught */
    h = fopen(tmp, "wb"); fputs("; just a title\n  ,\n", h); fclose(h);
    if (scan(tmp, &f, 1) == 0) { printf("SELFTEST FAIL: missed missing sections\n"); fails++; }
    else printf("selftest ok: caught missing IO and TAPE MAP\n");

    /* an unannotated run is caught */
    h = fopen(tmp, "wb");
    fputs("; title\n; IO  in: none\n; TAPE MAP\n", h);
    for (int i = 0; i < MAXRUN + 3; i++) fputs("  +\n", h);
    fclose(h);
    if (scan(tmp, &f, 1) == 0) { printf("SELFTEST FAIL: missed a long unannotated run\n"); fails++; }
    else printf("selftest ok: caught a long unannotated run\n");

    /* an over-budget file with NO skeleton beside it is caught */
    const char *skel = "/tmp/bfstyle_selftest.skel";
    remove(skel);
    h = fopen(tmp, "wb");
    fputs("; title\n; IO  in: none\n; TAPE MAP\n", h);
    for (int i = 0; i < MAXLINES + 10; i++) fputs("; filler\n", h);
    fclose(h);
    if (scan(tmp, &f, 1) == 0) { printf("SELFTEST FAIL: missed an over-budget file\n"); fails++; }
    else printf("selftest ok: caught a file past the line budget\n");

    /* the same file, with a SHORT skeleton beside it, is a composite: long
     * because routines were spliced into it, not because anyone wrote it. The
     * budget follows the writing. */
    h = fopen(skel, "wb"); fputs("; a short skeleton\n@@SOMETHING@@ 0\n", h); fclose(h);
    if (scan(tmp, &f, 1) != 0) { printf("SELFTEST FAIL: a composite with a short skeleton was rejected\n"); fails++; }
    else printf("selftest ok: a long expansion of a short skeleton passes\n");

    /* and the exemption is not a blank cheque: a long skeleton still fails,
     * so the rule reaches the writing rather than being switched off by the
     * mere presence of a file. */
    h = fopen(skel, "wb");
    fputs("; a long skeleton\n", h);
    for (int i = 0; i < MAXLINES + 10; i++) fputs("; filler\n", h);
    fclose(h);
    if (scan(tmp, &f, 1) == 0) { printf("SELFTEST FAIL: an over-budget skeleton was let through\n"); fails++; }
    else printf("selftest ok: caught a skeleton past the line budget\n");

    remove(skel);
    remove(tmp);
    if (fails) { printf("SELFTEST FAILED (%d)\n", fails); return 1; }
    printf("SELFTEST PASSED\n");
    return 0;
}

int main(int argc, char **argv) {
    if (argc < 2) { fprintf(stderr, "usage: %s [--report|--selftest] FILE...\n", argv[0]); return 2; }
    if (strcmp(argv[1], "--selftest") == 0) return selftest();

    int report = (strcmp(argv[1], "--report") == 0);
    int start = report ? 2 : 1, bad = 0;

    if (report) printf("%-34s %6s %6s %6s %6s\n", "file", "code", "notes", "trail", "indent");
    for (int i = start; i < argc; i++) {
        struct fp f;
        int r = scan(argv[i], &f, report);
        if (report)
            printf("%-34s %6d %6d %6d %6d\n", argv[i], f.code, f.cmt, f.trailing, f.badcomment);
        else if (r == 0) printf("PASS %s\n", argv[i]);
        bad |= r;
    }
    return (bad && !report) ? 1 : 0;
}
