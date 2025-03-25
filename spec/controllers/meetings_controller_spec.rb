# spec/controllers/meetings_controller_spec.rb
require 'rails_helper'

RSpec.describe MeetingsController, type: :controller do
  describe 'GET #index' do
    it 'returns a success response' do
      create(:meeting) # Assuming you have a factory for Meeting
      get :index
      expect(response).to be_successful
      expect(JSON.parse(response.body)).to be_an(Array)
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new Meeting' do
        expect {
          post :create, params: { team_id: 1, meeting_date: '2023-10-27' }
        }.to change(Meeting, :count).by(1)
      end

      it 'returns a created response' do
        post :create, params: { team_id: 1, meeting_date: '2023-10-27' }
        expect(response).to have_http_status(:created)
      end
    end

    context 'with invalid params' do
      it 'does not create a new Meeting' do
        expect {
          post :create, params: { team_id: nil, meeting_date: nil }
        }.to_not change(Meeting, :count)
      end

      it 'returns an unprocessable entity response' do
        post :create, params: { team_id: nil, meeting_date: nil }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'PUT #update' do
    let!(:meeting) { create(:meeting, team_id: 1, meeting_date: '2023-10-27') }

    context 'with valid params' do
      it 'updates the requested meeting' do
        put :update, params: { id: meeting.id, team_id: 1, meeting_date: '2023-10-28', old_date: '2023-10-27' }
        meeting.reload
        expect(meeting.meeting_date).to eq(Date.parse('2023-10-28'))
      end

      it 'returns a success response' do
        put :update, params: { id: meeting.id, team_id: 1, meeting_date: '2023-10-28', old_date: '2023-10-27' }
        expect(response).to be_successful
      end
    end

    context 'with invalid params' do
      it 'returns an unprocessable entity response' do
        put :update, params: { id: meeting.id, team_id: nil, meeting_date: nil, old_date: '2023-10-27' }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'meeting not found' do
      it 'returns a not found response' do
        put :update, params: { id: 999, team_id: 1, meeting_date: '2023-10-28', old_date: '2023-10-27' }
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:meeting) { create(:meeting, team_id: 1, meeting_date: '2023-10-27') }

    it 'destroys the requested meeting' do
      expect {
        delete :destroy, params: { id: meeting.id, team_id: 1, meeting_date: '2023-10-27' }
      }.to change(Meeting, :count).by(-1)
    end

    it 'returns a success response' do
      delete :destroy, params: { id: meeting.id, team_id: 1, meeting_date: '2023-10-27' }
      expect(response).to be_successful
    end

    context 'meeting not found' do
      it 'returns a not found response' do
        delete :destroy, params: { id: 999, team_id: 1, meeting_date: '2023-10-27' }
        expect(response).to have_http_status(:not_found)
      end
    end
  end
  describe '#meeting_params' do
    it 'permits team_id and meeting_date' do
      params = { meeting: { team_id: team.id, meeting_date: Date.today } }
      controller.params = params
      expect(controller.send(:meeting_params)).to eq({ team_id: team.id, meeting_date: Date.today })
    end

    it 'requires meeting params' do
      params = {}
      controller.params = params
      expect { controller.send(:meeting_params) }.to raise_error(ActionController::ParameterMissing)
    end
  end

  describe '#set_meeting' do
    context 'when meeting exists' do
      it 'sets the @meeting variable' do
        get :update, params: { team_id: team.id, id: meeting.id }, format: :json
        expect(assigns(:meeting)).to eq(meeting)
      end
    end

    context 'when meeting does not exist' do
      it 'renders a not found response' do
        get :update, params: { team_id: team.id, id: 999 }, format: :json # Assuming 999 doesn't exist
        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)['message']).to eq('Meeting not found')
      end
    end
  end

  describe '#update' do
    context 'with valid params' do
      it 'updates the meeting' do
        put :update, params: { team_id: team.id, id: meeting.id, meeting: { meeting_date: Date.tomorrow } }, format: :json
        meeting.reload
        expect(meeting.meeting_date).to eq(Date.tomorrow)
      end

      it 'renders a success response' do
        put :update, params: { team_id: team.id, id: meeting.id, meeting: { meeting_date: Date.tomorrow } }, format: :json
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['message']).to eq('Meeting updated successfully')
      end
    end

    context 'with invalid params' do
      it 'renders an unprocessable entity response' do
        put :update, params: { team_id: team.id, id: meeting.id, meeting: { meeting_date: nil } }, format: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['errors']).to be_present
      end
    end
  end

  describe '#destroy' do
    it 'destroys the meeting' do
      delete :destroy, params: { team_id: team.id, id: meeting.id }, format: :json
      expect(Meeting.exists?(meeting.id)).to be_falsey
    end

    it 'renders a success response' do
      delete :destroy, params: { team_id: team.id, id: meeting.id }, format: :json
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['message']).to eq('Meeting deleted successfully')
    end

    context 'when the meeting cannot be destroyed' do
      before do
        allow_any_instance_of(Meeting).to receive(:destroy).and_return(false)
      end

      it 'renders an unprocessable entity response' do
        delete :destroy, params: { team_id: team.id, id: meeting.id }, format: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['error']).to eq('Failed to delete meeting')
      end
    end
  end
end
