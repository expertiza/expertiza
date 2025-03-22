describe AnswerTagsController do
  # factory objects required for "action_allowed" test cases
  let(:instructor) { build(:instructor, id: 1) }
  let(:student) { build(:student, id: 1) }
  let!(:assignment) { create(:assignment, name: 'assignment', directory_path: 'assignment', id: 1) }
  let!(:assignment2) { create(:assignment, name: 'assignment2', directory_path: 'assignment2', id: 2) }
  let!(:questionnaire) { create(:questionnaire, id: 1) }
  let!(:tag_prompt_deployment) { create(:tag_prompt_deployment, id: 1, assignment_id: 1, questionnaire_id: 1) }
  let!(:tag_prompt_deployment2) { create(:tag_prompt_deployment, id: 2, assignment_id: 2, questionnaire_id: 1) }
  let!(:answer_tag) { create(:answer_tag, id: 1, tag_prompt_deployment_id: 1, user_id: student.id) }

  # factory objects required for "create_edit" test cases - since creating answer tags and updating answer tags requires pre mapping of answer and tag deployment key constraints
  let(:questionnaire1) { create(:questionnaire, id: 2) }
  let(:question1) { create(:question, questionnaire: questionnaire, weight: 2, id: 2, type: 'Criterion') }
  let(:response_map) { create(:review_response_map, id: 2, reviewed_object_id: 2) }
  let!(:response_record) { create(:response, id: 2, response_map: response_map) }
  let!(:answer) { create(:answer, question: question1, comments: 'test comment', response_id: response_record.id) }
  let(:tag_prompt) { create(:tag_prompt, id: 3, prompt: '??', desc: 'desc', control_type: 'slider') }
  let(:tag_deploy) { create(:tag_prompt_deployment, id: 3, tag_prompt: tag_prompt, question_type: 'Criterion') }
  # To allow the functionality only if the accessing user is having student privileges
  # params: action
  describe '#action_allowed?' do
    context 'when user with student privilege following actions should be allowed' do
      before(:each) do
        controller.request.session[:user] = student
      end

      it 'when action index is accessed' do
        controller.params = { id: '1', action: 'index' }
        expect(controller.send(:action_allowed?)).to be true
      end

      it 'when action create_edit is accessed' do
        controller.params = { id: '1', action: 'create_edit' }
        expect(controller.send(:action_allowed?)).to be true
      end
    end

    context 'when the session is a not defined all the actions are restricted' do
      before(:each) do
        controller.request.session[:user] = nil
      end

      it 'when action index is accessed' do
        controller.params = { id: '1', action: 'index' }
        expect(controller.send(:action_allowed?)).to be false
      end

      it 'when action create_edit is accessed' do
        controller.params = { id: '1', action: 'create_edit' }
        expect(controller.send(:action_allowed?)).to be false
      end
    end

    #new

    # Ensures that a user without a role is denied access to index and create_edit actions
    context 'when a user without a role tries to access restricted actions' do
      let(:guest_user) { build(:student, id: 4, role: nil) }
    
      before(:each) do
        controller.request.session[:user] = guest_user
      end
      
      # Guest user without role should not be allowed to access index
      it 'denies access when a user without a role tries to access index' do
        controller.params = { action: 'index' }
        expect(controller.send(:action_allowed?)).to be false
      end
    
      # Guest user without role should not be allowed to access create_edit
      it 'denies access when a user without a role tries to access create_edit' do
        controller.params = { action: 'create_edit' }
        expect(controller.send(:action_allowed?)).to be false
      end
    end

    # Ensures teaching assistants are denied access to student-only actions
    context 'when a teaching assistant tries to access restricted actions' do
      let(:ta) { build(:teaching_assistant, id: 2) }
    
      before(:each) do
        controller.request.session[:user] = ta
      end
    
      it 'denies access when TA tries to access index' do
        controller.params = { action: 'index' }
        expect(controller.send(:action_allowed?)).to be false
      end
    
      it 'denies access when TA tries to access create_edit' do
        controller.params = { action: 'create_edit' }
        expect(controller.send(:action_allowed?)).to be false
      end
    end
    
    # Ensures unrecognized actions are blocked even if user is valid
    context 'when the action is not recognized by the controller' do
      before(:each) do
        controller.request.session[:user] = student
      end
    
      # Action `destroy` is not supported by action_allowed?
      it 'denies access for unrecognized actions' do
        controller.params = { action: 'destroy' }
        expect(controller.send(:action_allowed?)).to be false
      end
    end

    # Ensures student cannot access unsupported controller actions
    context 'when a student tries to access an unsupported action' do
      before(:each) do
        controller.request.session[:user] = student
      end
    
      # Student tries to access `show`, which isn't supported
      it 'denies access for unsupported action: show' do
        controller.params = { action: 'show' }
        expect(controller.send(:action_allowed?)).to be false
      end
    end

    # Ensures instructor cannot perform restricted actions
    context 'when an instructor tries to access an unsupported action' do
      before(:each) do
        controller.request.session[:user] = instructor
      end
    
      # Instructor tries to access destroy, which is not allowed
      it 'denies access for action: destroy' do
        controller.params = { action: 'destroy' }
        expect(controller.send(:action_allowed?)).to be false
      end
    end

    # Ensures action_allowed? returns false when action param is missing
    context 'when student session is active but no action is given' do
      before(:each) do
        controller.request.session[:user] = student
      end
    
      # No action param — should return false
      it 'denies access if no action param is present' do
        controller.params = {}
        expect(controller.send(:action_allowed?)).to be false
      end
    end
  end

  # Test index method used to return all tag prompt deployments in JSON format
  describe '#index' do
    context 'tag prompt deployments are requested' do
      before(:each) do
        controller.request.session[:user] = student
      end

      it 'when there are no tag prompt deployments' do
        allow(TagPromptDeployment).to receive(:all).and_return(TagPromptDeployment.none)
        get :index
        output = JSON.parse(response.body)
        expect(output.length).to eql(0)
      end

      it 'when there is one answer tag' do
        get :index
        output = JSON.parse(response.body)
        expect(output.length).to eql(1)
      end

      it 'when there is one tag prompt deployment but has no answer tag' do
        request_params = { assignment_id: 2 }
        get :index, params: request_params
        output = JSON.parse(response.body)
        expect(output.length).to eql(0)
      end

      it 'when there is one answer tag for given user_id' do
        request_params = { user_id: student.id }
        get :index, params: request_params
        output = JSON.parse(response.body)
        expect(output.length).to eql(1)
      end

      it 'when there is one answer tag for given assignment_id' do
        request_params = { assignment_id: assignment.id }
        get :index, params: request_params
        output = JSON.parse(response.body)
        expect(output.length).to eql(1)
      end

      it 'when there is one answer tag for given questionnaire_id' do
        request_params = { questionnaire_id: questionnaire.id }
        get :index, params: request_params
        output = JSON.parse(response.body)
        expect(output.length).to eql(1)
      end

      it 'when there are no answer tags for given random user_id' do
        request_params = { user_id: 42 }
        get :index, params: request_params
        output = JSON.parse(response.body)
        expect(output.length).to eql(0)
      end

      it 'when there are no answer tags for given random assignment_id' do
        request_params = { assignment_id: 42 }
        get :index, params: request_params
        output = JSON.parse(response.body)
        expect(output.length).to eql(0)
      end

      it 'when there are no answer tags for given random questionnaire_id' do
        request_params = { questionnaire_id: 42 }
        get :index, params: request_params
        output = JSON.parse(response.body)
        expect(output.length).to eql(0)
      end

      it 'when the user_id is nil' do
        request_params = { user_id: nil }
        get :index, params: request_params
        output = JSON.parse(response.body)
        expect(output.length).to eql(0)
      end

      it 'when the questionnaire_id is nil' do
        request_params = { questionnaire_id: nil }
        get :index, params: request_params
        output = JSON.parse(response.body)
        expect(output.length).to eql(0)
      end

      it 'when the assignment_id is nil' do
        request_params = { assignment_id: nil }
        get :index, params: request_params
        output = JSON.parse(response.body)
        expect(output.length).to eql(0)
      end
    end

  # New
  
  context 'when accessing the endpoint without authentication' do
    before(:each) do
      controller.request.session[:user] = nil
    end

    it 'returns unauthorized (401) when the user is not logged in' do
      get :index
      expect(response).not_to have_http_status(200)
    end
  end

  context 'when the user is an instructor' do
    before(:each) do
      controller.request.session[:user] = instructor
    end

    it 'when there are no tag prompt deployments' do
      allow(TagPromptDeployment).to receive(:all).and_return(TagPromptDeployment.none)
      get :index
      output = JSON.parse(response.body)
      expect(output.length).to eql(0)
    end

    it 'when there is one answer tag' do
      get :index
      output = JSON.parse(response.body)
      expect(output.length).to eql(1)
    end

    it 'when there is one tag prompt deployment but has no answer tag' do
      request_params = { assignment_id: 2 }
      get :index, params: request_params
      output = JSON.parse(response.body)
      expect(output.length).to eql(0)
    end

    it 'when there is one answer tag for given user_id' do
      request_params = { user_id: student.id }
      get :index, params: request_params
      output = JSON.parse(response.body)
      expect(output.length).to eql(1)
    end

    it 'when there is one answer tag for given assignment_id' do
      request_params = { assignment_id: assignment.id }
      get :index, params: request_params
      output = JSON.parse(response.body)
      expect(output.length).to eql(1)
    end

    it 'when there is one answer tag for given questionnaire_id' do
      request_params = { questionnaire_id: questionnaire.id }
      get :index, params: request_params
      output = JSON.parse(response.body)
      expect(output.length).to eql(1)
    end

    it 'when there are no answer tags for given random user_id' do
      request_params = { user_id: 42 }
      get :index, params: request_params
      output = JSON.parse(response.body)
      expect(output.length).to eql(0)
    end

    it 'when there are no answer tags for given random assignment_id' do
      request_params = { assignment_id: 42 }
      get :index, params: request_params
      output = JSON.parse(response.body)
      expect(output.length).to eql(0)
    end

    it 'when there are no answer tags for given random questionnaire_id' do
      request_params = { questionnaire_id: 42 }
      get :index, params: request_params
      output = JSON.parse(response.body)
      expect(output.length).to eql(0)
    end

    it 'when the user_id is nil' do
      request_params = { user_id: nil }
      get :index, params: request_params
      output = JSON.parse(response.body)
      expect(output.length).to eql(0)
    end

    it 'when the questionnaire_id is nil' do
      request_params = { questionnaire_id: nil }
      get :index, params: request_params
      output = JSON.parse(response.body)
      expect(output.length).to eql(0)
    end

    it 'when the assignment_id is nil' do
      request_params = { assignment_id: nil }
      get :index, params: request_params
      output = JSON.parse(response.body)
      expect(output.length).to eql(0)
    end
  end

  context 'when an invalid parameter is passed' do
    before(:each) do
      controller.request.session[:user] = student
    end

    it 'ignores extra unexpected parameters and returns valid results' do
      request_params = { invalid_param: 'xyz' }
      get :index, params: request_params
      output = JSON.parse(response.body)
      expect(output.length).to eql(1)
    end
  end

  context 'when there are multiple answer tags for the assignment' do
    let!(:extra_answer_tag) { create(:answer_tag, id: 2, tag_prompt_deployment_id: 1, user_id: student.id) }

    before(:each) do
      controller.request.session[:user] = student
    end

    it 'returns all answer tags associated with the assignment' do
      request_params = { assignment_id: assignment.id }
      get :index, params: request_params
      output = JSON.parse(response.body)
      expect(output.length).to eql(2)
    end
  end

  context 'when answer tags exist for multiple users' do
    let!(:new_student) { create(:student, id: 3) }
    let!(:extra_answer_tag) { create(:answer_tag, id: 3, tag_prompt_deployment_id: 1, user_id: new_student.id) }

    before(:each) do
      controller.request.session[:user] = student
    end

    it 'returns only the answer tags for the specified user' do
      request_params = { user_id: student.id }
      get :index, params: request_params
      output = JSON.parse(response.body)
      expect(output.length).to eql(1)
    end
  end

  context 'when user_id parameter is invalid' do
    it 'returns a 400 Bad Request error for an invalid user_id' do
      request_params = { user_id: 'invalid' }
      get :index, params: request_params
      expect(response).to have_http_status(:bad_request)
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

      it 'add entry if not existing and update the old value by new value provided as param' do
        request_params = { answer_id: answer.id, tag_prompt_deployment_id: tag_deploy.id, value: '0' }
        post :create_edit, params: request_params
        expect(response).to have_http_status(200)
        expect(AnswerTag.find_by(answer_id: answer.id).value).to eql('0')
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

    #new

    # Ensures user_id param is ignored and current_user is used for tag creation
    it 'ignores passed user_id param and uses current_user' do
      controller.request.session[:user] = student  
    
      request_params = {
        user_id: 42, # random other user
        answer_id: answer.id,
        tag_prompt_deployment_id: tag_deploy.id,
        value: '1'
      }
    
      post :create_edit, params: request_params
    
      created_tag = AnswerTag.find_by(answer_id: answer.id, tag_prompt_deployment_id: tag_deploy.id)
      expect(created_tag.user_id).to eq(student.id)
    end
    
    # Raises error if tag_prompt_deployment_id is invalid (not an integer)
    it 'raises error if tag_prompt_deployment_id is a string' do
      request_params = {
        answer_id: answer.id,
        tag_prompt_deployment_id: 'not_an_id',
        value: '1'
      }
    
      expect {
        post :create_edit, params: request_params
      }.to raise_error(ActiveRecord::RecordInvalid)
    end

    let(:other_student) { create(:student) }

    # Allows tagging an answer not written by the current_user (based on current logic)
    it 'allows tagging an answer not written by current_user' do
      controller.request.session[:user] = student  
    
      request_params = {
        answer_id: answer.id,
        tag_prompt_deployment_id: tag_deploy.id,
        value: '2'
      }
    
      post :create_edit, params: request_params
      tag = AnswerTag.find_by(answer_id: answer.id, tag_prompt_deployment_id: tag_deploy.id, user_id: student.id)
      expect(tag.user_id).to eq(student.id)
    end
    
    # Ensures an error is raised when no parameters are passed
    it 'raises error when no parameters are passed' do
      expect {
        post :create_edit, params: {}
      }.to raise_error(ActiveRecord::RecordInvalid)
    end

    # Verifies that duplicate tags are not created for the same user, answer, and deployment
    it 'does not create duplicate AnswerTags on repeated calls' do
      controller.request.session[:user] = student  
    
      request_params = {
        answer_id: answer.id,
        tag_prompt_deployment_id: tag_deploy.id,
        value: '1'
      }
    
      post :create_edit, params: request_params
      post :create_edit, params: request_params
    
      tags = AnswerTag.where(answer_id: answer.id, tag_prompt_deployment_id: tag_deploy.id, user_id: student.id)
      expect(tags.count).to eq(1)
    end
    
    # Ensures the tag value gets updated if an existing tag is found
    it 'updates the value when the tag already exists with a different value' do
      controller.request.session[:user] = student
    
      tag = AnswerTag.create!(
        user_id: student.id,
        answer_id: answer.id,
        tag_prompt_deployment_id: tag_deploy.id,
        value: 'old_value'
      )
    
      request_params = {
        answer_id: answer.id,
        tag_prompt_deployment_id: tag_deploy.id,
        value: 'new_value'
      }
    
      post :create_edit, params: request_params
    
      updated_tag = AnswerTag.find_by(
        user_id: student.id,
        answer_id: answer.id,
        tag_prompt_deployment_id: tag_deploy.id
      )
    
      expect(updated_tag.value).to eq('new_value')
    end

    # Confirms a new tag is created if no previous tag exists for this combination
    it 'creates a new tag if one does not exist for this student, answer, and deployment' do
      controller.request.session[:user] = student
    
      # Ensure no pre-existing tag for this combination
      AnswerTag.where(
        user_id: student.id,
        answer_id: answer.id,
        tag_prompt_deployment_id: tag_deploy.id
      ).destroy_all
    
      request_params = {
        answer_id: answer.id,
        tag_prompt_deployment_id: tag_deploy.id,
        value: '3'
      }
    
      expect {
        post :create_edit, params: request_params
      }.to change {
        AnswerTag.where(
          user_id: student.id,
          answer_id: answer.id,
          tag_prompt_deployment_id: tag_deploy.id
        ).count
      }.from(0).to(1)
    end
  end
end
