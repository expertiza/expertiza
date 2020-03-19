require_relative 'helpers/assignment_creation_helper'

# Begin Due Date tab
describe "Assignment creation due dates tab", js: true do
	include AssignmentCreationHelper
	before(:each) do
		create_deadline_types()
		@assignment = create(:assignment, name: 'public assignment for test')
		login_as("instructor6")
		visit "/assignments/#{@assignment.id}/edit"
		click_link 'Due date'
	end

	xit "Able to create a new penalty policy" do # This case doesn't work in expertiza yet, i.e. not able to create new late policy.
		find_link('New late policy').click
		fill_in 'late_policy_policy_name', with: 'testlatepolicy'
		fill_in 'policy_penalty_per_unit', with: 'testlatepolicypenalty'
		fill_in 'late_policy_max_penalty', with: 2
		click_button 'Create'
	end

	# able to set deadlines for a single round of reviews
	it "set the deadline for an assignment review" do
		fill_in 'assignment_form_assignment_rounds_of_reviews', with: '1'
		click_button 'set_rounds'
		fill_in 'datetimepicker_submission_round_1', with: (Time.now.in_time_zone + 1.day).strftime("%Y/%m/%d %H:%M")
		fill_in 'datetimepicker_review_round_1', with: (Time.now.in_time_zone + 10.days).strftime("%Y/%m/%d %H:%M")
		click_button 'submit_btn'

		submission_type_id = DeadlineType.where(name: 'submission')[0].id
		review_type_id = DeadlineType.where(name: 'review')[0].id

		submission_due_date = DueDate.find(1)
		review_due_date = DueDate.find(2)
		expect(submission_due_date).to have_attributes(
			deadline_type_id: submission_type_id,
			type: 'AssignmentDueDate'
		)

		expect(review_due_date).to have_attributes(
			deadline_type_id: review_type_id,
			type: 'AssignmentDueDate'
		)
	end
end
