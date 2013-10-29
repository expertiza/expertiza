require 'runit/testcase'
require 'runit/testsuite'
require 'runit/cui/testrunner'

$testcases = []
prev_dir = Dir.pwd
module RUNIT
  class TestCase
    def TestCase.inherited(subclass)
      $testcases.push subclass
    end
  end
end

regexp = ARGV[0] ? eval(ARGV[0]) : nil

testfiles = Dir["tests/utest*_*.rb"] + Dir["tests/test*_*.rb"] +
  Dir["tests/atest*_*.rb"] + Dir["tests/*test*_*.rb"]
testfiles = testfiles.select{|n| regexp.match(n)} if regexp
testfiles.each {|f| require f}

if $0 == __FILE__
  testrunner = RUNIT::CUI::TestRunner.new
  suite = RUNIT::TestSuite.new
  $testcases.each {|tc| suite.add_test(tc.suite)}
  testrunner.run(suite)
end
