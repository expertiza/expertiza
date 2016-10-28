require 'rails_helper'

feature 'Reset password mailer' do
  background do
    FactoryGirl.create :student
    # will clear the message queue
    clear_emails
    visit 'password_retrieval/forgotten'

    find('input#user_email', visible: false).set('expertiza@mailinator.com')
    click_button 'Request password'

    # Will find an email sent to expertiza.development@gmail.com and set `current_email`
    open_email('expertiza.development@gmail.com')
  end

  scenario 'testing for content' do
    expect(page).to have_current_path('/password_retrieval/forgotten')

    expect(current_email).to have_content 'Your Expertiza password has been reset. We strongly recommend that you change the password the next time you access the application.'
    expect(current_email).to have_content 'User Name'
    expect(current_email).to have_content 'New password'
  end
end

feature 'Welcome mailer' do
  background do
    create(:assignment)

    FactoryGirl.create :student
    # will clear the message queue
    clear_emails
    login_as("instructor6")
    visit '/users/new?role=Student'

    find('input#user_name', visible: false).set('Puma')
    find('input#user_fullname', visible: false).set('Qiaoxuan Xue')
    find('input#user_email', visible: false).set('expertiza@test.com')

    click_button 'Create'

    # Will find an email sent to expertiza.development@gmail.com and set `current_email`
    open_email('expertiza.development@gmail.com')
  end

  scenario 'testing for content' do
    expect(page).to have_current_path('/users/list')

    expect(current_email).to have_content 'Your Expertiza account has been created at http://expertiza.ncsu.edu. We strongly recommend that you change the password the first time you access the application.'
    expect(current_email).to have_content 'User Name'
    expect(current_email).to have_content 'E-mail address'
    expect(current_email).to have_content 'New password'
  end
end

feature 'New submission mailer' do
  background do

    # using the method called same as response.rb => email
    defn = {}
    defn[:body] = {}
    defn[:body][:partial_name] = 'new_submission'
    # will clear the message queue
    clear_emails
    Mailer.sync_message(defn).deliver_now
    # Will find an email sent to expertiza.development@gmail.com and set `current_email`
    open_email('expertiza.development@gmail.com')
  end

  scenario 'testing for content' do
    expect(current_email).to have_content 'assignment has just been entered'
  end
end