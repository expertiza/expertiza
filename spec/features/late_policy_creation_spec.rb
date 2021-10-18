# require 'byebug'

require_relative 'helpers/assignment_creation_helper'
include AssignmentCreationHelper
describe "Late Policy Creation" do
  policy_instructor_id = 1
  let!(:instructor) { create(:instructor, id: 6) }
  let(:assignment) {
    # create(:assignment, name: "Assignment1684", directory_path: "Assignment1684")
    create(:assignment)
  }
  before(:each) do
    puts Instructor.all
    create_deadline_types
      # byebug
    # stub_current_user(instructor, instructor.role.name, instructor.role)
      # login_as("instructor6")
  end

  it "create new late policy for assignment" do

      login_as("instructor6")
    visit edit_assignment_path(assignment)
    puts page.body
    click_on "Due dates"
    click_on "New late policy"

    expect(page).to have_current_path(new_late_policy_path)
    expect(true).to eql(true)
  end

end
