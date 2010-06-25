 
#dvd_m2_runner $n_nodes $p_value $filename

# Takes input from dvd website and passes it to M2 to compute fixed points
# returns 0 (no errors) or 1 (errors) 

n_nodes = ARGV[0] 
p_value = ARGV[1]
functionFile = ARGV[2] 

puts "<br>"
if (p_value != 2)
  puts "This feature is only available for 2 states per node, not #{p_value}.<br>"
  return 1
end


return 0
