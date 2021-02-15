describe SurveyDeploymentController do
	let(:instructor) { build(:instructor, id: 6) }
	let(:student) { build(:student, id: 1) }
	let(:questionnaire) { build(:questionnaire, id: 1, questions: [question] , type: 'AssignmentSurveyDeployment')}
  let(:question) { Criterion.new(id: 1, weight: 2, break_before: true) }
	describe '#action_allowed?' do
		context 'when the user is a instructor' do
			it 'returns true' do
				session[:user] = instructor
				expect(controller.send(:action_allowed?)).to be true
			end
		end
		context 'when a user is a student' do
			it 'returns false' do
				session[:user] = student
				expect(controller.send(:action_allowed?)).to be false
			end
		end
	end

describe '#survey_deployment_types' do
	context 'when the function is called' do
		it 'returns the types of survey deployments' do
			expect(controller.send(:survey_deployment_types)).to eq %w[AssignmentSurveyDeployment
       CourseSurveyDeployment]
		end
	end
end

describe '#survey_deployment_type' do
	context 'when the assignment is an Assignment Survey Deployment' do
		it 'a constantized AssignmentSurveyDeployment is returned' do
			controller.params[:type] = 'AssignmentSurveyDeployment'
			expect(controller.send(:survey_deployment_type)).to eq AssignmentSurveyDeployment(id: integer, 
				questionnaire_id: integer, start_date: datetime, end_date: datetime, last_reminder: datetime,
				 parent_id: integer, global_survey_id: integer, type: string) 
		end
	end
end


	describe '#pending_surveys' do
		context 'when session[:user] is invalid' do
			it 'redirects to root' do
				get :pending_surveys, @params
				expect(response).to redirect_to('/')
			end
		end
	end
end