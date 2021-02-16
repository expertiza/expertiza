describe SurveyDeploymentController do
	let(:instructor) { build(:instructor, id: 6) }
	let(:student) { build(:student, id: 1) }
	let(:questionnaire1) { build(:questionnaire, id: 1, questions: [question] , type: 'AssignmentSurveyDeployment')}
  let(:question) { Criterion.new(id: 1, weight: 2, break_before: true) }
  let(:assignment) {build(:assignment, id: 1, name: "test_assignment")}
  let(:course) { build(:course, id: 1) }
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
			expect(controller.send(:survey_deployment_type)).to eq controller.params[:type].constantize
		end
	end
	context 'when the assignment is an Course Survey Deployment' do
		it 'a constantized CourseSurveyDeployment is returned' do
			controller.params[:type] = 'CourseSurveyDeployment'
			expect(controller.send(:survey_deployment_type)).to eq controller.params[:type].constantize
		end
	end
	context 'when the assignment is an invalid Survey Deployment' do
		it 'returns nil' do
			controller.params[:type] = 'InvalidSurveyDeployment'
			expect(controller.send(:survey_deployment_type)).to be nil
		end
	end
end

describe '#new' do
	context 'when you try to make an invalid survey' do
		it 'generates an error' do
			controller.params[:type] = 'InvalidSurveyDeployment'
			get :new, controller.params
			expect(flash[:error]).to be_present
		end
	end
	context 'when you try to create an Assignment Survey Deployment' do
		it 'creates an assignment survey deployment' do
			allow(Assignment).to receive(:find).with('1').and_return(assignment)
			controller.params[:type] = 'AssignmentSurveyDeployment'
			controller.params[:id] = 1
    	session = {user: instructor}
			get :new, controller.params, session
			expect(response).to render_template(:new)
		end
	end
	context 'when you try to create an Course Survey Deployment' do
		it 'creates an course survey deployment' do
			allow(Course).to receive(:find).with('1').and_return(course)
			controller.params[:type] = 'CourseSurveyDeployment'
			controller.params[:id] = 1
    	session = {user: instructor}
			get :new, controller.params, session
			expect(response).to render_template(:new)
		end
	end
end

describe '#param_test' do
	context 'params is nil' do
		it 'returns an error' do
			controller.params = {}
			get :param_test, controller.params
			expect(response).to raise_error(ActionController::ParameterMissing)
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