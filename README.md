[![Build Status](https://travis-ci.org/moznion/Test-Synopsis-Expectation.png?branch=master)](https://travis-ci.org/moznion/Test-Synopsis-Expectation) [![Coverage Status](https://coveralls.io/repos/moznion/Test-Synopsis-Expectation/badge.png?branch=master)](https://coveralls.io/r/moznion/Test-Synopsis-Expectation?branch=master)
# NAME

Test::Synopsis::Expectation - Test SYNOPSIS code with expectations

# SYNOPSIS

    use Test::Synopsis::Expectation;
    use Test::More;

    synopsis_ok('path/to/target.pm');
    done_testing;

    ### Following, SYNOPSIS of `target.pm`
    my $sum;
    $sum = 1; # => 1
    ++$sum;   # => is 2

    use Foo::Bar;
    my $instance = Foo::Bar->new; # => isa 'Foo::Bar'

    my $str = 'Hello, I love you'; # => like qr/ove/

    my $obj = {
        foo => ["bar", "baz"],
    }; # => is_deeply { foo => ["bar", "baz"] }

# DESCRIPTION

Test::Synopsis::Expectation is the test module to test the SYNOPSIS code with expectations.
This module can check the SYNOPSIS is valid syntax or not, and tests whether the result is suitable for expected.

# FUNCTIONS

- synopsis\_ok($files)

    This function tests SYNOPSIS codes of each files.
    This function expects file names as an argument as ARRAYREF or SCALAR.
    (This function is exported)

- all\_synopsis\_ok()

    This function tests SYNOPSIS codes of the all of library files.
    This function uses `MANIFEST` to list up the target files of testing.
    (This function is exported)

- prepare($code\_str)

    Register the executable codes to prepare for evaluation.

    If you use like;

        use Test::Synopsis::Expectation;
        use Test::More;
        Test::Synopsis::Expectation::prepare('my $foo = 1;');
        synopsis_ok('path/to/target.pm');
        done_testing;

        ### Following, SYNOPSIS of `target.pm`
        $foo; # => 1

    Then, SYNOPSIS of `target.pm` is the same as;

        my $foo = 1;
        $foo; # => 1

    (This function is not exported)

# NOTATION OF EXPECTATION

Comment that starts at `# =>` then this module treats the comment as test statement.

- \# => is

        my $foo = 1; # => is 1

    This way is equivalent to the next.

        my $foo = 1;
        is $foo, 1;

    This carries out the same behavior as `Test::More::is`.

- \# =>

        my $foo = 1; # => 1

    This notation is the same as `# => is`

- \# => isa

        use Foo::Bar;
        my $instance = Foo::Bar->new; # => isa 'Foo::Bar'

    This way is equivalent to the next.

        use Foo::Bar;
        my $instance = Foo::Bar->new;
        isa_ok $instance, 'Foo::Bar';

    This carries out the same behavior as `Test::More::isa_ok`.

- \# => like

        my $str = 'Hello, I love you'; # => like qr/ove/

    This way is equivalent to the next.

        my $str = 'Hello, I love you';
        like $str, qr/ove/;

    This carries out the same behavior as `Test::More::like`.

- \# => is\_deeply

        my $obj = {
            foo => ["bar", "baz"],
        }; # => is_deeply { foo => ["bar", "baz"] }

    This way is equivalent to the next.

        my $obj = {
            foo => ["bar", "baz"],
        };
        is_deeply $obj, { foo => ["bar", "baz"] };

    This carries out the same behavior as `Test::More::is_deeply`.

# NOTES

This module ignores yada-yada operators that is in SYNOPSIS code.
Thus, following code is valid.

    my $foo;
    ...
    $foo = 1; # => 1

It cannot put test case in for(each) statement.

    # Example of not working
    for (1..10) {
        my $foo = $_; # => 10
    }

This example doesn't work. On the contrary, it will be error.
(Probably nobody uses such as this way... I think.)

# LICENSE

Copyright (C) moznion.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

moznion <moznion@gmail.com>
