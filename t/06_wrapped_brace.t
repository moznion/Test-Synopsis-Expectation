#!perl

use strict;
use warnings;
use FindBin;
use File::Spec::Functions qw/catfile/;

use Test::Synopsis::Expectation;
use Test::More;

my $target_file = catfile($FindBin::Bin, 'resources', 'wrapped_brace.pod');
synopsis_ok($target_file);

done_testing;
