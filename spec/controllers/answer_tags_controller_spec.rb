describe AnswerTagsController do

  #factory objects required for "action_allowed" test cases
  let(:instructor) { build(:instructor, id: 1) }
  let(:student) { build(:student, id: 1) }
  let!(:assignment) { create(:assignment, id: 1) }
  let!(:assignment2) { create(:assignment, id: 2) }
  let!(:questionnaire) { create(:questionnaire, id: 1) }
  let!(:tag_prompt_deployment) { create(:tag_prompt_deployment, id: 1, assignment_id: 1, questionnaire_id: 1) }
  let!(:tag_prompt_deployment2) { create(:tag_prompt_deployment, id: 2, assignment_id: 2, questionnaire_id: 1) }
  let!(:answer_tag) { create(:answer_tag, id: 1, tag_prompt_deployment_id: 1, user_id: student.id) }

  #To allow the functionality only if the accessing user is having student privileges
  #params: action
  describe '#action_allowed?' do

    context 'when user with student privilege following actions should be allowed' do
      before(:each) do
        controller.request.session[:user] = student
      end

      it 'when action index is accessed' do
        controller.params = {id: '1', action: 'index'}
        expect(controller.send(:action_allowed?)).to be true
      end

      it 'when action create_edit is accessed' do
        controller.params = {id: '1', action: 'create_edit'}
        expect(controller.send(:action_allowed?)).to be true
      end
    end

    context 'when the session is a not defined all the actions are restricted' do
      before(:each) do
        controller.request.session[:user] = nil
      end

      it 'when action index is accessed' do
        controller.params = {id: '1', action: 'index'}
        expect(controller.send(:action_allowed?)).to be false
      end

      it 'when action create_edit is accessed' do
        controller.params = {id: '1', action: 'create_edit'}
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
        params = {assignment_id: 2}
        get :index, params
        output = JSON.parse(response.body)
        expect(output.length).to eql(0)
      end

      it 'when there is one answer tag for given user_id' do
        params = {user_id: student.id}
        get :index, params
        output = JSON.parse(response.body)
        expect(output.length).to eql(1)
      end

      it 'when there is one answer tag for given assignment_id' do
        params = {assignment_id: assignment.id}
        get :index, params
        output = JSON.parse(response.body)
        expect(output.length).to eql(1)
      end

      it 'when there is one answer tag for given questionnaire_id' do
        params = {questionnaire_id: questionnaire.id}
        get :index, params
        output = JSON.parse(response.body)
        expect(output.length).to eql(1)
      end
      
      it 'when there are no answer tags for given random user_id' do
        params = {user_id: 42}
        get :index, params
        output = JSON.parse(response.body)
        expect(output.length).to eql(0)
      end

      it 'when there are no answer tags for given random assignment_id' do
        params = {assignment_id: 42}
        get :index, params
        output = JSON.parse(response.body)
        expect(output.length).to eql(0)
      end

      it 'when there are no answer tags for given random questionnaire_id' do
        params = {questionnaire_id: 42}
        get :index, params
        output = JSON.parse(response.body)
        expect(output.length).to eql(0)
      end
    end
  end
end
