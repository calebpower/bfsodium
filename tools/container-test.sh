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

echo "container-test: THE FALLBACK LANE. 'reaper test' is the gate of record."
echo "container-test: building $IMAGE (the first build needs a network)"
"$engine" build -t "$IMAGE" -f "$repo/Containerfile" "$repo"

mkdir -p "$repo/out"

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
# `set -e` would abort on a red suite before the status is captured, losing the
# closing lines at exactly the moment they are wanted, so the run is guarded.
status=0
"$engine" run --rm \
    -v "$repo":/src:ro \
    -v "$repo/out":/out \
    -w /work \
    "$IMAGE" \
    sh -euc '
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
