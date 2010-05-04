#!/usr/bin/perl
#
# using the output file from Macaulay, we graph
# the state space and compute connected components and fixed points
#
# This requires you to have dot, gc, sccmap, ccomps in your path!!!
#
# usage: perl count-comps.pl functionfile prime #nodes
#
# Nick Eriksson
# Hussein Vastani
################################################################

use Getopt::Std;
use Cwd;
getopts('vph');

#set non-zero to get too much information
$DEBUG=$opt_v;
#$DEBUG=1;

#set non-zero to output and open a postscript view of the statespace
#this can be very slow!
$PICTURE=$opt_p;


die "Usage: count-comps.pl [-vph] functionfile prime #nodes ip updateType updateValue \n\t-v  verbose \n\t-p  output and open postscript picture\n\t-h  this help\n" if ($opt_h || $#ARGV != 6);

#set path for graphviz for the server to use
$ENV{'PATH'}='/usr/local/bin:/bin:/etc:/usr/bin';
$ENV{'LD_LIBRARY_PATH'}='/usr/local/lib/graphviz';

#get the clients ip address
$clientip = $ARGV[3];
#print "Content-type: text/plain\n\n";
#foreach $var (sort(keys(%ENV))) {
 #   $val = $ENV{$var};
 #   $val =~ s|\n|\\n|g;
 #   $val =~ s|"|\\"|g;
 #   print "${var}=\"${val}\"<br>";
#}

#check that GraphViz is accessible...

$is_dot = 0;
@path = split (/:/,  $ENV{'PATH'});
foreach $s (@path){
    if (-e "$s/dot")
    {
	$is_dot = 1;
	print "graphviz found in $s \n" if ($DEBUG);
    }
}

die "You must have the GraphViz programs (gc, sccmap, ccomps, dot) in your path.\n" if (! $is_dot);

$p_value = $ARGV[1];
$num_nodes = $ARGV[2];

$updateType = $ARGV[4];
$updateValue = $ARGV[5];
$fileformat = $ARGV[6];
$found = 0; #to keep track if any error occured
$errString = ""; # to save the error string to be printed on screen

if( (-r $ARGV[0]) && (-T $ARGV[0]) && (-s $ARGV[0]) )
{
   open (INFILE,$ARGV[0]) or die("Failed to open input file");
}
else
{
   $errString = "File uploaded is not readable or is not a plain text file. Please check your file and try again";
   $found = 1;
}
if($found == 0)
{
	$n = 1;
	$fcount = 1;
	while(<INFILE>)
	{
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
				$errString =  "ERROR: Empty function no $fcount";
				$found = 1;
				last;
			}
			if($func =~ m/[^(x)(\d)(\()(\))(\+)(\-)(\*)(\^)]/g)
			{
				$errString =  "ERROR: Found unacceptable character(s) in line $n";
				$found = 1;
				last;
			}
			# check to see if there are equal number of opening and closing paranthesis
			if( tr/\(/\(/ != tr/\)/\)/ )
			{
				$errString = "ERROR: Missing paranthesis in line $n.";
				$found = 1;
				last;
			}
			#check to see if the index of x is acceptable
			$err = 0;
			while( $func =~ m/x(\d+)/g )
			{
				if( ($1 > $num_nodes) || ($1 < 1) )
				{
					$errString = "ERROR: Index of x out of range in line $n.";
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
				$errString = "ERROR: Incorrect syntax in line $n. Inappropriate char at start of function";
				$found = 1;
				last;
			}
			#Check to see if function is ending properly
			if($func =~ m/[^\)\d]$/)
			{
				$errString = "ERROR: Incorrect syntax in line $n. Inappropriate char at end of function";
				$found = 1;
				last;
			}
			#check to see if x always has an index
			if($func =~ m/x\D/g)
			{
				$errString = "ERROR: Incorrect syntax in line $n. Check x variable";
				$found = 1;
				last;
			}
			#check to see if ^ always has a number following
			if($func =~ m/\^\D/g)
			{
				$errString = "ERROR: Incorrect syntax in line $n. Check exponent value";
				$found = 1;
				last;
			}
			if( ($func =~ m/[\+\-\*\(][\)\+\-\*\^]/g) || ($func =~ m/\)[\(\d x]/g) || ($func =~ m/\d[\( x]/g) )
			{
				$errString = "ERROR: Incorrect syntax in line $n. Read the <a href=http://dvd.vbi.vt.edu/visualizer/tutorial.html target=_blank>tutorial</a> for correct formatting rules.";
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
				$errString = "ERROR: Incorrect start of function declaration in line $n.";
				$found = 1;
				last;
			}
		}
		$n++;
	}
}
#after while loop ends, check to see if any error was found reading the file
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

