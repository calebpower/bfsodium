#!/bin/sh
# tools/container-test.sh -- run the whole suite in a container.
#
# THIS IS THE FALLBACK LANE, NOT THE GATE. `reaper test` is what a change is
# judged by; this is for working from a host that cannot reach the reaper site.
# It runs the same tests/run.sh, with nothing excluded, against the same
# ubuntu-26.04 userland, so a pass here means what a pass there means -- but it
# has not proved the change on the machine of record, and saying so is the
# whole reason this banner exists.
#
# Usage:  sh tools/container-test.sh
#         CONTAINER_ENGINE=docker sh tools/container-test.sh
#
# The image carries only the toolchain; the tree is mounted at run time, so
# uncommitted work is what gets tested, which is the point of a pre-push loop.
set -eu

IMAGE=${BFSODIUM_IMAGE:-bfsodium-suite}
engine=${CONTAINER_ENGINE:-podman}
repo=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)

command -v "$engine" >/dev/null 2>&1 || {
    echo "container-test: no '$engine' on PATH" >&2
    echo "container-test: set CONTAINER_ENGINE, or install podman" >&2
    exit 1
}

mkdir -p "$repo/out"

# The host paths, which are the engine's business, and the container paths,
# which are not. On a Unix host these are the same strings and the block below
# does nothing.
#
# Under Git Bash the engine is a native Windows binary, and MSYS rewrites every
# argument that LOOKS like a POSIX path before it arrives. Left alone it turns
# `-v /repo:/src:ro` into `\Program Files\Git\src;ro` -- it reads the whole
# argument as a colon-separated path LIST -- and rewrites `/work` the same way.
# Turning the rewriting off is necessary but not sufficient: podman then reads
# the host half of a mount, and the build context, as Windows paths and
# resolves `/d/projects` to `D:\d\projects`. Neither setting is right for both
# halves, so the halves are separated -- rewriting off, host paths converted
# explicitly with cygpath, container paths written literally.
host=$repo
hostout=$repo/out
hostfile=$repo/Containerfile
case ${OSTYPE:-$(uname -s)} in
    msys* | cygwin* | MINGW* | MSYS* | CYGWIN*)
        MSYS_NO_PATHCONV=1
        MSYS2_ARG_CONV_EXCL='*'
        export MSYS_NO_PATHCONV MSYS2_ARG_CONV_EXCL
        host=$(cygpath -w -- "$repo")
        hostout=$(cygpath -w -- "$repo/out")
        hostfile=$(cygpath -w -- "$repo/Containerfile")
        ;;
esac

echo "container-test: THE FALLBACK LANE. 'reaper test' is the gate of record."
echo "container-test: building $IMAGE (the first build needs a network)"
"$engine" build -t "$IMAGE" -f "$hostfile" "$host"

# The tree goes in READ ONLY and is copied to scratch inside the container.
#
# Two reasons, and the first is a defect this project has already had.
# .reaper.toml excludes the host-built binaries from its sync because a
# FreeBSD-built bfi looks present to the suite's rebuild and then fails to
# exec; a bind mount from a Windows or FreeBSD checkout carries exactly the
# same foreign binaries, so they are deleted from the copy and rebuilt by
# --build. Second, the suite compiles and interprets some twenty five megabytes
# of brainfuck -- sha256/hkdf.bf alone is seventeen -- and a Windows bind mount
# is a bad place to do that. The copy pays the crossing once.
#
# Writing to the mounted tree is refused rather than merely avoided: nothing
# this runs can leave a Linux ELF binary in the checkout you are editing.
#
# On an SELinux host add ,z to the :ro below if the mount is denied.
#
# There is no -w flag. The Containerfile's WORKDIR already lands the container
# in /work, so the flag was only ever a second way of saying it, and a badly
# behaved one: a podman 4.5 client against a 4.9 server refused it outright,
# "workdir /work does not exist", for a directory that does exist and is the
# image's own WorkingDir. A matched 5.8 pair accepts it again, so that was the
# version skew and not podman -- but the flag is redundant either way, and the
# `cd` below says the same thing where no engine can misread it.
# `set -e` would abort on a red suite before the status is captured, losing the
# closing lines at exactly the moment they are wanted, so the run is guarded.
status=0
"$engine" run --rm \
    -v "$host:/src:ro" \
    -v "$hostout:/out" \
    "$IMAGE" \
    sh -euc '
        cd /work
        cp -a /src/. /work/
        rm -f tools/bfi tools/hx tools/bflint tools/bfstyle tools/bffoot
        sh tools/guest-setup.sh --build
        # No pipe into tee. /bin/sh here is dash: no pipefail, no PIPESTATUS,
        # and the suite exit status is the entire point of running it. This is
        # the same idiom .reaper.toml uses, for the same reason.
        sh tests/run.sh > /out/suite.log 2>&1; s=$?
        cat /out/suite.log
        exit $s
    ' || status=$?

echo "container-test: log in out/suite.log"
echo "container-test: this was the FALLBACK lane; gate with 'reaper test' before landing."
exit $status
