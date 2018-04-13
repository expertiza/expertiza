describe UsersController do
  # RSpec::Mocks.configuration.allow_message_expectations_on_nil=true
  let(:admin) { build(:admin) }
  let(:instructor) { build(:instructor) }
  # let(:instructor2) { build(:instructor, id: 66) }
  # let(:ta) { build(:teaching_assistant, id: 8) }
  let(:student1) { build(:student, id: 1, name: :lily) }
  let(:student2) { build(:student) }
  before(:each) do
    stub_current_user(instructor, instructor.role.name, instructor.role)
  end

  describe '#edit' do
    it 'renders users#edit page' do
      allow(User).to receive(:find).with('1').and_return(student1)
      @params = {id: 1}
      session = {user: instructor}
      get :edit, @params,session
      expect(response).to render_template(:edit)
    end
  end

  describe '#update' do
    context 'when user is updated successfully' do
      it 'shows correct flash and redirects to users#show page' do
        allow(User).to receive(:find).with('1').and_return(student1)
        @params = {id: 1}
        allow(student1).to receive(:update_attributes).with(any_args).and_return(true)
        post :update, @params
        expect(flash[:success]).to eq 'The user "lily" has been successfully updated.'
        expect(response).to redirect_to('/users')
      end
    end
    context 'when user is not updated successfully' do
      it 'redirects to users#edit page' do
        allow(User).to receive(:find).with('2').and_return(student2)
        @params = {id: 2}
        allow(student2).to receive(:update_attributes).with(any_args).and_return(false)
        post :update, @params
        expect(response).to render_template(:edit)
      end
    end
  end

  describe '#destroy' do
    # context 'when user is deleted successfully' do
    #   it 'shows correct flash and redirects to users/list page' do
    #     assignment_participant = [double('AssignmentParticipant', user_id: 1)]
    #     teams_user = [double('TeamsUser', user_id: 1)]
    #     assignment_questionnaire = [double('AssignmentQuestionnaire', user_id: 1)]
    #
    #     allow(assignment_participant).to receive(:delete).and_return(true)
    #     allow(teams_user).to receive(:delete).and_return(true)
    #     allow(assignment_questionnaire).to receive(:destroy).and_return(true)
    #
    #     allow(assignment_participant).to receive(:each).and_return(true)
    #     allow(teams_user).to receive(:each).and_return(true)
    #     allow(assignment_questionnaire).to receive(:each).and_return(true)
    #
    #     allow(student1).to receive(:destroy).and_return(true)
    #     allow(User).to receive(:find).with('1').and_return(student1)
    #     @params = {id: 1}
    #     get :destroy, @params
    #     expect(flash[:note]).to match(/'The user "lily" has been successfully updated.*/)
    #     expect(response).to redirect_to('/users/list')
    #   end
    # end
    context 'when user is not deleted successfully' do
      it 'shows an error and redirects to users/list page' do
        allow(User).to receive(:find).with('2').and_return(student2)
        @params = {id: 2}
        get :destroy, @params
        expect(flash[:error]).not_to be_nil
        expect(response).to redirect_to('/users/list')
      end
    end
  end

  describe '#keys' do
    before(:each) do
      stub_current_user(student1, student1.role.name, student1.role)
    end
    context 'when params[:id] is not nil' do
      it '@private_key gets correct value' do
        the_key="the key"
        allow(User).to receive(:find).with('1').and_return(student1)
        allow(student1).to receive(:generate_keys).and_return(the_key)
        @params = {id: 1}
        get :keys, @params
        expect(controller.instance_variable_get(:@private_key)).to be(the_key)
      end
    end
    context 'when params[:id] is nil' do
      it 'redirects to ' do
        get :keys
        expect(response).to redirect_to('/tree_display/drill')
      end
    end
  end
end
