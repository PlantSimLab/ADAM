# ginSim-converter $clientip.ginsim.ginml $filename $valuesFile

# Takes GINsim file and converts it to a PDS so DVD can run calculations
# returns 0 (no errors) or 1 (errors) 

unless ARGV.size == 1
  puts "Usage: ruby ginSim-converter.rb clientip"
  exit 0
end

clientip = ARGV[0]

#result = `cd lib/M2code/; M2 convertToPDS.m2 --stop --no-debug --silent -q -e 'cF = converter("../../#{clientip}.ginsim.ginml"); stdio << toString first cF << "?" << toString last cF << "?" << char ring last cF << "?" << numgens ring last cF; exit 0'`
result = `cd lib/M2code/; /usr/local/bin/M2 convertToPDS.m2 --stop --no-debug --silent -q -e 'cF = converter("../../#{clientip}.ginsim.ginml"); stdio << toString first cF << "?" << toString last cF << "?" << char ring last cF << "?" << numgens ring last cF; exit 0'`

result = result.split("?")
varList = result.fetch(0)
m2_result = result.fetch(1)

# get p_value and n_nodes
p = result.fetch(2)
File.open("#{clientip}.pVal.txt", "w"){|f| f.write(p)}
n = result.fetch(3)
File.open("#{clientip}.nVal.txt", "w"){|f| f.write(n)}

#Converts varList to readable output
vars = varList.split("{")
vars = vars.fetch(1).chop!
vars = vars.split(",")

formatVars = String.new(str="Variables:<br>")
for i in 0..(vars.length-1) do
  v = "x" + (i+1).to_s + " =" + vars.fetch(i)
  formatVars = formatVars + " " + v + "<br>"
end

puts formatVars

#Outputs p value to user
puts "<br>The number of states in this model is: " + p + "<br><br>"

#Converts functions in m2_result to something ADAM can read
#get functions into array
#puts m2_result
functions = m2_result.split("{{")
functions = functions.fetch(1).chop!.chop!
functions = functions.split(",")

#make empty string for formatted functions
formatFuncts = String.new(str="")

#format functions into f_i = ...
for i in 0..(functions.length-1) do
  f = "f" + (i+1).to_s + " =" + functions.fetch(i)
  formatFuncts = formatFuncts + " " + f + "<br>"
end

#formatFuncts = formatFuncts.split("<br>")
puts "The logical model was converted to:<br>"
puts formatFuncts
formatFuncts = formatFuncts.gsub(/<br>/, "\n")
File.open("#{clientip}.functionfile.txt", "w"){|f| f.write(formatFuncts)}

exit 0

###
