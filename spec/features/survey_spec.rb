require 'rails_helper'
include InstructorInterfaceHelperSpec

def create_assignment_questionnaire survey_name
    visit '/questionnaires/new?model=Assignment+SurveyQuestionnaire&private=0'
    fill_in 'questionnaire_name', with: survey_name
    find('input[name="commit"]').click
end

def deploy_survey(start_date, end_date, survey_name)
    login_as('instructor6')
    expect(page).to have_content('Manage content')
    create_assignment_questionnaire survey_name
    survey = Questionnaire.where(name = survey_name)
    
    instructor = User.where(name: 'instructor6').first
    assignment = Assignment.where(instructor_id: instructor.id).first
    visit '/survey_deployment/new?id=' + assignment.id.to_s + '&type=AssignmentSurveyDeployment'
    expect(page).to have_content('New Survey Deployment')
    fill_in 'survey_deployment_start_date', with: start_date
    fill_in 'survey_deployment_end_date', with: end_date
    select survey.name, :from => "survey_deployment_questionnaire_id"
    find('input[name="commit"]').click
end

describe "Survey questionnaire tests for instructor interface" do
    
    before(:each) do
        assignment_setup
    end
    
    it "is able to create a survey" do
        login_as('instructor6')
        survey_name = "Survey Questionnaire 1"
        create_assignment_questionnaire survey_name
        expect(Questionnaire.where(name: survey_name)).to exist
    end
    
    it "is able to deploy a survey with valid dates" do
        survey_name = 'Survey Questionnaire 1'
        
        # passing current time + 1 day for start date and current time + 2 days for end date
        deploy_survey((Time.now + 1 * 86400).strftime("%Y-%m-%d %H:%M:%S"), (Time.now + 2 * 86400).strftime("%Y-%m-%d %H:%M:%S"), survey_name)
        expect(page).to have_content(survey_name)
    end
    
    it "is not able to deploy a survey with invalid dates" do
        survey_name = 'Survey Questionnaire 1'
        # passing current time - 1 day for start date and current time + 2 days for end date
        deploy_survey((Time.now - 1 * 86400).strftime("%Y-%m-%d %H:%M:%S"), (Time.now + 2 * 86400).strftime("%Y-%m-%d %H:%M:%S"), survey_name)
        expect(page).to have_content('Dates should be in the future')
    end
    
    it "is able to view statistics of a survey" do
        survey_name = 'Survey Questionnaire 1'
        deploy_survey((Time.now + 1 * 86400).strftime("%Y-%m-%d %H:%M:%S"), (Time.now + 2 * 86400).strftime("%Y-%m-%d %H:%M:%S"), survey_name)
        
        survey_questionnaire_1 = Questionnaire.where(name: survey_name).first
        
        #adding some questions for the deployed survey
        visit '/questionnaires/' + survey_questionnaire_1.id.to_s + '/edit'
        fill_in('question_total_num', with: '1')
        select('Criterion', from: 'question_type')
        click_button "Add"
        expect(page).to have_content('Remove')
        
        fill_in "Edit question content here", with: "Test question 1"
        click_button "Save assignment survey questionnaire"
        expect(page).to have_content('All questions has been successfully saved!')
        
        survey_deployment = SurveyDeployment.where(questionnaire_id: survey_questionnaire_1.id).first
        question = Question.find_by_sql("select * from questions where questionnaire_id = " + survey_questionnaire_1.id.to_s + " and (type = 'Criterion' OR type = 'Checkbox')")
        
        visit '/survey_deployment/generate_statistics/' + survey_deployment.id.to_s
        question.each do |q|
            expect(page).to have_content(q.txt)
        end
        expect(page).to have_content("No responses for this question")
    end

    it "is able to view responses of a survey" do
        survey_name = 'Survey Questionnaire 1'
        deploy_survey((Time.now + 1 * 86400).strftime("%Y-%m-%d %H:%M:%S"), (Time.now + 2 * 86400).strftime("%Y-%m-%d %H:%M:%S"), survey_name)
        
        survey_questionnaire_1 = Questionnaire.where(name: survey_name).first
        survey_deployment = SurveyDeployment.where(questionnaire_id: survey_questionnaire_1.id).first
        
        #before adding any responses:
        visit '/response/view_responses/' + survey_deployment.id.to_s
        expect(page).to have_content('No one has responded to the survey')
        
        #add a response for the survey_deployment: survey_deployment.id		
        @response = create(:response)			
        response_map = ResponseMap.find(@response.map_id)
        response_map.reviewee_id = survey_deployment.id
        
        #after adding a response:
        visit '/response/view_responses/' + survey_deployment.id.to_s
        expect(page).to have_content(survey_name)
    end
end
