require 'test_helper'

class ResponseMapTest < ActiveSupport::TestCase
  fixtures :response_maps, :participants

  # Replace this with your real tests.

  test "method_contributor" do
    p = SelfReviewResponseMap.new
    p.review_mapping = response_maps(:resmap1)
    p.contributor
    assert p.valid?
  end

  test "method_questionnaire" do
    p = SelfReviewResponseMap.new
    p.review_mapping = response_maps(:resmap1)
    #p.assignment.questionnaires = questionnaires(:questionnaire0)
    p.questionnaire(1)
  end

  test "method_get_title" do
    p = SelfReviewResponseMap.new
    assert_equal p.get_title, "Self Review"
    end
end