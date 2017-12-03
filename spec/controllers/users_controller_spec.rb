describe UsersController do
  let(:admin) {build(:admin)}
  let(:superadmin) {build(:superadmin)}
  let(:instructor) {build(:instructor, id: 6)}
  let(:instructor2) {build(:instructor, id: 66)}
  let(:ta) {build(:teaching_assistant, id: 8)}
  let(:student) {build(:student)}

  describe '#action_allowed?' do
    context 'when params action is request_new' do
      it 'allows certain action' do
        controller.params = {action: 'request_new'}
        expect(controller.send(:action_allowed?)).to be true
      end
    end

    context 'when params action is request_user_create' do
      it 'allows certain action' do
        controller.params = {action: 'request_user_create'}
        expect(controller.send(:action_allowed?)).to be true
      end
    end


    context 'when params action is review' do
      it 'allows certain action' do
        controller.params = {action: 'review'}
        stub_current_user(superadmin, superadmin.role.name, superadmin.role)
        expect(controller.send(:action_allowed?)).to be true
      end
    end

    context 'when params action is keys' do
      it 'allows certain action' do
        controller.params = {action: 'keys'}
        stub_current_user(student, student.role.name, student.role)
        expect(controller.send(:action_allowed?)).to be true
      end
    end

    context 'when the current role is administrator and params action is something else' do
      it 'allows certain action' do
        controller.params = {action: 'view'}
        stub_current_user(admin, admin.role.name, admin.role)
        expect(controller.send(:action_allowed?)).to be true
      end
    end

    context 'when the current role is superadministrator and params action is something else' do
      it 'allows certain action' do
        controller.params = {action: 'view'}
        stub_current_user(superadmin, superadmin.role.name, superadmin.role)
        expect(controller.send(:action_allowed?)).to be true
      end
    end

    context 'when the current role is instructor and params action is something else' do
      it 'allows certain action' do
        controller.params = {action: 'view'}
        stub_current_user(instructor, instructor.role.name, instructor.role)
        expect(controller.send(:action_allowed?)).to be true
      end
    end

    context 'when the current role is ta and params action is something else' do
      it 'allows certain action' do
        controller.params = {action: 'view'}
        stub_current_user(ta, ta.role.name, ta.role)
        expect(controller.send(:action_allowed?)).to be true
      end
    end
  end

  describe '#index' do
    context 'when the current user is student' do
      it 'redirect to the home page' do
        stub_current_user(student, student.role.name, student.role)
        get :index
        expect(response).to redirect_to('/')
      end
    end

    context 'when the current user is not student' do
      it 'redirect to /users/list page' do
        stub_current_user(instructor, instructor.role.name, instructor.role)
        @request.session['user'] = instructor
        get :index
        expect(response).to render_template(:list)
      end
    end
  end

  describe '#list' do
    it 'render list' do
      # stub_current_user(instructor, instructor.role.name, instructor.role)
      # get :show_selection, {'user' => {'name' => 'instructor6sss'}}
      # expect(response).to render_template('/users/list')
      stub_current_user(instructor, instructor.role.name, instructor.role)
      @request.session['user'] = instructor
      get :list
      expect(response).to render_template(:list)
    end
  end
  describe '#list_pending_requested' do
    it 'render list pending' do
      stub_current_user(instructor, instructor.role.name, instructor.role)
      get :list_pending_requested
      expect(response).to render_template(:list_pending_requested)
    end
  end

end


