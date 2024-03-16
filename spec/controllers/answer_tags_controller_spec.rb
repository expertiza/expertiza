# TODO: Determine which skeleton tests have already been implemented.

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
    context 'when user with student privilege, actions index and create_edit should be allowed' do
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

      it 'when action destroy is accessed' do
        controller.params = { id: '1', action: 'destroy' }
        # TODO: Why is this returning nil and not false?
        expect(controller.send(:action_allowed?)).to be nil
      end
    end

    context 'when the session is not defined, all the actions are restricted' do
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

      it 'when action destroy is accessed' do
        controller.params = { id: '1', action: 'destroy' }
        # TODO: Why is this returning nil and not false?
        expect(controller.send(:action_allowed?)).to be nil
      end
    end
  end


  # Test skeletons provided by Vyshnavi Adusumelli
  # describe "action_allowed?" do


  #   context "when action is 'index'" do
  #     it "returns true if current user has student privileges" do
  #       # Test scenario 1
  #       # 'when action index is accessed' under 'when user with student privilege...'
  #     end
  #   end

  #   context "when action is 'create_edit'" do
  #     it "returns true if current user has student privileges" do
  #       # Test scenario 2
  #       # 'when action create_edit is accessed' from 'when user with student privilege...'
  #     end
  #   end

  #   context "when action is not 'index' or 'create_edit' (i.e. 'destroy')" do
  #     it "returns false" do
  #       # Test scenario 3
  #       # Implemented above
  #     end
  #   end
  # end


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
      
      it 'when there are no answer tag for given random user_id, assignment_id, questionnaire_id' do
        request_params = { user_id: 42, assignment_id: 42, questionnaire_id: 42 }
        get :index, params: request_params
        output = JSON.parse(response.body)
        expect(output.length).to eql(0)
      end
      
      it "when assignment_id and questionnaire_id are not provided" do
        request_params = { user_id: 42, assignment_id: nil, questionnaire_id: nil }
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
  end


  # Test skeletons provided by Vyshnavi Adusumelli
  describe "index" do
    context "when assignment_id and questionnaire_id are not provided" do
      it "returns all tag prompts" do
        #request_params = { user_id: 42, assignment_id: nil, questionnaire_id: nil }
        #get :index, params: request_params
        #output = JSON.parse(response.body)
        #expect(output.length).to eql(0)
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
  end


  # Test skeletons provided by Vyshnavi Adusumelli
  describe "create_edit" do
    context "when the AnswerTag does not exist" do
      it "creates a new AnswerTag with the given parameters" do
        # Test body
      end

      it "returns the created AnswerTag as JSON" do
        # Test body
      end
    end

    context "when the AnswerTag already exists" do
      it "updates the value of the existing AnswerTag with the given parameters" do
        # Test body
      end

      it "returns the updated AnswerTag as JSON" do
        # Test body
      end
    end
  end

  # Test skeletons provided by Vyshnavi Adusumelli
  describe "#destroy" do
    context "when called on an object" do
      it "should delete the object from the database" do
        # Test body
      end
      it "should return true if the object is successfully deleted" do
        # Test body
      end
      it "should return false if the object does not exist in the database" do
        # Test body
      end
    end

    context "when called without an object" do
      it "should raise an error" do
        # Test body
      end
    end
  end
end
