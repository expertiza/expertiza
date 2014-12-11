require_relative '../rails_helper'

describe 'Tests mailer' do
  it 'should send email to required email address with proper content ' do
    # Send the email, then test that it got queued
    email = Mailer.sync_message(
        {:to => 'tluo@ncsu.edu',
         :subject => "Test",
         :body => {
             :obj_name => 'assignment',
             :type => 'submission',
             :location => '1',
             :first_name => 'User',
             :partial_name => 'update'
         }
        }
    ).deliver

    expect(email.from[0]).to eql("expertiza.development@gmail.com")
    expect(email.to[0]).to eql('expertiza.development@gmail.com')
    expect(email.subject).to eql('Test')
    #assert_equal read_fixture('invite').join, email.body.to_s
  end
end
