require 'rails_helper'

describe TeamsParticipantController do
  let(:instructor) { create(:instructor) }
  let(:student) { create(:student) }
  let(:assignment) { create(:assignment) }
  let(:team) { create(:assignment_team, assignment: assignment) }
  let(:participant) { create(:participant, user: student, assignment: assignment) }
  let(:teams_participant) { create(:teams_participant, team: team, participant: participant) }

  before(:each) do
    allow(controller).to receive(:current_user).and_return(instructor)
  end

  describe 'GET #list' do
    it 'renders the list template' do
      get :list, params: { id: team.id }
      expect(response).to render_template(:list)
    end
  end

  describe 'GET #new' do
    it 'renders the new template' do
      get :new, params: { id: team.id }
      expect(response).to render_template(:new)
    end
  end

  describe 'POST #create' do
    context 'with valid parameters' do
      it 'creates a new teams participant' do
        expect {
          post :create, params: { id: team.id, user: { name: student.name } }
        }.to change(TeamsParticipant, :count).by(1)
      end

      it 'redirects to teams list' do
        post :create, params: { id: team.id, user: { name: student.name } }
        expect(response).to redirect_to(controller: 'teams', action: 'list', id: team.parent_id)
      end
    end

    context 'with invalid parameters' do
      it 'does not create a teams participant' do
        expect {
          post :create, params: { id: team.id, user: { name: 'nonexistent_user' } }
        }.not_to change(TeamsParticipant, :count)
      end

      it 'renders the new template' do
        post :create, params: { id: team.id, user: { name: 'nonexistent_user' } }
        expect(response).to render_template(:new)
      end
    end
  end

  describe 'DELETE #delete' do
    it 'deletes the teams participant' do
      teams_participant
      expect {
        delete :delete, params: { id: teams_participant.id }
      }.to change(TeamsParticipant, :count).by(-1)
    end

    it 'redirects to teams list' do
      delete :delete, params: { id: teams_participant.id }
      expect(response).to redirect_to(controller: 'teams', action: 'list', id: team.parent_id)
    end
  end

  describe 'DELETE #delete_selected' do
    it 'deletes selected teams participants' do
      teams_participant
      expect {
        delete :delete_selected, params: { id: team.id, item: [teams_participant.id] }
      }.to change(TeamsParticipant, :count).by(-1)
    end

    it 'redirects to list action' do
      delete :delete_selected, params: { id: team.id, item: [teams_participant.id] }
      expect(response).to redirect_to(action: 'list', id: team.id)
    end
  end

  describe 'PATCH #update_duties' do
    it 'updates the duty' do
      patch :update_duties, params: { 
        teams_participant_id: teams_participant.id,
        teams_participant: { duty_id: 1 },
        participant_id: participant.id
      }
      teams_participant.reload
      expect(teams_participant.duty_id).to eq(1)
    end

    it 'redirects to student teams view' do
      patch :update_duties, params: { 
        teams_participant_id: teams_participant.id,
        teams_participant: { duty_id: 1 },
        participant_id: participant.id
      }
      expect(response).to redirect_to(controller: 'student_teams', action: 'view', student_id: participant.id)
    end
  end
end 