describe 'Tests mailer' do
  it 'should send email to required email address with proper content ' do
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

    expect(email.from[0]).to eq('expertiza.mailer@gmail.com')
    expect(email.to[0]).to eq('expertiza.mailer@gmail.com')
    expect(email.subject).to eq('Test')
  end

  describe '#email_author_reviewers' do
    let(:subject) { 'Test Subject' }
    let(:body) { 'Test Body' }
    let(:email) { 'test@example.com' }

    let(:mail) { Mailer.email_author_reviewers(subject, body, email) }

    it 'renders the body' do
      expect(mail.body.encoded).to match(body)
    end

    it 'renders the content type as html' do
      expect(mail.content_type).to start_with('text/html')
    end

    it 'renders the sender email' do
      expect(mail.from).to eq(['expertiza.mailer@gmail.com'])
    end
  end

  describe '#generic_message' do
    let(:defn) do
      {
        subject: 'Generic Message Subject',
        to: 'recipient@example.com',
        bcc: 'bcc@example.com',
        body: {
          partial_name: 'test_partial',
          user: create(:user),
          first_name: 'John',
          password: 'password123',
          new_pct: 90,
          avg_pct: 85,
          assignment: create(:assignment),
          conference_variable: 'conference',
          team_name: 'Test Team'
        }
      }
    end
  end
end
