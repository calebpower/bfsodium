#!/bin/sh
# bfrun.sh -- run any routine in this library through programs/run.bf.
#
#   sh tools/bfrun.sh sha256.bf < framed-input > output
#   printf '\003\000abc' | sh tools/bfrun.sh sha256.bf | ./tools/hx
#
# THE CALLER DOES THE FRAMING, and that is the whole difference between this
# and tools/bfprog.sh programs/sha256.bf. Every routine declares its own IO
# line -- sha256 wants len{2} LE then the message, add8 wants two bytes, the
# AEAD wants a key and a nonce and aad and plaintext -- and a runner that
# tried to know all of them would be a worse version of each. So the bytes on
# stdin are whatever that routine's header says, exactly, and what comes back
# is whatever it writes.
#
# Read the routine's own skeleton for its IO line. That line is the contract.
#
# WHAT THIS SCRIPT ADDS is one byte: programs/run.bf reads a name length and
# then that many bytes of name before anything else, and writing the length
# by hand means typing an octal escape and counting characters, which is the
# kind of thing that is wrong once in twenty and looks like a broken routine
# when it is.
#
# The name is a BASENAME. The broker resolves it against its working
# directory, and bfprog.sh flattens every routine in the tree into the
# scratch directory it runs in, so "sha256.bf" finds sha256/sha256.bf. A path
# with directories in it will not resolve and is reduced to its last
# component here rather than failing obscurely later.
set -eu

[ $# -eq 1 ] || { echo "usage: bfrun.sh ROUTINE.bf < framed-input" >&2; exit 2; }

name=$(basename -- "$1")
n=${#name}

# 226 is not arbitrary: programs/run.bf declares a spawn frame whose length is
# 29 plus the name, in one byte, and does not carry into the second. Past that
# the declared length wraps and the broker answers BADLEN and exits 70 -- loud,
# but a long way from the cause. Refusing here says what is actually wrong.
[ "$n" -ge 1 ] || { echo "bfrun: empty routine name" >&2; exit 2; }
[ "$n" -le 226 ] || { echo "bfrun: routine name longer than 226 bytes: $name" >&2; exit 2; }

repo=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)

# The prefix and the caller's bytes are ONE stream: the program reads the name
# and then goes straight on reading the routine's input from the same handle.
{
    printf "\\$(printf '%03o' "$n")%s" "$name"
    cat
} | sh "$repo/tools/bfprog.sh" "$repo/programs/run.bf"
