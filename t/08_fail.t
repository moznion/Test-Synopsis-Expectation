#!perl

use strict;
use warnings;
use FindBin;
use File::Spec::Functions qw/catfile/;

use Test::Builder::Tester;
use Test::Synopsis::Expectation;

my $target_file = catfile($FindBin::Bin, 'resources', 'fail.pod');
test_out('ok 1', 'not ok 2', 'ok 3', 'not ok 4');
synopsis_ok($target_file);
test_test (name => 'testing used_modules_ok()', skip_err => 1);

done_testing;
