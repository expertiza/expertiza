describe LockController do
  let(:super_admin) { build(:superadmin, id: 1, role_id: 5) }
  let(:instructor1) { build(:instructor, id: 10, role_id: 3, parent_id: 3, name: 'Instructor1') }
  let(:student1) { build(:student, id: 21, role_id: 1) }
  let(:lock1) { build(:lock, id: 1, name: 'test lockable') }

  describe '#action_allowed?' do
    context 'when the role of current user is Instructor' do
      it 'allows certain action' do
        stub_current_user(instructor1, instructor1.role.name, instructor1.role)
        expect(controller.send(:action_allowed?)).to be_truthy
      end
    end 
    context 'when the role of current user is Student' do
      it 'refuses certain action' do
        stub_current_user(student1, student1.role.name, student1.role)
        expect(controller.send(:action_allowed?)).to be_falsey
      end
    end
    context 'when the role of current user is Super Admin' do
      it 'allows certain action' do
        stub_current_user(super_admin, super_admin.role.name, super_admin.role)
        expect(controller.send(:action_allowed?)).to be_truthy
      end
    end
  end
  describe '#release_lock' do
    context 'when release lock ' do
      it 'renders the response correctly' do
        allow(Lock).to receive(:find).with('1').and_return(lock1)
        @params = {
          id: 1,
          lock: {
            name: 'test lockable'
          }
        }
        get :release_lock, @params
        expect(response).to redirect_to(:back)
      end
    end
  end
end