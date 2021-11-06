describe AccountRequestController do
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
  let(:requested_user1) {AccountRequest.new id: 4, name: 'requester1', role_id: 2, fullname: 're, requester1',
                                           institution_id: 1, email: 'requester1@test.com', status: nil, self_introduction: 'no one'}
  let(:superadmin) {build(:superadmin)}
  let(:assignment) {build(:assignment, id: 1, name: "test_assignment", instructor_id: 2,
                          participants: [build(:participant, id: 1, user_id: 1, assignment: assignment)], course_id: 1)}
  before(:each) do
    stub_current_user(instructor, instructor.role.name, instructor.role)
  end

  context "#create_approved_user" do
    before(:each) do
      allow(AccountRequest).to receive(:find_by).with(id: "4").and_return(requested_user1)
      allow(User).to receive(:find_by).with(id: 3).and_return(admin)
    end

    it 'the input status is nil and original status is nil' do
      params = {
          id: 4,
          status: nil
      }
      post :create_approved_user, params
      expect(flash[:error]).to eq 'Please Approve or Reject before submitting'
      expect(response).to redirect_to('http://test.host/account_request/list_pending_requested')
    end

    it 'the input status is Approved' do
      session = {user: admin}
      params = {
          id: 4,
          status: 'Approved'
      }
      post :create_approved_user, params, session
      allow_any_instance_of(AccountRequest).to receive(:undo_link).with('The user "requester1" has been successfully created. ').and_return(true)
      expect(flash[:success]).to eq "A new password has been sent to new user's e-mail address." or 'The user "requester1" has been successfully updated.'
      expect(response).to redirect_to('http://test.host/account_request/list_pending_requested')
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
      expect(response).to redirect_to('http://test.host/account_request/list_pending_requested')
    end

    it 'the input status is Rejected' do
      params = {
          id: 4,
          status: 'Rejected'
      }
      post :create_approved_user, params
      expect(flash[:success]).to eq 'The user "requester1" has been Rejected.' or 'The user "requester1" has been successfully updated.'
      expect(response).to redirect_to('http://test.host/account_request/list_pending_requested')
    end

      it 'the input status is Rejected but update_colums fails' do
      expect_any_instance_of(AccountRequest).to receive(:update_columns).and_return(false)
      params = {
          id: 4,
          status: 'Rejected'
      }
      post :create_approved_user, params
      expect(flash[:success]).to eq 'The user "requester1" has been successfully updated.'
      expect(flash[:error]).to eq 'Error processing request.'
      expect(response).to redirect_to('http://test.host/account_request/list_pending_requested')
    end
  end

  context "#list_pending_requested" do
    it 'test list_pednign_requested view' do
      stub_current_user(super_admin, super_admin.role.name, super_admin.role)
      get :list_pending_requested
      expect(response).to render_template(:list_pending_requested)
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
      expect(response).to redirect_to('http://test.host/account_request/request_new?role=Student')
    end

    it 'if requested user is not saved' do
      expect_any_instance_of(AccountRequest).to receive(:save).and_return(false)
      params = {
          user: {name: 'instructor6',
                 role_id: 2,
                 fullname: '6, instructor',
                 institution_id: 1,
                 email: 'chenzy@gmail.com'},
          requested_user: {self_introduction: 'I am good'}
      }
      post :create_requested_user_record, params
      expect(response).to redirect_to('http://test.host/account_request/request_new?role=Student')
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


end
