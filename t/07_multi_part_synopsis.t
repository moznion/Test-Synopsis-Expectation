#!perl

use strict;
use warnings;
use FindBin;
use File::Spec::Functions qw/catfile/;

use Test::Synopsis::Expectation;

my $target_file = catfile($FindBin::Bin, 'resources', 'multi_part_synopsis.pod');
synopsis_ok($target_file);

done_testing;
