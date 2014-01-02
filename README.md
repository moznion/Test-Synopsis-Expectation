[![Build Status](https://travis-ci.org/moznion/Test-Synopsis-Expectation.png?branch=master)](https://travis-ci.org/moznion/Test-Synopsis-Expectation) [![Coverage Status](https://coveralls.io/repos/moznion/Test-Synopsis-Expectation/badge.png?branch=master)](https://coveralls.io/r/moznion/Test-Synopsis-Expectation?branch=master)
# NAME

Test::Synopsis::Expectation - Test SYNOPSIS code with expectations

# SYNOPSIS

    use Test::Synopsis::Expectation;

    synopsis_ok('eg/sample.pod');
    done_testing;

Following, SYNOPSIS of `eg/sample.pod`

    my $num;
    $num = 1; # => 1
    ++$num;   # => is 2

    use PPI::Tokenizer;
    my $tokenizer = PPI::Tokenizer->new(\'code'); # => isa 'PPI::Tokenizer'

    my $str = 'Hello, I love you'; # => like qr/ove/

    my $obj = {
        foo => ["bar", "baz"],
    }; # => is_deeply { foo => ["bar", "baz"] }

    my $bool = 1; # => success

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
        Test::Synopsis::Expectation::prepare('my $foo = 1;');
        synopsis_ok('path/to/target.pm');
        done_testing;

        ### Following, SYNOPSIS of `target.pm`
        $foo; # => 1

    Then, SYNOPSIS of `target.pm` is the same as;

        my $foo = 1;
        $foo; # => 1

    (This function is not exported)

- set\_ignorings

    Set the procedures which would like to ignore.

        use Test::Synopsis::Expectation;
        Test::Synopsis::Expectation::set_ignorings(['++$num;']);
        synopsis_ok(*DATA);
        done_testing;

        __DATA__
        =head1 SYNOPSIS

            my $num;
            $num = 1; # => 1
            ++$num;
            $num; # => 1

    In the above example, `++$num;` will be ignored.

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

- \# => success

        my $bool = 1;
        $bool; # => success

    This way checks value as boolean.
    If target value of testing is 0 then this test will fail. Otherwise, it will pass.

# ANNOTATIONS

- =for test\_synopsis\_expectation\_no\_test

    The code block behind this annotation will not be tested.

            my $sum;
            $sum = 1; # => 1

        =for test_synopsis_expectation_no_test

            my $sum;
            $sum = 1; # => 2

    In this example, the first code block will be tested, but the second will not.

# RESTRICTION

## Test case must be one line

The following is valid;

    my $obj = {
        foo => ["bar", "baz"],
    }; # => is_deeply { foo => ["bar", "baz"] }

However, the following is invalid;

    my $obj = {
        foo => ["bar", "baz"],
    }; # => is_deeply {
       #        foo => ["bar", "baz"]
       #    }

So test case must be one line.

## Not put test cases inside of for(each)

    # Example of not working
    for (1..10) {
        my $foo = $_; # => 10
    }

This example doesn't work. On the contrary, it will be error (Probably nobody uses such as this way... I think).

# NOTES

## yada-yada operator

This module ignores yada-yada operators that is in SYNOPSIS code.
Thus, following code is runnable.

    my $foo;
    ...
    $foo = 1; # => 1

# LICENSE

Copyright (C) moznion.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

moznion <moznion@gmail.com>
