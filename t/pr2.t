use Test::More qw(no_plan);
use ExtUtils::testlib;

use Algorithm::PageRank;
ok(1);

$pr = new Algorithm::PageRank;
$Algorithm::PageRank::d_factor = 0.05;
$pr->graph([
	    qw(
	       0 1
	       0 2
	       1 2
	       
	       3 4
	       3 5
	       3 6
	       4 3
	       4 6
	       5 3
	       5 6
	       6 4
	       6 3
	       6 5
	       )
	    ]);
$pr->iterate(100);

@r = $pr->result()->list;
@a = (
      '0',
      '0',
      '0',
      '0.00101494786634297',
      '0.000676631910895312',
      '0.000676631910895312',
      '0.00101494786634297'
      );

foreach (0..$#r){
    ok(abs($r[$_] - $a[$_] < 0.000001), "Weakly-connected graph" );
}



__END__
