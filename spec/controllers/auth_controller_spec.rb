describe AuthController do
  let(:admin) { build(:admin) }
  let(:instructor) { build(:instructor, id: 6) }
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
  	context 'when the action desired is google login' do
  	  it 'returns true' do
  	  	controller.params = { action: 'google_login' }
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
  	  	params = {login: {name: 'jwbumga2'}}
  	  	allow(User).to receive(:find_by_login).and_return(nil)
  	  	post :login, params
  	  	expect(response).to redirect_to('/password_retrieval/forgotten')
  	  end
  	end
  	context 'when the user is found and the password is correct' do
  	  it 'calls after login' do
  	  	params = {login: {name: 'jwbumga2', password: 'password'}}
  	  	allow(instructor).to receive(:valid_password?).with('password').and_return(true)
  	  	allow(User).to receive(:find_by_login).and_return(instructor)
  	  	expect(controller).to receive(:after_login)
  	  	post :login, params	
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
end