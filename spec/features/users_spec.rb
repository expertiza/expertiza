#require 'rails_helper'
#include LogInHelper
#
#feature 'Method 1: Instructor search a user' do
#  before(:all) do
#    instructor.save
#    student.save
#    log_in instructor.name, "password"
#  end
#
#  scenario 'by login name' do
#    
#    visit '/users/list'
#    fill_in 'letter', with: 'student'
#    find('#search_by').select 'Username'
#    click_button 'Search'
#
#    expect(page).to have_content("Student, Perfect")
#    expect(page).to have_content("pstudent@dev.null")
#  end
#end
#
#feature 'Method2: Instructor search a user' do
#  before(:all) do
#    instructor.save
#    student.save
#    log_in instructor.name, "password"
#  end
#
#  scenario 'by last or first name' do
#
#    visit '/users/list'
#    fill_in 'letter', with: 'Bob'
#    find('#search_by').select 'Full name'
#    click_button 'Search'
#
#    expect(page).to have_content("Dole, Bob")
#    expect(page).to have_content("bdole@dev.null")
#  end
#end
#
#feature 'Method3: Instructor search a user' do
#  before(:all) do
#    instructor.save
#    student.save
#    log_in instructor.name, "password"
#  end
#
#  scenario 'by email' do
#
#    visit '/users/list'
#    fill_in 'letter', with: 'bdole@dev.null'
#    find('#search_by').select 'Email'
#    click_button 'Search'
#
#    expect(page).to have_content("Dole, Bob")
#    expect(page).to have_content("bdole@dev.null")
#  end
#end
#
#feature 'Instructor attempts to delete a user' do
#  before(:all) do
#    instructor.save
#    student.save
#    log_in instructor.name, "password"
#  end
#
#  scenario 'who has not performed any actions' do
#    visit '/users/list'
#    #in order to show whole user list
#    fill_in 'letter', with: ''
#    find('#search_by').select 'Username'
#    click_button 'Search'
#    click_link 'student'
#    click_link 'Delete'
#    expect(page).to_not have_content("student")
#    expect(page).to have_content("instructor")
#  end
#end
