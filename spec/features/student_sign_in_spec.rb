require 'rails_helper'
require 'spec_helper'
require_relative './helpers/login_helper'
include LogInHelper
feature 'student sign in' do
  scenario 'with Invalid email and password' do
    # jump to student task list
    log_in('student', 'adadsd')
    expect(page).to have_content "Incorrect Name"
  end

  scenario 'with valid email or password' do
    # jump to password retrieve page
    log_in('student1', 'password')
    expect(page).to have_content 'User: student1'

  end


end
