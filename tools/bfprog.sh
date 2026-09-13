#!/bin/sh
# bfprog.sh -- run a program from programs/ under the pinned broker.
#
#   sh tools/bfprog.sh programs/sha256.bf < myfile > digest.bin
#   cat myfile | sh tools/bfprog.sh programs/sha256.bf | ./tools/hx
#
# ONE ARGUMENT, AND THE BYTES COME DOWN STDIN. That is not a style choice: a
# program reads the BROKER's stdin, sequentially, and never seeks it, so there
# is nothing a filename would buy. Taking one would be a second way to say the
# same thing, and the only one of the two that cannot be a pipe -- this script
# could not then be fed by another program, by a process substitution, or by a
# here-document. The first version did take one and then immediately
# redirected it, which is a redirect spelled the long way.
#
# A program is not a routine and cannot be run the way one is. A routine is
# `bfi routine.bf < input`: pure computation, stdin to stdout, nothing else in
# the picture. A program needs a BROKER on the other end of its stdin and
# stdout, because what it does is sequence routines by spawning them, and the
# eight instructions cannot spawn anything on their own.
#
# So this does what tools/kat.sh does for a routine: it is the one place that
# knows how to invoke the thing, and every caller goes through it.
#
# WHAT THE SCRATCH DIRECTORY IS FOR. The program spawns `bfi` on a routine by
# NAME, resolved against the broker's working directory, and it writes a
# temporary file there. Handing it a directory of its own means it cannot
# collide with a parallel run, cannot read a stale temporary, and cannot leave
# anything behind -- the directory goes when this script returns.
#
# The broker and the interpreter both come from the brainstem checkout that
# tools/guest-setup.sh pinned and built. If it is missing this FAILS rather
# than skipping: "run it when present" is a skip and this project does not
# skip.
#
# The op timeout is generous rather than tight, and deliberately so. SHA-256 is
# about two seconds per 64 byte block under the pinned interpreter, so the
# first read of the digest waits out the whole hash -- a kilobyte of input is
# half a minute of silence before a single byte comes back. The point of the
# bound is that a HANG ends; it is not there to punish a slow run.
set -eu

BS=${BRAINSTEM_DIR:-/opt/brainstem}

[ $# -eq 1 ] || { echo "usage: bfprog.sh PROGRAM.bf < INPUT" >&2; exit 2; }
prog=$1

# A RELATIVE PROGRAM PATH MEANS WHAT IT MEANT WHERE IT WAS TYPED, so it is
# made absolute here, before the cd below moves the ground under it. Resolving
# it afterwards silently reinterprets it against the repository root, which is
# how
#
#   cat x | bfsodium/tools/bfprog.sh bfsodium/programs/sha256.bf
#
# run from the PARENT of the checkout came to report "no such program" for a
# file that was plainly there: it had been turned into bfsodium/bfsodium/...
# The script only ever worked when invoked from inside the repo, and nothing
# said so, because every caller in the suite happened to be.
case $prog in
    /*) ;;
    *)  prog=$(pwd)/$prog ;;
esac

repo=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$repo"

[ -r "$prog" ] || { echo "bfprog: no such program: $prog" >&2; exit 2; }
[ -x "$BS/build/brainstem" ] || {
    echo "bfprog: no broker at $BS/build/brainstem" >&2
    echo "bfprog: tools/guest-setup.sh builds it from BRAINSTEM_COMMIT" >&2
    exit 2
}
[ -x tools/bfi ] || { echo "bfprog: tools/bfi is not built" >&2; exit 2; }

d=$(mktemp -d)
trap 'rm -rf "$d"' EXIT

cp tools/bfi "$d/bfi"
cp "$prog" "$d/prog.bf"
# Every routine a program might spawn, by name, flattened into the scratch
# directory. Copied rather than symlinked because the broker resolves the name
# against its working directory and a symlink would reach back into the tree
# this is deliberately isolated from.
for r in */*.bf; do
    case "$r" in programs/*) continue ;; esac
    cp "$r" "$d/$(basename "$r")"
done

# stdin and stdout are inherited untouched: the shell has already connected
# them to whatever the caller meant, and the broker hands them to the program.
( cd "$d" && timeout 900 "$BS/build/brainstem" --op-timeout 600000 \
    -- ./bfi ./prog.bf )
