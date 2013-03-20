require File.dirname(__FILE__) + '/../test_helper'

class AuthorFeedbackQuestionnaireTest < ActiveSupport::TestCase
   #TODO verify fixture
  fixtures :assignment_questionnaires, :questionnaires, :assignments, :participants, :scores

  def setup
    @participant = AssignmentParticipant.new
  end

end
