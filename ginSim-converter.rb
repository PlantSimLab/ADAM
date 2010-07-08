 
# ginSim-converter $filename

# Takes GINsim file and converts it to a PDS so DVD can run calculations
# returns 0 (no errors) or 1 (errors) 

unless ARGV.size == 1
  puts "Usage: ruby ginSim-converter.rb functionFile"
  exit 0
end

functionFile = ARGV[0] 

m2_result = `cd lib/M2code/; M2 convertToPDS.m2 --stop --no-debug --silent -q -e 'toString converter("#{functionFile}"); exit 0'`

#TODO: all the exponents disappear in Ruby b/c in M2 they're saved as type Expression
#may possibly be easier to just make a function to make the string in M2

#TODO: in addition, all the multiplication symbols are gone. this happens in M2 too.
#I have no idea what's going on, since that doesn't make too much sense with the rings in M2

#get functions into array
functions = m2_result.split("{")
functions = functions.fetch(1).chop!
functions = functions.split(",")

#make empty string for formatted functions
formatFuncts = String.new(str="")

#format functions into f_i = ...
for i in 0..(functions.length-1) do
  f = "f" + (i+1).to_s + " =" + functions.fetch(i)
  formatFuncts = formatFuncts + " " + f + "\n"
end

#TODO: this newline thing doesn't work for some reason
puts formatFuncts

exit 0

###
