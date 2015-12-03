require 'spec_helper'
require 'rails_helper'

describe "Test:view review scores" do
  it "should be able to view review scores" do
    # login as instructor6
    visit 'content_pages/view'
    fill_in "User Name", with: "instructor6"
    fill_in "Password", with: "password"
    click_button "SIGN IN"
    expect(page).to have_content('Assignments')

    # view assignments
    visit '/tree_display/list'
    expect(page).to have_content('Assignments')

    # view review reports
    visit '/review_mapping/response_report?id=723'
    expect(page).to have_content('Review report')

    # view review scores
    visit '/popup/view_review_scores_popup?assignment_id=723&reviewer_id=29065'
    expect(page).to have_content('Review scores')

  end
end