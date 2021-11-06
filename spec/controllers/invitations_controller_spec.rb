describe InvitationsController do
  let(:instructor) { build(:instructor, id: 6) }
  let(:student) { build(:student) }
  let(:admin) { build(:admin) }
  let(:ta) { build(:teaching_assistant, id: 8) }
  let(:invitation) { build(:invitation) }
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

  describe '#create' do
    it 'creates a new Invitation object' do
      expect { create(:invitation) }.to change(Invitation, :count).by(1)
    end
  end

  describe '#accept' do
    it 'accepts the invite' do
      allow(Invitation).to receive(:find).with('1').and_return(invitation)
      params = {team_id: 1, inv_id: 1}
      session = {user: instructor}
      get :accept, params, session
      expect(flash[:error]).to eq 'The team that invited you does not exist anymore.'
      expect(response).to redirect_to('/student_teams/view')
    end
  end

  describe '#decline' do
    it ' declines the invite' do
      allow(Invitation).to receive(:find).with('1').and_return(invitation)
      allow(Participant).to receive(:find).with(student.id).and_return(student)
      params = {student_id: student.id, inv_id: 1}
      session = {user: instructor}
      get :decline, params, session
      expect(response).to redirect_to('/student_teams/view')
    end
  end

  describe '#cancel' do
    it 'cancels the invite' do
      allow(Invitation).to receive(:find).with('1').and_return(invitation)
      allow(invitation).to receive(:destroy).and_return(true)
      params = {inv_id: 1, student_id: student.id}
      session = {user: instructor}
      get :cancel, params, session
      expect(response).to redirect_to('/student_teams/view')
    end
  end
end
