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
end