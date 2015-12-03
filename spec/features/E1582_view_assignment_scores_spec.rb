require 'spec_helper'
feature 'View assignment scores' do
  scenario 'instructor view scores' do
    #login with instructor and password
    login_with 'instructor6', 'password'
    expect(page).to have_content('Manage content')
    #go to view assignments
    click_link( 'Assignments', match: :first)
    expect(page).to have_content('Assignments')
    #go to assignment chapter 11-12 madeup exercise scores
    visit '/grades/view?id=722'
    expect(page).to have_content('Class Average')
  end
  def login_with(username, password)
    visit root_path
    fill_in 'login_name', with: username
    fill_in 'login_password', with: password
    click_button 'SIGN IN'
  end
end