describe UsersController do
  let(:admin) { build(:admin, id: 3) }
  let(:super_admin) {build (:superadmin)}
  let(:instructor) { build(:instructor, id: 2) }
  let(:student1) { build(:student, id: 1, name: :lily) }
  let(:student2) { build(:student) }
  let(:student3) { build(:student, id: 10, role_id: 1, parent_id: nil) }
  let(:student4) { build(:student, id: 20, role_id: 4) }
  let(:student5) { build(:student, role_id: 4, parent_id: 3) }
  let(:student6) { build(:student, role_id: nil, name: :lilith)}

  let(:institution1) {build(:institution, id: 1)}
  let(:requested_user1) {RequestedUser.new id: 4, name: 'requester1', role_id: 2, fullname: 're, requester1', 
    institution_id: 1, email: 'requester1@test.com', status: nil, self_introduction: 'no one'}
  let(:superadmin) {build(:superadmin)}
  let(:assignment) {build(:assignment, id: 1, name: "test_assignment", instructor_id: 2, 
    participants: [build(:participant, id: 1, user_id: 1, assignment: assignment)], course_id: 1)}
  before(:each) do
    stub_current_user(instructor, instructor.role.name, instructor.role)
  end

  context '#index' do
    it 'redirects if user is student' do
      stub_current_user(student3, student3.role.name, student3.role)
      allow(controller).to receive(:current_user_role?).and_return("Student")
      get :index
      expect(response).to redirect_to('/tree_display/drill')
    end

    it 'renders list if user is instructor' do
      allow(instructor).to receive(:get_user_list).and_return(student1)
      @params = {}
      session = {user: instructor}
      get :index, @params, session
      expect(controller.instance_variable_get(:@users)).to equal(student1)
      expect(response).to render_template(:list)
    end
  end

  context '#set_anonymized_view' do
    it 'redirects to back' do
      request.env["HTTP_REFERER"] = "http://www.example.com"
      @params = {}
      session = {user: instructor}
      get :set_anonymized_view, params: @params, session: session
      expect(response).to redirect_to("http://www.example.com")
    end
  end

  context "#list_pending_requested" do
    it 'test list_pednign_requested view' do
      stub_current_user(super_admin, super_admin.role.name, super_admin.role)
      get :list_pending_requested
      expect(response).to render_template(:list_pending_requested)
    end
  end

  context "#show_selection" do
    before(:each) do
      allow(User).to receive(:find).with(2).and_return(instructor)
    end
    it 'user is nil' do
      allow(User).to receive(:find_by).with(name: 'instructor6').and_return(nil)
      session = {user: admin}
      params = {
        user: {name: 'instructor6'}
      }
      post :show_selection, params, session
      expect(response).to redirect_to('http://test.host/users/list')
    end

    it 'user is not nil and user is available for editing' do
      allow(User).to receive(:find_by).with(name: 'instructor6').and_return(student3)
      session = {user: student4}
      params = {
        user: {name: 'instructor6'}
      }
      get :show_selection, params
      expect(response).to render_template(:show)
    end

    it 'user is not nil but is not available for editing' do
      allow(User).to receive(:find_by).with(name: 'instructor6').and_return(student4)
      allow(Role).to receive(:find).with(4).and_return(student5)
      session = {user: student3}
      params = {
        user: {name: 'instructor6'}
      }
      post :show_selection, params, session
      expect(response).to redirect_to('http://test.host/users/list')
    end
  end

  context '#show' do
    it 'when params[:id] is not nil' do
      allow(controller).to receive(:current_user).and_return(student1)
      allow(User).to receive(:find).with('1').and_return(student1)
      @params = {id: 1}
      session = {user: student1}
      get :show, @params, session
      expect(response).to render_template(:show)
    end

    it 'when params[:id] is not nil but role_id is nil' do
      allow(controller).to receive(:current_user).and_return(student6)
      allow(User).to receive(:find).with('6').and_return(student6)
      @params = {id: 6}
      session = {user: student6}
      get :show, @params, session
      expect(response).to render_template(:show)
    end

    it 'when params[:id] is nil' do
      @params = {id: nil}
      get :show, @params
      expect(response).to redirect_to('/tree_display/drill')
    end
  end

  context "#new" do
    it '1' do
      allow(Role).to receive(:find_by).with(name: 'instructor').and_return('instructor')
      params = {role: 'instructor'}
      session = {user: instructor}
      get :new, params, session
      expect(response).to render_template(:new)
    end
  end

  context "#request new" do
    it '1' do
      allow(Role).to receive(:find_by).with(name: 'instructor').and_return('instructor')
      params = {role: 'instructor'}
      post :request_new, params
      expect(response).to render_template(:request_new)
    end
  end

  context "#create" do
    before(:each) do
      allow(User).to receive(:find).with(3).and_return(admin)
    end
    it 'save successfully with email as name' do
      allow(User).to receive(:find_by).with(name: 'lily').and_return(student1)
      session = {user: admin}
      params = {
        user: {name: 'lily',
               crypted_password: 'password',
               role_id: 2,
               password_salt: 1,
               fullname: '6, instructor',
               email: 'chenzy@gmail.com',
               parent_id: 1,
               private_by_default: false,
               mru_directory_path: nil,
               email_on_review: true,
               email_on_submission: true,
               email_on_review_of_review: true,
               is_new_user: false,
               master_permission_granted: 0,
               handle: 'handle',
               digital_certificate: nil,
               timezonepref: 'Eastern Time (US & Canada)',
               public_key: nil,
               copy_of_emails: nil,
               institution_id: 1}
      }
      post :create, params, session
      allow_any_instance_of(User).to receive(:undo_link).with('The user "chenzy@gmail.com" has been successfully created. ').and_return(true)
      expect(flash[:success]).to eq "A new password has been sent to new user's e-mail address."
      expect(response).to redirect_to('http://test.host/users/list')
    end

    it 'save successfully without the same name' do
      session = {user: admin}
      params = {
        user: {name: 'instructor6',
               crypted_password: 'password',
               role_id: 2,
               password_salt: 1,
               fullname: '6, instructor',
               email: 'chenzy@gmail.com',
               parent_id: 1,
               private_by_default: false,
               mru_directory_path: nil,
               email_on_review: true,
               email_on_submission: true,
               email_on_review_of_review: true,
               is_new_user: false,
               master_permission_granted: 0,
               handle: 'handle',
               digital_certificate: nil,
               timezonepref: 'Eastern Time (US & Canada)',
               public_key: nil,
               copy_of_emails: nil,
               institution_id: 1}
      }
      post :create, params, session
      allow_any_instance_of(User).to receive(:undo_link).with('The user "instructor6" has been successfully created. ').and_return(true)
      expect(flash[:success]).to eq "A new password has been sent to new user's e-mail address."
      expect(response).to redirect_to('http://test.host/users/list')
    end

    it 'save unsuccessfully' do
      expect_any_instance_of(User).to receive(:save).and_return(false)
      session = {user: admin}
      params = {
        user: {name: 'instructor6',
               crypted_password: 'password',
               role_id: 2,
               password_salt: 1,
               fullname: '6, instructor',
               email: 'chenzy@gmail.com',
               parent_id: 1,
               private_by_default: false,
               mru_directory_path: nil,
               email_on_review: true,
               email_on_submission: true,
               email_on_review_of_review: true,
               is_new_user: false,
               master_permission_granted: 0,
               handle: 'handle',
               digital_certificate: nil,
               timezonepref: 'Eastern Time (US & Canada)',
               public_key: nil,
               copy_of_emails: nil,
               institution_id: 1}
      }
      post :create, params, session
      expect(response).to render_template(:new)
    end
  end

  context "#create_requested_user_record" do
    it 'if user not exists and requested user is saved' do
      params = {
        user: {name: 'instructor6',
               role_id: 2,
               fullname: '6, instructor',
               institution_id: 1,
               email: 'chenzy@gmail.com'},
        requested_user: {self_introduction: 'I am good'}
      }
      post :create_requested_user_record, params # session
      expect(flash[:success]).to eq 'User signup for "instructor6" has been successfully requested.'
      expect(response).to redirect_to('http://test.host/instructions/home')
    end

    it 'if user exists' do
      allow(User).to receive(:find_by).with(name: 'instructor6').and_return(instructor)
      params = {
        user: {name: 'instructor6',
               role_id: 2,
               fullname: '6, instructor',
               institution_id: 1,
               email: 'chenzy@gmail.com'},
        requested_user: {self_introduction: 'I am good'}
      }
      post :create_requested_user_record, params
      expect(flash[:error]).to eq 'The account you are requesting has already existed in Expertiza.'
      expect(response).to redirect_to('http://test.host/users/request_new?role=Student')
    end

    it 'if requested user is not saved' do
      expect_any_instance_of(RequestedUser).to receive(:save).and_return(false)
      params = {
        user: {name: 'instructor6',
               role_id: 2,
               fullname: '6, instructor',
               institution_id: 1,
               email: 'chenzy@gmail.com'},
        requested_user: {self_introduction: 'I am good'}
      }
      post :create_requested_user_record, params
      expect(response).to redirect_to('http://test.host/users/request_new?role=Student')
    end

    it 'if user not exists, requested user is saved and params[:user][:institution_id] is empty' do
      params = {
        user: {name: 'instructor6',
               role_id: 2,
               fullname: '6, instructor',
               institution_id: [],
               email: 'chenzy@gmail.com'},
        requested_user: {self_introduction: 'I am good'},
        institution: {name: 'google'}
      }
      post :create_requested_user_record, params
      expect(response).to redirect_to('http://test.host/instructions/home')
    end
  end

  context "#create_approved_user" do
    before(:each) do
      allow(RequestedUser).to receive(:find_by).with(id: "4").and_return(requested_user1)
      allow(User).to receive(:find_by).with(id: 3).and_return(admin)
    end

    it 'the input status is nil and original status is nil' do
      params = {
        id: 4,
        status: nil
      }
      post :create_approved_user, params
      expect(flash[:error]).to eq 'Please Approve or Reject before submitting'
      expect(response).to redirect_to('http://test.host/users/list_pending_requested')
    end

    it 'the input status is Approved' do
      session = {user: admin}
      params = {
        id: 4,
        status: 'Approved'
      }
      post :create_approved_user, params, session
      allow_any_instance_of(RequestedUser).to receive(:undo_link).with('The user "requester1" has been successfully created. ').and_return(true)
      expect(flash[:success]).to eq "A new password has been sent to new user's e-mail address." or 'The user "requester1" has been successfully updated.'
      expect(response).to redirect_to('http://test.host/users/list_pending_requested')
    end

    it 'the input status is Approved but save fails' do
      expect_any_instance_of(User).to receive(:save).and_return(false)
      session = {user: admin}
      params = {
        id: 4,
        status: 'Approved'
      }
      post :create_approved_user, params, session
      expect(flash[:success]).to eq 'The user "requester1" has been successfully updated.'
      expect(response).to redirect_to('http://test.host/users/list_pending_requested')
    end

    it 'the input status is Rejected' do
      params = {
        id: 4,
        status: 'Rejected'
      }
      post :create_approved_user, params
      expect(flash[:success]).to eq 'The user "requester1" has been Rejected.' or 'The user "requester1" has been successfully updated.'
      expect(response).to redirect_to('http://test.host/users/list_pending_requested')
    end

    it 'the input status is Rejected but update_colums fails' do
      expect_any_instance_of(RequestedUser).to receive(:update_columns).and_return(false)
      params = {
        id: 4,
        status: 'Rejected'
      }
      post :create_approved_user, params
      expect(flash[:success]).to eq 'The user "requester1" has been successfully updated.'
      expect(flash[:error]).to eq 'Error processing request.'
      expect(response).to redirect_to('http://test.host/users/list_pending_requested')
    end
  end

  context '#edit' do
    it 'renders users#edit page' do
      allow(User).to receive(:find).with('1').and_return(student1)
      @params = {id: 1}
      session = {user: instructor}
      get :edit, @params, session
      expect(response).to render_template(:edit)
    end
  end

  context '#update' do
    it 'when user is updated successfully' do
      allow(User).to receive(:find).with('1').and_return(student1)
      @params = {id: 1}
      allow(student1).to receive(:update_attributes).with(any_args).and_return(true)
      post :update, @params
      expect(flash[:success]).to eq 'The user "lily" has been successfully updated.'
      expect(response).to redirect_to('/users')
    end
    it 'when user is not updated successfully' do
      allow(User).to receive(:find).with('2').and_return(student2)
      @params = {id: 2}
      allow(student2).to receive(:update_attributes).with(any_args).and_return(false)
      post :update, @params
      expect(response).to render_template(:edit)
    end
  end

  context '#keys' do
    before(:each) do
      stub_current_user(student1, student1.role.name, student1.role)
    end
    it 'when params[:id] is not nil' do
      the_key = "the key"
      allow(User).to receive(:find).with('1').and_return(student1)
      allow(student1).to receive(:generate_keys).and_return(the_key)
      @params = {id: 1}
      get :keys, @params
      expect(controller.instance_variable_get(:@private_key)).to be(the_key)
    end
    it 'when params[:id] is nil' do
      get :keys
      expect(response).to redirect_to('/tree_display/drill')
    end
  end
end
