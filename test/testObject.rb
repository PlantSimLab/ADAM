require 'test/unit'


class MyObject
  attr_accessor :arr

  def initialize(arr)
    @arr = arr
  end

  def ==(other)
    return @arr == other
  end

  def [](index)
    return @arr[index]
  end

  def blubb 
    return "a"
  end
end

class TestObject < Test::Unit::TestCase
  def testEqual
    o = MyObject.new( [1,2,3] )
    
    assert_equal('a',  o.blubb)
    assert( [1,2,3] == [1,2,3] )
    assert_equal( [1,2,3], o.arr, "arrays are not equal")
    assert( o == [1,2,3] , "equality function not working")
    assert_equal( o, [1,2,3], "object not equal to array")
  end

  def testAccess
    o = MyObject.new( [1,2,3] )
    assert_equal(3, o[2])
    assert_equal('no', o[2])
  end
end
