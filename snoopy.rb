require 'rubygems'
require 'xmlsimple'
require 'mathn'

# an instance of this class represents a Petri Net

class Snoopy

  # Nodes, Transitions, Edges, and their counts
  attr_accessor :pValue
  attr_accessor :filename, :strippedFile, :config
  attr_accessor :petriNetClass
  attr_accessor :nNodes, :nTransitions, :nEdges
  attr_accessor :nodes, :edges, :transitions
  attr_accessor :variables
  attr_accessor :incidenceMatrix, :indicatorFunctions, :networks
  
  def initialize( filename, pValue )
    
    @pValue = nextPrime pValue

    @filename = filename
    parse()

    # Currently, we solely work with standard petri nets
    if (@petriNetClass != "Petri Net") 
      puts "Please use a Standard Petri Net. Other types of Petri Nets are not supported yet."
      exit 1
    end

    puts "Here comes a #{pValue -1}-bounded Petri net converted to a system of polynomials over F_#{@pValue}."
    # node id and variable index (from 1 to n)
    @variables = {}

    # for each transition, an indicator function
    @indicatorFunctions = []
    @networks = []

    assignIndexToIDs()
    #populateIncidenceMatrix()
    #makeIndicatorFunctions()
    #makeNetworks()
  end

  def printNames
    names = []
    @nodes.each_pair{ |id, v|
      var = @variables[id.to_i]
      name = v['attribute']['Name']['content'].strip
      names.push "x#{var} = #{name}" 
    }
    ret = ""
    names.each { |n|
      ret = ret + "#{n}\n"
    }
    ret
  end

  def simplifyFunction( input )
    functionList = ""
    input.each{ |function|
      functionList = functionList + "\"" + function + "\","
    }
    functionList.chop!
    ret = `/usr/local/bin/M2 indicatorFunc.m2 --stop --no-debug --silent -q -e 'simplify( {#{functionList}}, #{@pValue}, #{@nNodes}); exit 0'`
    ret.split( /\n/)
  end

  def assignIndexToIDs
    index = 1 
    @nodes.each_pair{ |id, v|
      @variables[id.to_i] = index
      index = index + 1
    }
  end

  def makeRow(pairs, multiplier)
    row = Array.new(@nNodes, 0) 
    pairs.each{ |pair|
      nodeID = pair.first
      edgeID = pair.last
      multiplicity = @edges[edgeID]['attribute']['Multiplicity']['content'].strip.to_i
      row[@variables[nodeID.to_i] - 1] = multiplier* multiplicity
    }
    row
  end

  def self.arrayAdd(a,b)
    if (a.size != b.size) 
      puts "There is a problem adding arrays that do not have the same length.  Exiting"
      exit 1
    end
    a.each_with_index { |value, i|
      a[i] = value + b[i]
    }
    a
  end

  # for each transition, make an array of functions
  def makeNetworks
    makeIndicatorFunctions()
    populateIncidenceMatrix()
    @transitions.keys.each_with_index { |id, index| 
      network = []
      c = @indicatorFunctions[index]
      at = @incidenceMatrix[index]
      for i in 1..@nNodes 
        addOn = "(#{c}) * #{at[i-1]}"
        f = "x#{i} + #{addOn}"
        network.push f
      end
      @networks.push simplifyFunction network
    }
  end

  # make the C(x) function
  def makeIndicatorFunctions 
    @transitions.keys.each { |id|
      # select all edges ending in this transition, then collect the IDs of the incoming nodes
      # inputs: [IDs of nodes, ID of edge]
      inputs = @edges.keys.select{ |k| @edges[k]['target'] == id }.collect{ |k| 
        [@edges[k]['source'], @edges[k]['attribute']['Multiplicity']['content'].strip.to_i ]
      }
      func = ""
      inputs.each { |pair| 
        nodeID = pair.first
        var = @variables[nodeID.to_i]
        multiplicity = pair.last
        ret = `/usr/local/bin/M2 indicatorFunc.m2 --stop --no-debug --silent -q -e 'indicatorF(#{multiplicity}, #{@pValue -1}, #{var}, #{@pValue}); exit 0'`
        func = func + "(#{ret.chop})*"
      }
      func.chop!
      @indicatorFunctions.push func
    }
    simplifyFunction @indicatorFunctions
  end 

  def populateIncidenceMatrix
    @incidenceMatrix=[]
    @transitions.keys.each { |id|
      # select all edges ending in this transition, then collect the IDs of the incoming nodes
      # inputs: [IDs of nodes, ID of edge]
      inputs = @edges.keys.select{ |k| @edges[k]['target'] == id }.collect{ |k| [@edges[k]['source'], k] }
      outputs = @edges.keys.select{ |k| @edges[k]['source'] == id }.collect{|k| [@edges[k]['target'], k] }
      row = Snoopy.arrayAdd( makeRow(inputs, -1), makeRow(outputs, 1))
      @incidenceMatrix.push row
    }
  end

  # return next largest prime number
  def nextPrime p 
    a = Prime.new
    a.each { |succ|
      if succ.to_i >= p.to_i 
        break
      end
    }
                
    a.instance_variable_get(:@primes).last
  end

  def parse 
    @strippedFile = stripGraphics
    @config = XmlSimple.xml_in(@strippedFile, { 'KeyAttr' => ['name', 'node', 'id'] })

    @petriNetClass = @config['netclass'].keys.to_s

    @nNodes = @config['nodeclasses'].first['nodeclass']['Place']['count'].to_i
    @nEdges = @config['edgeclasses'].first['edgeclass']['Edge']['count'].to_i
    @nTransitions = @config['nodeclasses'].first['nodeclass']['Transition']['count'].to_i

    @nodes = @config['nodeclasses'].first['nodeclass']['Place']['node']
    @edges = @config['edgeclasses'].first['edgeclass']['Edge']['edge']
    @transitions = @config['nodeclasses'].first['nodeclass']['Transition']['node']
  end

  # remove all graphics tags, they mess up content somehow
  def stripGraphics
    line_arr = File.readlines(self.filename)
    new_arr = []
    inGraphicsFlag = false
    line_arr.each do |line|

      if ( line =~ /^\s*<graphics/ )
        unless( line =~ /^\s*<graphics.*\/>\s*$/ )
          inGraphicsFlag = true
        end
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

    File.open(self.filename+".new", "w") do |f| 
      new_arr.each{|line| f.puts(line)}
    end

    return self.filename+".new"
  end
end
