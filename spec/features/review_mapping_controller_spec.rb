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
def delete_reviewer(student_name)

end
  describe "review mapping", js: true do
    before(:each) do
      @assignment=create(:assignment, name: "automatic review mapping test",max_team_size: 4)
      create_list(:participant, 10)
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
      @team1=create(:assignment_team,name:'teamone')
      @team2=create(:assignment_team,name:'teamtwo')
      @team3=create(:assignment_team,name:'teamthree')
      @teamuser1=create(:team_user, user: User.where(role_id: 2).first,team: AssignmentTeam.where(name:'teamone').first)
      @teamuser2=create(:team_user, user: User.where(role_id: 2).limit(2).last,team: AssignmentTeam.where(name:'teamone').first)
      create(:team_user, user: User.where(role_id: 2).limit(3).last,team: AssignmentTeam.where(name:'teamone').first)
      create(:team_user, user: User.where(role_id: 2).limit(4).last,team: AssignmentTeam.where(name:'teamtwo').first)
      create(:team_user, user: User.where(role_id: 2).limit(5).last,team: AssignmentTeam.where(name:'teamtwo').first)
      create(:team_user, user: User.where(role_id: 2).limit(6).last,team: AssignmentTeam.where(name:'teamtwo').first)
      create(:team_user, user: User.where(role_id: 2).limit(7).last,team: AssignmentTeam.where(name:'teamthree').first)
      create(:team_user, user: User.where(role_id: 2).limit(8).last,team: AssignmentTeam.where(name:'teamthree').first)
      create(:team_user, user: User.where(role_id: 2).limit(9).last,team: AssignmentTeam.where(name:'teamthree').first)
      @teamuser10=create(:team_user, user: User.where(role_id: 2).limit(10).last,team: AssignmentTeam.where(name:'teamthree').first)
      # create(:review_response_map, reviewer_id: User.where(role_id: 2).third.id)
      # create(:review_response_map, reviewer_id: User.where(role_id: 2).second.id, reviewee: AssignmentTeam.second)
      # sleep(10000)
    end

    it "can add reviewer then delete it" do
      @student1 = create :student,name:'student_reviewer1'
      @participant_reviewer1 = create :participant, assignment: @assignment, user: @student1

      login_and_assign_reviewer("instructor6",@assignment.id,0,0)

      first(:link,'add reviewer').click
      add_reviewer(@student1.name)

      first(:link,'delete outstanding reviewers').click

      expect(page).to have_content ("All review mappings for \"#{@team1.name}\" have been deleted")

    end
    it "show error when assign both 2" do
       login_and_assign_reviewer("instructor6",@assignment.id,2,2)
       expect(page).to have_content('Please choose either the number of reviews per student or the number of reviewers per team (student), not both')

    end
    it "show error when assign both 0" do
      login_and_assign_reviewer("instructor6",@assignment.id,0,0)
      expect(page).to have_content('Please choose either the number of reviews per student or the number of reviewers per team (student)')

    end
    it "calculate reviewmapping from given review number per student" do
      login_and_assign_reviewer("instructor6",@assignment.id,2,0)

      num = ReviewResponseMap.where(reviewee_id: 1, reviewed_object_id: 1).count
      expect(num).to eq(7)
      #num2 = ReviewResponseMap.where(reviewee_id: @team3.id, reviewed_object_id: @assignment.id).count
      #expect(num2).to eq(6)

    end

    it "calculate reviewmapping from given review number per submission" do
      login_and_assign_reviewer("instructor6",@assignment.id,0,7)

      num = ReviewResponseMap.where(reviewer_id: 1, reviewed_object_id: 1).count
      expect(num).to eq(2)

    end

    # instructor assign reviews will happen only one time, so the data will not be store in DB.

  end