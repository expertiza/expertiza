load 'test/test_helper.rb'
require 'automated_metareview/wordnet_based_similarity'
require 'automated_metareview/degree_of_relevance'
require 'automated_metareview/text_preprocessing'
require 'automated_metareview/graph_generator'

class Deg_rel_setup

  attr_accessor :vertex_match, :pos_tagger, :core_NLP_tagger, :review_vertices, :subm_vertices, :num_rev_vert, :num_sub_vert, :review_edges, :subm_edges, :num_rev_edg, :num_sub_edg, :speller
  def setup
   # @vertex_match =Array.new(:num_rev_vert){Array.new}
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
    #@speller = Aspell.new("en")
    @speller=FFI::Aspell::Speller.new('en_US')
    @speller.suggestion_mode = Aspell::NORMAL
  end
end

