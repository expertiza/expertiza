describe LockController do
  let(:super_admin) { build(:superadmin, id: 1, role_id: 5) }
  let(:instructor1) { build(:instructor, id: 10, role_id: 3, parent_id: 3, name: 'Instructor1') }
  let(:student1) { build(:student, id: 21, role_id: 1) }
  let(:lock1) { build(:lock, id: 1, user: instructor1, lockable_type: 'test lockable') }

  # Testing the action_allowed function with diffent roles
  # only current role can release the lock
  #
  describe '#action_allowed?' do
    context 'when the role of current user is Instructor' do
      it 'allows certain action' do
        stub_current_user(instructor1, instructor1.role.name, instructor1.role)
        expect(controller.send(:action_allowed?)).to be_truthy
      end
    end 
    context 'when the role of current user is Student' do
      it 'refuses the action' do
        stub_current_user(student1, student1.role.name, student1.role)
        expect(controller.send(:action_allowed?)).to be_falsey
      end
    end
    context 'when the role of current user is Super Admin' do
      it 'refuses the action' do
        stub_current_user(super_admin, super_admin.role.name, super_admin.role)
        expect(controller.send(:action_allowed?)).to be_falsey
      end
    end
  end
  # This test case is to test the release_lock function. We call HTTP get with a test @params input 
  # and expect the response to redirect to :back view once done
  describe '#release_lock' do
    context 'when release lock ' do
      it 'renders the response correctly' do
        allow(Lock).to receive(:find_by).with(any_args).and_return(lock1) # Allowing find_by to be call on Lock and return the lock1 instance for the test
        @params = {
          id: 123,
          type: 'test lockable'
        }
        get :release_lock, params: @params
        expect(response).to redirect_to(request.env['HTTP_REFERER'] ? :back : :root)
      end
    end
  end
end