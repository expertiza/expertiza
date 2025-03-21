require 'rails_helper'

describe PairProgrammingController do
  let(:super_admin) { build(:superadmin, id: 1, role_id: 5) }
  let(:admin) { build(:admin, id: 3) }
  let(:instructor1) { build(:instructor, id: 10, role_id: 3, parent_id: 3, name: 'Instructor1') }
  let(:student1) { build(:student, id: 21, role_id: 1) }
  let(:student2) { build(:student, id: 22, role_id: 1) }
  let(:ta) { build(:teaching_assistant, id: 6) }  
  
  let(:team_user1) { build(:team_user, id: 1, team: team, user: student1, pair_programming_status: "Z") }
  let(:team_user2) { build(:team_user, id: 2, team: team, user: student2, pair_programming_status: "Z") }
  let(:team) { build(:assignment_team, id: 1, parent_id: 1, pair_programming_request: 0) }
  
  let(:team_participant) { build(:teams_participant, id: 1, team_id: 1, participant_id: 1) }
  let(:participant) { build(:participant, id: 1) }
  
  #load student object with id 21
  before(:each) do
    allow(User).to receive(:find).with(21).and_return(student1)
  end

  describe '#action_allowed?' do
    #check if super-admin is able to perform the actions
    it 'allows super_admin to perform certain action' do
      stub_current_user(super_admin, super_admin.role.name, super_admin.role)
      expect(controller.send(:action_allowed?)).to be_truthy
    end

    #check if instructor is able to perform the actions
    it 'allows instructor to perform certain action' do
      stub_current_user(instructor1, instructor1.role.name, instructor1.role)
      expect(controller.send(:action_allowed?)).to be_truthy
    end

    #check if student is able to perform the actions
    it 'allows student to perform certain action' do
      stub_current_user(student1, student1.role.name, student1.role)
      expect(controller.send(:action_allowed?)).to be_truthy
    end

    #check if teaching assistant is able to perform the actions
    it 'allows teaching assistant to perform certain action' do
      stub_current_user(ta, ta.role.name, ta.role)
      expect(controller.send(:action_allowed?)).to be_truthy
    end

    #check if admin is able to perform the actions
    it 'allows admin to perform certain action' do
      stub_current_user(admin, admin.role.name, admin.role)
      expect(controller.send(:action_allowed?)).to be_truthy
    end
  end

  describe '#send_invitations' do
    it 'sends pair programming invitation to all the team members' do
      users = allow(TeamsUser).to receive(:where).and_return([team_user1,team_user2])
      [users].each do |user|
        allow(user).to receive(:update_attributes).and_return(true)
      end
      user1 = allow(TeamsUser).to receive(:find_by).and_return(team_user1)
      allow(user1).to receive(:update_attributes).and_return(true)
      team1 = allow(Team).to receive(:find).and_return(team)
      allow(team1).to receive(:update_attributes).and_return(true)
      user_session = { user: student1 }
      params = {team_id: team.id, user_id: student1.id}
      result = post :send_invitations, params: params, session: user_session
      expect(flash[:success]).to eq('Invitations have been sent successfully!')
      expect(result.status).to eq 302
      expect(result).to redirect_to('/student_teams/view')
    end
  end

  describe '#accept' do
    it 'accepts the pair programming request' do
      user1 = allow(TeamsUser).to receive(:find_by).and_return(team_user1)
      allow(user1).to receive(:update_attributes).and_return(true)
      user_session = { user: student1 }
      params = {team_id: team.id, user_id: student1.id}
      result = post :accept, params: params, session: user_session
      expect(flash[:success]).to eq('Pair Programming Request Accepted Successfully!')
      expect(result.status).to eq 302
      expect(result).to redirect_to('/student_teams/view')
    end
  end

  describe '#decline' do
    it 'declines the pair programming request' do
      user1 = allow(TeamsUser).to receive(:find_by).and_return(team_user1)
      allow(user1).to receive(:update_attributes).and_return(true)
      team1 = allow(Team).to receive(:find).and_return(team)
      allow(team1).to receive(:update_attributes).and_return(true)
      user_session = { user: student1 }
      params = {team_id: team.id, user_id: student1.id}
      result = post :decline, params: params, session: user_session
      expect(flash[:success]).to eq('Pair Programming Request Declined!')
      expect(result.status).to eq 302
      expect(result).to redirect_to('/student_teams/view')
    end
  end

  describe 'GET #index' do
    it 'renders the index template' do
      get :index
      expect(response).to render_template(:index)
    end
  end

  describe 'GET #show' do
    it 'shows pair programming details' do
      allow(Team).to receive(:find).with(1).and_return(team)
      allow(TeamsParticipant).to receive(:where).with(team_id: 1).and_return([team_participant])
      get :show, params: { id: 1 }
      expect(response).to render_template(:show)
    end
  end

  describe 'GET #new' do
    it 'renders the new template' do
      get :new
      expect(response).to render_template(:new)
    end
  end

  describe 'POST #create' do
    it 'creates a new pair programming session' do
      allow(TeamsParticipant).to receive(:create).with(team_id: 1, participant_id: 1).and_return(team_participant)
      post :create, params: { pair_programming: { team_id: 1, participant_id: 1 } }
      expect(response).to redirect_to(pair_programming_path(1))
    end
  end

  describe 'GET #edit' do
    it 'renders the edit template' do
      allow(PairProgramming).to receive(:find).with(1).and_return(build(:pair_programming))
      get :edit, params: { id: 1 }
      expect(response).to render_template(:edit)
    end
  end

  describe 'PATCH #update' do
    it 'updates a pair programming session' do
      allow(PairProgramming).to receive(:find).with(1).and_return(build(:pair_programming))
      patch :update, params: { id: 1, pair_programming: { team_id: 1, participant_id: 1 } }
      expect(response).to redirect_to(pair_programming_path(1))
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys a pair programming session' do
      allow(PairProgramming).to receive(:find).with(1).and_return(build(:pair_programming))
      delete :destroy, params: { id: 1 }
      expect(response).to redirect_to(pair_programmings_path)
    end
  end

  describe 'GET #start_session' do
    it 'starts a pair programming session' do
      allow(Team).to receive(:find).with(1).and_return(team)
      allow(TeamsParticipant).to receive(:where).with(team_id: 1).and_return([team_participant])
      get :start_session, params: { id: 1 }
      expect(response).to redirect_to(pair_programming_path(1))
    end
  end

  describe 'GET #end_session' do
    it 'ends a pair programming session' do
      allow(Team).to receive(:find).with(1).and_return(team)
      allow(TeamsParticipant).to receive(:where).with(team_id: 1).and_return([team_participant])
      get :end_session, params: { id: 1 }
      expect(response).to redirect_to(pair_programming_path(1))
    end
  end
end
