package Test::Synopsis::Expectation;
use 5.008005;
use strict;
use warnings;
use parent qw/Test::Builder::Module/;
use Compiler::Lexer;
use ExtUtils::Manifest qw/maniread/;
use Test::More ();
use Test::Synopsis::Expectation::Pod;

our $VERSION = "0.01";
our @EXPORT  = qw/all_synopsis_ok synopsis_ok/;

my $prepared = '';

sub prepare {
    $prepared = shift;
}

sub all_synopsis_ok {
    my $builder = __PACKAGE__->builder;
    my @files   = _list_up_files_from_manifest($builder);
    for my $file (@files) {
        _synopsis_ok(__PACKAGE__->builder, $file);
    }
}

sub synopsis_ok {
    my ($files) = @_;

    $files = [$files] if ref $files ne 'ARRAY';
    for my $file (@$files) {
        _synopsis_ok(__PACKAGE__->builder, $file);
    }
}

sub _synopsis_ok {
    my ($builder, $file) = @_;

    local $Test::Builder::Level = $Test::Builder::Level + 1;

    my $parser = Test::Synopsis::Expectation::Pod->new;
    $parser->parse_file($file);

    my $expectations = _analyze_expectations($parser->{target_code});

    for my $expectation (@$expectations) {
        my $got      = eval $expectation->{code};     ## no critic
        my $expected = eval $expectation->{expected}; ## no critic
        my $method   = $expectation->{method};

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
}

sub _analyze_expectations {
    my ($target_code) = @_;

    my $lexer = Compiler::Lexer->new({verbose => 1});

    my $code = $prepared || ''; # code for test
    my @expectations; # store expectations for test
    foreach my $line (split /\n\r?/, $target_code) {
        my $tokens = $lexer->tokenize($line);
        next if (grep {$_->{name} eq 'ToDo'} @$tokens); # Ignore yada-yada operator
        $code .= "$line\n";

        # Extract comment statement
        # Tokens contain one comment token on a line, at the most
        if (my ($comment) = grep {$_->{name} eq 'Comment'} @$tokens) {
            # Accept special comment for this module
            # e.g.
            #     # => is 42
            my ($expectation) = $comment->{data} =~ /#\s*=>\s*(.+)/;
            next unless $expectation;

            # Accept test methods as string
            my $method;
            if ($expectation =~ s/^(is|isa|is_deeply|like)\s// && $1) {
                $method = $1;
            }

            push @expectations, +{
                'method'   => $method || 'is',
                'expected' => $expectation,
                'code'     => $code,
            };
        }
    }

    return \@expectations;
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

=head1 NAME

Test::Synopsis::Expectation - It's new $module

=head1 SYNOPSIS

    use Test::Synopsis::Expectation;
    my $sum = 1; # => 1

=head1 DESCRIPTION

Test::Synopsis::Expectation is ...

=head1 LICENSE

Copyright (C) moznion.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

moznion E<lt>moznion@gmail.comE<gt>

=cut

