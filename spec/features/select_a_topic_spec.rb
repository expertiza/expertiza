require 'rails_helper'
require 'spec_helper'

include LogInHelper
feature 'student select a topic' do
  scenario 'assignment available' do
    log_in('student4347', 'password')
    click_link('Ethical analysis 3')
    click_link('Signup sheet')
    first(:link, 'Check icon').click
    expect(page).to have_content "Your topic(s): Self-plagiarism "
  end


end


