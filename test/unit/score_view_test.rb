require File.dirname(__FILE__) + '/../test_helper'
# Testing the Questionaire

class QuestionaireTest < ActiveSupport::TestCase
fixtures :questionnaires, :assignments

def test_scores_view
  questionnaire1 = Array.new
  questionnaire1<<questionnaires(:questionnaire0)
  questionnaire1<<questionnaires(:questionnaire1)
  questionnaire1<<questionnaires(:questionnaire2)
  questionnaire1<<questionnaires(:peer_review_questionnaire)
  scores = Hash.new
  scores[:participant] = AssignmentParticipant.find_by_parent_id(assignments(:assignment0))
  questionnaire1.each do |questionnaire|
    scores[questionnaire.symbol] = Hash.new
    scores[questionnaire.symbol][:assessments] = questionnaire.get_assessments_for(AssignmentParticipant.find_by_parent_id(assignments(:assignment0)))
    assert_not_equal(scores[questionnaire.symbol][:assessments],0)
  end
end

