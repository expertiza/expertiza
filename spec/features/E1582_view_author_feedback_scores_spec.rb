require 'spec_helper'
require 'rails_helper'

describe "Test:view author-feedback scores" do
  it "should be able to view author-feedback scores" do
    # login as instructor6
    visit 'content_pages/view'
    fill_in "User Name", with: "instructor6"
    fill_in "Password", with: "password"
    click_button "SIGN IN"
    expect(page).to have_content('Assignments')

    # view assignments
    visit '/tree_display/list'
    expect(page).to have_content('Assignments')

    # view assignment scores
    visit '/grades/view?id=722'
    expect(page).to have_content('Hide stats')

    # view author-feedback scores
    visit '/grades/view?id=722#user_student5689'
    expect(page).to have_content('Hide stats')

  end
end