describe AccountRequestController do
  let(:admin) { build(:admin, id: 3) }
  let(:super_admin) { build(:superadmin) }
  let(:instructor) { build(:instructor, id: 2) }
  let(:student1) { build(:student, id: 1, username: :lily) }
  let(:student2) { build(:student) }
  let(:student3) { build(:student, id: 10, role_id: 1, parent_id: nil) }
  let(:student4) { build(:student, id: 20, role_id: 4) }
  let(:student5) { build(:student, role_id: 4, parent_id: 3) }
  let(:student6) { build(:student, role_id: nil, username: :lilith) }

  let(:institution1) { build(:institution, id: 1) }
  let(:requested_user1) do
    AccountRequest.new id: 4, username: 'requester1', role_id: 2, name: 're, requester1',
                       institution_id: 1, email: 'requester1@test.com', status: nil, self_introduction: 'no one'
  end
  let(:superadmin) { build(:superadmin) }
  let(:assignment) do
    build(:assignment, id: 1, name: 'test_assignment', instructor_id: 2,
                       participants: [build(:participant, id: 1, user_id: 1, assignment: assignment)], course_id: 1)
  end
  before(:each) do
    stub_current_user(instructor, instructor.role.name, instructor.role)
  end

  context '#create_approved_user' do
    before(:each) do
      allow(AccountRequest).to receive(:find_by).with(id: '4').and_return(requested_user1)
      allow(User).to receive(:find_by).with(id: 3).and_return(admin)
    end

    it 'the input status is nil and original status is nil' do
      request_params = {
        commit: 'Reject'
      }
      post :create_approved_user, params: request_params
      expect(flash[:error]).to eq 'Please select at least one user before approving or rejecting'
      expect(response).to redirect_to('http://test.host/account_request/list_pending_requested')
    end

    it 'the input status is Approved' do
      allow(controller).to receive(:requested_user_params).and_return({ 'id' => '1' })
      user_session = { user: admin }
      request_params = {
        selection: { '4' => true },
        commit: 'Accept'
      }
      post :create_approved_user, params: request_params, session: user_session
      allow_any_instance_of(AccountRequest).to receive(:undo_link).with('The user "requester1" has been successfully created. ').and_return(true)
      expect(flash[:success]).to(eq "A new password has been sent to new user's e-mail address.") || 'The user "requester1" has been successfully updated.'
      expect(response).to redirect_to('http://test.host/account_request/list_pending_requested')
    end

    it 'the input status is Approved but save fails' do
      allow(controller).to receive(:requested_user_params).and_return({ 'id' => '1' })

      expect_any_instance_of(User).to receive(:save).and_return(false)
      user_session = { user: admin }
      request_params = {
        selection: { '4' => true },
        commit: 'Accept'
      }
      post :create_approved_user, params: request_params, session: user_session
      expect(flash[:success]).to eq 'The user "requester1" has been successfully updated.'
      expect(response).to redirect_to('http://test.host/account_request/list_pending_requested')
    end

    it 'the input status is Rejected' do
      allow(controller).to receive(:requested_user_params).and_return({ 'id' => '1' })
      request_params = {
        selection: { '4' => true },
        commit: 'Reject'
      }
      post :create_approved_user, params: request_params
      expect(flash[:success]).to(eq 'The user "requester1" has been Rejected.') || 'The user "requester1" has been successfully updated.'
      expect(response).to redirect_to('http://test.host/account_request/list_pending_requested')
    end

    it 'the input status is Rejected but update_colums fails' do
      allow(controller).to receive(:requested_user_params).and_return({ 'id' => '1' })
      expect_any_instance_of(AccountRequest).to receive(:update_columns).and_return(false)
      request_params = {
        selection: { '4' => true },
        commit: 'Reject'
      }
      post :create_approved_user, params: request_params
      expect(flash[:success]).to eq 'The user "requester1" has been successfully updated.'
      expect(flash[:error]).to eq 'Error processing request.'
      expect(response).to redirect_to('http://test.host/account_request/list_pending_requested')
    end
  end

  context '#list_pending_requested' do
    it 'test list_pending_requested view' do
      stub_current_user(super_admin, super_admin.role.name, super_admin.role)
      get :list_pending_requested
      expect(response).to render_template(:list_pending_requested)
    end
  end

  context '#list_pending_requested_finalized' do
    it 'test list_pending_requested_finalized view' do
      stub_current_user(super_admin, super_admin.role.name, super_admin.role)
      get :list_pending_requested_finalized
      expect(response).to render_template(:list_pending_requested_finalized)
    end
  end

  context '#request new' do
    it '1' do
      allow(Role).to receive(:find_by).with(name: 'instructor').and_return('instructor')
      request_params = { role: 'instructor' }
      post :new, params: request_params
      expect(response).to render_template(:new)
    end
  end

  context '#create_requested_user_record' do
    request_params = {
      requested_user: { self_introduction: 'I am good' },
      user: { username: 'instructor6',
              role_id: 2,
              name: '6, instructor',
              institution_id: 1,
              email: 'chenzy@gmail.com' }
    }
    it 'if user not exists and requested user is saved' do
      post :create_requested_user_record, params: request_params # user_session
      expect(flash[:success]).to eq 'User signup for "instructor6" has been successfully requested.'
      expect(response).to redirect_to('http://test.host/instructions/home')
    end

    it 'if user exists' do
      allow(User).to receive(:find_by).with(username: 'instructor6').and_return(instructor)

      post :create_requested_user_record, params: request_params
      expect(flash[:error]).to eq 'The account you are requesting already exists in Expertiza.'
      expect(response).to redirect_to('http://test.host/account_request/new?role=Student')
    end

    it 'if requested user is not saved' do
      expect_any_instance_of(AccountRequest).to receive(:save).and_return(false)

      post :create_requested_user_record, params: request_params
      expect(response).to redirect_to('http://test.host/account_request/new?role=Student')
    end

    it 'if user not exists, requested user is saved and request_params[:user][:institution_id] is empty' do
      post :create_requested_user_record, params: request_params
      expect(response).to redirect_to('http://test.host/instructions/home')
    end
  end
end
