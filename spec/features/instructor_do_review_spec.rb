describe "check 'Begin review' showing up before due date and 'Assign grade' after due date" do
  let(:team) { build(:assignment_team, id: 1, name: 'team1') }

  it 'Begin review' do
    instructor6 = create(:instructor) # create instructor6
    assignment_test = create(:assignment, name: 'E2086', course: nil) # create an assignment without course
    create(:deadline_type, name: 'submission')
    create(:deadline_type, name: 'review')
    create(:deadline_type, name: 'team_formation')
    create(:assignment_due_date, deadline_type: DeadlineType.where(name: 'submission').first, due_at: DateTime.now.in_time_zone .day)
    create(:assignment_due_date, deadline_type: DeadlineType.where(name: 'review').first, due_at: DateTime.now.in_time_zone + 10.day)
    create(:assignment_due_date, deadline_type: DeadlineType.where(name: 'team_formation').first, due_at: DateTime.now.in_time_zone .day)

    questionnaire1 = create(:questionnaire, name: 'TestQuestionnaire1')
    create(:questionnaire, name: 'TestQuestionnaire2')
    create(:question, txt: 'Question1', questionnaire: ReviewQuestionnaire.where(name: 'TestQuestionnaire1').first)
    create(:question, txt: 'Question2', questionnaire: ReviewQuestionnaire.where(name: 'TestQuestionnaire2').first)
    create(:assignment_questionnaire, questionnaire: ReviewQuestionnaire.where(name: 'TestQuestionnaire1').first, used_in_round: 1)
    create(:assignment_questionnaire, questionnaire: ReviewQuestionnaire.where(name: 'TestQuestionnaire2').first, used_in_round: 2)

    expect(assignment_test.instructor_id).to eql(instructor6.id)
    expect(assignment_test.course_id).to eql(nil)
    student_test = create(:student, username: 'student6666', email: 'stu6666@ncsu.edu') # create a student for test

    visit(root_path)
    fill_in('login_username', with: 'instructor6')
    fill_in('login_password', with: 'password')
    click_button('Sign in')
    expect(current_path).to eql('/tree_display/list')
    expect(page).to have_content('Manage content')

    visit("/participants/list?id=#{assignment_test.id}&model=Assignment")
    expect(page).to have_content('E2086')
    fill_in('user_name', match: :first, with: instructor6.username)
    click_button('Add', match: :first)
    expect(page).to have_content(instructor6.username)
    expect(page).to have_content(instructor6.email)
    click_button('Submit', match: :first)

    visit("/participants/list?id=#{assignment_test.id}&model=Assignment")
    expect(page).to have_content('E2086')
    fill_in('user_name', match: :first, with: student_test.username)
    click_button('Add', match: :first)
    expect(page).to have_content(student_test.username)
    expect(page).to have_content(student_test.email)

    user_id = User.find_by(username: 'student6666').id
    participant_student = Participant.where(user_id: user_id)
    participant_id = participant_student.first.id
    parent_id = participant_student.first.parent_id
    team_student = Team.where(parent_id: parent_id)
    team_user = create(:team_user, user_id: user_id)

    visit("/assignments/list_submissions?id=#{assignment_test.id}")
    expect(page).to have_content('student6666')
    expect(page).to have_content('https://www.expertiza.ncsu.edu')

    visit("/response/new?id=#{questionnaire1.id}&return=ta_review")
    expect(page).to have_content('E2086')

    fill_in 'responses[0][comment]', with: 'Excellent Work'
    click_button 'Submit Review'
    expect(page).to have_content 'Your response was successfully saved.'

    visit("/assignments/list_submissions?id=#{assignment_test.id}")
    expect(page).to have_content('student6666')
    expect(page).to have_content('https://www.expertiza.ncsu.edu')

    visit('/impersonate/start')
    expect(page).to have_content('Enter user account')
    fill_in('user_name', with: student_test.username)
    click_button('Impersonate')
    expect(current_path).to eql('/student_task/list')
    expect(page).to have_content("User: #{student_test.username}")
    expect(page).to have_content('E2086')
    click_link('E2086')
  end

  it 'Assign grade' do
    instructor6 = create(:instructor) # create instructor6
    assignment_test = create(:assignment, name: 'E2086', course: nil) # create an assignment without course
    create(:deadline_type, name: 'submission')
    create(:deadline_type, name: 'review')
    create(:assignment_due_date, deadline_type: DeadlineType.where(name: 'submission').first, due_at: DateTime.now.in_time_zone - 10.day)
    create(:assignment_due_date, deadline_type: DeadlineType.where(name: 'review').first, due_at: DateTime.now.in_time_zone - 5.day)

    create(:questionnaire, name: 'TestQuestionnaire1')
    create(:questionnaire, name: 'TestQuestionnaire2')
    create(:question, txt: 'Question1', questionnaire: ReviewQuestionnaire.where(name: 'TestQuestionnaire1').first)
    create(:question, txt: 'Question2', questionnaire: ReviewQuestionnaire.where(name: 'TestQuestionnaire2').first)
    create(:assignment_questionnaire, questionnaire: ReviewQuestionnaire.where(name: 'TestQuestionnaire1').first, used_in_round: 1)
    create(:assignment_questionnaire, questionnaire: ReviewQuestionnaire.where(name: 'TestQuestionnaire2').first, used_in_round: 2)

    expect(assignment_test.instructor_id).to eql(instructor6.id)
    expect(assignment_test.course_id).to eql(nil)
    student_test = create(:student, username: 'student6666', email: 'stu6666@ncsu.edu') # create a student for test

    visit(root_path)
    fill_in('login_username', with: 'instructor6')
    fill_in('login_password', with: 'password')
    click_button('Sign in')
    expect(current_path).to eql('/tree_display/list')
    expect(page).to have_content('Manage content')

    visit("/participants/list?id=#{assignment_test.id}&model=Assignment")
    expect(page).to have_content('E2086')
    fill_in('user_name', match: :first, with: instructor6.username)
    click_button('Add', match: :first)
    expect(page).to have_content(instructor6.username)
    expect(page).to have_content(instructor6.email)
    click_button('Submit', match: :first)

    visit("/participants/list?id=#{assignment_test.id}&model=Assignment")
    expect(page).to have_content('E2086')
    fill_in('user_name', match: :first, with: student_test.username)
    click_button('Add', match: :first)
    expect(page).to have_content(student_test.username)
    expect(page).to have_content(student_test.email)

    user_id = User.find_by(username: 'student6666').id
    participant_student = Participant.where(user_id: user_id)
    participant_id = participant_student.first.id
    parent_id = participant_student.first.parent_id
    team_student = Team.where(parent_id: parent_id)
    team_user = create(:team_user, user_id: user_id)

    visit("/assignments/list_submissions?id=#{assignment_test.id}")
    expect(page).to have_content('https://www.expertiza.ncsu.edu')
    expect(page).to have_link('Assign Grade', exact: true)
  end
end
