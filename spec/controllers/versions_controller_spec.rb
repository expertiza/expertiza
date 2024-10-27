describe VersionsController do
  let(:admin) { build(:admin, id: 3) }
  let(:instructor) { build(:instructor, id: 2) }
  let(:student) { build_stubbed(:student, id: 1, username: 'student') }
  let(:super_admin) { build(:superadmin, id: 1, role_id: 5) }
  let(:version) { build(:version) }

  describe '#action_allowed?' do
    context 'when user does not have right privilege, it denies action' do
      it 'for no user' do
        expect(controller.send(:action_allowed?)).to be false
      end
      it 'for student' do
        allow(controller).to receive(:current_user).and_return(build(:student))
        expect(controller.send(:action_allowed?)).to be false
      end
      it 'for instructor' do
        stub_current_user(instructor, instructor.role.name, instructor.role)
        expect(controller.send(:action_allowed?)).to be false
      end
    end
    context 'when user has right privilege, it allows action' do
      it 'for admin' do
        stub_current_user(admin, admin.role.name, admin.role)
        expect(controller.send(:action_allowed?)).to be true
      end
      it 'for super_admin' do
        stub_current_user(super_admin, super_admin.role.name, super_admin.role)
        expect(controller.send(:action_allowed?)).to be true
      end

    end
  end

  describe 'GET /index' do
    it 'redirect to search' do
      stub_current_user(admin, admin.role.name, admin.role)
      get 'index'
      expect(response).to redirect_to('/versions/search')
    end
  end

  describe 'GET /show' do
    it 'render show' do
      stub_current_user(admin, admin.role.name, admin.role)
      allow(Version).to receive(:find).with('1').and_return(version)
      get 'show', params: {id: 1}
      expect(response).to render_template('show')
    end

  end

  describe 'GET /search' do
    it 'returns http success' do
      stub_current_user(admin, admin.role.name, admin.role)
      params = { id: 3 }
      get 'search', params: params
      expect(response).to be_success
    end
    it 'should render search template' do
      stub_current_user(admin, admin.role.name, admin.role)
      get 'search'
      expect(response).to render_template('search')
    end
  end

end
