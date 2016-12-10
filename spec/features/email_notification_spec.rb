require 'rails_helper'

feature 'Reset password notification' do
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

feature 'Welcome notification' do
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

feature 'New submission notification' do
  background do

    # using the method called same as response.rb => email
    student = FactoryGirl.create :student
    defn = {}
    defn[:body] = {}
    defn[:body][:partial_name] = 'new_submission'
    defn[:body][:first_name] = student.name
    # will clear the message queue
    clear_emails
    Mailer.sync_message(defn).deliver_now
    # Will find an email sent to expertiza.development@gmail.com and set `current_email`
    open_email('expertiza.development@gmail.com')
  end

  scenario 'testing for content' do
    expect(current_email).to have_content 'assignment has just been entered'
    expect(current_email).to have_content 'You may log into Expertiza and view it now'
    expect(current_email).to have_content 'Hi'
  end
end


feature 'Update assignment email notification' do
  background do
    student = FactoryGirl.create :student
    assignment = FactoryGirl.create :assignment
    # will clear the message queue
    clear_emails

    Mailer.sync_message(
        recipients: 'expertiza.development@gmail.com',
        subject: "One of the assignment#{assignment.name} is updated, you can review it now",
        body: {
            home_page: 'http://expertiza.ncsu.edu',
            first_name: ApplicationHelper.get_user_first_name(student),
            name: student.name,
            password: student.password,
            partial_name: "update"
        }
    ).deliver_now

    open_email('expertiza.development@gmail.com')
  end
  scenario 'testing for content' do
    expect(current_email).to have_content 'assignment has just been entered or revised.'
    expect(current_email).to have_content 'You may log into Expertiza and review the work now'
  end
end


feature 'Register notification' do
  background do
    defn = {}
    defn[:body] = {}
    defn[:body][:partial_name] = 'register'
    # will clear the message queue
    clear_emails
    Mailer.sync_message(defn).deliver_now
    # Will find an email sent to expertiza.development@gmail.com and set `current_email`
    open_email('expertiza.development@gmail.com')
  end

  scenario 'testing for content' do
    expect(current_email).to have_content "You have been registered to use the Expertiza system."
    expect(current_email).to have_content "You can access the system using the following URL"
    expect(current_email).to have_content "Please use the following information to log into Expertiza:"
  end
end