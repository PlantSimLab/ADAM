require 'test/unit'
require 'pp'
require 'tempfile'
require 'snoopy'
require 'fileutils'


# test functions related to Snoopy, i.e., Petri Nets
# ruby -I test test/testSnoopy.rb


# To-do List

# names of transitions
# if places aren't named, display warning
# shuffle result into PBN

class TestSnoopyPrime < Test::Unit::TestCase
  def testFindNextPrime
    @pn = Snoopy.new("erk.spped", 2)
    assert_equal( 2, @pn.pValue )

    @pn = Snoopy.new("erk.spped", 4)
    assert_equal( 5, @pn.pValue )

    @pn = Snoopy.new("erk.spped", 8)
    assert_equal( 11, @pn.pValue )
  end

  def testTooLargeBoundPrime
    @pn = Snoopy.new("erk.spped", 101)
    assert false
  end  

end


class TestSnoopyOpenSystem < Test::Unit::TestCase
  def setup
    @pn = Snoopy.new("pc_openSystem.spped", 2)
  end

  def testDummy 
    assert true
  end
end

class TestSnoopyErkPathway< Test::Unit::TestCase
  def setup
    @pn = Snoopy.new("erk.spped", 2)
  end

  def testNames
    assert_equal("x1 = RKIP-P\nx2 = MEK-PP_ERK\nx3 = RP\nx4 = Raf-1Star_RKIP_ERK-PP\nx5 = RKIP-P_RP\nx6 = MEK-PP\nx7 = Raf-1Star\nx8 = RKIP\nx9 = ERK\nx10 = Raf-1Star_RKIP\nx11 = ERK-PP\n", @pn.printNames())
  end

  def testFunctions
    @pn.makeNetworks()
    assert_equal(11, @pn.networks.size)
    f = @pn.networks
    expected = []
    expected.push [ 'x1', '0', 'x3', 'x4', 'x5', 'x2+x6', 'x7', 'x8', 'x9', 'x10', 'x2+x11']
    expected.push [ 'x1', 'x2', 'x3+x5', 'x4', '0', 'x6', 'x7', 'x5+x8', 'x9', 'x10', 'x11']
    expected.push [ 'x1', 'x2', 'x3', 'x4', 'x5', 'x6', 'x7*x8+x7', 'x7*x8+x8', 'x9', 'x7*x8+x10', 'x11']
    expected.push [ 'x1', 'x2', 'x3', 'x4', 'x5', 'x6', 'x7+x10', 'x8+x10', 'x9', '0', 'x11']
    expected.push [ 'x1', 'x2', 'x3', 'x10*x11+x4', 'x5', 'x6', 'x7', 'x8', 'x9', 'x10*x11+x10', 'x10*x11+x11']
    expected.push [ 'x1', 'x2', 'x3', '0', 'x5', 'x6', 'x7', 'x8', 'x9', 'x4+x10', 'x4+x11']
    expected.push [ 'x1', 'x6*x9+x2', 'x3', 'x4', 'x5', 'x6*x9+x6', 'x7', 'x8', 'x6*x9+x9', 'x10', 'x11']
    expected.push [ 'x1', '0', 'x3', 'x4', 'x5', 'x2+x6', 'x7', 'x8', 'x2+x9', 'x10', 'x11']
    expected.push [ 'x1+x5', 'x2', 'x3+x5', 'x4', '0', 'x6', 'x7', 'x8', 'x9', 'x10', 'x11']
    expected.push [ 'x1*x3+x1', 'x2', 'x1*x3+x3', 'x4', 'x1*x3+x5', 'x6', 'x7', 'x8', 'x9', 'x10', 'x11']
    expected.push [ 'x1+x4', 'x2', 'x3', '0', 'x5', 'x6', 'x4+x7', 'x8', 'x4+x9', 'x10', 'x11']

    

    assert_equal(expected, f)
  end

end


class TestSnoopyProducerConsumer < Test::Unit::TestCase
  def setup 
    @pn = Snoopy.new("procon_bounded.spped", 2)
  end

  def testTransitionNames
    #assert_equal(@pn.networks,  "produce")
  end


  def testFunctions
    @pn.makeNetworks()
    assert_equal(4, @pn.networks.size)

    f = @pn.networks
    expected = []
    expected.push ['0', 'x2', 'x3', 'x4', 'x5', 'x1+x6']
    expected.push ['x5*x6+x1', 'x5*x6+x2', 'x3', 'x4', 'x5*x6+x5', 'x5*x6+x6']
    expected.push ['x1', 'x2*x4+x2', 'x2*x4+x3', 'x2*x4+x4', 'x2*x4+x5', 'x6']
    expected.push ['x1', 'x2', '0', 'x3+x4', 'x5', 'x6' ]

    assert_equal(expected, f)
  end
end





class TestSnoopyNotStandard < Test::Unit::TestCase
  def testNotSupportedFile
    assert_raise(SystemExit) {
      @pn = Snoopy.new("extended.spept", 3)
    }
  end
end


