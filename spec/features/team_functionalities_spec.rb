require 'rails_helper'
def create_new_assignment
  login_as("instructor6")
  visit "/assignments/new?private=0"

  fill_in 'assignment_form_assignment_name', with: 'public assignment for test'
  select('Course 2', from: 'assignment_form_assignment_course_id')
  fill_in 'assignment_form_assignment_directory_path', with: 'testDirectory'
  fill_in 'assignment_form_assignment_spec_location', with: 'testLocation'
  check("assignment_form_assignment_microtask")
  check("team_assignment")
  fill_in 'assignment_form_assignment_max_team_size', with: '3', visible: false
  check("assignment_form_assignment_reviews_visible_to_all")
  check("assignment_form_assignment_is_calibrated")
  check("assignment_form_assignment_availability_flag")
  expect(page).to have_select("assignment_form[assignment][reputation_algorithm]", options: ['--', 'Hamer', 'Lauw'])

  click_button 'Create'
end

def add_topic_to_assignment assignment
  visit "/assignments/#{assignment.id}/edit"
  click_link 'Topics'
  click_link 'New topic'
  fill_in 'topic_topic_identifier', with: '112'
  fill_in 'topic_topic_name', with: 'test_topic_1'
  fill_in 'topic_category', with: 'test_topic_1'
  fill_in 'topic_max_choosers', with: 3
  click_button 'Create'
  create(:assignment_due_date)
  create_list(:participant, 3)
end

describe "create group assignment"  do
  before(:each) do
    create(:deadline_type, name: "submission")
    create(:deadline_type, name: "review")
    create(:deadline_type, name: "metareview")
    create(:deadline_type, name: "drop_topic")
    create(:deadline_type, name: "signup")
    create(:deadline_type, name: "team_formation")
    create(:deadline_right)
    create(:deadline_right, name: 'Late')
    create(:deadline_right, name: 'OK')
    (1..3).each do |i|
      create(:course, name: "Course #{i}")
    end
    create_new_assignment
    @assignment = Assignment.where(name: 'public assignment for test').first
    add_topic_to_assignment @assignment
  end

  it "is able to create a public group assignment" do
    #assignment = Assignment.where(name: 'public assignment for test').first
    expect(@assignment).to have_attributes(
                              name: 'public assignment for test',
                              course_id: Course.find_by(name: 'Course 2').id,
                              directory_path: 'testDirectory',
                              spec_location: 'testLocation',
                              microtask: true,
                              is_calibrated: true,
                              availability_flag: true
                          )

    #add_topic_to_assignment assignment
    sign_up_topics = SignUpTopic.where(topic_name: 'test_topic_1').first
    expect(sign_up_topics).to have_attributes(
                                  topic_name: 'test_topic_1',
                                  assignment_id: 1,
                                  max_choosers: 3,
                                  topic_identifier: '112',
                                  category: 'test_topic_1'
                              )
  end

  it "should impersonate as student" do

    user = User.find_by(name: "student2064")
    stub_current_user(user, user.role.name, user.role)
    visit '/student_task/list'
    # Assignment name
    expect(page).to have_content('public assignment for test')
    click_link 'public assignment for test'
    expect(page).to have_content('Submit or Review work for public assignment for test')

    click_link 'Signup sheet'
    expect(page).to have_content('Signup sheet for public assignment for test assignment')
    assignment_id = Assignment.first.id
    visit "/sign_up_sheet/sign_up?id=#{assignment_id}&topic_id=1"
    expect(page).to have_content('Your topic(s): test_topic_1')

    visit '/student_task/list'
    click_link 'public assignment for test'
    click_link 'Your team'
    expect(page).to have_content('public assignment for test_Team1')
    fill_in 'user_name', with: 'student2065'
    click_button 'Invite'
    fill_in 'user_name', with: 'student2066'
    click_button 'Invite'
    expect(page).to have_content('student2065')
    end

  it "Other users join/decline the team" do

    user = User.find_by(name: "student2065")
    stub_current_user(user, user.role.name, user.role)
    visit '/student_task/list'
    expect(page).to have_content('public assignment for test')
    visit '/invitation/accept?inv_id=1&student_id=1&team_id=1'
    visit '/student_teams/view?student_id=1'
    expect(page).to have_content('Team Information for public assignment for test')

    # to test invalid case - student who is not part of the team does not have created assignment
    user = User.find_by(name: "student2066")
    stub_current_user(user, user.role.name, user.role)
    visit '/student_task/list'
    page.should has_no_content?('public assignment for test')

  end
end