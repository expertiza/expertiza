require 'rails_helper'
require 'spec_helper'
require 'selenium-webdriver'
require_relative './helpers/login_helper'

include LogInHelper
feature 'student select a submission to review',:js=>true do
  scenario 'assignment available' do
    page.driver.browser.manage.window.maximize
    log_in('student1', 'password')
    click_link('Assignments')
    click_link('Assignment1')
    click_link("Others' work")
    expect(page).to have_content 'Reviews for "Assignment1" '
  end
end
