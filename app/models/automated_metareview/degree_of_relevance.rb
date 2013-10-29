require 'automated_metareview/wordnet_based_similarity'
require 'automated_metareview/graph_generator'

class DegreeOfRelevance
#creating accessors for the instance variables
attr_accessor :vertex_match
attr_accessor :review

=begin
  Identifies relevance between a review and a submission
=end
  #double dimensional arrays that contain the submissions and the reviews respectively
def get_relevance(reviews, submissions, num_reviews, pos_tagger, core_NLP_tagger, speller)
    review_vertices = nil
    review_edges = nil
    subm_vertices = nil
    subm_edges = nil
    num_rev_vert = 0
    num_rev_edg = 0
    num_sub_vert = 0
    numSubEdg = 0
    vert_match = 0.0
    edge_without_syn = 0.0
    edge_with_syn = 0.0
    edge_diff_type = 0.0
    double_edge = 0.0
    double_edge_with_syn = 0.0
  
    #since Reviews and Submissions "should" contain the same number of records review - submission pairs
    g = GraphGenerator.new
    #generating review's graph
    g.generate_graph(reviews, pos_tagger, core_NLP_tagger, true, false)
    review_vertices = g.vertices
    review_edges = g.edges
    num_rev_vert = g.num_vertices
    num_rev_edg = g.num_edges
    
    #assigning graph as a review graph to use in content classification
    @review = g.clone
      
    #generating the submission's graph
    g.generate_graph(submissions, pos_tagger, core_NLP_tagger, true, false)
    subm_vertices = g.vertices
    subm_edges = g.edges
    num_sub_vert = g.num_vertices
    num_sub_edg = g.num_edges

    compareVerticesObj = CompareGraphVertices.new
    compareSVOEdgesObj =  CompareGraphSVOEdges.new
    compareEdgesObj = CompareGraphEdges.new
    @vertex_match, vert_match = compareVerticesObj.compare_vertices(@vertex_match, pos_tagger, review_vertices,
                                                                    subm_vertices, num_rev_vert, num_sub_vert, speller)

    if(num_rev_edg > 0 and num_sub_edg > 0)
      @vertex_match, edge_without_syn =
          compareEdgesObj.compare_edges_non_syntax_diff(@vertex_match, review_edges, subm_edges,num_rev_edg, num_sub_edg)
      @vertex_match, edge_with_syn =
          compareEdgesObj.compare_edges_syntax_diff(@vertex_match, review_edges, subm_edges,num_rev_edg, num_sub_edg)
      @vertex_match, edge_diff_type =
          compareEdgesObj.compare_edges_diff_types(@vertex_match, review_edges, subm_edges,num_rev_edg, num_sub_edg)
      edge_match = (edge_without_syn.to_f + edge_with_syn.to_f )/2.to_f #+ edge_diff_type.to_f
      @vertex_match, double_edge =
          compareSVOEdgesObj.compare_SVO_edges(review_edges, subm_edges,num_rev_edg, num_sub_edg)
      @vertex_match, double_edge_with_syn =
          compareSVOEdgesObj.compare_SVO_diff_syntax(review_edges, subm_edges,num_rev_edg, num_sub_edg)
      double_edge_match = (double_edge.to_f + double_edge_with_syn.to_f)/2.to_f
    else
      edge_match = 0
      double_edge_match = 0
    end
      
    #differently weighted cases
    #tweak this!!
    alpha = 0.55
    beta = 0.35
    gamma = 0.1 #alpha > beta > gamma

    #case1's value will be in the range [0-6] (our semantic values)
    relevance = (alpha.to_f * vert_match.to_f) + (beta * edge_match.to_f) + (gamma * double_edge_match.to_f)
    scaled_relevance = relevance.to_f/6.to_f #scaled from [0-6] in the range [0-1]

    return scaled_relevance
end


#------------------------------------------#------------------------------------------
=begin  
   SR Labels and vertex matches are given equal importance
   * Problem is even if the vertices didn't match, the SRL labels would cause them to have a high similarity.
   * Consider "boy - said" and "chocolate - melted" - these edges have NOMATCH for vertices, but both edges
   * have the same label "SBJ" and would get an EXACT match,
   * resulting in an avg of 3! This cant be right!
   * We therefore use the labels to only decrease the match value found from vertices,i.e., if the labels were different
   * Match value will be left as is, if the labels were the same.
=end
  def compare_labels(edge1, edge2)
    if(((!edge1.label.nil? && !edge2.label.nil?) &&(edge1.label.downcase == edge2.label.downcase)) ||
        (edge1.label.nil? and edge2.label.nil?))
      result = EQUAL
    else
      result = DISTINCT
    end
    return result
  end # end of method
end