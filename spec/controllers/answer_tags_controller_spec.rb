describe AnswerTagsController do
  # Set up factory objects for testing
  # These objects simulate database records that are needed for the testing.
  let!(:instructor) { build(:instructor, id: 1) }
  let!(:student) { build(:student, id: 1) }
  let!(:assignment) { create(:assignment, name: 'assignment', directory_path: 'assignment', id: 1) }
  let!(:assignment2) { create(:assignment, name: 'assignment2', directory_path: 'assignment2', id: 2) }
  let!(:questionnaire) { create(:questionnaire, name: 'questionnaire', id: 1) }
  let!(:tag_prompt_deployment) { create(:tag_prompt_deployment, id: 1, assignment_id: 1, questionnaire_id: 1) }
  let!(:tag_prompt_deployment2) { create(:tag_prompt_deployment, id: 2, assignment_id: 2, questionnaire_id: 1) }
  let!(:answer_tag) { create(:answer_tag, id: 1, tag_prompt_deployment_id: 1, user_id: student.id) }

  # Factory objects required for "create_edit" test cases - since creating answer tags and updating answer tags requires pre mapping of answer and tag deployment key constraints
  let!(:student2) { build(:student, id: 2) }
  let!(:assignment3) { create(:assignment, name: 'assignment3', directory_path: 'assignment3', id: 3) }
  let!(:questionnaire1) { create(:questionnaire, name: 'questionnaire1', id: 2) }
  let!(:question1) { create(:question, questionnaire: questionnaire, weight: 2, id: 2, type: 'Criterion') }
  let!(:response_map) { create(:review_response_map, id: 2, reviewed_object_id: 2) }
  let!(:response_record) { create(:response, id: 2, response_map: response_map) }
  let!(:answer) { create(:answer, question: question1, comments: 'test comment', response_id: response_record.id) }
  let!(:tag_prompt) { create(:tag_prompt, id: 3, prompt: '??', desc: 'desc', control_type: 'slider') }
  let!(:tag_deploy) { create(:tag_prompt_deployment, id: 3, tag_prompt: tag_prompt, question_type: 'Criterion') }

  # Tests for checking permissions based on user roles and session status
  # To allow the functionality only if the accessing user is having student privileges
  # params: action
  describe '#action_allowed?' do
    # Verifies that students can perform certain actions
    context 'when user with student privileges accesses the controller' do
      before(:each) do
        controller.request.session[:user] = student
      end

      context 'accessing index action' do
        it 'allows access' do
          controller.params = { id: '1', action: 'index' }
          expect(controller.send(:action_allowed?)).to be true
        end
      end
      
      context 'accessing create_edit action' do
        it 'allows access' do
          controller.params = { id: '1', action: 'create_edit' }
          expect(controller.send(:action_allowed?)).to be true
        end
      end

      context 'accessing destroy action' do
        it 'allow accessed' do
          controller.params = { id: '1', action: 'destroy' }
          expect(controller.send(:action_allowed?)).to be nil
        end
      end
    end

    # Ensures that actions are restricted when the session is undefined
    context 'with undefined session' do
      before(:each) do
        controller.request.session[:user] = nil
      end

      context 'accessing index action' do
        it 'denies access' do
          controller.params = { id: '1', action: 'index' }
          expect(controller.send(:action_allowed?)).to be false
        end
      end
      
      context 'accessing index action' do
        it 'denies access' do
          controller.params = { id: '1', action: 'create_edit' }
          expect(controller.send(:action_allowed?)).to be false
        end
      end

      context 'accessing index action' do
        it 'denies access' do
          controller.params = { id: '1', action: 'destroy' }
          expect(controller.send(:action_allowed?)).to be nil
        end
      end
    end
  end


  # Test index method used to return all tag prompt deployments in JSON format
  describe '#index' do
    context 'tag prompt deployments are requested by user' do
      before(:each) do
        controller.request.session[:user] = student
      end

      context 'and none are available' do
        it 'returns no tag prompts' do
          allow(TagPromptDeployment).to receive(:all).and_return(TagPromptDeployment.none)
          get :index
          output = JSON.parse(response.body)
          expect(output.length).to eql(0)
        end
      end

      context 'and only one is present' do
        it 'returns a list with only one tag prompt' do
          get :index
          output = JSON.parse(response.body)
          expect(output.length).to eql(1)
        end
      end

      context 'and only one tag prompt deployment is present but has no answer tag' do
        it 'returns no tag prompts for that assignment' do
          request_params = { assignment_id: 2 }
          get :index, params: request_params
          output = JSON.parse(response.body)
          expect(output.length).to eql(0)
        end
      end

      context 'and only one answer tag is present for the given user_id' do
        it 'returns a list with one tag prompt' do
          request_params = { user_id: student.id }
          get :index, params: request_params
          output = JSON.parse(response.body)
          expect(output.length).to eql(1)
        end
      end

      context 'and only one answer tag is present for the given assignment_id' do
        it 'returns a list with one tag prompt' do
          request_params = { assignment_id: assignment.id }
          get :index, params: request_params
          output = JSON.parse(response.body)
          expect(output.length).to eql(1)
        end
      end

      context 'and only one answer tag is present fo the given questionnaire_id' do
        it 'returns a list with one tag prompt' do
          request_params = { questionnaire_id: questionnaire.id }
          get :index, params: request_params
          output = JSON.parse(response.body)
          expect(output.length).to eql(1)
        end
      end

      context 'and only one answer tag is present for the given user_id, assignment_id, and questionnaire_id' do
        it 'returns a list with one tag prompt' do
          request_params = { user_id: student.id, assignment_id: assignment.id, questionnaire_id: questionnaire.id }
          get :index, params: request_params
          output = JSON.parse(response.body)
          expect(output.length).to eql(1)
        end
      end

      context 'and no answer tags are present for the given user_id' do
        it 'returns no tag prompts' do
          request_params = { user_id: student2.id }
          get :index, params: request_params
          output = JSON.parse(response.body)
          expect(output.length).to eql(0)
        end
      end

      context 'and no answer tags are present for the given assignment_id' do
        it 'returns no tag prompts' do
          request_params = { assignment_id: assignment3.id }
          get :index, params: request_params
          output = JSON.parse(response.body)
          expect(output.length).to eql(0)
        end
      end

      context 'and no answer tags are present for the given questionnaire_id' do
        it 'returns no tag prompts' do
          request_params = { questionnaire_id: questionnaire1.id }
          get :index, params: request_params
          output = JSON.parse(response.body)
          expect(output.length).to eql(0)
        end
      end

      context 'and no answer tags are present for the given user_id, assignment_id, and questionnaire_id' do
        it 'returns no tag prompts' do
          request_params = { user_id: student2.id, assignment_id: assignment3.id, questionnaire_id: questionnaire.id }
          get :index, params: request_params
          output = JSON.parse(response.body)
          expect(output.length).to eql(0)
        end
      end

      context 'and no answer tags are present for given undefined user_id' do
        it 'returns no tag prompts' do
          request_params = { user_id: 42 }
          get :index, params: request_params
          output = JSON.parse(response.body)
          expect(output.length).to eql(0)
        end
      end

      context 'and no answer tags are present for given undefined assignment_id' do
        it 'returns no tag prompts' do
          request_params = { assignment_id: 42 }
          get :index, params: request_params
          output = JSON.parse(response.body)
          expect(output.length).to eql(0)
        end
      end

      context 'and no answer tags are present for given undefined questionnnaire_id' do
        it 'returns no tag prompts' do
          request_params = { questionnaire_id: 42 }
          get :index, params: request_params
          output = JSON.parse(response.body)
          expect(output.length).to eql(0)
        end
      end

      context 'and user_id is nil' do
        it 'returns no tag prompts' do
          request_params = { user_id: nil }
          get :index, params: request_params
          output = JSON.parse(response.body)
          expect(output.length).to eql(0)
        end
      end

      context 'and questionnaire_id is nil' do
        it 'returns no tag prompts' do
          request_params = { questionnaire_id: nil }
          get :index, params: request_params
          output = JSON.parse(response.body)
          expect(output.length).to eql(0)
        end
      end

      context 'and assignment_id is nil' do
        it 'returns no tag prompts' do
          request_params = { assignment_id: nil }
          get :index, params: request_params
          output = JSON.parse(response.body)
          expect(output.length).to eql(0)
        end
      end
    end
  end


  # To allow creation if not existing and simultaneously updating the new answer tag.
  # params: answer_id (answer id mapping to which tag is being created)
  # params: tag_prompt_deployment_id (tag_prompt id mapping to which tag is being created)
  # params: value (new value to be updated)
  describe '#create_edit' do
    context 'when student tries to create or update the answer tags' do
      before(:each) do
        controller.request.session[:user] = student
      end

      context "when entry doesn't exist" do
        it 'adds entry and adds new value provided as param' do
          request_params = { answer_id: answer.id, tag_prompt_deployment_id: tag_deploy.id, value: '0' }
          post :create_edit, params: request_params
          expect(response).to have_http_status(:ok)
          expect(AnswerTag.find_by(answer_id: answer.id).value).to eql('0')
        end

        it 'adds entry and JSON returns true' do
          request_params = { answer_id: answer.id, tag_prompt_deployment_id: tag_deploy.id, value: '0' }
          post :create_edit, params: request_params
          output = JSON.parse(response.body)
          expect(output).to eql(true)
        end
      end

      context "when the entry already exists" do
        it 'updates the old value by new value provided as param' do
          request_params = { answer_id: answer.id, tag_prompt_deployment_id: tag_deploy.id, value: '0' }
          post :create_edit, params: request_params
          expect(response).to have_http_status(:ok)
          expect(AnswerTag.find_by(answer_id: answer.id).value).to eql('0')

          request_params = { answer_id: answer.id, tag_prompt_deployment_id: tag_deploy.id, value: '1' }
          post :create_edit, params: request_params
          expect(response).to have_http_status(:ok)
          expect(AnswerTag.find_by(answer_id: answer.id).value).to eql('1')
        end

        it 'updates the value and JSON returns true' do
          request_params = { answer_id: answer.id, tag_prompt_deployment_id: tag_deploy.id, value: '0' }
          post :create_edit, params: request_params
          output = JSON.parse(response.body)
          expect(output).to eql(true)
        end

        it 'restricts updating answer tag by student if no mapping is found related to any answer for that tag (foreign key constraint)' do
          request_params = { answer_id: nil, tag_prompt_deployment_id: tag_deploy.id, value: '0' }
          expect do
            post :create_edit, params: request_params
          end.to raise_error(ActiveRecord::RecordInvalid)
        end

        it 'restricts updating answer tag by student if no mapping is found related to any tag_prompt_deployment for that tag (foreign key constraint)' do
          request_params = { answer_id: answer.id, tag_prompt_deployment_id: nil, value: '0' }
          expect do
            post :create_edit, params: request_params
          end.to raise_error(ActiveRecord::RecordInvalid)
        end

        it 'restricts updating answer tag by student if no updated value is provided for the answer tag' do
          request_params = { answer_id: answer.id, tag_prompt_deployment_id: tag_deploy.id, value: nil }
          expect do
            post :create_edit, params: request_params
          end.to raise_error(ActiveRecord::RecordInvalid)
        end
      end
    end
  end
end
