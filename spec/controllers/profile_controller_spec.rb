require 'rails_helper'

describe ProfileController do
  let(:super_admin) { build(:superadmin, id: 1) }
  let(:instructor1) { build(:instructor, id: 10, name: 'Instructor1') }
  let(:questionnaire) { build(:questionnaire, id: 666) }
  let(:assignment_questionnaire) { build(:assignment_questionnaire, id: 1, questionnaire: questionnaire) }

  describe '#action_allowed?' do
    context 'when someone is logged in' do
      it 'allows certain action' do
        stub_current_user(instructor1, instructor1.role.name, instructor1.role)
        expect(controller.send(:action_allowed?)).to be_truthy
      end
    end

    context 'when no one is logged in' do
      it 'refuses certain action' do
        expect(controller.send(:action_allowed?)).to be_falsey
      end
    end
  end

  describe '#edit' do
    it 'renders edit page' do
      stub_current_user(instructor1, instructor1.role.name, instructor1.role)
      allow(AssignmentQuestionnaire).to receive(:where).with(any_args)
                                                       .and_return([assignment_questionnaire])

      get :edit
      expect(response).to render_template(:edit)
    end
  end

  describe '#update' do
    context 'when profile is saved successfully' do
      it 'shows a success flash message and redirects to profile#edit page' do
        stub_current_user(instructor1, instructor1.role.name, instructor1.role)
        allow(instructor1).to receive(:update_attributes).with(any_args).and_return(true)
        allow(instructor1).to receive(:save!).and_return(true)
        params = {
          id: 1,
          no_show_action: 'not_show_actions'
        }
        post :update, params
        expect(flash[:success]).to eq('Your profile was successfully updated.')
        expect(response).to redirect_to('/profile/1/edit')
      end
    end

    context 'when profile is saved successfully and assignment_questionnaire is not nil' do
      it 'shows a success flash message and redirects to profile#edit page' do
        stub_current_user(instructor1, instructor1.role.name, instructor1.role)
        allow(instructor1).to receive(:update_attributes).with(any_args).and_return(true)
        allow(instructor1).to receive(:save!).and_return(true)
        allow(AssignmentQuestionnaire).to receive(:where).with(any_args).and_return([assignment_questionnaire])

        params = {
          id: 1,
          no_show_action: 'not_show_actions',
          assignment_questionnaire: { 'assignment_id' => '1', 'questionnaire_id' => '666', 'dropdown' => 'true',
                                      'questionnaire_weight' => '0', 'notification_limit' => '15', 'used_in_round' => '1' }
        }
        post :update, params
        expect(flash[:success]).to eq('Your profile was successfully updated.')
        expect(response).to redirect_to('/profile/1/edit')
      end
    end

    context 'when profile is not saved successfully' do
      it 'displays an error flash message and redirects to profile#edit page' do
        stub_current_user(instructor1, instructor1.role.name, instructor1.role)
        allow(instructor1).to receive(:update_attributes).with(any_args).and_return(false)
        params = {
          id: 1
        }
        post :update, params
        expect(flash[:error]).to eq('An error occurred and your profile could not updated.')
        expect(response).to redirect_to('/profile/1/edit')
      end
    end

  end
end