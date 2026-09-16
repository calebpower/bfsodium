#!/bin/sh
# guest-setup.sh — provision a disposable guest to run the bfsodium suite.
#
# Two things are needed beyond a base system:
#   a C compiler, for the pinned interpreter (tools/bfi.c), the hex tool and
#   the legibility lint; and
#   Cryptol plus z3, which are the second oracle every primitive KAT is
#   checked against.
#
# Cryptol is pinned to an explicit version so a guest built next month runs the
# same oracle as one built today.
#
# Two phases, and with NO ARGUMENT it runs both -- which is what reaper's
# [build] has always invoked and what it still invokes. The container fallback
# wants only the first half, because an apt transaction and a Cryptol tarball
# fetched from GitHub is the slow part and belongs in a cached image layer
# rather than in every run; Containerfile takes --toolchain and
# tools/container-test.sh then takes --build against the tree under test.
#
# The phases live here, in the file reaper already runs, rather than being
# reproduced in the Containerfile. A Containerfile carrying its own apt line
# and its own Cryptol version is a SECOND definition of the toolchain, and the
# day it drifts is the day the fallback starts passing what the gate would
# fail. There is one definition, and this is it.
#
# --SKIP-DEPS, WHICH MATTERS MORE THAN THE DISTRO BRANCHES. There are two of
# those, apt and pacman, and only apt is tested: it is what the gate guest and
# the container run, so every gate exercises it. pacman is a convenience for a
# development machine and nothing here will ever prove it works. It is
# labelled untested where it is written rather than left to look equal, which
# is the honest way to carry a branch nobody runs.
#
# That is also why the list stops at two. A script with a branch per package
# manager is a script nobody can test, and the untested ones rot quietly until
# somebody trusts one. --skip-deps is what covers everything else, and it
# covers it better than a guess at the right incantation would.
#
# The install is the ONLY part that cares. Everything else here --
# the pinned Cryptol version, the pinned brainstem commit, the build, the
# version report -- is the same on any Unix, and refusing to run it because
# the package manager is unfamiliar makes the script useless on a machine
# where every dependency is already installed. So --skip-deps skips the
# install and nothing else.
#
# What that leaves is an honest division: this script still says WHAT is
# needed and pins the versions that matter, and stops having an opinion about
# HOW it arrived. Arch, Fedora, NixOS and a hand-built compiler all work; none
# of them needs a line in here.
#
#   Needs, for the record: a C compiler, git, curl, z3, and cryptol 3.4.0.
#   The last two are only for the design proofs -- a guest that just RUNS
#   programs needs neither, which is why their absence is reported rather
#   than fatal once the install has been skipped.
set -eu

CRYPTOL_VERSION=3.4.0

# The P1 broker, pinned by commit. DECLARED AND NOT YET FETCHED: nothing in
# the suite consumes it, because programs/ does not exist yet. It is here
# rather than in a document because a pin belongs beside the other pin, and
# because of what its FORM is going to mean.
#
# A brainstem client -- a program under programs/, once there is one -- needs a
# broker on the far end to chain routines through, so the gate will need one
# built here the way it already builds Cryptol. Pinning it by SHA says this
# repository is tracking a moving dependency.
#
# MOVED ONCE SO FAR, from f1048de, and for a defect this repository found.
# programs/sha256 sent its exit frame, got its reply, and then deadlocked with
# the broker: a child started by spawn inherited the write end of the
# INTERPRETER's stdin, so closing the broker's copy no longer delivered end of
# input to it. brainstem c203c98 marks those descriptors close-on-exec. A pin
# that moves without a reason written beside it is a pin nobody trusts.
#
# WHEN THIS BECOMES A TAG, bfsodium is close to v1.0.0. brainstem gets tagged
# first, this pin changes from a SHA to that tag, and the change is the
# signal: a library that depends on an untagged commit of its infrastructure
# is not a library anybody should be depending on either. The version number
# is downstream of that, not a decision of its own.
BRAINSTEM_COMMIT=e8f6880183a7873c3c4bbaa29d9d1b02c6575493

