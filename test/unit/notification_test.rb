require 'test_helper'


class NotificationTest < ActionMailer::TestCase
  tests Mailer
  test "test_invite" do
    #@expected.from    = 'customercare.quickfix@example.com'
    @expected.to      = 'vsing3@ncsu.edu'
    @expected.subject = "subject1"
    @expected.content_type = 'text/html'
    @expected.charset = 'utf-8'
    @expected.body    = read_fixture('invite.html')
    @expected.date = Time.now 
    
    assert_not_nil(Mailer, "Mailer is nil")
    
    mail_message = {:recipients => "vsing3@ncsu.edu",
     :subject => "subject1",
     :body => {
      :obj_name => self.name,
      :type => "submission",
      :location => "location",
      :first_name => "FNU",
      :partial_name => "testing"
      }
    }
    assert_equal @expected.encoded, Mailer.deliver_message(mail_message).encoded
  end
end
