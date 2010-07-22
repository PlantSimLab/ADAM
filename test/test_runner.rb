require 'test/unit'
require 'tempfile'

# test that control_runner.rb interfaces well with M2 code 
# run with 
# ruby -I test test/test_runner.rb


class TestRunner < Test::Unit::TestCase
  

  def get_tmp_filename
    f = Tempfile.new("gif")
    tmpfilename = f.path
    f.close!
    tmpfilename
  end

  def test_expect_broken 
    `ruby control_runner.rb 2 2 2 "f1 = x1+x2*u1
    f2 = x2+u1" test.gif 0_0_0 "1 1"`
    ret = $?.exitstatus
    #puts "This should be 1 #{ret}"
    assert ret == 1
    
    `ruby control_runner.rb`
    assert $?.exitstatus == 1
  end
 
  def test_nothing
    tmpfilename = get_tmp_filename
    `ruby control_runner.rb 2 2 2 "f1 = x1+x2*u1
    f2 = x2+u1" #{tmpfilename} nothing 0_0 1_1`
    assert $?.exitstatus == 0
    assert File.exists? tmpfilename

    `ruby control_runner.rb 2 2 2 "f1 = x1+x2*u1
    f2 = x2+u1" test.gif nothing `
    assert $?.exitstatus == 0
  end

  def test_given
    `ruby control_runner.rb 2 2 2 "f1 = x1+x2*u1
    f2 = x2+u1" test.gif given 0_0 "1 1"`
    ret = $?.exitstatus
    #puts "This should be 0 #{$?}"
    assert ret == 0
  end
  
  def test_heuristic
    `ruby control_runner.rb 2 2 2 "f1 = x1+x2*u1
    f2 = x2+u1" test-heuristic.gif heuristic 0_0 1_1`
    assert $?.exitstatus == 0
  end
  
  def test_optimal
    `ruby control_runner.rb 2 2 2 "f1 = x1+x2*u1
    f2 = x2+u1" test-best.gif best 0_0 1_1`
    assert $?.exitstatus == 0
  end

end
