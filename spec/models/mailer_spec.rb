describe 'Tests mailer' do
  it 'should send email to required email address with proper content ' do
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
  it 'should correctly populate the template with the right partial ' do
    # Send the email, then test that it got queued
    email = Mailer.sync_message(
      to: 'oigewe@ncsu.edu',
      subject: "Test",
      body: {
        obj_name: 'assignment',
        type: 'submission',
        first_name: 'User',
        partial_name: 'updated_submission_since_review'
      }
    ).deliver_now

    expect(email.from[0]).to eq("expertiza.development@gmail.com")
    expect(email.to[0]).to eq('expertiza.development@gmail.com')
    expect(email.subject).to eq('Test')
    # expect(email.body.to_s).to eq('asd') FIXME Not sure how to get the body of the email
  end
end
