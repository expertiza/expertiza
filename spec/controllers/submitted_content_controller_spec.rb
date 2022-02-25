describe SubmittedContentController do
  let(:super_admin) { build(:superadmin, id: 1, role_id: 5) }
  let(:instructor1) { build(:instructor, id: 10, role_id: 3, parent_id: 3, name: 'Instructor1') }
  let(:student1) { build(:student, id: 21, role_id: 1) }
  let(:participant) { build(:participant, id: 1, user_id: 21) }
  describe '#submit_file' do
    context 'current user does not match up with the participant' do
      it 'renders edit template' do
        allow(AssignmentParticipant).to receive(:find).and_return(participant)
        stub_current_user(instructor1, instructor1.role.name, instructor1.role)
        request_params = { id: 1 }
        response = get :submit_file, params: request_params
        expect(response).to redirect_to(action: :edit, id: 1)
      end
    end
  end
end
