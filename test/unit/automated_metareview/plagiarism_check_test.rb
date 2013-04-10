require 'test_helper'
require 'automated_metareview/plagiarism_check'
    
class PlagirismCheckTest < ActiveSupport::TestCase

  test "check for plagiarism true match" do
    review_text = ["The sweet potatoes in the vegetable bin are green with mold. These sweet potatoes in the vegetable bin are fresh."]
    subm_text = ["The sweet potatoes in the vegetable bin are green with mold. These sweet potatoes in the vegetable bin are fresh."]
    #creating an instance of the degree of relevance class and calling the 'compare_vertices' method
    instance = PlagiarismChecker.new
    assert_equal(true, instance.check_for_plagiarism(review_text, subm_text))
  end
  
  test "check for plagiarism false match" do
    review_text = ["The sweet potatoes in the vegetable bin are green with mold. These sweet potatoes in the vegetable bin are fresh."]
    subm_text = ["Neither of these cookbooks contains the recipe for Manhattan-style squid eyeball stew."]
    #creating an instance of the degree of relevance class and calling the 'compare_vertices' method
    instance = PlagiarismChecker.new
    assert_equal(false, instance.check_for_plagiarism(review_text, subm_text))
  end
  
  test "check for plagiarism true match with different quoted segments" do
    review_text = ["They liked, \"the sweet potatoes\" and \"the green spinach\" very much."]
    subm_text = ["The sweet potatoes in the vegetable bin are green with mold. These sweet potatoes in the vegetable bin are fresh."]
    #creating an instance of the degree of relevance class and calling the 'compare_vertices' method
    instance = PlagiarismChecker.new
    assert_equal(false, instance.check_for_plagiarism(review_text, subm_text))
  end
  
  test "check for fewer than NGRAM match" do
    review_text = ["The sweet potatoes in the vegetable bin are green with mold. These sweet potatoes in the vegetable bin are fresh."]
    subm_text = ["Neither of these cooks used the sweet potatoes."]
    #creating an instance of the degree of relevance class and calling the 'compare_vertices' method
    instance = PlagiarismChecker.new
    assert_equal(false, instance.check_for_plagiarism(review_text, subm_text))
  end
  
  test "check for NGRAM-1 match" do
    review_text = ["The potatoes in the vegetable bin are green with mold. These sweet potatoes in the vegetable bin are fresh."]
    subm_text = ["Neither of these cooks used the potatoes in the basket."] #"the potatoes in the vegetable" or "potatoes in the vegetable bin"
    #creating an instance of the degree of relevance class and calling the 'compare_vertices' method
    instance = PlagiarismChecker.new
    assert_equal(false, instance.check_for_plagiarism(review_text, subm_text))
  end
  
  test "check for exact NGRAM match" do
    review_text = ["The potatoes in the vegetable bin are green with mold. These sweet potatoes in the vegetable bin are fresh."]
    subm_text = ["Neither of these cooks used the potatoes in the vegetable bin."] #"the potatoes in the vegetable" or "potatoes in the vegetable bin"
    #creating an instance of the degree of relevance class and calling the 'compare_vertices' method
    instance = PlagiarismChecker.new
    assert_equal(true, instance.check_for_plagiarism(review_text, subm_text))
  end
    
  test "check for plagiarism true match with quoted text" do
    review_text = ["They said, \"The sweet potatoes in the vegetable bin are green with mold. These sweet potatoes in the vegetable bin are fresh.\""]
    subm_text = ["The sweet potatoes in the vegetable bin are green with mold. These sweet potatoes in the vegetable bin are fresh."]
    #creating an instance of the degree of relevance class and calling the 'compare_vertices' method
    instance = PlagiarismChecker.new
    preprocess = TextPreprocessing.new
    review_text = preprocess.remove_text_within_quotes(review_text)
    assert_equal(false, instance.check_for_plagiarism(review_text, subm_text))
  end
end
