require 'rails_helper'

describe 'should not view inherit teams' do

  it 'should display inherit teams while creating an assignment team' do
    create(:assignment)
    create(:assignment_node)
    create(:assignment_team)

    login_as("instructor6")
    visit '/teams/list?id=1&type=Assignment'
    click_link 'Create Team'
    expect(page).to have_content('Inherit Teams From Course')
  end

end
