# take the partial information given by the user 
# and overwrite the reverse engineered information

require 'pp'
class PartialInput  

  # if the string given is good function data, return a hash with the functions for the variables listed, otherwise return nil
  def self.parse_into_hash s
    #puts "begin parse_into_hash"
    #puts ":#{s}:"
    functions = Hash.new
    function_list_state = false
    function_state = false
    good_line = false
    variable = 0
    s.each {|line|
      line.gsub!(/\s/, '')
      # we are assuming this is a correct line without checking the bounds for subscripts
      #when /^\s*f\d+\s*=\s*(x\d+(\s*\^\s*\d+)?|(0|1))\s*((\+|\*)\s*(x\d+(\s*\^\s*\d+)?|(0|1))\s*)*\s*$/
      if line.match /^f(\d+)=(.*)$/
        good_line = true
        variable = $1.to_i
        #puts "starting with variable #{variable}"
        functions[variable] = [] 
        line = $2
        function_state = true
      end
      if line.match /(\{)/
        good_line = true
        #puts "this should be {: #{$1}"
        #functions[variable] = functions[variable] + "{\n"
        function_list_state = true
      end
      if (function = line.match /(\-?((x\d+(\^\d+)?)|\d+)((\+|\*|\-)((x\d+(\^\d+)?)|\d+))*(\#0?\.\d+)?)/ )
        good_line = true
        f = line
        if !function[-1].nil? # with probability
          #puts "found probability"
          f = f.sub(/#/, " # ")
          f = line.match /(.*)(\#0?\.\d+)/
          #puts f
        end
        #puts "Found function #{f}"
        #puts function.to_s
        #pp function
        #puts variable
        if !function_state
          #puts "some error..." 
          return nil
        end
        functions[variable].push f
        #functions[variable] = functions[variable] + (function.to_s  +"\n")
        #puts "functions[variable]: #{functions[variable]}"
      end
      if line.match /\}\s*$/
        good_line = true
        if !function_list_state
          puts "there is a closing } without being opened before"
          return nil
        end
        #functions[variable] = functions[variable] + "}\n"
        function_list_state = false
        function_state = false
      end
      if line.match /^\s*$/ # empty lines are ok
        #puts "found an empty line"
        good_line = true
      end
    }
    if !good_line
      nil
    else 
      functions
    end
  end

  # overwrite all fi in multifile with functions[i]
  def self.overwrite_file(functions, myfile)
    m = parse_into_hash myfile
    
    #m = Hash.new
    #myfile.each_with_index{ |line, index|
    #  m[index] = line
    #}

    m.each{ |variable,function|
      if functions.has_key?(variable)
        m[variable] = functions[variable]
        puts "replaced m[#{variable}] with #{m[variable]}"
      end
    }
    pp m
    m.collect{ |k,v| "f#{k} = #{v}"}.to_s
  end
    
end
