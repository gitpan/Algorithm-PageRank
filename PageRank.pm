package Algorithm::PageRank;
$|++;
use 5.006;
use strict;
use XSLoader;
our $VERSION = '0.02';
XSLoader::load 'Algorithm::PageRank';

sub new {
    my $pkg = shift;
    my $arg = {@_};
    die "Please specify db file's prefix for writing\n" unless $arg->{dbprefix};
    die "The number of vertexes is supposed to be greater than 4\n" unless $arg->{num_vertex} >= 5;
    bless {
	dbprefix => $arg->{dbprefix},
	outdeg => {},
	num_vertex => $arg->{num_vertex},
	matrix => _create_matrix($arg->{num_vertex}),
	prv    => _create_prv($arg->{num_vertex}),
    }, $pkg;
}

sub DESTROY {
    my $pkg = shift;
    _kill_prv($pkg->{prv});
    _kill_matrix($pkg->{matrix}, $pkg->{num_vertex});
    close $pkg->{dbh};
}


use List::Util qw/max/;
sub graph {
    my $pkg = shift;
    my $arrf = ref($_[0]) eq 'ARRAY' ? $_[0] : \@_;
    my $prev = -1;
    my $t;

    for(my $i=0; $i<$#$arrf; $i+=2){
	push @{$t->{$arrf->[$i+1]}}, $arrf->[$i];
	$pkg->{outdeg}->{$arrf->[$i]}++;
    }

    # recording out degrees
    open F, '>', $pkg->{dbprefix}.'.outdeg';
    my $max = max keys %{$pkg->{outdeg}};
    foreach (0..$max){
	print F pack("i", ($pkg->{outdeg}->{$_} || 0) );
    }
    close F;
    open $pkg->{dbh}, '>', $pkg->{dbprefix} or die "Cannot open $pkg->{dbprefix} for writing\n" ;

    for my $k ( sort { $a <=> $b } keys %$t ){
	print { $pkg->{dbh} } $k, ' ', join( q/,/, sort { $a <=> $b } @{$t->{$k}}), "\n";
    }
    close $pkg->{dbh};
}

sub _convert2bin {
    my $pkg = shift;
    my $prev;
    my $accu_cnt = 0;

    # index file
    open IDX, '>', $pkg->{dbprefix}.".idx";
    # inverted file
    open INV, '>', $pkg->{dbprefix}.".inv";

    binmode(INV);
    binmode(IDX);

    print IDX pack("i", $pkg->{num_vertex});

    open F, $pkg->{dbprefix};
    while(chomp($_=<F>)){
	my ($curnode, $predstr) = split /\s/o;
	my @predec = eval $predstr;  # predecessor
	print IDX pack("ii",  $accu_cnt, scalar @predec);
	print INV pack("i*", sort { $a <=> $b } @predec);
	$accu_cnt += @predec;
    }
    close F;

    close INV;
    close IDX;

}

sub iterate {
    my $pkg = shift;
    my $iter = shift || 100;
    $pkg->_convert2bin;

    _multiply(
	      $pkg->{num_vertex},
	      $pkg->{matrix},
	      $pkg->{prv},
	      $iter,
	      $pkg->{dbprefix}
	      );
}

sub pagerank {
    my $pkg = shift;
    die "Cannot exceed $pkg->{num_vertex}\n" if $_[0] >= $pkg->{num_vertex};
    if(defined $_[0] && $_[0] >= 0){
	return _getscalar($pkg->{dbprefix}, $_[0]);
    }
    my @ret;
    open F, $pkg->{dbprefix}.'.pr' or die "cannot open pagerank file\n";
    binmode(F);
    @ret = unpack("d*", <F>);
    close F;
    @ret;
}

1;
__END__
# Below is stub documentation for your module. You better edit it!

=head1 NAME

Algorithm::PageRank - Calculating PageRank

=head1 SYNOPSIS

  use Algorithm::PageRank;
  $pr = Algorithm::PageRank->new( dbprefix => $prefix);

  $pr->graph([
	      0 => 1,
	      0 => 2,
	      1 => 0,
	      2 => 1,
	      ]
	      );

  $pr->iterate(100);

  $pr->pagerank();

=head1 DESCRIPTION

This is a simple implementation of pagerank algorithm exploited by Google. Please do not expect it to be potent to cope with zilla-size of data.

=head2 new

The contructor. Please specify the prefix of db files.

=head2 graph

Feeding the graph topology. Vertices count from 0, which are all of integer, and there is not expected to be any gap within the integer series.

=head2 iterate

Calculating the pagerank vector. The parameter is the maximal number of iterations. If the vector does not converge before reaching the threshold, then calculation will stop at the maximum. Default is 100.

=head2 pagerank

Returns the pagerank vector. You can give an extra index number for retrieval of a scalar. 


=head1 COPYRIGHT

xern E<lt>xern@cpan.orgE<gt>

This module is free software; you can redistribute it or modify it under the same terms as Perl itself.

=cut
