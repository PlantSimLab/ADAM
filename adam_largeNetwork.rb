#adam_largeNetwork $n_nodes $p_value $filename $limCyc_length

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

m2_system =  "{{"

largestI = 0
File.open( functionFile, 'r').each {|line|
  # puts "#{line}<br>"
  ll = line.split(/=/)
  m2_system = m2_system + ll.last 
  m2_system =  m2_system + ","
  largestI = ll.first.split(/f/).last.to_i
}

if (largestI != n_nodes.to_i ) 
  puts "There should be #{n_nodes} functions in order in the function
  input, but the last function I read was f#{largestI}. Exiting. <br>"
  exit 1
end

# remove last comma
m2_system.chop!
m2_system = m2_system + "}}"

puts "<br>"
#puts m2_system
#puts "<br>"
puts "Running fixed point calculation now ...<br>"

#one line is for my machine, one line is for the server b/c M2 is in different paths
#  m2_result = `cd lib/M2code/; M2 solvebyGB.m2 --stop --no-debug --silent -q -e 'QR = makeRing(#{n_nodes}, #{p_value}); ll = gbSolver( matrix(QR, #{m2_system}), #{limCyc_length}); stdio << length ll << "?" << gbTable ll; exit 0'`
  m2_result = `cd lib/M2code/; /usr/local/bin/M2 solvebyGB.m2 --stop --no-debug --silent -q -e 'QR = makeRing(#{n_nodes}, #{p_value}); ll = gbSolver( matrix(QR, #{m2_system}), #{limCyc_length}); stdio << length ll << "?" << gbTable ll; exit 0'`
  temp = m2_result.split('?')
  numCycles = temp.fetch(0)
  table = temp.fetch(1)
if numCycles.chomp == "0"
  puts "There are no limit cycles of length #{limCyc_length}."
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
