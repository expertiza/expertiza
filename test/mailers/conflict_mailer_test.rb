require 'test_helper'

class ConflictMailerTest < ActionMailer::TestCase
  test "send_conflict_email" do
    mail = ConflictMailer.send_conflict_email
    assert_equal "Send conflict email", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

end
