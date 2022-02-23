describe AuthController do
  let(:admin) { build(:admin) }
  let(:instructor) { build(:instructor, id: 6) }
  let(:instructor_role) { build(:role_of_instructor, id: 2, name: 'Instructor_role_test', description: '', parent_id: nil, default_page_id: nil) }
  describe '#action_allowed?' do
    before(:each) do
      stub_current_user(admin, admin.role.name, admin.role)
    end
    context 'when the action desired is login' do
      it 'returns true' do
        controller.params = { action: 'login' }
        expect(controller.send(:action_allowed?)).to be_truthy
      end
    end
    context 'when the action desired is logout' do
      it 'returns true' do
        controller.params = { action: 'logout' }
        expect(controller.send(:action_allowed?)).to be_truthy
      end
    end
    context 'when the action desired is login failed' do
      it 'returns true' do
        controller.params = { action: 'login_failed' }
        expect(controller.send(:action_allowed?)).to be_truthy
      end
    end
    context 'when the action desired is other' do
      it 'returns false' do
        controller.params = { action: 'other' }
        expect(controller.send(:action_allowed?)).to be_falsey
      end
    end
  end
  describe '#login' do
    context 'when the login attempt is done as part of a GET request' do
      it 'clears the session' do
        expect(AuthController).to receive(:clear_session)
        get :login
      end
    end
    context 'when the user cannot be found' do
      it 'redirects to the password retrieval page' do
        request_params = { login: { name: 'jwbumga2' } }
        allow(User).to receive(:find_by_login).and_return(nil)
        post :login, params: request_params
        expect(response).to redirect_to('/password_retrieval/forgotten')
      end
    end
    context 'when the user is found and the password is correct' do
      it 'calls after login' do
        request_params = { login: { name: 'jwbumga2', password: 'password' } }
        allow(instructor).to receive(:valid_password?).with('password').and_return(true)
        allow(User).to receive(:find_by_login).and_return(instructor)
        expect(controller).to receive(:after_login)
        post :login, params: request_params
      end
    end
  end
  describe '#after_login' do
    it 'calls set current role and redirects to home controller' do
      allow(controller).to receive(:redirect_to)
      expect(AuthController).to receive(:set_current_role)
      controller.after_login(instructor)
    end
  end
  describe '#logout' do
    it 'calls logout and redirects to root' do
      expect(controller).to receive(:logout)
      get :logout
    end
  end
  describe '#self.logout' do
    it 'calls clear_session' do
      session = { user: instructor }
      expect(AuthController).to receive(:clear_session).with(session)
      AuthController.logout(session)
    end
  end
  describe '#self.set_current_role' do
    context 'when the role is found' do
      it 'sets the session for the role' do
        allow(Role).to receive(:find).and_return(instructor_role)
        expect(ExpertizaLogger).to receive(:info)
        AuthController.set_current_role(2, {})
      end
    end
    context 'when the role is not found' do
      it 'throws an error' do
        allow(Role).to receive(:find).and_return(nil)
        expect(ExpertizaLogger).to receive(:error)
        AuthController.set_current_role(2, {})
      end
    end
  end
  describe '#self.clear_session' do
    it 'returns nil and clears session hash' do
      session = { user: instructor }
      expect(AuthController.clear_session(session)).to be_nil
      expect(session[:clear]).to be_truthy
    end
  end
  describe '#self.clear_user_info' do
    it 'returns nil and clears session hash' do
      session = { user: instructor }
      allow(Role).to receive(:student).and_return(instructor_role)
      expect(AuthController.clear_user_info(session, 1)).to be_nil
      expect(session[:clear]).to be_truthy
    end
  end
end
