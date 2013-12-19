package Test::Synopsis::Expectation;
use 5.008005;
use strict;
use warnings;
use parent qw/Test::Builder::Module/;

my @test_more_exports;
BEGIN { @test_more_exports = (qw/done_testing/) }
use PPI::Tokenizer;
use ExtUtils::Manifest qw/maniread/;
use Test::More import => \@test_more_exports;
use Test::Synopsis::Expectation::Pod;

our $VERSION = "0.03";
our @EXPORT  = (@test_more_exports, qw/all_synopsis_ok synopsis_ok/);

my $prepared = '';

sub prepare {
    $prepared = shift;
}

sub all_synopsis_ok {
    my $builder = __PACKAGE__->builder;
    my @files   = _list_up_files_from_manifest($builder);
    for my $file (@files) {
        _synopsis_ok($file);
    }
}

sub synopsis_ok {
    my ($files) = @_;

    $files = [$files] if ref $files ne 'ARRAY';
    for my $file (@$files) {
        _synopsis_ok($file);
    }
}

sub _synopsis_ok {
    my ($file) = @_;

    local $Test::Builder::Level = $Test::Builder::Level + 1;

    my $parser = Test::Synopsis::Expectation::Pod->new;
    $parser->parse_file($file);

    for my $target_code (@{$parser->{target_codes}}) {
        my ($expectations, $code) = _analyze_target_code($target_code);

        _check_syntax($code);
        for my $expectation (@$expectations) {
            _check_with_expectation($expectation);
        }
    }
}

sub _check_syntax {
    package Test::Synopsis::Expectation::Sandbox;
    eval $_[0]; ## no critic
    if ($@) {
        Test::More::fail;
    }
    else {
        Test::More::pass;
    }
}

sub _check_with_expectation {
    package Test::Synopsis::Expectation::Sandbox;

    # $_[0] is expectation
    my $got      = eval $_[0]->{code};     ## no critic
    my $expected = eval $_[0]->{expected}; ## no critic
    my $method   = $_[0]->{method};

    if ($method eq 'is') {
        Test::More::is($got, $expected);
    } elsif ($method eq 'isa') {
        Test::More::isa_ok($got, $expected);
    } elsif ($method eq 'like') {
        Test::More::like($got, $expected);
    } elsif ($method eq 'is_deeply') {
        Test::More::is_deeply($got, $expected);
    }
}

sub _analyze_target_code {
    my ($target_code) = @_;

    my $deficient_brace = 0;
    my $code = $prepared || ''; # code for test
    my @expectations; # store expectations for test
    for my $line (split /\n\r?/, $target_code) {
        my $tokens = PPI::Tokenizer->new(\$line)->all_tokens;

        if (grep {$_->{content} eq '...' && $_->isa('PPI::Token::Operator')} @$tokens) {
            next;
        }
        $code .= "$line\n";

        # Count the number of left braces to complete deficient right braces
        $deficient_brace++ if (grep {$_->{content} eq '{' && $_->isa('PPI::Token::Structure')}  @$tokens);
        $deficient_brace-- if (grep {$_->{content} eq '}' && $_->isa('PPI::Token::Structure')}  @$tokens);

        # Extract comment statement
        # Tokens contain one comment token on a line, at the most
        if (my ($comment) = grep {$_->isa('PPI::Token::Comment')} @$tokens) {
            # Accept special comment for this module
            # e.g.
            #     # => is 42
            my ($expectation) = $comment->{content} =~ /#\s*=>\s*(.+)/;
            next unless $expectation;

            # Accept test methods as string
            my $method;
            if ($expectation =~ s/^(is|isa|is_deeply|like)\s// && $1) {
                $method = $1;
            }

            push @expectations, +{
                'method'   => $method || 'is',
                'expected' => $expectation,
                'code'     => $code . ('}' x $deficient_brace),
            };
        }
    }

    return (\@expectations, $code);
}

