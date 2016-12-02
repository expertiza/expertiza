require 'rails_helper'

def login_and_assign_reviewer(user,assignment_id,student_num,submission_num)
  login_as(user)
  visit "/assignments/#{assignment_id}/edit"
  find_link('ReviewStrategy').click
  select "Instructor-Selected", from: 'assignment_form_assignment_review_assignment_strategy'
  fill_in 'num_reviews_per_student', with: student_num
  choose 'num_reviews_submission'
  fill_in 'num_reviews_per_submission', with: submission_num
  click_on('Assign reviewers')
end

def add_reviewer(student_name)
	fill_in 'user_name', with: student_name
	click_on ('Add Reviewer')
	expect(page).to have_content student_name
end

def add_matareviewer(student_name)
  fill_in 'user_name', with: student_name
  click_on ('Add Metareviewer')
  expect(page).to have_content student_name
end

describe "page should have" do
	it "page should have student name on clicking Add reviewer" do	
		def add_reviewer(student_name)
 			fill_in 'user_name', with: student_name
  		click_on ('Add Reviewer')
  		expect(page).to have_content student_name
		end
	end
	it "page should have student name on clicking metareviewer" do	

	end
end

 describe "review mapping", js: true do
   before(:each) do
     @assignment=create(:assignment, name: "automatic review mapping test",max_team_size: 4)
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

      @student1 = create :student,name:'student1'
      @student2 = create :student,name:'student2'
      @student3 = create :student,name:'student3'
      @student4 = create :student,name:'student4'
      @student5 = create :student,name:'student5'
      @participant1 = create :participant, assignment: @assignment, user: @student1
      @participant2 = create :participant, assignment: @assignment, user: @student2
      @participant3 = create :participant, assignment: @assignment, user: @student3
      @participant4 = create :participant, assignment: @assignment, user: @student4
      @participant5 = create :participant, assignment: @assignment, user: @student5

      @team1=create(:assignment_team,name:'teamone')
      @team2=create(:assignment_team,name:'teamtwo')
      @team3=create(:assignment_team,name:'teamthree')
      @teamuser1=create(:team_user, user: @student1,team: @team1)
      @teamuser2=create(:team_user, user: @student2,team: @team1)
      @teamuser3=create(:team_user, user: @student3,team: @team1)
      @teamuser4=create(:team_user, user: @student4,team: @team2)
      @teamuser5=create(:team_user, user: @student5,team: @team2)
   end

    it "can add reviewer then delete it" do
      @student_reviewer = create :student,name:'student_reviewer'
      @participant_reviewer = create :participant, assignment: @assignment, user: @student_reviewer
      @student_reviewer2 = create :student,name:'student_reviewer2'
      @participant_reviewer2 = create :participant, assignment: @assignment, user: @student_reviewer2
      login_and_assign_reviewer("instructor6",@assignment.id,0,0)

      first(:link,'add reviewer').click	#add_reviewer
      add_reviewer(@student_reviewer.name)
      expect(page).to have_content @student_reviewer.name

      click_link('delete')        #delete_reviewer
      expect(page).to have_content ("The review mapping for \"#{@team1.name}\" and \"#{@student_reviewer.name}\" has been deleted")
		end
end

