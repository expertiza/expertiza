#set up student
#set up assignment
#set up topics
#set up topic submissions

def login_and_request_review def
	#fill instance_variable_get
	login_as(user)
	find_link(assignment name).click #find the link that allows user to request randomized topic submission
	find_link('Others\' Work').click  #find the link for others' work
	find_link(request review link name).click #find the link that requests a review 
end

require 'rails_helper'

describe "review assignment", js: true do
	before(:each) do
		@assignment = create(:assignment, name: "automatic review assignment test", max_team_size: 4)
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

		(1..10).each do |i|
			student = create :student, name: 'student' + i.to_s
			create :participant, assignment: @assignment, user: student
			if i % 3 == 1 and i != 10
				instance_variable_set('@team' + (i / 3 + 1).to_s, create(:assignment_team, name: 'team' + i.to_s))
				@team = instance_variable_get('@team' + (i / 3 + 1).to_s)
			end
			create :team_user, user: student, team: @team
		end
	end
	
	it "can get review" do
		@student_reviewer = create :student, name: 'test_student'
		@participant_reviewer = create :participant, assignment: @assignment, user: @student_reviewer	
	end
	
	it "show error when student's submission is only available for topic" do
		expect(page).to have_content("There are no more submissions to review on this #{work}.")
	end
	
	
end
:w
