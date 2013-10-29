require 'runit/testcase'
require 'runit/testsuite'
require 'runit/cui/testrunner'
require 'runit/topublic'
include RUNIT::ToPublic

require 'graph/directed_graph'

class TestDirectedGraph < RUNIT::TestCase
  def setup
    @dg = DirectedGraph.new
    [[1,2],[2,3],[3,2],[2,4]].each_with_index do |(src,dest),i| 
      @dg.add_link(src, dest, i)
    end
  end

  def test_initialize
    assert_kind_of(DirectedGraph, @dg)
  end

  def test_links
    assert_equals(4, @dg.links.length)
    assert_equals([1,2,2,3], @dg.links.map {|l| l.from}.sort)
    assert_equals([2,2,3,4], @dg.links.map {|l| l.to}.sort)
    assert_equals([0,1,2,3], @dg.links.map {|l| l.info}.sort)
  end

  def test_nodes
    assert_equals([1,2,3,4], @dg.nodes.sort)
  end

  def test_root?
    assert_equals(true, @dg.root?(1))
    assert_equals(false, @dg.root?(2))
    assert_equals(false, @dg.root?(3))
    assert_equals(false, @dg.root?(4))
  end

  def test_roots
    assert_equals([1], @dg.roots)
  end

  def test_leaf?
    assert_equals(false, @dg.leaf?(1))
    assert_equals(false, @dg.leaf?(2))
    assert_equals(false, @dg.leaf?(3))
    assert_equals(true, @dg.leaf?(4))
  end

  def test_leafs
    assert_equals([4], @dg.leafs)
  end

  def test_internal_nodes
    assert_equals([2,3], @dg.internal_nodes.sort)
  end

  def test_acyclic?
    assert_equals(false, @dg.acyclic?)

    dg = DirectedGraph.new
    [[1,2],[2,3],[2,4]].each {|f,t| dg.add_link(f,t)}
    assert_equals(true, dg.acyclic?)
  end

  def test_cyclic?
    assert_equals(true, @dg.cyclic?)

    dg = DirectedGraph.new
    [[1,2],[2,3],[2,4]].each {|f,t| dg.add_link(f,t)}
    assert_equals(false, dg.cyclic?)
  end

  def test_each_reachable_node_once_depth_first
    # Test inclusive visit
    visited_nodes = Array.new
    @dg.each_reachable_node_once_depth_first(1) {|n| visited_nodes.push(n)}
    assert_equals(4, visited_nodes.length)
    assert_equals([3,4], visited_nodes[0..1].sort)
    assert_equals([2,1], visited_nodes[2..3])

    # Test exclusive visit
    visited_nodes.clear
    @dg.each_reachable_node_once_depth_first(1, false) do |n| 
      visited_nodes.push(n)
    end
    assert_equals(3, visited_nodes.length)
    assert_equals([3,4], visited_nodes[0..1].sort)
    assert_equals([2], visited_nodes[2..2])
  end

  def test_each_reachable_node_once_breadth_first
    # Test inclusive visit
    visited_nodes = Array.new
    @dg.each_reachable_node_once_breadth_first(1) {|n| visited_nodes.push(n)}
    assert_equals(4, visited_nodes.length)
    assert_equals([1,2], visited_nodes[0..1])
    assert_equals([3,4], visited_nodes[2..3].sort)

    # Test exclusive visit
    visited_nodes.clear
    @dg.each_reachable_node_once_breadth_first(1, false) do |n| 
      visited_nodes.push(n)
    end
    assert_equals(3, visited_nodes.length)
    assert_equals([3,4], visited_nodes[1..2].sort)
    assert_equals([2], visited_nodes[0..0])
  end

  def test_link_from_to
    assert_equals(1, @dg.links_from_to(1,2).length)
    assert_equals(1, @dg.links_from_to(2,3).length)
    assert_equals(1, @dg.links_from_to(3,2).length)
    assert_equals(1, @dg.links_from_to(2,4).length)
    assert_equals(0, @dg.links_from_to(4,2).length)
    assert_equals(0, @dg.links_from_to(4,1).length)
    assert_equals(0, @dg.links_from_to(2,1).length)
    assert_equals(0, @dg.links_from_to(3,1).length)
  end

  def test_link_from_to?
    assert_equals(true, @dg.links_from_to?(1,2))
    assert_equals(true, @dg.links_from_to?(2,3))
    assert_equals(true, @dg.links_from_to?(3,2))
    assert_equals(true, @dg.links_from_to?(2,4))
    assert_equals(false, @dg.links_from_to?(2,1))
    assert_equals(false, @dg.links_from_to?(3,1))
    assert_equals(false, @dg.links_from_to?(4,1))
    assert_equals(false, @dg.links_from_to?(4,2))
  end

  def test_link_nodes
    len = @dg.links.length
    @dg.link_nodes(1,2)
    assert_equals(len, @dg.links.length)
    @dg.link_nodes(1,4)
    assert_equals(len+1, @dg.links.length)
  end

  def temp_filename(suffix = "", prefix = "tmp")
    filename = prefix + rand(100000).inspect + suffix
    while test(?f, filename)
      filename = prefix + rand(100000).inspect + suffix
    end
    filename
  end

  def test_to_dot
    d = @dg.to_dot
    assert_kind_of(DotGraphPrinter, d)
    d.write_to_file(filename = temp_filename(".ps"))
    assert(test(?f, filename))
    File.delete(filename)
  end

  def test_to_postscript_file
    filename = temp_filename(".ps")
    d = @dg.to_postscript_file(filename)
    assert(test(?f, filename))
    File.delete(filename)
  end

  def test_transition
    assert_equals(2, @dg.transition(1, 0))
    assert_equals(3, @dg.transition(2, 1))
    assert_equals(2, @dg.transition(3, 2))
    assert_equals(4, @dg.transition(2, 3))
    assert_exception(GraphTraversalException) {@dg.transition(2,-1)}
  end

  def test_traverse
    assert_equals(4, @dg.traverse(1,[0,3]))
    assert_equals(3, @dg.traverse(1,[0,1]))
    assert_equals(2, @dg.traverse(1,[0,1,2]))
    assert_equals(4, @dg.traverse(1,a = [0,1,2,3]))
    assert_equals([0,1,2,3], a)
    assert_equals(1, @dg.traverse(1,[]))
    assert_exception(GraphTraversalException) {@dg.traverse(1,[0,1,2,-1])}
  end

  DecoratedNode = Struct.new("DecoratedNode", :num, :set)

  def test_propagation
    dg = DirectedGraph.new
    nodes = Hash.new
    [1,2,3,4].each {|n| nodes[n] = DecoratedNode.new(n,[n])}
    [[1,2],[2,3],[3,2],[2,4]].each_with_index do |ft,i| 
      dg.add_link(nodes[ft[0]], nodes[ft[1]], i)
    end
    prop = DagPropagator.new(dg, dg.roots) {|p, c| c.set |= p.set}
    prop.propagate
    nodes = dg.nodes.sort {|n1, n2| n1.num <=> n2.num}
    assert_equals([1], nodes[0].set)
    assert_equals([1,2,3], nodes[1].set.sort)
    assert_equals([1,2,3], nodes[2].set.sort)
    # Note that cycles are not correctly handled! If they were the set below
    # should be [1,2,3,4]!
    assert_equals([1,2,4], nodes[3].set.sort)
  end

  def test_transitive_closure
    tcg = @dg.transitive_closure
    assert_kind_of(DirectedGraph, tcg)
    assert_equals([1,2,3,4], tcg.children(1).sort)
    assert_equals([2,3,4], tcg.children(2).sort)
    assert_equals([2,3,4], tcg.children(3).sort)
    assert_equals([4], tcg.children(4).sort)
  end

  def test_num_vertices
    assert_equals(4, @dg.num_vertices)
  end

  def test_strongly_connected_components
    components = @dg.strongly_connected_components
    assert_equal(3, components.length)
    assert_equal([[4], [2, 3], [1]], components.map {|ns| ns.sort})
  end
end

RUNIT::CUI::TestRunner.run(TestDirectedGraph.suite) if $0 == __FILE__