usage() {
    echo "usage: guest-setup.sh [--toolchain|--build] [--skip-deps]" >&2
    echo "  (no phase flag)  provision the toolchain AND build the tools" >&2
    echo "  --toolchain      provision only: deps, cryptol, the pinned broker" >&2
    echo "  --build          build only: the interpreter and the checkers" >&2
    echo "  --skip-deps      do not install packages; everything else as usual" >&2
    exit 2
}

do_toolchain=yes
do_build=yes
do_deps=yes
phase=

# A LOOP RATHER THAN A CASE ON $1, because --skip-deps composes with the phase
# flags instead of replacing one. It is also why a second PHASE flag is an
# error rather than the last one winning: "--toolchain --build" reads like
# "both", means "build only", and would provision nothing.
while [ $# -gt 0 ]; do
    case "$1" in
        --toolchain) [ -z "$phase" ] || usage; phase=toolchain; do_build=no ;;
        --build)     [ -z "$phase" ] || usage; phase=build; do_toolchain=no ;;
        --skip-deps) do_deps=no ;;
        *)           usage ;;
    esac
    shift
done

if [ "$do_toolchain" = yes ]; then

# TWO PACKAGE MANAGERS, AND ONLY ONE OF THEM IS TESTED. apt is what the gate
# guest and the container run, so it is exercised on every single gate. pacman
# is not exercised by anything here and never will be -- it is a convenience
# for a development machine, and it is written down as untested rather than
# left to look equal.
#
# The list is the same in both because the NEEDS are the same; only the
# spelling differs. Arch's base-devel is Debian's build-essential, and neither
# carries cryptol -- that comes from the pinned tarball below on either.
#
# If neither manager is here, that is not an error worth inventing a third
# branch for. --skip-deps is the answer, and the message says so.
# EVERY GUEST NEEDS CRYPTOL, and an earlier version of this file was wrong
# about that in a way worth recording, because the mistake is the kind that
# sounds like analysis.
#
# The claim was: a proof is a statement over bitvectors, so tier 8 need only
# run on one guest; and Cryptol is not a runtime dependency of anything else,
# because the dual oracle's values are pinned literals. The first half is
# true. The second is FALSE. tools/dkat.sh runs `cryptol -b` ONCE PER VECTOR
# and compares the brainfuck against what the spec computes, live -- that is
# what makes it a dual oracle rather than a table of numbers. Tiers 2 and 4
# are a hundred and fifty seven checks and every one of them needs Cryptol.
#
# It was believed because tests/run.sh mentions cryptol in three places and
# none of them is a KAT. dkat.sh is a different file. Grepping one file and
# concluding something about the suite is how a plausible sentence gets
# written down; FreeBSD answered it with 156 failures in two tiers.
#
# security/hs-cryptol is what makes the fix possible, and quarterly carries
# 3.4.0 -- the version CRYPTOL_VERSION pins. THE VERSION IS VERIFIED BELOW
# rather than trusted, because pkg gives whatever its branch has and quarterly
# rolls: the day it carries 3.6.0, two guests would be running two oracles and
# the pin would have quietly stopped meaning anything.
#
# GUEST freebsd-15.1 FreeBSD
# GUEST ubuntu-26.04 Linux

if [ "$do_deps" = no ]; then
    echo "guest-setup: --skip-deps: assuming cc, git, curl, z3 and cryptol are present"