if ($DEBUG) {
    print $_ foreach (@functions)
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
		for($h = 0; $h < scalar(@prefArr); $h++)
		{
			if($prefArr[$h] > $num_nodes)
			{
				print "<br><font color=red>Please check your update schedule.<br>";
				print "Make sure the range of each index of the update schedule is between 1 and number of nodes</font><br>";
				die("Program quitting..Error with update schedule field");
			}
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
			 # functions are changed, such that later a regular synchronuous
			 # update can be made, for example f1=x1+x2, f2=x1, 1_2 turns into 
			 #($x[1])+($x[2])
			 #(($x[1])+($x[2]))
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
		print "After async update functions look like\n<br>";
		print "$_<br>" foreach (@functions);
	}
}
#now for the main loop.
#we create a file ip.out.dot describing the state space

#open and initialize the file
open (OUTDOT,">$clientip.out.dot") or die("Failed to open file for writing");
print OUTDOT "digraph test {\n";

#we count both by $i and by @y which encodes $i in base $p_value
#first initialize @y, probably not needed

$y[$_] = 0 foreach(0..$num_nodes-1);


#MAIN LOOP
#loop over all p^n states, applying @function to each
for ($i=0; $i < $p_value**$num_nodes; $i++){


#  @functions wants a list @x, and it starts indexing from 1
    @x = (0, @y);

#   apply functions, reduce mod p.

#FIXME:  it would be noticibly faster to reduce during function evaluation
#instead of after -- to do this you could add a regex to
#substitute "%$p_value +" for occurances of "+" in @functions, I guess
#only a problem for larger primes

    $j = 0;
    foreach $f(@functions)    {
	$ans[$j] = eval($f) % $p_value;
	$j++;
    }

    if ($DEBUG) {
	print "$_ " foreach (@y);
	print "\t";
	print "$_ " foreach (@ans);
	print "\n";
    }

#but we have to number the nodes.  remember were looping over $i,
#so node @y is the $ith, but we have to
#convert the list @ans to decimal

    $dec_ans = 0;
    for ($j = 0 ; $j < $num_nodes; $j++){
	$dec_ans += $ans[$j]*$p_value**($num_nodes-$j-1);
    }


#check for fixed points
#theyre stored in an array of arrays @fixed_points
    if ($i == $dec_ans) {
	push(@fixed_points,[ @y ]);
    }


#here we essentially translate @y and @ans into strings $v, $w
#to be used for the labels in the graphviz view
    $v = "";    $w = "";
    for($j = 0 ; $j < $num_nodes; $j++){
	$v = $v ." " . "$y[$j]";
	$w = $w ." " . "$ans[$j]";
    }


#now we make the ip.out.dot file:
#declare node$i
    print OUTDOT "node$i [label=\"$v\"];\n";

#hopefully graphviz doesnt need us to declare every node before
#using it. If there is an error, uncomment this line at the cost
#of making the dot.out file larger
#    print OUTDOT "node$dec_ans [label=\"$w\"];\n";

#make an edge from @y to @ans
    print OUTDOT "node$i -> node$dec_ans;\n";


#   end of loop.  Finally increment @y -- a base p counter
#   $i is incremented by the for loop, so we dont have to worry
#   about when to stop

    $pos = $num_nodes-1;
    while ($pos >= 0) {
	if ($y[$pos] == $p_value - 1){
	    $y[$pos] = 0;
	    $pos--;
	}
	else {
	    $y[$pos]++;
	    last;
	}
    }
} #end for loop

#terminate and close ip.out.dot

print OUTDOT "}";
close(OUTDOT);


print "loop ended - begining to process .dot file\n" if ($DEBUG);

#make directories to save the component files and other information 

print "### $clientip<BR>" if ($DEBUG);
`mkdir $clientip`;
`chmod 777 $clientip`;
`mkdir $clientip/tmp`;
`chmod 777 $clientip/tmp`;
`mkdir $clientip/dev`;
`chmod 777 $clientip/dev`;
#$pres = `pwd`;
#chomp($pres);
$pres = "";

#let graphviz compute connected components
#gc returns  output like "     2 test (ip.out.dot)"
$s = `gc -c $clientip.out.dot`;
#remove trailing return
chomp $s;
#remove white space at beginning (\s+ matchs 1 or more spaces)
$s =~ s/\s+//;
#split off the number
@tmp = split(/ /, $s);
$num_comps = $tmp[0];
$fp = $#fixed_points + 1;
print "There are $num_comps components and $fp fixed point(s)<br>";

print "Processing components...\n" if ($DEBUG);