class TestSnoopy2Transitions < Test::Unit::TestCase
  def setup
    @pn = Snoopy.new("2trans.spped", 3)
  end

  def testPrintNames
    assert_equal("x1 = Node3\nx2 = Node2\nx3 = Node1\nx4 = out\nx5 = in\n", @pn.printNames())
  end
  
  def testFullFunctions
    @pn.makeNetworks()
    assert_equal(2, @pn.networks.size)
    f = @pn.networks.first
    assert_equal( 5, f.size )
    assert_equal( 'x1', f[0] )
    assert_equal( 'x2', f[1])
    assert_equal( 'x3', f[2])
    assert_equal( '-x4^2+x4', f[3])
    assert_equal( 'x4^2+x5', f[4])
    
    f = @pn.networks.last
    assert_equal( 5, f.size )
    assert_equal( '-x2^2*x3^2+x2^2*x3+x1', f[0] )
    assert_equal( 'x2^2*x3^2-x2^2*x3+x2', f[1])
    assert_equal( '-x2^2*x3^2+x2^2*x3+x3', f[2])
    assert_equal( 'x4', f[3])
    assert_equal( 'x5', f[4])
  end
end

class TestSnoopyConstant < Test::Unit::TestCase
  def setup
    @pn = Snoopy.new("simpleConstant.spped", 3)
  end

  def testNumberOfPlaces 
    assert_equal(4, @pn.nNodes)
  end

  def testPrintNames
    assert_equal("x1 = Node3\nx2 = Node2\nx3 = Node1\nx4 = constantNode\n", @pn.printNames())
  end
  
  def testFullFunctions
    @pn.makeNetworks()
    f = @pn.networks.first
    assert_equal( 4, f.size )
    assert_equal( '-x2^2*x3^2+x2^2*x3+x1', f[0] )
    assert_equal( 'x2^2*x3^2-x2^2*x3+x2', f[1])
    assert_equal( '-x2^2*x3^2+x2^2*x3+x3', f[2])
    assert_equal( 'x4', f[3])
  end

end

class TestSnoopy < Test::Unit::TestCase
  def setup
    @pn = Snoopy.new("simple.spped", 3)
  end

  def testPetriNetClass
    assert_equal("Petri Net", @pn.petriNetClass)
  end
  
  def testStripGraphics
    assert( FileUtils.compare_file("stripTestControl.spped", @pn.strippedFile))
  end

  def testNewFilename
    f = @pn.stripGraphics
    assert_equal( "simple.spped.new", f)
    FileUtils.remove(f)
  end

  def testNumberOfPlaces 
    assert_equal(3, @pn.nNodes)
  end

  def testNumberOfTransitions
    assert_equal(1, @pn.nTransitions)
  end

  def testNumberOfEdges
    assert_equal(3, @pn.nEdges)
  end

  def testNodeNames
    names = []
    @pn.nodes.each_value{ |v|
      name = v['attribute']['Name']['content'].strip
      names.push name
    }
    assert_equal( ["Node1", "Node2", "Node3"], names.sort )
  end

  def testPrintNames
    assert_equal("x1 = Node3\nx2 = Node2\nx3 = Node1\n", @pn.printNames())
  end

  def testVariableId
    id = @pn.nodes.keys.first.to_i
    assert_equal(1, @pn.variables[id])
    assert_equal(3, @pn.variables[4159])
  end

  def test2DArray
    foo = [1,2,3,4]
    arr = []
    arr.push [1,2,3]
    assert_equal([[1,2,3]], arr)
    arr.push ['a', 'b']
    assert_equal([[1,2,3],['a','b']], arr)
    assert_equal('b', arr[1][1])
    assert_equal( 3, arr[0][2])

    assert_equal( [1,1,1], Array.new(3, 1) )
    assert_equal( [0,0,0], Array.new(@pn.nNodes, 0 ) )
  end


  def testSimplifyFunctions
    assert_equal( ['x1', 'x1^2', '0'], @pn.simplifyFunction( ['(x1)', '(x1)*(x1)', '3*x1']) ) 
  end

  def testSimplifyFunction
    assert_equal( ['x1'], @pn.simplifyFunction( '(x1)') ) 
    assert_equal( ['x1^2'], @pn.simplifyFunction( '(x1)*(x1)') ) 
    assert_equal( ['0'], @pn.simplifyFunction( '3*x1') ) 
  end

  # I manually tested the state space of these functions
  def testFullFunctions
    @pn.makeNetworks()
    f = @pn.networks.first
    assert_equal( '-x2^2*x3^2+x2^2*x3+x1', f[0] )
    assert_equal( 'x2^2*x3^2-x2^2*x3+x2', f[1])
    assert_equal( '-x2^2*x3^2+x2^2*x3+x3', f[2])
  end

  def testIncidenceMatrix
    @pn.populateIncidenceMatrix()
    assert_equal([[1,-1,-2]], @pn.incidenceMatrix) 
  end

  def testFindEdgeWeight
    assert(1, @pn.edges['4213']['attribute']['Multiplicity']['content'].strip.to_i)
  end

  def testMakeRow
   id = @pn.transitions.keys.first
   pairs = @pn.edges.keys.select{ |k| @pn.edges[k]['target'] == id }.collect{ |k| [@pn.edges[k]['source'], k] }
   row = @pn.makeRow( pairs, 17)
   assert_equal([0,17,34], row)
  end

  def testArrayAdd
    a = [2,4,6]
    b = [17, 3, 100]
    assert_equal( [19, 7, 106], Snoopy.arrayAdd(a,b) )
  end

  def testIndicatorFunction
    assert_equal( ['-x2^2*x3^2+x2^2*x3'], @pn.makeIndicatorFunctions() )
  end

end
