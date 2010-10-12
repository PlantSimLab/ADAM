require 'rubygems'
require 'snoopy'
require 'xmlsimple'
require 'pp'

# remove all <graphics> tags
      

filename = ARGV[0]
pvalue = ARGV[1].to_i

begin
  pn = Snoopy.new(filename, pvalue)
rescue 
  puts "There was a problem with your input. Please check that the input file
is a standard petri net and that the k-bound you entered is 1 less than a
prime number. Thank you."
  exit 1
end

puts pn.printNames()
puts ""
pn.populateIncidenceMatrix()
pn.makeIndicatorFunctions()
pn.makeNetworks()
pn.networks.each_with_index{ |network, index|
  puts "transition: #{index+1}"
  network.each_with_index{ |n, i|
    puts "f#{i+1} = #{n}"
  }
  puts ""
}


exit 0 
#end
#
#variable['attribute'] 
#
#config['nodeclasses'].first['nodeclass']['Place']['node']['2002']
#config['nodeclasses'].first['nodeclass']['Place']['node']['1991']
#variableName =  config['nodeclasses'].first['nodeclass']['Place']['node']['1991']['attribute']['Name']['content'].strip
#variableName =  config['nodeclasses'].first['nodeclass']['Place']['node']['2002']['attribute']['Name']['contentgg
#pp config['nodeclasses'].first['nodeclass']['Place']['node']['2002']
#numberOfPlaces = config['nodeclasses'].first['nodeclass']['Place']['count'].to_i
#config['nodeclasses'].first['nodeclass']['Transition']
#config["node"].first.class
#config["node"].size
#
# config["netclass"]
# config["nodeclass"].keys
# config["nodeclasses"].keys
# config["nodeclasses"].values.class
# numberOfNodes = config["nodeclasses"].values.first["nodeclass"].keys.first.to_i
# nodes = config["nodeclasses"].values.first["nodeclass"].values.first
#  config["nodeclasses"].values.first["nodeclass"].values.first
#  config["nodeclasses"].values.first["nodeclass"].values.size
# nodes.size
# nodes.size == numberOfNodes
# if ( nodes.size != numberOfNodes)
#   puts "Error in number of nodes"
#   exit 1
# end
# nodes.first
# nodes.last
# nodes.first.values
# nodes.each { |n| 
#  pp n 
# }
# pp config["nodeclasses"]["4"]["nodeclass"]
# pp (config["nodeclasses"].values)["nodeclass"].values
# hh = config["nodeclasses"]["4"]["nodeclass"].values.first
# hh.keys
# hhh = hh["node"].first
# hhh.keys
# hhh["id"]
# pp config["nodeclasses"]["4"]["nodeclass"].keys
# pp config["nodeclasses"]
# 
#
#numberOfVariables = config["nodeclasses"]["4"]["nodeclass"].keys.first.to_i
#
#cc = XmlSimple.xml_in( config['nodeclasses'], 
#
#
