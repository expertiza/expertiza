class DotGraphPrinter
  attr_accessor :orientation, :size, :color

  # The following can be set to blocks of code that gives a default
  # value for the node shapes, node labels and link labels, respectively.
  attr_accessor :node_shaper, :node_labeler, :link_labeler

  # A node shaper maps each node to a string describing its shape.
  # Valid shapes are: 
  #   "ellipse"   (default)
  #   "box"
  #   "circle"
  #   "plaintext" (no outline)
  #   "doublecircle"
  #   "diamond"
  # Not yet supported or untested once are:
  #   "polygon", "record", "epsf"
  @@default_node_shaper = proc{|n| "box"}

  @@default_node_labeler = proc{|n| 
    if Symbol===n
      n.id2name 
    elsif String===n
      n
    else
      n.inspect
    end
  }

  @@default_link_labeler = proc{|info| info ? info.inspect : nil}

  # links is either array of 
  #                   arrays [fromNode, toNode [, infoOnLink]], or
  #                   objects with attributes :from, :to, :info
  # nodes is array of node objects
  # All nodes used in the links are used as nodes even if they are not 
  # in the "nodes" parameters.
  def initialize(links = [], nodes = [])
    @links, @nodes = links, add_nodes_in_links(links, nodes)
    @node_attributes, @edge_attributes = Hash.new, Hash.new
    set_default_values
  end

  def set_default_values
    @color = "black"
    @size = "9,11"
    @orientation = "portrait"
    @node_shaper = @@default_node_shaper
    @node_labeler = @@default_node_labeler
    @link_labeler = @@default_link_labeler
  end

  def write_to_file(filename, fileType = "ps")
    dotfile = temp_filename(filename)
    File.open(dotfile, "w") {|f| f.write to_dot_specification}
    system "dot -T#{fileType} -o #{filename} #{dotfile}"
    File.delete(dotfile)
  end

  def set_edge_attributes(anEdge, aHash)
    # TODO check if attributes are valid dot edge attributes
    edge = find_edge(anEdge)
    set_attributes(edge, @edge_attributes, true, aHash)
  end

  def set_node_attributes(aNode, aHash)
    # TODO check if attributes are valid dot node attributes
    set_attributes(aNode, @node_attributes, true, aHash)
  end

  def to_dot_specification
    set_edge_labels(@links)
    set_node_labels_and_shape(@nodes)
    "digraph G {\n" +
      graph_parameters_to_dot_specification +
      @nodes.uniq.map {|n| format_node(n)}.join(";\n") + ";\n" +
      @links.uniq.map {|l| format_link(l)}.join(";\n") + ";\n" +
      "}"
  end

  protected

  def find_edge(anEdge)
    @links.each do |link|
      return link if source_and_dest(link) == source_and_dest(anEdge)
    end
  end

  def set_attributes(key, hash, override, newAttributeHash)
    h = hash[key] || Hash.new
    newAttributeHash = all_keys_to_s(newAttributeHash) 
    newAttributeHash.each do |k, value|
      h[k] = value unless h[k] and !override
    end
    hash[key] = h
  end

  def graph_parameters_to_dot_specification
    "graph [\n" + 
      (self.size ? "  size = #{@size.inspect},\n" : "") +
      (self.orientation ? "  orientation = #{@orientation},\n" : "") +
      (self.color ? "  color = #{@color}\n" : "") +
      "]\n"
  end

  def each_node_in_links(links)
    links.each do |l|
      src, dest = source_and_dest(l)
      yield src
      yield dest
    end
  end

  def add_nodes_in_links(links, nodes)
    new_nodes = []
    each_node_in_links(links) {|node| new_nodes.push node}
    (nodes + new_nodes).uniq
  end

  def all_keys_to_s(aHash)
    # MAYBE reuse existing hash?
    Hash[*(aHash.map{|p| p[0] = p[0].to_s; p}.flatten)]
  end

  def set_edge_labels(edges)
    edges.each do |edge|
      src, dest, info = get_link_data(edge)
      if info
	label = @link_labeler.call(info)
	set_attributes(edge, @edge_attributes, false, :label =>label) if label 
      end
    end
  end

  def set_node_labels_and_shape(nodes)
    nodes.each do |node|
      set_attributes(node, @node_attributes, false,
		     :label => @node_labeler.call(node).inspect,
		     :shape => @node_shaper.call(node).inspect)
    end
  end

  def get_link_data(link)
    begin
      return link.from, link.to, link.info
    rescue Exception
      return link[0], link[1], link[2]
    end
  end
  
  def source_and_dest(link)
    get_link_data(link)[0,2]
  end

  def format_attributes(attributes)
    return "" unless attributes
    strings = attributes.map {|a, v| "#{a}=#{v}"}
    strings.length > 0 ? (" [" + strings.join(", ") + "]") : ("")
  end

  def mangle_node_name(node)
    "n" + node.hash.abs.inspect
  end

  def format_link(link)
    from, to, info = get_link_data(link)
    mangle_node_name(from) + " -> " + mangle_node_name(to) + 
      format_attributes(@edge_attributes[link])
  end

  def format_node(node)
    mangle_node_name(node) + format_attributes(@node_attributes[node])
  end

  def temp_filename(base = "tmp")
    tmpfile = base + rand(100000).inspect
    while test(?f, tmpfile)
      tmpfile = base + rand(100000).inspect
    end
    tmpfile
  end
end
