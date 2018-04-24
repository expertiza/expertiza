describe UsersController do
  # RSpec::Mocks.configuration.allow_message_expectations_on_nil=true
  let(:admin) { build(:admin, id: 3) }
  let(:instructor) { build(:instructor, id: 2) }
  # let(:instructor2) { build(:instructor, id: 66) }
  # let(:ta) { build(:teaching_assistant, id: 8) }
  let(:student1) { build(:student, id: 1, name: :lily) }
  let(:student2) { build(:student) }
  let(:student3) { build(:student, id: 10, role_id: 1, parent_id: nil) }
  let(:student4) { build(:student, id: 20, role_id: 4) }
  let(:student5) { build(:student, role_id: 4, parent_id: 3) }
  let(:student6) { build(:student, role_id: nil, name: :lilith)}

  let(:institution1) {build(:institution, id: 1)}
  let(:requested_user1) {RequestedUser.new id: 4, name: 'requester1', role_id: 2, fullname: 're, requester1', institution_id: 1, email: 'requester1@test.com', status: nil, self_introduction: 'no one'}
  let(:superadmin) {build(:superadmin)}

  before(:each) do
    stub_current_user(instructor, instructor.role.name, instructor.role)
  end

  context "#show_selection" do
    before(:each) do
      allow(User).to receive(:find).with(2).and_return(instructor)
    end
    it 'user is nil' do
      allow(User).to receive(:find_by).with(name: 'instructor6').and_return(nil)
      session = {user: admin}
      params ={
          user: { name: 'instructor6',
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
      post :show_selection, params, session
      expect(response).to redirect_to('http://test.host/users/list')
    end

    it 'user is not nil and user is available for editing' do
      allow(User).to receive(:find_by).with(name: 'instructor6').and_return(student3)
      session = {user: student4}
      params ={
          user: { name: 'instructor6',
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
      get :show_selection, params
      expect(response).to render_template(:show)
    end

    it 'user is not nil but is not available for editing' do
      allow(User).to receive(:find_by).with(name: 'instructor6').and_return(student4)
      allow(Role).to receive(:find).with(4).and_return(student5)
      session = {user: student3}
      params ={
          user: { name: 'instructor6',
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
      post :show_selection, params, session
      expect(response).to redirect_to('http://test.host/users/list')
    end

  end

  context '#show' do
    it 'when params[:id] is not nil' do
      allow(controller).to receive(:current_user).and_return(student1)
      allow(User).to receive(:find).with('1').and_return(student1)

      @params = {id: 1,
          user: { name: 'instructor6',
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
      session = {user: student1}
      get :show, @params, session
      expect(response).to render_template(:show)
    end

    it 'when params[:id] is not nil but role_id is nil' do
      allow(controller).to receive(:current_user).and_return(student6)
      allow(User).to receive(:find).with('6').and_return(student6)

      @params = {id: 6,
                 user: { name: 'instructor6',
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
      params ={
          user: { name: 'lily',
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
      expect(flash[:success]).to eq "A new password has been sent to new user's e-mail address."
      expect(response).to redirect_to('http://test.host/users/list')
    end

    it 'save successfully without the same name' do
      session = {user: admin}
      params ={
          user: { name: 'instructor6',
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
      expect(flash[:success]).to eq "A new password has been sent to new user's e-mail address."
      expect(response).to redirect_to('http://test.host/users/list')
    end

    it 'save unsuccessfully' do
      expect_any_instance_of(User).to receive(:save).and_return(false)
      session = {user: admin}
      params ={
          user: { name: 'instructor6',
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
#			allow(User).to receive_message_chain(:joins, :where).and_return([superadmin])
#			session = { user: admin,
#				    ip: "5646:asdh"					
#					}			
      params ={
          user: { name: 'instructor6',
                  role_id: 2,
                  fullname: '6, instructor',
                  institution_id: 1,
                  email: 'chenzy@gmail.com'},
          requested_user: { self_introduction: 'I am good'}
      }
      post :create_requested_user_record, params #session
      expect(flash[:success]).to eq 'User signup for "instructor6" has been successfully requested.'
      expect(response).to redirect_to('http://test.host/instructions/home')
    end

    it 'if user exists' do
      allow(User).to receive(:find_by).with(name: 'instructor6').and_return(instructor)
      params ={
          user: { name: 'instructor6',
                  role_id: 2,
                  fullname: '6, instructor',
                  institution_id: 1,
                  email: 'chenzy@gmail.com'},
          requested_user: { self_introduction: 'I am good'}
      }
      post :create_requested_user_record, params
      expect(flash[:error]).to eq 'The account you are requesting has already existed in Expertiza.'
      expect(response).to redirect_to('http://test.host/users/request_new?role=Student')
    end

    it 'if requested user is not saved' do
      expect_any_instance_of(RequestedUser).to receive(:save).and_return(false)
      params ={
          user: { name: 'instructor6',
                  role_id: 2,
                  fullname: '6, instructor',
                  institution_id: 1,
                  email: 'chenzy@gmail.com'},
          requested_user: { self_introduction: 'I am good'}
      }
      post :create_requested_user_record, params
      expect(response).to redirect_to('http://test.host/users/request_new?role=Student')
    end

    it 'if user not exists, requested user is saved and params[:user][:institution_id] is empty' do
      params ={
          user: { name: 'instructor6',
                  role_id: 2,
                  fullname: '6, instructor',
                  institution_id: [],
                  email: 'chenzy@gmail.com'},
          requested_user: { self_introduction: 'I am good'},
          institution: { name: 'google' }
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
      params ={
          id: 4,
          status: nil
      }
      post :create_approved_user, params
      expect(flash[:error]).to eq 'Please Approve or Reject before submitting'
      expect(response).to redirect_to('http://test.host/users/list_pending_requested')
    end

    it 'the input status is Approved' do
      session = { user: admin}
      params ={
          id: 4,
          status: 'Approved'
      }
      post :create_approved_user, params, session
      expect(flash[:success]).to eq "A new password has been sent to new user's e-mail address." or 'The user "requester1" has been successfully updated.'
#			expect(flash[:success]).to eq 'The user requester1 has been successfully updated'
      expect(response).to redirect_to('http://test.host/users/list_pending_requested')
    end

    it 'the input status is Approved but save fails' do
      expect_any_instance_of(User).to receive(:save).and_return(false)
      session = { user: admin}
      params ={
          id: 4,
          status: 'Approved'
      }
      post :create_approved_user, params, session
      expect(flash[:success]).to eq 'The user "requester1" has been successfully updated.'
      expect(response).to redirect_to('http://test.host/users/list_pending_requested')
    end

    it 'the input status is Rejected' do
      params ={
          id: 4,
          status: 'Rejected'
      }
      post :create_approved_user, params
#			expect(flash[:success]).to eq 'The user "requester1" has been successfully updated.'
      expect(flash[:success]).to eq 'The user "requester1" has been Rejected.' or 'The user "requester1" has been successfully updated.'
      expect(response).to redirect_to('http://test.host/users/list_pending_requested')
    end

    it 'the input status is Rejected but update_colums fails' do
      expect_any_instance_of(RequestedUser).to receive(:update_columns).and_return(false)
      params ={
          id: 4,
          status: 'Rejected'
      }
      post :create_approved_user, params
      expect(flash[:success]).to eq 'The user "requester1" has been successfully updated.'
      expect(flash[:error]).to eq 'Error processing request.'
      expect(response).to redirect_to('http://test.host/users/list_pending_requested')
    end
  end

  describe '#edit' do
    it 'renders users#edit page' do
      allow(User).to receive(:find).with('1').and_return(student1)
      @params = {id: 1}
      session = {user: instructor}
      get :edit, @params,session
      expect(response).to render_template(:edit)
    end
  end

  describe '#update' do
    context 'when user is updated successfully' do
      it 'shows correct flash and redirects to users#show page' do
        allow(User).to receive(:find).with('1').and_return(student1)
        @params = {id: 1}
        allow(student1).to receive(:update_attributes).with(any_args).and_return(true)
        post :update, @params
        expect(flash[:success]).to eq 'The user "lily" has been successfully updated.'
        expect(response).to redirect_to('/users')
      end
    end
    context 'when user is not updated successfully' do
      it 'redirects to users#edit page' do
        allow(User).to receive(:find).with('2').and_return(student2)
        @params = {id: 2}
        allow(student2).to receive(:update_attributes).with(any_args).and_return(false)
        post :update, @params
        expect(response).to render_template(:edit)
      end
    end
  end

  describe '#destroy' do
    # context 'when user is deleted successfully' do
    #   it 'shows correct flash and redirects to users/list page' do
    #     assignment_participant = [double('AssignmentParticipant', user_id: 1)]
    #     teams_user = [double('TeamsUser', user_id: 1)]
    #     assignment_questionnaire = [double('AssignmentQuestionnaire', user_id: 1)]
    #
    #     allow(assignment_participant).to receive(:delete).and_return(true)
    #     allow(teams_user).to receive(:delete).and_return(true)
    #     allow(assignment_questionnaire).to receive(:destroy).and_return(true)
    #
    #     allow(assignment_participant).to receive(:each).and_return(true)
    #     allow(teams_user).to receive(:each).and_return(true)
    #     allow(assignment_questionnaire).to receive(:each).and_return(true)
    #
    #     allow(student1).to receive(:destroy).and_return(true)
    #     allow(User).to receive(:find).with('1').and_return(student1)
    #     @params = {id: 1}
    #     get :destroy, @params
    #     expect(flash[:note]).to match(/'The user "lily" has been successfully updated.*/)
    #     expect(response).to redirect_to('/users/list')
    #   end
    # end
    context 'when user is not deleted successfully' do
      it 'shows an error and redirects to users/list page' do
        allow(User).to receive(:find).with('2').and_return(student2)
        @params = {id: 2}
        get :destroy, @params
        expect(flash[:error]).not_to be_nil
        expect(response).to redirect_to('/users/list')
      end
    end
  end

  describe '#keys' do
    before(:each) do
      stub_current_user(student1, student1.role.name, student1.role)
    end
    context 'when params[:id] is not nil' do
      it '@private_key gets correct value' do
        the_key="the key"
        allow(User).to receive(:find).with('1').and_return(student1)
        allow(student1).to receive(:generate_keys).and_return(the_key)
        @params = {id: 1}
        get :keys, @params
        expect(controller.instance_variable_get(:@private_key)).to be(the_key)
      end
    end
    context 'when params[:id] is nil' do
      it 'redirects to ' do
        get :keys
        expect(response).to redirect_to('/tree_display/drill')
      end
    end
  end
end
