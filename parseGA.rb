#!/usr/bin/ruby -w

# (halasadi@umich.edu) July 24, 2011 

require 'pp'
# Assume ARGV[1]: size of the field
#        ARGV[2]: weights
#        ARGV[2]: dream steady state
#        ARGV[3]: Input Function



unless ARGV.size == 4
  puts "Usage: ruby parseGA.rb p_value weights dream_ss filename "
  exit 0
end

# REQUIRES: m2result to be a valid output returned by M2 in string format. Specifically
#           each knockout combination must be separated by a new line
# EFFECTS: the result of the M2 calculation is parsed and outputted to the screen
def parseoutput(m2result)
  knockouts = Array.new
  m2result.gsub!("{", "")
  m2result.gsub!("}", "")
  m2result.gsub!(",","")
  cnt = 0
  m2result.each_line {  |line|
    puts "<br> <font color=blue> Knockout Combination: #{cnt+1}</font color=blue><br>"
    line.gsub!(/ /,"")
    num_chars = 1  # count the number of characters
    num_knockouts = 0 # count the number of knockouts
    line.each_char { |c|
    if c == '0' 
      puts "Gene #{num_chars}, "
      num_knockouts = num_knockouts + 1
    end
      num_chars = num_chars + 1
    }
    if num_knockouts == 0 
      puts "No Knockouts" 
    end
    cnt = cnt + 1 # count the number of knockout combinations
  }
 return nil
end

# checks if there any invalid characters in dreamss
def checkdreamss(dreamss, field_size)
  str_array = (0..(field_size-1)).collect{ |i| i.to_s}
  dreamss.each { |i|
    if (str_array.include? i) || i == "?" 
        # we're good
    else
      puts " <font color=red>Error, please re-enter desired steady state.</font color=red><br>"
      exit 1
    end
  }
end 

# checks if each weight is a valid character and a positive integer
def checkweights(weights)
  weights.each {
    |weight|
    num = weight.to_i
    # check if it is a positive integer
    if num.to_s == weight && num >= 0 || weight == "n" || weight == 'N'
      # we are good
    else
      puts " <font color=red>Error, please re-enter weights.</font color=red><br>"
      exit 1
    end
  }
end

# read in the inputs
p_value = ARGV[0]
weights = ARGV[1]
dreamss = ARGV[2]
inputfunctions = ARGV[3]


puts "<br>"
p = p_value.to_i

if p == -1 
  puts "<font color=red>Error. Number of nodes should be a positive integer.</font color=red><br>"
  exit 1
end

# Read the functions
functions = Array.new
file = File.new(inputfunctions, "r")
cnt = 0
while(line = file.gets)
  functions[cnt] = line.gsub(" ", "")
  functions[cnt] = "\"" + functions[cnt].rstrip + "\""
  cnt = cnt + 1
end
file.close

# set the number of lines as the number of variables
num_vars = cnt

# format the functions as a list
tempfunctions = "\{"
functions.each do |function|
  tempfunctions = tempfunctions + function + ","
end
tempfunctions.chop!
functions = tempfunctions + "\}"

# put the goal steady state in M2 format
cnt = 0
dreamss = dreamss.split
checkdreamss(dreamss, p)
tempdreamss = "\{"
dreamss.each do |ss|
  tempdreamss = tempdreamss + ss + ","
  cnt = cnt + 1
end
if (cnt != num_vars)
   puts "<font color=red>Error. Number of entries in the steady state should equal the number of variables.</font color=red><br>"
  exit 1
end
dreamss = tempdreamss.gsub("?","NA")



# put the weights in M2 format
cnt = 0
weights = weights.split
checkweights(weights)
tempweights = ""
weights.each do |weight|
  tempweights = tempweights + weight + ","
  cnt = cnt + 1
end
if (cnt != num_vars)
   puts "<font color=red>Error. Number of weights should equal the number of variables.</font color=red><br>"
  exit 1
end
tempweights.chop!
weights = tempweights + "\}"
weights.gsub!("n","no")
weights.gsub!("N","no")

# combine the steady states and weights in one string
ss_and_weights = dreamss + weights


# call M2
#puts "#{num_vars}, #{p_value}, #{functions}, #{ss_and_weights}"

m2_result = `/usr/local/bin/M2 methodAdaptiveGA.m2 -q -e 'AdaptiveGAwPS(#{num_vars}, #{p_value}, #{functions}, #{ss_and_weights} ); exit 7'`
#puts m2_result
if $?.exitstatus == 7
  puts " The genetic algorithm found these resulting knockouts<br>" 
  parseoutput(m2_result)
else
  "<font color=red>Error. Number of nodes should be a positive integer.</font color=red><br>"
  puts "<font color=red> Error. Please re-enter your function, refer to the userguide for the correct format.</font color=red><br>"
end

exit 0
