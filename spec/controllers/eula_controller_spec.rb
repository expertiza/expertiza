describe EulaController do
  let(:instructor) { build(:instructor, id: 6) }
  let(:student) { build(:student) }
  
  describe '#action_allowed?' do
    context 'when current user is student' do
      # first test to make sure student cannot do all actions
      it 'allows all actions' do
        expect(controller.send(:action_allowed?)).to be false
      end
      # then test to make sure student can do accept and decline actions
      it 'allows accept action' do
        controller.params = {action: 'accept'}
        user = student
        stub_current_user(user, user.role.name, user.role)
        expect(controller.send(:action_allowed?)).to be true
      end
      it 'allows decline action' do
        controller.params = {action: 'decline'}
        user = student
        stub_current_user(user, user.role.name, user.role)
        expect(controller.send(:action_allowed?)).to be true
      end
    end
    # make sure action_allowed is only available for those with student privileges
    context 'when current user is anything besides student' do
      it 'allows all actions' do
        user = instructor
        stub_current_user(user, user.role.name, user.role)
        expect(controller.send(:action_allowed?)).to be true
      end
    end
  end
  
  describe '#display' do
    # check it displays current page
    it 'displays current page' do
      expect(response.status).to eq(200)
    end
  end

  describe '#accept' do
    # test if the is_new_user attribute is updated
    it 'updates is_new_user attribute' do
      params = {id: 1}
      session = {user: student}
      get :accept, params: params, session: session
      expect(session[:user].is_new_user).to eq(false)
    end
    it 'accept redirects to student_task/list' do      
      params = {id: 1}
      session = {user: student}
      post :accept, params: params, session: session
      expect(response).to redirect_to('/student_task/list')
    end
  end

  describe '#decline' do
    # test if the message is displayed before redirect
    it 'displays the flash notice' do
      params = {id: 1}
      session = {user: student}
      get :decline, params: params, session: session
      expect(flash[:notice]).to eq 'Please accept the license agreement in order to use the system.'
    end
    # test if it shows the same page again
    it 'redirects to display same page' do
      params = {id: 1}
      session = {user: student}
      get :decline, params: params, session: session
      expect(response).to redirect_to('/eula/display')
    end
  end
end
