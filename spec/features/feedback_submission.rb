require 'rails_helper'
require 'spec_helper'

RSpec.feature 'feedback submission when unlogged user' do

  # Before all block runs once before all the scenarios are tested
  before(:all) do
    feedback_settings = FactoryGirl.create(:feedback_setting)
    feedback_attachment_setting = FactoryGirl.create(:feedback_attachment_setting)
    #role = FactoryGirl.create(:role)
    user = FactoryGirl.create(:user)
  end

  before(:each) do
    visit root_path
  end

  # Scenario to check whether feedback link is present
  scenario 'visits homepage and finds link' do
    expect(page).to have_content 'Report An Error'
  end

  # Scenario to check that user is not able to submit feedback with unregistered  email
  scenario 'enters invalid user email' do
    click_on 'Report An Error'
    fill_in 'Email', :with => 'a@expertiza.com'
    fill_in 'Title', :with => 'This is test title'
    fill_in 'Description', :with => 'This is test description'
    click_on 'Submit'
    expect(page).to have_content 'Please enter your registered email to Expertiza'
  end

  # Scenario to check that user is not able to submit feedback without email
  scenario 'enters no email' do
    click_on 'Report An Error'
    fill_in 'Email', :with => ''
    fill_in 'Title', :with => 'This is test title'
    fill_in 'Description', :with => 'This is test description'
    click_on 'Submit'
    expect(page).to have_content 'Please enter your registered email to Expertiza'
  end

  # Scenario to check that user is not able to submit feedback without title
  scenario 'enters no title' do
    click_on 'Report An Error'
    fill_in 'Email', :with => 'a@a.com'
    fill_in 'Title', :with => ''
    fill_in 'Description', :with => 'This is test description'
    click_on 'Submit'
    expect(page).to have_content 'This is not allowed to index this feedbacks'
  end

  # Scenario to check that user is not able to submit feedback with an invalid attachment
  scenario 'attaches unsupported file extension'  do
    click_on 'Report An Error'
    fill_in 'Email', :with => 'a@a.com'
    fill_in 'Title', :with => 'This is test title'
    fill_in 'Description', :with => 'This is test description'
    attach_file('feedback_attachment',File.absolute_path('./prototype.js'))
    click_on 'Submit'
    expect(page).to have_content 'The file extension is not supported'
  end

  # Scenario to check that user is able to submit feedback with attachment and without description
  scenario 'enters no description but valid attachment'  do
    click_on 'Report An Error'
    fill_in 'Email', :with => 'a@a.com'
    fill_in 'Title', :with => 'This is test title'
    fill_in 'Description', :with => ''
    attach_file('feedback_attachment',File.absolute_path('./spec/rails_helper.rb'))
    click_on 'Submit'
    expect(page).to have_content 'Feedback was successfully created'
  end

end