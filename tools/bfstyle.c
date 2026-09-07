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
 *   2. Annotations live on their own line. A code line never contains ';'
 *      (a trailing annotation), because a chunked multi-line operation cannot
 *      carry one, and one form everywhere beats two forms sometimes.
 *   3. Annotation lines begin at column 0 with ';'.
 *   4. No run of more than MAXRUN consecutive code lines without an
 *      annotation, so no block goes unexplained.
 *
 * Usage:
 *   bfstyle FILE...        check; exit 1 if any file diverges
 *   bfstyle --report FILE... print each file's fingerprint (no pass/fail)
 *   bfstyle --selftest     prove the checker complains at divergent input
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAXRUN 12

static int is_cmd(int c) {
    return c=='>'||c=='<'||c=='+'||c=='-'||c=='.'||c==','||c=='['||c==']';
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

        if (is_comment) {
            f->cmt++;
            run = 0;
            /* rule 3: annotations start at column 0 */
            if (p != line) {
                f->badcomment++;
                if (!quiet) printf("FAIL %s:%d: annotation is indented; annotations start at column 0\n", path, lineno);
                bad = 1;
            }
            if (f->io_line < 0 && strstr(line, "IO ")) f->io_line = lineno;
            if (f->map_line < 0 && strstr(line, "TAPE MAP")) f->map_line = lineno;
        } else {
            /* rule 2: a code line must not carry a trailing annotation */
            int has_cmd = 0;
            for (char *q = line; *q; q++) if (is_cmd((unsigned char)*q)) { has_cmd = 1; break; }
            if (strchr(line, ';')) {
                f->trailing++;
                if (!quiet) printf("FAIL %s:%d: trailing annotation on a code line; put it on its own line above\n", path, lineno);
                bad = 1;
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

    /* trailing annotation is caught */
    h = fopen(tmp, "wb");
    fputs("; title\n; IO  in: none\n; TAPE MAP\n  ,   ; read a byte\n", h);
    fclose(h);
    if (scan(tmp, &f, 1) == 0) { printf("SELFTEST FAIL: missed a trailing annotation\n"); fails++; }
    else printf("selftest ok: caught a trailing annotation\n");

    /* indented annotation is caught */
    h = fopen(tmp, "wb");
    fputs("; title\n; IO  in: none\n; TAPE MAP\n   ; an indented note\n  ,\n", h);
    fclose(h);
    if (scan(tmp, &f, 1) == 0) { printf("SELFTEST FAIL: missed an indented annotation\n"); fails++; }
    else printf("selftest ok: caught an indented annotation\n");

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
