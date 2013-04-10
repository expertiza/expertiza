require 'test_helper'
class WordnetBasedSimilarityTest < ActiveSupport::TestCase
  attr_accessor :instance, :speller
  def setup
    require 'automated_metareview/wordnet_based_similarity'
    @instance = WordnetBasedSimilarity.new
    #initializing the speller
    @speller = Aspell.new("en_US")
    @speller.suggestion_mode = Aspell::NORMAL
  end
  
  # test "compare string type difference" do
    # v1 =  Vertex.new("run", 3, 1, 0, 0, 1, "JJ") #the 2nd argument is vertex type, 1-NOUN, 2-verb, 3, adj etc.
    # v2 =  Vertex.new("run", 2, 1, 0, 0, 1, "VB")
    # assert_equal(6, instance.compare_strings(v1, v2, speller)) #for an exact match with type difference the value is halved
  # end
#   
  # test "compare string same case" do
    # v1 =  Vertex.new("potatoes in vegetable bin", 1, 1, 0, 1, 1, "JJ")
    # v2 =  Vertex.new("potatoes in vegetable bin", 1, 1, 0, 1, 1, "JJ")
    # assert_equal(6, instance.compare_strings(v1, v2, speller))
  # end
#   
  # test "compare string case difference" do
    # v1 =  Vertex.new("sweet", 1, 1, 0, 0, 1, "JJ")
    # v2 =  Vertex.new("Sweet", 1, 1, 0, 0, 1, "JJ")
    # assert_equal(6, instance.compare_strings(v1, v2, speller))
  # end
#   
  # test "compare string state difference" do
    # v1 =  Vertex.new("sweet", 1, 1, 1, 0, 1, "JJ") #the 4th argument is state that is changed from positive to suggestive
    # v2 =  Vertex.new("Sweet", 1, 1, 0, 0, 1, "JJ")
    # assert_equal(-6, instance.compare_strings(v1, v2, speller))
  # end
#   
  # #type difference doesnt matter!!
  # test "compare string state and type difference" do
    # v1 =  Vertex.new("run", 3, 1, 1, 0, 1, "JJ") #the 2nd argument is vertex type, 1-NOUN etc.
    # v2 =  Vertex.new("run", 2, 1, 0, 0, 1, "VB")
    # assert_equal(-6, @instance.compare_strings(v1, v2, @speller))
 # end
#  
 # test "compare string and stem word exact match" do
    # v1 =  Vertex.new("run", 2, 1, 1, 0, 1, "VB") 
    # v2 =  Vertex.new("running", 2, 1, 1, 0, 1, "VB")
    # assert_equal(6, @instance.compare_strings(v1, v2, @speller))
 # end
#  
 # test "compare string synonyms" do
    # v1 =  Vertex.new("smart", 3, 1, 1, 0, 1, "JJ") 
    # v2 =  Vertex.new("intelligent", 3, 1, 1, 0, 1, "JJ")
    # assert_equal(5, @instance.compare_strings(v1, v2, @speller))
 # end
#  
 # test "compare string synonyms diff POS" do
    # v1 =  Vertex.new("lazy", 3, 1, 1, 0, 1, "JJ") 
    # v2 =  Vertex.new("idle", 3, 1, 1, 0, 1, "JJ")
    # assert_equal(5, @instance.compare_strings(v1, v2, @speller)) #POS tag shouldn't matter!
 # end
#  
 # test "compare string synonyms with diff state" do
    # v1 =  Vertex.new("beautiful", 3, 1, 1, 1, 1, "JJ") 
    # v2 =  Vertex.new("handsome", 3, 1, 0, 0, 1, "JJ")
    # assert_equal(-5, @instance.compare_strings(v1, v2, @speller))
 # end
#  
 # test "compare string antonyms" do
    # v1 =  Vertex.new("security", 2, 1, 0, 0, 1, "NN") 
    # v2 =  Vertex.new("insecurity", 2, 1, 0, 0, 1, "NN")
    # assert_equal(-5, @instance.compare_strings(v1, v2, @speller))
 # end
#  
 # test "compare string antonyms diff state" do
    # v1 =  Vertex.new("security", 2, 1, 1, 0, 1, "NN") #the 2nd argument is vertex type, 1-NOUN etc.
    # v2 =  Vertex.new("insecurity", 2, 1, 0, 0, 1, "NN")
    # assert_equal(5, instance.compare_strings(v1, v2, speller)) #the words are antonyms but are used in sentences with different states
 # end
#  
 # test "compare string antonyms diff POS" do
    # v1 =  Vertex.new("security", 2, 1, 1, 0, 1, "NN")
    # v2 =  Vertex.new("insecurity", 2, 1, 1, 0, 1, "NN")
    # assert_equal(-5, instance.compare_strings(v1, v2, speller))
 # end
#  
 # test "compare string hypernyms" do
    # v1 =  Vertex.new("run", 2, 1, 0, 0, 1, "VB")
    # v2 =  Vertex.new("jog", 2, 1, 0, 0, 1, "VB")
    # assert_equal(4, instance.compare_strings(v1, v2, speller))
 # end
