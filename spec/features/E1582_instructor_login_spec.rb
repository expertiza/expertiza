require 'spec_helper'

#describe "E1582. Create integration tests for the instructor interface using capybara and rspec" do
#  describe "Test1: login" do
#     it "should be able to login" do
#       visit 'content_pages/view'
#
#       fill_in "User Name", with: 'instructor6'
#       fill_in "Password", with: 'password'
#       click_button "SIGN IN"
#
#       expect(page).to have_content("Manage content")
#     end
#  end
#end


feature 'Instructor login' do
  scenario 'with valid username and password' do
    login_with 'instructor6', 'password'

    expect(page).to have_content('Manage content')
  end

  scenario 'with invalid username' do
    login_with 'instructor', 'password'

    expect(page).to have_content('Incorrect Name/Password')
  end

  scenario 'with invalid password' do
    login_with 'instructor6', 'passwordrowssap'

    expect(page).to have_content('Incorrect Name/Password')
  end

  def login_with(username, password)
    visit root_path
    fill_in 'login_name', with: username
    fill_in 'login_password', with: password
    click_button 'SIGN IN'
  end
end
