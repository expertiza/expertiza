require_relative 'helpers/assignment_creation_helper'

describe 'Assignment creation topics tab', js: true do
  include AssignmentCreationHelper
  before(:each) do
    create_deadline_types
    (1..3).each do |i|
      create(:course, name: "Course #{i}")
    end
    assignment = create(:assignment, name: 'public assignment for test')
    login_as('instructor6')
    visit "/assignments/#{assignment.id}/edit"
    check('assignment_has_topics')
    click_link 'Topics'
  end
  it 'Selects all the checkboxes when select all checkbox clicked' do
    assignment = Assignment.where(name: 'public assignment for test').first
    create(:topic, assignment_id: assignment.id)
    create(:topic, assignment_id: assignment.id)
    visit "/assignments/#{assignment.id}/edit"
    click_link 'Topics'
    expect(page).to have_field('select_all')
    check('select_all')
    expect(page).to have_checked_field('topic_check')
  end
  it 'Deletes nothing when select all checkbox is not clicked and none of the topics are selected', js: true do
    assignment = Assignment.where(name: 'public assignment for test').first
    create(:topic, assignment_id: assignment.id)
    create(:topic, assignment_id: assignment.id)
    visit "/assignments/#{assignment.id}/edit"
    click_link 'Topics'
    click_button 'Delete selected topics'
    page.driver.browser.switch_to.alert.accept
    sleep 3
    topics_exist = SignUpTopic.where(assignment_id: assignment.id).count
    expect(topics_exist).to be_eql 2
  end
  it 'can edit topics properties' do
    check('assignment_form_assignment_allow_suggestions')
    check('assignment_form_assignment_is_intelligent')
    check('assignment_form_assignment_can_review_same_topic')
    check('assignment_form_assignment_can_choose_topic_to_review')
    check('assignment_form_assignment_use_bookmark')
    click_button 'submit_btn'
    assignment = Assignment.where(name: 'public assignment for test').first
    expect(assignment).to have_attributes(
      allow_suggestions: true,
      is_intelligent: true,
      can_review_same_topic: true,
      can_choose_topic_to_review: true,
      use_bookmark: true
    )
  end

  it 'proceeds without topics properties' do
    uncheck('assignment_form_assignment_allow_suggestions')
    uncheck('assignment_form_assignment_is_intelligent')
    uncheck('assignment_form_assignment_can_review_same_topic')
    uncheck('assignment_form_assignment_can_choose_topic_to_review')
    uncheck('assignment_form_assignment_use_bookmark')
    click_button 'submit_btn'
    assignment = Assignment.where(name: 'public assignment for test').first
    expect(assignment).to have_attributes(
      allow_suggestions: false,
      is_intelligent: false,
      can_review_same_topic: false,
      can_choose_topic_to_review: false,
      use_bookmark: false
    )
  end

  it 'can create new topics' do
    click_link 'New topic'
    click_button 'OK'
    fill_in 'topic_topic_identifier', with: '1'
    fill_in 'topic_topic_name', with: 'Test'
    fill_in 'topic_category', with: 'Test Category'
    fill_in 'topic_max_choosers', with: 2
    click_button 'Create'

    sign_up_topics = SignUpTopic.where(topic_name: 'Test').first
    expect(sign_up_topics).to have_attributes(
      topic_name: 'Test',
      assignment_id: 1,
      max_choosers: 2,
      topic_identifier: '1',
      category: 'Test Category'
    )
  end

  it 'can delete existing topic', js: true do
    create(:assignment_due_date, deadline_type: DeadlineType.where(name: 'submission').first, due_at: DateTime.now.in_time_zone + 1.day)
    click_link 'Due date'
    fill_in 'assignment_form_assignment_rounds_of_reviews', with: '1'
    click_button 'set_rounds'
    # fill_in 'datetimepicker_submission_round_1', with: (Time.now.in_time_zone + 10.days).strftime("%Y/%m/%d %H:%M")
    # fill_in 'datetimepicker_review_round_1', with: (Time.now.in_time_zone + 100.days).strftime("%Y/%m/%d %H:%M")
    click_button 'submit_btn'
    assignment = Assignment.where(name: 'public assignment for test').first
    create(:topic, assignment_id: assignment.id)
    visit "/assignments/#{assignment.id}/edit"
    click_link 'Topics'
    all(:xpath, '//img[@title="Delete Topic"]')[0].click
    click_button 'OK'

    topics_exist = SignUpTopic.where(assignment_id: assignment.id).count
    expect(topics_exist).to be_eql 0
  end

  it 'hides topics tab when has topics is un-checked', js: true do
    click_link 'General'
    uncheck('assignment_has_topics')
    # The below line is used to accept the js confirmation popup
    page.driver.browser.switch_to.alert.accept
    # Wait for topics to be removed and page to re-load
    sleep 3
    expect(page).not_to have_link('Topics')
  end
end
