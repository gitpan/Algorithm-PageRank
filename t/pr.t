use Test::More qw(no_plan);
use ExtUtils::testlib;

use Algorithm::PageRank;
$pr = new Algorithm::PageRank;
$Algorithm::PageRank::d_factor = 0;

$pr->graph([
	qw(
	0 1
	0 2
	0 3
	0 4
	0 6

	1 0

	2 0
	2 1

	3 1
	3 2
	3 4

	4 0
	4 2
	4 3
	4 5

	5 0
	5 4

	6 4
	)
	]);

$pr->iterate(100);

$pr->result();

ok(1);
