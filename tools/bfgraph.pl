#!/usr/bin/perl
# bfgraph.pl — the skeleton dependency graph, as a draw.io file.  PROTOTYPE.
#
#   bfgraph.pl              check graph.drawio still matches the tree
#   bfgraph.pl --fix        rewrite it
#   bfgraph.pl --audit      report the geometry, and fail if it is unreadable
#   bfgraph.pl --selftest   prove the audit complains when it should
#   bfgraph.pl --slice X    stdout only, the subgraph reachable from X
#
# THE AUDIT IS THE POINT OF HAVING A TOOL AT ALL. A picture that is redrawn
# automatically can become unreadable automatically, so the geometry is
# measured rather than eyeballed: no line may cross a node it does not
# connect, no two lines may lie on top of one another, and there are minimum
# separations. Every one of those failed at some point while this was being
# written -- 27 lines through unrelated nodes, 40 lines 2px apart -- and each
# time it was the measurement that said so, not the looking.
#
# Documentation derived from the tree, in the same family as tools/bftable.pl
# and tools/bftier.pl: a generated artifact whose job is to be CHECKED against
# reality rather than trusted. Not the thing CONVENTIONS section 6 forbids --
# that rule is about .skel files, which a person writes. A picture of the
# graph is not a component of the library.
#
# THE LAYOUT IS SUGIYAMA, and it has to be. Fifty three percent of the edges
# in this tree skip at least one column: aes/encrypt128 reaches idiom/xor8
# across four of them. A layered picture that draws those as straight lines
# puts them through whatever nodes lie between, which is what the first cut
# did. So every long edge is broken into a chain of DUMMY points, one in each
# column it crosses, the dummies take part in the crossing-reduction ordering
# alongside real nodes, and each resulting segment spans exactly one column.
use strict;
use warnings;
use File::Basename qw(dirname);
use Cwd qw(abs_path);

my $here = dirname(abs_path($0));
my $repo = $ENV{BFGRAPH_REPO} || abs_path("$here/..");
my $slice = '';
my $mode  = 'check';
for (my $i = 0; $i < @ARGV; $i++) {
    $slice = $ARGV[$i+1] if $ARGV[$i] eq '--slice';
    $mode  = 'fix'      if $ARGV[$i] eq '--fix';
    $mode  = 'audit'    if $ARGV[$i] eq '--audit';
    $mode  = 'selftest' if $ARGV[$i] eq '--selftest';
}
my $OUT = "$repo/graph.drawio";
my $MIN_LINE = 20;      # between two parallel lines
my $MIN_NODE = 24;      # between a line and a node it does not touch
exit selftest() if $mode eq 'selftest';

# ---- the graph ------------------------------------------------------------
my %case;
open my $bx, '<', "$repo/tools/bfexpand.sh" or die "no bfexpand: $!\n";
while (<$bx>) { $case{$1} = $2 if /^\s*'\@\@([A-Z0-9]+)\@\@'\*\)\s*import "\$repo\/(\S+?)\.bf"/ }
close $bx;

my (%edge, %node);
opendir my $rd, $repo or die $!;
my @dirs = sort grep { -d "$repo/$_" && !/^\./ } readdir $rd;
closedir $rd;
for my $dir (@dirs) {
    opendir my $d, "$repo/$dir" or next;
    for my $f (sort grep { /\.skel$/ } readdir $d) {
        (my $name = "$dir/$f") =~ s/\.skel$//;
        $node{$name} = 1;
        open my $fh, '<', "$repo/$dir/$f" or next;
        while (my $l = <$fh>) {
            my $t;
            $t = $case{$1} if $l =~ /^\@\@([A-Z0-9]+)\@\@/;
            $t = $1        if $l =~ /^\s*%%(.*?)%%\s*$/;
            next unless defined $t && $t ne $name;
            $edge{$name}{$t}++; $node{$t} = 1;
        }
        close $fh;
    }
    closedir $d;
}

