require 'graph/base_extensions'
require 'graph/graphviz_dot'

class HashOfHash < DefaultInitHash
  def initialize(&initBlock)
    super do
      if initBlock
	DefaultInitHash.new(&initBlock)
      else
	Hash.new
      end
    end
  end
end

GraphLink = Struct.new("GraphLink", :from, :to, :info)
class GraphLink
  def inspect
    info_str = info ? info.inspect + "-" : ""
    "#{from.inspect}-#{info_str}>#{to.inspect}"
  end
end

class GraphTraversalException < Exception
  attr_reader :node, :links, :link_info
  def initialize(node, links, linkInfo)
    @node, @links, @link_info = node, links, linkInfo
    super(message)
  end

  def message
    "There is no link from #{@node.inspect} having info #{@link_info.inspect} (valid links are #{@links.inspect})"  
  end
  alias inspect message
end

class DirectedGraph
  # This is a memory expensive variant that manages several additional
  # information data structures to cut down on processing when the graph
  # has been built.

  attr_reader :links
  
  def initialize
    @link_map = HashOfHash.new {Array.new} # [from][to] -> array of links
    @links = Array.new # All links in one array
    @is_root = Hash.new # true iff root node
    @is_leaf = Hash.new # true iff leaf node
  end

  def nodes
    @is_root.keys
  end

  def add_node(node)
    unless include_node?(node)
      @is_root[node] = @is_leaf[node] = true
    end
  end

  def root?(node)
    @is_root[node]
  end

  def leaf?(node)
    @is_leaf[node]
  end

  def include_node?(node)
    @is_root.has_key?(node)
  end

  def links_from_to(from, to)
    @link_map[from][to]
  end    

  def links_from(node)
    @link_map[node].map {|to, links| links}.flatten
  end

  def children(node)
    @link_map[node].keys.select {|k| @link_map[node][k].length > 0}
  end

  # (Forced) add link will always add link even if there are already links 
  # between the nodes.
  def add_link(from, to, informationOnLink = nil)
    add_link_nodes(from, to)
    link = GraphLink.new(from, to, informationOnLink)
    links_from_to(from, to).push link
    add_to_links(link)
    link
  end

  def add_link_nodes(from, to)
    add_node(from)
    add_node(to)
    @is_leaf[from] = @is_root[to] = false
  end

  # Add link if not already linked
  def link_nodes(from, to, info = nil)
    links_from_to?(from, to) ? nil : add_link(from, to, info)
  end

  def links_from_to?(from, to)
    not links_from_to(from, to).empty?
  end
  alias linked? links_from_to?
  
  def add_to_links(link)
    @links.push link
  end
  private :add_to_links

  def each_reachable_node_once_depth_first(node, inclusive = true, &block)
    children(node).each do |c|
      recurse_each_reachable_depth_first_visited(c, Hash.new, &block)
    end
    block.call(node) if inclusive
  end
  alias each_reachable_node each_reachable_node_once_depth_first

  def recurse_each_reachable_depth_first_visited(node, visited, &block)    
    visited[node] = true
    children(node).each do |c|
      unless visited[c]
	recurse_each_reachable_depth_first_visited(c, visited, &block)
      end
    end
    block.call(node)
  end

  def each_reachable_node_once_breadth_first(node, inclusive = true, &block)
    block.call(node) if inclusive
    children(node).each do |c|
      recurse_each_reachable_breadth_first_visited(c, Hash.new, &block)
    end
  end
  alias each_reachable_node each_reachable_node_once_depth_first

  def recurse_each_reachable_breadth_first_visited(node, visited, &block)    
    visited[node] = true
    block.call(node)
    children(node).each do |c|
      unless visited[c]
	recurse_each_reachable_breadth_first_visited(c, visited, &block)
      end
    end
  end

  def root_nodes
    @is_root.reject {|key,val| val == false}.keys
  end
  alias_method :roots, :root_nodes

  def leaf_nodes
    @is_leaf.reject {|key,val| val == false}.keys
  end
  alias_method :leafs, :leaf_nodes

  def internal_node?(node)
    !root?(node) and !leaf?(node) 
  end

  def internal_nodes
    nodes.reject {|n| root?(n) or leaf?(n)}
  end

  def recurse_cyclic?(node, visited)
    visited[node] = true
    children(node).each do |c|
      return true if visited[c] || recurse_cyclic?(c, visited)
    end
    false
  end

  def cyclic?
    visited = Hash.new
    root_nodes.each {|root| return true if recurse_cyclic?(root, visited)}
    false
  end

  def acyclic?
    not cyclic?
  end

  def transition(state, linkInfo)
    link = links_from(state).detect {|l| l.info == linkInfo}
    begin
      link.to
    rescue Exception
      raise GraphTraversalException.new(state, links_from(state), linkInfo)
    end
  end

  def traverse(fromState, alongLinksWithInfo = [])
    state, len = fromState, alongLinksWithInfo.length
    alongLinksWithInfo = alongLinksWithInfo.clone
    while len > 0
      state = transition(state, alongLinksWithInfo.shift)
      len -= 1
    end
    state
  end

  def to_dot(nodeShaper = nil, nodeLabeler = nil, linkLabeler = nil)
    dgp = DotGraphPrinter.new(links, nodes)
    dgp.node_shaper = nodeShaper if nodeShaper
    dgp.node_labeler = nodeLabeler if nodeLabeler
    dgp.link_labeler = linkLabeler if linkLabeler
    dgp
  end

  def to_postscript_file(filename, nodeShaper = nil, nodeLabeler = nil, 
			 linkLabeler = nil)
    to_dot(nodeShaper, nodeLabeler, linkLabeler).write_to_file(filename)
  end

  # Floyd-Warshal algorithm which should be O(n^3) where n is the number of 
  # nodes. We can probably work a bit on the constant factors!
  def transitive_closure_floyd_warshal
    vertices = nodes
    tcg = DirectedGraph.new
    num_nodes = vertices.length

    # Direct links
    for k in (0...num_nodes)
      for s in (0...num_nodes)
	vk, vs = vertices[k], vertices[s]	
	if vk == vs
	  tcg.link_nodes(vk,vs)
	elsif linked?(vk, vs)
	  tcg.link_nodes(vk,vs)
	end
      end
    end

    # Indirect links
    for i in (0...num_nodes)
      for j in (0...num_nodes)
	for k in (0...num_nodes)
	  vi, vj, vk = vertices[i], vertices[j], vertices[k]
	  if not tcg.linked?(vi,vj)
	    tcg.link_nodes(vi, vj) if linked?(vi,vk) and linked?(vk,vj)
	  end
	end
      end
    end
    tcg
  end
  alias_method :transitive_closure, :transitive_closure_floyd_warshal

  def num_vertices
    @is_root.size
  end
  alias num_nodes num_vertices

  # strongly_connected_components uses the algorithm described in
  # following paper.
  # @Article{Tarjan:1972:DFS,
  #   author =       "R. E. Tarjan",
  #   key =          "Tarjan",
  #   title =        "Depth First Search and Linear Graph Algorithms",
  #   journal =      "SIAM Journal on Computing",
  #   volume =       "1",
  #   number =       "2",
  #   pages =        "146--160",
  #   month =        jun,
  #   year =         "1972",
  #   CODEN =        "SMJCAT",
  #   ISSN =         "0097-5397 (print), 1095-7111 (electronic)",
  #   bibdate =      "Thu Jan 23 09:56:44 1997",
  #   bibsource =    "Parallel/Multi.bib, Misc/Reverse.eng.bib",
  # }
  def strongly_connected_components
    order_cell = [0]
    order_hash = {}
    node_stack = []
    components = []

    order_hash.default = -1

    nodes.each {|node|
      if order_hash[node] == -1
        recurse_strongly_connected_components(node, order_cell, order_hash, node_stack, components)
      end
    }

    components
  end

  def recurse_strongly_connected_components(node, order_cell, order_hash, node_stack, components)
    order = (order_cell[0] += 1)
    reachable_minimum_order = order
    order_hash[node] = order
    stack_length = node_stack.length
    node_stack << node

    links_from(node).each {|link|
      nextnode = link.to
      nextorder = order_hash[nextnode]
      if nextorder != -1
        if nextorder < reachable_minimum_order
          reachable_minimum_order = nextorder
        end
      else
        sub_minimum_order = recurse_strongly_connected_components(nextnode, order_cell, order_hash, node_stack, components)
        if sub_minimum_order < reachable_minimum_order
          reachable_minimum_order = sub_minimum_order
        end
      end
    }

    if order == reachable_minimum_order
      scc = node_stack[stack_length .. -1]
      node_stack[stack_length .. -1] = []
      components << scc
      scc.each {|n|
        order_hash[n] = num_vertices
      }
    end
    return reachable_minimum_order;
  end
