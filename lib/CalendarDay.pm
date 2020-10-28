package CalendarDay;

use strict;
use warnings;

use Time::Piece;

sub new{
    my $class = shift;
    my $self = {
        date => shift,
        events_desc => [@_],
    };

    bless $self, $class;
    return $self;
}
sub getDate {
    my ($self) = @_;
    return $self->{date};#->strftime("%Y.%m.%d");
}
sub getDateFormated {
    my ($self) = @_;
    return $self->{date}->strftime("%Y.%m.%d");
}
sub getEventsDesc {
  my( $self ) = @_;
  my @events = @{ $self->{ events_desc} };
  #
  #return wantarray ? @events : \@events;
  return @events;
}
sub setEventsDesc {
  my ( $self, @events_desc ) = @_;
  $self->{events_desc} = \@events_desc;
}

1;

