require 'rails_helper'
require 'spec_helper'
require_relative './helpers/login_helper'
include LogInHelper

def send_invi

  click_link "Ethical analysis 2"
  click_link "Your team"
  fill_in 'user_name', with: 'student4347'
  click_button 'Invite'
end

feature 'Add someone to a team' do
  scenario 'add' do

    # sign in

    log_in('student4346', 'password')

    # send invitation
    send_invi
    expect(page). to have_content('Waitings for reply')
    # log out
    #click_link 'Logout'

=begin
  # sign in as the receiver
  log_in('student4347','password')
  click_link "Ethical analysis 2"
  click_link "Your team"

  # Click accept
  expect(page). to have_content('student4346')
  click_link 'Accept'

  # log out
  click_link 'Logout'

  # sign in as invitation sender
  log_in('student4346', 'password')

  # In Your team view should appear receiver name

  click_link "Ethical analysis 2"
  click_link "Your team"
 # expect(page). to have_content('student4347')
=end

  end

end
