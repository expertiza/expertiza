describe 'expert review' do
  ###
  # Please do not share this file with other teams.
  # Please follow the TDD process as much as you can.
  # Use factories to create necessary DB records.
  # Please avoid duplicated code as much as you can by moving the code to before(:each) block or separated methods.
  # RSpec feature tests examples: spec/features/airbrake_expection_errors_feature_tests_spec.rb and spec/features/peer_review_spec.rb
  # For single user login, please use login_as method.
  # If your tests need to switch to different users frequently,
  # please use stub_current_user(user, user.role.name, user.role) each time to stub login behavior.
  ##
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
  end

  context 'in assignments#edit page' do
    it 'has a checkbox with title \'Add expert peer review?\' on \'General\' tab' do

      assignment = Assignment.first
      login_as 'instructor6'
      visit "/assignments/#{assignment.id}/edit"
      find(:css, "#assignment_form.assignment.has_expert_review").set(true)
    end


    context 'when clicking \'Add expert peer review?\' checkbox and clicking \'save\' button' do
      it 'displays a new tab named \'Expert review\'' do

      end
    end
  end

  context 'when current assignment with single review round supports expert peer-review' do
    context 'expert review feature' do
      it 'works correctly'
      # on assignments#edit page
      # an instructor is able to do expert review and the data can be saved successfully
      # a TA is able to do expert review and the data can be saved successfully

      # on student_review#list page
      # a student is able to do peer review
      # the student is able to compare the results of expert reviews done by both the instructor and the TA
      # by clicking 'show expert peer-review results'
    end
  end

  context 'when current assignment with vary-rubric-by-round supports expert peer-review' do
    context 'expert review feature' do
      it 'works correctly'
      # round 1 with review rubric 1
      # on assignments#edit page
      # an instructor is able to do round 1 expert review with review rubric 1 and the data can be saved successfully
      # a TA is able to do round 1 expert review  with review rubric 1 and the data can be saved successfully

      # on student_review#list page
      # a student is able to do round 1 peer review  with review rubric 1
      # the student is able to compare the results of round 1 expert reviews done by both the instructor and the TA
      # by clicking 'show expert peer-review results

      # round 2 with review rubric 2
      # on assignments#edit page
      # an instructor is able to do round 2 expert review with review rubric 2 and the data can be saved successfully
      # a TA is able to do round 2 expert review  with review rubric 2 and the data can be saved successfully

      # on student_review#list page
      # a student is able to do round 2 peer review  with review rubric 2
      # the student is able to compare the results of round 1 and round 2 expert reviews done by both the instructor and the TA
      # by clicking 'show expert peer-review results
    end
  end
end
