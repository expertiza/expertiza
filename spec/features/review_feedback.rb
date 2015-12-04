require 'rails_helper'
require 'spec_helper'
require_relative './helpers/login_helper'
require 'selenium-webdriver'
include LogInHelper


feature 'review feedback' do
  scenario 'give feedback to reviewer', :js=>true do
    log_in('student2656', 'password')
    click_link 'Ethical analysis'
    click_link 'Your scores'
    click_link 'show reviews'
    Capybara.match = :first
    click_link 'Give feedback'
    fill_in 'responses_0_comments', with: 'feedback test 0'
    fill_in 'responses_1_comments', with: 'feedback test 1'
    fill_in 'responses_2_comments', with: 'feedback test 2'
    select('3', :from => 'responses_0_score')
    select('4', :from => 'responses_1_score')
    select('5', :from => 'responses_2_score')
    fill_in 'review_comments', with: 'feedback test 3'
    click_button 'Save Feedback'
    expect(page). to have_content('Your response was successfully saved.')
  end  
end