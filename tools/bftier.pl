#!/usr/bin/perl
# bftier.pl — HANDOFF.md's tier status table, checked against the suite.
#
# CONVENTIONS section 8 says which tiers the project REQUIRES and why. That is
# a slow-moving, normative claim and it is a person's to write. HANDOFF.md says
# which of them are BUILT, and that is fast-moving fact, so it is this tool's
# to write instead.
#
# The two were one table until they were not, and the failure is worth stating
# because it is the whole reason this file exists. Tier 6, differential fuzz,
# sat in the tier table in the same voice as the tiers that ran. A reader
# seeing it beside a green 336 concluded there was fuzz coverage; there was
# none, and there never had been. A table that describes what you want and what
# you have in the same column will drift the moment those differ, and they
# differ almost always.
#
# tools/bftable.pl already does this for the routine table, and the routine
# table is the one table in this repository that has never rotted. That is not
# a coincidence, and this is that lesson applied one table over.
#
# HOW A TIER IS FOUND. tests/run.sh carries "# TIER <ids>" markers. A marker
# claims every assertion after it, until the next marker, for each id it names.
# Ids may be numbers or numbers with a letter (9a). One marker may name several
# tiers where the suite genuinely interleaves them -- "# TIER 2 4" is honest,
# because a boundary vector and a golden vector sit in the same list and no
# machine can tell which is which.
#
# A grep pattern per tier was the alternative and was rejected: the pattern
# would live in the document rather than in the suite, so the suite could stop
# testing something and the document would go on matching a line that no longer
# ran. The marker lives where the assertions are.
#
# THREE STATES, because two were not enough:
#   yes     automated; at least one assertion under a marker naming it
#   manual  a practice rather than a check, so it has no marker and must not
#           have one; tier 11 (mutation) is the case
#   no      declared in CONVENTIONS and not built
#
# Usage:
#   bftier.pl             check; exit 1 if the table disagrees with the tree
#   bftier.pl --fix       rewrite the counts in HANDOFF.md
#   bftier.pl --selftest  prove it complains at each divergence
use strict;
use warnings;

my $CONV  = 'CONVENTIONS.md';
my $DOC   = 'HANDOFF.md';
my $SUITE = 'tests/run.sh';

# The required set: the leading token of each row in section 8's tier table.
# A row looks like "| 9a style consistency | ... | ... |".
sub required_tiers {
    my ($path) = @_;
    open my $fh, '<', $path or die "bftier: cannot read $path: $!\n";
    my (%want, $in8);
    while (my $l = <$fh>) {
        $in8 = 1 if $l =~ /^## 8\. /;
        $in8 = 0 if $in8 && $l =~ /^## 9\. /;
        next unless $in8;
        next unless $l =~ /^\|\s*(\d+[a-z]?)\s+\S/;
        $want{$1} = 1;
    }
    close $fh;
    return \%want;
}

# What the suite actually exercises: assertions per tier, by marker.
sub suite_tiers {
    my ($path) = @_;
    open my $fh, '<', $path or die "bftier: cannot read $path: $!\n";
    my (%count, @cur);
    while (my $l = <$fh>) {
        if ($l =~ /^#\s*TIER\s+(.+?)\s*$/) {
            @cur = split /\s+/, $1;
            $count{$_} += 0 for @cur;      # a marker with no assertions still exists
            next;
        }
        # An assertion is a run or dk invocation, or a hand-rolled check that
        # bumps the pass counter itself. Three shapes, and all three are real:
        #
        #   run "x" cmd                       the common case
        #   for f in */*.bf; do run "x" ...   one SOURCE line, many checks
        #   ...; then echo PASS; pass=$((pass+1))
        #
        # the last being how the Cryptol proofs are written, because they need
        # a heredoc and a grep and do not fit the helper. Matching only the
        # start of a line missed both of the others, and the tiers they serve
        # reported zero assertions while plainly having some -- which would
        # have made this tool's first act a false accusation.
        #
        # The count is of SOURCE LINES and the table says so. A loop that runs
        # thirty times counts once; pretending otherwise would be a number
        # nobody could verify, which is the thing being fixed here.
        next unless @cur;
        next unless $l =~ /(?:^|;|\bdo\s)\s*(?:run|dk)\s/
                 || $l =~ /pass=\$\(\(pass\+1\)\)/;
        $count{$_}++ for @cur;
    }
    close $fh;
    return \%count;
}

