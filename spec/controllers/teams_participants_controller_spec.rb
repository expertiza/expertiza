require 'rails_helper'

describe TeamsParticipantsController do
  let(:team_participant) { build(:teams_participant, id: 1, team_id: 1, participant_id: 1) }
  let(:team) { build(:team, id: 1) }
  let(:participant) { build(:participant, id: 1) }

  describe 'POST #create' do
    it 'creates a new team participant' do
      allow(TeamsParticipant).to receive(:create).with(team_id: 1, participant_id: 1).and_return(team_participant)
      post :create, params: { team_id: 1, participant_id: 1 }
      expect(response).to redirect_to(team_path(1))
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys a team participant' do
      allow(TeamsParticipant).to receive(:find).with(1).and_return(team_participant)
      delete :destroy, params: { id: 1 }
      expect(response).to redirect_to(team_path(1))
    end
  end

  describe 'DELETE #delete_selected' do
    it 'deletes selected team participants' do
      allow(TeamsParticipant).to receive(:find).with(1).and_return(team_participant)
      delete :delete_selected, params: { selected: [1] }
      expect(response).to redirect_to(team_path(1))
    end
  end

  describe 'GET #list' do
    it 'lists team participants' do
      allow(Team).to receive(:find).with(1).and_return(team)
      allow(TeamsParticipant).to receive(:where).with(team_id: 1).and_return([team_participant])
      get :list, params: { team_id: 1 }
      expect(response).to render_template(:list)
    end
  end

  describe 'GET #new' do
    it 'renders the new template' do
      allow(Team).to receive(:find).with(1).and_return(team)
      get :new, params: { team_id: 1 }
      expect(response).to render_template(:new)
    end
  end

  describe 'GET #edit' do
    it 'renders the edit template' do
      allow(TeamsParticipant).to receive(:find).with(1).and_return(team_participant)
      get :edit, params: { id: 1 }
      expect(response).to render_template(:edit)
    end
  end

  describe 'PATCH #update' do
    it 'updates a team participant' do
      allow(TeamsParticipant).to receive(:find).with(1).and_return(team_participant)
      patch :update, params: { id: 1, teams_participant: { team_id: 1, participant_id: 1 } }
      expect(response).to redirect_to(team_path(1))
    end
  end
end 