describe 'Staggered deadline test' do
  before(:each) do
    # assignment and topic
    create(:assignment,
           name: 'Assignment1665',
           directory_path: 'Assignment1665',
           rounds_of_reviews: 2,
           vary_by_round?: true,
           staggered_deadline: true,
           max_team_size: 1,
           allow_selecting_additional_reviews_after_1st_round: true)
    create_list(:participant, 3)
    create(:topic, topic_name: 'Topic_1')
    create(:topic, topic_name: 'Topic_2')
    create(:topic, topic_name: 'Topic_3')

    # rubric
    create(:questionnaire, name: 'TestQuestionnaire1')
    create(:questionnaire, name: 'TestQuestionnaire2')
    create(:question, txt: 'Question1', questionnaire: ReviewQuestionnaire.where(name: 'TestQuestionnaire1').first)
    create(:question, txt: 'Question2', questionnaire: ReviewQuestionnaire.where(name: 'TestQuestionnaire2').first)
    create(:assignment_questionnaire, questionnaire: ReviewQuestionnaire.where(name: 'TestQuestionnaire1').first, used_in_round: 1)
    create(:assignment_questionnaire, questionnaire: ReviewQuestionnaire.where(name: 'TestQuestionnaire2').first, used_in_round: 2)

    # deadline type
    create(:deadline_type, name: 'submission')
    create(:deadline_type, name: 'review')
    create(:deadline_type, name: 'metareview')
    create(:deadline_type, name: 'drop_topic')
    create(:deadline_type, name: 'signup')
    create(:deadline_type, name: 'team_formation')
    create(:deadline_right)
    create(:deadline_right, name: 'Late')
    create(:deadline_right, name: 'OK')

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
    user = User.find_by(username: name)
    login_as(user.username)
    visit '/student_task/list'
    visit topic # signup topic
    visit '/student_task/list'
    click_link 'Assignment1665'
    click_link 'Your work'
    fill_in 'submission', with: work
    click_on 'Upload link'
    expect(page).to have_content work
  end

  # change topic staggered deadline
  def change_due(topic, type, round, time)
    topic_due = TopicDueDate.where(parent_id: topic, deadline_type_id: type, round: round, type: 'TopicDueDate').first
    topic_due.due_at = time
    topic_due.save
  end

  it 'test1: in round 1, student2064 in review stage could do review' do
    # impersonate each participant submit their topics
    submit_topic('student2064', '/sign_up_sheet/sign_up?id=1&topic_id=1', 'https://google.com')
    click_link('Logout')
    submit_topic('student2065', '/sign_up_sheet/sign_up?id=1&topic_id=2', 'https://ncsu.edu')
    click_link('Logout')
    # change deadline to make student2064 in review stage in round 1
    change_due(1, 1, 1, DateTime.now.in_time_zone - 10)

    # impersonate each participant and check their topic's current stage

    # ####student 1:
    user = User.find_by(username: 'student2064')
    login_as(user.username)
    visit '/student_task/list'
    expect(page).to have_content 'review'

    # student2064 in review stage could review others' work
    # however, student2065 is still in submission stage.
    # So actually, student2064 cannot review anything.
    # the reason is that the review_allowed_id of default submission deadline is OK, should be NO.
    click_link 'Assignment1665'
    expect(page).to have_content "Others' work"
    click_link "Others' work"
    expect(page).to have_content 'Reviews for "Assignment1665"'
    click_button 'Request a new submission to review'
    expect(page).to have_content 'No topic is selected. Please go back and select a topic.'
    click_link('Logout')

    # Although student2065 is in submission stage, he or she can still review other's work.
    user = User.find_by(username: 'student2065')
    login_as(user.username)
    visit '/student_task/list'
    expect(page).to have_content 'Stage Deadline'
    click_link 'Assignment1665'
    expect(page).to have_content "Others' work"
    click_link "Others' work"
    expect(page).to have_content 'Reviews for "Assignment1665"'
    choose 'topic_id_1'
    click_button 'Request a new submission to review'
    expect(page).to have_content 'Review 1.'
    click_link 'Begin'
    expect(page).to have_content 'You are reviewing Topic_1'
    expect(page).to have_content 'Question1'
    select 5, from: 'responses_0_score'
    fill_in 'responses_0_comments', with: 'test fill'
    click_button 'Save Review'
    expect(page).to have_content 'View'
  end

  it 'test2: in round 2, both students should be in review stage to review each other' do
    # impersonate each participant submit their topics
    submit_topic('student2064', '/sign_up_sheet/sign_up?id=1&topic_id=1', 'https://google.com')
    click_link('Logout')
    submit_topic('student2065', '/sign_up_sheet/sign_up?id=1&topic_id=2', 'https://ncsu.edu')
    click_link('Logout')
    # change deadline to make both in review stage in round 2
    change_due(1, 1, 1, DateTime.now.in_time_zone - 30)
    change_due(1, 2, 1, DateTime.now.in_time_zone - 20)
    change_due(1, 1, 2, DateTime.now.in_time_zone - 10)
    change_due(2, 1, 1, DateTime.now.in_time_zone - 30)
    change_due(2, 2, 1, DateTime.now.in_time_zone - 20)
    change_due(2, 1, 2, DateTime.now.in_time_zone - 10)

    # impersonate each participant and check their topic's current stage

    # ##first student:
    user = User.find_by(username: 'student2064')
    login_as(user.username)
    visit '/student_task/list'
    expect(page).to have_content 'review'

    # student in review stage could review others' work
    click_link 'Assignment1665'
    expect(page).to have_content "Others' work"
    click_link "Others' work"
    expect(page).to have_content 'Reviews for "Assignment1665"'
    choose 'topic_id_2'
    click_button 'Request a new submission to review'
    expect(page).to have_content 'Review 1.'
    click_link 'Begin'
    expect(page).to have_content 'You are reviewing Topic_2'

    # check it is the right rubric for this round
    expect(page).to have_content 'Question2'

    # Check fill in rubrics and save, submit the review
    select 5, from: 'responses_0_score'
    fill_in 'responses_0_comments', with: 'test fill'
    click_button 'Save Review'
    expect(page).to have_content 'View'
    click_link('Logout')

    # ##second student
    user = User.find_by(username: 'student2065')
    login_as(user.username)
    visit '/student_task/list'
    expect(page).to have_content 'review'

    # student in review stage could review others' work
    click_link 'Assignment1665'
    expect(page).to have_content "Others' work"
    click_link "Others' work"
    expect(page).to have_content 'Reviews for "Assignment1665"'
    choose 'topic_id_1'
    click_button 'Request a new submission to review'
    expect(page).to have_content 'Review 1.'
    click_link 'Begin'
    expect(page).to have_content 'You are reviewing Topic_1'

    # check it is the right rubric for this round
    expect(page).to have_content 'Question2'

    # Check fill in rubrics and save, submit the review
    select 5, from: 'responses_0_score'
    fill_in 'responses_0_comments', with: 'test fill'
    click_button 'Save Review'
    expect(page).to have_content 'View'
    click_link('Logout')
  end

  it 'test3: in round 2, both students after review deadline should not do review' do
    # impersonate each participant submit their topics
    submit_topic('student2064', '/sign_up_sheet/sign_up?id=1&topic_id=1', 'https://google.com')
    click_link('Logout')
    submit_topic('student2065', '/sign_up_sheet/sign_up?id=1&topic_id=2', 'https://ncsu.edu')
    click_link('Logout')

    # change deadline to make both after review deadline in round 2
    change_due(1, 1, 1, DateTime.now.in_time_zone - 40)
    change_due(1, 2, 1, DateTime.now.in_time_zone - 30)
    change_due(1, 1, 2, DateTime.now.in_time_zone - 20)
    change_due(1, 2, 2, DateTime.now.in_time_zone - 10)
    change_due(2, 1, 1, DateTime.now.in_time_zone - 40)
    change_due(2, 2, 1, DateTime.now.in_time_zone - 30)
    change_due(2, 1, 2, DateTime.now.in_time_zone - 20)
    change_due(2, 2, 2, DateTime.now.in_time_zone - 10)

    # impersonate each participant and check their topic's current stage
    user = User.find_by(username: 'student2064')
    login_as(user.username)
    visit '/student_task/list'
    expect(page).to have_content 'Finished'

    # student in finish stage can not review others' work
    click_link 'Assignment1665'
    expect(page).to have_content "Others' work"
    click_link "Others' work"
    expect(page).to have_content 'Reviews for "Assignment1665"'
    # it should not able to choose topic for review
    expect { choose 'topic_id_2' }.to raise_error(/Unable to find visible radio button "topic_id_2"/)
    click_link('Logout')

    user = User.find_by(username: 'student2065')
    login_as(user.username)
    visit '/student_task/list'
    expect(page).to have_content 'Finished'
    click_link 'Assignment1665'
    expect(page).to have_content "Others' work"
    click_link "Others' work"
    expect(page).to have_content 'Reviews for "Assignment1665"'
    expect { choose 'topic_id_2' }.to raise_error(/Unable to find visible radio button "topic_id_2"/)
    click_link('Logout')
  end

  # the test will test the Java script which is embedded into the sign up sheet. The java script will
  # computer the offset in dates for the deadlines using the first topic and as soon as we input the date
  # in the first field of a new topic , the other deadlines corresponding to the topic will be populated
  # automatically using the offsets that were calculated from the first topic.
  it 'test4: When creating a new topic when already a topic exists for assignment , it should take the offset from the first topic for setting the due dates.',
     js: true do
    login_as('instructor6')
    assignment = Assignment.find_by(name: 'Assignment1665')
    visit "/assignments/#{assignment.id}/edit"
    click_link 'Topics'
    expect(page).to have_content 'Show start/due date'
    click_link 'Show start/due date'
    expect(page).to have_content 'Hide start/due date'
    current_time = DateTime.current
    fill_in 'due_date_3_submission_1_due_date', with: current_time
    expect(find_field('due_date_3_submission_1_due_date').value).to_not eq(nil)
    find(:xpath, ".//input[@id='due_date_3_review_1_due_date']").click
    expect(find_field('due_date_3_review_1_due_date').value).to_not eq(nil)
  end

  it 'test5: Deletes all selected topics that contain staggered deadlines', js: true do
    login_as('instructor6')
    assignment = Assignment.find_by(name: 'Assignment1665')
    visit "/assignments/#{assignment.id}/edit"
    click_link 'Topics'
    check('select_all')
    click_button 'Delete selected topics'
    page.driver.browser.switch_to.alert.accept
    sleep 3
    expect(page).not_to have_content('Topics')
    expect(page).not_to have_content('Topic_1')
    expect(page).not_to have_content('Topic_2')
    expect(page).not_to have_content('Topic_3')
  end
end
