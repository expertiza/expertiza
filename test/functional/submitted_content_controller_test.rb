require File.dirname(__FILE__) + '/../test_helper'

class SubmittedContentControllerTest < ActionController::TestCase
  fixtures :courses, :teams, :users, :teams_users, :participants, :assignments, :nodes, :roles

  def setup
   @request.session[:user] = User.find(users(:student1).id)
  end

  def test_remove_hp

    participant = AssignmentParticipant.find(participants(:participant1).id)
    count1 = 0
    participant.hyperlinks_array.each do
      count1 += 1
    end
    post :remove_hyperlink, :id => participants(:participant1).id, :chk_links => '1'

    count2 = 0
    participant = AssignmentParticipant.find((participants(:participant1).id))
    participant.hyperlinks_array.each do
      count2 += 1
    end
    assert_equal count1 - 1, count2
  end
end