elif [ "$(uname -s)" = FreeBSD ]; then
    # clang and awk are in base and are VERIFIED rather than assumed -- "it is
    # in base" is exactly what was said about perl in the sibling project, and
    # perl was absent. git is not in base, and hs-cryptol brings z3 with it.
    echo "guest-setup: FreeBSD -- clang is in base; installing git and hs-cryptol"
    for _gs_t in cc awk; do
        command -v "$_gs_t" >/dev/null 2>&1 || {
            echo "guest-setup: $_gs_t is missing from base" >&2
            echo "guest-setup: this is not the guest bfsodium targets" >&2
            exit 1; }
    done
    pkg install -y git hs-cryptol >/dev/null
    # THE PIN IS CHECKED, NOT ASSUMED. pkg installs what its branch carries,
    # and the whole point of CRYPTOL_VERSION is that a guest built next month
    # runs the same oracle as one built today. If quarterly has moved, say so
    # here -- where it is one line to read -- rather than let two guests prove
    # things with two different Cryptols and call that a dual oracle.
    _gs_cv=$(cryptol --version 2>&1 | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
    if [ "$_gs_cv" != "$CRYPTOL_VERSION" ]; then
        echo "guest-setup: pkg gave cryptol $_gs_cv; this repository pins $CRYPTOL_VERSION" >&2
        echo "guest-setup: security/hs-cryptol has moved off the pinned version." >&2
        echo "guest-setup: either move CRYPTOL_VERSION to match both guests, or" >&2
        echo "guest-setup: build the pinned one here. Do not run two oracles." >&2
        exit 1
    fi
elif command -v apt-get >/dev/null 2>&1; then
    echo "guest-setup: apt toolchain (C compiler, z3, curl)"
    export DEBIAN_FRONTEND=noninteractive
    apt-get update -qq
    apt-get install -y -qq build-essential z3 curl ca-certificates git >/dev/null
elif command -v pacman >/dev/null 2>&1; then
    echo "guest-setup: pacman toolchain (C compiler, z3, curl) -- UNTESTED by the gate"
    pacman -Sy --needed --noconfirm base-devel z3 curl ca-certificates git >/dev/null
else
    echo "guest-setup: no apt-get and no pacman on this system." >&2
    echo "guest-setup: install a C compiler, git, curl and z3 yourself, then" >&2
    echo "guest-setup: re-run with --skip-deps. Everything else here is" >&2
    echo "guest-setup: the same on any Unix and does not need a branch." >&2
    exit 2
fi

if [ "$(uname -s)" = FreeBSD ]; then
    echo "guest-setup: cryptol came from pkg (security/hs-cryptol)"
elif command -v cryptol >/dev/null 2>&1; then
    echo "guest-setup: cryptol already present"
elif [ "$do_deps" = no ]; then
    # --skip-deps means install NOTHING, and a tarball off GitHub is as much
    # an install as an apt transaction. Downloading one here would be the
    # script having an opinion about how a dependency arrived, which is the
    # opinion the flag exists to drop. The version is still pinned above and
    # is still the version to install: CRYPTOL_VERSION is the statement, and
    # the download was only ever one way of satisfying it.
    echo "guest-setup: --skip-deps: not installing cryptol $CRYPTOL_VERSION"
else
    echo "guest-setup: installing cryptol $CRYPTOL_VERSION"
    # Asset names have changed between releases (Linux-x86_64, ubuntu-NN.NN-X64,
    # ...), so ask the release API which asset this tag actually ships rather
    # than hardcoding a filename that silently rots.
    api="https://api.github.com/repos/GaloisInc/cryptol/releases/tags/${CRYPTOL_VERSION}"
    url=$(curl -fsSL "$api" \
          | grep -o '"browser_download_url"[^,]*' \
          | grep -iE 'linux|ubuntu' | grep -E '\.tar\.gz"?$' \
          | head -1 | sed 's/.*: *"//; s/"$//')
    [ -n "$url" ] || { echo "guest-setup: no Linux tarball in the $CRYPTOL_VERSION release" >&2; exit 1; }
    echo "guest-setup: asset $url"
    tmp=$(mktemp -d)
    if ! curl -fsSL "$url" -o "$tmp/cryptol.tar.gz"; then
        echo "guest-setup: FAILED to download cryptol from $url" >&2
        echo "guest-setup: the second oracle is mandatory; not degrading to a single oracle" >&2
        exit 1
    fi
    mkdir -p /opt/cryptol
    tar -xzf "$tmp/cryptol.tar.gz" -C /opt/cryptol --strip-components=1
    # The tarball layout has moved between releases; find the binary rather
    # than assuming a path, and fail loudly if it is not there.
    bin=$(find /opt/cryptol -type f -name cryptol -perm -u+x | head -1)
    [ -n "$bin" ] || { echo "guest-setup: no cryptol binary in the tarball" >&2; exit 1; }
    ln -sf "$bin" /usr/local/bin/cryptol
    rm -rf "$tmp"
fi

# The P1 broker, at BRAINSTEM_COMMIT. programs/ are brainstem clients: they
# chain routines by spawning them through a broker, so the broker is a build
# dependency of this repository exactly as Cryptol is.
#
# Cloned rather than vendored, and pinned to a SHA rather than a branch, for
# the reason the Cryptol pin exists: a dependency that moves on its own turns
# a red suite into a question about somebody else's tree. The checkout also
# provides tools/bfgen.sh, which is what expands a programs/*.poke -- there is
# deliberately no second copy of it here, because two copies of an expander is
# two things that can disagree about what a .poke means.
if [ -x /opt/brainstem/build/brainstem ] \
   && [ "$(cat /opt/brainstem/PINNED 2>/dev/null)" = "$BRAINSTEM_COMMIT" ]; then
    echo "guest-setup: brainstem $BRAINSTEM_COMMIT already built"
else
    echo "guest-setup: fetching brainstem $BRAINSTEM_COMMIT"
    rm -rf /opt/brainstem
    git clone -q https://github.com/calebpower/brainstem /opt/brainstem \
        || { echo "guest-setup: FAILED to clone brainstem" >&2; exit 1; }
    ( cd /opt/brainstem && git checkout -q "$BRAINSTEM_COMMIT" ) \
        || { echo "guest-setup: no commit $BRAINSTEM_COMMIT in brainstem" >&2; exit 1; }
    ( cd /opt/brainstem && sh tools/build.sh >/dev/null ) \
        || { echo "guest-setup: brainstem did not build" >&2; exit 1; }
    # Recorded so a re-run can tell "already built" from "built something else".
    printf '%s
' "$BRAINSTEM_COMMIT" > /opt/brainstem/PINNED
fi

# THE VERSION REPORT IS THE RECEIPT, and it is strict when this script did the
# installing and tolerant when it did not. Having just run the apt line, a
# missing z3 is a broken provision and should stop the run. Under --skip-deps
# the operator installed things by hand and may deliberately have left the
# proof oracle out -- a guest that only RUNS programs needs neither z3 nor
# cryptol -- so their absence is reported and carried on from. The C compiler
# and git are required either way, because nothing below works without them.
echo "guest-setup: versions"
cc --version | head -1
git --version
if [ "$do_deps" = yes ]; then
    z3 --version
    cryptol --version 2>&1 | head -1
else
    z3 --version || echo "guest-setup: no z3 -- the design proofs will fail"
    cryptol --version 2>&1 | head -1 \
        || echo "guest-setup: no cryptol -- the DUAL ORACLE will fail, all of tiers 2 and 4"
fi
echo "brainstem $(cat /opt/brainstem/PINNED)"

fi

if [ "$do_build" = yes ]; then

echo "guest-setup: building the pinned interpreter and tools"
# Every tool tests/run.sh builds, so a compile error is reported HERE as a
# build failure rather than surfacing later as a test failure. bffoot and
# bfstyle were missing from this list, and bffoot used two POSIX functions that
# -std=c99 hides on glibc -- which meant the suite did not build at all on a
# current Linux guest, and said so only once it reached the run phase.
cc -O2 -std=c99 -Wall -Wextra -o tools/bfi     tools/bfi.c
cc -O2 -std=c99 -Wall -Wextra -o tools/hx      tools/hx.c
cc -O2 -std=c99 -Wall -Wextra -o tools/bflint  tools/bflint.c
cc -O2 -std=c99 -Wall -Wextra -o tools/bfstyle tools/bfstyle.c
cc -O2 -std=c99 -Wall -Wextra -o tools/bffoot  tools/bffoot.c

fi

echo "guest-setup: done"
