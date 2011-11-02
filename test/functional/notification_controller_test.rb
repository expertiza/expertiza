require 'test_helper'

# class NotificationControllerTest < ActionController::TestCase
#   # Replace this with your real tests.
#   test "the truth" do
#     assert true
#   end
# end

class UserControllerTest < ActionController::TestCase
  test "invite friend" do
    assert_difference 'ActionMailer::Base.deliveries.size', +1 do
      post :invite_friend, :email => 'friend@example.com'
    end
    invite_email = ActionMailer::Base.deliveries.first
 
    assert_equal "You have been invited by me@example.com", invite_email.subject
    assert_equal 'friend@example.com', invite_email.to[0]
    assert_match(/Hi friend@example.com/, invite_email.body)
  end
end