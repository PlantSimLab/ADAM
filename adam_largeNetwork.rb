#adam_largeNetwork $n_nodes $p_value $filename $limCyc_length

require './partial_input'
require 'FileUtils'
require 'pp'
require 'json'

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

def stateStringJSON(p_value)
  strs = [*0..p_value.to_i-1].map { |i| '"' + i.to_s + '"' }
  "[" + strs.join(",") + "]"
end

def polyToJSON(functionHash, i)
  # functionHash: created above
  # i: an index
  # output: a string of the form:
  #      "x1": { 
  #          "polynomialFunction": "x1*x2"
  #      }
  '"x' + i.to_s + '": {
      "polynomialFunction": "' + functionHash[i][0].to_s + '"}'
end

def variableToJSON(i,p_value)
  # i: an index
  # output: a string of the form:
  # { "id": "xi", "name": "xi", "states":stateString }
  stateString = stateStringJSON(p_value)
  '{ "id": "x' + i.to_s + '",
            "states": ' + stateString + '
        }'
end

def polysToJSON(functionHash, n_nodes)
  # functionHash: created above
  # n_nodes: number of nodes.  These are expected to be x1, x2, ....
  strs = [*1..n_nodes.to_i].map { |i| polyToJSON(functionHash,i) }
  "{" + strs.join(",") + "}"
end

def modelToJSON(functionHash, n_nodes, p_value)
  varlist = [*1..n_nodes.to_i].map { |i| variableToJSON(i,p_value) }
  vars = '"variables": [' + varlist.join(",") + ']'
  updatestr = '"updateRules": ' + polysToJSON(functionHash, n_nodes)
  '{ "model": {' + vars + ", " + updatestr + '} }' 
end

#puts variableToJSON(3,p_value)
#puts polyToJSON(functionHash,2)
#puts polysToJSON(functionHash, n_nodes)
#puts modelToJSON(functionHash,n_nodes,p_value)

puts "Running analysis now ...<br>"

ourModel = modelToJSON(functionHash,n_nodes,p_value)
model_hash = JSON.parse(ourModel)
ourModel2 = JSON.pretty_generate(model_hash)

#pp(ourModel2)

modelFile = "/tmp/myModelFile.json"
File.open(modelFile, 'w') { |file| file.write(ourModel2) }

m2_result = `./lib/M2code/limitCycles.m2 #{modelFile} #{limCyc_length}`

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
