describe ImportFileController do
  let(:super_admin) { build(:superadmin, id: 1, role_id: 5) }
  let(:instructor1) { build(:instructor, id: 10, role_id: 3, parent_id: 3, name: 'Instructor1') }
  let(:ta) { build(:teaching_assistant, id: 6) }
  let(:student1) { build(:student, id: 21, role_id: 1) }

  describe '#action_allowed?' do
    context 'when someone is logged in' do
      it 'allows certain action for admin' do
        stub_current_user(super_admin, super_admin.role.name, super_admin.role)
        expect(controller.send(:action_allowed?)).to be_truthy
      end
      it 'allows certain action for instructor' do
        stub_current_user(instructor1, instructor1.role.name, instructor1.role)
        expect(controller.send(:action_allowed?)).to be_truthy
      end
      it 'allows certain action for ta' do
        stub_current_user(ta, ta.role.name, ta.role)
        expect(controller.send(:action_allowed?)).to be_truthy
      end
      it 'refuses certain action for student' do
        stub_current_user(student1, student1.role.name, student1.role)
        expect(controller.send(:action_allowed?)).to be_falsey
      end
    end
    context 'when no one is logged in' do
      it 'refuses certain action' do
        expect(controller.send(:action_allowed?)).to be_falsey
      end
    end
  end
end