#!perl

use strict;
use warnings;
use FindBin;
use File::Spec::Functions qw/catfile/;

use Test::Synopsis::Expectation;
use Test::More;

my $target_file = catfile($FindBin::Bin, 'resources', 'less.pod');
open my $fh, '<', $target_file;
synopsis_ok($fh);
close $fh;

done_testing;
