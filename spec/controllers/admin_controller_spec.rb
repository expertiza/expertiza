describe AdminController do
  let(:admin1) { build(:admin, id: 3, role_id: 4, parent_id: 1, name: 'Administrator1') }
  let(:admin2) { build(:admin, id: 4, role_id: 4, parent_id: 1, name: 'Administrator2') }
  let(:super_admin) { build(:superadmin, id: 1, role_id: 5) }
  let(:instructor1) { build(:instructor, id: 10, role_id: 3, parent_id: 3, name: 'Instructor1') }
  let(:instructor2) { build(:instructor, id: 11, role_id: 3, parent_id: 4, name: 'Instructor2') }
  let(:student1) { build(:student, id: 21, role_id: 1) }

  # create fake lists
  let(:admin_list) { [admin1, admin2] }
  let(:instructor_list) { [instructor1, instructor2] }
  let(:instructor_list_pid3) { [instructor1] }
  let(:instructor_list_pid4) { [instructor2] }

  # define default behaviors for each method call
  before(:each) do
    allow(User).to receive(:find).with('3').and_return(admin1)
    allow(User).to receive(:find).with('1').and_return(super_admin)
    allow(User).to receive(:find).with('10').and_return(instructor1)
    allow(User).to receive(:where).with(['role_id = ?', super_admin.role_id]).and_return([super_admin])

    allow(User).to receive(:where).with(role_id: admin1.role).and_return(admin_list)
    allow(admin_list).to receive(:order).with(:name).and_return(admin_list)
    allow(admin_list).to receive(:where).with('parent_id = ?', super_admin.id).and_return(admin_list)
    allow(admin_list).to receive(:paginate).with(page: '1', per_page: 50).and_return(admin_list)

    allow(User).to receive(:where).with(role_id: instructor1.role).and_return(instructor_list)
    allow(instructor_list).to receive(:order).with(:name).and_return(instructor_list)
    allow(instructor_list).to receive(:where).with('parent_id = ?', admin1.id).and_return(instructor_list_pid3)
    allow(instructor_list_pid3).to receive(:paginate).with(page: '1', per_page: 50).and_return(instructor_list_pid3)
  end

  describe '#action_allowed?' do
    context 'when params action is list all instructors' do
      before(:each) do
        controller.params = { action: 'list_instructors' }
      end

      context 'when the role of current user is Admin' do
        it 'allows certain action' do
          stub_current_user(admin1, admin1.role.name, admin1.role)
          controller.send(:action_allowed?).should be true
        end
      end

      context 'when the role of current user is Super-Admin' do
        it 'allows certain action' do
          stub_current_user(super_admin, super_admin.role.name, super_admin.role)
          controller.send(:action_allowed?).should be true
        end
      end

      context 'when the role of current user is Instructor' do
        it 'refuses certain action' do
          stub_current_user(instructor1, instructor1.role.name, instructor1.role)
          controller.send(:action_allowed?).should be false
        end
      end

      context 'when the role of current user is Student' do
        it 'refuses certain action' do
          stub_current_user(student1, student1.role.name, student1.role)
          controller.send(:action_allowed?).should be false
        end
      end
    end

    context 'when params action is remove an instructor' do
      before(:each) do
        controller.params = { action: 'remove_instructor' }
      end

      context 'when the role of current user is Admin' do
        it 'allows certain action' do
          stub_current_user(admin1, admin1.role.name, admin1.role)
          controller.send(:action_allowed?).should be true
        end
      end

      context 'when the role of current user is Super-Admin' do
        it 'allows certain action' do
          stub_current_user(super_admin, super_admin.role.name, super_admin.role)
          controller.send(:action_allowed?).should be true
        end
      end

      context 'when the role of current user is Instructor' do
        it 'refuses certain action' do
          stub_current_user(instructor1, instructor1.role.name, instructor1.role)
          controller.send(:action_allowed?).should be false
        end
      end

      context 'when the role of current user is Student' do
        it 'refuses certain action' do
          stub_current_user(student1, student1.role.name, student1.role)
          controller.send(:action_allowed?).should be false
        end
      end
    end

    context 'when params action is other than list and remove instructors' do
      before(:each) do
        controller.params = { action: 'remove_administrator' }
      end

      context 'when the role of current user is Admin' do
        it 'refuses certain action' do
          stub_current_user(admin1, admin1.role.name, admin1.role)
          controller.send(:action_allowed?).should be false
        end
      end

      context 'when the role of current user is Super-Admin' do
        it 'allows certain action' do
          stub_current_user(super_admin, super_admin.role.name, super_admin.role)
          controller.send(:action_allowed?).should be true
        end
      end

      context 'when the role of current user is Instructor' do
        it 'refuses certain action' do
          stub_current_user(instructor1, instructor1.role.name, instructor1.role)
          controller.send(:action_allowed?).should be false
        end
      end

      context 'when the role of current user is Student' do
        it 'refuses certain action' do
          stub_current_user(student1, student1.role.name, student1.role)
          controller.send(:action_allowed?).should be false
        end
      end
    end
  end

  context '#list_super_administrators' do
    it 'lists all the Super-Administrators' do
      stub_current_user(super_admin, super_admin.role.name, super_admin.role)
      get :list_super_administrators
      expect(assigns(:users)).to eq([super_admin])
    end
  end

  context '#show_super_administrator' do
    it 'find selected Super-Administrator and render #show' do
      stub_current_user(super_admin, super_admin.role.name, super_admin.role)
      request_params = { id: '1' }
      get :show_super_administrator, params: request_params
      expect(assigns(:user)).to eq(super_admin)
      expect(assigns(:role)).to eq(super_admin.role)
      expect(response).to render_template(:show_super_administrator)
    end
  end

  context '#list_administrators' do
    it 'lists all the admins' do
      stub_current_user(super_admin, super_admin.role.name, super_admin.role)
      request_params = { page: '1' }
      get :list_administrators, params: request_params
      expect(assigns(:users)).to eq(admin_list)
    end
  end

  context '#show_administrator' do
    it 'find selected admin and render #show' do
      stub_current_user(super_admin, super_admin.role.name, super_admin.role)
      request_params = { id: '3' }
      get :show_administrator, params: request_params
      expect(assigns(:user)).to eq(admin1)
      expect(assigns(:role)).to eq(admin1.role)
      expect(response).to render_template(:show_administrator)
    end
  end

  context '#list_instructors' do
    it 'lists all the instructors' do
      stub_current_user(admin1, admin1.role.name, admin1.role)
      request_params = { page: '1' }
      get :list_instructors, params: request_params
      expect(assigns(:users)).to eq(instructor_list_pid3)
    end
  end

  context '#show_instructor' do
    it 'find selected instructor and render #show' do
      stub_current_user(super_admin, super_admin.role.name, super_admin.role)
      request_params = { id: '10' }
      get :show_instructor, params: request_params
      expect(assigns(:user)).to eq(instructor1)
      expect(assigns(:role)).to eq(instructor1.role)
      expect(response).to render_template(:show_instructor)
    end
  end
end
