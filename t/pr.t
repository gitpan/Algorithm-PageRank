use Test;
BEGIN { plan tests => 3 };
ok(1);

use Algorithm::PageRank;


$pr = new Algorithm::PageRank(
			      dbprefix => 't/db.tmp',
			      num_vertex => 5,
			      );

$pr->graph([
	    qw/
	    0 2
	    1 0
	    1 2
	    1 3
	    1 4
	    2 4
	    3 1
	    3 2
	    4 2
	    4 3
	    /
	     ]);

$pr->iterate(1000);


ok( $pr->pagerank(2), 0.321183459725857101);
@ret = $pr->pagerank();
ok( $ret[3], 0.194100711964219047);

unlink $_ for qw,t/db.tmp  t/db.tmp.idx  t/db.tmp.inv  t/db.tmp.outdeg  t/db.tmp.pr,;
