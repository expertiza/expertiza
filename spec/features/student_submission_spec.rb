require 'rails_helper'
require 'spec_helper'


RSpec.feature 'student login process' do
  scenario 'with valid email and password', :js => true do
    student = FactoryGirl.create(:user)
    visit root_path
    fill_in 'User Name', :with => student.name
    fill_in 'Password', :with => student.password
    click_on 'SIGN IN'
    expect(page).to have_content 'Assignments'
  end
end