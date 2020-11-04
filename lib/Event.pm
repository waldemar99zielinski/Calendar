package Event;

use strict;
use warnings;

use Time::Piece;

sub new{
    my $class = shift;
    my $self = {
        date => Time::Piece->strptime(shift, '%Y.%m.%d'),
        description => shift
    };

    bless $self, $class;
    return $self;
}
sub getDate {
    my ($self) = @_;
    return $self->{date};
}
sub getDateFormated {
    my ($self) = @_;
    return $self->{date}->strftime("%Y.%m.%d");
}
sub getDescription {
    my ($self) = @_;
    return $self->{description};
}

1;

