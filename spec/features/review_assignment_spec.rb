describe 'peer review testing' do
  before(:each) do
    # create assignment and topic
    create(:assignment, name: 'TestAssignment', directory_path: 'TestAssignment')
    create_list(:participant, 3)
    create(:topic, topic_name: 'TestTopic')
    create(:deadline_type, name: 'submission')
    create(:deadline_type, name: 'review')
    create(:deadline_type, name: 'metareview')
    create(:deadline_type, name: 'drop_topic')
    create(:deadline_type, name: 'signup')
    create(:deadline_type, name: 'team_formation')
    create(:deadline_right)
    create(:deadline_right, name: 'Late')
    create(:deadline_right, name: 'OK')
    create(:assignment_due_date, deadline_type: DeadlineType.where(name: 'submission').first, due_at: DateTime.now.in_time_zone + 1.day)
    create(:assignment_due_date, deadline_type: DeadlineType.where(name: 'review').first, due_at: DateTime.now.in_time_zone + 1.day)
  end

  def signup_topic
    user = User.find_by(name: 'student2064')
    login_as(user.name)
    visit '/student_task/list'
    visit '/sign_up_sheet/sign_up?id=1&topic_id=1' # signup topic
    visit '/student_task/list'
    click_link 'TestAssignment'
    click_link 'Your work'
  end

  def submit_to_topic
    signup_topic
    fill_in 'submission', with: 'https://www.ncsu.edu'
    click_on 'Upload link'
    expect(page).to have_content 'https://www.ncsu.edu'
  end

  it 'is able to submit a single valid link' do
    submit_to_topic
    # open the link and check content
    click_on 'https://www.ncsu.edu'
    expect(page).to have_http_status(200)
  end

  it 'is not able to select review with no submissions' do
    user = User.find_by(name: 'student2065')
    login_as(user.name)
    visit '/student_task/list'
    click_link 'TestAssignment'
    click_link "Others' work"
    find(:css, '#i_dont_care').set(true)
    click_button 'Request a new submission to review'
    expect(page).to have_content 'No topics are available to review at this time. Please try later.'
  end

  it 'is not able to be assigned to review a topic only they have submitted on' do
    submit_to_topic
    visit '/student_task/list'
    click_link 'TestAssignment'
    click_link "Others' work"
    find(:css, '#i_dont_care').set(true)
    click_button 'Request a new submission to review'
    expect(page).to have_content 'No topics are available to review at this time. Please try later.'
  end

  it 'is not able to select topic for review only they have submitted to' do
    submit_to_topic
    visit '/student_task/list'
    click_link 'TestAssignment'
    click_link "Others' work"
    expect(page).to have_content 'Reviews for "TestAssignment"'
    expect(page).not_to have_button("topic_id_#{SignUpTopic.find_by(topic_name: 'TestTopic').id}")
  end

  it 'is able to select topic for review with valid submissions' do
    submit_to_topic
    click_link 'Logout'
    user = User.find_by(name: 'student2065')
    login_as(user.name)
    visit '/student_task/list'
    visit '/sign_up_sheet/sign_up?id=1&topic_id=1'
    visit '/student_task/list'
    click_link 'TestAssignment'
    click_link "Others' work"
    choose "topic_id_#{SignUpTopic.find_by(topic_name: 'TestTopic').id}"
    click_button 'Request a new submission to review'
    expect(page).to have_content 'No previous versions available'
  end

  it 'is able to be assigned random topic for review' do
    submit_to_topic
    click_link 'Logout'
    user = User.find_by(name: 'student2065')
    login_as(user.name)
    visit '/student_task/list'
    visit '/sign_up_sheet/sign_up?id=1&topic_id=1'
    visit '/student_task/list'
    click_link 'TestAssignment'
    click_link "Others' work"
    find(:css, '#i_dont_care').set(true)
    click_button 'Request a new submission to review'
    expect(page).to have_content 'No previous versions available'
  end
end
