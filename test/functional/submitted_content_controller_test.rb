require File.dirname(__FILE__) + '/../test_helper'

class SubmittedContentControllerTest < ActionController::TestCase
  fixtures :participants
  fixtures :users

  def setup
   @request.session[:user] = User.find(users(:student1).id)
  end

  def test_remove_hp

    participant = AssignmentParticipant.find(participants(:par1).id)
    count1 = 0
    participant.get_hyperlinks.each do
      count1 += 1
    end
    post :remove_hyperlink, :id => participants(:par1).id, :chk_links => '1'

    count2 = 0
    participant = AssignmentParticipant.find((participants(:par1).id))
    participant.get_hyperlinks.each do
      count2 += 1
    end
    assert_equal count1 - 1, count2
  end
end