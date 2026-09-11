#!/usr/bin/perl
# bflayout.pl — lay the committed brainfuck out as code on the left, English on
# the right.
#
# A skeleton is AUTHORED with the annotation on the line above its operation,
# because that is the order you think in: say what you are about to do, then do
# it. It is READ the other way round -- brainfuck in the left column, English in
# the right, so the eye can run down either one alone. This pass turns the first
# into the second.
#
# It does three things and decides nothing about meaning:
#
#   1. The last plain-prose comment immediately above a code line becomes that
#      line's trailing annotation. Comments that are STRUCTURE rather than prose
#      stay on their own line: "; ASSERT" (which binds to the next instruction
#      and must not move), "; emit" and "; ====" (section boundaries that
#      bfexpand and bffoot both parse), "; INTERFACE", tape-map rows, and
#      anything separated from the code by a blank line, which is how a file
#      header keeps its last line from being dragged onto the first operation.
#
#      bfexpand's own "; walk in"/"; walk back" wrappers used to be listed there
#      too, and that was wrong: each is a single line labelling the one code
#      line beneath it, which is the definition of an annotation. Left at column
#      zero they were the only such label in the file not in the right hand
#      column, so the eye could not run down that column and find everything.
#
#   2. A code line longer than CODEW is split. Newlines are inert in brainfuck,
#      so this cannot change meaning, and tools/bflint proves that by comparing
#      the instruction stream against the canonical one. Continuations carry
#      "; continued" so no line is ever a bare wall of arrows.
#
#   3. Annotations are padded to a fixed column so they line up.
#
# It is idempotent: a line that already carries a trailing annotation is taken
# apart and laid out again, which is what lets a routine that has already been
# laid out be pasted into a caller and come out consistent.
use strict;
use warnings;

my $COL   = 64;   # the column an annotation starts in (1-based)
my $CODEW = 60;   # the most code characters allowed on one line
my $MAXW  = 118;  # the widest line to emit; long remarks wrap down the column
my $ANNW  = $MAXW - $COL - 1;

# Break an annotation into pieces that fit the right hand column, keeping the
# original spacing between words. The double space that ends a sentence here is
# punctuation -- a full stop would be an instruction -- so it must survive.
sub wrap_ann {
    my ($ann) = @_;
    return () unless defined $ann && length $ann;
    my @toks;
    while ($ann =~ /(\s*)(\S+)/g) { push @toks, [$1, $2] }
    my (@out, $cur);
    $cur = '';
    for my $t (@toks) {
        my ($gap, $word) = @$t;
        if (!length $cur) { $cur = $word; next }
        if (length($cur) + length($gap) + length($word) <= $ANNW) { $cur .= $gap . $word }
        else { push @out, $cur; $cur = $word }
    }
    push @out, $cur if length $cur;
    return @out;
}

my @pending;      # comment lines seen since the last code line

sub is_structure {
    my ($c) = @_;
    return 1 if $c =~ /^;\s*$/;                 # a spacer
    return 1 if $c =~ /^; ASSERT\b/;            # binds to the next instruction
    return 1 if $c =~ /^; emit\b/;              # a section boundary bfexpand cuts on
    return 1 if $c =~ /^; INTERFACE\b/;
    return 1 if $c =~ /^; ====/;                # a section banner
    return 1 if $c =~ /^;\s+\@/;                # a tape map row
    return 1 if $c =~ /^; continued\b/;         # already a continuation
    return 0;
}

my $seen_code = 0;   # the header keeps column zero; the body does not

# Four kinds of line keep column zero even inside the body, and only one of
# those is a matter of taste.
#
# "; emit" and "; INTERFACE" are ANCHORS: tools/bffoot finds the end of a body
# with strncmp(line, "; emit", 6) and tools/bfexpand cuts on /^; emit/ and
# greps '^; INTERFACE'. Indent either and a routine stops being pasteable,
# quietly, which is the worst way for it to stop.
#
# A tape map row belongs to the header block and is a table, not a remark.
#
# A section banner is the matter of taste: it is wider than the annotation
# column, so indenting it would wrap it across three lines and make the thing
# it is meant to separate harder to find, not easier.
sub anchored_left {
    my ($c) = @_;
    return 1 if $c =~ /^;\s*$/;                 # a spacer has nothing to align
    return 1 if $c =~ /^\s*; emit\b/;           # bffoot and bfexpand cut on this
    return 1 if $c =~ /^\s*; INTERFACE\b/;      # bfexpand greps for it
    return 1 if $c =~ /^\s*; ====/;             # a banner is wider than the column
    return 1 if $c =~ /^;\s+\@/;                # a tape map row
    return 0;
}