sub _list_up_files_from_manifest {
    my ($builder) = @_;

    my $manifest = $ExtUtils::Manifest::MANIFEST;
    if ( not -f $manifest ) {
        $builder->plan( skip_all => "$manifest doesn't exist" );
    }
    return grep { m!\Alib/.*\.pm\Z! } keys %{ maniread() };
}
1;
__END__

=encoding utf-8

=for stopwords isa yada-yada

=head1 NAME

Test::Synopsis::Expectation - Test SYNOPSIS code with expectations

=head1 SYNOPSIS

    use Test::Synopsis::Expectation;

    synopsis_ok('path/to/target.pm');
    done_testing;

Following, SYNOPSIS of `target.pm`

    my $num;
    $num = 1; # => 1
    ++$num;   # => is 2

    use Foo::Bar;
    my $instance = Foo::Bar->new; # => isa 'Foo::Bar'

    my $str = 'Hello, I love you'; # => like qr/ove/

    my $obj = {
        foo => ["bar", "baz"],
    }; # => is_deeply { foo => ["bar", "baz"] }

=head1 DESCRIPTION

Test::Synopsis::Expectation is the test module to test the SYNOPSIS code with expectations.
This module can check the SYNOPSIS is valid syntax or not, and tests whether the result is suitable for expected.

=head1 FUNCTIONS

=over 4

=item * synopsis_ok($files)

This function tests SYNOPSIS codes of each files.
This function expects file names as an argument as ARRAYREF or SCALAR.
(This function is exported)

=item * all_synopsis_ok()

This function tests SYNOPSIS codes of the all of library files.
This function uses F<MANIFEST> to list up the target files of testing.
(This function is exported)

=item * prepare($code_str)

Register the executable codes to prepare for evaluation.

If you use like;

    use Test::Synopsis::Expectation;
    use Test::More;
    Test::Synopsis::Expectation::prepare('my $foo = 1;');
    synopsis_ok('path/to/target.pm');
    done_testing;

    ### Following, SYNOPSIS of `target.pm`
    $foo; # => 1

Then, SYNOPSIS of F<target.pm> is the same as;

    my $foo = 1;
    $foo; # => 1

(This function is not exported)

=back

=head1 NOTATION OF EXPECTATION

Comment that starts at C<# =E<gt>> then this module treats the comment as test statement.

=over 4

=item * # => is

    my $foo = 1; # => is 1

This way is equivalent to the next.

    my $foo = 1;
    is $foo, 1;

This carries out the same behavior as C<Test::More::is>.

=item * # =>

    my $foo = 1; # => 1

This notation is the same as C<# =E<gt> is>

=item * # => isa

    use Foo::Bar;
    my $instance = Foo::Bar->new; # => isa 'Foo::Bar'

This way is equivalent to the next.

    use Foo::Bar;
    my $instance = Foo::Bar->new;
    isa_ok $instance, 'Foo::Bar';

This carries out the same behavior as C<Test::More::isa_ok>.

=item * # => like

    my $str = 'Hello, I love you'; # => like qr/ove/

This way is equivalent to the next.

    my $str = 'Hello, I love you';
    like $str, qr/ove/;

This carries out the same behavior as C<Test::More::like>.

=item * # => is_deeply

    my $obj = {
        foo => ["bar", "baz"],
    }; # => is_deeply { foo => ["bar", "baz"] }

This way is equivalent to the next.

    my $obj = {
        foo => ["bar", "baz"],
    };
    is_deeply $obj, { foo => ["bar", "baz"] };

This carries out the same behavior as C<Test::More::is_deeply>.

=back

=head1 RESTRICTION

=head2 Test case must be one line

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

=head2 Not put test cases inside of for(each)

    # Example of not working
    for (1..10) {
        my $foo = $_; # => 10
    }

This example doesn't work. On the contrary, it will be error (Probably nobody uses such as this way... I think).

=head1 NOTES

=head2 yada-yada operator

This module ignores yada-yada operators that is in SYNOPSIS code.
Thus, following code is runnable.

    my $foo;
    ...
    $foo = 1; # => 1

=head1 LICENSE

Copyright (C) moznion.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

moznion E<lt>moznion@gmail.comE<gt>

=cut

