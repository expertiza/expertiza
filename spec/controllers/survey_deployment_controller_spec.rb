describe SurveyDeploymentController do
	let(:instructor) { build(:instructor, id: 6) }
	let(:student) { build(:student, id: 1) }
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
			expect(controller.send(:survey_deployment_types)).size. to be 2
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