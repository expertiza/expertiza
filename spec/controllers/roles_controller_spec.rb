describe RolesController do
  let(:super_admin) { build(:superadmin, id: 1, role_id: 5) }
  let(:student) { build(:student, id: 1, role_id: 1) }
  let(:student_role) { build(:role_of_student, id: 1, name: 'Student_role_test', description: '', parent_id: nil, default_page_id: nil) }
  let(:instructor_role) { build(:role_of_instructor, id: 2, name: 'Instructor_role_test', description: '', parent_id: nil, default_page_id: nil) }
  let(:admin_role) { build(:role_of_administrator, id: 3, name: 'Administrator_role_test', description: '', parent_id: nil, default_page_id: nil) }
  describe '#action_allowed?' do
    context 'when the current user is student' do
      it 'returns false' do
        stub_current_user(student, student.role.name, student.role)
        expect(controller.send(:action_allowed?)).to be_falsey
      end
    end
    context 'when the current user is Super-Admin' do
      it 'returns false' do
        stub_current_user(super_admin, super_admin.role.name, super_admin.role)
        expect(controller.send(:action_allowed?)).to be_truthy
      end
    end
  end
  before(:each) do
    stub_current_user(super_admin, super_admin.role.name, super_admin.role)
  end
  describe '#index' do
    it 'returns the Roles ordered by name' do
      allow(Role).to receive(:order).with(:name).and_return([admin_role, instructor_role, student_role])
      roles = controller.send(:index)
      expect(roles[0]).to eq(admin_role)
      expect(roles[1]).to eq(instructor_role)
      expect(roles[2]).to eq(student_role)
    end
  end
  describe '#list' do
    it 'redirects to /roles' do
      get :list
      expect(response).to redirect_to('/roles')
    end
  end
  describe '#show' do
    it 'renders show' do
      request_params = { id: '1' }
      allow(Role).to receive(:find).with('1').and_return(student_role)
      allow(student_role).to receive(:get_parents).and_return([])
      get :show, params: request_params
      expect(response).to render_template(:show)
    end
  end
  describe '#new' do
    it 'renders new' do
      get :new
      expect(response).to render_template(:new)
    end
  end
  describe '#create' do
    context 'when the role is saved successfully' do
      it 'redirects to list' do
        allow(Role).to receive(:new).and_return(student_role)
        allow(student_role).to receive(:save).and_return(true)
        post :create
        expect(response).to redirect_to('/roles')
      end
    end
    context 'when the role is saved unsuccessfully' do
      it 'redirects to new' do
        allow(Role).to receive(:new).and_return(student_role)
        allow(student_role).to receive(:save).and_return(false)
        post :create
        expect(response).to render_template(:new)
      end
    end
  end
  describe '#edit' do
    it 'renders edit' do
      request_params = { id: '1' }
      allow(Role).to receive(:find).with('1').and_return(student_role)
      get :edit, params: request_params
      expect(response).to render_template(:edit)
    end
  end
  describe '#update' do
    context 'when the role is updated successfully' do
      it 'redirects to show' do
        allow(Role).to receive(:find).and_return(student_role)
        allow(student_role).to receive(:update_with_params).and_return(true)
        post :update
        expect(response).to redirect_to('/roles/1')
      end
    end
    context 'when the role is updated unsuccessfully' do
      it 'redirects to edit' do
        allow(Role).to receive(:find).and_return(student_role)
        allow(student_role).to receive(:save).and_return(false)
        post :update
        expect(response).to render_template(:edit)
      end
    end
  end
  describe '#destroy' do
    it 'calls destroy on student role' do
      allow(Role).to receive(:find).and_return(student_role)
      expect(student_role).to receive(:destroy)
      post :destroy
      expect(response).to redirect_to('/roles')
    end
  end
  describe '#foreign' do
    it 'returns users associated with role' do
      controller.instance_variable_set(:@role, student_role)
      allow(student_role).to receive(:users).and_return([student])
      expect(controller.foreign).to eq([student])
    end
  end
end
