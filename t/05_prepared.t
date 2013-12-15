#!perl

use strict;
use warnings;
use FindBin;
use File::Spec::Functions qw/catfile/;

use Test::Synopsis::Detail;
use Test::More;

Test::Synopsis::Detail::prepare('my $foo = 1;');
my $target_file = catfile($FindBin::Bin, 'resources', 'prepared.pod');
synopsis_ok($target_file);

done_testing;
