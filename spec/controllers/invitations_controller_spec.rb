describe InvitationsController do
  let(:instructor) { build(:instructor, id: 6) }
  let(:student) { build(:student, parent_id: 2, id: 1) }
  let(:student1) { build(:student, id: 2) }
  let(:admin) { build(:admin) }
  let(:ta) { build(:teaching_assistant, id: 8) }
  let(:invitation) { build(:invitation) }
  let(:participant) { build(:participant, id: 1) }
  let(:assignment) { build(:assignment, id: 2, is_conference_assignment: 1, max_team_size: 100) }
  let(:assignment2) { build(:assignment, id: 2, is_conference_assignment: 0, max_team_size: 100) }
  let(:teamUser) { build(:team_user, id: 3) }
  let(:team) { build(:team, id: 3) }
  describe '#action_allowed?' do
    context 'when current user is student' do
      it 'allows the actions' do
        user = student
        stub_current_user(user, user.role.name, user.role)
        expect(controller.send(:action_allowed?)).to be true
      end
    end
    context 'when current user is instructor' do
      it 'allows the actions' do
        user = instructor
        stub_current_user(user, user.role.name, user.role)
        expect(controller.send(:action_allowed?)).to be true
      end
    end
    context 'when current user is ta' do
      it 'allows the actions' do
        user = ta
        stub_current_user(user, user.role.name, user.role)
        expect(controller.send(:action_allowed?)).to be true
      end
    end
    context 'when current user is admin' do
      it 'allows the actions' do
        user = admin
        stub_current_user(user, user.role.name, user.role)
        expect(controller.send(:action_allowed?)).to be true
      end
    end
  end

  describe '#check_user_before_invitation' do
    it 'invitation added for existing user' do
      allow(User).to receive(:find_by).with(name: 'student@gmail.com').and_return(student)
      allow(AssignmentParticipant).to receive(:find).with('1').and_return(participant)
      allow(Assignment).to receive(:find).with(1).and_return(assignment)
      request_params = {
        user: { name: 'student@gmail.com', email: 'student@gmail.com' },
        student_id: 1
      }
      user_session = { user: student }

      expect { post :create, params: request_params, session: user_session }.to change(Invitation, :count).by(1).and change(User, :count).by(0)
    end

    it 'invitation added for new user who does not have an expertiza account yet and sends an invitation' do
      allow(User).to receive(:skip_callback).with(:create, :after, :email_welcome).and_return(true)
      request_params = {
        user: { name: 'testuser@gmail.com',
                fullname: 'John Bumgardner',
                parent_id: 1,
                institution_id: 1 },
        student_id: 1,
        team_id: 1
      }
      allow(AssignmentParticipant).to receive(:find).with('1').and_return(participant)
      allow(Assignment).to receive(:find).with(1).and_return(assignment)
      allow(TeamsUser).to receive(:find).with('1').and_return(teamUser)
      allow(Team).to receive(:find).with('1').and_return(team)
      user_session = { user: student1 }
      expect { post :create, params: request_params, session: user_session }.to change(Invitation, :count).by(1).and change(User, :count).by(1)
    end

    it 'invitation not added for new user if entered email has incorrect format' do
      allow(User).to receive(:skip_callback).with(:create, :after, :email_welcome).and_return(true)
      request_params = {
        user: { name: 'testuser',
                parent_id: 1,
                institution_id: 1 },
        student_id: 1,
        team_id: 1
      }
      allow(AssignmentParticipant).to receive(:find).with('1').and_return(participant)
      allow(Assignment).to receive(:find).with(1).and_return(assignment)
      allow(TeamsUser).to receive(:find).with('1').and_return(teamUser)
      allow(Team).to receive(:find).with('1').and_return(team)
      user_session = { user: student1 }
      expect { post :create, params: request_params, session: user_session }.to change(Invitation, :count).by(0).and change(User, :count).by(0)
    end

    it 'invitation and user not added for new user with normal assignment' do
      request_params = {
        user: { name: 'testuser@gmail.com',
                email: 'testuser@gmail.com' },
        student_id: 1,
        team_id: 1
      }
      allow(AssignmentParticipant).to receive(:find).with('1').and_return(participant)
      allow(Assignment).to receive(:find).with(1).and_return(assignment2)
      allow(TeamsUser).to receive(:find).with('1').and_return(teamUser)
      allow(Team).to receive(:find).with('1').and_return(team)
      user_session = { user: student1 }
      expect { post :create, params: request_params, session: user_session }.to change(Invitation, :count).by(0).and change(User, :count).by(0)
      expect(flash[:error]).to eq 'The user "testuser@gmail.com" does not exist. Please make sure the name entered is correct.'
    end
  end
  describe '#create' do
    it 'creates a new Invitation object' do
      expect { create(:invitation) }.to change(Invitation, :count).by(1)
    end
  end

  describe '#accept' do
    it 'accepts the invite' do
      allow(Invitation).to receive(:find).with('1').and_return(invitation)
      request_params = { team_id: 1, inv_id: 1 }
      user_session = { user: instructor }
      get :accept, params: request_params, session: user_session
      expect(flash[:error]).to eq 'The team that invited you does not exist anymore.'
      expect(response).to redirect_to('/student_teams/view')
    end
  end

  describe '#decline' do
    it ' declines the invite' do
      allow(Invitation).to receive(:find).with('1').and_return(invitation)
      allow(Participant).to receive(:find).with('1').and_return(student)
      request_params = { student_id: student.id, inv_id: 1 }
      user_session = { user: instructor }
      get :decline, params: request_params, session: user_session
      expect(response).to redirect_to('/student_teams/view?student_id=1')
    end
  end

  describe '#cancel' do
    it 'cancels the invite' do
      allow(Invitation).to receive(:find).with('1').and_return(invitation)
      allow(invitation).to receive(:destroy).and_return(true)
      request_params = { inv_id: 1, student_id: student.id }
      user_session = { user: instructor }
      get :cancel, params: request_params, session: user_session
      expect(response).to redirect_to('/student_teams/view?student_id=1')
    end
  end
end
