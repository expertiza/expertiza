require 'rails_helper'
require 'spec_helper'
require_relative './helpers/login_helper'
include LogInHelper

system 'mysql -u root -h localhost expertiza_test < spec/features/db/TestData.sql'
sleep(10)

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
