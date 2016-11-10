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
def delete_reviewer(student_name)

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
      @student6 = create :student,name:'student6'
      @student7 = create :student,name:'student7'
      @student8 = create :student,name:'student8'
      @student9 = create :student,name:'student9'
      @student10 = create :student,name:'student10'
      @participant1 = create :participant, assignment: @assignment, user: @student1
      @participant2 = create :participant, assignment: @assignment, user: @student2
      @participant3 = create :participant, assignment: @assignment, user: @student3
      @participant4 = create :participant, assignment: @assignment, user: @student4
      @participant5 = create :participant, assignment: @assignment, user: @student5
      @participant6 = create :participant, assignment: @assignment, user: @student6
      @participant7 = create :participant, assignment: @assignment, user: @student7
      @participant8 = create :participant, assignment: @assignment, user: @student8
      @participant9 = create :participant, assignment: @assignment, user: @student9
      @participant10 = create :participant, assignment: @assignment, user: @student10

      @team1=create(:assignment_team,name:'teamone')
      @team2=create(:assignment_team,name:'teamtwo')
      @team3=create(:assignment_team,name:'teamthree')
      @teamuser1=create(:team_user, user: @student1,team: @team1)
      @teamuser2=create(:team_user, user: @student2,team: @team1)
      @teamuser3=create(:team_user, user: @student3,team: @team1)
      @teamuser4=create(:team_user, user: @student4,team: @team2)
      @teamuser5=create(:team_user, user: @student5,team: @team2)
      @teamuser6=create(:team_user, user: @student6,team: @team2)
      @teamuser7=create(:team_user, user: @student7,team: @team3)
      @teamuser8=create(:team_user, user: @student8,team: @team3)
      @teamuser9=create(:team_user, user: @student9,team: @team3)
      @teamuser10=create(:team_user, user: @student10,team:@team3)
      # create(:review_response_map, reviewer_id: User.where(role_id: 2).third.id)
      # create(:review_response_map, reviewer_id: User.where(role_id: 2).second.id, reviewee: AssignmentTeam.second)
      # sleep(10000)
    end

    it "can add reviewer then delete it" do

      @student_reviewer = create :student,name:'student_reviewer'
      @participant_reviewer = create :participant, assignment: @assignment, user: @student_reviewer
      @student_reviewer2 = create :student,name:'student_reviewer2'
      @participant_reviewer2 = create :participant, assignment: @assignment, user: @student_reviewer2
      login_and_assign_reviewer("instructor6",@assignment.id,0,0)

      #add_reviewer
      first(:link,'add reviewer').click
      add_reviewer(@student_reviewer.name)
      expect(page).to have_content @student_reviewer.name
      #delete_reviewer
      click_link('delete')
      expect(page).to have_content ("The review mapping for \"#{@team1.name}\" and \"#{@student_reviewer.name}\" has been deleted")

      #add_meta_reviewer
      first(:link,'add reviewer').click
      add_reviewer(@student_reviewer.name)
      click_link('add metareviewer')
      add_matareviewer(@student_reviewer2.name)
      expect(page).to have_content @student_reviewer2.name
      #delete_meta_reviewer
      find(:xpath, "//a[@href='/review_mapping/delete_metareviewer?id=3']").click
      expect(page).to have_content ("The metareview mapping for #{@student_reviewer.name} and #{@student_reviewer2.name} has been deleted")

      click_link('add metareviewer')
      add_matareviewer(@student_reviewer2.name)
      #delete_all_meta_reviewer
      click_link('delete all metareviewers')
      expect(page).to have_content ("All metareview mappings for contributor \"#{@team1.name}\" and reviewer \"#{@student_reviewer.name}\" have been deleted")

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
