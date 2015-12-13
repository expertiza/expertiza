require 'rails_helper'
require 'spec_helper'
require_relative './helpers/login_helper'
require 'selenium-webdriver'
include LogInHelper

feature 'student select a topic',:js=>true do
  scenario 'user has already signed up a topic for this assignment' do
    page.driver.browser.manage.window.maximize
    log_in('student1', 'password')
    click_link('Assignment1')
    click_link('Signup sheet')
    first(:link, 'Check icon').click
    expect(page).to have_content "Your topic(s): Topic1 "
  end


end


