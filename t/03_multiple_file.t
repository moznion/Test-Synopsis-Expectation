#!perl

use strict;
use warnings;
use FindBin;
use File::Spec::Functions qw/catfile/;

use Test::Synopsis::Detail;
use Test::More;

my $target_file = catfile($FindBin::Bin, 'resources', 'less.pod');
open my $fh, '<', $target_file;
synopsis_ok([$fh, $target_file]);
close $fh;

done_testing;
