require 'test_helper'

class TeamControllerTest < ActionController::TestCase
  fixtures :invitations, :users, :participants
  setup do
end

 test "A sends invitation to B" do
    invitation1 = Invitation.new(:id=>1, :assignment_id=>9, from_id => 10,to_id => 11, reply_status =>'W')
    invitation1.save
    assert_response :success
  end

# B should fail to send an invitation to A since B has already received an invitation from A
  test "B should fail to send invitation to A" do
    invitation2 = Invitation.new(:id=>2, :assignment_id=>9, from_id => 11,to_id => 10, reply_status =>'W')
    invitation2.save
    assert_response :fail
  end
end
