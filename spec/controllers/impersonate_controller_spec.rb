describe ImpersonateController do
  let(:instructor) { build(:instructor, id: 2) }
  let(:student1) { build(:student, id: 30, name: :Amanda) }
  let(:student2) { build(:student, id: 40, name: :Brian) }

  # impersonate is mostly used by instructors
  # run all tests using instructor account
  # except some exceptions where we'll use other accounts
  before(:each) do
    stub_current_user(instructor, instructor.role.name, instructor.role)
  end

  context '#impersonate' do
    it 'when instructor tries to impersonate another user' do
      expect(controller.action_allowed?).to be true
    end

    it 'when student tries to impersonate another user' do
      stub_current_user(student1, student1.role.name, student1.role)
      expect(controller.action_allowed?).to be false
    end

    it 'redirects to back' do
      allow(User).to receive(:find_by).with(name: student1.name).and_return(student1)
      request.env['HTTP_REFERER'] = 'http://www.example.com'
      @params = { user: { name: student1.name } }
      get :impersonate, params: @params
      expect(response).to redirect_to('http://www.example.com')
    end

    it 'instructor should be able to impersonate a user with their real name' do
      allow(User).to receive(:find_by).with(name: student1.name).and_return(student1)
      allow(instructor).to receive(:can_impersonate?).with(student1).and_return(true)
      request.env['HTTP_REFERER'] = 'http://www.example.com'
      @params = { user: { name: student1.name } }
      @session = { user: instructor }
      post :impersonate, params: @params, session: @session
      expect(session[:super_user]).to eq instructor
      expect(session[:user]).to eq student1
      expect(session[:original_user]).to eq instructor
      expect(session[:impersonate]).to be true
    end

    it 'instructor redirects to student home page after impersonating a student' do
      allow(User).to receive(:find_by).with(name: student1.name).and_return(student1)
      allow(instructor).to receive(:can_impersonate?).with(student1).and_return(true)
      request.env['HTTP_REFERER'] = 'http://www.example.com'
      @params = { user: { name: student1.name } }
      @session = { user: instructor }
      post :impersonate, params: @params, session: @session
      expect(response).to redirect_to('/tree_display/drill')
    end

    it 'instructor should be able to impersonate a user with their anonymized name' do
      allow(User).to receive(:find_by).with(name: student1.name).and_return(student1)
      allow(instructor).to receive(:can_impersonate?).with(student1).and_return(true)
      allow(User).to receive(:anonymized_view?).and_return(true)
      allow(User).to receive(:real_user_from_anonymized_name).with('Student30').and_return(student1)
      request.env['HTTP_REFERER'] = 'http://www.example.com'
      @params = { user: { name: 'Student30' } }
      @session = { user: instructor }
      post :impersonate, params: @params, session: @session
      expect(session[:super_user]).to eq instructor
      expect(session[:user]).to eq student1
      expect(session[:original_user]).to eq instructor
      expect(session[:impersonate]).to be true
    end

    it 'instructor should be able to impersonate a user while already impersonating a user' do
      allow(User).to receive(:find_by).with(name: student1.name).and_return(student1)
      allow(User).to receive(:find_by).with(name: student2.name).and_return(student2)
      allow(instructor).to receive(:can_impersonate?).with(student1).and_return(true)
      allow(instructor).to receive(:can_impersonate?).with(student2).and_return(true)
      request.env['HTTP_REFERER'] = 'http://www.example.com'
      @params = { user: { name: student1.name } }
      @session = { user: instructor }
      post :impersonate, params: @params, session: @session
      @params = { user: { name: student2.name } }
      post :impersonate, params: @params, session: @session
      expect(session[:super_user]).to eq instructor
      expect(session[:user]).to eq student2
      expect(session[:original_user]).to eq instructor
      expect(session[:impersonate]).to be true
    end

    it 'instructor should be able to impersonate a user while already impersonating a user but from nav bar' do
      allow(User).to receive(:find_by).with(name: student1.name).and_return(student1)
      allow(User).to receive(:find_by).with(name: student2.name).and_return(student2)
      allow(instructor).to receive(:can_impersonate?).with(student1).and_return(true)
      allow(instructor).to receive(:can_impersonate?).with(student2).and_return(true)
      request.env['HTTP_REFERER'] = 'http://www.example.com'
      @params = { user: { name: student1.name } }
      @session = { user: instructor }
      post :impersonate, params: @params, session: @session
      # nav bar uses the :impersonate as the param name, so let make sure it always works from there too.
      @params = { impersonate: { name: student2.name } }
      post :impersonate, params: @params, session: @session
      expect(session[:super_user]).to eq instructor
      expect(session[:user]).to eq student2
      expect(session[:original_user]).to eq instructor
      expect(session[:impersonate]).to be true
    end
  end
end
