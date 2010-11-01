#adam_largeNetwork $n_nodes $p_value $filename $limCyc_length

require 'partial_input'
require 'pp'

# Takes input from dvd website and passes it to M2 to compute fixed points
# returns 0 (no errors) or 1 (errors) 

unless ARGV.size == 4
  puts "Usage: ruby adam_largeNetwork.rb n_nodes p_value functionFile limCyc_length"
  exit 0
end

n_nodes = ARGV[0]
p_value = ARGV[1]
functionFile = ARGV[2] 
limCyc_length = ARGV[3]

puts "<br>"

# read the complete input file
s = IO.readlines(functionFile,'').to_s

# take the input functions and put the in a hash, for example
# {1=>["x1+x2"], 2=>["x2"], 3=>["x3", "x2", "x1"]}
functionHash = PartialInput.parse_into_hash s

#puts "<pre>"
#pp functionHash
#puts "</pre>"

 
# this is the list that gives the number of functions per variable
# if one variable has more than 1 function, the system is probabilistic
numFunctions = functionHash.values.collect { |f| f.size }
if false # numFunctions.max != 1 
  if limCyc_length.to_i != 1
    puts "Error, for a large probabilistic network, only fixed points can be calculated, no limit cycles of longer length. Exiting. <br>"
    exit 1
  end
end


# some error checking on fi
if  functionHash.keys.sort != (1..n_nodes.to_i).to_a 
  #puts "functionHash: #{functionHash}<br>"
  #puts "functionHash.keys: #{functionHash.keys.sort}<br>"
  puts "Error. There should be #{n_nodes} functions in order in the function input and functions should be called f1, ..., f#{n_nodes}. Did you maybe forget to select a file?<br>"
  exit 1
end


# making a list in M2 format of equations
m2_system =  "{{"
functionHash.sort.each{ |index,functions|
  functions.each{ |f|
    m2_system = m2_system + f
    m2_system =  m2_system + ","

    varIndices = f.scan(/x+[0-9]+/)
    varIndices = varIndices.collect{ |x| x.slice(1, x.length-1) }
    for i in varIndices
      if (i.to_i > n_nodes.to_i)
        puts "Error. Index of x out of range in function f#{index}. Exiting. <br>"
        exit 1
      end
    end
  }
}
# remove last comma
m2_system.chop!
m2_system = m2_system + "}}"

#puts "<br>"
#puts m2_system
#puts "<br>"
puts "Running analysis now ...<br>"

#one line is for my machine, one line is for the server b/c M2 is in different paths
#  m2_result = `cd lib/M2code/; M2 solvebyGB.m2 --stop --no-debug --silent -q -e 'QR = makeRing(#{n_nodes}, #{p_value}); ll = gbSolver( matrix(QR, #{m2_system}), #{limCyc_length}, #{m2_numFunctions}); stdio << length ll << "?" << gbTable ll; exit 0'`
  m2_result = `cd lib/M2code/; /usr/local/bin/M2 solvebyGB.m2 --stop --no-debug --silent -q -e 'QR = makeRing(#{n_nodes}, #{p_value}); ll = gbSolver( matrix(QR, #{m2_system}), #{limCyc_length}); stdio << length ll << "?" << gbTable ll; exit 0'`
  #puts "QR = makeRing(#{n_nodes}, #{p_value}); ll = gbSolver( matrix(QR, #{m2_system}), #{limCyc_length})<br>"
  #puts "cd lib/M2code/; /usr/local/bin/M2 solvebyGB.m2 --stop --no-debug --silent -q -e 'QR = makeRing(#{n_nodes}, #{p_value}); ll = gbSolver( matrix(QR, #{m2_system}), #{limCyc_length}, #{m2_numFunctions}); stdio << length ll << \"?\" << gbTable ll; exit 0'<br>"
  temp = m2_result.split('?')
  numCycles = temp.fetch(0)
  table = temp.fetch(1)
if numCycles.chomp == "0"
  puts "There are no limit cycles of length #{limCyc_length}."
  puts "<br>"
  puts "<br>"
else
  puts "There are " + numCycles + " limit cycles of length #{limCyc_length}"
  puts " and they are: <br>"
  puts table
  puts "<br>"
end


exit 0

###

##M2 solvebyGB.m2 --stop --no-debug --silent -q -e 'QR = booleanRing 2; ll = gbSolver( { a,a+b}, QR); exit 0'
## M2 --stop --no-debug --silent -q -e 'loadPackage "solvebyGB"; QR = booleanRing 2; ll = gbSolver( { a,a+b}, QR); quit'
