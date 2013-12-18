#!perl

use strict;
use warnings;
use Test::Builder::Tester;
use Test::Synopsis::Expectation;

test_out('ok 1', 'not ok 2', 'ok 3', 'not ok 4');
synopsis_ok(*DATA);
test_test (name => 'testing used_modules_ok()', skip_err => 1);

done_testing;
__DATA__
=head1 NAME

fail - crazy!!

=head1 SYNOPSIS

    2; # => 1

Of course following is true!

    1; # => 2

=head1 AUTHOR

moznion E<lt>moznion@gmail.comE<gt>
