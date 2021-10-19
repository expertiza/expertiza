require_relative 'helpers/assignment_creation_helper'
include AssignmentCreationHelper
describe "Late Policy Creation" do
  let!(:instructor) { create(:instructor, id: 6) }
  let(:assignment) {
    create(:assignment)
  }
  before(:each) do
    create_deadline_types
      login_as("instructor6")
  end

  it "create new late policy for assignment" do

    visit edit_assignment_path(assignment)
    click_on "Due dates"
    click_on "New late policy"
    expect(page).to have_current_path(new_late_policy_path)

    policy_name = "Late policy name"
    penalty_per_unit = 1
    max_penalty = 10
    fill_in "late_policy[policy_name]", :with => policy_name
    fill_in "late_policy[penalty_per_unit]", :with => penalty_per_unit
    fill_in "late_policy[max_penalty]", :with => max_penalty

    click_on "Create"

    expect(page).to have_current_path(late_policies_path)
    expect(page).to have_content("The penalty policy was successfully created.")

    # Check if database has the new policy
    policy = LatePolicy.where(policy_name: policy_name).first
    expect(policy).to have_attributes(
      penalty_per_unit: penalty_per_unit,
      max_penalty: max_penalty,
    )

  end

end
