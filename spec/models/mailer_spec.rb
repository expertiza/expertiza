describe 'Tests mailer' do
  let(:assignment) {
    build(:assignment, name: "test_assignment")
  }

  it 'should be able to pass parameters to generic message' do
    # Send the email, then test that it got queued
    email = Mailer.generic_message(
      to: 'tluo@ncsu.edu',
      subject: "Test",
      body: {
        partial_name: "new_submission",
        user: "John Doe",
        first_name: "John",
        password: "Password",
        new_pct: 97,
        avg_pct: 90,
        assignment: "code assignment"
      }
    )
    expect(email.from[0]).to eq("expertiza.development@gmail.com")
    expect(email.to[0]).to eq('expertiza.development@gmail.com')
    expect(email.subject).to eq('Test')
  end

  it 'should be able to send an email using generic message' do
    ActionMailer::Base.deliveries.clear

    email = Mailer.generic_message(
      to: 'tluo@ncsu.edu',
      subject: "Test",
      body: {
        partial_name: "new_submission",
        user: "John Doe",
        first_name: "John",
        password: "Password",
        new_pct: 97,
        avg_pct: 90,
        assignment: "code assignment"
      }
    ).deliver_now

    ActionMailer::Base.deliveries.last.tap do |mail|
      expect(mail.from).to eq(["expertiza.development@gmail.com"])
      expect(mail.to).to eq(["expertiza.development@gmail.com"])
      expect(mail.subject).to eq("Test")
      expect(mail.body).to eq(email.body)
    end
  end

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

  it 'should send email with a suggested topic is approved' do
    # Send the email, then test that it got queued
    email = Mailer.suggested_topic_approved_message(
      to: 'tluo@ncsu.edu',
      cc: 'tluo2@ncsu.edu',
      subject: "Suggested topic 'Test' has been approved",
      body: {
        approved_topic_name: 'assignment',
        proposer: 'User'
      }
    ).deliver_now
    expect(email.from[0]).to eq("expertiza.development@gmail.com")
    expect(email.to[0]).to eq('expertiza.development@gmail.com')
    expect(email.bcc[0]).to eq('expertiza.development@gmail.com')
    expect(email.subject).to eq("Suggested topic 'Test' has been approved")
  end

  it 'should send email to required email address when score is outside acceptable value ' do
    # Send the email, then test that it got queued
    email = Mailer.notify_grade_conflict_message(
      to: 'tluo@ncsu.edu',
      subject: "Test",
      body: {
        assignment: assignment,
        type: 'review',
        reviewer_name: 'Reviewer',
        reviewee_name: 'Reviewee',
        new_score: 0.95,
        conflicting_response_url: 'https://expertiza.ncsu.edu/response/view?id=1',
        summary_url: 'https://expertiza.ncsu.edu/grades/view_team?id=1',
        assignment_edit_url: 'https://expertiza.ncsu.edu/assignments/1/edit'
      }
    ).deliver_now

    expect(email.from[0]).to eq("expertiza.development@gmail.com")
    expect(email.to[0]).to eq('expertiza.development@gmail.com')
    expect(email.subject).to eq('Test')
  end
end