#store the components in files /tmp/component, /tmp/component_1, etc
#FIXME: parse output of ccomps -v to get #components, then eliminate gc check
#above.  Probably only saves a few percent of the time, though, so whatever
$clientip = substr($clientip,6);

`cd ../../; ccomps -x -o $clientip/tmp/component $clientip.out.dot`;
#`ccomps -x -o /Users/franzi/Sites/$clientip/tmp/component /Users/franzi/Sites/$clientip.out.dot`;
$clientip = "../../" . $clientip;

#NOTE:   sccmap picks out the strongly connected component
#        of a directed graph.  In our case, that's the limit cycle.
#        But sccmap doesn't consider self loops, so we add the fixed point in


#first process ./tmp/component (stupid naming scheme by ccomps)
#FIXME: this really should be broken into a procedure
$size = `grep label $clientip/tmp/component | wc -l`;
$cycle = `sccmap $clientip/tmp/component 2> $clientip/dev/null | grep label |wc -l`;
chomp $size;
chomp $cycle;
$size =~ s/\s+//;
$cycle =~ s/\s+//;

if ($cycle == 0){ $cycle++;}
 print "<table border=0 cellspacing=3 cellpadding=2><tr><td align=center><b>Components</b></td><td align=center><b>Size</b></td><td align=center><b>Cycle Length</b></td></tr>";
print "<tr><td align=center>1</td><td align=center>$size</td><td align=center>$cycle</td></tr>";

$total_size += $size;

#if $num_comps > 1 then loop over $clientip/tmp/component_$i

for ($i = 1; $i < $num_comps; $i++){

    $size = `grep label $clientip/tmp/component_$i | wc -l`;
    $cycle = `sccmap $clientip/tmp/component_$i 2> $clientip/dev/null | grep label |wc -l`;
    
    chomp $size;
    chomp $cycle;
    $size =~ s/\s+//;
    $cycle =~ s/\s+//;
    if ($cycle == 0){ $cycle++;}
    $tmp = $i+1;
    print "<tr><td align=center>$tmp</td><td align=center>$size</td><td align=center>$cycle</td></tr>";
    $total_size += $size;

}
 print "</table>";

print "TOTAL: $total_size = $p_value^$num_nodes nodes<br>";

#print out fixed points and size of their components
    if ($fp > 0) {
      print "Printing fixed point(s)...<br>";
      for $i ( 0 .. $#fixed_points ) {
        print "\t [ @{$fixed_points[$i]} ] lies in a component of size ";

        #once again convert base p back to decimal
        $num = 0;
        for ($j = 0 ; $j < $num_nodes; $j++) {
          print $j."\n" if ($DEBUG);
          $num += $fixed_points[$i][$j]*$p_value**($num_nodes-$j-1);
        }

#this computes the connected component of node @fixed_points[$i]
        print "\n<br>" if ($DEBUG);
	      print "ccomps -Xnode$num $clientip.out.dot -v > $clientip/tmp/blah 2> $clientip/dev/null<br>" if ($DEBUG);
        print `which ccomps`."<br>\n" if ($DEBUG);
	      `ccomps -Xnode$num $clientip.out.dot -v > $clientip/tmp/blah 2> $clientip/dev/null`;
        print "ccomps \n<br>" if ($DEBUG);
#then we count how many labels (and thus nodes) there are in the file
        $s = `grep label $clientip/tmp/blah | wc -l`;
        chomp($s);
        $s =~ s/\s+//;
        print "$s. <br>";
      }
    }


#make the nice picture -- THIS IS SLOW!
#FIXME:  figure out how to make a pretty .png graph, so
#the file isn't so huge
if ($PICTURE){
    if($total_size <= 1000)
    {
      if(-e "$clientip.out.dot")
      {
        `dot -T$fileformat -o $clientip.out.$fileformat $clientip.out.dot`;
        #print "dot -T$fileformat -o $clientip.out.$fileformat $clientip.out.dot";
	#`dot -Tgif -o 198-82-22-143-29-9-11.out.gif 198-82-22-143-29-9-11.out.dot`;
#	if (-e "$clientip.out.$fileformat" )
#	{
#		print "dot -T$fileformat -o $clientip.out.$fileformat $clientip.out.dot";
#	}
#	else
#	{
#        print "HOT -T$fileformat -o $clientip.out.$fileformat $clientip.out.dot";
#	}
      }
    }
    else
   {
     print "<br><font color=red><i>Sorry. Unable to draw a graph with more than 1000 nodes in the state space.</i></font>";
     print "<br><font color = red>If you still want to see the graph, then email your function file and the parameters to hvastani@vbi.vt.edu</font>";
   }
}

