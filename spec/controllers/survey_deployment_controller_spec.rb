describe SurveyDeploymentController do
	let(:instructor) { build(:instructor, id: 6) }
	let(:admin) { build(:admin, id: 7) }
	let(:student) { build(:student, id: 1) }
	let(:questionnaire1) { 
		build(:questionnaire, 
			id: 1, 
			questions: [question], 
			type: 'AssignmentSurveyDeployment',
			min_question_score: 75,
			max_question_score: 95
			)}
  let(:question) { Criterion.new(id: 1, weight: 2, break_before: true) }
  let(:assignment) {build(:assignment, id: 1, name: "test_assignment")}
  let(:course) { build(:course, id: 1) }
  let(:survey_deployment) { build(:survey_deployment)}
  let(:review_response_map) { build(:review_response_map)}
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
			it 'remains unpermitted' do
				controller.params = ActionController::Parameters.new(survey_deployment: nil)
				get :param_test, controller.params
				expect(controller.params.permitted?).to be false
			end
		end
		context 'params is valid' do
			it 'is now permitted' do
				controller.params = ActionController::Parameters.new(
					survey_deployment: {
						questionnaire_id: 1, 
						start_date: DateTime.now, 
						end_date: DateTime.now.new_offset('+09:00'), 
						parent_id: 1
					}
				)
				val = controller.param_test
				expect(val.permitted?).to be true
			end
		end
	end

	describe '#create' do
		context 'creating an assignment survey deployment' do
			it 'increments count of survey deployment by one' do
				allow(Assignment).to receive(:find).with('1').and_return(assignment)
				expect_any_instance_of(SurveyDeployment).to receive(:save).and_return(true) 
				params = ActionController::Parameters.new(
					type: "AssignmentSurveyDeployment",
					survey_deployment: {
						questionnaire_id: 1, 
						start_date: DateTime.now, 
						end_date: DateTime.now.new_offset('+09:00'), 
						type: "AssignmentSurveyDeployment",
						parent_id: 1
					}
				)
				session = {user: instructor}
				post :create, params, session 
				expect(response).to redirect_to('/survey_deployment/list')
			end
		end 
		context 'creating an survey deployment with missing parameters' do
			it 'redirects to the tree display and flashes an error' do
				allow(Assignment).to receive(:find).with('1').and_return(assignment)
				params = ActionController::Parameters.new(
					type: "AssignmentSurveyDeployment",
					survey_deployment: {
						type: "AssignmentSurveyDeployment",
					}
				)
				session = {user: instructor}
				post :create, params, session 
				expect(response).to redirect_to('/tree_display/list')
				expect(flash[:error]).to be_present
			end
		end
	end

	describe '#list' do
		context 'when a student tries to access list of survey deployments' do
			it 'they are redirected to root' do
				session = {user: student}
				get :list, session
				expect(response).to redirect_to('/')
				expect(flash[:error]).to be_present
			end
		end
		context 'when an instructor tries to access list of survey deployments' do 
			it 'successfully responds' do
				allow(SurveyDeployment).to receive(:all).and_return([])
				allow(Questionnaire).to receive(:find).with(1).and_return(questionnaire1)
				allow_any_instance_of(SurveyDeployment).to receive(:questionnaire_id).and_return(1)
				stub_current_user(instructor, instructor.role.name, instructor.role)
				session = {user: instructor}
				get :list, session
				expect(response).to have_http_status(200)
			end
		end
	end

	describe '#delete' do 
		context 'when someone tries to delete a SurveyDeployment' do
			it 'redirects them to list and removes the SurveyDeployment from the database' do
				allow(SurveyDeployment).to receive(:find).with('1').and_return(survey_deployment)
				allow(survey_deployment).to receive(:destroy).and_return(true)
				allow(survey_deployment).to receive(:response_maps).and_return([review_response_map])
				params = {id: 1}
      	session = {user: instructor}
      	post :delete, params, session
      	expect(response).to redirect_to('/survey_deployment/list')
			end
		end
	end

	describe '#generate_statistics' do
		context 'when generate_statistics is called' do
			it 'assigns range of scores' do
				allow(SurveyDeployment).to receive(:find).with('1').and_return(survey_deployment)
				params = {global_survey: false, id: 1}
				allow(survey_deployment).to receive(:questionnaire_id).and_return('1')
				allow(Questionnaire).to receive(:find).with('1').and_return(questionnaire1)
				stub_current_user(instructor, instructor.role.name, instructor.role)
				session = {user: instructor}
				get :generate_statistics, params, session
				expect(assigns(:sd)).to eq(survey_deployment)
				expect(assigns(:range_of_scores)).to eq((75..95).to_a)
			end
		end
	end

	describe '#view_responses' do
		context 'when the responses of a survey deployment is called' do
			it 'it returns the question associated' do
				params = {global_survey: false, id: 1}
				allow(SurveyDeployment).to receive(:find_by).with(parent_id: '1').and_return(survey_deployment)
				allow(survey_deployment).to receive(:questionnaire_id).and_return('1')
				allow(survey_deployment).to receive(:id).and_return('1')
				allow(Questionnaire).to receive(:find).with('1').and_return(questionnaire1)
				allow(Question).to receive(:where).with(questionnaire_id: questionnaire1.id).and_return([question])
				allow(ResponseMap).to receive(:where).with(reviewee_id: '1').and_return([review_response_map])
				stub_current_user(instructor, instructor.role.name, instructor.role)
				session = {user: instructor}
				get :view_responses, params, session
				expect(assigns(:questionnaire)).to eq(questionnaire1)
				expect(assigns(:questions)).to eq([question])
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