if ($slice) {
    my (%keep, @q);
    for (keys %node) { if (/^\Q$slice\E/) { $keep{$_} = 1; push @q, $_ } }
    while (my $n = shift @q) {
        for my $t (keys %{ $edge{$n} || {} }) { next if $keep{$t}++; push @q, $t }
    }
    %node = map { $_ => 1 } keys %keep;
    for my $s (keys %edge) {
        if (!$keep{$s}) { delete $edge{$s}; next }
        for my $t (keys %{ $edge{$s} }) { delete $edge{$s}{$t} unless $keep{$t} }
    }
}

# ---- depth: the longest path to a leaf ------------------------------------
my %depth;
sub depth {
    my ($n) = @_;
    return $depth{$n} if exists $depth{$n};
    $depth{$n} = 0;                                  # bfdag proves acyclicity
    my $d = 0;
    for my $t (keys %{ $edge{$n} || {} }) { my $c = depth($t) + 1; $d = $c if $c > $d }
    return $depth{$n} = $d;
}
depth($_) for keys %node;
my $maxd = 0;
for (values %depth) { $maxd = $_ if $_ > $maxd }

my %lines;
for my $n (keys %node) {
    my $c = 0;
    if (open my $fh, '<', "$repo/$n.skel") { $c++ while <$fh>; close $fh }
    $lines{$n} = $c;
}
my %indeg;
for my $s (keys %edge) { $indeg{$_}++ for keys %{ $edge{$s} } }

# ---- items per layer: real nodes, plus a dummy per crossed column ---------
my (@E, %items, %chain);
my $ei = 0;
for my $s (sort keys %edge) {
    for my $t (sort keys %{ $edge{$s} }) {
        my ($ds, $dt) = ($depth{$s}, $depth{$t});
        my @mid;
        for (my $d = $ds - 1; $d > $dt; $d--) {
            my $id = "d:$ei:$d";
            push @{ $items{$d} }, $id;
            push @mid, [$d, $id];
        }
        push @E, { s => $s, t => $t, n => $edge{$s}{$t}, mid => \@mid };
        # the ordering graph is the chain, so every link is between neighbours
        my @path = ("n:$s", (map { $_->[1] } @mid), "n:$t");
        for my $i (0 .. $#path - 1) {
            push @{ $chain{ $path[$i] } }, $path[$i + 1];
            push @{ $chain{ $path[$i + 1] } }, $path[$i];
        }
        $ei++;
    }
}
push @{ $items{ $depth{$_} } }, "n:$_" for sort keys %node;
for my $d (keys %items) { @{ $items{$d} } = sort @{ $items{$d} } }

# ---- barycentre sweeps ----------------------------------------------------
my %pos;
for my $d (keys %items) { my $i = 0; $pos{$_} = $i++ for @{ $items{$d} } }
for my $pass (1 .. 12) {
    my @order = sort { $a <=> $b } keys %items;
    @order = reverse @order if $pass % 2;
    for my $d (@order) {
        my %bary;
        for my $it (@{ $items{$d} }) {
            my @nb = grep { defined $pos{$_} } @{ $chain{$it} || [] };
            $bary{$it} = @nb ? (eval { my $s = 0; $s += $pos{$_} for @nb; $s / @nb })
                             : $pos{$it};
        }
        @{ $items{$d} } = sort { $bary{$a} <=> $bary{$b} || $a cmp $b } @{ $items{$d} };
        my $i = 0; $pos{$_} = $i++ for @{ $items{$d} };
    }
}

# ---- geometry -------------------------------------------------------------
# Rows first. Columns cannot be placed yet, because how wide a gutter must be
# depends on how many lines have to run through it, and that is not known
# until the lanes are assigned.
my ($W, $H, $TOP) = (190, 46, 40);
my ($MARGIN, $STEP) = (28, 20);     # clear air beside a column; lane pitch
# A node needs a row it can sit in; a dummy is only a corner a line turns at,
# so it gets a slim one. Giving both 92px made the full graph 7210px tall for
# no gain -- most of those rows held nothing but a bend.
my ($ROW_NODE, $ROW_DUMMY) = (92, 30);

