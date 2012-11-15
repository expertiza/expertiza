require 'test_helper'
require 'automated_metareview/degree_of_relevance'
require 'automated_metareview/text_preprocessing'
require 'automated_metareview/graph_generator'

class DegreeOfRelevanceTest < ActiveSupport::TestCase
  attr_accessor :pos_tagger, :core_NLP_tagger, :review_vertices, :subm_vertices, :num_rev_vert, :num_sub_vert, :review_edges, :subm_edges, :num_rev_edg, :num_sub_edg, :speller
  def setup
    @pos_tagger = EngTagger.new
    @core_NLP_tagger =  StanfordCoreNLP.load(:tokenize, :ssplit, :pos, :lemma, :parse, :ner, :dcoref)
    #getting the review
    reviews = ["The sweet potatoes in the vegetable bin are green with mold. These sweet potatoes in the vegetable bin are fresh."]
    tc = TextPreprocessing.new
    reviews = tc.segment_text(0, reviews)
    #getting the submission  
    subms = ["The sweet potatoes in the vegetable bin are green with mold. These sweet potatoes in the vegetable bin are fresh."] 
    tc = TextPreprocessing.new
    subms = tc.segment_text(0, subms)
    #getting review details
    g = GraphGenerator.new
    g.generate_graph(reviews, pos_tagger, core_NLP_tagger, true, false)
    @review_vertices = g.vertices
    @review_edges = g.edges
    @num_rev_vert = g.num_vertices
    @num_rev_edg = g.num_edges
    g.print_graph(@review_edges, @review_vertices)
    #getting submission details
    g.generate_graph(subms, pos_tagger, core_NLP_tagger, true, false)
    @subm_vertices = g.vertices
    @subm_edges = g.edges
    @num_sub_vert = g.num_vertices
    @num_sub_edg = g.num_edges
    g.print_graph(@subm_edges, @subm_vertices)
    #initializing the speller
    @speller = Aspell.new("en_US")
    @speller.suggestion_mode = Aspell::NORMAL
  end
  
  test "compare vertices exact match" do
    #creating an instance of the degree of relevance class and calling the 'compare_vertices' method
    instance = DegreeOfRelevance.new
    assert_equal(6, instance.compare_vertices(@pos_tagger, @review_vertices, @subm_vertices, @num_rev_vert, @num_sub_vert, @speller))
  end
  
  test "compare edges non syntax diff exact match" do
    #creating an instance of the degree of relevance class and calling the 'compare_vertices' method
    instance = DegreeOfRelevance.new
    #call compare vertices to instantiate the vertex_match array, since this array is used by the compare edges method
    instance.compare_vertices(@pos_tagger, @review_vertices, @subm_vertices, @num_rev_vert, @num_sub_vert, @speller)
    assert_equal(6, instance.compare_edges_non_syntax_diff(@review_edges, @subm_edges, @num_rev_edg, @num_sub_edg))
  end
  
  test "compare edges syntax diff exact match" do
    #creating an instance of the degree of relevance class and calling the 'compare_vertices' method
    instance = DegreeOfRelevance.new
    #call compare vertices to instantiate the vertex_match array, since this array is used by the compare edges method
    instance.compare_vertices(@pos_tagger, @review_vertices, @subm_vertices, @num_rev_vert, @num_sub_vert, @speller)
    #since one of the vertices likely to match, while not the other, the match is likely to be less than or equal to 3
    assert(instance.compare_edges_syntax_diff(@review_edges, @subm_edges, @num_rev_edg, @num_sub_edg) <= 3)
  end
  
  test "compare edges diff types exact match" do
    #creating an instance of the degree of relevance class and calling the 'compare_vertices' method
    instance = DegreeOfRelevance.new
    #call compare vertices to instantiate the vertex_match array, since this array is used by the compare edges method
    instance.compare_vertices(@pos_tagger, @review_vertices, @subm_vertices, @num_rev_vert, @num_sub_vert, @speller)
    #since one of the vertices likely to match, while not the other, the match is likely to be less than or equal to 3
    assert(instance.compare_edges_diff_types(@review_edges, @subm_edges, @num_rev_edg, @num_sub_edg) <= 3)
  end
  
  test "compare SVO edges without syn exact match" do
    #creating an instance of the degree of relevance class and calling the 'compare_vertices' method
    instance = DegreeOfRelevance.new
    #call compare vertices to instantiate the vertex_match array, since this array is used by the compare edges method
    instance.compare_vertices(@pos_tagger, @review_vertices, @subm_vertices, @num_rev_vert, @num_sub_vert, @speller)
    assert_equal(6, instance.compare_SVO_edges(@review_edges, @subm_edges, @num_rev_edg, @num_sub_edg))
  end
  
  test "compare SVO edges diff syn exact match" do
    #creating an instance of the degree of relevance class and calling the 'compare_vertices' method
    instance = DegreeOfRelevance.new
    #call compare vertices to instantiate the vertex_match array, since this array is used by the compare edges method
    # puts "@num_rev_vert #{@num_rev_vert} .. @num_sub_vert #{@num_sub_vert}"
    instance.compare_vertices(@pos_tagger, @review_vertices, @subm_vertices, @num_rev_vert, @num_sub_vert, @speller)
    #due to different types of the vertices being compared, their cumulative double edge match = 0   
    assert_equal(0, instance.compare_SVO_diff_syntax(@review_edges, @subm_edges, @num_rev_edg, @num_sub_edg))
  end
end
