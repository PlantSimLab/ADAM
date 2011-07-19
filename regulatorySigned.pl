#!/usr/bin/perl

##Hussein Vastani##

die "Usage: regulatory.pl functionfile #nodes ip p_value" if ($#ARGV != 4);

#set path for graphviz for the server to use
$ENV{'PATH'}='/usr/local/bin:/bin:/etc:/usr/bin';                           
$ENV{'LD_LIBRARY_PATH'}='/usr/local/lib/graphviz';

$num_nodes = $ARGV[1];
$clientip = $ARGV[2];
$fileformat = $ARGV[3];
$p_value = $ARGV[4];

print "p_value is: $p_value";
#$sign = $ARGV[4];

open (INFILE,$ARGV[0]) or die("Failed to open input file");
$n = 1;
$found = 0;
$errString = "";
#print "Beginning error checking......\n";
$fcount = 1;
while(<INFILE>){
    $line = $_;
    #remove newline character
    chomp($line);
    #remove all spaces
    $line =~ s/\s*//g;
    #remove repetitions of equals
    $line =~ s/=+/=/g;
    $count = 0;
   # $count = $line =~ s/\*{2}/\^/g;
    #if the line begins with f or F
    if( (($line ne "")&&($line ne null)) && ($line =~ m/^f$fcount=/i) && (@functions  < $num_nodes))
    {
       $func = (split(/=/,$line))[1]; # just read the function
       if(length($func) == 0)
       {
         $errString =  "ERROR: Empty function no $fcount\n";
         $found = 1;
         last;
       }
       if($func =~ m/[^(x)(\d)(\()(\))(\+)(\-)(\*)(\^)]/g)
       {
         $errString =  "ERROR: Found unacceptable character(s) in line $n\n";
         $found = 1;
         last;
       }
       # check to see if there are equal number of opening and closing paranthesis
       if( tr/\(/\(/ != tr/\)/\)/ )
       {
         $errString = "ERROR: Missing paranthesis in line $n.\n";
         $found = 1;
         last;
       }
       #check to see if the index of x is acceptable
       $err = 0;
       while( $func =~ m/x(\d+)/g )
       {
         if( ($1 > $num_nodes) || ($1 < 1) )
         {
           $errString = "ERROR: Index of x out of range in line $n.\n ";
           $found = 1;
           $err = 1;
           last;
         }
       }
       #check to see if there was any error in the above while loop
       if($err == 1)
       {
		 $found = 1;
         last;
       }
       #Check to see if function is starting properly
       if($func =~ m/^[\)\*\^]/)
       {
         $errString = "ERROR: Incorrect syntax in line $n. Inappropriate char at start of function\n";
         $found = 1;
         last;
       }
       #Check to see if function is ending properly
       if($func =~ m/[^\)\d]$/)
       {
         $errString = "ERROR: Incorrect syntax in line $n. Inappropriate char at end of function\n";
         $found = 1;
         last;
       }
       #check to see if x always has an index
       if($func =~ m/x\D/g)
       {
         $errString = "ERROR: Incorrect syntax in line $n. Check x variable\n";
         $found = 1;
         last;
       }
       #check to see if ^ always has a number following
       if($func =~ m/\^\D/g)
       {
         $errString = "ERROR: Incorrect syntax in line $n. Check exponent value\n";
         $found = 1;
         last;
       }
       if( ($func =~ m/[\+\-\*\(][\)\+\-\*\^]/g) || ($func =~ m/\)[\(\d x]/g) || ($func =~ m/\d[\( x]/g) )
       {
         $errString = "ERROR: Incorrect syntax in line $n. Read the <a href=http://dvd.vbi.vt.edu/visualizer/tutorial.html target=_blank>tutorial</a> for correct formatting rules.\n";
         $found = 1;
         last;
       }
       if($found == 0)
       {
	   push(@functions2, $func);
	   print "func is: $func <br>";
		 $func =~ s/\^/\*\*/g; # replace carret with double stars
		 $func =~ s/x(\d+)/\$x\[$1\]/g; #for evaluation
        push(@functions, $func);
		 $fcount++;
       }
    }
    else
    {
		if(($line ne "")&&($line ne null))
		{
			$errString = "ERROR: Incorrect start of function declaration in line $n.\n";
			$found = 1;
			last;
		}
    }
    $n++;
}
#print "Format checking done\n";
if($found == 1)
{
  print "<br><font size=3>Errors found in the input functions. See below for description:</font>";
  print "<br>-----------------------------------------------------------------------<br>";
  print "<font color=red>".$errString."</font><br>";
  @functions = ();
  die("Errors with input file..ending program");
}
if(($fcount-1) < $num_nodes)
{
	print "<br><font size=3>Errors found in the input functions. See below for description:</font>";
    print "<br>-----------------------------------------------------------------------<br>";
	print "<font color=red>ERROR: Insufficient number of functions in the input provided. Check your number of nodes field</font><br>";
	@functions = ();
    die("Errors with input file..ending program");
}

if ($p_value == 2) {
    print "functions2 is: @functions2";
    $funcStr = join(",", @functions2);
    open (OUTDOT, ">$clientip.out1.dot") or die("failed to create out1.dot file");
    system("cd lib/M2code; M2 functionalCircuits.m2 --stop --no-debug --silent -q -e 'QR = makeRing($num_nodes, $p_value);
  F = matrix(QR, {{$funcStr}}); M = edgeSigns F; makeDepGraph(M, \"$clientip.out1.dot\"); exit 0'");
    close OUTDOT;
}

else {
open (OUTDOT,">$clientip.out1.dot") or die("failed to create out1.dot file");
print OUTDOT "digraph test {\n";

for($ind = 1; $ind <= scalar(@functions); $ind++)
{
   print OUTDOT "node$ind [label=\"x$ind\", shape=\"box\"];\n";
}
for($h = 1; $h <= scalar(@functions); $h++)
{
  $node = $functions[$h-1];
  @vars = ();
  while( $node =~ m/x\[(\d+)\]/g )
  {
     $vars[$1] = $1;
  }
  if(scalar(@vars > 0))
  {
     for($j = 0; $j < scalar(@vars); $j++)
     {
       if(defined($vars[$j]) )
       {
           $from = $vars[$j];
           print OUTDOT "node$from -> node$h;\n";
       }
     }
  }
}
print OUTDOT "}";
close(OUTDOT);

##make the graph
if(-e "$clientip.out1.dot")
{
  `dot -T$fileformat -o $clientip.out1.$fileformat $clientip.out1.dot`;
}
`#rm -f $clientip.out1.dot`;