# The status table in HANDOFF: "| 9a | yes | 1 | ... |"
sub doc_rows {
    my ($path) = @_;
    open my $fh, '<', $path or die "bftier: cannot read $path: $!\n";
    my (@rows, $in);
    my $lineno = 0;
    while (my $l = <$fh>) {
        $lineno++;
        $in = 1 if $l =~ /^\| tier \| built \| run\.sh lines \|/;
        next unless $in;
        last if $in && $l =~ /^\s*$/ && @rows;
        next if $l =~ /^\|\s*-+/;
        next if $l =~ /^\| tier \|/;
        next unless $l =~ /^\|\s*(\S+)\s*\|\s*(\S+)\s*\|\s*(\S+)\s*\|/;
        push @rows, { id => $1, built => $2, lines => $3, at => $lineno };
    }
    close $fh;
    return \@rows;
}

sub check {
    my ($dir, $quiet) = @_;
    my $cwd = $dir eq '.' ? '' : "$dir/";
    my $want  = required_tiers("$cwd$CONV");
    my $suite = suite_tiers("$cwd$SUITE");
    my $rows  = doc_rows("$cwd$DOC");
    my $bad = 0;

    my %row = map { $_->{id} => $_ } @$rows;

    # 1. the two documents name the same tiers
    for my $t (sort keys %$want) {
        next if $row{$t};
        printf "FAIL %s: tier %s is required by %s and has no status row\n", $DOC, $t, $CONV unless $quiet;
        $bad = 1;
    }
    for my $r (@$rows) {
        next if $want->{ $r->{id} };
        printf "FAIL %s:%d: tier %s has a status row and is required by nothing\n", $DOC, $r->{at}, $r->{id} unless $quiet;
        $bad = 1;
    }

    # 2/3/4. the status agrees with the suite
    for my $r (@$rows) {
        my ($t, $b) = ($r->{id}, $r->{built});
        my $n = $suite->{$t};
        if ($b eq 'yes') {
            if (!defined $n || $n == 0) {
                printf "FAIL %s:%d: tier %s says built and no assertion in %s claims it;\n"
                     . "     add a \"# TIER %s\" marker above the checks that serve it\n",
                       $DOC, $r->{at}, $t, $SUITE, $t unless $quiet;
                $bad = 1;
            } elsif ($r->{lines} ne $n) {
                printf "FAIL %s:%d: tier %s says %s run.sh lines; the suite has %d\n",
                       $DOC, $r->{at}, $t, $r->{lines}, $n unless $quiet;
                $bad = 1;
            }
        } else {
            if (defined $n && $n > 0) {
                printf "FAIL %s:%d: tier %s says %s and %s has %d assertion(s) under a\n"
                     . "     marker claiming it; the tier got built and nobody said so\n",
                       $DOC, $r->{at}, $t, $b, $SUITE, $n unless $quiet;
                $bad = 1;
            }
            if ($r->{lines} ne '0') {
                printf "FAIL %s:%d: tier %s is not built, so its line count must be 0\n",
                       $DOC, $r->{at}, $t unless $quiet;
                $bad = 1;
            }
        }
        if ($b ne 'yes' && $b ne 'no' && $b ne 'manual') {
            printf "FAIL %s:%d: tier %s has built=%s; it must be yes, no or manual\n",
                   $DOC, $r->{at}, $t, $b unless $quiet;
            $bad = 1;
        }
    }

    # a marker naming a tier nobody has heard of
    for my $t (sort keys %$suite) {
        next if $row{$t};
        printf "FAIL %s: a \"# TIER %s\" marker names a tier with no status row\n", $SUITE, $t unless $quiet;
        $bad = 1;
    }

    print "bftier: ${DOC}'s tier table matches the suite (" . scalar(@$rows) . " tiers)\n"
        if !$bad && !$quiet;
    return $bad;
}

