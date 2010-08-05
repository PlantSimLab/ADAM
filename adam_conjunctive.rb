#adam_conjunctive $n_nodes $p_value $dpGraph

# Takes input from dvd website and passes it to conjunctiveNetwork.m2 to
# compute fixed points/limit cycles
# returns 0 (no errors) or 1 (errors) 

unless ARGV.size == 3
  puts "Usage: ruby adam_conjunctive.rb n_nodes p_value dpGraph"
  exit 0
end

n_nodes = ARGV[0] 
p_value = ARGV[1]
dpGraph = ARGV[2]

puts "<br>"
if (p_value.to_i != 2)
  puts "This feature is only available for 2 states per node, not #{p_value}.<br>"
  exit 1
end

puts "<br>"
puts "<font color=blue><b>If your dependency graph is not strongly connected
  then it will exit at this time, sorry.</b></font><br>";
puts "<font color=blue><b>Calculating fixed points and limit cycles for
  conjunctive/disjunctive network now...</b></font><br>";

dpGraph = "../../" + dpGraph

#  m2_result = `cd lib/M2code/; M2 conjunctiveNetwork.m2 --stop --no-debug --silent -q -e 'QR = makeRing (#{n_nodes}, #{p_value}); ll = limCycles("#{dpGraph}"); exit 0'`
  m2_result = `cd lib/M2code/; /usr/local/bin/M2 conjunctiveNetwork.m2 --stop --no-debug --silent -q -e 'QR = makeRing (#{n_nodes}, #{p_value}); ll = limCycles("#{dpGraph}"); exit 0'`
m2_result = m2_result.gsub(/\n/, "<br>")
  puts m2_result
  puts "<br>"

exit 0
