require './spec/support/teams_shared.rb'

describe AdvertiseForPartnerController do
  # Including the stubbed objects from the teams_shared.rb file
  include_context 'object initializations'
  let(:team1user1) { build_stubbed(:team_user, id: 1, team: team1, user: student1) }
  let(:team1user2) { build_stubbed(:team_user, id: 2, team: team1, user: student2) }
  let(:participant) { build(:participant,  id: 1) }
  # Performs authorization check for user
  describe 'action allowed method' do
    context 'when called directly' do
      # Including the shared method from the teams_shared.rb file
      include_context 'authorization check'
      it 'provides access for student' do
        stub_current_user(student1, student1.role.name, student1.role)
        expect(controller.send(:action_allowed?)).to be true
      end
    end
    # we expect 302 status in response because these tests are only to check the authorization that happens before
    # controller enters the method itself, since there are no stubbings for methods themselves, the process will
    # encounter some problem once inside the method and redirect in all cases
    # since we only care about authorization checks, we are not concerned with where we get redirected to for now
    context 'performs access check when called before' do
      it 'checks if create method can be called by the user' do
        allow(AssignmentTeam).to receive(:find_by).and_return(team1)
        allow(team1).to receive(:update_attributes).with(any_args).and_return(true)
        allow(AssignmentTeam).to receive_message_chain(:find_by, :assignment).and_return(assignment1)
        allow(AssignmentParticipant).to receive(:find_by).with(any_args).and_return(participant)
        allow(AssignmentParticipant).to receive(:exists?).and_return(true)
        user_session = { user: student1 }
        result = get :create, session: user_session
        # status code 302: Redirect url
        expect(result.status).to eq 302
      end
      it 'check if update method can be called by the user' do
        allow(AssignmentTeam).to receive(:find_by).and_return(team1)
        allow(team1).to receive(:update_attributes).with(any_args).and_return(true)
        allow(AssignmentTeam).to receive_message_chain(:find_by, :assignment).and_return(assignment1)
        allow(AssignmentParticipant).to receive(:find_by).with(any_args).and_return(participant)
        allow(AssignmentParticipant).to receive(:exists?).and_return(true)
        user_session = { user: student1 }
        result = get :update, session: user_session
        # status code 302: Redirect url
        expect(result.status).to eq 302
      end
      it 'check if edit method can be called by the user' do
        allow(AssignmentTeam).to receive(:find_by).and_return(team1)
        allow(team1).to receive(:update_attributes).with(any_args).and_return(true)
        allow(AssignmentTeam).to receive_message_chain(:find_by, :assignment).and_return(assignment1)
        allow(AssignmentParticipant).to receive(:exists?).and_return(true)
        allow(AssignmentParticipant).to receive(:find_by).with(any_args).and_return(participant)
        user_session = { user: student1 }
        result = get :edit, session: user_session
        # status code 302: Redirect url
        expect(result.status).to eq 200
      end
      it 'check if remove method can be called by the user' do
        allow(AssignmentTeam).to receive(:find_by).and_return(team1)
        allow(AssignmentTeam).to receive_message_chain(:find_by, :assignment).and_return(assignment1)
        allow(AssignmentParticipant).to receive(:exists?).and_return(true)
        user_session = { user: student1 }
        result = get :remove, session: user_session
        # status code 302: Redirect url
        expect(result.status).to eq 302
      end
    end
  end

  # When the Assignment team exists and the assignment participant exists, then allow user to edit
  describe 'edit method called' do
    it 'by a valid team allows user to edit the advertisement' do
      allow(AssignmentTeam).to receive(:find_by).and_return(team1)
      allow(AssignmentTeam).to receive_message_chain(:find_by, :assignment).and_return(assignment1)
      allow(AssignmentParticipant).to receive(:exists?).and_return(true)
      request_params = { id: team1.id, team_id: team1.id }
      user_session = { user: student1 }
      result = get :edit, params: request_params, session: user_session
      # status code 200: Request succeeded
      expect(result.status).to eq 200
      expect(controller.instance_variable_get(:@team)).to eq team1
    end
  end

  # create advertisement by passing team and paticipant details
  describe 'create method called' do
    context 'by a an existing team with advertisement comment' do
      it 'will create an advertisement for the team in current session' do
        allow(AssignmentTeam).to receive(:find_by).and_return(team1)
        allow(AssignmentParticipant).to receive(:exists?).and_return(true)
        allow(team1).to receive(:assignment).and_return(assignment1)
        allow(team1).to receive(:update_attributes).and_return(true)
        allow(AssignmentParticipant).to receive(:find_by).and_return(participant)
        request_params = { id: team1.id, team_id: team1.id }
        user_session = { user: ta }
        result = get :create, params: request_params, session: user_session
        # status code 302: Redirect url
        expect(result.status).to eq 302
        expect(result).to redirect_to(view_student_teams_path(student_id: 1))
      end
    end
  end

  # Update advertisement by passing team and participant details
  describe 'update method called' do
    context 'to update the comment in advertisement by a valid member of the current team in user_session' do
      it 'updates the advertisement successfully' do
        allow(AssignmentTeam).to receive(:find_by).and_return(team1)
        allow(AssignmentParticipant).to receive(:exists?).and_return(true)
        allow(team1).to receive(:assignment).and_return(assignment1)
        allow(team1).to receive(:update_attributes).and_return(true)
        allow(AssignmentParticipant).to receive(:find_by).and_return(participant)
        request_params = {
          id: team1.id,
          team_id: team1.id
        }
        user_session = { user: ta }
        result = get :update, params: request_params, session: user_session
        # status code 302: Redirect url
        expect(result.status).to eq 302
        expect(result).to redirect_to(view_student_teams_path(student_id: 1))
      end
    end

    context 'to update the comment in advertisement by a non-valid member of the current team in user_session' do
      it 'throws an error and the advertisement is not updated' do
        allow(AssignmentTeam).to receive(:find_by).and_return(team1)
        allow(AssignmentParticipant).to receive(:exists?).and_return(true)
        allow(team1).to receive(:assignment).and_return(assignment1)
        allow(AssignmentParticipant).to receive(:find_by).and_return(participant)
        allow(team1).to receive(:update_attributes).and_raise(StandardError)
        request_params = {
          id: team1.id,
          team_id: team1.id
        }
        user_session = { user: ta }
        result = get :update, params: request_params, session: user_session
        expect(flash[:error]).to eq 'An error occurred and your advertisement was not updated!'
        # status code 200: Request succeeded
        expect(result.status).to eq 200
      end
    end
  end

  # Remove advertisement by passing team and participant details
  describe 'remove method' do
    context 'when called by a valid member of the current team in user_session' do
      it 'allows to successfully remove the advertisement' do
        allow(AssignmentTeam).to receive(:find_by).and_return(team1)
        allow(AssignmentParticipant).to receive(:exists?).and_return(true)
        allow(team1).to receive(:assignment).and_return(assignment1)
        allow(team1).to receive(:update_attributes).and_return(true)
        allow(AssignmentParticipant).to receive(:find_by).and_return(participant)
        request_params = {
          id: team1.id,
          team_id: team1.id
        }
        user_session = { user: ta }
        result = get :remove, params: request_params, session: user_session
        # status code 302: Redirect url
        expect(result.status).to eq 302
        expect(result).to redirect_to(view_student_teams_path(student_id: 1))
      end
    end

    context 'when called by a non-valid member of the current team in session' do
      it 'throws an error and advertisement is not removed' do
        allow(AssignmentTeam).to receive(:find_by).and_return(team1)
        allow(AssignmentParticipant).to receive(:exists?).and_return(true)
        allow(team1).to receive(:assignment).and_return(assignment1)
        allow(AssignmentParticipant).to receive(:find_by).and_return(participant)
        allow(team1).to receive(:update_attributes).and_raise(StandardError)
        request_params = {
          id: team1.id,
          team_id: team1.id
        }
        user_session = { user: ta }
        result = get :remove, params: request_params, session: user_session
        expect(flash[:error]).to eq 'An error occurred and your advertisement was not removed!'
        expect(result).to redirect_to(request.env['HTTP_REFERER'] ? :back : :root)
      end
    end
  end
end
