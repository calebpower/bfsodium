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

sub flatten {
    my ($path, $whence) = @_;

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
        if ($l =~ /^\s*%%(.*?)%%\s*$/) {
            my $name = $1;
            if ($name !~ m{^[A-Za-z0-9_][A-Za-z0-9_/]*$}) {
                print STDERR "bfinclude: $path:$line: not a block name: $name\n";
                exit 1;
            }
            flatten("$repo/$name.skel", "$path:$line");
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

        print "$l\n";
    }

    close $fh;
    pop @stack;
    delete $on_stack{$path};
}

if (!@ARGV || $ARGV[0] eq '--help') {
    print STDERR "usage: bfinclude.pl FILE.skel\n";
    exit 2;
}
flatten(abs_path($ARGV[0]), undef);
