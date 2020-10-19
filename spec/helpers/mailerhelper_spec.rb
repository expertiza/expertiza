describe 'Tests MailerHelper' do
    let(:super_user) do
        User.new name: 'superabc', fullname: 'superabc xyz', email: 'abcxyz@gmail.com', password: '12345678', password_confirmation: '12345678',
                 email_on_submission: 1, email_on_review: 1, email_on_review_of_review: 0, copy_of_emails: 1, handle: 'handle'
    end

    let(:user) do
      User.new name: 'abc', fullname: 'abc xyz', email: 'abcxyz@gmail.com', password: '12345678', password_confirmation: '12345678',
               email_on_submission: 1, email_on_review: 1, email_on_review_of_review: 0, copy_of_emails: 1, handle: 'handle'
  end
    
    
  before do
    @subject = "Test"
    @partial_name = "new_submission"
    @password = "pa$Sw0rD"
    @mail_partial = "new_submission"
  end

  it 'Check if send_mail_to_all_super_users can properly send emails to super_users' do 
    ActionMailer::Base.deliveries.clear
    
    MailerHelper.submission_mail_to_reviewer(
      user, @subject, @mail_partial
    ).deliver_now

    email = Mailer.notify_reviewer_for_new_submission(
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
    ActionMailer::Base.deliveries.last.tap do |mail|
        expect(mail.from).to eq(["expertiza.development@gmail.com"])
        expect(mail.to).to eq(["abcxyz@gmail.com"])
        expect(mail.subject).to eq("Test")
      end
  end


    it 'Check if send_mail_to_user can properly send emails using generic message' do 
      ActionMailer::Base.deliveries.clear
      MailerHelper.send_mail_to_user(
          user, @subject, @partial_name, @password
      ).deliver_now

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
      ActionMailer::Base.deliveries.last.tap do |mail|
          expect(mail.from).to eq(["expertiza.development@gmail.com"])
          expect(mail.to).to eq(["expertiza.development@gmail.com"])
          expect(mail.subject).to eq("Test")
        end
  end
end
  
