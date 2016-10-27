require 'rails_helper'

describe 'Tests mailer' do
  it 'should send an email' do
    expect { Mailer.sync_message(
                to: 'qxue4@ncsu.edu',
                subject: "Test",
                body: {
                    obj_name: 'assignment',
                    type: 'submission',
                    location: '1',
                    first_name: 'User',
                    partial_name: 'update'
                }
            ).deliver_now }.to change { ActionMailer::Base.deliveries.count }.by(1)
  end

  it 'should send an email with correct content' do
    # Send the email, then test that it got queued
    email = Mailer.sync_message(
        to: 'tluo@ncsu.edu',
        subject: "Test",
        body: {
            obj_name: 'assignment',
            type: 'submission',
            location: '1',
            first_name: 'User',
            partial_name: 'update'
        }
    ).deliver_now

    expect(email.from[0]).to eq("expertiza.development@gmail.com")
    expect(email.to[0]).to eq('expertiza.development@gmail.com')

    expect(email.subject).to eq('Test')
  end
end