end

# Parallel propagation in directed acyclic graphs. Should be faster than 
# traversing all links from each start node if the graph is dense so that 
# many traversals can be merged.
class DagPropagator
  def initialize(directedGraph, startNodes, &propagationBlock)
    @graph, @block = directedGraph, propagationBlock
    init_start_nodes(startNodes)
    @visited = Hash.new
  end

  def init_start_nodes(startNodes)
    @startnodes = startNodes
  end

  def propagate
    @visited.clear
    propagate_recursive
  end

  def propagate_recursive
    next_start_nodes = Array.new
    @startnodes.each do |parent|
      @visited[parent] = true
      @graph.children(parent).each do |child|
	@block.call(parent, child)
	unless @visited[child] or next_start_nodes.include?(child)
	  next_start_nodes.push(child)
	end
      end
    end
    if next_start_nodes.length > 0
      @startnodes = next_start_nodes
      propagate_recursive
    end
  end
end

# Directed graph with fast traversal from children to parents (back)
class BackLinkedDirectedGraph < DirectedGraph
  def initialize(*args)
    super
    @back_link_map = HashOfHash.new {Array.new} # [to][from] -> array of links
    @incoming_links_info = DefaultInitHash.new {Array.new}
  end

  def add_link(from, to, informationOnLink = nil)
    link = super
    links_to_from(to, from).push link
    if informationOnLink and 
	!@incoming_links_info[to].include?(informationOnLink)
      @incoming_links_info[to].push informationOnLink
    end
    link
  end

  def incoming_links_info(node)
    @incoming_links_info[node]
  end

  def back_transition(node, backLinkInfo)
    link = links_to(node).detect {|l| l.info == backLinkInfo}
    begin
      link.from
    rescue Exception
      raise GraphTraversalException.new(node, links_to(node), backLinkInfo)
    end
  end

  def back_traverse(state, alongLinksWithInfo = [])
    len = alongLinksWithInfo.length
    alongLinksWithInfo = alongLinksWithInfo.clone
    while len > 0
      state = back_transition(state, alongLinksWithInfo.pop)
      len -= 1
    end
    state
  end

  def links_to(node)
    @back_link_map[node].map {|from, links| links}.flatten
  end

  protected

  def links_to_from(to, from)
    @back_link_map[to][from]
  end    
