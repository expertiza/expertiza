require 'rails_helper'
require 'spec_helper'
require_relative './helpers/login_helper'
require 'selenium-webdriver'
include LogInHelper

system 'mysql -u root -h localhost expertiza_test < spec/features/db/TestData.sql'
sleep(10)

feature 'review feedback' do
  scenario 'give feedback to reviewer', :js=>true do
    log_in('student3', 'password')
    click_link 'Assignment1'
    click_link 'Your scores'
    click_link 'show reviews'
    Capybara.match = :first
    click_link 'Give feedback'
    fill_in 'responses_0_comments', with: 'feedback test 0'
    fill_in 'responses_1_comments', with: 'feedback test 1'
    fill_in 'responses_2_comments', with: 'feedback test 2'
    fill_in 'review_comments', with: 'feedback test 3'
    click_button 'Save Feedback'
    expect(page). to have_content('Your response was successfully saved.')
  end  
end