sub fix {
    my $suite = suite_tiers($SUITE);
    open my $in, '<', $DOC or die "bftier: cannot read $DOC: $!\n";
    my @out;
    my $seen = 0;
    while (my $l = <$in>) {
        if ($l =~ /^\|\s*(\S+)\s*\|\s*(\S+)\s*\|\s*(\S+)\s*\|(.*)$/ && $seen) {
            my ($t, $b, undef, $rest) = ($1, $2, $3, $4);
            my $n = $b eq 'yes' ? ($suite->{$t} // 0) : 0;
            $l = sprintf "| %s | %s | %s |%s\n", $t, $b, $n, $rest;
        }
        $seen = 1 if $l =~ /^\|\s*-+\s*\|\s*-+\s*\|\s*-+\s*\|/ && !$seen && @out && $out[-1] =~ /^\| tier \| built \|/;
        push @out, $l;
    }
    close $in;
    open my $o, '>', $DOC or die "bftier: cannot write $DOC: $!\n";
    print $o @out;
    close $o;
    print "bftier: $DOC rewritten\n";
    return 0;
}

# Self-test: the checker must complain at input a broken tree would produce,
# and must pass a good one. Both polarities, because a checker that has never
# been observed failing is indistinguishable from a clean corpus.
sub selftest {
    require File::Temp;
    my $fails = 0;
    my $mk = sub {
        my (%o) = @_;
        my $d = File::Temp::tempdir(CLEANUP => 1);
        mkdir "$d/tests";
        open my $c, '>', "$d/$CONV" or die;
        print $c "## 8. Testing protocol\n\n| Tier | Q | How |\n|---|---|---|\n";
        print $c "| 1 interpreter self-test | a | b |\n";
        print $c "| 6 differential fuzz | a | b |\n";
        print $c "| 11 mutation | a | b |\n";
        print $c $o{extra_conv} // '';
        print $c "\n## 9. Scope\n";
        close $c;
        open my $s, '>', "$d/$SUITE" or die;
        print $s "#!/bin/sh\n";
        print $s $o{suite} // "# TIER 1\nrun \"a\" true\nrun \"b\" true\n";
        close $s;
        open my $h, '>', "$d/$DOC" or die;
        print $h "## State\n\n| tier | built | run.sh lines | note |\n|---|---|---|---|\n";
        print $h $o{rows} // "| 1 | yes | 2 | x |\n| 6 | no | 0 | x |\n| 11 | manual | 0 | x |\n";
        print $h "\ntail\n";
        close $h;
        return $d;
    };

    my @cases = (
        [ 'a clean tree passes', {}, 0 ],
        [ 'caught a tier required with no status row',
          { extra_conv => "| 7 metamorphic | a | b |\n" }, 1 ],
        [ 'caught a status row for a tier nobody requires',
          { rows => "| 1 | yes | 2 | x |\n| 6 | no | 0 | x |\n| 11 | manual | 0 | x |\n| 42 | yes | 1 | x |\n" }, 1 ],
        [ 'caught a tier claiming built with nothing behind it',
          { rows => "| 1 | yes | 2 | x |\n| 6 | yes | 1 | x |\n| 11 | manual | 0 | x |\n" }, 1 ],
        [ 'caught a stale line count',
          { rows => "| 1 | yes | 9 | x |\n| 6 | no | 0 | x |\n| 11 | manual | 0 | x |\n" }, 1 ],
        [ 'caught a tier that got built while the table still said no',
          { suite => "# TIER 1\nrun \"a\" true\nrun \"b\" true\n# TIER 6\nrun \"c\" true\n" }, 1 ],
        [ 'caught a marker naming a tier with no status row',
          { suite => "# TIER 1\nrun \"a\" true\nrun \"b\" true\n# TIER 99\nrun \"c\" true\n" }, 1 ],
        [ 'caught an unknown built state',
          { rows => "| 1 | maybe | 2 | x |\n| 6 | no | 0 | x |\n| 11 | manual | 0 | x |\n" }, 1 ],
    );

    for my $c (@cases) {
        my ($name, $opt, $want) = @$c;
        my $d = $mk->(%$opt);
        my $got = check($d, 1);
        if ($got == $want) { print "selftest ok: $name\n" }
        else { print "SELFTEST FAIL: $name (wanted $want got $got)\n"; $fails++ }
    }
    if ($fails) { print "SELFTEST FAILED ($fails)\n"; return 1 }
    print "bftier --selftest: ok\n";
    return 0;
}

my $arg = $ARGV[0] // '';
exit selftest() if $arg eq '--selftest';
exit fix()      if $arg eq '--fix';
exit check('.', 0);
