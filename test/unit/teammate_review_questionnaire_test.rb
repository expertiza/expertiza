require File.dirname(__FILE__) + '/../test_helper'

class TeammateReviewQuestionnaireTest < ActiveSupport::TestCase
  #fixtures :author_feedback_questionnaires
  #TODO verify fixture
  fixtures :assignment_questionnaires, :questionnaires, :assignments, :participants, :scores

  def setup
    @participant = AssignmentParticipant.new
  end

end
