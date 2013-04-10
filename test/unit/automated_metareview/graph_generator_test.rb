require 'test_helper'

class GraphgeneratorTest < ActiveSupport::TestCase
  attr_accessor :pos_tagger, :core_NLP_tagger, :tc, :instance
  def setup  
    @pos_tagger = EngTagger.new
    @core_NLP_tagger =  StanfordCoreNLP.load(:tokenize, :ssplit, :pos, :lemma, :parse, :ner, :dcoref)
    require 'automated_metareview/text_preprocessing'
    @tc = TextPreprocessing.new
    require 'automated_metareview/graph_generator'
    @instance = GraphGenerator.new
  end
  
  test "Number Of Vertices Generated 1" do
    #creating a test review array
    train_reviews = ["Parallel lines never meet."]
    train_reviews = @tc.segment_text(0, train_reviews)
    @instance.generate_graph(train_reviews, @pos_tagger, @core_NLP_tagger, false, false)
    assert_equal(4, @instance.num_vertices)
  end  
  
  test "Contents Of Vertices Generated 1" do
    #creating a test review array
    train_reviews = ["Parallel lines never meet."]
    train_reviews = @tc.segment_text(0, train_reviews)
    @instance.generate_graph(train_reviews, @pos_tagger, @core_NLP_tagger, false, false)
    #checking content of the vertices
    assert_equal("parallel", @instance.vertices[0].name.downcase)
    assert_equal("lines", @instance.vertices[1].name.downcase)
    assert_equal("never", @instance.vertices[2].name.downcase)
    assert_equal("meet", @instance.vertices[3].name.downcase)
  end
  
  #Testing with longer review, with two sentences and duplicate token vertices
  test "Number Of Vertices Generated 2" do
    #review array
    train_reviews = ["The sweet potatoes in the vegetable bin are green with mold. These sweet potatoes in the vegetable bin are fresh."]
    train_reviews = @tc.segment_text(0, train_reviews)
    @instance.generate_graph(train_reviews, @pos_tagger, @core_NLP_tagger, false, false)
    assert_equal(9, @instance.num_vertices) #since vertices in different sentences are treated different.
  end
  
  test "Contents Of Vertices Generated 2" do
    #review array
    train_reviews = ["The sweet potatoes in the vegetable bin are green with mold. These sweet potatoes in the vegetable bin are fresh."]
    train_reviews = @tc.segment_text(0, train_reviews)
    @instance.generate_graph(train_reviews, @pos_tagger, @core_NLP_tagger, false, false)
    #checking content of the vertices
    assert_equal("sweet", @instance.vertices[0].name.downcase)
    assert_equal("potatoes in vegetable bin", @instance.vertices[1].name.downcase)
    assert_equal("are", @instance.vertices[2].name.downcase)
    assert_equal("green", @instance.vertices[3].name.downcase)#"green" was an adjective
    assert_equal("with mold", @instance.vertices[4].name.downcase)
    assert_equal("sweet", @instance.vertices[5].name.downcase)
    assert_equal("potatoes in vegetable bin", @instance.vertices[6].name.downcase)
    assert_equal("are", @instance.vertices[7].name.downcase)
    assert_equal("fresh", @instance.vertices[8].name.downcase)
  end
  
  test "Number Of Vertices Generated 3" do
    #review array
    train_reviews = ["The sweet potatoes in the vegetable bin are green with mold. These sweet potatoes in the vegetable bin are fresh."]
    train_reviews = @tc.segment_text(0, train_reviews)
    @instance.generate_graph(train_reviews, @pos_tagger, @core_NLP_tagger, false, false)
    #checking content of the vertices
    assert_equal(9, @instance.num_vertices)
  end
  
  test "Number Of Edges Generated 1" do
    #review array      
    train_reviews = ["Parallel lines never meet."]
    train_reviews = @tc.segment_text(0, train_reviews)
    @instance.generate_graph(train_reviews, @pos_tagger, @core_NLP_tagger, false, false)
    assert_equal(3, @instance.num_edges)
  end
  
  test "Contents Of Edges Generated 1" do
    #review array
    train_reviews = ["Parallel lines never meet."]
    train_reviews = @tc.segment_text(0, train_reviews)
    @instance.generate_graph(train_reviews, @pos_tagger, @core_NLP_tagger, false, false)
    #noun-adjective
    assert_equal("parallel", @instance.edges[0].in_vertex.name.downcase)
    assert_equal("lines", @instance.edges[0].out_vertex.name.downcase)
    #verb-adverbs before verb-nouns
    assert_equal("never", @instance.edges[1].in_vertex.name.downcase)
    assert_equal("meet", @instance.edges[1].out_vertex.name.downcase)
    #verb-nouns
    assert_equal("lines", @instance.edges[2].in_vertex.name.downcase)
    assert_equal("meet", @instance.edges[2].out_vertex.name.downcase)
  end
  
  test "Number Of Edges Generated 2" do
    #review array 
    train_reviews = ["The sweet potatoes in the vegetable bin are green with mold."]
    train_reviews = @tc.segment_text(0, train_reviews)
    @instance.generate_graph(train_reviews, @pos_tagger, @core_NLP_tagger, false, false)     
    assert_equal(4, @instance.num_edges)
  end
  
  test "Contents Of Edges Generated 2" do
    #review array 
    train_reviews = ["The sweet potatoes in the vegetable bin are green with mold."]
    train_reviews = tc.segment_text(0, train_reviews)
    instance.generate_graph(train_reviews, pos_tagger, core_NLP_tagger, false, false)  
    #assertions
    assert_equal("sweet", instance.edges[0].in_vertex.name.downcase)
    assert_equal("potatoes in vegetable bin", instance.edges[0].out_vertex.name.downcase)
    #noun-verbs
    assert_equal("potatoes in vegetable bin", instance.edges[1].in_vertex.name.downcase)
    assert_equal("are", instance.edges[1].out_vertex.name.downcase)
    #adjective-noun before verb-nouns
    assert_equal("green", instance.edges[2].in_vertex.name.downcase)
    assert_equal("with mold", instance.edges[2].out_vertex.name.downcase)
    #verb-object
    assert_equal("are", instance.edges[3].in_vertex.name.downcase)
    assert_equal("with mold", instance.edges[3].out_vertex.name.downcase)
  end
  
  #Testing Number of Edges when they repeat
  test "Edges Which Repeat" do
    #review array   
    train_reviews = ["The sweet potatoes in the vegetable bin are green with mold. These sweet potatoes in the vegetable bin are fresh."]
    train_reviews = tc.segment_text(0, train_reviews)
    instance.generate_graph(train_reviews, pos_tagger, core_NLP_tagger, false, false)
    #assertions
    assert_equal(5, instance.num_edges)
  end
  
  test "Frequency Of Edges 1" do
    #review array
    train_reviews = ["The sweet potatoes in the vegetable bin are green with mold.", "These sweet potatoes in the vegetable bin are fresh."]
    train_reviews = tc.segment_text(0, train_reviews)
    number_edges = instance.generate_graph(train_reviews, pos_tagger, core_NLP_tagger, false, false)
    #assertions
    assert_equal(1, instance.edges[0].frequency)
    assert_equal(1, instance.edges[1].frequency)
    assert_equal(0, instance.edges[2].frequency)
    assert_equal(0, instance.edges[3].frequency)
    assert_equal(0, instance.edges[4].frequency)
    assert_equal(5, number_edges)
  end
  
  #with repetition in edges.
  test "Frequency Of Edges 2" do
    #review array
    train_reviews = ["The sweet potatoes in the vegetable bin are green with mold.These sweet potatoes in the vegetable bin are fresh. " +
          "These sweet potatoes in the vegetable bin are fresh."]
    train_reviews = tc.segment_text(0, train_reviews)
    #puts "train_reviews.length = #{train_reviews.length}"
    instance.generate_graph(train_reviews, pos_tagger, core_NLP_tagger, false, false)
    #number of edges
    assert_equal(5, instance.num_edges)
    #checking frequency, all frequencies are 0 since they are all from the same text
    assert_equal(2, instance.edges[0].frequency)
    assert_equal(2, instance.edges[1].frequency)
    assert_equal(0, instance.edges[2].frequency)
    assert_equal(0, instance.edges[3].frequency)
    assert_equal(1, instance.edges[4].frequency)
  end
  
  test "Frequency Of Edges 2 Different Texts" do
    #review array
    train_reviews = ["The sweet potatoes in the vegetable bin are green with mold.","These sweet potatoes in the vegetable bin are fresh. ",
        "These sweet potatoes in the vegetable bin are fresh."]
    train_reviews = tc.segment_text(0, train_reviews)
    instance.generate_graph(train_reviews, pos_tagger, core_NLP_tagger, false, false)
    #number of edges
    assert_equal(5, instance.num_edges)
    #checking frequency
    assert_equal(2, instance.edges[0].frequency)#sweet - potatoes in vegetable bin
    assert_equal(2, instance.edges[1].frequency) #potatoes in vegetable bin - are
    assert_equal(0, instance.edges[2].frequency) #green - with mold
    assert_equal(0, instance.edges[3].frequency) #are - with mold
    assert_equal(1, instance.edges[4].frequency) #potatoes in vegetable bin - fresh
  end
    
   test "Frequency Of Edges 4" do
    #review array  
    train_reviews = ["Neither of these cookbooks contains the recipe for Manhattan-style squid eyeball stew."]
    train_reviews = tc.segment_text(0, train_reviews)
    instance.generate_graph(train_reviews, pos_tagger, core_NLP_tagger, false, false)
    #checking number of edges
    assert_equal(2, instance.num_edges)
    #checking the edges values (subj-verb)
    assert_equal("of cookbooks", instance.edges[0].in_vertex.name.downcase)
    assert_equal("contains", instance.edges[0].out_vertex.name.downcase)
    #next edge (verb-obj)
    assert_equal("contains", instance.edges[1].in_vertex.name.downcase)
    assert_equal(("recipe for Manhattan-style squid eyeball stew").downcase, instance.edges[1].out_vertex.name.downcase)
  end
  
  #May be a failing test case, since the number of edges is affected by the POS tagging (could be 9 or 10)
  test "Frequency Of Edges 3" do
    #review array
    train_reviews = ["Tommy, along with the other students, breathed a sigh of relief when " +
          "Mrs Markham announced that she was postponing the due date for the research essay."]
    train_reviews = tc.segment_text(0, train_reviews)
    instance.generate_graph(train_reviews, pos_tagger, core_NLP_tagger, false, false)
    #checking number of edges
    assert(instance.num_edges >= 9)
  end
end
