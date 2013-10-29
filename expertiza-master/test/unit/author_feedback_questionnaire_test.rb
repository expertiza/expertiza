require File.dirname(__FILE__) + '/../test_helper'

class AuthorFeedbackQuestionnaireTest < ActiveSupport::TestCase
  #fixtures :author_feedback_questionnaires
   #TODO verify fixture
  fixtures :questionnaires, :assignments, :participants

  # Replace this with your real tests.
  #def test_truth
  #  assert true
  #end

  def setup
    @participant = AssignmentParticipant.new
  end

  def test_get_weighted_score
    assignment = Assignment.new
    assignment = assignments(:assignment1)
    scores = Hash.new
    scores[:participants] = Hash.new
    assignment.participants.each{
      | participant |
      scores[:participants][participant.id.to_s.to_sym] = Hash.new
      scores[:participants][participant.id.to_s.to_sym][:participant] = participant
      questionnaires.each{
        | questionnaire |
        scores[:participants][participant.id.to_s.to_sym][questionnaire.symbol] = Hash.new
        weighted_score = get_weighted_score(assignment,scores)
        assert_not_nil(weighted_score)
        }
      }
  end
end
