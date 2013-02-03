require 'test_helper'
require 'automated_metareview/tone'
require 'automated_metareview/text_preprocessing'
    
class ToneTest < ActiveSupport::TestCase
  attr_accessor :pos_tagger,  :core_NLP_tagger, :tc, :g
  
  def setup
    #initializing the pos tagger and nlp tagger/semantic parser  
    @pos_tagger = EngTagger.new
    @core_NLP_tagger =  StanfordCoreNLP.load(:tokenize, :ssplit, :pos, :lemma, :parse, :ner, :dcoref)
    @tc = TextPreprocessing.new
    @g = GraphGenerator.new
  end
  
  test "identify tone with negations but a neutral tone 1" do
    instance = Tone.new
    review_text = ["Parallel lines never meet."]
    review_text = tc.segment_text(0, review_text)
    tone_array = Array.new
    g.generate_graph(review_text, pos_tagger, core_NLP_tagger, true, false)
    tone_array = instance.identify_tone(@pos_tagger, @core_NLP_tagger, review_text, g)
    assert_equal(3, tone_array.length) #only positive and negative available at this point
    assert_equal(0, tone_array[0])#positive
    assert_equal(0, tone_array[1])#negative
    assert_equal(1, tone_array[2])#neutral
  end
  
  test "identify tone with negations but a neutral tone 2" do
    instance = Tone.new
    review_text = ["He is not playing."] #neutral although it has a negator
    review_text = tc.segment_text(0, review_text)
    tone_array = Array.new
    g.generate_graph(review_text, pos_tagger, core_NLP_tagger, true, false)
    tone_array = instance.identify_tone(@pos_tagger, @core_NLP_tagger, review_text, g)
    assert_equal(3, tone_array.length) #only positive and negative available at this point
    assert_equal(0, tone_array[0])#positive
    assert_equal(0, tone_array[1])#negative
    assert_equal(1, tone_array[2])#neutral
  end
  
  test "identify tone with negations but a neutral tone 3" do
    instance = Tone.new
    review_text = ["No examples and no explanation have been provided."] #neutral although it has a negator
    review_text = tc.segment_text(0, review_text)
    tone_array = Array.new
    g.generate_graph(review_text, pos_tagger, core_NLP_tagger, true, false)
    tone_array = instance.identify_tone(@pos_tagger, @core_NLP_tagger, review_text, g)
    assert_equal(3, tone_array.length) #only positive and negative available at this point
    assert_equal(0, tone_array[0])#positive
    assert_equal(0, tone_array[1])#negative
    assert_equal(1, tone_array[2])#neutral
  end
  
  test "identify tone with a neutral tone 1" do
    instance = Tone.new
    review_text = ["It was so hot, I couldn't hardly breathe."] #neutral although it has a negative descriptor
    review_text = tc.segment_text(0, review_text)
    tone_array = Array.new
    g.generate_graph(review_text, pos_tagger, core_NLP_tagger, true, false)
    tone_array = instance.identify_tone(@pos_tagger, @core_NLP_tagger, review_text, g)
    assert_equal(3, tone_array.length) #only positive and negative available at this point
    assert(tone_array[0] > tone_array[1])
    #this sentence gets classified as positive since "couldn't" is treated as "could + n't" and "could" is classified with a + tone 
  end
  
  test "identify tone with a negative word 1" do
    instance = Tone.new
    review_text = ["This is barely duplicated."] #negative
    review_text = tc.segment_text(0, review_text)
    tone_array = Array.new
    g.generate_graph(review_text, pos_tagger, core_NLP_tagger, true, false)
    tone_array = instance.identify_tone(@pos_tagger, @core_NLP_tagger, review_text, g)
    assert_equal(3, tone_array.length) #only positive and negative available at this point
    assert_equal(0, tone_array[0])#positive
    assert_equal(1, tone_array[1])#negative
    assert_equal(0, tone_array[2])#neutral
  end
  
  test "identify tone with positive and negative components 1" do
    instance = Tone.new
    review_text = ["It is ambiguous and I would have preferred to do it differently."] #negative
    review_text = tc.segment_text(0, review_text)
    tone_array = Array.new
    g.generate_graph(review_text, pos_tagger, core_NLP_tagger, true, false)
    tone_array = instance.identify_tone(@pos_tagger, @core_NLP_tagger, review_text, g)
    assert_equal(3, tone_array.length) #only positive and negative available at this point
    assert(tone_array[0] == 0)#poisitive > negative
    assert(tone_array[1] == 1)
    assert(tone_array[2] == 0)
  end
  
  test "identify tone with positive and negative components 2" do
    instance = Tone.new
    review_text = ["This is a good report. I would have liked it to be a bit longer though."] #negative
    review_text = tc.segment_text(0, review_text)
    tone_array = Array.new
    g.generate_graph(review_text, pos_tagger, core_NLP_tagger, true, false)
    tone_array = instance.identify_tone(@pos_tagger, @core_NLP_tagger, review_text, g)
    assert_equal(3, tone_array.length) #only positive and negative available at this point
    assert(tone_array[0] > tone_array[1])#poisitive > negative
  end
  
  test "identify tone with positive and negative components 3" do
    instance = Tone.new
    review_text = ["It is ambiguous and I was a very report."] #negative
    review_text = tc.segment_text(0, review_text)
    tone_array = Array.new
    g.generate_graph(review_text, pos_tagger, core_NLP_tagger, true, false)
    tone_array = instance.identify_tone(@pos_tagger, @core_NLP_tagger, review_text, g)
    assert_equal(3, tone_array.length) #only positive and negative available at this point
    assert(tone_array[0] < tone_array[1])#poisitive > negative
  end
  
  test "identify tone with a neutral tone 2" do
    instance = Tone.new
    review_text = ["It is perhaps better you not do the homework."] #negative
    review_text = tc.segment_text(0, review_text)
    tone_array = Array.new
    g.generate_graph(review_text, pos_tagger, core_NLP_tagger, true, false)
    tone_array = instance.identify_tone(@pos_tagger, @core_NLP_tagger, review_text, g)
    assert_equal(3, tone_array.length) #only positive and negative available at this point
    assert(tone_array[0] == tone_array[1])
    assert(tone_array[2] == 1)
  end
end
