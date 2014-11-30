describe 'Student retrieves password', :type => :feature do
  # Student test users used in following scenarios.
  student1 = FactoryGirl.create :student


  scenario 'access by link' do
    visit root_path

    # Traverse to the password retrieval page by way of the link.
    click_link 'Forgotten your password?'

    expect(page).to have_content('Forgotten Your Password?')
  end


  scenario 'access after failed login' do
    visit root_path

    # Fail to log in as student1
    fill_in 'login_name', with: student1.name
    fill_in 'login_password', with: 'bogus'
    click_on 'Login'

    expect(page).to have_content('Incorrect Name/Password')
    expect(page).to have_content('Forgotten Your Password?')
  end


  scenario 'with valid e-mail' do
    visit root_path

    # Traverse to the password retrieval page by way of the link.
    click_link 'Forgotten your password?'

    expect(page).to have_content('Forgotten Your Password?')

    fill_in 'user_email', with: student1.email

    click_on 'Request password'

    expect(page).to have_content('A new password has been sent to your email address.')
  end


  scenario 'with invalid e-mail' do
    visit root_path

    # Traverse to the password retrieval page by way of the link.
    click_link 'Forgotten your password?'

    expect(page).to have_content('Forgotten Your Password?')

    # NOTE: The behavior of an improperly formatted and a non-existent 
    # e-mail address is the same.
    fill_in 'user_email', with: 'bogus'

    click_on 'Request password'

    expect(page).to have_content('No account is associated with the address, "' + student1.email + '". Please try again.')
  end
end

