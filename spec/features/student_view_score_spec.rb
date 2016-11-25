require 'rails_helper'
require 'spec_helper'
require_relative './helpers/login_helper'
require 'selenium-webdriver'
include LogInHelper

system 'mysql -u root -h localhost expertiza_test < spec/features/db/TestData.sql'
sleep(10)

feature 'view your scores' do
  scenario 'no scores available yet', :js=>true do
    log_in('student1', 'password')
    click_link "Assignment1"
    click_link "Your scores"
    expect(page). to have_content('0')
  end
  scenario 'scores available', :js=>true do
    log_in('student3', 'password')
    click_link "Assignment1"
    click_link "Your scores"
    click_link "show reviews"
    expect(page). to have_content('Review 1')
  end  
end
