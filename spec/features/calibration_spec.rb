describe 'expert review' do
  ###
  # Please do not share this file with other teams.
  # Please follow the TDD process as much as you can.
  # Use factories to create necessary DB records.
  # Please avoid duplicated code as much as you can by moving the code to before(:each) block or separated methods.
  # RSpec feature tests examples: spec/features/airbrake_expection_errors_feature_tests_spec.rb and spec/features/peer_review_spec.rb
  # If your tests need to switch to different users frequently,
  # please use stub_current_user(user, user.role.name, user.role) each time to stub login behavior.
  ###

=begin
  before(:each) do
    create(:instructor)
    create_list(:participant, 3)
    create(:topic, topic_name: "TestTopic")
    create(:deadline_type, name: "submission")
    create(:deadline_type, name: "review")
    create(:deadline_type, name: "metareview")
    create(:deadline_type, name: "drop_topic")
    create(:deadline_type, name: "signup")
    create(:deadline_type, name: "team_formation")
    create(:deadline_type, name: "calibration")
    create(:deadline_right)
    create(:deadline_right, name: 'Late')
    create(:deadline_right, name: 'OK')
    create(:assignment_due_date, deadline_type: DeadlineType.where(name: "submission").first, due_at: DateTime.now.in_time_zone + 1.day)
    create(:assignment, name: "test")
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
    create(:assignment_node)


  end
=end

  before(:each) do
    # assignment and topic
    create(:instructor)
    create(:assignment, name: "Assignment1665", directory_path: "Assignment1665", rounds_of_reviews: 2, staggered_deadline: true)
    create_list(:participant, 3)
    create(:topic, topic_name: "Topic_1")
    create(:topic, topic_name: "Topic_2")


    create(:deadline_type, name: "submission")
    create(:deadline_type, name: "review")
    create(:deadline_type, name: "metareview")
    create(:deadline_type, name: "drop_topic")
    create(:deadline_type, name: "signup")
    create(:deadline_type, name: "team_formation")
    create(:deadline_type, name: "calibration")
    create(:deadline_right)
    create(:deadline_right, name: 'Late')
    create(:deadline_right, name: 'OK')

    create(:questionnaire, name: "TestQuestionnaire1")
    create(:questionnaire, name: "TestQuestionnaire2")
    create(:question, txt: "Question1", questionnaire: ReviewQuestionnaire.where(name: 'TestQuestionnaire1').first, type: "Criterion")
    create(:question, txt: "Question2", questionnaire: ReviewQuestionnaire.where(name: 'TestQuestionnaire2').first, type: "Criterion")
    create(:assignment_questionnaire, questionnaire: ReviewQuestionnaire.where(name: 'TestQuestionnaire1').first, used_in_round: 1)
    create(:assignment_questionnaire, questionnaire: ReviewQuestionnaire.where(name: 'TestQuestionnaire2').first, used_in_round: 2)

    # assignment deadline
    assignment_due('submission', DateTime.now.in_time_zone + 10, 1, 1)
    assignment_due('review', DateTime.now.in_time_zone + 20, 1)
    assignment_due('submission', DateTime.now.in_time_zone + 30, 2)
    assignment_due('review', DateTime.now.in_time_zone + 40, 2)

    # topic deadline
    topic_due('submission', DateTime.now.in_time_zone + 10, 1, 1, 1)
    topic_due('review', DateTime.now.in_time_zone + 20, 1, 1)
    topic_due('submission', DateTime.now.in_time_zone + 30, 1, 2, 1)
    topic_due('review', DateTime.now.in_time_zone + 40, 1, 2)
    topic_due('submission', DateTime.now.in_time_zone + 10, 2, 1, 1)
    topic_due('review', DateTime.now.in_time_zone + 20, 2, 1)
    topic_due('submission', DateTime.now.in_time_zone + 30, 2, 2, 1)
    topic_due('review', DateTime.now.in_time_zone + 40, 2, 2)
  end

  # create assignment deadline
  # by default the review_allow_id is 3 (OK), however, for submission the review_allowed_id should be 1 (No).
  def assignment_due(type, time, round, review_allowed_id = 3)
    create(:assignment_due_date,
           deadline_type: DeadlineType.where(name: type).first,
           due_at: time,
           round: round,
           review_allowed_id: review_allowed_id)
  end

  # create topic deadline
  def topic_due(type, time, id, round, review_allowed_id = 3)
    create(:topic_due_date,
           due_at: time,
           deadline_type: DeadlineType.where(name: type).first,
           topic: SignUpTopic.where(id: id).first,
           round: round,
           review_allowed_id: review_allowed_id)
  end

  # impersonate student to submit work
  def submit_topic(name, topic, work)
    user = User.find_by_name(name)
    stub_current_user(user, user.role.name, user.role)
    visit '/student_task/list'
    visit topic # signup topic
    visit '/student_task/list'
    click_link "Assignment1665"
    click_link "Your work"
    fill_in 'submission', with: work
    click_on 'Upload link'
    expect(page).to have_content work
  end

  # change topic staggered deadline
  def change_due(topic, type, round, time)
    topic_due = TopicDueDate.where(parent_id: topic, deadline_type_id: type, round: round, type: "TopicDueDate").first
    topic_due.due_at = time
    topic_due.save
  end

  context 'in assignments#edit page' do
    it 'has a checkbox with title \'Calibration for training?\' on \'General\' tab' do
      assignment = Assignment.where(name: "Assignment1665").first
      instructor = User.find_by(name: "instructor6")
      login_as("instructor6")
      stub_current_user(instructor, instructor.role.name, instructor.role)
      visit "/assignments/#{assignment.id}/edit"
      click_link 'General'
      expect(page).to have_field('Calibration for training?')
    end
    context 'when clicking \'Calibration for training?\' checkbox and clicking \'save\' button' do
      context '\'Calibration\' due date' do
        it 'works correctly'do
          # displays a new tab named \'Calibration\' and adds a calibration due date in \'Due dates\' tab'
          assignment = Assignment.where(name: "Assignment1665").first
          instructor = User.find_by(name: "instructor6")
          login_as("instructor6")
          stub_current_user(instructor, instructor.role.name, instructor.role)
          visit "/assignments/#{assignment.id}/edit"
          click_link 'General'
          expect(page).to have_field('Calibration for training?')
          page.check 'Calibration for training?'
          click_on 'Save'
          #expect(page).to have_link('Calibration')
          #click_link 'Due dates'
          #fill_in 'calibration', with: 'Date'

          # allows instructors to change and save date & time and permissions of calibration due date'

        end
      end
    end
  end
