# The off-network fallback lane for the bfsodium suite.
#
# reaper is the gate of record and nothing here changes that; .reaper.toml is
# untouched. This exists for working from a host that cannot reach the reaper
# site, and it runs the SAME tests/run.sh with nothing excluded and nothing
# skipped. A fallback that tests less than the gate is not a fallback, it is a
# way to be surprised later.
#
# ubuntu:26.04 is the guest reaper provisions -- see `guests` in .reaper.toml --
# so both lanes compile the pinned interpreter against the same libc with the
# same compiler, and a result from one means the same thing as a result from
# the other.
FROM ubuntu:26.04

# Only the toolchain half. It is the expensive one: an apt transaction plus a
# Cryptol tarball fetched from GitHub, which is also the only step here that
# needs a network. Baking it into a layer is precisely what makes this usable
# offline -- build the image once while there is a network, and run the suite
# afterwards when there is not.
#
# guest-setup.sh is copied on its own rather than with the rest of the tree, so
# that editing brainfuck does not invalidate this layer. Only a change to the
# toolchain definition rebuilds it.
COPY tools/guest-setup.sh /opt/bfsodium/guest-setup.sh
RUN sh /opt/bfsodium/guest-setup.sh --toolchain

# The tree under test is not baked in. tools/container-test.sh mounts it at run
# time, so the image outlives any particular state of the working tree and the
# thing being tested is whatever is on disk right now -- uncommitted work
# included, which is the whole point of a pre-push loop.
WORKDIR /work
