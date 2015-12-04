require 'rails_helper'
require 'spec_helper'
require_relative './helpers/login_helper'
require 'selenium-webdriver'
include LogInHelper

feature 'view your scores' do
  scenario 'no scores available yet', :js=>true do
    log_in('student4346', 'password')
    click_link "Ethical analysis 3"
    click_link "Your scores"
    expect(page). to have_content('0.00%')
  end
  scenario 'scores available', :js=>true do
    log_in('student4346', 'password')
    click_link "Ethical analysis"
    click_link "Your scores"
    expect(page). to have_content('78.33%')
  end  
end