 
#dvd_m2_runner $n_nodes $p_value $filename

# Takes input from dvd website and passes it to M2 to compute fixed points
# returns 0 (no errors) or 1 (errors) 

n_nodes = ARGV[0] 
p_value = ARGV[1]
functionFile = ARGV[2] 

puts "<br>"
puts functionFile
if (p_value.to_i != 2)
  puts "This feature is only available for 2 states per node, not #{p_value}.<br>"
  exit 1
end

puts "printing file #{functionFile}<br>"
m2_system =  "{"

File.open( functionFile, 'r').each {|line|
  puts "#{line}<br>"
  m2_system = m2_system + line.split(/=/).last 
  m2_system =  m2_system + ","
}

# remove last comma
m2_system.chop!
m2_system = m2_system + "};"

puts "<br>"
puts m2_system
puts "<br>"
puts "running M2 now ...<br>"

m2_result = `/Applications/Macaulay2-1.2/bin/M2 solvebyGB.m2 --stop --no-debug --silent -q -e 'QR = booleanRing 2; ll = gbSolver( { x1, x1+x2}, QR); exit 0'`

puts m2_result
puts "<br>"



exit 0

###

##M2 solvebyGB.m2 --stop --no-debug --silent -q -e 'QR = booleanRing 2; ll = gbSolver( { a,a+b}, QR); exit 0'
## M2 --stop --no-debug --silent -q -e 'loadPackage "solvebyGB"; QR = booleanRing 2; ll = gbSolver( { a,a+b}, QR); quit'
