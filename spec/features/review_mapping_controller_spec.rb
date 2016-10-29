require 'rails_helper'


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
    it "show error when assign both 0" do
      login_as("instructor6")
      visit '/assignments/1/edit'
      find_link('ReviewStrategy').click
      select "Instructor-Selected", from: 'assignment_form_assignment_review_assignment_strategy'
      fill_in 'num_reviews_per_student', with: 0
      choose 'num_reviews_submission'
      fill_in 'num_reviews_per_submission', with: 0
      click_button 'second_submit_tag'
      #click_button 'Save'
      expect(page).to have_content('Please choose either the number of reviews per student or the number of reviewers per team (student)')

    end
    it "show error when assign both numbers" do
      login_as("instructor6")
      visit '/assignments/1/edit'
      find_link('ReviewStrategy').click
      select "Instructor-Selected", from: 'assignment_form_assignment_review_assignment_strategy'
      fill_in 'num_reviews_per_student', with: 1
      choose 'num_reviews_submission'
      fill_in 'num_reviews_per_submission', with: 1
      click_button 'second_submit_tag'
      #click_button 'Save'
      expect(page).to have_content('Please choose either the number of reviews per student or the number of reviewers per team (student), not both')

    end
    it "calculate reviewmapping from given review number per student" do
      login_as("instructor6")
      visit '/assignments/1/edit'
      find_link('ReviewStrategy').click
      select "Instructor-Selected", from: 'assignment_form_assignment_review_assignment_strategy'
      #find("num_reviews_student", visible: false).check
      fill_in 'num_reviews_per_student', with: 2
      click_button 'first_submit_tag'
      num = ReviewResponseMap.where(reviewee_id: @team1.id, reviewed_object_id: @assignment.id).count
      expect(num).to eq(7)
      #num2 = ReviewResponseMap.where(reviewee_id: @team3.id, reviewed_object_id: @assignment.id).count
      #expect(num2).to eq(6)

    end
    it "calculate reviewmapping from given review number per submission" do
      login_as("instructor6")
      visit '/assignments/1/edit'
      find_link('ReviewStrategy').click
      select "Instructor-Selected", from: 'assignment_form_assignment_review_assignment_strategy'
      #find("num_reviews_student", visible: false).check
      choose 'num_reviews_submission'
      fill_in 'num_reviews_per_submission', with: 7
      click_button 'second_submit_tag'
      #click_button 'Save'
      num = ReviewResponseMap.where(reviewer_id: @teamuser1.id, reviewed_object_id: @assignment.id).count
      expect(num).to eq(2)

    end

    # instructor assign reviews will happen only one time, so the data will not be store in DB.

  end