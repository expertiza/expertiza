require 'rails_helper'
require 'spec_helper'
include LogInHelper
feature 'student select a topic' do
  scenario 'assignment available' do
    log_in('student4349', 'password')
    click_link('Assignments')
    click_link('Ethical analysis 3')
    click_link("Others' work")
    expect(page).to have_content 'Reviews for "Ethical analysis 3" '
  end
end