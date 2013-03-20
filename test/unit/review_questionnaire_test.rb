require File.dirname(__FILE__) + '/../test_helper'

class ReviewQuestionnaireTest < ActiveSupport::TestCase
  #fixtures :author_feedback_questionnaires
  #TODO verify fixture
  fixtures :questionnaires, :assignments, :participants, :scores

  def setup
    @participant = AssignmentParticipant.new
  end

end
