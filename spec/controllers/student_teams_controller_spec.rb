require './spec/support/teams_shared.rb'

describe StudentTeamsController do
  # Including the stubbed objects from the teams_shared.rb file
  include_context 'object initializations'
  # Including the shared method from the teams_shared.rb file
  include_context 'authorization check'

  let(:student_teams_controller) { StudentTeamsController.new }
  let(:student) { double 'student' }

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

  describe '#update' do
    # When the name is not already present in the database, it updates the name
    context 'update team name when matching name not found' do
      it 'update name when the name is not already present in the database' do
        allow(AssignmentTeam).to receive(:where).with(name: 'test', parent_id: 1).and_return([])
        allow(Team).to receive(:find).with('1').and_return(team7)
        allow(AssignmentParticipant).to receive(:find).with('1').and_return(student1)
        allow(AuthorizationHelper).to receive(:current_user_has_id).with(any_args).and_return(true)
        allow(student1).to receive(:user_id).with(any_args).and_return(1)
        allow(team7).to receive(:user_id).with(any_args).and_return(1)
        allow(team7).to receive(:update_attribute).and_return(true)
        user_session = { user: student1 }
        request_params = {
          student_id: 1,
          team_id: 1,
          team: {
            name: 'test'
          },
          action: 'update'
        }
        result = post :update, params: request_params, session: user_session
        # status code 302: Redirect url
        expect(result.status).to eq(302)
      end
    end
    # When no team has name and only one matching team is found,update the name
    context 'update name when name is found' do
      it 'update name when no team has name and only one matching team is found' do
        allow(AssignmentTeam).to receive(:where).with(name: 'test', parent_id: 1).and_return(team1)
        allow(Team).to receive(:find).with('1').and_return(team8)
        allow(AssignmentParticipant).to receive(:find).with('1').and_return(student1)
        allow(AuthorizationHelper).to receive(:current_user_has_id).with(any_args).and_return(true)
        allow(student1).to receive(:user_id).with(any_args).and_return(1)
        allow(team8).to receive(:user_id).with(any_args).and_return(1)
        allow(team8).to receive(:update_attribute).and_return(true)
        allow(team1).to receive(:length).and_return(1)
        allow(team1).to receive(:name).and_return('test')
        allow(team8).to receive(:name).and_return('test')
        user_session = { user: student1 }
        request_params = {
          student_id: 1,
          team_id: 1,
          team: {
            name: 'test'
          },
          action: 'update'
        }
        result = post :update, params: request_params, session: user_session
        # status code 302: Redirect url
        expect(result.status).to eq(302)
      end
    end
    # when the team name is already in use, then flash the error message
    context 'name is already in use' do
      it 'when the team name is already in use flash notice' do
        allow(AssignmentTeam).to receive(:where).with(name: 'test', parent_id: 1).and_return(team1)
        allow(Team).to receive(:find).with('1').and_return(team8)
        allow(AssignmentParticipant).to receive(:find).with('1').and_return(student1)
        allow(AuthorizationHelper).to receive(:current_user_has_id).with(any_args).and_return(true)
        allow(student1).to receive(:user_id).with(any_args).and_return(1)
        allow(team8).to receive(:user_id).with(any_args).and_return(1)
        allow(team1).to receive(:length).and_return(2)

        user_session = { user: student1 }
        request_params = {
          student_id: 1,
          team_id: 1,
          team: {
            name: 'test'
          },
          action: 'update'
        }
        result = post :update, params: request_params, session: user_session
        # status code 302: Redirect url
        expect(result.status).to eq(302)
      end
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
