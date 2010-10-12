
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


class TestSnoopyJoachim < Test::Unit::TestCase
  def setup
    @pn = Snoopy.new("example1.spped", 2)
  end

  def testPrintNames
    assert_equal("x1 = \nx2 = \n", @pn.printNames())
  end
  
  def testNumberOfPlaces 
    assert_equal(2, @pn.nNodes)
  end
  
  def testPetriNetClass
    assert_equal("Petri Net", @pn.petriNetClass)
  end
  
  def testNumberOfTransitions
    assert_equal(2, @pn.nTransitions)
  end
  
  def testNumberOfEdges
    assert_equal(4, @pn.nEdges)
  end

  def testFullFunctions
    @pn.makeNetworks()
    f = @pn.networks.first
    assert_equal( 'x1+x2', f[0] )
    assert_equal( '0', f[1])
    
    f = @pn.networks[1]
    assert_equal( 'x1+x2', f[1] )
    assert_equal( '0', f[0])
  end
end
