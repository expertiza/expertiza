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
  scenario 'send the invitation as sender' do

    # sign in

    log_in('student4346', 'password')

    # send invitation
    send_invi
    expect(page). to have_content('Waitings for reply')
  end

end
