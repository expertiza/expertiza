describe 'Student views scores', :type => :feature do
  # Student test users used in following scenarios.
  student1 = FactoryGirl.create :student
  # TODO: Add FactoryGirl code here to create an assignment
  #     for student1 that is already scored.


  scenario 'viewing student scores' do
    visit root_path

    fill_in 'login_name', with: student1.name
    fill_in 'login_password', with: 'bogus'
    click_on 'Login'

    expect(page).to have_content(student1.name)

    # TODO: Need to make sure that this assignment exists in test data.
    click_on 'assignment'
  end
end

