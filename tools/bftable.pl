#!/usr/bin/env perl
#
# tools/bftable.pl -- HANDOFF.md's routine table, checked against the tree.
#
# The table gives a line count for each routine's .bf and its .skel. Nothing
# ever regenerated it and nothing ever checked it, so it drifted: eighteen of
# its thirty rows were wrong when this was written, chacha20/qrloop by a factor
# of three, because the row was last touched when the transpiler was deleted
# and the .bf has since grown the routines it pastes. A number nobody verifies
# is not documentation, it is a rumor, and what a reader uses that table for is
# to judge what a routine costs to read. So it is checked the way the brainfuck
# is.
#
# Run with no argument to check; the exit status is what the suite gates on.
# Run with --fix to rewrite the two count columns in place -- it touches only
# those two columns, so the "verified against" prose stays yours. Run with
# --selftest first, because a checker nobody checks is the thing it exists to
# forbid.
#
# Every routine with a skeleton must have a row. That is what keeps a new
# primitive from being merely absent from the table rather than wrong in it.

use strict;
use warnings;
use File::Temp qw(tempdir);

my $ROW = qr/^\| \`([a-z0-9]+\/[a-z0-9_]+)\` \| (\d+) \| (\d+) \|/;

sub lines_in {
    my ($path) = @_;
    open my $fh, '<', $path or return undef;
    my $n = 0;
    $n++ while <$fh>;
    close $fh;
    return $n;
}

# Returns (\@complaints, \@doc_lines_possibly_rewritten). Rewriting is done
# here rather than at the call site so that --fix can only ever change a line
# this has just found to be wrong.
sub check {
    my ($dir, $doc, $rewrite) = @_;
    open my $in, '<', "$dir/$doc" or die "bftable: cannot read $dir/$doc: $!\n";
    my @doc = <$in>;
    close $in;

    my (@bad, %seen);
    for my $line (@doc) {
        next unless $line =~ $ROW;
        my ($routine, $said_bf, $said_skel) = ($1, $2, $3);
        $seen{$routine} = 1;

        my $bf   = lines_in("$dir/$routine.bf");
        my $skel = lines_in("$dir/$routine.skel");
        if (!defined $bf || !defined $skel) {
            push @bad, "$routine: the table has a row for it and the tree does not";
            next;
        }
        next if $bf == $said_bf && $skel == $said_skel;

        push @bad, sprintf("%-28s table says %s/%s, the tree says %d/%d",
                           $routine, $said_bf, $said_skel, $bf, $skel);
        $line =~ s/^(\| \`\Q$routine\E\` \| )\d+( \| )\d+( \|)/$1$bf$2$skel$3/
            if $rewrite;
    }

    for my $skel (sort glob "$dir/*/*.skel") {
        (my $routine = $skel) =~ s/\.skel$//;
        $routine =~ s/^\Q$dir\E\///;
        next if $seen{$routine};
        push @bad, "$routine: has a skeleton and no row in the table";
    }
    return (\@bad, \@doc, scalar keys %seen);
}

sub selftest {
    my $dir = tempdir(CLEANUP => 1);
    mkdir "$dir/idiom" or die $!;
    my $write = sub {
        my ($path, $n) = @_;
        open my $fh, '>', "$dir/$path" or die $!;
        print $fh "x\n" for 1 .. $n;
        close $fh;
    };
    $write->('idiom/one.bf', 7);
    $write->('idiom/one.skel', 3);

    my $doc = sub {
        my ($body) = @_;
        open my $fh, '>', "$dir/H.md" or die $!;
        print $fh $body;
        close $fh;
    };
    my $fail = sub { print "bftable: SELFTEST FAILED: $_[0]\n"; exit 1 };

    # A table that agrees with the tree passes.
    $doc->("| \`idiom/one\` | 7 | 3 | prose |\n");
    my ($bad) = check($dir, 'H.md', 0);
    @$bad and $fail->("a correct table was called wrong: @$bad");

    # A wrong count is caught, in either column.
    $doc->("| \`idiom/one\` | 8 | 3 | prose |\n");
    ($bad) = check($dir, 'H.md', 0);
    @$bad == 1 or $fail->('a wrong .bf count was not caught');
    $doc->("| \`idiom/one\` | 7 | 4 | prose |\n");
    ($bad) = check($dir, 'H.md', 0);
    @$bad == 1 or $fail->('a wrong .skel count was not caught');

    # --fix mends exactly the two columns and leaves the prose alone.
    $doc->("| \`idiom/one\` | 8 | 4 | prose that must survive |\n");
    (my $b2, my $lines) = check($dir, 'H.md', 1);
    $lines->[0] eq "| \`idiom/one\` | 7 | 3 | prose that must survive |\n"
        or $fail->("--fix rewrote the row wrongly: $lines->[0]");

    # A routine the table does not mention at all is the failure that matters
    # most, because a new primitive is absent rather than wrong.
    $doc->("nothing here\n");
    ($bad) = check($dir, 'H.md', 0);
    @$bad == 1 && $bad->[0] =~ /no row in the table/
        or $fail->('a routine missing from the table was not caught');

    # And a row for a routine that does not exist is caught too.
    $doc->("| \`idiom/gone\` | 1 | 1 | prose |\n");
    ($bad) = check($dir, 'H.md', 0);
    grep { /the tree does not/ } @$bad or $fail->('a row with no routine was not caught');

    print "bftable: selftest passed\n";
    exit 0;
}

my $arg = shift // '';
die "usage: bftable.pl [--fix|--selftest]\n" if @ARGV || ($arg ne '' && $arg !~ /^--(fix|selftest)$/);
selftest() if $arg eq '--selftest';

my $fix = $arg eq '--fix';
my ($bad, $doc, $n) = check('.', 'HANDOFF.md', $fix);

if ($fix) {
    open my $out, '>', 'HANDOFF.md' or die "bftable: cannot write HANDOFF.md: $!\n";
    print $out @$doc;
    close $out;
    print "bftable: HANDOFF.md rewritten\n";
    # A missing row cannot be mended by rewriting a number, so --fix is not a
    # licence to report success while one is outstanding.
    my @unfixable = grep { /no row in the table|the tree does not/ } @$bad;
    if (@unfixable) {
        print "bftable: still wrong, and --fix cannot mend it:\n";
        print "  $_\n" for @unfixable;
        exit 1;
    }
    exit 0;
}

if (@$bad) {
    print "bftable: HANDOFF.md does not describe the tree:\n";
    print "  $_\n" for @$bad;
    print "  run: perl tools/bftable.pl --fix\n";
    exit 1;
}
print "bftable: HANDOFF.md matches the tree ($n routines)\n";
exit 0;
