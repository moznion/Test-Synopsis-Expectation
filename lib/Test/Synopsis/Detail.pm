package Test::Synopsis::Detail;
use 5.008005;
use strict;
use warnings;
use parent qw/Test::Builder::Module/;
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

    my $got      = eval $parser->{target_code}; ## no critic
    my $expected = eval $parser->{expected}; ## no critic

    $builder->is_eq($got, $expected);
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

