describe 'Student logs in', :type => :feature do
  it 'with valid username and password' do
    student1 = FactoryGirl.create :student
    student2 = FactoryGirl.create :student

    visit root_path

    # Log in as student1
    fill_in 'login_name', with: student1.name
    fill_in 'login_password', with: student1.password
    click_on 'Login'
    click_on 'Logout'


    # Create a team
#    fill_in 'team_name', with: 'TestTeamName'
#    click_on 'Create Team'
#
#    # Expect team name to be displayed
#    expect(page).to have_content('TestTeamName')
#
#    # Invite student2 to the team
#    fill_in 'user_name', with: student2.name
#    click_on 'Invite'
#
#    # Expect student2 to show up under 'Sent Invitations'
#    expect(page).to have_content(student2.name)
  end
end


# Stuff pulled in from design document that needs to be reworked.

#    scenario ‘with valid username and password’ do
#        log_in_with ‘student1’, ‘password’
#
#        expect(page).to have_content(‘User: ’ + username)
#    end
#
#    scenario ‘with invalid password’ do
#        log_in_with ‘student1’, ‘badpassword’
#
#        expect(page).to have_content(‘Incorrect Name/Password’)
#    end
#
#    scenario ‘with invalid username’ do
#        log_in_with ‘bogus’, ‘password’
#
#        expect(page).to have_content(‘Incorrect Name/Password’)
#    end
#
#    scenario ‘with blank password’ do
#        log_in_with ‘student1’, ‘’
#
#        expect(page).to have_content(‘Incorrect Name/Password’)
#    end
#
#def log_in_with(username, password)
#  visit root_path
#  fill_in ‘login_name’, with: username
#  fill_in ‘login_password’, with: password
#  click_button ‘Login’
#end
#end
#
#feature ‘Student retrieves password’ do
#    scenario ‘with valid email’ do
#        request_password_for(email)
#
#        expect(page).to have_content(‘No account is associated with the address, "’ + username + ‘". Please try again.’)
#    end
#
#    scenario ‘with valid username’ do
#        request_password_for(username)
#
#        expect(page).to have_content(‘A new password has been sent to your email address.’)
#    end
#
#    def request_password_for(email)
#        visit forgotten_path
#        fill_in ‘user_email’, with: email
#        click_button ‘Request password’
#    end
#end
#
