require 'rubygems'
require 'xmlsimple'
require 'pp'

# remove all <graphics> tags

filename = 'foo.xml'
line_arr = File.readlines(filename)
new_arr = []
inGraphicsFlag = false
line_arr.each do |line|

  if ( line =~ /\s*<graphics/ )
    inGraphicsFlag = true
    next
  end

  if ( line =~ /\s*<\/graphics/ )
    inGraphicsFlag = false
    next
  end

  if inGraphicsFlag
    next
  end

  new_arr.push line
end 

File.open(filename+".new", "w") do |f| 
  new_arr.each{|line| f.puts(line)}
end

config = XmlSimple.xml_in(filename+".new", { 'KeyAttr' => ['name', 'node', 'id', 'node'] })



# these are the nodes and their names
index = 1
variables = {}
nNodes = config['nodeclasses'].first['nodeclass']['Place']['count'].to_i
nodes = config['nodeclasses'].first['nodeclass']['Place']['node']
nodes.each_pair{ |id, v|
  puts "x#{index} = #{v['attribute']['Name']['content'].strip}"
  variables[id] = index
  index = index + 1
}

# these are the edges connecting places and transitions
edges = config['edgeclasses'].first['edgeclass']['Edge']['edge']
edges.keys
edges.each_pair{ |id, e|
#  puts e['source']
#  puts e['target']
}

# these are the transitions
index = 1
transitions = config['nodeclasses'].first['nodeclass']['Transition']['node']
transitions.each_pair{ |id, t|
  inputs = edges.keys.select{ |k| edges[k]['target'] == id }.collect{ |k| edges[k]['source'] }
  outputs= edges.keys.select{ |k| edges[k]['source'] == id }.collect{ |k| edges[k]['target'] }

  puts 
  puts "transition: #{index}"
  index = index + 1
  prod = ""
  inputs.collect!{ |id| variables[id] }
  inputs.each { |i| 
    prod = prod + "x#{i}*"
  }
  prod.chop!

  # if all inputs are on, decrease them
  inputs.each{ |i| puts "f#{i} = 1 - #{prod}" }
  
  outputs.collect!{ |id| variables[id] }
  # if all inputs are on, increase all outputs
  outputs.each{ |i| puts "f#{i} = #{prod}" }

  tmp = (inputs + outputs).uniq
  vars = (1..nNodes).to_a - tmp
  vars.each{ |i|
    puts "f#{i} = x#{i}"
  }

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
