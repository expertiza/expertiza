require 'test_helper'
require 'automated_metareview/text_preprocessing'
require 'automated_metareview/constants'
    
class TextPreprocessingTest < ActiveSupport::TestCase

  # Testing segment_text functionality
  test "check get review return array as is" do
    review_text = ["The sweet potatoes in the vegetable bin are green with mold."]    
    instance = TextPreprocessing.new
    result = instance.segment_text(0, review_text)
    assert_equal(1, result.length)
  end
  
  test "check get review break at full stop" do
    review_text = ["The sweet potatoes in the vegetable bin are green with mold. These sweet potatoes in the vegetable bin are fresh."]
    instance = TextPreprocessing.new
    result = instance.segment_text(0, review_text)
    assert_equal(2, result.length)
    assert_equal("The sweet potatoes in the vegetable bin are green with mold.", result[0])
    assert_equal("These sweet potatoes in the vegetable bin are fresh.", result[1])
  end
  
  test "check get review break at comma" do
    review_text = ["The sweet potatoes were tasty, and they were well-cooked too."]
    instance = TextPreprocessing.new
    result = instance.segment_text(0, review_text)
    assert_equal(2, result.length)
    assert_equal("The sweet potatoes were tasty,", result[0])
    assert_equal("and they were well-cooked too.", result[1])
  end
  
  test "check get review break at semicolon" do
    review_text = ["The sweet potatoes were tasty; they were all well-cooked."]
    instance = TextPreprocessing.new
    result = instance.segment_text(0, review_text)
    assert_equal(2, result.length)
    assert_equal("The sweet potatoes were tasty;", result[0])
    assert_equal("they were all well-cooked.", result[1])
  end
  
  test "check get review break at question-mark" do
    review_text = ["Was the report well-written? What grade would you give it?"]
    instance = TextPreprocessing.new
    result = instance.segment_text(0, review_text)
    assert_equal(2, result.length)
    assert_equal("Was the report well-written?", result[0])
    assert_equal("What grade would you give it?", result[1])
  end
  
  test "check get review break at exclamation" do
    review_text = ["This work is great! Thanks for all the hard work!"]
    instance = TextPreprocessing.new
    result = instance.segment_text(0, review_text)
    assert_equal(2, result.length)
    assert_equal("This work is great!", result[0])
    assert_equal("Thanks for all the hard work!", result[1])
  end
  
  test "check get review multiple punctuations 1" do
    review_text = ["Was the report well-written? What grade would you give it? Please grade the report on a scale of 1 to 5."]
    instance = TextPreprocessing.new
    result = instance.segment_text(0, review_text)
    assert_equal(3, result.length)
    assert_equal("Was the report well-written?", result[0])
    assert_equal("What grade would you give it?", result[1])
    assert_equal("Please grade the report on a scale of 1 to 5.", result[2])
  end
  
  test "check get review multiple punctuations 2" do
    review_text = ["This work is great! The report contains all the graphs. Would you be able to email me a copy of the same? Thanks!"]
    instance = TextPreprocessing.new
    result = instance.segment_text(0, review_text)
    assert_equal(4, result.length)
    assert_equal("This work is great!", result[0])
    assert_equal("The report contains all the graphs.", result[1])
    assert_equal("Would you be able to email me a copy of the same?", result[2])
    assert_equal("Thanks!", result[3])
  end
  
  # Testing read_patterns
  test "read patterns - check numbers" do
    instance = TextPreprocessing.new
    pos_tagger = EngTagger.new
    patterns = instance.read_patterns("automated_metareview/patterns-assess.csv", pos_tagger)
    assert_equal(17, patterns.length)
  end
  
  test "read patterns - check contents" do
    instance = TextPreprocessing.new
    pos_tagger = EngTagger.new
    patterns = instance.read_patterns("app/models/automated_metareview/patterns-assess.csv", pos_tagger)
    assert_equal("is", patterns[0].in_vertex.name)
    assert_equal("very", patterns[0].out_vertex.name)
    
    assert_equal("authors prose", patterns[4].in_vertex.name)
    assert_equal("understand", patterns[4].out_vertex.name)
    
    assert_equal("performance", patterns[13].in_vertex.name)
    assert_equal("are discussed", patterns[13].out_vertex.name)
    
    assert_equal("labeling is", patterns[16].in_vertex.name)
    assert_equal("quite", patterns[16].out_vertex.name)
  end
  
  test "read patterns - check state positive" do
    instance = TextPreprocessing.new
    pos_tagger = EngTagger.new
    patterns = instance.read_patterns("app/models/automated_metareview/patterns-assess.csv", pos_tagger)
    assert_equal(POSITIVE, patterns[0].in_vertex.state)
    assert_equal(POSITIVE, patterns[0].out_vertex.state)
    
    assert_equal(POSITIVE, patterns[4].in_vertex.state)
    assert_equal(POSITIVE, patterns[4].out_vertex.state)
    
    assert_equal(POSITIVE, patterns[13].in_vertex.state)
    assert_equal(POSITIVE, patterns[13].out_vertex.state)
    
    assert_equal(POSITIVE, patterns[16].in_vertex.state)
    assert_equal(POSITIVE, patterns[16].out_vertex.state)
  end
  
  test "read patterns - check state negative" do
    instance = TextPreprocessing.new
    pos_tagger = EngTagger.new
    patterns = instance.read_patterns("app/models/automated_metareview/patterns-prob-detect.csv", pos_tagger)
    assert_equal(NEGATED, patterns[0].in_vertex.state)
    assert_equal(NEGATED, patterns[0].out_vertex.state)
    
    assert_equal(NEGATED, patterns[4].in_vertex.state)
    assert_equal(NEGATED, patterns[4].out_vertex.state)
    
    assert_equal(NEGATED, patterns[13].in_vertex.state)
    assert_equal(NEGATED, patterns[13].out_vertex.state)
    
    assert_equal(NEGATED, patterns[16].in_vertex.state)
    assert_equal(NEGATED, patterns[16].out_vertex.state)
  end
  
  test "read patterns - check state suggestive" do
    instance = TextPreprocessing.new
    pos_tagger = EngTagger.new
    patterns = instance.read_patterns("app/models/automated_metareview/patterns-suggest.csv", pos_tagger)
    assert_equal(SUGGESTIVE, patterns[0].in_vertex.state)
    assert_equal(SUGGESTIVE, patterns[0].out_vertex.state)
    
    assert_equal(SUGGESTIVE, patterns[4].in_vertex.state)
    assert_equal(SUGGESTIVE, patterns[4].out_vertex.state)
    
    assert_equal(SUGGESTIVE, patterns[13].in_vertex.state)
    assert_equal(SUGGESTIVE, patterns[13].out_vertex.state)
    
    assert_equal(SUGGESTIVE, patterns[16].in_vertex.state)
    assert_equal(SUGGESTIVE, patterns[16].out_vertex.state)
  end
end
