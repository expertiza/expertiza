describe ProfileController do
  let(:super_admin) { build(:superadmin, id: 1, role_id: 5) }
  let(:instructor1) { build(:instructor, id: 10, role_id: 3, parent_id: 3, name: 'Instructor1') }
  let(:student1) { build(:student, id: 21, role_id: 1) }
  describe '#action_allowed?' do
    context 'when someone is logged in' do
      it 'allows certain action' do
        stub_current_user(instructor1, instructor1.role.name, instructor1.role)
        expect(controller.send(:action_allowed?)).to be_truthy
      end
    end
    context 'when no one is logged in' do
      it 'refuses certain action' do
        expect(controller.send(:action_allowed?)).to be_falsey
      end
    end
  end
end