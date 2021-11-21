describe AnswerTagsController do

  #factory objects required for "action_allowed" test cases
  let(:instructor) { build(:instructor, id: 1) }
  let(:student) { build(:student, id: 1) }

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

end
