/*
 * hx — hex <-> binary for the bfsodium test harness.
 *
 *   hx        read binary from stdin, write lowercase hex (no spaces) to stdout
 *   hx -r     read hex from stdin (whitespace ignored), write raw bytes
 *
 * Test vectors are written as hex strings (readable, diff-friendly); the driver
 * uses this to feed bytes to `bfi` and to render its output for comparison.
 */
#include <stdio.h>
#include <string.h>

static int hexval(int c) {
    if (c >= '0' && c <= '9') return c - '0';
    if (c >= 'a' && c <= 'f') return c - 'a' + 10;
    if (c >= 'A' && c <= 'F') return c - 'A' + 10;
    return -1;
}

int main(int argc, char **argv) {
    int rev = (argc > 1 && strcmp(argv[1], "-r") == 0);
    int c;
    if (!rev) {
        while ((c = getchar()) != EOF) printf("%02x", c & 0xff);
    } else {
        int hi = -1;
        while ((c = getchar()) != EOF) {
            int v = hexval(c);
            if (v < 0) continue;                 /* skip spaces/newlines */
            if (hi < 0) { hi = v; }
            else { putchar((hi << 4) | v); hi = -1; }
        }
        if (hi >= 0) { fprintf(stderr, "hx: odd number of hex digits\n"); return 1; }
    }
    return 0;
}
