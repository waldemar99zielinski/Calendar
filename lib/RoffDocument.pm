package RoffDocument;

use strict;
use warnings;

use Time::Piece;

use Event;
use CalendarDay;
use Time::Seconds;

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
        
        $currentDayOfTheWeek++;
        
    }

    foreach my $day(@caledarDaysArray){
        
        if($currentDayOfTheWeek<6){
          
            my @descArray = $day->getEventsDesc();
            $week = $week.getTBLDay($day->getDate()->mday, \@descArray);
            $week = $week."&";
        
            $currentDayOfTheWeek++;
            
        }else{#end table line
            
            my @descArray = $day->getEventsDesc();
            $week = $week.getTBLDay($day->getDate()->mday, \@descArray);
            $week = $week."\n";
          
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
    my $tables = "\n";
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

1;