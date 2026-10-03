#!/usr/bin/perl
# bfinclude.pl — flatten a skeleton's %%includes%% into one stream of text.
#
#   bfinclude.pl FILE.skel > flattened
#
# A skeleton may name another skeleton on a line of its own:
#
#     %%block/xor8%%
#
# and this substitutes that file's TEXT, recursively. That is the whole of it.
# There is no base, no entry or exit wrapping, no prologue stripping and no
# contract rebasing — those belong to the older `@@NAME@@ base` paste, which
# splices a verified routine's BODY out of its committed .bf. The two forms
# coexist while the library migrates and they are deliberately unalike to
# look at, because they are unalike to think about.
#
# WHY INCLUSION RATHER THAN A PASTE. A paste reads the callee's .bf, so a
# caller can be regenerated against a STALE callee and nothing says so --
# that cost an afternoon once, and HANDOFF still carries it as the worst trap
# in the file. An include reads the callee's .skel, which is the only thing a
# person edits, so there is one source of truth per block and no window in
# which two artifacts disagree.
#
# It also decouples composition from tools/bffoot. A paste needs an INTERFACE
# line, bffoot will not issue one for a file whose loops are unbalanced, and
# an indexed walk is unbalanced by construction -- so the S-box read could not
# be a component at all. Inclusion does not care: it is text. The assembled
# .bf is still checked by every tool in the suite, once, at the end.
#
# WHAT THIS DELIBERATELY CANNOT DO. There is no conditional, no repetition,
# no parameter and no arithmetic. A skeleton is text plus the names of other
# files. Anything that computes an offset from a symbolic name is a transpiler
# and this project deleted its last one; CONVENTIONS section 6 says why, and
# the size budget in bfstyle exists to keep it deleted.
use strict;
use warnings;
use File::Basename qw(dirname);
use File::Spec;
use Cwd qw(abs_path);

# abs_path rather than canonpath: canonpath does not resolve "..", and a
# diagnostic reading tools/../block/x is a diagnostic somebody has to squint at.
my $here = dirname(abs_path($0));
my $repo = abs_path("$here/..");

# The include stack, used for cycle detection and for the message when one is
# found. A cycle is reported with the whole path that closes it, because
# "cycle detected" without the ring is a puzzle rather than a diagnosis.
my @stack;
my %on_stack;

# REBASING A CONTRACT THAT CAME FROM A BLOCK. An include used to substitute
# text and nothing else, which left `; ASSERT ptr=` inside a block meaningless
# -- the same text lands in different frames, so the number could only be a
# claim about wherever it happened to fall, and CONVENTIONS forbade it
# outright. The paste form never had that problem: `@@NAME@@ 82` rebases its
# callee's contracts, which is why a pasteable routine writes them relative.
#
# So an include may now say where the block lands:
#
#   %%block/name%%        the block's frame starts at the caller's own zero
#   %%block/name%% 82     it starts at cell 82
#
# and a relative contract inside the block is resolved against that. The
# offset is a NUMBER, exactly as the paste form's base is; it is not control
# logic, and nothing else about an include has changed.
sub rebase {
    my ($line, $base) = @_;
    return $line if $base == 0 && $line !~ /ASSERT/;
    if ($line =~ /^(\s*; ASSERT ptr=)\+?(-?\d+)(.*)$/) {
        return "$1" . ($2 + $base) . "$3";
    }
    if ($line =~ /^(\s*; ASSERT zero )\+?(-?\d+):\+?(-?\d+)(.*)$/) {
        return "$1" . ($2 + $base) . ":" . ($3 + $base) . "$4";
    }
    # A PASTE BASE IS A CELL NUMBER IN THE SAME FRAME, so the offset shifts it
    # exactly as it shifts a contract. Without this, a block that pastes
    # anything can only ever be included at offset NOUGHT: the paste rebases
    # its callee's contracts against a base that is right for the block's own
    # zero and wrong for wherever the block actually landed, and the error
    # surfaces far away as a contract naming a cell nobody recognises.
    # block/shl128 pastes idiom/xor8 at 52 and aes/cmacsubkeys includes it at
    # 967; the first contract the paste produced said cell 54 while the
    # pointer stood at 1021.
    #
    # Rn AND Ln ARE NOT CELL NUMBERS and must not be touched. A run length is
    # "forty six arrows" and means the same thing wherever the text lands,
    # which is the distinction block/copy16's header makes from the other
    # side: an offset shifts a frame and does not rescale what is inside it.
    # The self-tests below pin both halves of that.
    if ($line =~ /^(\s*\@\@\w+\@\@\s+)(-?\d+)(\s*)$/) {
        return "$1" . ($2 + $base) . "$3";
    }
    return $line;
}

