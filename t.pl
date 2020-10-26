use strict;
use warnings;
use diagnostics;

use Time::Piece;

use feature 'say';

use feature "switch";

use lib 'lib';
use Event;
use Time::Seconds;

=put
# The original date as a string
my $date_str = '2013.10.31';
# Parse the date string and create a Time::Piece object
my $date     = Time::Piece->strptime($date_str, '%Y.%m.%d');
# Create a new (improved!) date string using strftime()
my $new_date = $date->strftime('%Y.%m.%d');


print $date, "\n";
print $new_date;



my $a = new Event('2013.10.31', 'opis');

print $a->getDate();
my $date = Time::Piece->strptime('2013.10.31', '%Y.%m.%d');
if($a->getDate() == $date){
    print "jestem rowny\n";
}

=cut
sub getArrayEventsFromNotes{
    my @events;

    my $file = 'notatki';

    open my $fh, '<', $file
        or die "Cant open file :<";

    while(my $info = <$fh>){
        #removes new line from the line
        chomp($info);

        my($date, $desc) = split(/ /, $info, 2);

        push(@events, new Event($date, $desc));

        #print "Data: $date, opis: $desc\n";
    }

    my @sorted_events = sort {$a->{date}->strftime("%Y.%m.%d") cmp $b->{date}->strftime("%Y.%m.%d")} @events;

    return @sorted_events;
}
#print $events[0]->getDate();
=put
my @sorted_events = sort {$a->{date}->strftime("%Y.%m.%d") cmp $b->{date}->strftime("%Y.%m.%d")} @events;

foreach my $event (@events){
    print $event->getDate()->strftime("%Y.%m.%d");
    print "\n";
} 
print "\n";
foreach (@sorted_events){
    print $_->getDate()->strftime("%Y.%m.%d");
    print "\n";
}
=cut
=put
my @dates;
#print $events[0]->getDate();

#my $date = $events[0]->getDate() + ONE_DAY;
print "Insert begining date(yyyy.mm.dd): ";
my $date = <STDIN>;
my $xd = chomp($date);
#print "$date";
my $check = "2013.10.23";

my $date2 = Time::Piece->strptime($date, '%Y.%m.%d');
print "$date2\n";
printf "Day of the week %s \n", $date2->wdayname;
printf "Day of the week %d \n",$date2->_wday ;
print $date2->wdayname;
=cut
#arguments (initial date, weeks)
sub getArrayOfDates{
    my $initial_date = Time::Piece->strptime($_[0], '%Y.%m.%d');
    my $number_of_weeks = $_[1];
    my $current_date = $initial_date;
    my $number_of_days_in_a_week = 7;
    my @days;


    

    for(my $i = 0; $i < $number_of_weeks; $i++){
	    for(my $j = 0; $j < $number_of_days_in_a_week; $j++){
            push(@days, $current_date);
            $current_date += ONE_DAY;
            
        }
    }
=put
    for my $i (@days){
        print("$i \n");
    }
=cut
    return @days;

}
my @events = getArrayEventsFromNotes();
my @dates = getArrayOfDates("2013.02.07", 2);

#arguments (\dates, \events) passing arrays as a reference
sub datesAndEvents{
    my @dates = @{$_[0]};
    my @events = @{$_[1]};
  
    my $event = shift @events;
    my $date = shift @dates;

    while($date && $event){
        #print("event: ",$event->getDate(), "\n");
        #print("date: ",$date, "\n");
        if($date == $event->getDate()){
            #print("match\n");
            print($date, " ", $event->getDescription(), "\n");
            $event = shift @events;
        }elsif($date > $event->getDate()){
            $event = shift @events;
        }else{
            print($date, "\n");
            $date = shift @dates;
        }
        
    }
    while($date){
        print($date, "\n");
        $date = shift @dates;
    }

}

#print("@dates \n");
#passing arrays as a reference
datesAndEvents(\@dates, \@events);
