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

  it "create new late policy for assignment successfully" do

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

  context "creation errors are triggered" do
    let!(:existing_policy) {
      create(:late_policy, instructor_id: 6)
    }

    it "does not create new policy if policy name already exists" do

      visit edit_assignment_path(assignment)
      click_on "Due dates"
      click_on "New late policy"
      expect(page).to have_current_path(new_late_policy_path)

      # Use the name for an existing policy
      policy_name = existing_policy.policy_name
      penalty_per_unit = 1
      max_penalty = 10
      fill_in "late_policy[policy_name]", :with => policy_name
      fill_in "late_policy[penalty_per_unit]", :with => penalty_per_unit
      fill_in "late_policy[max_penalty]", :with => max_penalty

      click_on "Create"

      expect(page).to have_current_path(new_late_policy_path)
      policies_with_same_name = LatePolicy.where policy_name: existing_policy.policy_name
      # Ensure only 1 policy exists with the name
      expect(policies_with_same_name.length).to eql(1)

    end

    it "does not create new policy if fields are empty" do

      visit edit_assignment_path(assignment)
      click_on "Due dates"
      click_on "New late policy"
      expect(page).to have_current_path(new_late_policy_path)

      # Use empty fields
      policy_name = ''
      penalty_per_unit = ''
      max_penalty = ''
      fill_in "late_policy[policy_name]", :with => policy_name
      fill_in "late_policy[penalty_per_unit]", :with => penalty_per_unit
      fill_in "late_policy[max_penalty]", :with => max_penalty

      expect {
        click_on "Create"
      }.to_not change{LatePolicy.all.length}

      expect(page).to have_current_path(new_late_policy_path)
      expect(page).to have_content("Policy name can't be blank")
      expect(page).to have_content("Penalty per unit can't be blank")

    end


  end

end
