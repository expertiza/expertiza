describe 'Tests mailer' do
  it '1. should send email to required email address with proper content' do
    # Send the email, then test that it got queued
    email = Mailer.sync_message(
      to: 'tluo@ncsu.edu',
      subject: 'Test',
      body: {
        obj_name: 'assignment',
        type: 'submission',
        location: '1',
        first_name: 'User',
        partial_name: 'update'
      }
    ).deliver_now

    expect(email.from[0]).to eq('expertiza.debugging@gmail.com')
    expect(email.to[0]).to eq('expertiza.debugging@gmail.com')
    expect(email.subject).to eq('Test')
  end

  it '2. test method: email_author_reviewers' do 
    # https://stackoverflow.com/questions/17088619/how-can-you-call-class-methods-on-mailers-when-theyre-not-defined-as-such
    mailer = Mailer.new
    email = mailer.email_author_reviewers('Mailer spec test method: email_author_reviewers', 'Body', 'mzdacana@ncsu.edu').deliver
    expect(email.from[0]).to eq('expertiza.debugging@gmail.com')
    expect(email.to[0]).to eq('expertiza.debugging@gmail.com')
    expect(email.subject).to eq('Mailer spec test method: email_author_reviewers')
  end

  it '3. request_user_message' do 
  end
end
