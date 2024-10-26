include InstructorInterfaceHelperSpec

def create_course_itemnaire(survey_name)
  visit '/itemnaires/new?model=Course+SurveyQuestionnaire&private=0'
  fill_in 'itemnaire_name', with: survey_name
  find('input[name="commit"]').click
end

def deploy_course_survey(start_date, end_date, survey_name)
  login_as('instructor6')
  expect(page).to have_content('Manage content')
  create_course_itemnaire survey_name
  survey = Questionnaire.where(name: survey_name)
  instructor = User.where(name: 'instructor6').first
  course = Course.where(instructor_id: instructor.id).first
  visit '/survey_deployment/new?id=' + course.id.to_s + '&type=CourseSurveyDeployment'
  expect(page).to have_content('New Survey Deployment')
  fill_in 'survey_deployment_start_date', with: start_date
  fill_in 'survey_deployment_end_date', with: end_date
  select survey.name, from: 'survey_deployment_itemnaire_id'
  find('input[name="commit"]').click
end

describe 'Course Survey itemnaire tests for instructor interface' do
  before(:each) do
    course_setup
    @previous_day = (Time.now.getlocal - 1 * 86_400).strftime('%Y-%m-%d %H:%M:%S')
    @next_day = (Time.now.getlocal + 1 * 86_400).strftime('%Y-%m-%d %H:%M:%S')
    @next_to_next_day = (Time.now.getlocal + 2 * 86_400).strftime('%Y-%m-%d %H:%M:%S')
  end

  it 'is able to create a Course survey' do
    login_as('instructor6')
    survey_name = 'Course Survey Questionnaire 1'
    create_course_itemnaire survey_name
    expect(Questionnaire.where(name: survey_name)).to exist
  end

  it 'is able to deploy a course survey with valid dates' do
    survey_name = 'Course Survey Questionnaire 1'
    deploy_course_survey(@next_day, @next_to_next_day, survey_name)
    expect(page).to have_content(survey_name)
  end

  it 'is not able to deploy a course survey with invalid dates' do
    survey_name = 'Course Survey Questionnaire 1'
    # passing current time - 1 day for start date and current time + 2 days for end date
    deploy_course_survey(@previous_day, @next_day, survey_name)
    expect(page).to have_content(survey_name)
  end

  it 'is able to add and edit items to a course survey' do
    survey_name = 'Course Survey Questionnaire 1'
    deploy_course_survey(@next_day, @next_to_next_day, survey_name)
    survey_itemnaire = Questionnaire.where(name: survey_name).first
    # adding some items for the deployed survey
    visit '/itemnaires/' + survey_itemnaire.id.to_s + '/edit'
    fill_in('item_total_num', with: '1')
    select('Criterion', from: 'item_type')
    click_button 'Add'
    expect(page).to have_content('Remove')
    fill_in 'Edit item content here', with: 'Test item 1'
    click_button 'Save course survey itemnaire'
    expect(page).to have_content('All items have been successfully saved!')
  end

  it 'is able to delete item from a course survey' do
    survey_name = 'Course Survey Questionnaire 1'
    deploy_course_survey(@next_day, @next_to_next_day, survey_name)
    survey_itemnaire = Questionnaire.where(name: survey_name).first
    visit '/itemnaires/' + survey_itemnaire.id.to_s + '/edit'
    fill_in('item_total_num', with: '1')
    select('Criterion', from: 'item_type')
    click_button 'Add'
    expect(page).to have_content('Remove')
    fill_in 'Edit item content here', with: 'Test item 1'
    click_button 'Save course survey itemnaire'
    expect(page).to have_content('All items have been successfully saved!')
    item = Question.find_by_sql('select * from items where itemnaire_id = ' + survey_itemnaire.id.to_s)
    click_link('Remove')
    expect(page).to have_content('You have successfully deleted the item!')
  end
end
