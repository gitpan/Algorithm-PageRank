use ExtUtils::MakeMaker;


WriteMakefile(
    'NAME'		=> 'Algorithm::PageRank',
    'VERSION_FROM'	=> 'PageRank.pm', 
    'PREREQ_PM'		=> {}, 
    ($] >= 5.005 ?    
      (ABSTRACT_FROM => 'PageRank.pm', 
       AUTHOR     => 'xern <xern@cpan.org>') : ()),
    'LIBS'		=> ['-lz'], 
    'DEFINE'		=> '', 
	
    'INC'		=> '', 
	
    
);