#  
 # test "compare string hypernyms diff state" do
    # v1 =  Vertex.new("run", 2, 1, 0, 0, 1, "VB")
    # v2 =  Vertex.new("jog", 2, 1, 2, 0, 1, "VB")
    # assert_equal(-4, instance.compare_strings(v1, v2, speller))
 # end
#  
 # test "compare string hypernyms diff POS" do
    # v1 =  Vertex.new("run", 2, 1, 0, 0, 1, "VB")
    # v2 =  Vertex.new("jog", 2, 1, 0, 0, 1, "NN")
    # assert_equal(4, instance.compare_strings(v1, v2, speller)) #no POS is considered for hypernyms and hyponyms
 # end
#  
 # test "compare string hyponyms" do
    # v1 =  Vertex.new("run", 2, 1, 0, 0, 1, "VB")
    # v2 =  Vertex.new("trot", 2, 1, 0, 0, 1, "VB")
    # assert_equal(4, instance.compare_strings(v1, v2, speller))
 # end
#  
 # test "compare string hyponyms diff state" do
    # instance = WordnetBasedSimilarity.new
    # v1 =  Vertex.new("run", 2, 1, 0, 0, 1, "VB")
    # v2 =  Vertex.new("trot", 2, 1, 2, 0, 1, "VB")
    # assert_equal(-4, instance.compare_strings(v1, v2, speller))
 # end
#  
 # test "compare string hyponyms diff POS" do
    # instance = WordnetBasedSimilarity.new
    # v1 =  Vertex.new("run", 2, 1, 0, 0, 1, "VB")
    # v2 =  Vertex.new("trot", 2, 1, 0, 0, 1, "NN")
    # assert_equal(4, instance.compare_strings(v1, v2, speller))#no POS is considered for hypernyms and hyponyms
 # end
 
  test "compare string overlap defs" do
    v1 =  Vertex.new("speech", 2, 1, 0, 0, 1, "NN")
    v2 =  Vertex.new("delivering", 2, 1, 0, 0, 1, "VB")
    assert_equal(1, instance.compare_strings(v1, v2, speller))#no POS is considered for hypernyms and hyponyms
 end

  # test "compare string overlap defs diff state" do
    # v1 =  Vertex.new("speech", 2, 1, 0, 0, 1, "NN")
    # v2 =  Vertex.new("delivering", 2, 1, 2, 0, 1, "VB")
    # assert_equal(-1, instance.compare_strings(v1, v2, speller))#no POS is considered for hypernyms and hyponyms
 # end
end #end of test class

####### Not doing holonyms and meronyms or overlapping examples

# test "compare string holonyms" do
    # v1 =  Vertex.new("speech", 2, 1, 0, 0, 1, "NN")
    # v2 =  Vertex.new("dialogue", 2, 1, 0, 0, 1, "NN")
    # assert_equal(3, instance.compare_strings(v1, v2, speller))
 # end
#  
  # test "compare string holonyms diff state" do
    # v1 =  Vertex.new("speech", 2, 1, 0, 0, 1, "NN")
    # v2 =  Vertex.new("dialogue", 2, 1, 2, 0, 1, "NN")
    # assert_equal(-3, instance.compare_strings(v1, v2, speller))
 # end
#  
 # test "compare string holonyms diff POS" do
    # v1 =  Vertex.new("speech", 2, 1, 0, 0, 1, "NN")
    # v2 =  Vertex.new("dialogue", 2, 1, 0, 0, 1, "NN")
    # assert_equal(3, instance.compare_strings(v1, v2, speller))#no POS is considered for hypernyms and hyponyms
 # end

# test "compare string meronyms 2" do
    # v1 =  Vertex.new("car", 2, 1, 0, 0, 1, "NN")
    # v2 =  Vertex.new("accelerator", 2, 1, 0, 0, 1, "NN")
    # assert_equal(3, instance.compare_strings(v1, v2, speller))
 # end
#  
  # test "compare string meronyms diff state 2" do
    # v1 =  Vertex.new("car", 2, 1, 0, 0, 1, "NN")
    # v2 =  Vertex.new("accelerator", 2, 1, 2, 0, 1, "NN")
    # assert_equal(-3, instance.compare_strings(v1, v2, speller))
 # end
#  
 # test "compare string meronyms diff POS 2" do
    # v1 =  Vertex.new("Car", 2, 1, 0, 0, 1, "NN")
    # v2 =  Vertex.new("AcceleRAtoR", 2, 1, 0, 0, 1, "VB")
    # assert_equal(3, instance.compare_strings(v1, v2, speller))#no POS is considered for hypernyms and hyponyms
 # end 

#  
 # test "compare string overlap examples" do
    # v1 =  Vertex.new("pound", 2, 1, 0, 0, 1, "NN")
    # v2 =  Vertex.new("scale", 2, 1, 0, 0, 1, "VB")
    # assert_equal(1, instance.compare_strings(v1, v2, speller))#no POS is considered for hypernyms and hyponyms
 # end
#  
 # test "compare string overlap examples diff state" do
    # v1 =  Vertex.new("pound", 2, 1, 0, 0, 1, "NN")
    # v2 =  Vertex.new("scale", 2, 1, 2, 0, 1, "VB")
    # assert_equal(-1, instance.compare_strings(v1, v2, speller))#no POS is considered for hypernyms and hyponyms
 # end