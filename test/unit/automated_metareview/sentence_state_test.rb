require 'test_helper'
require 'automated_metareview/sentence_state'
    
class SentenceStateTest < ActiveSupport::TestCase
  attr_accessor :pos_tagger, :sstate
  def setup
    @pos_tagger = EngTagger.new
    #creating an instance of the 'SentenceState' class        
    @sstate = SentenceState.new
  end
  
  test "Identify State 1" do
    sentence = "Parallel lines never meet."
    #getting the tagged string
    tagged_string = @pos_tagger.get_readable(sentence)
    #calling the identify_sentence_state method with tagged_string as a parameter
    state_array = sstate.identify_sentence_state(tagged_string) #returns an array containing states as the output (depending on the number and types of segments)    
    assert_equal(state_array[0], NEGATED)
  end  
  
  test "Identify State 2" do
    sentence = "He is not playing."
    #getting the tagged string
    tagged_string = @pos_tagger.get_readable(sentence)
    #calling the identify_sentence_state method with tagged_string as a parameter
    state_array = sstate.identify_sentence_state(tagged_string) #returns an array containing states as the output (depending on the number and types of segments)    
    assert_equal(state_array[0], NEGATED)
  end     
  
  test "Identify State 3" do
    sentence = "I’m not ever going to do any homework."
    #getting the tagged string
    tagged_string = @pos_tagger.get_readable(sentence)
    #calling the identify_sentence_state method with tagged_string as a parameter
    state_array = sstate.identify_sentence_state(tagged_string) #returns an array containing states as the output (depending on the number and types of segments)    
    assert_equal(state_array[0], NEGATED)
  end 
     
  test "Identify State 4" do
    sentence = "You aren't ever going to go anywhere with me if you act like that."
    #getting the tagged string
    tagged_string = @pos_tagger.get_readable(sentence)
    #calling the identify_sentence_state method with tagged_string as a parameter
    state_array = sstate.identify_sentence_state(tagged_string) #returns an array containing states as the output (depending on the number and types of segments)    
    assert_equal(state_array[0], NEGATED)
  end   
  
  test "Identify State 5" do
    sentence = "No examples and no explanation have been provided."
    #getting the tagged string
    tagged_string = @pos_tagger.get_readable(sentence)
    #calling the identify_sentence_state method with tagged_string as a parameter
    state_array = sstate.identify_sentence_state(tagged_string) #returns an array containing states as the output (depending on the number and types of segments)    
    assert_equal(state_array[0], NEGATED)
  end
   
  test "Identify State 6" do
    sentence = "No good or bad examples have been provided."
    #getting the tagged string
    tagged_string = @pos_tagger.get_readable(sentence)
    #calling the identify_sentence_state method with tagged_string as a parameter
    state_array = sstate.identify_sentence_state(tagged_string) #returns an array containing states as the output (depending on the number and types of segments)    
    assert_equal(state_array[0], NEGATED)
  end
  
  test "Identify State 7" do
    sentence = "It is too short not to contain sufficient explanation." #the sentence is ambiguous
    #getting the tagged string
    tagged_string = @pos_tagger.get_readable(sentence)
    #calling the identify_sentence_state method with tagged_string as a parameter
    state_array = sstate.identify_sentence_state(tagged_string) #returns an array containing states as the output (depending on the number and types of segments)    
    assert_equal(state_array[0], POSITIVE) 
  end
  
  test "Identify State 8" do
    sentence = "We are not not musicians."
    #getting the tagged string
    tagged_string = @pos_tagger.get_readable(sentence)
    #calling the identify_sentence_state method with tagged_string as a parameter
    state_array = sstate.identify_sentence_state(tagged_string) #returns an array containing states as the output (depending on the number and types of segments)    
    assert_equal(state_array[0], POSITIVE)
  end

  test "Identify State 9" do
    sentence = "I don't need none."
    #getting the tagged string
    tagged_string = @pos_tagger.get_readable(sentence)
    #calling the identify_sentence_state method with tagged_string as a parameter
    state_array = sstate.identify_sentence_state(tagged_string) #returns an array containing states as the output (depending on the number and types of segments)    
    assert_equal(state_array[0], POSITIVE)
  end  

  test "Identify State 10" do
    sentence = "It was so hot, I couldn't hardly breathe."
    #getting the tagged string
    tagged_string = @pos_tagger.get_readable(sentence)
    #calling the identify_sentence_state method with tagged_string as a parameter
    state_array = sstate.identify_sentence_state(tagged_string) #returns an array containing states as the output (depending on the number and types of segments)
    assert_equal(1, state_array.length)    
    assert_equal(state_array[0], NEGATED)
  end
  
  test "Identify State 11" do
    sentence = "I don't want to go nowhere."
    #getting the tagged string
    tagged_string = @pos_tagger.get_readable(sentence)
    #calling the identify_sentence_state method with tagged_string as a parameter
    state_array = sstate.identify_sentence_state(tagged_string) #returns an array containing states as the output (depending on the number and types of segments) 
    assert_equal(state_array[0], POSITIVE)
  end
  
  test "Identify State 12" do
    sentence = "This essay is clearly not nonsense."
    #getting the tagged string
    tagged_string = @pos_tagger.get_readable(sentence)
    #calling the identify_sentence_state method with tagged_string as a parameter
    state_array = sstate.identify_sentence_state(tagged_string) #returns an array containing states as the output (depending on the number and types of segments) 
    assert_equal(state_array[0], POSITIVE)
  end

  test "Identify State 13" do
    sentence = "I receive a not insufficient allowance."
    #getting the tagged string
    tagged_string = @pos_tagger.get_readable(sentence)
    #calling the identify_sentence_state method with tagged_string as a parameter
    state_array = sstate.identify_sentence_state(tagged_string) #returns an array containing states as the output (depending on the number and types of segments) 
    assert_equal(state_array[0], POSITIVE)
  end   
       
  test "Identify State 14 ambiguous" do
    sentence = "This is barely duplicated."
    #getting the tagged string
    tagged_string = @pos_tagger.get_readable(sentence)
    #calling the identify_sentence_state method with tagged_string as a parameter
    state_array = sstate.identify_sentence_state(tagged_string) #returns an array containing states as the output (depending on the number and types of segments) 
    assert_equal(state_array[0], POSITIVE)
  end
   
  test "Identify State suggestive 15" do
    sentence = "It is ambiguous and I would have preferred to do it differently."
    #getting the tagged string
    tagged_string = @pos_tagger.get_readable(sentence)
    #calling the identify_sentence_state method with tagged_string as a parameter
    state_array = sstate.identify_sentence_state(tagged_string) #returns an array containing states as the output (depending on the number and types of segments)
    assert_equal(2, state_array.length) 
    assert_equal(state_array[0], NEGATED)
    assert_equal(state_array[1], SUGGESTIVE)
  end
  
  test "Identify State suggestive 16" do
    sentence = "I suggest you not take that route."
    #getting the tagged string
    tagged_string = @pos_tagger.get_readable(sentence)
    #calling the identify_sentence_state method with tagged_string as a parameter
    state_array = sstate.identify_sentence_state(tagged_string) #returns an array containing states as the output (depending on the number and types of segments)
    assert_equal(state_array[0], SUGGESTIVE)
  end

  test "Identify State suggestive 17" do
    sentence = "I hardly suggested that option."
    #getting the tagged string
    tagged_string = @pos_tagger.get_readable(sentence)
    #calling the identify_sentence_state method with tagged_string as a parameter
    state_array = sstate.identify_sentence_state(tagged_string) #returns an array containing states as the output (depending on the number and types of segments)
    assert_equal(state_array[0], SUGGESTIVE)
  end
  
  test "Identify State negated 18" do
    sentence = "It is perhaps better you not do the homework."
    #getting the tagged string
    tagged_string = @pos_tagger.get_readable(sentence)
    #calling the identify_sentence_state method with tagged_string as a parameter
    state_array = sstate.identify_sentence_state(tagged_string) #returns an array containing states as the output (depending on the number and types of segments)
    assert_equal(state_array[0], SUGGESTIVE) #negative or suggestive, is ambiguous
  end
end
