#!/usr/bin/perl
use strict;
use warnings;
use diagnostics;

use Time::Piece;
use Time::Seconds;


use lib 'lib';
use Event;
use CalendarDay;
use LaTeXDocument;
use RoffDocument;


sub getArrayEventsFromNotes{
   
    my @events;

    my $file = 'notes.txt';
   
        open my $fh, '<', $file
        or die "Cant open file notes.txt";
        while(my $info = <$fh>){
            #removes new line from the line
            chomp($info);

            my($date, $desc) = split(/ /, $info, 2);

            push(@events, new Event($date, $desc));

        
        }
        #sort events by date 
        my @sortedEvents= sort {$a->{date}->strftime("%Y.%m.%d") cmp $b->{date}->strftime("%Y.%m.%d")} @events;

        return @sortedEvents;
  
    
}
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


#arguments (\dates, \events) passing arrays as a reference
sub getDatesAndEvents{
    my @dates = @{$_[0]};
    my @events = @{$_[1]};
  
    my $event = shift @events;
    my $date = shift @dates;

    my @calendarDays;

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

    return @calendarDays;

}

#users inputs
my $initialDate;
my $weekOrMonth;
my $numberOfTimeUnits;
#tex or tbl
my $strategy;
my $outputFileName;

print "Calendar generator\n";
print "Script creates calendar for certain number of weeks or months,\npopulates dates with notes form notes.txt\nand provides two output strategies: TeX or TBL\n";
print "Insert unit of time (month/week): ";
$weekOrMonth = <STDIN>;
#get rid of new line
chomp($weekOrMonth);

if($weekOrMonth ne "week" && $weekOrMonth ne "month"){
    print "Error: wrong input\n";
    exit;
}


print ("Insert number of $weekOrMonth", "s (int greater than 0): ");
    $numberOfTimeUnits = <STDIN>;
    chomp($numberOfTimeUnits);
#validate whether input is a positive number 
if($numberOfTimeUnits  !~ /^[0-9]+$/ || $numberOfTimeUnits<=0){
    print "Error: Input is not a valid number\n";
    exit;
}

eval{

    print "Insert initial date(yyyy.mm.dd): ";
    my $date = <STDIN>;
    chomp($date);
  

    $initialDate = Time::Piece->strptime($date, '%Y.%m.%d');

} or do{
    print "Error: wrong input\n";
    exit;
};
print $initialDate;
print "Insert strategy type (tex/tbl): ";
$strategy = <STDIN>;
#get rid of new line
chomp($strategy);

if($strategy ne "tex" && $strategy ne "tbl"){
    print "Error: wrong input\n";
    exit;
}
print "Insert output file name: ";
$outputFileName = <STDIN>;
#get rid of new line
chomp($outputFileName);



my @events = getArrayEventsFromNotes();
my @dates;
if($weekOrMonth eq "month"){
    @dates = getArrayOfDatesForMonths($initialDate->strftime('%Y.%m.%d'), $numberOfTimeUnits);
}else{
     @dates = getArrayOfDatesForWeeks($initialDate->strftime('%Y.%m.%d'), $numberOfTimeUnits);
}

my @calendarDaysArray= getDatesAndEvents(\@dates, \@events);



open(FH, '>', $outputFileName) or die $!;

if($strategy eq "tex"){
    print FH LaTeXDocument::getTeXDocument(\@calendarDaysArray);  
    close(FH);
    system("pdflatex $outputFileName");

}else{
    print FH RoffDocument::getTBLDocument(\@calendarDaysArray);  
    close(FH);
    system("tbl $outputFileName | groff -Tpdf > a.pdf");
}

print "Success\n";





