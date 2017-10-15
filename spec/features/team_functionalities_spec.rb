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
  end

  it "is able to create a public group assignment" do
    create_new_assignment
    assignment = Assignment.where(name: 'public assignment for test').first
    expect(assignment).to have_attributes(
                              name: 'public assignment for test',
                              course_id: Course.find_by(name: 'Course 2').id,
                              directory_path: 'testDirectory',
                              spec_location: 'testLocation',
                              microtask: true,
                              is_calibrated: true,
                              availability_flag: true
                          )
    visit "/assignments/#{assignment.id}/edit"
    click_link 'Topics'
    click_link 'New topic'
    fill_in 'topic_topic_identifier', with: '112'
    fill_in 'topic_topic_name', with: 'test_topic_1'
    fill_in 'topic_category', with: 'test_topic_1'
    fill_in 'topic_max_choosers', with: 3
    # fill_in 'topic_link', with: 'test_topic_1'
    # fill_in 'topic_description', with: 'test_topic_1'
    click_button 'Create'
    sign_up_topics = SignUpTopic.where(topic_name: 'test_topic_1').first
    expect(sign_up_topics).to have_attributes(
                                  topic_name: 'test_topic_1',
                                  assignment_id: 1,
                                  max_choosers: 3,
                                  topic_identifier: '112',
                                  category: 'test_topic_1'
                              )
    create(:assignment_due_date)
    # assignment = Assignment.where(name: 'public assignment for test').first

    # expect(page).to have_current_path("/assignments/#{assignment.id}/edit#tabs-5", url: true)
    # visit "/assignments/#{assignment.id}/edit#tabs-5"
    # puts current_url
    # fill_in 'assignment_form_assignment_rounds_of_reviews', with: '1'
    # fill_in 'datetimepicker_submission_round_1', with: (Time.now.in_time_zone + 1.day).strftime("%Y/%m/%d %H:%M")
    # fill_in 'datetimepicker_review_round_1', with: (Time.now.in_time_zone + 10.days).strftime("%Y/%m/%d %H:%M")
    # click_button 'Save'
    # expect(page).to have_content("The assignment was successfully saved....")

  end

  # it "adds topic to assignment" do
  #   assignment = Assignment.where(name: 'public assignment for test').first
  #   visit "/assignments/#{assignment.id}/edit"
  #   puts "/assignments/#{assignment.id}/edit"
  # end
end