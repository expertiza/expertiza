describe ImpersonateController do
  let(:instructor) { build(:instructor, id: 2) }
  let(:student1) { build(:student, id: 30, username: :Amanda) }
  let(:student2) { build(:student, id: 40, username: :Brian) }
  let(:admin) { build(:admin, id: 3, username: :Admin) }
  let(:super_admin) { build(:superadmin, id: 5, username: :Superadmin) }

  let(:teaching_assistant) { build(:teaching_assistant, id: 6, username: :Teaching_Assistant) }
  # impersonate is mostly used by instructors
  # run all tests using instructor account
  # except some exceptions where we'll use other accounts
  before(:each) do
    stub_current_user(instructor, instructor.role.name, instructor.role)
  end

  context '#impersonate' do
    it 'when input is blank' do
      request.env['HTTP_REFERER'] = 'http://www.example.com'
      @params = { user: { username: '' } }
      get :impersonate, params: @params
      expect(response).to redirect_to('http://www.example.com')
    end

    it 'when instructor tries to impersonate another user' do
      expect(controller.action_allowed?).to be true
    end

    it 'when student tries to impersonate another user' do
      stub_current_user(student1, student1.role.name, student1.role)
      expect(controller.action_allowed?).to be false
    end

    it 'redirects to back' do
      allow(User).to receive(:find_by).with(username: student1.username).and_return(student1)
      request.env['HTTP_REFERER'] = 'http://www.example.com'
      @params = { user: { username: student1.username } }
      get :impersonate, params: @params
      expect(response).to redirect_to('http://www.example.com')
    end

    it 'instructor should be able to impersonate a user with their real name' do
      allow(User).to receive(:find_by).with(username: student1.username).and_return(student1)
      allow(instructor).to receive(:can_impersonate?).with(student1).and_return(true)
      request.env['HTTP_REFERER'] = 'http://www.example.com'
      @params = { user: { username: student1.username } }
      @session = { user: instructor }
      post :impersonate, params: @params, session: @session
      expect(session[:super_user]).to eq instructor
      expect(session[:user]).to eq student1
      expect(session[:original_user]).to eq instructor
      expect(session[:impersonate]).to be true
    end

    it 'instructor should not be able to impersonate a super admin user with their real name' do
      allow(User).to receive(:find_by).with(username: super_admin.username).and_return(super_admin)
      allow(instructor).to receive(:can_impersonate?).with(super_admin).and_return(false)
      request.env['HTTP_REFERER'] = 'http://www.example.com'
      @params = { user: { username: super_admin.username } }
      @session = { user: instructor }
      post :impersonate, params: @params, session: @session
      expect(session[:impersonate]).to be nil
    end

    it 'instructor should not be able to impersonate an admin user with their real name' do
      allow(User).to receive(:find_by).with(username: admin.username).and_return(admin)
      allow(instructor).to receive(:can_impersonate?).with(admin).and_return(false)
      request.env['HTTP_REFERER'] = 'http://www.example.com'
      @params = { user: { username: admin.username } }
      @session = { user: instructor }
      post :impersonate, params: @params, session: @session
      expect(session[:impersonate]).to be nil
    end

    it 'instructor should be able to impersonate a teaching assistant user with their real name' do
      allow(User).to receive(:find_by).with(username: teaching_assistant.username).and_return(teaching_assistant)
      allow(instructor).to receive(:can_impersonate?).with(teaching_assistant).and_return(true)
      request.env['HTTP_REFERER'] = 'http://www.example.com'
      @params = { user: { username: teaching_assistant.username } }
      @session = { user: instructor }
      post :impersonate, params: @params, session: @session
      expect(session[:super_user]).to eq instructor
      expect(session[:user]).to eq teaching_assistant
      expect(session[:original_user]).to eq instructor
      expect(session[:impersonate]).to be true
    end

    it 'teaching assistant should be able to impersonate a student with their real name' do
      stub_current_user(teaching_assistant, teaching_assistant.role.name, teaching_assistant.role)
      allow(User).to receive(:find_by).with(username: student1.username).and_return(student1)
      allow(teaching_assistant).to receive(:can_impersonate?).with(student1).and_return(true)
      request.env['HTTP_REFERER'] = 'http://www.example.com'
      @params = { user: { username: student1.username } }
      @session = { user: teaching_assistant }
      post :impersonate, params: @params, session: @session
      expect(session[:super_user]).to eq teaching_assistant
      expect(session[:user]).to eq student1
      expect(session[:original_user]).to eq teaching_assistant
      expect(session[:impersonate]).to be true
    end

    it 'teaching assistant should not be able to impersonate an instructor with their real name' do
      stub_current_user(teaching_assistant, teaching_assistant.role.name, teaching_assistant.role)
      allow(User).to receive(:find_by).with(username: instructor.username).and_return(instructor)
      allow(teaching_assistant).to receive(:can_impersonate?).with(instructor).and_return(false)
      request.env['HTTP_REFERER'] = 'http://www.example.com'
      @params = { user: { username: instructor.username } }
      @session = { user: teaching_assistant }
      post :impersonate, params: @params, session: @session
      expect(session[:impersonate]).to be nil
    end

    it 'teaching assistant should not be able to impersonate an admin with their real name' do
      stub_current_user(teaching_assistant, teaching_assistant.role.name, teaching_assistant.role)
      allow(User).to receive(:find_by).with(username: admin.username).and_return(admin)
      allow(teaching_assistant).to receive(:can_impersonate?).with(admin).and_return(false)
      request.env['HTTP_REFERER'] = 'http://www.example.com'
      @params = { user: { username: admin.username } }
      @session = { user: teaching_assistant }
      post :impersonate, params: @params, session: @session
      expect(session[:impersonate]).to be nil
    end

    it 'teaching assistant should not be able to impersonate an super admin with their real name' do
      stub_current_user(teaching_assistant, teaching_assistant.role.name, teaching_assistant.role)
      allow(User).to receive(:find_by).with(username: super_admin.username).and_return(super_admin)
      allow(teaching_assistant).to receive(:can_impersonate?).with(super_admin).and_return(false)
      request.env['HTTP_REFERER'] = 'http://www.example.com'
      @params = { user: { username: super_admin.username } }
      @session = { user: teaching_assistant }
      post :impersonate, params: @params, session: @session
      expect(session[:impersonate]).to be nil
    end

    it 'admin should be able to impersonate a student with their real name' do
      stub_current_user(admin, admin.role.name, admin.role)       
      allow(User).to receive(:find_by).with(username: student1.username).and_return(student1)
      allow(admin).to receive(:can_impersonate?).with(student1).and_return(true)
      request.env['HTTP_REFERER'] = 'http://www.example.com'
      @params = { user: { username: student1.username } }
      @session = { user: admin }
      post :impersonate, params: @params, session: @session
      expect(session[:super_user]).to eq admin
      expect(session[:user]).to eq student1
      expect(session[:original_user]).to eq admin
      expect(session[:impersonate]).to be true
    end

    it 'admin should be able to impersonate a teaching assistant with their real name' do
      stub_current_user(admin, admin.role.name, admin.role)
      allow(User).to receive(:find_by).with(username: teaching_assistant.username).and_return(teaching_assistant)
      allow(admin).to receive(:can_impersonate?).with(teaching_assistant).and_return(true)
      request.env['HTTP_REFERER'] = 'http://www.example.com'
      @params = { user: { username: teaching_assistant.username } }
      @session = { user: admin }
      post :impersonate, params: @params, session: @session
      expect(session[:super_user]).to eq admin
      expect(session[:user]).to eq teaching_assistant
      expect(session[:original_user]).to eq admin
      expect(session[:impersonate]).to be true
    end

    it 'admin should be able to impersonate an instructor with their real name' do
      stub_current_user(admin, admin.role.name, admin.role)
      allow(User).to receive(:find_by).with(username: instructor.username).and_return(instructor)
      allow(admin).to receive(:can_impersonate?).with(instructor).and_return(true)
      request.env['HTTP_REFERER'] = 'http://www.example.com'
      @params = { user: { username: instructor.username } }
      @session = { user: admin }
      post :impersonate, params: @params, session: @session
      expect(session[:super_user]).to eq admin
      expect(session[:user]).to eq instructor
      expect(session[:original_user]).to eq admin
      expect(session[:impersonate]).to be true
    end

    it 'admin should not be able to impersonate a super admin with their real name' do
      stub_current_user(admin, admin.role.name, admin.role)
      allow(User).to receive(:find_by).with(username: super_admin.username).and_return(super_admin)
      allow(admin).to receive(:can_impersonate?).with(super_admin).and_return(false)
      request.env['HTTP_REFERER'] = 'http://www.example.com'
      @params = { user: { username: super_admin.username } }
      @session = { user: admin }
      post :impersonate, params: @params, session: @session
      expect(session[:impersonate]).to be nil
    end

    it 'super admin should be able to impersonate a student with their real name' do
      stub_current_user(super_admin, super_admin.role.name, super_admin.role)       
      allow(User).to receive(:find_by).with(username: student1.username).and_return(student1)
      allow(super_admin).to receive(:can_impersonate?).with(student1).and_return(true)
      request.env['HTTP_REFERER'] = 'http://www.example.com'
      @params = { user: { username: student1.username } }
      @session = { user: super_admin }
      post :impersonate, params: @params, session: @session
      expect(session[:super_user]).to eq super_admin
      expect(session[:user]).to eq student1
      expect(session[:original_user]).to eq super_admin
      expect(session[:impersonate]).to be true
    end

    it 'super admin should be able to impersonate a teaching assistant with their real name' do
      stub_current_user(super_admin, super_admin.role.name, super_admin.role)
      allow(User).to receive(:find_by).with(username: teaching_assistant.username).and_return(teaching_assistant)
      allow(super_admin).to receive(:can_impersonate?).with(teaching_assistant).and_return(true)
      request.env['HTTP_REFERER'] = 'http://www.example.com'
      @params = { user: { username: teaching_assistant.username } }
      @session = { user: super_admin }
      post :impersonate, params: @params, session: @session
      expect(session[:super_user]).to eq super_admin
      expect(session[:user]).to eq teaching_assistant
      expect(session[:original_user]).to eq super_admin
      expect(session[:impersonate]).to be true
    end

    it 'super admin should be able to impersonate an instructor with their real name' do
      stub_current_user(super_admin, super_admin.role.name, super_admin.role)
      allow(User).to receive(:find_by).with(username: instructor.username).and_return(instructor)
      allow(super_admin).to receive(:can_impersonate?).with(instructor).and_return(true)
      request.env['HTTP_REFERER'] = 'http://www.example.com'
      @params = { user: { username: instructor.username } }
      @session = { user: super_admin }
      post :impersonate, params: @params, session: @session
      expect(session[:super_user]).to eq super_admin
      expect(session[:user]).to eq instructor
      expect(session[:original_user]).to eq super_admin
      expect(session[:impersonate]).to be true
    end

    it 'super admin should be able to impersonate an admin with their real name' do
      stub_current_user(super_admin, super_admin.role.name, super_admin.role)
      allow(User).to receive(:find_by).with(username: admin.username).and_return(admin)
      allow(super_admin).to receive(:can_impersonate?).with(admin).and_return(true)
      request.env['HTTP_REFERER'] = 'http://www.example.com'
      @params = { user: { username: admin.username } }
      @session = { user: super_admin }
      post :impersonate, params: @params, session: @session
      expect(session[:super_user]).to eq super_admin
      expect(session[:user]).to eq admin
      expect(session[:original_user]).to eq super_admin
      expect(session[:impersonate]).to be true
    end

    it 'instructor redirects to student home page after impersonating a student' do
      allow(User).to receive(:find_by).with(username: student1.username).and_return(student1)
      allow(instructor).to receive(:can_impersonate?).with(student1).and_return(true)
      request.env['HTTP_REFERER'] = 'http://www.example.com'
      @params = { user: { username: student1.username } }
      @session = { user: instructor }
      post :impersonate, params: @params, session: @session
      expect(response).to redirect_to('/tree_display/drill')
    end

    it 'instructor should be able to impersonate a user with their anonymized name' do
      allow(User).to receive(:find_by).with(username: student1.username).and_return(student1)
      allow(instructor).to receive(:can_impersonate?).with(student1).and_return(true)
      allow(User).to receive(:anonymized_view?).and_return(true)
      allow(User).to receive(:real_user_from_anonymized_username).with('Student30').and_return(student1)
      request.env['HTTP_REFERER'] = 'http://www.example.com'
      @params = { user: { username: 'Student30' } }
      @session = { user: instructor }
      post :impersonate, params: @params, session: @session
      expect(session[:super_user]).to eq instructor
      expect(session[:user]).to eq student1
      expect(session[:original_user]).to eq instructor
      expect(session[:impersonate]).to be true
    end

    it 'instructor should be able to impersonate a user while already impersonating a user' do
      allow(User).to receive(:find_by).with(username: student1.username).and_return(student1)
      allow(User).to receive(:find_by).with(username: student2.username).and_return(student2)
      allow(instructor).to receive(:can_impersonate?).with(student1).and_return(true)
      allow(instructor).to receive(:can_impersonate?).with(student2).and_return(true)
      request.env['HTTP_REFERER'] = 'http://www.example.com'
      @params = { user: { username: student1.username } }
      @session = { user: instructor }
      post :impersonate, params: @params, session: @session
      @params = { user: { username: student2.username } }
      post :impersonate, params: @params, session: @session
      expect(session[:super_user]).to eq instructor
      expect(session[:user]).to eq student2
      expect(session[:original_user]).to eq instructor
      expect(session[:impersonate]).to be true
    end

    it 'instructor should be able to impersonate a user while already impersonating a user but from nav bar' do
      allow(User).to receive(:find_by).with(username: student1.username).and_return(student1)
      allow(User).to receive(:find_by).with(username: student2.username).and_return(student2)
      allow(instructor).to receive(:can_impersonate?).with(student1).and_return(true)
      allow(instructor).to receive(:can_impersonate?).with(student2).and_return(true)
      request.env['HTTP_REFERER'] = 'http://www.example.com'
      @params = { user: { username: student1.username } }
      @session = { user: instructor }
      post :impersonate, params: @params, session: @session
      # nav bar uses the :impersonate as the param name, so let make sure it always works from there too.
      @params = { impersonate: { username: student2.username } }
      post :impersonate, params: @params, session: @session
      expect(session[:super_user]).to eq instructor
      expect(session[:user]).to eq student2
      expect(session[:original_user]).to eq instructor
      expect(session[:impersonate]).to be true
    end
  end
end
