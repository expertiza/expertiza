describe ConferenceController do
  let(:admin) { build(:admin, id: 3) }
  let(:super_admin) { build(:superadmin) }
  let(:instructor) { build(:instructor, id: 2) }
  let(:instructor1) { build(:instructor, id: 2, timezonepref: 'Eastern Time (US & Canada)') }
  let(:student1) { build(:student, id: 1, username: :lily) }
  let(:student1) { build(:student, id: 2, username: :lily23) }
  let(:student2) { build(:student) }
  let(:student3) { build(:student, id: 10, role_id: 1, parent_id: nil) }
  let(:student4) { build(:student, id: 20, role_id: 4) }
  let(:student5) { build(:student, role_id: 4, parent_id: 3) }

  let(:participant) { build(:participant, id: 1) }
  let(:institution1) { build(:institution, id: 1) }
  let(:assignment1) { build(:assignment, id: 2, is_conference_assignment: 1, max_team_size: 100) }
  let(:requested_user1) do
    AccountRequest.new id: 4, username: 'requester1', role_id: 2, fullname: 're, requester1',
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

  context '#new' do
    it 'saves successfully for logged in user as Author' do
      request_params = { assignment_id: 2 }
      user_session = { user: student1 }
      stub_current_user(student1, student1.role.name, student1.role)
      allow(Assignment).to receive(:find_by_id).with('2').and_return(assignment1)
      allow(AssignmentParticipant).to receive(:create).with(any_args).and_return(participant)
      post :new, params: request_params, session: user_session
      expect(flash[:success]).to eq 'You are added as an Author for assignment final2'
      expect(response).to redirect_to('http://test.host/student_task/list')
    end
  end

  context '#create' do
    before(:each) do
      allow(User).to receive(:find).with(3).and_return(admin)
    end

    it 'save successfully for new Author' do
      request_params = {
        user: { username: 'lily',
                role_id: 2,
                email: 'chenzy@gmail.com',
                fullname: 'John Bumgardner',
                assignment: '2' }
      }
      allow(Assignment).to receive(:find_by_id).with('2').and_return(assignment1)
      allow(Assignment).to receive(:find).with('2').and_return(assignment1)
      allow(User).to receive(:find).with(1).and_return(instructor1)
      allow(User).to receive(:skip_callback).with(:create, :after, :email_welcome).and_return(true)
      post :create, params: request_params
      expect(flash[:success]).to eq 'You are added as an Author for assignment final2'
    end

    it 'save successfully for existing user as Author' do
      request_params = {
        user: { username: 'lily',
                assignment: '2' }
      }
      allow(User).to receive(:find_by).with(username: 'lily').and_return(student1)
      allow(Assignment).to receive(:find_by_id).with('2').and_return(assignment1)
      allow(Assignment).to receive(:find).with('2').and_return(assignment1)
      allow(AssignmentParticipant).to receive(:create).with(any_args).and_return(participant)
      allow(User).to receive(:find).with(1).and_return(instructor1)
      post :create, params: request_params
      expect(flash[:success]).to eq 'You are added as an Author for assignment final2'
    end
    it 'return error if user email already exist' do
      request_params = {
        user: { username: 'lily',
                role_id: 2,
                email: 'chenzy@gmail.com',
                fullname: 'John Bumgardner',
                assignment: '2' }
      }
      allow(Assignment).to receive(:find_by_id).with('2').and_return(assignment1)
      allow(Assignment).to receive(:find).with('2').and_return(assignment1)
      allow(User).to receive(:find).with(1).and_return(instructor1)
      allow(User).to receive(:skip_callback).with(:create, :after, :email_welcome).and_return(true)
      post :create, params: request_params

      request_params2 = {
        user: { username: 'lily23',
                role_id: 2,
                email: 'chenzy@gmail.com',
                fullname: 'John Bumgardner',
                assignment: '2' }
      }
      allow(Assignment).to receive(:find_by_id).with('2').and_return(assignment1)
      allow(Assignment).to receive(:find).with('2').and_return(assignment1)
      allow(User).to receive(:find).with(2).and_return(instructor1)
      post :create, params: request_params2
      expect(flash[:error]).to eq 'A user with username of this email already exists, Please provide a unique email to continue.'
    end
  end

  context 'Author/Co-Author login with captcha' do
    it 'should redirect to root with correct recaptcha' do
      user_session = { user: student1 }
      request_params = {
        user: { username: 'lily',
                crypted_password: 'password',
                role_id: 1,
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
                institution_id: 1 }
      }
      allow(ConferenceController).to receive(:verify_recaptcha).and_return(true)
      #   expect(response).to render_template 'content_pages/view'

      post :create, params: request_params, session: user_session
      expect(response).to redirect_to(root_path)
    end
    it 'should redirect to join conference page with incorrect recaptcha' do
      user_session = { user: student2 }
      request_params = {
        user: { username: 'lily2',
                crypted_password: 'password',
                role_id: 1,
                password_salt: 1,
                fullname: '6, instructor',
                email: 'chenzy2@gmail.com',
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
                institution_id: 1 }
      }

      allow_any_instance_of(ConferenceController).to receive(:verify_recaptcha).and_return(false)
      #   expect(response).to render_template 'content_pages/view'
      post :create, params: request_params, session: user_session
      expect { post :create, params: request_params, session: user_session }.to change(User, :count).by(0)
    end
  end
end