end

def calc_masks(start, stop, masks = Array.new)
  mask = 1 << start
  (start..stop).each {|i| masks[i] = mask; mask <<= 1}
  masks
end

class BooleanMatrix
  def initialize(objects)
    @index, @objects, @matrix = Hash.new, objects, Array.new 
    cnt = 0
    objects.each do |o| 
      @index[o] = cnt
      @matrix[cnt] = 0 # Use Integers to represent the booleans
      cnt += 1
    end
    @num_obects = cnt
  end

  @@masks_max = 1000
  @@masks = calc_masks(0,@@masks_max)

  def mask(index)
    mask = @@masks[index]
    unless mask
      calc_masks(@@masks_max+1, index, @@masks)
      mask = @masks[index]
    end
    mask
  end

  def or(index1, index2)
    @matrix[index1] |= @matrix[index2]
  end

  def indices(anInteger)
    index = 0
    while anInteger > 0
      yeild(index) if anInteger & 1
      anInteger >>= 1
      index += 1
    end
  end

  def directed_graph
    dg = Directedgraph.new
    @matrix.each_with_index do |v,i|
      indices(v) do |index|
	dg.link_nodes(@objects[i], @objects[index])
      end 
    end
    dg
  end

  def transitive_closure
    for i in (0..@num_obects)
      for j in (0..@num_obects)
	
      end
    end
  end
end
