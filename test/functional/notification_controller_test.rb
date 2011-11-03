require 'test_helper'

class NotificationControllerTest < ActionController::TestCase
   
  def test_invite_friend
      puts "Deliveries #{ActionMailer::Base.deliveries}"
      assert_difference('ActionMailer::Base.deliveries.size', +1) do
        post :controller, :email => 'friend@example.com'
      end
      invite_email = ActionMailer::Base.deliveries.first
      assert_equal invite_email.subject, "You have been invited by me@example.com"
      assert_equal invite_email.to[0], 'friend@example.com'
      assert_match /Hi friend@example.com/, invite_email.body
    end
  end
