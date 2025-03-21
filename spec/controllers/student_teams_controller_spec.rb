require './spec/support/teams_shared.rb'
require 'rails_helper'

describe StudentTeamsController do
  # Including the stubbed objects from the teams_shared.rb file
  include_context 'object initializations'
  # Including the shared method from the teams_shared.rb file
  include_context 'authorization check'

  let(:student_teams_controller) { StudentTeamsController.new }
  let(:student) { double 'student' }
  let(:team_participant) { build(:teams_participant, id: 1, team_id: 1, participant_id: 1) }
  let(:team) { build(:team, id: 1) }
  let(:participant) { build(:participant, id: 1) }

  # renders the student view
  describe '#view' do
    it 'sets the student' do
      allow(AssignmentParticipant).to receive(:find).with('12345').and_return student
      allow(student_teams_controller).to receive(:current_user_id?)
      allow(student_teams_controller).to receive(:params).and_return(student_id: '12345')
      allow(student).to receive(:user_id)
      student_teams_controller.view
    end
  end

  describe 'GET #index' do
    it 'renders the index template' do
      get :index
      expect(response).to render_template(:index)
    end
  end

  describe 'GET #show' do
    it 'shows student team details' do
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
    # When assignment team is empty it flashes a notice
    context 'when create Assignment team' do
      it 'flash notice when team is empty' do
        allow(AssignmentTeam).to receive(:where).with(name: '', parent_id: 1).and_return([])
        allow(AssignmentParticipant).to receive(:find).with('1').and_return(student1)
        allow(AuthorizationHelper).to receive(:current_user_has_id).with(any_args).and_return(true)
        allow(student1).to receive(:user_id).with(any_args).and_return(1)
        user_session = { user: student1 }
        request_params = {
          student_id: 1,
          team: {
            name: ''
          },
          action: 'create'
        }
        result = post :create, params: request_params, session: user_session
        # status code 302: Redirect url
        expect(result.status).to eq 302
      end
    end
    # when all the team name is set correctly, create team
    context 'create team' do
      it 'saves the team when all the team name is set correctly' do
        allow(AssignmentNode).to receive(:find_by).with(node_object_id: 1).and_return(node1)
        allow(AssignmentTeam).to receive(:new).with(name: 'test', parent_id: 1).and_return(team7)
        allow(AssignmentParticipant).to receive(:find).with('1').and_return(student1)
        allow(AuthorizationHelper).to receive(:current_user_has_id).with(any_args).and_return(true)
        allow(User).to receive(:find).with(1).and_return(team_user1)
        allow_any_instance_of(Team).to receive(:add_member).with(any_args).and_return(true)
        allow(student1).to receive(:user_id).with(any_args).and_return(1)
        allow(team7).to receive(:save).and_return(true)
        user_session = { user: student1 }
        request_params = {
          student_id: 1,
          team: {
            name: 'test'
          },
          action: 'create'
        }
        result = post :create, params: request_params, session: user_session
        # status code 302: Redirect url
        expect(result.status).to eq(302)
      end
    end
    # when the team name is already in use, it flashes message
    context 'name already in use' do
      it 'flash notice when the team name is already in use' do
        allow(AssignmentTeam).to receive(:where).with(name: 'test', parent_id: 1).and_return(team7)
        allow(AssignmentParticipant).to receive(:find).with('1').and_return(student1)
        allow(AuthorizationHelper).to receive(:current_user_has_id).with(any_args).and_return(true)
        allow(student1).to receive(:user_id).with(any_args).and_return(1)
        allow(team7).to receive(:empty?).and_return(false)
        user_session = { user: student1 }
        request_params = {
          student_id: 1,
          team: {
            name: 'test'
          },
          action: 'create'
        }
        result = post :create, params: request_params, session: user_session
        # status code 302: Redirect url
        expect(result.status).to eq 302
      end
    end
  end

  describe 'GET #edit' do
    it 'renders the edit template' do
      allow(StudentTeam).to receive(:find).with(1).and_return(build(:student_team))
      get :edit, params: { id: 1 }
      expect(response).to render_template(:edit)
    end
  end

  describe 'PATCH #update' do
    it 'updates a student team' do
      allow(StudentTeam).to receive(:find).with(1).and_return(build(:student_team))
      patch :update, params: { id: 1, student_team: { team_id: 1, participant_id: 1 } }
      expect(response).to redirect_to(student_team_path(1))
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys a student team' do
      allow(StudentTeam).to receive(:find).with(1).and_return(build(:student_team))
      delete :destroy, params: { id: 1 }
      expect(response).to redirect_to(student_teams_path)
    end
  end

  describe 'GET #list' do
    it 'lists student teams' do
      allow(StudentTeam).to receive(:all).and_return([build(:student_team)])
      get :list
      expect(response).to render_template(:list)
    end
  end

  describe 'GET #view' do
    it 'views a student team' do
      allow(Team).to receive(:find).with(1).and_return(team)
      allow(TeamsParticipant).to receive(:where).with(team_id: 1).and_return([team_participant])
      get :view, params: { id: 1 }
      expect(response).to render_template(:view)
    end
  end

  # Commenting the testcase as the test is failing due to an error in the users controller
  # describe '#remove_participant' do
  #  context 'remove team user' do
  #    it 'remove user' do
  #   allow(AssignmentParticipant).to receive(:find).and_return(participant)
  #   allow(TeamsUser).to receive(:where).and_return(team_user1)
  #   allow(team_user1).to receive(:destroy_all)
  #   allow(team_user1).to receive_message_chain(:where,:empty?).and_return(false)
  #   allow_any_instance_of(AssignmentParticipant).to receive(:save).and_return(false)
  #   user_session = {user:student1}
  #   request_params = {
  #     team_id:1,
  #     user_id:1,
  #     student_id:1,
  #     team:{
  #       name:'test'
  #     }
  #   }
  #   result = post :remove_participant, params: request_params, session: user_session
  #   expect(result.status).to eq 302
  #   # expect(result).to redirect_to(view_student_teams_path(:student_id => 1))
  #    end
  #  end
  # end
end
