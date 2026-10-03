#!/usr/bin/perl
# bfdag.pl — the skeleton include graph, checked.
#
#   bfdag.pl              check; exit 1 if anything below is false
#   bfdag.pl --selftest   prove it complains at each divergence
#
# Three claims, and each one is a defect this project has actually had:
#
#   1. EVERY REFERENCE RESOLVES. An unregistered `@@paste@@` used to expand to
#      nothing, silently, because it carries no command byte -- the routine
#      simply did not appear and only a failing vector said so. bfinclude
#      already errors on a missing file, but that only speaks when something
#      is being built; this speaks for the whole tree at once.
#
#   2. THE GRAPH IS ACYCLIC. bfexpand's older paste form had no cycle check at
#      all: rebuild.sh looped to a fixpoint and reported "the pastes have a
#      cycle" only by failing to converge after ten passes, which is a
#      symptom and a slow one.
#
#   3. NO BLOCK IS ORPHANED. A component nothing includes is a component
#      nothing tests: index/fetch8 sat in the tree unused and unvectored until
#      AES needed a lookup and could not use it. That is only checked under
#      block/, because a top level routine is a root by definition and being
#      included by nothing is what makes it one.
use strict;
use warnings;
use File::Basename qw(dirname);
use File::Find;
use Cwd qw(abs_path);

my $here = dirname(abs_path($0));
my $repo = abs_path("$here/..");

# ---------------------------------------------------------------------------
sub skeletons {
    my ($root) = @_;
    my @out;
    find({ wanted => sub { push @out, $File::Find::name if /\.skel$/ },
           no_chdir => 1 }, $root);
    return sort @out;
}

sub refs_of {
    my ($path) = @_;
    open my $fh, '<', $path or die "bfdag: cannot read $path: $!\n";
    my (@r, $n);
    while (my $l = <$fh>) {
        $n++;
        chomp $l;
        push @r, [$1, $n] if $l =~ /^\s*%%(.*?)%%(?:\s+-?\d+)?\s*$/;
    }
    close $fh;
    return @r;
}

