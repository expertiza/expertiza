describe 'Student logs in', :type => :feature do

  scenario 'with valid username and password' do
    # Student test users used in following scenarios.
    student1 = FactoryGirl.create :student

    visit root_path

    # Log in as student1
    fill_in 'login_name', with: student1.name
    fill_in 'login_password', with: student1.password
    click_on 'Login'

    expect(page).to have_content(student1.name)

    # Leave system in state that doesn't mess up other tests.
    click_on 'Logout'
  end


  scenario 'with invalid user name' do
    # Student test users used in following scenarios.
    student1 = FactoryGirl.create :student

    visit root_path

    # Attempt to log in as an invalid student.
    fill_in 'login_name', with: 'bogus'
    fill_in 'login_password', with: student1.password
    click_on 'Login'

    expect(page).to have_content('Incorrect Name/Password')
  end


  scenario 'with valid user name and invalid password' do
    # Student test users used in following scenarios.
    student1 = FactoryGirl.create :student

    visit root_path

    fill_in 'login_name', with: student1.name
    fill_in 'login_password', with: 'bogus'
    click_on 'Login'

    expect(page).to have_content('Incorrect Name/Password')
  end


  scenario "with valid user name and another user's password" do
    # Student test users used in following scenarios.
    student1 = FactoryGirl.create :student
    student2 = FactoryGirl.create :alt_student

    visit root_path

    fill_in 'login_name', with: student1.name
    fill_in 'login_password', with: student2.password
    click_on 'Login'

    expect(page).to have_content('Incorrect Name/Password')
  end


  scenario 'with a blank password' do
    # Student test users used in following scenarios.
    student1 = FactoryGirl.create :student

    visit root_path

    fill_in 'login_name', with: student1.name
    fill_in 'login_password', with: ''
    click_on 'Login'

    expect(page).to have_content('Incorrect Name/Password')
  end
end
