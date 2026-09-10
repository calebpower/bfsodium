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
set -eu

CRYPTOL_VERSION=3.4.0

usage() {
    echo "usage: guest-setup.sh [--toolchain|--build]" >&2
    exit 2
}

do_toolchain=yes
do_build=yes
case "${1-}" in
    '')          [ $# -le 1 ] || usage ;;
    --toolchain) do_build=no ;;
    --build)     do_toolchain=no ;;
    *)           usage ;;
esac
[ $# -le 1 ] || usage

if [ "$do_toolchain" = yes ]; then

echo "guest-setup: apt toolchain (C compiler, z3, curl)"
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq
apt-get install -y -qq build-essential z3 curl ca-certificates >/dev/null

if command -v cryptol >/dev/null 2>&1; then
    echo "guest-setup: cryptol already present"
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

echo "guest-setup: versions"
cc --version | head -1
z3 --version
cryptol --version 2>&1 | head -1

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
