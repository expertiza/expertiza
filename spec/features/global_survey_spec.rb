include InstructorInterfaceHelperSpec

def create_global_questionnaire(survey_name)
  visit '/questionnaires/new?model=Course+SurveyQuestionnaire&private=0'
  fill_in 'questionnaire_name', with: survey_name
  find('input[name="commit"]').click
end

def deploy_global_survey(start_date, end_date, survey_name)
  login_as('instructor6')
  expect(page).to have_content('Manage content')
  create_global_questionnaire survey_name
  survey = Questionnaire.where(name: survey_name)
  instructor = User.where(name: 'instructor6').first
  course = Course.where(instructor_id: instructor.id).first
  visit '/survey_deployment/new?id=' + course.id.to_s + '&type=CourseSurveyDeployment'
  expect(page).to have_content('New Survey Deployment')
  fill_in 'survey_deployment_start_date', with: start_date
  fill_in 'survey_deployment_end_date', with: end_date
  check('add_global_survey')
  select survey.name, from: 'survey_deployment_questionnaire_id'
  find('input[name="commit"]').click
end

describe 'Global Survey questionnaire tests for instructor interface' do
  before(:each) do
    course_setup
    @previous_day = (Time.now.getlocal - 1 * 86_400).strftime('%Y-%m-%d %H:%M:%S')
    @next_day = (Time.now.getlocal + 1 * 86_400).strftime('%Y-%m-%d %H:%M:%S')
    @next_to_next_day = (Time.now.getlocal + 2 * 86_400).strftime('%Y-%m-%d %H:%M:%S')
  end

  it 'is able to create a Global survey' do
    login_as('instructor6')
    survey_name = 'Global Survey Questionnaire 1'
    create_global_questionnaire survey_name
    expect(Questionnaire.where(name: survey_name)).to exist
  end

  it 'is able to deploy a global survey with valid dates' do
    survey_name = 'Global Survey Questionnaire 1'
    deploy_global_survey(@next_day, @next_to_next_day, survey_name)
    expect(Questionnaire.where(name: survey_name)).to exist
  end

  it 'is not able to deploy a global survey with invalid dates' do
    survey_name = 'Global Survey Questionnaire 1'
    # passing current time - 1 day for start date and current time + 2 days for end date
    deploy_global_survey(@previous_day, @next_day, survey_name)
    expect(Questionnaire.where(name: survey_name)).to exist
  end

  it 'is able to add and edit questions to a course survey' do
    survey_name = 'Global Survey Questionnaire 1'
    deploy_global_survey(@next_day, @next_to_next_day, survey_name)
    survey_questionnaire = Questionnaire.where(name: survey_name).first

    # adding some questions for the deployed survey
    visit '/questionnaires/' + survey_questionnaire.id.to_s + '/edit'
    fill_in('question_total_num', with: '1')
    select('Criterion', from: 'question_type')
    click_button 'Add'
    expect(page).to have_content('Remove')
    fill_in 'Edit question content here', with: 'Test question 1'
    click_button 'Save course survey questionnaire'
    expect(page).to have_content('All questions have been successfully saved!')
  end

  it 'is able to delete question from a global survey' do
    survey_name = 'Global Survey Questionnaire 1'
    deploy_global_survey(@next_day, @next_to_next_day, survey_name)
    survey_questionnaire = Questionnaire.where(name: survey_name).first
    visit '/questionnaires/' + survey_questionnaire.id.to_s + '/edit'
    fill_in('question_total_num', with: '1')
    select('Criterion', from: 'question_type')
    click_button 'Add'
    expect(page).to have_content('Remove')
    fill_in 'Edit question content here', with: 'Test question 1'
    click_button 'Save course survey questionnaire'
    expect(page).to have_content('All questions have been successfully saved!')
    question = Question.find_by_sql('select * from questions where questionnaire_id = ' + survey_questionnaire.id.to_s)
    click_link('Remove')
    expect(page).to have_content('You have successfully deleted the question!')
  end
end
