package Test::Synopsis::Detail;
use 5.008005;
use strict;
use warnings;
use parent qw/Test::Builder::Module/;
use Compiler::Lexer;
use Test::More ();
use Test::Synopsis::Detail::Pod;

our $VERSION = "0.01";
our @EXPORT  = qw/synopsis_ok/;

sub synopsis_ok {
    my ($file) = @_;
    return _synopsis_ok(__PACKAGE__->builder, $file);
}

sub _synopsis_ok {
    my ($builder, $file) = @_;

    local $Test::Builder::Level = $Test::Builder::Level + 1;

    my $parser = Test::Synopsis::Detail::Pod->new;
    $parser->parse_file($file);

    my $lexer  = Compiler::Lexer->new({verbose => 1});
    my $tokens = $lexer->tokenize($parser->{target_code});
    my $expectations = _analyze_expectations($tokens);

    for my $expectation (@$expectations) {
        my $got      = eval $expectation->{code};     ## no critic
        my $expected = eval $expectation->{expected}; ## no critic

        my $method = $expectation->{method};
        if ($method eq 'is') {
            Test::More::is($got, $expected);
        }
    }
}

sub _analyze_expectations {
    my ($tokens) = @_;

    my $line = 0;
    my $code = '';    # target code for test
    my @expectations; # store expectations for test
    foreach my $token (@$tokens) {
        if ($token->{name} eq 'Comment') {
            # Not accept if it isn't on the same line as others
            next if $token->{line} > $line;

            # Accept special comment for this module
            # e.g.
            #     # => is 42
            my ($expectation) = $token->{data} =~ /#\s*=>\s*(.+)/;
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
        } else {
            $code .= "$token->{data} "; # Stack code without comment
            $line = $token->{line};
        }
    }

    return \@expectations;
}

1;
__END__

=encoding utf-8

=head1 NAME

Test::Synopsis::Detail - It's new $module

=head1 SYNOPSIS

    use Test::Synopsis::Detail;

=head1 DESCRIPTION

Test::Synopsis::Detail is ...

=head1 LICENSE

Copyright (C) moznion.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

moznion E<lt>moznion@gmail.comE<gt>

=cut

