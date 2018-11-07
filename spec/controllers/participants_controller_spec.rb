describe ParticipantsController do
  let(:instructor) { build(:instructor, id: 6) }
  let(:student) { build(:student) }
  let(:course_participant) { build(:course_participant) }
  let(:participant) { build(:participant) }
  describe '#action_allowed?' do
    context 'when current user is student' do
      it 'allows update_duties action' do
        controller.params = {action: 'update_duties'}
        user = student
        stub_current_user(user, user.role.name, user.role)
        expect(controller.send(:action_allowed?)).to be true
      end
      it 'allows change_handle action' do
        controller.params = {action: 'change_handle'}
        user = student
        stub_current_user(user, user.role.name, user.role)
        expect(controller.send(:action_allowed?)).to be true
      end
      it 'disallows all other actions' do
        user = student
        stub_current_user(user, user.role.name, user.role)
        expect(controller.send(:action_allowed?)).to be false
      end
    end
    context 'when current user is instructor and above' do
      it 'allows all actions' do
        user = instructor
        stub_current_user(user, user.role.name, user.role)
        expect(controller.send(:action_allowed?)).to be true
      end
    end
  end

  describe '#destroy' do
    it 'deletes the participant and redirects to #list page' do
      allow(Participant).to receive(:find).with('1').and_return(course_participant)
      allow(course_participant).to receive(:destroy).and_return(true)
      params = {id: 1}
      session = {user: instructor}
      post :destroy, params, session
      expect(response).to redirect_to('/participants/list?id=1&model=Course')
    end
  end

  describe '#delete_assignment_participant' do
    it 'deletes the assignment_participant and redirects to #review_mapping/list_mappings page' do
      allow(Participant).to receive(:find).with('1').and_return(participant)
      allow(participant).to receive(:destroy).and_return(true)
      params = {id: 1}
      session = {user: instructor}
      post :delete_assignment_participant, params, session
      expect(response).to redirect_to('/review_mapping/list_mappings?id=1')
    end
  end

  describe '#update_duties' do
    it 'updates the duties for the participant' do
      allow(Participant).to receive(:find).with('1').and_return(participant)
      params = {student_id: 1}
      session = {user: instructor}
      post :update_duties, params, session
      expect(response).to redirect_to('/student_teams/view?student_id=1')
    end
  end
end
