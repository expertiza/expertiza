require 'test_helper'
require 'automated_metareview/text_quantity'
require 'automated_metareview/text_preprocessing'
    
class ToneTest < ActiveSupport::TestCase
  attr_accessor :tc
  def setup
    @tc = TextPreprocessing.new
  end
  
  test "number of unique tokens without duplicate words" do
    instance = TextQuantity.new
    review_text = ["Parallel lines never meet."]
    review_text = tc.segment_text(0, review_text)
    num_tokens = instance.number_of_unique_tokens(review_text)
    assert_equal(4, num_tokens)
  end
  
  test "number of unique tokens with frequent words" do
    instance = TextQuantity.new
    review_text = ["I am surprised to hear the news."]
    review_text = tc.segment_text(0, review_text)
    num_tokens = instance.number_of_unique_tokens(review_text)
    assert_equal(3, num_tokens)
  end
  
  test "number of unique tokens with repeated words" do
    instance = TextQuantity.new
    review_text = ["The report is good, but more changes can be made to the report."]
    review_text = tc.segment_text(0, review_text)
    num_tokens = instance.number_of_unique_tokens(review_text)
    assert_equal(6, num_tokens) #tokens:report, good, but, more, changes, made (others are stop words)
  end
end
