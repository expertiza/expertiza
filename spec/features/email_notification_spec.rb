require 'rails_helper'
require 'capybara/email/rspec'


describe 'Test send email functionality' do

  context 'when a user is created' do

    it 'should send an welcome email to a user' do

      student = FactoryGirl.create :student
      email = MailerHelper.send_mail_to_user(student, "Your Expertiza account and password have been created", "user_welcome", student.password).deliver_now
      expect(email.subject).to eq('Your Expertiza account and password have been created')
      expect(email.from[0]).to eq("expertiza.development@gmail.com")
      expect(email.to[0]).to eq("expertiza.development@gmail.com")

    end

  end

  context 'When a user rests his password' do

    it 'should send an email with new password' do

      student = FactoryGirl.create :student
      password = student.reset_password # the password is reset

      expect {
        MailerHelper.send_mail_to_user(
            student,
            "Your Expertiza password has been reset",
            "send_password",
            password).deliver_now}.to change { ActionMailer::Base.deliveries.count }.by(1)

    end

  end


  it 'should be able to send a suggested_topic_approved_message' do

  end

end

feature 'mailer' do
  background do
    # will clear the message queue
    student = FactoryGirl.create :student
    clear_emails
    visit 'password_retrieval/forgotten'
    expect(page).to have_current_path('/password_retrieval/forgotten')

    find('input#user_email', visible: false).set('expertiza@mailinator.com')

    click_button 'Request password'

    expect(page).to have_content('A new password')
    # Will find an email sent to test@example.com
    # and set `current_email`
    open_email('expertiza.development@gmail.com')
  end

  scenario 'testing for content' do
    expect(current_email).to have_content 'Your'
  end
  #
  # scenario 'testing for a custom header' do
  #   expect(current_email.headers).to include 'header-key'
  # end
  #
  # scenario 'testing for a custom header value' do
  #   expect(current_email.header('header-key')).to eq 'header_value'
  # end
  #
  # scenario 'view the email body in your browser' do
  #   # the `launchy` gem is required
  #   current_email.save_and_open
  # end
end