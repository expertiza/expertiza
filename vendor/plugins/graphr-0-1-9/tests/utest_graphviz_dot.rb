# Unit test for file graphviz_dot.rb
#
# $Id: utest_graphviz_dot.rb,v 1.6 2001/11/16 04:54:46 feldt Exp $
#
# Copyright (c) 2001 Robert Feldt, feldt@ce.chalmers.se
# This is free software distributed under GPL. See LICENSE in top dir.
#
require 'runit/testcase'
require 'runit/testsuite'
require 'runit/cui/testrunner'

require 'graph/graphviz_dot'

class TestDotGraphPrinter < RUNIT::TestCase
  def test_initialize
    dgf = DotGraphPrinter.new
    assert_kind_of(DotGraphPrinter, dgf)
  end

  # TODO refactor
  def assert_dotgraph(dotGraph, 
		      expectedNodeAttributes = {},
		      expectedEdgeAttributes = {},
		      expectedParameters = nil)
    if expectedNodeAttributes
      expectedNodeAttributes = 
	replace_nodes_with_their_mangled_names(expectedNodeAttributes)
    end
    if expectedEdgeAttributes
      expectedEdgeAttributes = 
	replace_nodes_with_their_mangled_names(expectedEdgeAttributes, true)
    end
    lines = dotGraph.to_dot_specification.split("\n")
    assert_equals("digraph G {", lines[0])
    assert_equals("}", lines[-1])
    lines[1..-2].each do |line|
      if line =~ /(\w+)\s*->\s*(\w+)\s*(\[.*\])?/ && expectedEdgeAttributes
	source, dest = $1, $2
	expected = expectedEdgeAttributes[[source, dest]]
	if expected
	  if $3
	    attributes = $3[1..-2].split(/\s*,\s*/) 
	    assert_edge_attributes(expected, attributes)
	  else
	    assert(false, "There are no attributes but we expected #{expected.inspect}")
	  end
	end
      elsif line =~ /(\w+)\s+(\[.*\])?$/ && expectedNodeAttributes
	nodeid, attributes = $1, $2[1..-2].split(", ")
	assert_node_attributes(expectedNodeAttributes[nodeid], attributes)
      elsif line =~ /(\w+)\s*=\s*([\w\"]+)/ && expectedParameters
	parameter, value = $1, $2
	expected = expectedParameters[parameter]
	assert_equals(expected, $2) if expected
      end
    end
  end

  def assert_edge_attributes(expected, actualAttributes)
    actualAttributes.each do |attr|
      attr =~ /(\w+)\s*=\s*(\w+)/
      assert_equals(expected[$1], $2) if expected[$1]
    end
  end

  def mangle_node_name(node)
    "n" + node.hash.inspect
  end

  # The objects are referred to with their ids in the DotGraph, so we
  # must map them to ids.
  def replace_nodes_with_their_mangled_names(aHash, edges = false)
    h = Hash.new
    if edges
      aHash.each do |k, val| 
	k[0] = mangle_node_name(k[0])
	k[1] = mangle_node_name(k[1])
	h[k] = val
      end
    else
      aHash.each {|key, val| h[mangle_node_name(key)] = val}
    end
    h
  end

  def assert_node_attributes(expected, attributes)
    return unless expected
    attributes.each do |attr|
      attr =~ /(\w+)=([\w\"]+)/
      assert_equals(expected[$1], $2) if expected[$1]
    end
  end

  def test_format
    dgp = DotGraphPrinter.new([[1,2]])
    assert_dotgraph(dgp, {1 => {"shape" => '"box"', "label" => '"1"'},
		          2 => {"shape" => '"box"', "label" => '"2"'}})
  end

  def test_custom_node_shape
    dgp = DotGraphPrinter.new([[1,2]])
    dgp.node_shaper = proc{|n| n < 2 ? "doublecircle" : "ellipse"}
    assert_dotgraph(dgp, {1 => {"shape" => '"doublecircle"', "label" => '"1"'},
		          2 => {"shape" => '"ellipse"', "label" => '"2"'}})
  end

  def test_changing_orientation
    dgp = DotGraphPrinter.new([[1,2]])
    dgp.orientation = "portrait"
    assert_dotgraph(dgp, nil, nil, {"orientation" => "portrait"})

    dgp.orientation = "landscape"
    assert_dotgraph(dgp, nil, nil, {"orientation" => "landscape"})
  end

  def test_setting_edge_attributes
    # If we want a graph with arrows going up we can achieve this by
    #   * reversing all edges, and
    #   * adding an edge attribute "dir=back", which changes the direction
    #     of the arrow.
    #
    # This is the only way to acheive this according to the dot user manual
    # in section 2.4 on page 9.
    # 
    # Below is an example.
    #
    edges = [[1,2]]
    reversed_edges = edges.map {|e| e.reverse}
    dgp = DotGraphPrinter.new
    reversed_edges.each do |edge|
      dgp.set_edge_attributes(edge, "dir" => "back")
    end

    assert_dotgraph(dgp, nil, {[2,1] => {"dir" => "back"}})
  end

  def test_node_url_attribute
    dgp = DotGraphPrinter.new [[1,2]]
    dgp.set_node_attributes(1, :URL => "node1.html")
    assert_dotgraph(dgp, {1 => {"URL" => '"node1.html"'}})
  end

  def test_handles_negative_hash_values
    dgp = DotGraphPrinter.new [[-1,-2]]
    dgp.set_node_attributes(-11, :URL => "node1.html")
    assert_dotgraph(dgp, {-11 => {"URL" => '"node1.html"'}})
    assert_equals(nil, dgp.to_dot_specification =~ /n-\d+/)
  end
end

RUNIT::CUI::TestRunner.run(TestDotGraphPrinter.suite) if $0 == __FILE__
