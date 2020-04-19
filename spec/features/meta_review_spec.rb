describe "meta review user tests" do
    before(:each) do
      # create an assignment
      @assignment = create(:assignment, name: "TestAssignment", directory_path: 'test_assignment')
      create_list(:participant, 3)
      create(:topic, topic_name: "Topic_1")
      create(:topic, topic_name: "Topic_2")
      create(:topic, topic_name: "Topic_3")

      # create rubric
      create(:questionnaire, name: "TestQuestionnaire1")
      create(:question, txt: "Question1", questionnaire: ReviewQuestionnaire.where(name: 'TestQuestionnaire1').first, type: "Criterion")
      create(:assignment_questionnaire, questionnaire: ReviewQuestionnaire.where(name: 'TestQuestionnaire1').first, used_in_round: 1)
      
      # populate deadline type
      create(:deadline_type, name: "submission")
      create(:deadline_type, name: "review")
      create(:deadline_type, name: "metareview")
      create(:deadline_type, name: "drop_topic")
      create(:deadline_type, name: "signup")
      create(:deadline_type, name: "team_formation")
      create(:deadline_right)
      create(:deadline_right, name: 'Late')
      create(:deadline_right, name: 'OK')

      # populate assignment deadline
      create(:assignment_due_date)
      create(:assignment_due_date, deadline_type: DeadlineType.where(name: "submission").first, due_at: DateTime.now.in_time_zone + 1.day)
      create(:assignment_due_date, deadline_type: DeadlineType.where(name: 'review').first, due_at: Time.now.in_time_zone + 2.day)
      create(:assignment_due_date, deadline_type: DeadlineType.where(name: 'metareview').first, due_at: Time.now.in_time_zone + 3.day)
      create(:topic)
      create(:topic, topic_name: "TestReview")

      # topic deadline
      topic_due('submission', Time.now.in_time_zone + 1.day, 1, 1, 1)
      topic_due('review', Time.now.in_time_zone + 2.day + 20, 1, 1)
      topic_due('metareview', Time.now.in_time_zone + 3.day, 1, 1)

      # add participants to assignment
      @studentA = create(:student, name: 'submit_and_meta_student')
      @studentB = create(:student, name: 'review_student')
      create(:participant, assignment: @assignment, user: @studentA)
      create(:participant, assignment: @assignment, user: @studentB)

      # create a submission for student x, sumbit before assignment due date.
      submit_topic('submit_and_meta_student', '/sign_up_sheet/sign_up?id=1&topic_id=1', "https://ncsu.edu")
      
      # Pull due date back so it has already passed.
      change_due(1, 1, 1, DateTime.now.in_time_zone - 1.day)
      
      # Student y reivews student x's submission
      user = User.find_by(name: 'review_student')
      stub_current_user(user, user.role.name, user.role)
      visit '/student_task/list'
      expect(page).to have_content "review"
      click_link "TestAssignment"
      expect(page).to have_content "Others' work"
      click_link "Others' work"
      expect(page).to have_content 'Reviews for "TestAssignment"'
      choose "topic_id"
      click_button "Request a new submission to review"
      click_link "Begin"
      fill_in "responses[0][comment]", with: "This is garbage."
      click_button "Submit Review"
      expect(page).to have_content "Your response was successfully saved."

      # We might want to Pull due date back for reviews here so they've passed aswell.
      # We are now setup for the meta review tests.
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
  def topic_due(type, time, topic_id, round, review_allowed_id = 3)
    create(:topic_due_date,
           due_at: time,
           deadline_type: DeadlineType.where(name: type).first,
           topic: SignUpTopic.where(id: topic_id).first,
           round: round,
           review_allowed_id: review_allowed_id)
  end

  # impersonate student to submit work
  def submit_topic(name, topic, work)
    user = User.find_by(name: name)
    stub_current_user(user, user.role.name, user.role)
    visit '/student_task/list'
    visit topic # signup topic
    visit '/student_task/list'
    click_link "TestAssignment"
    click_link "Your work"
    fill_in 'submission', with: work
    click_on 'Upload link'
    expect(page).to have_content work
  end

  # change topic deadline
  def change_due(topic, type, round, time)
    topic_due = TopicDueDate.where(parent_id: topic, deadline_type_id: type, round: round, type: "TopicDueDate").first
    topic_due.due_at = time
    topic_due.save
  end
  
    it "Student is able to leave a simple meta review." do
      
    end
  end