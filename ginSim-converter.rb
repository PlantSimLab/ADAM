 
# ginSim-converter $upload_file

# Takes GINsim file and converts it to a PDS so DVD can run calculations
# returns 0 (no errors) or 1 (errors) 

unless ARGV.size == 2
  puts "Usage: ruby ginSim-converter.rb ginSimFile functionFile"
  exit 0
end

ginSimFile = ARGV[0]
functionFile = ARGV[1]

#m2_result = `cd lib/M2code/; M2 convertToPDS.m2 --stop --no-debug --silent -q -e 'print toString last converter("../../#{ginSimFile}"); exit 0'`
#varList = `cd lib/M2code/; M2 convertToPDS.m2 --stop --no-debug --silent -q -e 'print toString first converter("../../#{ginSimFile}"); exit 0'`
varList = `cd lib/M2code/; /usr/local/bin/M2 convertToPDS.m2 --stop --no-debug --silent -q -e 'print toString first converter("../../#{ginSimFile}"); exit 0'`
m2_result = `cd lib/M2code/; /usr/local/bin/M2 convertToPDS.m2 --stop --no-debug --silent -q -e 'print toString last converter("../../#{ginSimFile}"); exit 0'`

#Converts varList to readable output
vars = varList.split("{")
vars = vars.fetch(1).chop!.chop!
vars = vars.split(",")

formatVars = String.new(str="Variables:<br>")
for i in 0..(vars.length-1) do
  v = "x" + (i+1).to_s + " =" + vars.fetch(i)
  formatVars = formatVars + " " + v + "<br>"
end

puts formatVars

#Converts functions in m2_result to something VADD can read
#get functions into array
#puts m2_result
functions = m2_result.split("{")
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
File.open(functionFile, "w"){|f| f.write(formatFuncts)}

exit 0

###
