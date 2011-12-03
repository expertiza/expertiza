require File.dirname(__FILE__) + '/../test_helper'

class score_test < ActiveSupport::TestCase
  def setup
    @assignment_id = 308  #Final Project
    @existingParticipant_id = 11458 #name2140 on assgt 308
    @ReviewQuestionnaire_id = 14
    @user_id = 44

    @newParticipant_id = Participant.create(:user_id => @user_id,
                                            :parent_id => @assignment_id ).id
    @newTeam_id = Team.create(:name=> "stest team", :parent_id => @assignment_id).id
    TeamsUser.create(:team_id => @newTeam_id, :user_id => @user_id)
    puts @newTeam_id
    @ReviewQuestionnaire_id
    @existingParticipant_id = 11458 #user 2140 on assgt 308
  end
  def test_create_score
    map = ResponseMap.create(:reviewed_object_id => @assignment_id,
                                  :reviewer_id => @existingParticipant_id,
                                  :reviewee_id => @newTeam_id)
    count = Score.count
    response = Response.create(:map_id => map.id)
    questions = Question.find_all_by_questionnaire_id(
        @ReviewQuestionnaire_id )
    Score.create(:question_id=> :response=>Response.last,:grade=>3 )
    assert count==count+1
  end

end