#!usr/bin/perl
#author : Hussein Vastani
#This program takes an input file of functions and then evaluates it.
#it uses eval() to evaluate the functions

die "Usage: sim.pl functionfile prime #nodes initialization ip showGraph updateType updateValue" if ($#ARGV != 8);

#set path for graphviz for the server to use
$ENV{'PATH'}='/usr/local/bin:/bin:/etc:/usr/bin';                           
$ENV{'LD_LIBRARY_PATH'}='/usr/local/lib/graphviz';

$p_value = $ARGV[1];
$num_nodes = $ARGV[2];
$init = $ARGV[3];
$clientip = $ARGV[4];
$isgraph = $ARGV[5];
$updateType = $ARGV[6];
$updateValue = $ARGV[7];
$fileformat = $ARGV[8];

if($init eq "")
{
  print "<font color=red>Cannot accept empty input for initialization field </font><br>";
  die("Cannot accept empty input for initialization..Program quitting");
}
@x = ();
@functions = ();
@states = ();

open (INFILE,$ARGV[0]) or die("Failed to open input file");
$n = 1;
$found = 0;
$errString = "";
#print "Begining error checking......\n";
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

	$init =~ s/_/ /g;  #remove the underscores
    $line = $init;
	@y = split(/\s+/,$line);
	if( (scalar(@y) != $num_nodes)|| ($line =~ m/[^(\d)(\s*)]/g) )
	{
		print "<br><font color=red>Please check your initialization value.<br>";
		print "Make sure the states are separated by spaces and equal to the number of nodes</font><br>";
	    die("Program quitting..Error with initialization field");
	}
	$overrange = 0;
	for($h = 0; $h < scalar(@y); $h++)
	{
		if ($y[$h] >= $p_value) 
		{
			$overrange = 1;
			$y[$h] = $y[$h] % $p_value;
		}				
	}
    if($updateType eq "async")
	{
		if($updateValue ne "")
		{
			$updateValue =~ s/_/ /g;  #remove the underscores
			@prefArr = split(/\s+/,$updateValue);
			if( (scalar(@prefArr) != $num_nodes) || ($updateValue =~ m/[^(\d)(\s*)]/g) )
			{
				print "<br><font color=red>Please check your update schedule.<br>";
				print "Make sure the indices are non negative numbers separated by spaces and equal to the number of nodes</font><br>";
				die("Program quitting..Error with update schedule field");
			}
			if($prefArr[$h] > $num_nodes)
			{
				print "<br><font color=red>Please check your update schedule.<br>";
				print "Make sure the range of each index of the update schedule is between 1 and number of nodes</font><br>";
				die("Program quitting..Error with update schedule field");
			}
			for($i = 1; $i <= scalar(@functions); $i++)
			{
				push(@variables, "\$y[$i]");
			}
			for($curr = 0; $curr < scalar(@prefArr); $curr++)
			{
				$varToUpdate = $prefArr[$curr];#get the order number
				for($i = 1; $i <= scalar(@variables); $i++)
				{
					$j = $i - 1;
					$functions[$varToUpdate-1] =~ s/\$x\[$i\]/\($variables[$j]\)/g;
				}
				$variables[$varToUpdate-1] = $functions[$varToUpdate-1]; # get the function
				$functions[$varToUpdate-1] =~ s/y/x/g;  #replace ys back to x's
			}
		}
		else
		{
			print "<font color=red>Cannot accept null input for update schedule field</font><br>";
			die("Program quitting..Error with update schedule field");
		}
		if ($DEBUG) {
			print "After async update functions look like\n";
			print $_ foreach (@functions)
		}
	}
	
	if($overrange == 1)
	{
		print "The trajectory for<b> ". $init .  "</b> (which is @y) is</b><br>";
	}
	else
	{
		print "The trajectory for<b> ". $init .  "</b> is</b><br>";
	}
	# change the index of the array
	@x = (0,@y);
	$frominitial = 1;
	foreach (0..1000)
	{
	    $i = 1;
    	foreach $f(@functions)
    	{
       		$y[$i] = eval($f) % $p_value;
      		$i++;
    	}
    	# so now we have the next state stored in the array y. and initial state is still in array x
    	$nextsamestate = 1;
    	#compare the state and its next state (i.e compare x and y)
    	foreach $index(1..$num_nodes)
    	{
		    if ($x[$index] != $y[$index])
		    {
	     		$nextsamestate = 0;
	     	}
    	}
    	# if repeated is still 1, it means the states were same.
    	# so now check if the state was already in the list of previous states.
    	shift(@x);
    	$temp_string = join(' ',@x);
    	$found = 0;
    	$repeated = 0;
    	foreach(@states)
    	{
		    if ($_ eq $temp_string)
	     	{
           $repeated = 1;
			     $found = 1;
	     	}
    	}
    	# if the state did not repeat then print the state and push it on the list of previous states
    	if($found == 0)
     	{
    		push(@states,$temp_string);
		    print "$temp_string<br>";
     	}
     	else
      {
         	if( ($found == 1) && ($frominitial == 0) ) # state already occured and its not coming from initalization
         	{
	   		    print "$temp_string<br>";
         	}
     	}
    	# now make x to hold the next state
    	foreach $index(1..$num_nodes)
    	{
		    $x[$index] = $y[$index];
    	}

    	# if next coming state is the same..fixed point has been reached. make sure pair does not repeat
    	if( ($nextsamestate == 1) && ($found != 1) )
    	{
		    print "$temp_string<br>";
    		$repeated = 1;
    	}

    	if ($repeated == 1)
    	{
		    print "Repeated node found<br>";
        push(@states,$temp_string);
		    last;
    	}
    	# reset value of from initial
    	$frominitial = 0;
	}
if($isgraph eq "yes")
{
	$lastval = $states[$#states];
	$old = $states[0];
	$total_size = scalar($states);
	open (OUTFILE, ">$clientip.graph.dot") or die("Failed to open dot file in sim");
	print OUTFILE "digraph G{ \n";
	if($lastval eq $old)
	{
		 print OUTFILE "node[style=filled, color=cyan]\;\n";
		 $found = 1;
	}
	print OUTFILE "n" . hash($old) . " [label=\"$old\",shape=box]\;\n";
	$found = 0;

	for($h = 1; $h < scalar(@states); $h++)
	{
			$state = $states[$h];

		if( ($lastval eq $state)&&($found == 0) )
		{
			print OUTFILE "node[style=filled, color=cyan]\;\n";
		   $found = 1;
		}
		print OUTFILE "n" . hash($state) . " [label=\"$state\"]\;\n";
			print OUTFILE "n" . hash($old) . " [label=\"$old\"\];\n";
			print OUTFILE "n" . hash($old). " -> n" . hash($state) . ";\n";
			$old = $state;
		}

	print OUTFILE "}";
	print OUTFILE "}\n";
	close(OUTFILE);

	if($total_size <= 5000)
	{
           if(-e "$clientip.graph.dot")
	   {
	     `dot -T$fileformat -o $clientip.graph.$fileformat $clientip.graph.dot`;
	   }
	}
	else
	{
		print "<br><font color=red><i>Sorry. Unable to draw the trajectory with more than 1000 nodes.</i></font>"
	}
	`rm -f $clientip.graph.dot`;
}
sub hash
{
	@elems = split(/ /,$_[0]);
	$num_nodes = scalar(@elems);
	$dec_ans = 0;
	for ($j = 0 ; $j < $num_nodes; $j++){
		$dec_ans += $elems[$j]*$p_value**($num_nodes-$j-1);
	}
	@elems = ();
	return $dec_ans;
}
