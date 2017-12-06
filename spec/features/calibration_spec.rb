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

  before(:each) do
    # assignment and topic
    create(:instructor)
    create(:assignment, name: "Assignment1665", directory_path: "Assignment1665", rounds_of_reviews: 1, staggered_deadline: true)
    create_list(:participant, 3)
    create(:topic)
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


    assignment_due('submission', DateTime.now.in_time_zone + 20, 1, 1)
    assignment_due('review', DateTime.now.in_time_zone + 30, 1)
    assignment_due('submission', DateTime.now.in_time_zone + 40, 2)
    assignment_due('review', DateTime.now.in_time_zone + 50, 2)


    create(:team_user, user: User.where(role_id: 2).first)
    create(:team_user, user: User.where(role_id: 2).second)
    create(:assignment_team)
    create(:team_user, user: User.where(role_id: 2).third, team: AssignmentTeam.second)
    create(:signed_up_team)
    create(:signed_up_team, team_id: 2, topic: SignUpTopic.second)
    create(:assignment_questionnaire)
    create(:question)


  end

  def topic_due_at (time1, time2, time3, time4, time5, time6, time7, time8, time9)
    topic_due('calibration', time1, 1, 1)
    topic_due('submission', time2, 1, 1, 1)
    topic_due('review', time3, 1, 1)
    topic_due('submission', time4, 1, 2, 1)
    topic_due('review', time5, 1, 2)
    topic_due('submission', time6, 2, 1, 1)
    topic_due('review', time7, 2, 1)
    topic_due('submission', time8, 2, 2, 1)
    topic_due('review', time9, 2, 2)
  end


  def assignment_due(type, time, round, review_allowed_id = 3)
    create(:assignment_due_date,
           deadline_type: DeadlineType.where(name: type).first,
           due_at: time,
           round: round,
           review_allowed_id: review_allowed_id)
  end


  def topic_due(type, time, id, round, review_allowed_id = 3)
    create(:topic_due_date,
           due_at: time,
           deadline_type: DeadlineType.where(name: type).first,
           topic: SignUpTopic.where(id: id).first,
           round: round,
           review_allowed_id: review_allowed_id)
  end
  def load_work (time1, time2, time3, time4, time5, time6, time7, time8, time9, stage)
    assignment_due('calibration', DateTime.now.in_time_zone + 10, 1, 1)
    topic_due_at(time1, time2, time3, time4, time5, time6, time7, time8, time9)
    user = User.find_by_name('student2064')
    assignment = Assignment.find_by(name: "Assignment1665")
    assignment.is_calibrated = true
    stub_current_user(user, user.role.name, user.role)
    visit '/student_task/list'
    click_link 'Assignment1665'
    expect(assignment.current_stage_name(1)).to eql stage
    click_link "Others' work"
    find(:css, "#i_dont_care").set(true)
    click_button "Request a new submission to review"
    expect(page).to have_content "Begin"
    click_link "Begin"
    fill_in "responses[0][comment]", with: "Something"
    click_button "Save Review"
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
        it 'works correctly' do
          assignment = Assignment.where(name: "Assignment1665").first
          instructor = User.find_by(name: "instructor6")
          login_as("instructor6")
          stub_current_user(instructor, instructor.role.name, instructor.role)
          visit "/assignments/#{assignment.id}/edit"
          click_link 'General'
          expect(page).to have_content('Calibration for training?')
          find(:css, "#assignment_is_calibrated_field").set(true)
          click_button 'Save'
          expect(page).to have_link('Calibration')
          click_link 'Due dates'
          fill_in 'datetimepicker_calibration_review', with: (Time.now.in_time_zone + 10.days).strftime("%Y/%m/%d %H:%M")
          click_button 'submit_btn'
          calibration_type_id = DeadlineType.where(name: 'calibration_review')[0].id
          calibration_due_date = DueDate.find(12)
          expect(calibration_due_date).to have_attributes(
                                              deadline_type_id: calibration_type_id,
                                              type: 'AssignmentDueDate'
                                          )
        end
      end
    end
  end


  context 'when current assignment is in calibration stage' do
    context 'calibration feature' do
      it 'works correctly' do
        load_work(DateTime.now.in_time_zone + 10, DateTime.now.in_time_zone + 20, DateTime.now.in_time_zone + 30,
                  DateTime.now.in_time_zone + 40, DateTime.now.in_time_zone + 50, DateTime.now.in_time_zone + 20,
                  DateTime.now.in_time_zone + 30, DateTime.now.in_time_zone + 40, DateTime.now.in_time_zone + 50,  "calibration")
        expect(page).to have_content("Calibration Review 1")
        expect(page).to have_content("View")
        click_link "View"
      end
    end
  end


  context 'when current assignment is in review stage' do
    it 'excludes calibration reviews from outstanding review restriction and total review restriction' do
      load_work(DateTime.now.in_time_zone - 10, DateTime.now.in_time_zone - 20, DateTime.now.in_time_zone + 30,
                   DateTime.now.in_time_zone + 40, DateTime.now.in_time_zone + 50, DateTime.now.in_time_zone + 20,
                   DateTime.now.in_time_zone + 30, DateTime.now.in_time_zone + 40, DateTime.now.in_time_zone + 50, "review")
      expect(page).to have_content("Number of reviews allowed: 3")

    end
    it 'shows \'Review 1, 2, 3...\' and \'Calibration review 1, 2, 3...\' on student_review#list page' do
      load_work(DateTime.now.in_time_zone - 10, DateTime.now.in_time_zone - 20, DateTime.now.in_time_zone + 30,
                DateTime.now.in_time_zone + 40, DateTime.now.in_time_zone + 50, DateTime.now.in_time_zone + 20,
                DateTime.now.in_time_zone + 30, DateTime.now.in_time_zone + 40, DateTime.now.in_time_zone + 50, "review")
      expect(page).to have_content("Calibration Review 1")
      expect(page).to have_content("Review 1")
    end
  end
end
