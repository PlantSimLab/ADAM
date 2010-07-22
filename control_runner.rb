
# Franziska Hinkelmann
# July 2010


# Takes input from dvd website and passes it to M2 to generate controlled PDS
# returns 0 (no errors) or 1 (errors) 

require 'fileutils'

#puts ARGV.size
unless (6..8) === ARGV.size
  puts "Usage: ruby control_runner.rb n_nodes u_nodes p_value functions giffile controlType initialState finalState<br>" 
  puts "Initial and final state are optional"
  exit 1
end

n_nodes = ARGV[0].to_i 
u_nodes = ARGV[1].to_i 
p_value = ARGV[2].to_i
function = ARGV[3] 
file = ARGV[4]

controlType = ARGV[5]
#  - nothing
#  - given
#  - heuristic
#  - best

if controlType == "nothing" 
  traj = "{}" # this is the initial and final state, if heuristic control is desired, otherwise just an empty list
elsif controlType == "given" and (7..8) === ARGV.size 
  initialState = ARGV[6]
  controlSequence = ARGV[7]
  controlSequenceArr = controlSequence.strip.split(/\n/)
  if controlSequenceArr.size == 0 
    puts "There should be a least one control if you want to apply given
    control.<br>"
    exit 1
  end
  controlSequence = "{"
  controlSequenceArr.each{ |u|
    controlSequence = controlSequence + "{#{u.strip.gsub(/\s+/, ",")}},"
  }
  controlSequence.chop!
  controlSequence = controlSequence + "}"

  initialState = "{#{initialState.gsub(/_/, ",")}}"
elsif (controlType == "heuristic" or controlType == "best") and ARGV.size == 8 
  initialState = ARGV[6]
  finalState = ARGV[7]
  initialState = "{#{initialState.gsub(/_/, ",")}}"
  finalState = "{#{finalState.gsub(/_/, ",")}}"
else 
  puts "Sorry, something was wrong with your input. Did you enter correct initial and final states?"
  exit 1
end

#  puts traj

filePrefix = file.split(/gif/).first
#puts "<br>"
#puts function
#puts "<br>"
#puts file 
#puts "<br>"

functionArr = function.strip.split(/\n/)

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

if ( n_nodes < 11 ) 
  #puts controlType
  if controlType == "nothing"
    puts "Generating the phase space of the #{if u_nodes>0 then "controlled " end}PDS.<br>"
    m2_result = `cd controlM2/; /usr/local/bin/M2 Visualizer.m2 --stop --no-debug --silent -q -e 'QR = makeControlRing(#{n_nodes}, #{u_nodes}, #{p_value}); F = matrix(QR, #{m2_system}); visualizePhaseSpace( F, #{u_nodes}); exit 0'`
    #puts "cd controlM2/; /usr/local/bin/M2 Visualizer.m2 --stop --no-debug
    #--silent -q -e 'QR = makeControlRing(#{n_nodes}, #{u_nodes}, #{p_value});
    #F = matrix(QR, #{m2_system}); visualizePhaseSpace( F, #{u_nodes}); exit
    #0'"

  elsif controlType == "given"

    m2_result = `cd controlM2/; /usr/local/bin/M2 Visualizer.m2 --stop --no-debug --silent -q -e 'QR = makeControlRing(#{n_nodes}, #{u_nodes}, #{p_value}); visualizeTrajectory( matrix(QR, #{m2_system}), #{initialState},  #{controlSequence}); exit 0'`

  elsif controlType == "heuristic"
    puts "Generating the phase space and finding control heuristically.<br>"
    m2_result = `cd controlM2/; /usr/local/bin/M2 Visualizer.m2 --stop --no-debug --silent -q -e 'QR = makeControlRing(#{n_nodes}, #{u_nodes}, #{p_value}); F = matrix(QR, #{m2_system}); traj = first findControl(F, #{initialState}, #{finalState}); visualizePhaseSpace( F, #{u_nodes}, traj); exit 0'`

  elsif controlType == "best"
    puts "Generating the phase space and finding best control.<br>"
    m2_result = `cd controlM2/; /usr/local/bin/M2 Visualizer.m2 --stop --no-debug --silent -q -e 'QR = makeControlRing(#{n_nodes}, #{u_nodes}, #{p_value}); F = matrix(QR, #{m2_system}); traj = first findOptimalControl(F, #{initialState}, #{finalState}); visualizePhaseSpace( F, #{u_nodes}, traj); exit 0'`

  else 
    puts "I don't understand this control type #{controlType}<br>"
    exit 1
  end

#puts "here"
#puts "<br>"
#puts m2_result 

else 
  unless controlType == "given"
    puts "Too many variables to generate the phase space.<br>"
  end
  if controlType == "nothing"
    puts "Nothing to do, good bye. <br>"
    exit 0

  elsif controlType == "given"
    m2_result = `cd controlM2/; /usr/local/bin/M2 Visualizer.m2 --stop --no-debug --silent -q -e 'QR = makeControlRing(#{n_nodes}, #{u_nodes}, #{p_value}); visualizeTrajectory( matrix(QR, #{m2_system}), #{initialState},  #{controlSequence}); exit 0'`

  elsif controlType == "heuristic"
    puts "Finding control heuristically.<br>"
    m2_result = `cd controlM2/; /usr/local/bin/M2 Visualizer.m2 --stop --no-debug --silent -q -e 'QR = makeControlRing(#{n_nodes}, #{u_nodes}, #{p_value}); F = matrix(QR, #{m2_system}); traj = first findControl(F, #{initialState}, #{finalState}, #{u_nodes}); exit 0'`

  elsif controlType == "best"
    puts "Finding optimal control.<br>"
    m2_result = `cd controlM2/; /usr/local/bin/M2 Visualizer.m2 --stop --no-debug --silent -q -e 'QR = makeControlRing(#{n_nodes}, #{u_nodes}, #{p_value}); F = matrix(QR, #{m2_system}); traj = first findOptimalControl(F, #{initialState}, #{finalState}, #{u_nodes});  exit 0'`

  else 
    puts "I don't understand this control type #{controlType}<br>"
    exit 1
  end
end
  
  
if m2_result == "" # empty only if M2 errored out  
  puts "There was a problem with the calculation. Sorry<br>"
  exit 1
end

results = m2_result.split("digraph")
if controlType == "heuristic" or controlType== "best"  
  puts "<font color=\"#226677\">The following control was applied: </font><br>"
  puts (results.first).gsub(/\n/, "<br>") 
end

if results.size == 2 
  tmpFile = "#{filePrefix}dot"
  File.open( tmpFile, 'w') {|f| f.write "digraph #{results.last}"}

  dotPath = `which dot`
  dotPath.chop!
  #puts "#{dotPath} -Tgif #{tmpFile} -o #{file}"
  `#{dotPath} -Tgif #{tmpFile} -o #{file}`
end

exit 0


