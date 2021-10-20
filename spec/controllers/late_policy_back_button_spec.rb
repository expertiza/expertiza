require_relative 'helpers/assignment_creation_helper'
include AssignmentCreationHelper
describe "Late Policy Back Button Creation" do
  let!(:instructor) { create(:instructor, id: 6) }
  let(:assignment) {
    create(:assignment)
  }
  before(:each) do
    create_deadline_types
    login_as("instructor6")
  end

  it "Back button takes us to back page" do

    visit edit_assignment_path(assignment)
    click_on "Due dates"
    click_on "New late policy"
    expect(page).to have_current_path(new_late_policy_path)

    click_on "Back"

    expect(page).to have_current_path(edit_assignment_path(assignment))

  end

end
