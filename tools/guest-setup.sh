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
set -eu

CRYPTOL_VERSION=3.4.0

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

echo "guest-setup: building the pinned interpreter and tools"
cc -O2 -std=c99 -Wall -Wextra -o tools/bfi    tools/bfi.c
cc -O2 -std=c99 -Wall -Wextra -o tools/hx     tools/hx.c
cc -O2 -std=c99 -Wall -Wextra -o tools/bflint tools/bflint.c

echo "guest-setup: done"
