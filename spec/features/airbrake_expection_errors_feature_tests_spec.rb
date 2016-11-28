require 'rails_helper'

describe "Airbrake expection errors" do
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
    create(:assignment_due_date, due_at: (DateTime.now.in_time_zone + 1))
    create(:assignment_due_date, deadline_type: DeadlineType.where(name: 'review').first, due_at: (DateTime.now.in_time_zone + 5))
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

  # Airbrake-1806782678925052472
  it "can list sign_up_topics by using 'id' (participant_id) as parameter", js: true do
    login_as 'student2066'
    visit '/sign_up_sheet/list?id=1'
    expect(page).to have_content('Signup sheet for')
    expect(page).to have_content('Hello world!')
    expect(page).to have_content('TestReview')
  end

  # Airbrake-1780737855340413304
  it "will redirect to submitted_content#view page if trying to save quiz but w/o questions", js: true do
    assignment = Assignment.first
    assignment.update_attributes(require_quiz: true)
    login_as 'student2064'
    user_id = User.find_by_name('student2064').id
    participant_id = Participant.where(user_id: user_id).first.id
    visit '/student_task/list'
    click_link 'TestAssignment'
    click_link 'Your work'
    click_link 'Create a quiz'
    expect(page).to have_content('New Quiz')
    fill_in 'questionnaire_name', with: 'Test quiz'
    click_button 'Create Quiz'

    expect(page).to have_content 'View quiz'
    expect(page).to have_content 'Edit quiz'
    click_link 'Edit quiz'
    expect(page).to have_content('Edit Quiz')
    click_button 'Save quiz'
    expect(page).to have_current_path("/submitted_content/#{participant_id}/edit")
  end

  # Airbrake-1800240536513675372
  it "can delete topics in staggered deadline assignment", js: true do
    assignment = Assignment.first
    assignment.update_attributes(staggered_deadline: true)
    login_as 'instructor6'
    visit "/assignments/#{assignment.id}/edit"
    check("assignment_form_assignment_staggered_deadline")
    click_button 'Save'

    find_link('Topics').click
    # Delete first topic
    first("img[title='Delete Topic']").click
    # page.execute_script 'window.confirm = function () { return true }'
    click_button 'OK'
    find_link('Topics').click
    expect(page).to have_content('TestReview')
    expect(page).not_to have_content('Hello world!')
  end

  # Airbrake-1608029321738848168
  it "will not show error when instructor did not login and try to access assignment editting page" do
      assignment = Assignment.first
      visit "/assignments/#{assignment.id}/edit"
      expect(page).to have_current_path('/')
      expect(page).to have_content('is not allowed to edit this/these assignments')
      expect(page).to have_content('Welcome!')
      expect(page).to have_content('User Name')
      expect(page).to have_content('Password')

      login_as 'instructor6'
      visit "/assignments/#{assignment.id}/edit"
      expect(page).to have_current_path("/assignments/#{assignment.id}/edit")
      expect(page).to have_content('Editing Assignment: TestAssignment')
  end

  # Airbrake-1817691804353957801
  it 'will not raise error when saving questionnaire w/o question', js: true do
      login_as 'instructor6'
      visit '/questionnaires/new?model=ReviewQuestionnaire&private=0'
      fill_in('questionnaire_name', with: 'Review 1')
      click_button 'Create'
      questionnaire = Questionnaire.where(name: 'Review 1').first
      expect(page).to have_current_path("/author_feedback_questionnaires/#{questionnaire.id}/edit")
      expect(page).to have_content('Edit Review')
      expect(page).to have_content('Import/Export (from/to CSV format)')

      click_button('Save review questionnaire')
      expect{page}.not_to raise_error
      expect(page).to have_current_path("/questionnaires/#{questionnaire.id}/edit")
      expect(page).to have_content("undefined method `each_pair' for nil:NilClass")
  end
end

describe "airbrake-1517247902792549741" do
  it "cannot access to '/tree_display/list' if not login" do
    visit '/tree_display/list'
    expect(page).to have_current_path('/auth/failure')
    expect(page).not_to have_content('Manage content')
    expect(page).to have_content('Welcome!')
    expect(page).to have_content('User Name')
    expect(page).to have_content('Password')
  end

  it "can access to '/tree_display/list' after login as an admin/instructor/TA" do
    create(:instructor)
    login_as 'instructor6'
    visit '/tree_display/list'
    expect(page).to have_current_path('/tree_display/list')
    expect(page).to have_content('Manage content')
    expect(page).to have_content('Courses')
    expect(page).to have_content('Assignments')
    expect(page).to have_content('Questionnaires')
    expect(page).not_to have_content('Welcome!')
    expect(page).not_to have_content('User Name')
    expect(page).not_to have_content('Password')
  end

    it "can access to '/student_task/list' after login as a student" do
        stu = create(:student)
        login_as stu.name
        visit '/tree_display/list'
        expect(page).to have_current_path('/student_task/list')
        expect(page).to have_content('Assignments')
        expect(page).to have_content('Tasks not yet started')
        expect(page).to have_content('Students who have teamed with you')
        expect(page).to have_content('Review Grade')
        expect(page).to have_content('Publishing Rights')
        expect(page).not_to have_content('Welcome!')
        expect(page).not_to have_content('User Name')
        expect(page).not_to have_content('Password')
        expect(page).not_to have_content('SIGN IN')
    end
end

describe "airbrake-1804043391875943089" do
    it "can access team creation page even if the session[:team_type] is nil" do
        assignment = create(:assignment)
        login_as 'instructor6'
        visit "/teams/new?id=#{assignment.id}"
        expect{page}.not_to raise_error
        expect(page).to have_content("Create Teams for #{assignment.name}")
        expect(page).to have_content('Automatically')
        expect(page).to have_content('Manually')
        expect(page).to have_content('Inherit Teams From Course')
    end
end

describe 'airbrake-1776303046291622084' do
    it 'can paginate user list by clicking alphabet characters' do
        create(:instructor)
        (1..25).each { |i| create(:student, name: "student#{i}") }
        login_as 'instructor6'
        visit '/users/list'
        expect{page}.not_to raise_error
        expect(page).to have_content('Manage users')
        expect(page).to have_content('Users per page:')
        expect(page).to have_content('New User | Import Users| Export Users')
        expect(page).to have_content('instructor6')
        (1..25).each { |i| expect(page).to have_content("student#{i}")}

        # start paginating
        first(:link, 'N').click
        expect(page).to have_current_path('/users/list?from_letter=1&letter=N')
        expect(page).to have_content('← Previous 1 2 Next →')
        expect(page).to have_content('instructor6')
        (1..24).each { |i| expect(page).to have_content("student#{i}")}
        expect(page).not_to have_content('student25')

        # goto 2nd page
        first(:link, '2').click
        expect(page).not_to have_content("student1")
        # exclude content 'student2' because of 'student25'
        (3..24).each { |i| expect(page).not_to have_content("student#{i}")}
        expect(page).to have_content('student25')
    end
end