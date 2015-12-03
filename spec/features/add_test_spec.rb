require 'rails_helper'
require 'spec_helper'
require_relative './helpers/login_helper'
include LogInHelper

feature 'Add someone to a team' do
scenario 'send invitation work' do
  def send_invi
    click_link "Ethical analysis 2"
    click_link "Your team"
    fill_in 'user_name', with: 'student4347'
    click_button 'Invite'

  end

  # sign in
  log_in('student4346', 'password')
  # send invitation
  send_invi
  #expect(page).to have_content "Waiting for reply"
  #click_link 'Logout'




=begin
  # sign in as the receiver
  log_in('student4347','password')
  click_link "Ethical analysis 2"
  click_link "Your team"

  # Click accept
  expect(page). to have_content('student4346')
=end

  #click_link 'Accept'

  # Click accept

  # log out

  # sign in as invitation sender

  # In Your team view should appear receiver name




  page.visit '/sessions/new'
  expect(page). to have_content('student43xdd46')
=begin
  log_in('student4347','password')
  click_link 'Ethical analysis 2'
  click_link "Your team"
  expect(page). to have_content('student4346')
=end






end






end