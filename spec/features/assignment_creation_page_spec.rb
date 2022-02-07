require_relative 'helpers/assignment_creation_helper'

describe 'Assignment creation page', js: true do
  include AssignmentCreationHelper
  before(:each) do
    create_deadline_types
    (1..3).each do |i|
      create(:course, name: "Course #{i}")
    end
  end

  # Might as well test small flags for creation here
  it 'is able to create a public assignment' do
    login_as('instructor6')
    visit '/assignments/new?private=0'

    fill_in 'assignment_form_assignment_name', with: 'public assignment for test'
    select('Course 2', from: 'assignment_form_assignment_course_id')
    fill_in 'assignment_form_assignment_directory_path', with: 'testDirectory'
    fill_in 'assignment_form_assignment_spec_location', with: 'testLocation'
    check('assignment_form_assignment_microtask')
    check('assignment_form_assignment_reviews_visible_to_all')
    check('assignment_form_assignment_is_calibrated')
    uncheck('assignment_form_assignment_availability_flag')
    expect(page).to have_select('assignment_form[assignment][reputation_algorithm]', options: %w[-- Hamer Lauw])

    click_button 'Create'
    assignment = Assignment.where(name: 'public assignment for test').first
    expect(assignment).to have_attributes(
      name: 'public assignment for test',
      course_id: Course.find_by(name: 'Course 2').id,
      directory_path: 'testDirectory',
      spec_location: 'testLocation',
      microtask: true,
      is_calibrated: true,
      availability_flag: false
    )
  end

  it 'is able to create with teams' do
    assignment_creation_setup(1, 'private assignment for test')
    check('team_assignment')
    check('assignment_form_assignment_show_teammate_reviews')
    fill_in 'assignment_form_assignment_max_team_size', with: 3

    click_button 'Create'

    assignment = Assignment.where(name: 'private assignment for test').first
    expect(assignment).to have_attributes(
      max_team_size: 3,
      show_teammate_reviews: true
    )
  end

  # instructor can check "has quiz" box and set the number of quiz questions
  it 'is able to create with quiz' do
    assignment_creation_setup(1, 'private assignment for test')
    check('assignment_form_assignment_require_quiz')
    click_button 'Create'
    fill_in 'assignment_form_assignment_num_quiz_questions', with: 3
    click_button 'submit_btn'

    assignment = Assignment.where(name: 'private assignment for test').first
    expect(assignment).to have_attributes(
      num_quiz_questions: 3,
      require_quiz: true
    )
  end

  it 'is able to create with staggered deadline' do
    skip('skip test on staggered deadline temporarily')
    assignment_creation_setup(1, 'private assignment for test')
    begin
      check('assignment_form_assignment_staggered_deadline')
    rescue StandardError
      return
    end
    page.driver.browser.switch_to.alert.accept
    click_button 'Create'
    fill_in 'assignment_form_assignment_days_between_submissions', with: 7
    click_button 'submit_btn'

    assignment = Assignment.where(name: 'private assignment for test').first
    pending(%(not sure what's broken here but the error is: #ActionController::RoutingError: No route matches [GET] "/assets/staggered_deadline_assignment_graph/graph_1.jpg"))
    expect(assignment).to have_attributes(
      staggered_deadline: true
    )
  end

  ## should be able to create with review visible to all reviewres
  it 'is able to create with review visible to all reviewers' do
    assignment_creation_setup(1, 'private assignment for test')
    fill_in 'assignment_form_assignment_spec_location', with: 'testLocation'
    check('assignment_form_assignment_reviews_visible_to_all')
    click_button 'Create'
    expect(page).to have_select('assignment_form[assignment][reputation_algorithm]', options: %w[-- Hamer Lauw])
    # click_button 'Create'
    assignment = Assignment.where(name: 'private assignment for test').first
    expect(assignment).to have_attributes(
      name: 'private assignment for test',
      course_id: Course.find_by(name: 'Course 2').id,
      directory_path: 'testDirectory',
      spec_location: 'testLocation'
    )
  end

  it 'is able to create public micro-task assignment' do
    assignment_creation_setup(0, 'public assignment for test')
    check('assignment_form_assignment_microtask')
    click_button 'Create'

    assignment = Assignment.where(name: 'public assignment for test').first
    expect(assignment).to have_attributes(
      microtask: true
    )
  end

  it 'is able to create calibrated public assignment' do
    assignment_creation_setup(0, 'public assignment for test')
    check('assignment_form_assignment_is_calibrated')
    click_button 'Create'

    assignment = Assignment.where(name: 'public assignment for test').first
    expect(assignment).to have_attributes(
      is_calibrated: true
    )
  end

  it 'is able show tab review strategy' do
    assignment_creation_setup(1, 'private assignment for test')

    find_link('ReviewStrategy').click
    expect(page).to have_content('Review strategy')
  end

  it 'is able show tab due deadlines' do
    assignment_creation_setup(0, 'public assignment for test')

    find_link('Due date').click
    expect(page).to have_content('Deadline type')
  end

  it 'set the deadline for an assignment review' do
    assignment_creation_setup(0, 'public assignment for test')
    click_link 'Due date'
    fill_in 'assignment_form_assignment_rounds_of_reviews', with: '1'
    click_button 'set_rounds'
    fill_in 'datetimepicker_submission_round_1', with: (Time.now.in_time_zone + 1.day).strftime('%Y/%m/%d %H:%M')
    fill_in 'datetimepicker_review_round_1', with: (Time.now.in_time_zone + 10.days).strftime('%Y/%m/%d %H:%M')
    click_button 'submit_btn'

    submission_type_id = DeadlineType.where(name: 'submission')[0].id
    review_type_id = DeadlineType.where(name: 'review')[0].id

    submission_due_date = DueDate.find(1)
    review_due_date = DueDate.find(2)
    expect(submission_due_date).to have_attributes(
      deadline_type_id: submission_type_id,
      type: 'AssignmentDueDate'
    )

    expect(review_due_date).to have_attributes(
      deadline_type_id: review_type_id,
      type: 'AssignmentDueDate'
    )
  end

  it 'is able show tab rubrics' do
    assignment_creation_setup(0, 'public assignment for test')

    find_link('Rubrics').click
    expect(page).to have_content('rubric varies by round')
  end

  it 'is able show attributes in rubrics' do
    assignment_creation_setup(0, 'public assignment for test')

    find_link('Rubrics').click
    expect(page).to have_content('rubric varies by round')
  end

  it 'sets attributes for review strategy auto selects' do
    assignment_creation_setup(0, 'public assignment for test')

    find_link('ReviewStrategy').click
    select 'Auto-Selected', from: 'assignment_form_assignment_review_assignment_strategy'
    fill_in 'assignment_form_assignment_review_topic_threshold', with: 3
    fill_in 'assignment_form_assignment_max_reviews_per_submission', with: 10
    click_button 'Create'
    assignment = Assignment.where(name: 'public assignment for test').first
    expect(assignment).to have_attributes(
      review_assignment_strategy: 'Auto-Selected',
      review_topic_threshold: 3,
      max_reviews_per_submission: 10
    )
  end
end

describe 'adding to course', js: true do
  include AssignmentCreationHelper
  before(:each) do
    create_deadline_types
  end
  it 'check to find if the assignment can be added to a course', js: true do
    create(:assignment, course: nil, name: 'Test Assignment')
    create(:course, name: 'Test Course')

    course_id = Course.where(name: 'test Course')[0].id

    assignment_id = Assignment.where(name: 'Test Assignment')[0].id

    login_as('instructor6')
    visit "/assignments/place_assignment_in_course?id=#{assignment_id}"

    choose "course_id_#{course_id}"
    click_button 'Save'

    assignment_row = Assignment.where(name: 'Test Assignment')[0]
    expect(assignment_row).to have_attributes(
      course_id: course_id
    )
  end
end
