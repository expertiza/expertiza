class Edge
  attr_accessor :edgeID, :type, :name, :index, :in_vertex, :out_vertex, :edge_match, :average_match, :frequency, :label
  
  def initialize(edge_name, edge_type)
    @name = edge_name
    @type = edge_type #1 - verb, 2 - adjective, 3-adverb 
    @average_match = 0.0 #initializing match to 0
    @frequency = 0  
    #initializing the number of matches for each metric value to 0
    @edge_match = Array.new
    @edge_match = [0, 0, 0, 0, 0]
  end
end