sub rel { my $p = shift; $p =~ s/^\Q$_[0] || $repo\E\///; return $p; }

sub check {
    my ($root, $quiet) = @_;
    my @files = skeletons($root);
    my (%edges, %exists, @bad);
    $exists{$_} = 1 for @files;

    for my $f (@files) {
        for my $r (refs_of($f)) {
            my ($name, $line) = @$r;
            my $target = "$root/$name.skel";
            if (!$exists{$target}) {
                push @bad, sprintf("%s:%d: includes %s, which is not a file",
                                   substr($f, length($root) + 1), $line, $name);
                next;
            }
            push @{ $edges{$f} }, $target;
        }
    }

    # Depth first, three colours. The grey set is the path currently open, so
    # a back edge into it names the whole ring rather than the fact of one.
    my (%colour, @ring, @cycles);
    my $visit;
    $visit = sub {
        my ($n) = @_;
        return if ($colour{$n} || '') eq 'black';
        if (($colour{$n} || '') eq 'grey') {
            my @r = @ring;
            shift @r while @r && $r[0] ne $n;
            push @cycles, join(" -> ", map { substr($_, length($root) + 1) } @r, $n);
            return;
        }
        $colour{$n} = 'grey';
        push @ring, $n;
        $visit->($_) for @{ $edges{$n} || [] };
        pop @ring;
        $colour{$n} = 'black';
    };
    $visit->($_) for @files;

    my %included;
    for my $f (keys %edges) { $included{$_} = 1 for @{ $edges{$f} } }
    my @orphans = grep { !$included{$_} && m{/block/} } @files;

    # A CONTRACT INSIDE A BLOCK MUST BE RELATIVE. An include substitutes text,
    # so an absolute `; ASSERT ptr=9` inside a block is a claim about cell nine
    # of whatever frame the text happened to land in -- true for the caller it
    # was written against and a confident lie for the next one. Written `+9` it
    # is a claim about the ninth cell of the BLOCK, and tools/bfinclude adds
    # the include's offset to it.
    #
    # The rule used to forbid these outright, because an include had no offset
    # to resolve them against. It does now, so the prohibition became a
    # requirement: say it relative, or do not say it. Three blocks carried
    # absolute ones and nothing could see it, which is this project's standing
    # failure shape -- a documented rule with no checker.
    for my $f (@files) {
        next unless $f =~ m{/block/};
        open my $fh, '<', $f or next;
        my $n = 0;
        while (my $line = <$fh>) {
            $n++;
            next unless $line =~ /^\s*; ASSERT (?:ptr=|zero )/;
            next if $line =~ /^\s*; ASSERT ptr=\+/;
            next if $line =~ /^\s*; ASSERT zero \+\d+:\+\d+/;
            chomp $line;
            push @bad, sprintf("%s:%d: a contract in a block must be relative: %s",
                               substr($f, length($root) + 1), $n, $line);
        }
        close $fh;
    }

    # A CONTRACT AFTER THE LAST INSTRUCTION IS NOT A CONTRACT. "; ASSERT"
    # attaches to the NEXT instruction; tools/bfi and the scratchpad
    # interpreter both check it wherever execution reaches that instruction.
    # Written after the last instruction in a file there is nothing for it to
    # attach to, so it is never checked once -- while reading exactly like the
    # ones that are. Seventeen programs carried twenty-two of them, and at
    # least one was FALSE as well as dead: chacha20/stream claimed
    # "zero 0:397" at exit, but a message ending partway through a block
    # leaves the rest of that keystream sitting in cells 0 to 63.
    #
    # A block/ SKELETON IS EXEMPT, and this is not a loophole. Its text is
    # substituted into a caller, so a trailing contract there attaches to
    # whatever instruction follows the include site -- which is exactly how
    # block/aes128table's trailing "; ASSERT ptr=+45" fires, on the first
    # instruction of block/aes128encrypt. The seam between two blocks is
    # asserted by both parties and that is worth keeping.
    #
    # A ROUTINE IS NOT EXEMPT even though it is pasted, because a paste stops
    # at "; emit" and drops the tail, and because the routine's own .bf is run
    # by the suite in its own right -- which is the run where the claim is
    # dead.
    for my $f (@files) {
        next if $f =~ m{/block/};
        open my $fh, '<', $f or next;
        my @ls = <$fh>;
        close $fh;
        my $last = -1;
        for my $i (0 .. $#ls) {
            my $l = $ls[$i];
            $l =~ s/;.*//;
            # An instruction in a SKELETON is a command byte, an Rn/Ln walk,
            # a paste or an include. Missing the last three would have made
            # this check pass every keccak program by accident.
            $last = $i if $l =~ /[><+\-.,\[\]]/
                       || $l =~ /\b[RL]\d+/
                       || $l =~ /\@\@\w+\@\@/
                       || $l =~ m{%%[\w/]+%%};
        }
        for my $i ($last + 1 .. $#ls) {
            next unless $ls[$i] =~ /^\s*; ASSERT /;
            chomp(my $line = $ls[$i]);
            $line =~ s/^\s+//;
            push @bad, sprintf(
                "%s:%d: a contract after the last instruction can never fire: %s",
                substr($f, length($root) + 1), $i + 1, $line);
        }
    }

    push @bad, "include cycle: $_" for @cycles;
    push @bad, sprintf("%s is a block nothing includes", substr($_, length($root) + 1))
        for sort @orphans;

    if (@bad) {
        unless ($quiet) {
            print "FAIL bfdag: the include graph does not hold:\n";
            print "     $_\n" for @bad;
        }
        return (1, scalar @files);
    }
    printf "bfdag: %d skeletons, every include resolves, no cycles, no orphans\n",
        scalar @files unless $quiet;
    return (0, scalar @files);
}

# ---------------------------------------------------------------------------
sub selftest {
    require File::Temp;
    require File::Path;
    my $fails = 0;
    my $case = sub {
        my ($name, $files, $want) = @_;
        my $dir = File::Temp::tempdir(CLEANUP => 1);
        for my $f (sort keys %$files) {
            my $p = "$dir/$f";
            File::Path::make_path(dirname($p));
            open my $o, '>', $p or die $!;
            print $o $files->{$f};
            close $o;
        }
        my ($got) = check($dir, 1);
        my $ok = ($got == $want);
        printf "%s bfdag selftest: %s\n", $ok ? "PASS" : "FAIL", $name;
        $fails++ unless $ok;
    };

    $case->("a plain chain is accepted",
            { "block/leaf.skel" => "; leaf\n  [-]\n",
              "top.skel"        => "; top\n%%block/leaf%%\n" }, 0);
    $case->("a missing block is caught",
            { "top.skel" => "; top\n%%block/gone%%\n" }, 1);
    $case->("a two file cycle is caught",
            { "block/a.skel" => "%%block/b%%\n",
              "block/b.skel" => "%%block/a%%\n",
              "top.skel"     => "%%block/a%%\n" }, 1);
    $case->("a self reference is caught",
            { "block/a.skel" => "%%block/a%%\n",
              "top.skel"     => "%%block/a%%\n" }, 1);
    $case->("a block nobody includes is caught",
            { "block/leaf.skel" => "; leaf\n  [-]\n",
              "block/lonely.skel" => "; nobody wants me\n  [-]\n",
              "top.skel"        => "%%block/leaf%%\n" }, 1);
    $case->("a top level skeleton included by nobody is FINE",
            { "block/leaf.skel" => "; leaf\n  [-]\n",
              "one.skel"        => "%%block/leaf%%\n",
              "two.skel"        => "; a second root\n  ,\n" }, 0);
    $case->("a diamond is not a cycle",
            { "block/leaf.skel" => "; leaf\n  [-]\n",
              "block/l.skel"    => "%%block/leaf%%\n",
              "block/r.skel"    => "%%block/leaf%%\n",
              "top.skel"        => "%%block/l%%\n%%block/r%%\n" }, 0);

                $case->("an ABSOLUTE contract in a block is caught",
                { "block/leaf.skel" => "; leaf\n; ASSERT ptr=9\n  [-]\n",
                  "top.skel"        => "%%block/leaf%%\n" }, 1);
        $case->("a RELATIVE contract in a block is fine",
                { "block/leaf.skel" => "; leaf\n; ASSERT ptr=+9\n  [-]\n",
                  "top.skel"        => "%%block/leaf%% 82\n" }, 0);
        $case->("an absolute zero range in a block is caught too",
                { "block/leaf.skel" => "; leaf\n; ASSERT zero 5:9\n  [-]\n",
                  "top.skel"        => "%%block/leaf%%\n" }, 1);
        # The fixture carries an instruction AFTER the contract on purpose.
        # It did not, and when the placement check arrived this case started
        # failing for a reason it was never about: a contract at the very end
        # of a program is dead whether it is absolute or relative, and this
        # one is about absoluteness alone. A fixture that exercises two rules
        # cannot say which of them it is testing.
        $case->("a contract OUTSIDE a block may be absolute",
                { "block/leaf.skel" => "; leaf\n  [-]\n",
                  "top.skel"        => "%%block/leaf%%\n; ASSERT ptr=4\n  [-]\n" }, 0);

        $case->("a contract AFTER the last instruction in a program is caught",
                { "block/leaf.skel" => "; leaf\n  [-]\n",
                  "top.skel"        => "%%block/leaf%%\n  [-]\n; ASSERT ptr=0\n" }, 1);
        $case->("the same contract BEFORE the last instruction is fine",
                { "block/leaf.skel" => "; leaf\n  [-]\n",
                  "top.skel"        => "%%block/leaf%%\n; ASSERT ptr=0\n  [-]\n" }, 0);
        $case->("a trailing contract in a BLOCK is fine; it attaches to the caller",
                { "block/leaf.skel" => "; leaf\n  [-]\n; ASSERT ptr=+1\n",
                  "top.skel"        => "%%block/leaf%%\n  [-]\n" }, 0);
        $case->("an Rn walk counts as an instruction  so a contract after it is caught",
                { "block/leaf.skel" => "; leaf\n  [-]\n",
                  "top.skel"        => "%%block/leaf%%\nR5\n; ASSERT ptr=5\n" }, 1);
        $case->("an include counts as an instruction  so a contract after it is caught",
                { "block/leaf.skel" => "; leaf\n  [-]\n",
                  "top.skel"        => "; top\n%%block/leaf%%\n; ASSERT ptr=0\n" }, 1);

        print $fails ? "bfdag: $fails selftest(s) failed\n"
                 : "bfdag: selftests pass\n";
    return $fails ? 1 : 0;
}

# ---------------------------------------------------------------------------
if (@ARGV && $ARGV[0] eq '--selftest') { exit selftest(); }
my ($bad) = check($repo, 0);
exit $bad;
