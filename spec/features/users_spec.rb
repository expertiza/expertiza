require 'rails_helper'
include LogInHelper

feature 'Users' do
  before(:each) do
    instructor.save
    student.save
  end

  scenario 'are searched by username by an instructor' do
    log_in instructor.name, "password"

    visit '/users/list'
    fill_in 'letter', with: 'ude'
    find('#search_by').select 'Username'
    click_button 'Search'

    expect(page).to have_content("student")
    expect(page).to_not have_content("admin@mailinator")
  end
end
