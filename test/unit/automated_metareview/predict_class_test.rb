require 'test_helper'
require 'automated_metareview/predict_class'
require 'automated_metareview/text_preprocessing'
require 'automated_metareview/graph_generator'
require 'automated_metareview/wordnet_based_similarity'
    
class PredictClassTest < ActiveSupport::TestCase
  attr_accessor :pos_tagger, :core_NLP_tagger, :wordnet, :g
  def setup
    @pos_tagger = EngTagger.new
    @core_NLP_tagger =  StanfordCoreNLP.load(:tokenize, :ssplit, :pos, :lemma, :parse, :ner, :dcoref)
    @wordnet = WordnetBasedSimilarity.new
    @g = GraphGenerator.new
  end
  
  # test "check compare edges" do
    # e1 =  Edge.new("adj-edge", 1)
    # e1.in_vertex = Vertex.new("sweet", 1, 1, 0, 1, 1, "JJ")
    # e1.out_vertex = Vertex.new("potatoes in vegetable bin", 1, 1, 0, 1, 1, "NN")
    # e2 =  Edge.new("noun-edge", 1)
    # e2.in_vertex = Vertex.new("Sweet", 1, 1, 0, 1, 1, "JJ") 
    # e2.out_vertex = Vertex.new("potatoes in vegetable bin", 1, 1, 0, 1, 1, "NN")
    # content_instance = PredictClass.new
    # #predcting class - last parameter is the number of classes
    # assert_equal(6, content_instance.compare_edges(e1, e2, @wordnet))      
  # end
#   
  # test "check compare edges 2" do
    # e1 =  Edge.new("adj-edge", 1)
    # e1.in_vertex = Vertex.new("potatoes in vegetable bin", 1, 1, 0, 1, 1, "NN")
    # e1.out_vertex = Vertex.new("are", 1, 1, 0, 1, 1, "VB")
    # e2 =  Edge.new("noun-edge", 1)
    # e2.in_vertex = Vertex.new("potatoes in vegetable bin", 1, 1, 0, 1, 1, "NN") 
    # e2.out_vertex = Vertex.new("are", 1, 1, 0, 1, 1, "VB")
    # content_instance = PredictClass.new
    # #predcting class - last parameter is the number of classes
    # assert_equal(6, content_instance.compare_edges(e1, e2, @wordnet))      
  # end
#   
  # test "check compare review with patterns" do
    # tc = TextPreprocessing.new
    # patterns = tc.read_patterns("test/unit/automated_metareview/patterns-test-1.csv", @pos_tagger)
    # reviews = ["The sweet potatoes in the vegetable bin are green with mold."]
    # g.generate_graph(reviews, @pos_tagger, @core_NLP_tagger, false, true)    
    # content_instance = PredictClass.new
    # #since each review edge has a matching pattern (6) and (#patterns - 1) non exact matching patterns. 
    # #Therefore we assume the worst match between the review edge and all the other non- exact patterns. Therefore sum = 6 and n = #patterns. Avg = sum/#patterns 
    # assert(content_instance.compare_review_with_patterns(g.edges, patterns, @wordnet) >= 6/patterns.length)
  # end
#   
  # test "check predict class with test-1 patterns file" do
    # pattern_files_array = ["test/unit/automated_metareview/patterns-test-1.csv"]
    # review_text = ["The sweet potatoes in the vegetable bin are green with mold."]   
    # content_instance = PredictClass.new
    # g.generate_graph(review_text, @pos_tagger, @core_NLP_tagger, false, true)
    # content_probs = content_instance.predict_classes(@pos_tagger, @core_NLP_tagger, review_text, g, pattern_files_array, pattern_files_array.length)
    # assert_equal(1, content_probs.length)
    # assert(content_probs[0] >= 1) #since the patterns in the second file are very different
  # end
  
  test "check predict class with test-2 file" do
    pattern_files_array = ["test/unit/automated_metareview/patterns-test-2.csv"]
    review_text = ["The sweet potatoes in the vegetable bin are green with mold."]   
    content_instance = PredictClass.new
    g.generate_graph(review_text, @pos_tagger, @core_NLP_tagger, false, true)
    content_probs = content_instance.predict_classes(@pos_tagger, @core_NLP_tagger, review_text, g, pattern_files_array, pattern_files_array.length)
    assert_equal(1, content_probs.length)
    assert(content_probs[0].round == 0) #since the patterns in the second file are very different
  end
  
  test "check predict class with multiple pattern files" do
    #s = File.read(File.join(RAILS_ROOT, "app/assets/some_text_file.txt"))
    pattern_files_array = ["test/unit/automated_metareview/patterns-test-1.csv",
                            "test/unit/automated_metareview/patterns-test-2.csv"]
    review_text = ["The sweet potatoes in the vegetable bin are green with mold."]   
    content_instance = PredictClass.new
    g.generate_graph(review_text, @pos_tagger, @core_NLP_tagger, false, true)
    content_probs = content_instance.predict_classes(@pos_tagger, @core_NLP_tagger, review_text, g, pattern_files_array, pattern_files_array.length)
    assert_equal(2, content_probs.length)
    assert(content_probs[0] >= 1) #4 patterns are present in the first file
    assert(content_probs[1] < 1) #since the patterns in the second file are very different
  end
  
  test "check compare reviews with patterns 2" do
    tc = TextPreprocessing.new
    patterns = tc.read_patterns("test/unit/automated_metareview/patterns-test-2.csv", @pos_tagger)
    reviews = ["The sweet potatoes in the vegetable bin are green with mold."]
    g.generate_graph(reviews, @pos_tagger, @core_NLP_tagger, false, true)    
    content_instance = PredictClass.new
    #since the patterns in the second file are very different
    assert(content_instance.compare_review_with_patterns(g.edges, patterns, @wordnet) < 1)
  end
end
