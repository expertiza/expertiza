require 'rails_helper'

describe "Airbrake expection errors" do
#   it 'create data' do
#     create(:deadline_type, name: "submission")
#     create(:deadline_type, name: "review")
#     create(:deadline_type, name: "metareview")
#     create(:deadline_type, name: "drop_topic")
#     create(:deadline_type, name: "signup")
#     create(:deadline_type, name: "team_formation")
#     create(:deadline_right)
#     create(:deadline_right, name: 'Late')
#     create(:deadline_right, name: 'OK')
#     @assignment=create(:assignment, name: "TestAssignment_airbrake", directory_path: 'test_assignment')
#     create_list(:participant, 3,assignment: Assignment.find_by(name:'TestAssignment_airbrake'))
#     create(:assignment_node,node_object_id:@assignment.id)
#     create(:assignment_due_date, assignment:@assignment,due_at: (DateTime.now.in_time_zone + 10.year))
#     create(:assignment_due_date, assignment:@assignment,deadline_type: DeadlineType.where(name: 'review').first, due_at: (DateTime.now.in_time_zone + 100.year))
#     @topic1=create(:topic, assignment: @assignment,topic_name: "TestReview_airbrake")
#     @topic2=create(:topic, assignment: @assignment,topic_name: "TestReview_airbrake2")
#     @team1=create(:assignment_team,name:'airbrake_test_team1',assignment:@assignment)
#     create(:assignment_team,name:'airbrake_test_team2',assignment:@assignment)
#     create(:signed_up_team,team_id:@team1.id,topic:@topic1)
#     create(:team_user, user: User.where(role_id: 2).first,team: AssignmentTeam.find_by(name:'airbrake_test_team1'))
#     create(:team_user, user: User.where(role_id: 2).second,team: AssignmentTeam.find_by(name:'airbrake_test_team1'))
#     create(:team_user, user: User.where(role_id: 2).third, team: AssignmentTeam.find_by(name:'airbrake_test_team2'))
#     #create(:signed_up_team)
#     create(:signed_up_team, team_id: AssignmentTeam.where(name:'airbrake_test_team1').first.id, topic: SignUpTopic.where(topic_name:'TestReview_airbrake').first)
#
# #        @topic2=create(:topic,assignment:@assignment)# need to be deleted
# #        create(:signed_up_team, team_id: @team2.id, topic: @topic2)
#
#     create(:assignment_questionnaire,assignment:Assignment.find_by(name:'TestAssignment_airbrake'))
#     create(:signed_up_team, team_id: AssignmentTeam.where(name:'airbrake_test_team2').first.id, topic: SignUpTopic.where(topic_name:'TestReview_airbrake2').first)
#     (1..25).each { |i| create(:student, name: "student#{i}") }
#   end
#   end

