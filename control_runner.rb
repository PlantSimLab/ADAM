
# Franziska Hinkelmann
# July 2010

#$ret = system("ruby control_runner.rb $n_nodes $u_nodes $p_value $functions");

# Takes input from dvd website and passes it to M2 to generate controlled PDS
# returns 0 (no errors) or 1 (errors) 

require 'fileutils'


unless (ARGV.size == 5 or ARGV.size == 7 )
  puts "Usage: ruby control_runner.rb n_nodes u_nodes p_value functions initialState finalState<br>" 
  puts "Initial and final state are optional"
  exit 1
end

n_nodes = ARGV[0].to_i 
u_nodes = ARGV[1].to_i 
p_value = ARGV[2].to_i
function = ARGV[3] 
file = ARGV[4]

traj = "{}" # this is the initial and final state, if heuristic control is desired, otherwise just an empty list
if (ARGV.size == 7 )
  initialState = ARGV[5]
  finalState = ARGV[6]
  traj = "{{#{initialState.gsub(/_/, ",")}}, {#{finalState.gsub(/_/, ",")}}}"
end

#  puts traj

filePrefix = file.split(/gif/).first
#puts "<br>"
#puts function
#puts "<br>"
#puts file 
#puts "<br>"

functionArr = function.split(/\n/)

unless functionArr.size == n_nodes 
  puts "There should be #{n_nodes} functions, but I encountered #{functionArr.size}.<br>"
  exit 1
end

m2_system =  "{{"
functionArr.each { |func|
  ll = func.split(/=/)
  m2_system = m2_system + ll.last 
  m2_system =  m2_system + ","
}

# remove last comma
m2_system.chop!
m2_system = m2_system + "}}"

#puts "<br>"
#puts m2_system
#puts "<br>"

puts "Generating the phase space ...<br>"

#puts "cd controlM2/; /usr/local/bin/M2 Visualizer.m2 --stop --no-debug --silent -q -e 'QR = makeControlRing(#{n_nodes}, #{u_nodes}, #{p_value}); visualizeControl( matrix(QR, #{m2_system}), #{u_nodes}, #{traj}); exit 0'"
m2_result = `cd controlM2/; /usr/local/bin/M2 Visualizer.m2 --stop --no-debug --silent -q -e 'QR = makeControlRing(#{n_nodes}, #{u_nodes}, #{p_value}); visualizeControl( matrix(QR, #{m2_system}), #{u_nodes}, #{traj}); exit 0'`

# puts m2_result 

tmpFile = "#{filePrefix}dot"
File.open( tmpFile, 'w') {|f| f.write m2_result}

dotPath = `which dot`
dotPath.chop!
#puts "#{dotPath} -Tgif #{tmpFile} -o #{file}"
`#{dotPath} -Tgif #{tmpFile} -o #{file}`

exit 0

puts "<br>"
puts tmpFile
puts "<br>"
puts file
puts "<br>"



puts "Running fixed point calculation now ...<br>"

for i in 1..5 do 
  m2_result = `cd lib/M2code/; /usr/local/bin/M2 solvebyGB.m2 --stop --no-debug --silent -q -e 'QR = makeRing(#{n_nodes}, #{p_value}); ll = gbSolver( matrix(QR, #{m2_system}), #{i}); exit 0'`
  puts m2_result
  puts "<br>"
end



exit 0

###

##M2 solvebyGB.m2 --stop --no-debug --silent -q -e 'QR = booleanRing 2; ll = gbSolver( { a,a+b}, QR); exit 0'
## M2 --stop --no-debug --silent -q -e 'loadPackage "solvebyGB"; QR = booleanRing 2; ll = gbSolver( { a,a+b}, QR); quit'
