package Test::Synopsis::Detail::Pod;
use strict;
use parent qw/Pod::Simple::Methody/;

sub new {
    my $class  = shift;
    my $parser = $class->SUPER::new(@_);

    # Accept `test-synopsis-detail` format at formatter (=begin, =end, =for)
    $parser->accept_targets(qw/test-synopsis-detail/);

    # NOTE I think not good way...
    $parser->{in_head1}    = 0;
    $parser->{in_synopsis} = 0;
    $parser->{in_verbatim} = 0;
    $parser->{in_test}     = 0;

    $parser->{target_code} = '';
    $parser->{expected}    = '';

    return $parser;
}

sub handle_text {
    my($self, $text) = @_;
    if ($self->{in_head1} && $text =~ /^synopsis$/i) {
        $self->{in_synopsis} = 1;
    }

    # Target codes (that is synopsis code)
    if ($self->{in_synopsis} && $self->{in_verbatim}) {
        $self->{target_code} = $text;
    }

    # Extract expected value
    if ($self->{in_synopsis} && $self->{in_test}) {
        $self->{expected} = $text;
    }
}

sub start_head1 {
    my($self, $attrs) = @_;

    $self->{in_head1}    = 1;
    $self->{in_synopsis} = 0;
}

sub end_head1 {
    my($self) = @_;

    $self->{in_head1} = 0;
}

sub start_Verbatim {
    my($self, $attrs) = @_;

    $self->{in_verbatim} = 1;
}

sub end_Verbatim {
    my($self) = @_;

    $self->{in_verbatim} = 0;
}

# For `$self->{in_test}`.
# Only `=for` that is labeled `test-synopsis-detail` comes here.
sub start_for {
    my($self, $attrs) = @_;

    $self->{in_test} = 1;
}

sub end_for {
    my($self) = @_;

    $self->{in_test} = 0;
}
1;
