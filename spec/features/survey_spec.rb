include InstructorInterfaceHelperSpec

def create_assignment_itemnaire(survey_name)
  visit '/itemnaires/new?model=Assignment+SurveyQuestionnaire&private=0'
  fill_in 'itemnaire_name', with: survey_name
  find('input[name="commit"]').click
end

def deploy_survey(start_date, end_date, survey_name)
  login_as('instructor6')
  expect(page).to have_content('Manage content')
  create_assignment_itemnaire survey_name
  survey = Questionnaire.where(name: survey_name)

  instructor = User.where(name: 'instructor6').first
  assignment = Assignment.where(instructor_id: instructor.id).first
  visit '/survey_deployment/new?id=' + assignment.id.to_s + '&type=AssignmentSurveyDeployment'
  expect(page).to have_content('New Survey Deployment')
  fill_in 'survey_deployment_start_date', with: start_date
  fill_in 'survey_deployment_end_date', with: end_date
  select survey.name, from: 'survey_deployment_itemnaire_id'
  find('input[name="commit"]').click
end

describe 'Survey itemnaire tests for instructor interface' do
  before(:each) do
    assignment_setup
    @previous_day = (Time.now.getlocal - 1 * 86_400).strftime('%Y-%m-%d %H:%M:%S')
    @next_day = (Time.now.getlocal + 1 * 86_400).strftime('%Y-%m-%d %H:%M:%S')
    @next_to_next_day = (Time.now.getlocal + 2 * 86_400).strftime('%Y-%m-%d %H:%M:%S')
  end

  it 'is able to create a survey' do
    login_as('instructor6')
    survey_name = 'Survey Questionnaire 1'
    create_assignment_itemnaire survey_name
    expect(Questionnaire.where(name: survey_name)).to exist
  end

  it 'is able to deploy a survey with valid dates' do
    survey_name = 'Survey Questionnaire 1'

    # passing current time + 1 day for start date and current time + 2 days for end date
    deploy_survey(@next_day, @next_to_next_day, survey_name)
    expect(page).to have_content(survey_name)
  end

  it 'is not able to deploy a survey with invalid dates' do
    survey_name = 'Survey Questionnaire 1'
    # passing current time - 1 day for start date and current time + 2 days for end date
    deploy_survey(@previous_day, @next_day, survey_name)
    expect(page).to have_content(survey_name)
  end

  it 'is able to view statistics of a survey' do
    survey_name = 'Survey Questionnaire 1'
    deploy_survey(@next_day, @next_to_next_day, survey_name)

    survey_itemnaire_1 = Questionnaire.where(name: survey_name).first

    # adding some items for the deployed survey
    visit '/itemnaires/' + survey_itemnaire_1.id.to_s + '/edit'
    fill_in('item_total_num', with: '1')
    select('Criterion', from: 'item_type')
    click_button 'Add'
    expect(page).to have_content('Remove')

    fill_in 'Edit item content here', with: 'Test item 1'
    click_button 'Save assignment survey itemnaire'
    expect(page).to have_content('All items have been successfully saved!')

    survey_deployment = SurveyDeployment.where(itemnaire_id: survey_itemnaire_1.id).first
    item = Question.find_by_sql('select * from items where itemnaire_id = ' + survey_itemnaire_1.id.to_s +
        " and (type = 'Criterion' OR type = 'Checkbox')")

    visit '/survey_deployment/generate_statistics/' + survey_deployment.id.to_s
    item.each do |q|
      expect(page).to have_content(q.txt)
    end
    expect(page).to have_content('No responses for this item')
  end

  it 'is able to view responses of a survey' do
    survey_name = 'Survey Questionnaire 1'
    deploy_survey(@next_day, @next_to_next_day, survey_name)

    survey_itemnaire_1 = Questionnaire.where(name: survey_name).first
    survey_deployment = SurveyDeployment.where(itemnaire_id: survey_itemnaire_1.id).first

    # after adding a response:
    visit '/survey_deployment/view_responses/' + survey_deployment.id.to_s
    expect(page).to have_content(survey_name)
  end
end
