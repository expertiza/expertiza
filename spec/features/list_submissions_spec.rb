describe "List Submissions" do
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
      create(:assignment_due_date, deadline_type: DeadlineType.where(name: 'review').first, due_at: Time.now.in_time_zone - 1.day)
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
      login_as 'instructor6'
    end
    
    it "lets instructor see Assign grade after deadline" do
        assignment = Assignment.first
        visit "/assignments/list_submissions?id=#{assignment.id}"
        expect(page).to have_content 'Assign grade'
    end

    it "lets instructor see Add review before deadline" do
        assignment = Assignment.first
        create(:assignment_due_date, deadline_type: DeadlineType.where(name: 'review').first, due_at: Time.now.in_time_zone + 1.day)
        visit "/assignments/list_submissions?id=#{assignment.id}"
        expect(page).to have_content 'Add review'
    end
  end