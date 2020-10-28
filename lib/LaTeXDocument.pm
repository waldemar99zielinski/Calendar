use strict;
use warnings;
use diagnostics;

use Event;
use CalendarDay;
use Time::Seconds;

use Exporter;

our @ISA= qw( Exporter );


our @EXPORT_OK = qw( getTeXDocument );

our @EXPORT = qw( getTeXDocument );

#arguments ($dayOfTheMonth, @events)
sub getTeXDay{
    my $dayOfTheMonth = $_[0];
    my @events = @{$_[1]};

    #TeX formated day
    my $day;
    #add date
    $day = "{\\large $dayOfTheMonth}";
    #add events
    foreach my $event (@events){
        my $eventDesc = "\\newline {\\small -$event}";
        $day = $day.$eventDesc;
    }
    return $day;
}


#arguments(@caledarDaysArray), should contain dates for only one month
sub getTable{
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
            $week = $week.getTeXDay($day->getDate()->mday, \@descArray);
            $week = $week."&";
            #print ("week: ",$currentDayOfTheWeek, " ", $week, "\n");
            $currentDayOfTheWeek++;
            
        }else{
            
            my @descArray = $day->getEventsDesc();
            $week = $week.getTeXDay($day->getDate()->mday, \@descArray);
            $week = $week."\\\\ \\hline \n";
            #print ("endweek: ",$currentDayOfTheWeek, " ", $week, "\n");
            $currentDayOfTheWeek = 0;
        }
    }
    if($currentDayOfTheWeek != 0){
        while($currentDayOfTheWeek<6){
            $week = $week.$empytDay;
            $currentDayOfTheWeek++;
        }    
        $week = $week."\\\\ \\hline \n";
    }
    
    
    
    my $table = "\\begin{table}[t]
\\centering
    
\\renewcommand{\\arraystretch}{1.5}
\\begin{tabular}{|p{1.7cm}|p{1.7cm}|p{1.7cm}|p{1.7cm}|p{1.7cm}|p{1.7cm}|p{1.7cm}|} 
\\hline
\\multicolumn{7}{|c|}{$month}\\\\
\\hline
Sun & Mon & Tue & Wed & Thu & Fri & Sat\\\\ 
\\hline\\hline
    
$week
\\end{tabular}
\\end{table} 
";
    return $table;
}

#arguments(@cacaledarDaysArray)
sub getTeXDocument{
    my @caledarDaysArray = @{$_[0]};
    my $tables = "";
    my $currentMonth = $caledarDaysArray[0]->getDate()->mon;

    my @calendarDaysForOneMonth;

    foreach my $day(@caledarDaysArray){
     
        if($currentMonth == $day->getDate()->mon){
            push(@calendarDaysForOneMonth, $day);
         
            #print($day->getDate(), "\n");
        }else{
            $tables = $tables.getTable(\@calendarDaysForOneMonth);
            @calendarDaysForOneMonth = ();
            push(@calendarDaysForOneMonth, $day);
            $currentMonth = $day->getDate()->mon;
            #print($day->getDate(), "\n");
        }
       
       
    } 

    $tables = $tables.getTable(\@calendarDaysForOneMonth);

    
    my $document = "\\documentclass{article}
\\usepackage[utf8]{inputenc}
\\usepackage{array}
\\usepackage[a4paper, total={6in, 8in}]{geometry}
\\title{Calendar}
\\begin{document}

$tables

\\end{document}
";

    return $document;
}

1;