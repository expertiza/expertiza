require File.dirname(__FILE__) + '/../test_helper'

class ReviewQuestionnaireTest < ActiveSupport::TestCase
  #fixtures :author_feedback_questionnaires
  #TODO verify fixture
  fixtures :questionnaires, :assignments, :participants, :scores

  # Replace this with your real tests.
  #def test_truth
  #  assert true
  #end

  def setup
    @participant = AssignmentParticipant.new
  end

  def test_get_weighted_score
    assignment = assignments(:assignment1)
    questionnaire_weight = 50
    average = 95

    scores = Hash.new
    scores[:review] = {:scores => {:avg => average}}

    q = ReviewQuestionnaire.new(:name => "My Questionnaire",
                                    :type => "ReviewQuestionnaire",
                                    :min_question_score => 1,
                                    :max_question_score => 5,
                                    :section => "Regular" )
    q.save!

    aq = AssignmentQuestionnaire.new({:assignment_id => assignment.id,
                                      :questionnaire_id => q.id,
                                      :user_id => Fixtures.identify(:student3),
                                      :notification_limit => 15,
                                      :questionnaire_weight => questionnaire_weight })
    aq.save!
    assert_not_nil q.get_weighted_score(assignment, scores)
    assert_equal q.get_weighted_score(assignment, scores), average * questionnaire_weight/100.to_f

  end


end
