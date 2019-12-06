describe "Supplementary Review Questionnaire", js: true do
    before(:each) do
        create(:assignment, name: "TestAssignment", directory_path: "TestAssignment")
        create_list(:participant, 3)
        create(:topic, topic_name: "TestTopic")
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
        create(:assignment_due_date, due_at: (DateTime.now.in_time_zone.in_time_zone + 1))
        create(:assignment_due_date, deadline_type: DeadlineType.where(name: 'review').first, due_at: (DateTime.now.in_time_zone.in_time_zone + 5))
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
        (1..3).each do |i|
          create(:course, name: "Course #{i}")
        end

        (1..3).each do |i|
            create(:questionnaire, name: "ReviewQuestionnaire#{i}")
            create(:questionnaire, name: "AuthorFeedbackQuestionnaire#{i}", type: 'AuthorFeedbackQuestionnaire')
            create(:questionnaire, name: "TeammateReviewQuestionnaire#{i}", type: 'TeammateReviewQuestionnaire')
          end
      end

      def signup_topic
        user = User.find_by(name: "student2064")
        stub_current_user(user, user.role.name, user.role)
        visit '/student_task/list'
        visit '/sign_up_sheet/sign_up?id=1&topic_id=1' # signup topic
        visit '/student_task/list'
        click_link "TestAssignment"
        click_link "Your work"
      end
    
      def submit_to_topic
        signup_topic
        fill_in 'submission', with: "https://www.ncsu.edu"
        click_on 'Upload link'
        expect(page).to have_content "https://www.ncsu.edu"
      end

    it "can create assignment with supplementary review questoinnaire" do
        # Instructor logs in and visits the page of assignment creation
        login_as("instructor6")
        visit '/assignments/new?private=1'
        
        # Fill in the form under 'General'
        fill_in 'assignment_form_assignment_name', with: 'test assignment'
        select('Course 2', from: 'assignment_form_assignment_course_id')
        fill_in 'assignment_form_assignment_directory_path', with: 'test directory'
        check("team_assignment")

        # Fill in the form under 'Rubrics'
        click_link 'Rubrics'

        within(:css, "tr#questionnaire_table_ReviewQuestionnaire") do
            select "ReviewQuestionnaire2", from: 'assignment_form[assignment_questionnaire][][questionnaire_id]'
        end


        within(:css, "tr#questionnaire_table_AuthorFeedbackQuestionnaire") do
            select "AuthorFeedbackQuestionnaire2", from: 'assignment_form[assignment_questionnaire][][questionnaire_id]'
        end

        within(:css, "tr#questionnaire_table_TeammateReviewQuestionnaire") do
            select "TeammateReviewQuestionnaire2", from: 'assignment_form[assignment_questionnaire][][questionnaire_id]'
        end

        # Fill in the form under Review strategy
        click_link 'Review strategy'
        check 'assignment_form_assignment_is_supplementary_review_enabled'

        # Click to create the assignment
        click_button 'Create'
  
        # check if the assignment is created successfully
        assignment = Assignment.where(name: 'test assignment').first
        expect(assignment).to have_attributes(
            is_supplementary_review_enabled: true
        )
    end

    it "can add supplementary review questions" do
        submit_to_topic
        user = User.find_by(name: "student2065")
        stub_current_user(user, user.role.name, user.role)
        visit '/student_task/list'
        visit '/sign_up_sheet/sign_up?id=1&topic_id=1'
        visit '/student_task/list'
        click_link 'Your work'

        click_link 'Create/Edit Supplementary Review Questionnaire'
        expect(page).to have_content("Edit Review")
    end
end
