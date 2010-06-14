#Hussein Vastani
#This program takes in a file of boolean functions and prints out polynomial functions after the conversion


open (INFILE,"<$ARGV[0]") or die("Failed to open file for reading");
open (OUTFILE, ">$ARGV[1]") or die("Failed to open file for writing");
$num_nodes = $ARGV[2];


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
	$fcount = 1;
	$n = 1;
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
		#$count = $line =~ s/\*{2}/\^/g;
		#if the line begins with f or F
		if( (($line ne "")&&($line ne null)) && ($line =~ m/^f$fcount=/i) )
		{
			$func = (split(/=/,$line))[1]; # just read the function
			if(length($func) == 0)
		   {
				$errString =  "ERROR: Empty function no $fcount";
				$found = 1;
				last;
		   }
		   if($func =~ m/[^(x)(\d)(\()(\))(\+)(\-)(\*)(\~)]/g)
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
		   if($func =~ m/^[\)\*\+~]/)
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
		   if( ($func =~ m/[\+\-\*\(][\)\+\-\*]/g) || ($func =~ m/[\+\*][\~]/g) || ($func =~ m/\)[\(\d\~x]/g) || ($func =~ m/\d[\(\~ x]/g) )
		   {
				$errString = "ERROR: Incorrect syntax in line $n. Read the <a href=http://dvd.vbi.vt.edu/visualizer/tutorial.html target=_blank>tutorial</a> for correct formatting rules.";
				$found = 1;
				last;
		   }
		   # check to see if the number of opening paranthesis is atleast equal to the number of operators. 
		   if( ( tr/\(/\(/ ) < (  tr/\+/\+/ + tr/\*/\*/ + tr/~/~/ ) )
		   {
			   $errString = "ERROR: Function does not adhere to <b>Fully Bracketed Infix Expressions</b> format in line $n. Read the <a href=http://dvd.vbi.vt.edu/visualizer/tutorial.html target=_blank>tutorial</a> for more information.";
			   $found = 1;
			   last;
		   }
		   if($found == 0)
		   {
			   @express = ();
			   @testarr = split( /([\(\)\*\+\~ ])/,$func);
			   for($i = 0; $i < scalar(@testarr); $i++)
				{
					if($testarr[$i] ne "" && $testarr[$i] ne " " )
					{
						push(@express,$testarr[$i]);
					}
				}
				print OUTFILE "f$fcount = ".evaluateInfix(@express)."\n";
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
if($found == 1)
{
  print "<br><font size=3>Errors found in the input functions. See below for description:</font>";
  print "<br>-----------------------------------------------------------------------<br>";
  print "<font color=red>".$errString."</font><br>";
  close(OUTFILE);
 `rm -rf $ARGV[1]`;
  die("Errors with input file..ending program");
}
if(($n-1) < $num_nodes)
{
	print "<br><font size=3>Errors found in the input functions. See below for description:</font>";
    print "<br>-----------------------------------------------------------------------<br>";
	print "<font color=red>ERROR: Insufficient number of functions provided in input. Check your number of nodes field</font><br>";
	close(OUTFILE);
   `rm -rf $ARGV[1]`;
    die("Errors with input file..ending program");
}

sub isOperand
{
    $param = shift;
    if((!isOperator($param)) && ($param ne "(") && ($param ne ")"))
    {
        return 1;
    }
    else
    {
        return;
    }
}

sub isOperator
{
    $param = shift;
    if(($param eq "+") || ($param eq "*") || ($param eq "~"))
    {
        return 1;
    }
    else
    {
        return;
    }
}


sub InfixToPostfix
{
    @infixStr = @_;
    @postfixArr = ();
    @stack = ();
    for($i=0; $i<scalar(@infixStr); $i++)
    {
        if(isOperand($infixStr[$i]))  #if its an operand ( * or + or ~)
        {
            push(@postfixArr,$infixStr[$i]); # add it to the end of the postfixarray or as say top of stack
        }
        if(isOperator(@infixStr[$i])) #if its an operator (x1, x2, x3 etc)
        {
            push(@stack,$infixStr[$i]);   # add it to the top of stack
        }
        if(@infixStr[$i] eq ")") #this marks the latest closed paranthesis
        {
            push(@postfixArr, pop(@stack)); #remove from stack and push it in postFixArray
        }
    }
    return @postfixArr;
}
sub PostfixEval
{
    @postfixArr = @_;
    @stackArr = ();
    for($i=0; $i<scalar(@postfixArr); $i++)
    {
        if(isOperand($postfixArr[$i]))
        {
            push(@stackArr,$postfixArr[$i]);
        }
        if(isOperator($postfixArr[$i]))
        {
          $val = pop(@stackArr);
          if($postfixArr[$i] eq "~")
          {
              $val = "(".$val."+1)";
              push(@stackArr, $val);
          }
          if($postfixArr[$i] eq "+")
          {
             $val2 = pop(@stackArr);
             $val = "((".$val."+".$val2.")+(".$val."*".$val2."))";
             push(@stackArr, $val);
          }
          if($postfixArr[$i] eq "*")
          {
             $val2 = pop(@stackArr);
             $val = "(".$val."*".$val2.")";
             push(@stackArr, $val);
          }
        }
    }
    return @stackArr;
}

sub joinArr
{
    (@who)=@_;
    $who_len=@who;
    $retVal = "";
    for($i=0; $i<$who_len; $i++)
    {
        $retVal.=$who[$i];
    }
    return $retVal;
}
sub evaluateInfix
{
    @exp = @_;
    return joinArr(PostfixEval(InfixToPostfix(@exp)));
}

close(INFILE);
close(OUTFILE);
