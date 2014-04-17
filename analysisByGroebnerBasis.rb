#analysisByGroebnerBasis.rb $n_nodes $p_value $filename $limCyc_length

require './partial_input'
require 'FileUtils'
require 'pp'
require 'json'

def changeExtensionToJSON(originalFilename)
  path = File.dirname(originalFilename)
  basename = File.basename(originalFilename, ".txt")
  path + '/' + basename + ".json"
end

# Takes input from dvd website and passes it to M2 to compute fixed points
# returns 0 (no errors) or 1 (errors) 

unless ARGV.size == 4
  puts "Usage: ruby analysisByGroebnerBasis.rb n_nodes p_value functionFile limCyc_length"
  exit 0
end

n_nodes = ARGV[0]
p_value = ARGV[1]
functionFile = ARGV[2] 
limCyc_length = ARGV[3]

puts "<br>"

# read the complete input file
s = IO.readlines(functionFile)

# take the input functions and put the in a hash, for example
# {1=>["x1+x2"], 2=>["x2"], 3=>["x3", "x2", "x1"]}
functionHash = PartialInput.parse_into_hash s

#puts "<pre>"
#pp functionHash
#puts "</pre>"

 
# this is the list that gives the number of functions per variable
# if one variable has more than 1 function, the system is probabilistic
numFunctions = functionHash.values.collect { |f| f.size }

# some error checking on fi
if  functionHash.keys.sort != (1..n_nodes.to_i).to_a 
  #puts "functionHash: #{functionHash}<br>"
  #puts "functionHash.keys: #{functionHash.keys.sort}<br>"
  puts "Error. There should be #{n_nodes} functions in order in the function input and functions should be called f1, ..., f#{n_nodes}. Did you maybe forget to select a file?<br>"
  exit 1
end

def stateList(p)
  [*0..p-1].map{ |i| i.to_s }
end

def variableToHash(i, p)
  var = "x" + i.to_s
  {
    "name" => var, 
    "id" => var, 
    "states" => stateList(p)
  }
end

def polyToHash(functionHash, i)
  # functionHash: created above
  # i: an index
  function = functionHash[i][0]
  { "polynomialFunction" => function }
end

def modelToHash(functionHash, n_nodes, p_value)
  n = n_nodes.to_i
  p = p_value.to_i
  varList = [*1..n].map { |i| variableToHash(i, p) }
  updatesHash = {}
  for i in 1..n do 
    var = "x" + i.to_s
    updatesHash[var] = polyToHash(functionHash, i)
  end
  {"model" => {
     "variables" => varList,
     "updateRules" => updatesHash
     }
  }
end

puts "Running analysis now ...<br>"


model = modelToHash(functionHash,n_nodes,p_value)

modelFile = changeExtensionToJSON(functionFile)
File.open(modelFile, 'w') { |file| file.write(JSON.pretty_generate(model)) }

m2_result = `./lib/M2code/limitCycles.m2 #{modelFile} #{limCyc_length}`

#puts "result from m2: " + m2_result
result = JSON.parse(m2_result)
components = result["output"]["components"]
numCycles = components.length()

if numCycles == 0
  puts "There are no limit cycles of length #{limCyc_length}."
  puts "<br>"
  puts "<br>"
else
  if numCycles == 1
    puts "There is one limit cycle of length #{limCyc_length}"
  else
    puts "There are " + numCycles.to_s + " limit cycles of length #{limCyc_length}"
  end
  puts " and they are: <br>"
  components.each { |c| 
    cycle = c["steadyState"]
    puts cycle.to_s + "<br>"
    }
  puts "<br>"
end

exit 0