# Centres, not tops, because the two kinds of row are different heights.
my %yc;
for my $d (keys %items) {
    my $cur = $TOP;
    for my $it (@{ $items{$d} }) {
        my $slot = $it =~ /^n:/ ? $ROW_NODE : $ROW_DUMMY;
        $yc{$it} = $cur + $slot / 2;
        $cur += $slot;
    }
}
my %y;
$y{$_} = $yc{$_} - ($_ =~ /^n:/ ? $H / 2 : 0) for keys %yc;

# ---- anchors are spread along the node edge ------------------------------
# Every edge used to leave and arrive at the exact middle of a node's side,
# so all of a node's edges began collinear and stayed that way down the first
# stub. Fanning them across the side separates them at birth, and it also
# stops an edge LEAVING a node colliding with one ARRIVING at the node
# directly to its right when the two happen to share a row.
my (%exit_at, %entry_at);
{
    my (%out, %in);
    for my $e (@E) { push @{ $out{$e->{s}} }, $e; push @{ $in{$e->{t}} }, $e }
    for my $n (keys %out) {
        my @o = sort { $y{"n:$a->{t}"} <=> $y{"n:$b->{t}"} } @{ $out{$n} };
        for my $i (0 .. $#o) {
            $exit_at{"$o[$i]{s}|$o[$i]{t}"} =
                @o == 1 ? 0.5 : 0.15 + 0.7 * $i / ($#o);
        }
    }
    for my $n (keys %in) {
        my @o = sort { $y{"n:$a->{s}"} <=> $y{"n:$b->{s}"} } @{ $in{$n} };
        for my $i (0 .. $#o) {
            $entry_at{"$o[$i]{s}|$o[$i]{t}"} =
                @o == 1 ? 0.5 : 0.15 + 0.7 * $i / ($#o);
        }
    }
}

# ---- every vertical run gets its own lane --------------------------------
# Lanes are assigned by greedy interval colouring, so two runs share one only
# when their y ranges do not overlap. The lane COUNT is then the real
# congestion of that gutter, and the gutter is made wide enough to hold them
# at a fixed pitch. Dividing a fixed width by the lane count instead -- the
# previous attempt -- put forty lines 2px apart in the busiest gutter.
my %runs;
for my $e (@E) {
    my @ys = ($y{"n:$e->{s}"} + $H * $exit_at{"$e->{s}|$e->{t}"});
    push @ys, $yc{ $_->[1] } for @{ $e->{mid} };
    push @ys, $y{"n:$e->{t}"} + $H * $entry_at{"$e->{s}|$e->{t}"};
    $e->{ys} = \@ys;
    $e->{g0} = $maxd - $depth{ $e->{s} };
    for my $i (0 .. $#ys - 1) {
        push @{ $runs{ $e->{g0} + $i } },
             { e => $e, i => $i,
               lo => ($ys[$i] < $ys[$i+1] ? $ys[$i] : $ys[$i+1]),
               hi => ($ys[$i] < $ys[$i+1] ? $ys[$i+1] : $ys[$i]) };
    }
}
my (%lane, %lanes_in);
for my $g (sort { $a <=> $b } keys %runs) {
    my @r = sort { $a->{lo} <=> $b->{lo} || $a->{hi} <=> $b->{hi} } @{ $runs{$g} };
    my @endof;
    for my $r (@r) {
        my $k = 0;
        $k++ while defined $endof[$k] && $endof[$k] > $r->{lo} - 16;
        $endof[$k] = $r->{hi};
        $lane{"$r->{e}{s}|$r->{e}{t}|$r->{i}"} = $k;
        $lanes_in{$g} = $k + 1 if ($lanes_in{$g} || 0) < $k + 1;
    }
}

# ---- now the columns, each gutter as wide as its traffic -----------------
my @X = (40);
for my $g (0 .. $maxd - 1) {
    my $need = ($lanes_in{$g} || 1);
    push @X, $X[-1] + $W + 2 * $MARGIN + ($need - 1) * $STEP;
}
my %x;
for my $d (keys %items) { $x{$_} = $X[ $maxd - $d ] for @{ $items{$d} } }
sub gutter_x { my ($g, $k) = @_; return $X[$g] + $W + $MARGIN + $k * $STEP }

my %fill = (idiom=>'#dae8fc', index=>'#f8cecc', aes=>'#d5e8d4', chacha20=>'#ffe6cc',
            poly1305=>'#fff2cc', keccak=>'#e1d5e7', sha256=>'#d0e0e3',
            sha512=>'#cfe2f3', aead=>'#f4cccc', block=>'#ffffff');
my %line = (idiom=>'#6c8ebf', index=>'#b85450', aes=>'#82b366', chacha20=>'#d79b00',
            poly1305=>'#d6b656', keccak=>'#9673a6', sha256=>'#45818e',
            sha512=>'#6fa8dc', aead=>'#cc0000', block=>'#666666');

sub esc { my $t = shift; $t =~ s/&/&amp;/g; $t =~ s/</&lt;/g; $t =~ s/>/&gt;/g;
          $t =~ s/"/&quot;/g; $t }

my (@cells, %cid, @SEG);
my $id = 2;
for my $n (sort keys %node) {
    my ($dir) = $n =~ m{^([^/]+)/};
    my $leaf = !$edge{$n} || !keys %{ $edge{$n} };
    my $root = !$indeg{$n};
    my $style = "rounded=1;whiteSpace=wrap;html=1;"
              . "fillColor=" . ($fill{$dir} || '#eeeeee') . ";"
              . "strokeColor=" . ($line{$dir} || '#999999') . ";"
              . "fontSize=11;fontFamily=Courier New;spacingTop=-2;"
              . ($root ? "strokeWidth=3;" : "strokeWidth=1;")
              . ($leaf ? "dashed=1;" : "")
              . (($lines{$n} || 0) > 2000 ? "fontStyle=1;" : "");
    my @sub;
    push @sub, "$lines{$n} lines"   if $lines{$n};
    push @sub, "$indeg{$n} callers" if ($indeg{$n} || 0) > 1;
    my $label = esc($n) . (@sub ? "&#10;" . join("  ", @sub) : "");
    $cid{$n} = $id;
    push @cells, sprintf('<mxCell id="%d" value="%s" style="%s" vertex="1" parent="1">'
        . '<mxGeometry x="%d" y="%d" width="%d" height="%d" as="geometry"/></mxCell>',
        $id++, $label, $style, $x{"n:$n"}, $y{"n:$n"}, $W, $H);
}

for my $e (@E) {
    my ($s, $t, $n) = ($e->{s}, $e->{t}, $e->{n});
    my ($dir) = $s =~ m{^([^/]+)/};
    my $style = "edgeStyle=orthogonalEdgeStyle;rounded=0;html=1;jettySize=8;"
              . sprintf("exitX=1;exitY=%.3f;exitDx=0;exitDy=0;entryX=0;entryY=%.3f;entryDx=0;entryDy=0;",
                        $exit_at{"$s|$t"}, $entry_at{"$s|$t"})
              . "strokeColor=" . ($line{$dir} || '#999999') . ";endArrow=block;endFill=1;"
              . ($n > 1 ? "strokeWidth=2;" : "strokeWidth=1;opacity=55;");
    my @ys = @{ $e->{ys} };
    my @pts;
    for my $i (0 .. $#ys - 1) {
        my $gx = gutter_x($e->{g0} + $i, $lane{"$s|$t|$i"} || 0);
        push @pts, [ $gx, $ys[$i] ], [ $gx, $ys[$i+1] ];
    }
    my @route = ([ $x{"n:$s"} + $W, $ys[0] ], @pts, [ $x{"n:$t"}, $ys[-1] ]);
    for my $k (0 .. $#route - 1) {
        push @SEG, [ $route[$k][0], $route[$k][1],
                     $route[$k+1][0], $route[$k+1][1], $s, $t ];
    }
    push @cells, sprintf('<mxCell id="%d" value="%s" style="%s" edge="1" parent="1" '
        . 'source="%d" target="%d"><mxGeometry relative="1" as="geometry">%s</mxGeometry></mxCell>',
        $id++, ($n > 1 ? "x$n" : ""), $style, $cid{$s}, $cid{$t},
        '<Array as="points">' . join('', map { sprintf('<mxPoint x="%d" y="%d"/>', @$_) } @pts) . '</Array>');
}

my $title = $slice ? "bfsodium include graph -- $slice" : "bfsodium include graph";
my $xml = <<"XML";
<mxfile host="bfgraph" type="device">
  <diagram name="@{[ esc($title) ]}" id="bfsodium">
    <mxGraphModel dx="1400" dy="900" grid="1" gridSize="10" guides="1" tooltips="1"
                  connect="1" arrows="1" fold="1" page="1" pageScale="1"
                  pageWidth="1600" pageHeight="1200" math="0" shadow="0">
      <root>
        <mxCell id="0"/>
        <mxCell id="1" parent="0"/>
        @{[ join "\n        ", @cells ]}
      </root>
    </mxGraphModel>
  </diagram>
</mxfile>
XML

# ---------------------------------------------------------------------------
# The geometry, measured. Returns a list of complaints; empty means readable.
sub audit {
    my ($seg, $box) = @_;
    my @bad;

    # 1. no line may cross a node it does not connect
    my $clips = 0;
    for my $g (@$seg) {
        my ($x1, $y1, $x2, $y2, $s, $t) = @$g;
        my ($lo_x, $hi_x) = $x1 < $x2 ? ($x1, $x2) : ($x2, $x1);
        my ($lo_y, $hi_y) = $y1 < $y2 ? ($y1, $y2) : ($y2, $y1);
        for my $n (keys %$box) {
            next if $n eq $s || $n eq $t;
            my ($nx, $ny, $nw, $nh) = @{ $box->{$n} };
            $clips++ if $lo_x < $nx + $nw && $hi_x > $nx
                     && $lo_y < $ny + $nh && $hi_y > $ny;
        }
    }
    push @bad, "$clips line segment(s) cross a node they do not connect" if $clips;

    # 2. no two parallel lines may lie on top of one another
    my (%V, %H);
    for my $g (@$seg) {
        my ($x1, $y1, $x2, $y2, $s, $t) = @$g;
        push @{ $V{$x1} }, [ $y1 < $y2 ? ($y1,$y2) : ($y2,$y1), "$s|$t" ] if $x1 == $x2;
        push @{ $H{$y1} }, [ $x1 < $x2 ? ($x1,$x2) : ($x2,$x1), "$s|$t" ] if $y1 == $y2;
    }
    my $vov = 0;
    for my $k (keys %V) {
        my @v = sort { $a->[0] <=> $b->[0] } @{ $V{$k} };
        for my $i (0 .. $#v) {
            for my $j ($i+1 .. $#v) {
                last if $v[$j][0] >= $v[$i][1];
                $vov++ if $v[$i][2] ne $v[$j][2];
            }
        }
    }
    push @bad, "$vov pair(s) of vertical lines lie on top of one another" if $vov;

    # 3. minimum separations
    my $near_l = 1e9;
    my @ks = sort { $a <=> $b } keys %V;
    for my $i (0 .. $#ks) {
        for my $j ($i+1 .. $#ks) {
            last if $ks[$j] - $ks[$i] >= $near_l;
            for my $a (@{ $V{$ks[$i]} }) {
                for my $b (@{ $V{$ks[$j]} }) {
                    next unless $a->[0] < $b->[1] && $b->[0] < $a->[1];
                    $near_l = $ks[$j] - $ks[$i];
                }
            }
        }
    }
    my $near_n = 1e9;
    for my $g (@$seg) {
        my ($x1, $y1, $x2, $y2, $s, $t) = @$g;
        my ($lo_x, $hi_x) = $x1 < $x2 ? ($x1, $x2) : ($x2, $x1);
        my ($lo_y, $hi_y) = $y1 < $y2 ? ($y1, $y2) : ($y2, $y1);
        for my $n (keys %$box) {
            next if $n eq $s || $n eq $t;
            my ($nx, $ny, $nw, $nh) = @{ $box->{$n} };
            my $dx = $nx - $hi_x;  $dx = $lo_x - ($nx+$nw) if $lo_x > $nx+$nw;
            $dx = 0 if $dx < 0;
            my $dy = $ny - $hi_y;  $dy = $lo_y - ($ny+$nh) if $lo_y > $ny+$nh;
            $dy = 0 if $dy < 0;
            my $d = sqrt($dx*$dx + $dy*$dy);
            $near_n = $d if $d < $near_n;
        }
    }
    push @bad, sprintf("closest parallel lines are %.0fpx apart, minimum is %d",
                       $near_l, $MIN_LINE) if $near_l < $MIN_LINE;
    push @bad, sprintf("closest line to an unrelated node is %.0fpx, minimum is %d",
                       $near_n, $MIN_NODE) if $near_n < $MIN_NODE;
    return (\@bad, $clips, $vov, $near_l, $near_n);
}

sub selftest {
    # Both polarities, on geometry made up for the purpose: the audit must
    # accept a clean picture and complain about each way one goes wrong.
    my $fails = 0;
    my $case = sub {
        my ($name, $seg, $box, $want) = @_;
        my ($bad) = audit($seg, $box);
        my $got = @$bad ? 1 : 0;
        printf "%s bfgraph selftest: %s\n", $got == $want ? "PASS" : "FAIL", $name;
        $fails++ unless $got == $want;
    };
    my %two = (a => [0,0,100,40], b => [400,0,100,40]);
    $case->("a clear line between two nodes is accepted",
            [[100,20,400,20,'a','b']], \%two, 0);
    $case->("a line through a third node is caught",
            [[100,20,400,20,'a','b']],
            { %two, c => [200,0,100,40] }, 1);
    $case->("two lines on the same track are caught",
            [[200,0,200,100,'a','b'], [200,50,200,150,'a','c']], \%two, 1);
    $case->("parallel lines closer than the minimum are caught",
            [[200,0,200,100,'a','b'], [205,0,205,100,'a','c']], \%two, 1);
    $case->("a line grazing a node is caught",
            [[100,20,400,20,'a','b']],
            { %two, c => [200,15,100,40] }, 1);
    print $fails ? "bfgraph: $fails selftest(s) failed\n" : "bfgraph: selftests pass\n";
    return $fails ? 1 : 0;
}

my %box = map { $_ => [ $x{"n:$_"}, $y{"n:$_"}, $W, $H ] } keys %node;
my ($bad, $clips, $vov, $near_l, $near_n) = audit(\@SEG, \%box);

if ($slice) { print $xml; exit 0 }

if ($mode eq 'audit') {
    printf "bfgraph: %d nodes, %d edges, %d segments\n",
        scalar(keys %node), scalar(@E), scalar(@SEG);
    printf "         clips %d  vertical overlaps %d  line-to-line %.0fpx  line-to-node %.0fpx\n",
        $clips, $vov, $near_l, $near_n;
    if (@$bad) { print "FAIL bfgraph: the picture is not readable:\n";
                 print "     $_\n" for @$bad; exit 1 }
    print "bfgraph: the picture is readable\n";
    exit 0;
}

if ($mode eq 'fix') {
    open my $o, '>', $OUT or die "bfgraph: cannot write $OUT: $!\n";
    print $o $xml; close $o;
    print "bfgraph: graph.drawio rewritten\n";
    exit 0;
}

# default: the committed picture must be the one this tree produces
my $have = '';
if (open my $i, '<', $OUT) { local $/; $have = <$i>; close $i }
if ($have ne $xml) {
    print "FAIL bfgraph: graph.drawio does not match the tree; run bfgraph.pl --fix\n";
    exit 1;
}
printf "bfgraph: graph.drawio matches the tree (%d nodes, %d edges)\n",
    scalar(keys %node), scalar(@E);
exit 0;
