 
# ginSim-converter $filename

# Takes GINsim file and converts it to a PDS so DVD can run calculations
# returns 0 (no errors) or 1 (errors) 

unless ARGV.size == 1
  puts "Usage: ruby ginSim-converter.rb functionFile"
  exit 0
end

functionFile = ARGV[0] 

m2_result = `cd lib/M2code/; M2 convertToPDS.m2 --stop --no-debug --silent -q -e 'toString converter("#{functionFile}"); exit 0'`

#get functions into array
functions = m2_result.split("{")
functions = functions.fetch(1).chop!
functions = functions.split(",")

#make empty string for formatted functions
formatFuncts = String.new(str="")

#format functions into f_i = ...
for i in 0..(functions.length-1) do
  f = "f" + (i+1).to_s + " =" + functions.fetch(i)
  formatFuncts = formatFuncts + " " + f
end

puts formatFuncts
puts "<br>"

exit 0

###
