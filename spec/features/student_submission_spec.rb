require 'rails_helper'
require 'spec_helper'


RSpec.feature 'student assignment submission' do

  scenario 'student with invalid credentials' do
    visit root_path
    fill_in 'User Name', :with => 'student13'
    fill_in 'Password', :with => 'student13'
    click_on 'SIGN IN'
    expect(page).to have_content 'Incorrect Name/Password'
  end

  @login
  scenario 'student with valid credentials' do
    #visit root_path
    #fill_in 'User Name', :with => 'student13'
    #fill_in 'Password', :with => 'password'
    #click_on 'SIGN IN'
    expect(page).to have_content 'Assignment'
  end

  scenario 'submitting only valid link to ongoing assignment' do
    visit root_path
    fill_in 'User Name', :with => 'student13'
    fill_in 'Password', :with => 'password'
    click_on 'SIGN IN'
    click_on 'WCAE 2015'
    click_on 'Your work'
    fill_in 'submission', :with => 'http://www.csc.ncsu.edu/faculty/efg/517/f15/schedule'
    click_on 'Upload link'
    expect(page).to have_content 'http://www.csc.ncsu.edu/faculty/efg/517/f15/schedule'
  end

  scenario 'submitting only invalid link to ongoing assignment' do
    visit root_path
    fill_in 'User Name', :with => 'student13'
    fill_in 'Password', :with => 'password'
    click_on 'SIGN IN'
    click_on 'WCAE 2015'
    click_on 'Your work'
    fill_in 'submission', :with => 'http://'
    click_on 'Upload link'
    expect(page).to have_content 'bad URI(absolute but no path)'
  end

  scenario 'submitting only existing file to ongoing assignment' do
    visit root_path
    fill_in 'User Name', :with => 'student13'
    fill_in 'Password', :with => 'password'
    click_on 'SIGN IN'
    click_on 'WCAE 2015'
    click_on 'Your work'
    attach_file('uploaded_file', File.absolute_path('./spec/features/student_submission_spec.rb'))
    click_on 'Upload file'
    expect(page).to have_content 'student_submission_spec.rb'
  end

  scenario 'submitting link and file to ongoing assignment' do
    visit root_path
    fill_in 'User Name', :with => 'student13'
    fill_in 'Password', :with => 'password'
    click_on 'SIGN IN'
    click_on 'WCAE 2015'
    click_on 'Your work'
    fill_in 'submission', :with => 'http://www.csc.ncsu.edu/faculty/efg/517/f15/assignments'
    click_on 'Upload link'
    attach_file('uploaded_file', File.absolute_path('./spec/features/users_spec.rb'))
    click_on 'Upload file'
    expect(page).to have_content 'http://www.csc.ncsu.edu/faculty/efg/517/f15/assignments'
    expect(page).to have_content 'users_spec.rb'
  end

  scenario 'submitting link for finished assignment'  do
    visit root_path
    fill_in 'User Name', :with => 'student13'
    fill_in 'Password', :with => 'password'
    click_on 'SIGN IN'
    click_on 'SCOE'
    click_on 'Your work'
    expect(page).to have_no_button('Upload link')
  end

  scenario 'submitting file for finished assignment' do
    visit root_path
    fill_in 'User Name', :with => 'student13'
    fill_in 'Password', :with => 'password'
    click_on 'SIGN IN'
    click_on 'SCOE'
    click_on 'Your work'
    expect(page).to have_no_button('Upload file')
  end

end