# The rebase is the only arithmetic in this file and it rewrites a tracked
# artifact, which is the combination tools/bftier.pl got wrong by having no
# test at all. Both polarities, and the Rn case is here because getting it
# wrong would silently lengthen every walk in an offset block.
sub selftest {
    my $fails = 0;
    my @cases = (
        ["; ASSERT ptr=+9",        82,  "; ASSERT ptr=91"],
        ["; ASSERT ptr=+9",        0,   "; ASSERT ptr=9"],
        ["; ASSERT ptr=+0",        967, "; ASSERT ptr=967"],
        ["; ASSERT zero +3:+10",   82,  "; ASSERT zero 85:92"],
        ["\@\@XOR8\@\@ 52",        967, "\@\@XOR8\@\@ 1019"],
        ["\@\@XOR8\@\@ 52",        0,   "\@\@XOR8\@\@ 52"],
        ["  R46",                  82,  "  R46"],
        ["  L885",                 82,  "  L885"],
        ["  [-L885+R885]",         82,  "  [-L885+R885]"],
        ["; a comment about cell 9", 82, "; a comment about cell 9"],
    );
    for my $c (@cases) {
        my ($in, $base, $want) = @$c;
        my $got = rebase($in, $base);
        if ($got eq $want) {
            printf "PASS bfinclude selftest: %-24s at %-4d -> %s\n", $in, $base, $got;
        } else {
            printf "FAIL bfinclude selftest: %s at %d gave %s  wanted %s\n",
                   $in, $base, $got, $want;
            $fails++;
        }
    }
    print $fails ? "bfinclude: $fails selftest(s) failed\n"
                 : "bfinclude: selftests pass\n";
    return $fails ? 1 : 0;
}

sub flatten {
    my ($path, $whence, $base) = @_;
    $base ||= 0;

    if ($on_stack{$path}) {
        my @ring = @stack;
        shift @ring while @ring && $ring[0] ne $path;
        print STDERR "bfinclude: include cycle:\n";
        print STDERR "          $_ ->\n" for @ring;
        print STDERR "          $path\n";
        exit 1;
    }

    open my $fh, '<', $path
        or do {
            print STDERR "bfinclude: cannot read $path\n";
            print STDERR "          included from $whence\n" if $whence;
            exit 1;
        };

    push @stack, $path;
    $on_stack{$path} = 1;

    my $line = 0;
    while (my $l = <$fh>) {
        $line++;
        chomp $l;

        # An include is a WHOLE LINE and nothing else. Allowing one mid-line
        # would make the included text's first and last lines join their
        # neighbours, which is a formatting rule nobody would remember.
        if ($l =~ /^\s*%%(.*?)%%(?:\s+(-?\d+))?\s*$/) {
            my ($name, $off) = ($1, $2);
            if ($name !~ m{^[A-Za-z0-9_][A-Za-z0-9_/]*$}) {
                print STDERR "bfinclude: $path:$line: not a block name: $name\n";
                exit 1;
            }
            flatten("$repo/$name.skel", "$path:$line", $base + ($off || 0));
            next;
        }

        # A stray %% that is not a well formed include is an ERROR and not
        # text. It carries no command byte, so it would expand to nothing and
        # the block would simply be absent -- the same silent failure an
        # unregistered @@paste@@ used to have, and it is caught the same way.
        if ($l =~ /%%/) {
            print STDERR "bfinclude: $path:$line: malformed include:\n";
            print STDERR "          $l\n";
            print STDERR "          an include is %%name%% alone on its line\n";
            exit 1;
        }

        print rebase($l, $base) . "\n";
    }

    close $fh;
    pop @stack;
    delete $on_stack{$path};
}

if (@ARGV && $ARGV[0] eq '--selftest') { exit selftest(); }
if (!@ARGV || $ARGV[0] eq '--help') {
    print STDERR "usage: bfinclude.pl FILE.skel\n";
    exit 2;
}
flatten(abs_path($ARGV[0]), undef);
