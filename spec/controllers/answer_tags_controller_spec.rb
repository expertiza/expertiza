describe AnswerTagsController do

  #factory objects required for "action_allowed" test cases
  let(:instructor) { build(:instructor, id: 1) }
  let(:student) { build(:student, id: 1) }
  let(:assignment) { build(:assignment, id: 1) }
  let(:questionnaire) { build(:questionnaire, id: 1) }
  let(:tag_prompt_deployment) { build(:tag_prompt_deployment, id: 1, assignment: assignment, questionnaire: questionnaire) }
  let(:answer_tag) { build(:answer_tag, id: 1, tag_prompt_deployment: tag_prompt_deployment, user: student) }

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
    context 'all tag prompt deployments are requested' do
      before(:each) do
        controller.request.session[:user] = student
      end

      it 'when there are no tag prompt deployments' do
        allow(TagPromptDeployment).to receive(:all).and_return([])
        get :index
        output = JSON.parse(response.body)
        puts output
        expect(output.length).to eql(0)
      end

      it 'when there is one tag prompt deployment' do
        allow(TagPromptDeployment).to receive(:all).and_return([tag_prompt_deployment])
        get :index
        output = JSON.parse(response.body)
        expect(output.length).to eql(1)
      end

      it 'when there is one tag prompt deployment for given user_id' do
        allow(TagPromptDeployment).to receive(:all).and_return([tag_prompt_deployment])
        params = {user_id: student.id}
        get :index, params
        output = JSON.parse(response.body)
        expect(output.length).to eql(1)
      end

      it 'when there is one tag prompt deployment for given assignment_id' do
        allow(TagPromptDeployment).to receive(:all).and_return([tag_prompt_deployment])
        params = {assignment_id: assignment.id}
        get :index, params
        output = JSON.parse(response.body)
        expect(output.length).to eql(1)
      end

      it 'when there is one tag prompt deployment for given questionnaire_id' do
        allow(TagPromptDeployment).to receive(:all).and_return([tag_prompt_deployment])
        params = {questionnaire_id: questionnaire.id}
        get :index, params
        output = JSON.parse(response.body)
        expect(output.length).to eql(1)
      end
      
      it 'when there is one tag prompt deployment for given random user_id' do
        allow(TagPromptDeployment).to receive(:all).and_return([tag_prompt_deployment])
        params = {user_id: 42}
        get :index, params
        output = JSON.parse(response.body)
        expect(output.length).to eql(1)
      end

      it 'when there is one tag prompt deployment for given random assignment_id' do
        allow(TagPromptDeployment).to receive(:all).and_return([tag_prompt_deployment])
        params = {assignment_id: 42}
        get :index, params
        output = JSON.parse(response.body)
        expect(output.length).to eql(1)
      end

      it 'when there is one tag prompt deployment for given random questionnaire_id' do
        allow(TagPromptDeployment).to receive(:all).and_return([tag_prompt_deployment])
        params = {questionnaire_id: 42}
        get :index, params
        output = JSON.parse(response.body)
        expect(output.length).to eql(1)
      end
    end
  end
end
