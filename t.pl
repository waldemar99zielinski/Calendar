#!/usr/bin/perl
use strict;
use warnings;
use diagnostics;

use Time::Piece;
use Time::Seconds;
use feature 'say';

use feature "switch";

use lib 'lib';
use Event;
use CalendarDay;
use LaTeXDocument;


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
    #sort events by date 
    my @sorted_events = sort {$a->{date}->strftime("%Y.%m.%d") cmp $b->{date}->strftime("%Y.%m.%d")} @events;

    return @sorted_events;
}

=put
my @dates;
#print $events[0]->getDate();

#my $date = $events[0]->getDate() + ONE_DAY;
print "Insert begining date(yyyy.mm.dd): ";
my $date = <STDIN>;
chomp($date);
#print "$date";
my $check = "2013.10.23";

my $date2 = Time::Piece->strptime($date, '%Y.%m.%d');
print "$date2\n";
printf "Day of the week %s \n", $date2->wdayname;
printf "Day of the week %d \n",$date2->_wday ;
print $date2->wdayname;
=cut
#arguments (initial date, weeks)
sub getArrayOfDatesForWeeks{
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
sub getArrayOfDatesForMonths{
    my $initial_date = Time::Piece->strptime($_[0], '%Y.%m.%d');
    my $numberOfMonths = $_[1];

    my $month = $initial_date->mon;
    my $year = $initial_date->year;

    my $firstDayOfTheMonth = Time::Piece->strptime("".$year.".".$month."."."01", '%Y.%m.%d');

    my $currentDate = $firstDayOfTheMonth;
   
    my @days;
   
    my $monthsCounter = 0;
    while($monthsCounter<$numberOfMonths){
        push(@days, $currentDate);
        my $nextDate = $currentDate + ONE_DAY;
      
        if($currentDate->mon != $nextDate->mon){
            $monthsCounter++;
        }
        $currentDate = $nextDate;
    }
   
    return @days;

}

my @events = getArrayEventsFromNotes();
#my @dates = getArrayOfDates("2013.02.07", 6);
my @dates = getArrayOfDatesForMonths("2020.10.15", 3);
my @calendarDays;

#arguments (\dates, \events) passing arrays as a reference
sub datesAndEvents{
    my @dates = @{$_[0]};
    my @events = @{$_[1]};
  
    my $event = shift @events;
    my $date = shift @dates;

    my $singleCalendarDate = new CalendarDay($date);

    while($date && $event){
        

        if($date == $event->getDate()){
            #print("match\n");
            #print($date, " ", $event->getDescription(), "\n");
            
            #add desc event to calendar day
            my @descArray = $singleCalendarDate->getEventsDesc();
            push(@descArray, $event->getDescription());
            $singleCalendarDate->setEventsDesc(@descArray);

            $event = shift @events;
        }elsif($date > $event->getDate()){
            $event = shift @events;
        }else{
            #print($date, "\n");

            push(@calendarDays, $singleCalendarDate);

            $date = shift @dates;
            $singleCalendarDate = new CalendarDay($date);
        }
        
    }
    while($date){
        #print($date, "\n");
        
        push(@calendarDays, $singleCalendarDate);

        $date = shift @dates;
        $singleCalendarDate = new CalendarDay($date);
    }

}

#print("@dates \n");
#passing arrays as a reference
datesAndEvents(\@dates, \@events);
=put
foreach my $day (@calendarDays){
    print $day->getDate()->strftime("%Y.%m.%d");
 

    foreach my $path ($day->getEventsDesc ) {
        print $path, " | ";
    }
       print "\n";
} 
=cut
=put
open(FH, '>', "cal.tex") or die $!;

print FH getTeXDocument(\@calendarDays);

close(FH);
#print(getTeXDocument(\@calendarDays));
=cut

sub getTBLDay{
    my $dayOfTheMonth = $_[0];
    my @events = @{$_[1]};
    my $eventsText = "";
    #TeX formated day

    #add date
    
    #add events
    foreach my $event (@events){
   
        $eventsText = $eventsText."\n\n-$event"; 
    }
        my $day=
"T{
$dayOfTheMonth $eventsText
T}";
    return $day;
}
#my @a = ("XD", "dwa bardzo dlugie informacje");
#print(getTBLDay(1, \@a));

#arguments(@caledarDaysArray), should contain dates for only one month
sub getTBLTable{
    my @caledarDaysArray = @{$_[0]};
    my $month = $caledarDaysArray[0]->getDate()->fullmonth." ".$caledarDaysArray[0]->getDate()->year;
    my $week = "";
    my $empytDay = " &";
    my $currentDayOfTheWeek = 0;
    #align first date 
    my $dayOfTheWeekForTheFirstDay = $caledarDaysArray[0]->getDate()->_wday;
    for(my $i = 0; $i<$dayOfTheWeekForTheFirstDay; $i++){
     
        $week = $week.$empytDay;
        #print ("alignment: ",$currentDayOfTheWeek, " ", $week, "\n");
        $currentDayOfTheWeek++;
        
    }

    foreach my $day(@caledarDaysArray){
        
        if($currentDayOfTheWeek<6){
          
            my @descArray = $day->getEventsDesc();
            $week = $week.getTBLDay($day->getDate()->mday, \@descArray);
            $week = $week."&";
            #print ("week: ",$currentDayOfTheWeek, " ", $week, "\n");
            $currentDayOfTheWeek++;
            
        }else{#end table line
            
            my @descArray = $day->getEventsDesc();
            $week = $week.getTBLDay($day->getDate()->mday, \@descArray);
            $week = $week."\n";
            #print ("endweek: ",$currentDayOfTheWeek, " ", $week, "\n");
            $currentDayOfTheWeek = 0;
        }
    }
    
    if($currentDayOfTheWeek != 0){
        #pupulate table with empy cells
        while($currentDayOfTheWeek<6){
            $week = $week.$empytDay;
            $currentDayOfTheWeek++;
        }    
       
    }else{
        #delete last new line
        $week = substr($week, 0, (length $week)-1);
    }
    
    
    
    my $table = 
".TS
center allbox tab(&);
cB s s s s s s
cw(0.7i)B cw(0.7i)B cw(0.7i)B cw(0.7i)B cw(0.7i)B cw(0.7i)B cw(0.7i)B
lw(0.7i) lw(0.7i) lw(0.7i) lw(0.7i) lw(0.7i) lw(0.7i) lw(0.7i).
$month
Sun & Mon & Tue & Wed & Thu & Fri & Sat
$week
.TE
";
    return $table;
}
#arguments(@cacaledarDaysArray)
sub getTBLDocument{
    my @caledarDaysArray = @{$_[0]};
    my $tables = "";
    my $currentMonth = $caledarDaysArray[0]->getDate()->mon;

    my @calendarDaysForOneMonth;

    foreach my $day(@caledarDaysArray){
     
        if($currentMonth == $day->getDate()->mon){
            push(@calendarDaysForOneMonth, $day);
         
            #print($day->getDate(), "\n");
        }else{
            #
            $tables = $tables.getTBLTable(\@calendarDaysForOneMonth)."\n";
            @calendarDaysForOneMonth = ();
            push(@calendarDaysForOneMonth, $day);
            $currentMonth = $day->getDate()->mon;
            #print($day->getDate(), "\n");
        }
       
       
    } 

    $tables = $tables.getTBLTable(\@calendarDaysForOneMonth);

    
   
    return $tables;
}
open(FH, '>', "test.roff") or die $!;

print FH getTBLDocument(\@calendarDays);

close(FH);