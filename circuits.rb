#circuits $n_nodes $p_value $filename $circuitFile
# ruby circuits.rb n_nodes, infile, outfile

require 'partial_input'

# Outputs functional circuits from dependency graphs

unless ARGV.size == 4
  puts "Usage: ruby circuits.rb n_nodes p_value functionFile circuitFile"
  exit 0
end

n_nodes = ARGV[0]
p_value = ARGV[1]
functionFile = ARGV[2]
circuitFile = ARGV[3]

puts "<br>"

if p_value.to_i != 2 
  puts "<font color=red>Error. Circuit analysis only possible when the number of states per node is 2.</font color=red><br>"
  exit 1
end

# read the complete input file
s = IO.readlines(functionFile,'').to_s

# take the input functions and put the in a hash, for example
# {1=>["x1+x2"], 2=>["x2"], 3=>["x3", "x2", "x1"]}
functionHash = PartialInput.parse_into_hash s
 
# this is the list that gives the number of functions per variable
numFunctions = functionHash.values.collect { |f| f.size }

# make M2 list numFunctions 
m2_numFunctions = "{"
numFunctions.each { |i| 
  m2_numFunctions = m2_numFunctions + i.to_s
  m2_numFunctions = m2_numFunctions + ","
}
m2_numFunctions.chop!
m2_numFunctions = m2_numFunctions + "}"

# some error checking on fi
if  functionHash.keys.sort != (1..n_nodes.to_i).to_a 
  #puts "functionHash: #{functionHash}<br>"
  #puts "functionHash.keys: #{functionHash.keys.sort}<br>"
  puts "<font color=red>Error. There should be #{n_nodes} functions in order in the function input and functions should be called f1, ..., f#{n_nodes}. Did you maybe forget to select a file?</font color=red><br>"
  exit 1
end


# making a list in M2 format of equations
m2_system =  "{"
functionHash.sort.each{ |index,functions|
  functions.each{ |f|
    m2_system = m2_system + "\"" + f + "\""
    m2_system =  m2_system + ","

    varIndices = f.scan(/x+[0-9]+/)
    varIndices = varIndices.collect{ |x| x.slice(1, x.length-1) }
    for i in varIndices
      if (i.to_i > n_nodes.to_i)
        puts "<font color=red>Error. Index of x out of range in function f#{index}. Exiting. </font color=red><br>"
        exit 1
      end
    end
  }
}
# remove last comma
m2_system.chop!
m2_system = m2_system + "}"

#puts "<br>"
#puts m2_system
#puts "<br>"

#one line is for my machine, one line is for the server b/c M2 is in different paths
#m2_result = `cd lib/M2code/; M2 functionalCircuits.m2 --stop --no-debug --silent -q -e 'printAdjacencyMatrix constructAdjacencyMatrix #{m2_system}; exit 0'`
#puts m2_result
m2_result = `cd lib/M2code/; /usr/local/bin/M2 functionalCircuits.m2 --stop --no-debug --silent -q -e 'll = functionalCircuit #{m2_system}; stdio << length ll << "?" << circuitTable ll; exit 0'`
temp = m2_result.split('?')
numCircuits = temp.fetch(0)
table = temp.fetch(1)
f = ""
if numCircuits.chomp == "0"
  f = "There are no functional circuits in your dependency graph!<br><br>"
else
  f = "There are " + numCircuits + " functional circuits and they are: <br>" + table + "<br>"
end

File.open(circuitFile, "a"){|g| g.write(f)}


exit 0

###

##M2 solvebyGB.m2 --stop --no-debug --silent -q -e 'QR = booleanRing 2; ll = gbSolver( { a,a+b}, QR); exit 0'
## M2 --stop --no-debug --silent -q -e 'loadPackage "solvebyGB"; QR = booleanRing 2; ll = gbSolver( { a,a+b}, QR); quit'