# Everything else in the body is indented into the annotation column, so the
# English runs down ONE column with no breaks in it.
#
# This used to print every pending line verbatim at column zero, which left two
# kinds of line stranded on the left: an ASSERT, and every line but the last of
# a multi-line remark. Reading the right hand column then meant the eye jumping
# back to column zero and out again several times per screen -- which defeats
# the whole point of having two columns, and was the loudest thing wrong with
# the committed files.
#
# An ASSERT still keeps its own line, because it binds to the next instruction
# and folding it onto a code line would bind it to the previous one. Its own
# line is not the same requirement as column zero, and the two were conflated.
# A run of consecutive remark lines is REFLOWED as one paragraph rather than
# wrapped line by line. The author's line breaks were chosen against column
# zero and a 78 column page; re-using them against a 53 column gutter gives a
# ragged edge and half-empty lines, which looks like a mistake even though the
# words are right. Joining first and wrapping after gives back a tidy block.
sub flush_pending {
    my @para;
    my $flush_para = sub {
        return unless @para;
        my $t = join ' ', @para;
        print ' ' x ($COL - 1), "; $_\n" for wrap_ann($t);
        @para = ();
    };
    for my $c (@pending) {
        if (!$seen_code || anchored_left($c)) { $flush_para->(); print "$c\n"; next }
        my $t = $c;
        $t =~ s/^\s*;\s?//;
        # An ASSERT keeps its own line and is never folded into a paragraph:
        # it binds to the next instruction, so anything printed between it and
        # that instruction would be wrong, and running two of them together
        # would bind the second nowhere.
        if ($c =~ /^\s*; ASSERT\b/) {
            $flush_para->();
            print ' ' x ($COL - 1), "; $t\n";
            next;
        }
        push @para, $t;
    }
    $flush_para->();
    @pending = ();
}

# Emit one code line, split and aligned, with an optional annotation.
sub emit_code {
    my ($code, $ann) = @_;
    $code =~ s/\s+$//;
    my ($indent) = $code =~ /^(\s*)/;
    my $body = substr $code, length $indent;

    my @chunks;
    if (length($indent) + length($body) <= $CODEW) {
        push @chunks, $indent . $body;
    } else {
        my $first = 1;
        while (length $body) {
            my $pad  = $first ? $indent : '  ';
            my $room = $CODEW - length $pad;
            push @chunks, $pad . substr($body, 0, $room);
            $body = length($body) > $room ? substr($body, $room) : '';
            $first = 0;
        }
    }

    # Code chunks pair off against annotation pieces down the two columns. A
    # long run of arrows beside a long explanation reads down either side. When
    # one column runs out first, the code says "continued" and the annotation
    # simply carries on beside empty code.
    my @notes = wrap_ann($ann);
    my $n = @chunks > @notes ? @chunks : @notes;
    for my $i (0 .. $n - 1) {
        my $c = $i < @chunks ? $chunks[$i] : '';
        my $a = $i < @notes  ? $notes[$i]
              : ($i < @chunks && @notes ? 'continued' : undef);
        $a = 'continued' if !defined($a) && $i > 0 && $i < @chunks;
        if (defined $a && length $a) {
            $c .= ' ' while length($c) < $COL - 1;
            print "$c; $a\n";
        } else {
            print "$c\n";
        }
    }
}

while (my $line = <>) {
    chomp $line;

    if ($line =~ /^\s*$/) {          # a blank line ends a comment block
        flush_pending();
        print "\n";
        next;
    }

    if ($line =~ /^\s*;/) {          # a comment line
        push @pending, $line;
        next;
    }

    # A code line, possibly already carrying a trailing annotation.
    my ($code, $ann) = ($line, undef);
    if ($line =~ /^([^;]*);\s*(.*)$/) { ($code, $ann) = ($1, $2); }

    # A SINGLE plain-prose comment above the line becomes its annotation. Two or
    # more in a row are a paragraph, not a label -- the header of a file, or a
    # note that needed a second line -- and a paragraph stays where it was
    # written. Dragging only its last line into the right hand column would
    # split a sentence across two layouts, which is exactly what the first
    # draft of this did.
    if (!defined $ann && @pending && !is_structure($pending[-1])
        && (@pending < 2 || is_structure($pending[-2]))) {
        my $c = pop @pending;
        $c =~ s/^;\s*//;
        $ann = $c;
    }
    flush_pending();
    emit_code($code, $ann);
    $seen_code = 1;
}
flush_pending();
