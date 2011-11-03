require 'test_helper'

# #class NotificationTest < ActiveSupport::TestCase
# class UserMailerTest < ActionMailer::TestCase
#   # Replace this with your real tests.
#   
#   fixtures :users
#   
#   test "the truth" do
#     assert true
#   end
#   
#   test "invite" do
#         @expected.from    = 'me@example.com'
#         @expected.to      = 'friend@example.com'
#         @expected.subject = "You have been invited by #{@expected.from}"
#         @expected.body    = read_fixture('invite')
#         @expected.date    = Time.now
#         assert_equal @expected.encoded, UserMailer.create_invite('me@example.com', 'friend@example.com', @expected.date).encoded
#   end
#   
#    # assert_select_email do
#    #       assert_select "h1", "Email alert"
#    #   end
#   
#   test "required fields" do                 
#       user1 = users(:student1)
#       assert(!user1.valid?)
#       user2 =users(:student2)
#       assert(!user2.valid?)
#   end
#   
# end
   
   class MailerTest < ActionMailer::TestCase
     tests Mailer
       def test_invite 
         @expected.from    = 'me@example.com'
         @expected.to      = 'friend@example.com'
         @expected.subject = "You have been invited by #{@expected.from}"
         @expected.body    = read_fixture('invite')
         @expected.date    = Time.now
         
         assert_equal @expected.encoded, Mailer.message('me@example.com', 'friend@example.com', @expected.date).encoded
       end
    
     end
  