=begin

  context 'when current assignment is in calibration stage' do
    context 'calibration feature' do
      it 'works correctly' do
        user = User.find_by(name: "student2065")
        stub_current_user(user, user.role.name, user.role)
      # shows current stage of this assignment to be 'Calibration' on student_task#view page
        assignment = Assignment.where(name: "test").first
        visit "/student_task/view?id=#{assignment.id}"
        expect(assignment.current_stage_name).to eql 'Calibration'
        click_link "Others' work "
      # shows 'Calibration review 1, 2, 3...' instead of 'Review 1, 2, 3...' on student_review#list page

        expect(page).to have_content("Calibration review")
        expect(page).to have_no_content("Calibration review")
      # allows students to do calibration review and the data can be saved successfully


      # the student is able to compare the results of expert review by clicking 'show calibration results' link
        click_link "show calibration results"
      end
    end
  end

  context 'when current assignment is in review stage' do
    user = User.find_by(name: "student2065")
    stub_current_user(user, user.role.name, user.role)
    assignment = Assignment.where(name: "test").first
    it 'excludes calibration reviews from outstanding review restriction and total review restriction' do


    end
    it 'shows \'Review 1, 2, 3...\' and \'Calibration review 1, 2, 3...\' on student_review#list page' do
      visit "/student_task/list"
      expect(page).to have_content("Calibration review")
      expect(page).to have_content("Review")

    end
  end
=end
end