# Airbrake-1806782678925052472
  it "can list sign_up_topics by using 'id' (participant_id) as parameter", js: true do
    login_as 'student2066'
    @assignment=Assignment.find_by(name:'TestAssignment_airbrake')
    @student1=User.where(name:'student2066').first
    @participant1=  Participant.where(parent_id:@assignment.id,user_id:@student1.id).first
    visit "/sign_up_sheet/list?id=#{@participant1.id}"
    expect(page).to have_content('Signup sheet for')
    expect(page).to have_content('TestReview_airbrake')
  end
  # Airbrake-1780737855340413304
  it "will redirect to submitted_content#view page if trying to save quiz but w/o questions", js: true do
    assignment=Assignment.where(name:'TestAssignment_airbrake').first
    assignment.update_attributes(require_quiz: true)
    login_as 'student2064'
    user_id = User.find_by_name('student2064').id
    participant_id = Participant.where(user_id: user_id,parent_id:assignment.id).first.id
    visit '/student_task/list'
    click_link 'TestAssignment_airbrake'
    click_link 'Your work'
    click_link 'Create a quiz'
    expect(page).to have_content('New Quiz')
    fill_in 'questionnaire_name', with: 'Test quiz airbrake'
    click_button 'Create Quiz'

    expect(page).to have_content 'View quiz'
    expect(page).to have_content 'Edit quiz'
    click_link 'Edit quiz'
    expect(page).to have_content('Edit Quiz')
    click_button 'Save quiz'
    expect(page).to have_current_path("/submitted_content/#{participant_id}/edit")
    Questionnaire.where(name: 'Test quiz airbrake').destroy_all

  end

  # Airbrake-1800240536513675372
  it "can delete topics in staggered deadline assignment", js: true do

    assignment = Assignment.find_by(name:'TestAssignment_airbrake')
    assignment.update_attributes(staggered_deadline: true)
    create(:topic, assignment: assignment,topic_name: "tmp_airbrake_topic")

    login_as 'instructor6'
    visit "/assignments/#{assignment.id}/edit"
    check("assignment_form_assignment_staggered_deadline")
    click_button 'Save'

    find_link('Topics').click
    # Delete first topic
    all("img[title='Delete Topic']")[2].click
    # page.execute_script 'window.confirm = function () { return true }'
    click_button 'OK'
    find_link('Topics').click
    expect(page).to have_content('TestReview')
    expect(page).not_to have_content('tmp_airbrake_topic')
    assignment.update_attributes(staggered_deadline: false)
  end
  # Airbrake-1608029321738848168
  it "will not show error when instructor did not login and try to access assignment editting page" do
    assignment = Assignment.find_by(name:'TestAssignment_airbrake')
    visit "/assignments/#{assignment.id}/edit"
    expect(page).to have_current_path('/')
    expect(page).to have_content('is not allowed to edit this/these assignments')
    expect(page).to have_content('Welcome!')
    expect(page).to have_content('User Name')
    expect(page).to have_content('Password')

    login_as 'instructor6'
    visit "/assignments/#{assignment.id}/edit"
    expect(page).to have_current_path("/assignments/#{assignment.id}/edit")
    expect(page).to have_content('Editing Assignment: TestAssignment_airbrake')
  end
  it 'will not raise error when saving questionnaire w/o question', js: true do
    login_as 'instructor6'
    visit '/questionnaires/new?model=ReviewQuestionnaire&private=0'
    fill_in('questionnaire_name', with: 'Review airbrake')
    click_button 'Create'
    questionnaire = Questionnaire.where(name: 'Review airbrake').first
    expect(page).to have_current_path("/author_feedback_questionnaires/#{questionnaire.id}/edit")
    expect(page).to have_content('Edit Review')
    expect(page).to have_content('Import/Export (from/to CSV format)')

    click_button('Save review questionnaire')
    expect{page}.not_to raise_error
    expect(page).to have_current_path("/questionnaires/#{questionnaire.id}/edit")
    expect(page).to have_content("undefined method `each_pair' for nil:NilClass")
    Questionnaire.where(name: 'Review airbrake').destroy_all
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
    stu = User.find_by(name:'student2065')
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
    @assignment = Assignment.find_by(name:'TestAssignment_airbrake')
    login_as 'instructor6'
    visit "/teams/new?id=#{@assignment.id}"
    expect{page}.not_to raise_error
    expect(page).to have_content("Create Teams for #{@assignment.name}")
    expect(page).to have_content('Automatically')
    expect(page).to have_content('Manually')
    expect(page).to have_content('Inherit Teams From Course')
  end
end

describe 'airbrake-1776303046291622084' do
  it 'can paginate user list by clicking alphabet characters' do
    login_as 'instructor6'
    visit '/users/list'
    expect{page}.not_to raise_error
    expect(page).to have_content('Manage users')
    expect(page).to have_content('Users per page:')
    expect(page).to have_content('New User | Import Users| Export Users')
    expect(page).to have_content('instructor6')
    first=User.find_by(name:"student1").id
    last=User.find_by(name:"student10").id
    (first..last).each { |i| expect(page).to have_content("student#{i-first+1}")}

    # start paginating
    first(:link, 'N').click
    expect(page).to have_current_path('/users/list?from_letter=1&letter=N')
    expect(page).to have_content('← Previous 1 2 Next →')
    expect(page).to have_content('instructor6')
    (first..last-1).each { |i| expect(page).to have_content("student#{i-first+1}")}
    expect(page).not_to have_content('student25')

    # goto 2nd page
    first(:link, '2').click
    expect(page).not_to have_content("student1")
    # exclude content 'student2' because of 'student25'
    (first+2..last).each { |i| expect(page).not_to have_content("student#{i-first+1}")}
    expect(page).to have_content('student25')
  end
end

