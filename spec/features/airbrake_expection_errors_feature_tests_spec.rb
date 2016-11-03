require 'rails_helper'

describe "Airbrake expection errors" do
	before(:each) do
		create(:assignment, name: "TestAssignment", directory_path: 'test_assignment')
		create_list(:participant, 3)
		create(:assignment_node)
		create(:deadline_type, name: "submission")
		create(:deadline_type, name: "review")
		create(:deadline_type, name: "metareview")
		create(:deadline_type, name: "drop_topic")
		create(:deadline_type, name: "signup")
		create(:deadline_type, name: "team_formation")
		create(:deadline_right)
		create(:deadline_right, name: 'Late')
		create(:deadline_right, name: 'OK')
		create(:assignment_due_date, due_at: (DateTime.now + 1))
		create(:assignment_due_date, deadline_type: DeadlineType.where(name: 'review').first, due_at: (DateTime.now + 5))
		create(:topic)
		create(:topic, topic_name: "TestReview")
		create(:team_user, user: User.where(role_id: 2).first)
		create(:team_user, user: User.where(role_id: 2).second)
		create(:assignment_team)
		create(:team_user, user: User.where(role_id: 2).third, team: AssignmentTeam.second)
		create(:signed_up_team)
		create(:signed_up_team, team_id: 2, topic: SignUpTopic.second)
		create(:assignment_questionnaire)
		create(:question)
	end

	# Airbrake-1806782678925052472
	it "can list sign_up_topics by using 'id' (participant_id) as parameter", js: true do
		login_as 'student2066'
		visit '/sign_up_sheet/list?id=1'
		expect(page).to have_content('Signup sheet for')
		expect(page).to have_content('Hello world!')
		expect(page).to have_content('TestReview')
	end
end