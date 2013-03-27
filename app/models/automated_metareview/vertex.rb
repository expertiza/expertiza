class Vertex
  #attr_accessor auto creates the get and set methods for the following attributes
  attr_accessor :name, :type, :frequency, :index, :node_id, :state, :label, :parent, :pos_tag
  def initialize(vertex_name, vertex_type, index_value, state, lab, par, pos_tag)
    @name = vertex_name
    @type = vertex_type
    @frequency = 0
    @index = index_value
    @node_id = -1 #to identify if the id has been set or not
    @state = state #they are not negated by default
    
    #for semantic role labelling
    @label = lab
    @parent = par
    
    @pos_tag = pos_tag
  end
end
