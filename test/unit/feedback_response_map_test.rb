require File.dirname(__FILE__) + '/../test_helper'

class FeedbackResponseMapTest < ActiveSupport::TestCase
  fixtures :response_maps, :questionnaires , :assignments, :responses , :response_maps

  test "method_assignment" do
    r = FeedbackResponseMap.new
    r.review = responses(:response3)
    r.review.map = response_maps(:response_maps0)
    assert_equal '827400667', r.assignment.id.to_s
  end

  test "method_show_review" do
    r = FeedbackResponseMap.new
    r.review = responses(:response3)
    r.review.map = response_maps(:response_maps0)
    assert_match /Review/, r.show_review
  end
  test "method_get_title" do
    r = FeedbackResponseMap.new
    r.review = responses(:response3)
    r.review.map = response_maps(:response_maps0)
    assert_match /Feedback/, r.get_title
  end

  #test "method_questionnaire" do
    #@questionnaire = questionnaires(:peer_review_questionnaire)
    #@assignment = assignments(:assignment0)
    #f = FeedbackResponseMap.new
    #f.review = responses(:response7)
    #f.review.map = response_maps(:response_maps7)
    #f.assignment.questionnaires = questionnaires(:peer_review_questionnaire)
    #f.questionnaire
    #assert_equal "AuthorFeedbackQuestionnaire", f.assignment.questionnaires[0].type
  #end

  test "method_contributor" do
    p = FeedbackResponseMap.new
    p.review = responses(:response3)
    p.review.map = response_maps(:response_maps0)
    p.contributor
    assert p.valid?
  end

end