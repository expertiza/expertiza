describe SubmittedContentController do
  let(:admin) { build(:admin, id: 3) }
  let(:super_admin) { build(:superadmin, id: 1, role_id: 5) }
  let(:instructor1) { build(:instructor, id: 10, role_id: 3, parent_id: 3, username: 'Instructor1') }
  let(:student1) { build(:student, id: 21, role_id: 1) }
  let(:team) { build(:assignment_team, id: 1) }
  let(:participant) { build(:participant, id: 1, user_id: 21) }
  let(:assignment) { build(:assignment, id: 1) }
  describe '#action_allowed?' do
    context 'current user is not authorized' do
      it 'does not allow action for no user' do
        expect(controller.send(:action_allowed?)).to be false
      end
      it 'does not allow action for student without authorizations' do
        allow(controller).to receive(:current_user).and_return(build(:student))
        expect(controller.send(:action_allowed?)).to be false
      end
    end
    context 'current user has needed privileges' do
      it 'allows edit action for student with needed authorizations' do
        stub_current_user(student1, student1.role.name, student1.role)
        allow(controller).to receive(:are_needed_authorizations_present?).and_return(true)
        controller.params = {action: 'edit'}
        expect(controller.send(:action_allowed?)).to be true
      end
      it 'allows submit file action for students with team that can submit' do
        stub_current_user(student1, student1.role.name, student1.role)
        allow(controller).to receive(:one_team_can_submit_work?).and_return(true)
        controller.params = {action: 'submit_file'}
        expect(controller.send(:action_allowed?)).to be true
      end
      it 'allows submit hyperlink action for students with team that can submit' do
        stub_current_user(student1, student1.role.name, student1.role)
        allow(controller).to receive(:one_team_can_submit_work?).and_return(true)
        controller.params = {action: 'submit_hyperlink'}
        expect(controller.send(:action_allowed?)).to be true
      end
      it 'allows action for admin' do
        stub_current_user(admin, admin.role.name, admin.role)
        expect(controller.send(:action_allowed?)).to be true
      end
      it 'allows action for super admin' do
        stub_current_user(super_admin, super_admin.role.name, super_admin.role)
        expect(controller.send(:action_allowed?)).to be true
      end
    end
  end
  describe '#controller_locale' do
    it 'should return I18n.default_locale' do
      user = student1
      stub_current_user(user, user.role.name, user.role)
      expect(controller.send(:controller_locale)).to eq(I18n.default_locale)
    end
  end
  describe '#submit_hyperlink' do
    context 'current user is participant and submits hyperlink' do
      before(:each) do
        allow(AssignmentParticipant).to receive(:find).and_return(participant)
        stub_current_user(student1, student1.role.name, student1.role)
        allow(participant).to receive(:team).and_return(team)
        allow(participant).to receive(:name).and_return('Name')
      end
      it 'flashes error if a duplicate hyperlink is submitted' do
        allow(team).to receive(:hyperlinks).and_return(['google.com'])
        params = {submission: "google.com", id: 21}
        response = get :submit_hyperlink, params: params
        expect(response).to redirect_to(action: :edit, id: 1)
        expect(flash[:error]).to eq 'You or your teammate(s) have already submitted the same hyperlink.'
      end
      it 'flashes error if url is invalid' do
        allow(team).to receive(:hyperlinks).and_return([])
        params = {submission: "abc123", id: 21}
        response = get :submit_hyperlink, params: params
        expect(response).to redirect_to(action: :edit, id: 1)
        expect(flash[:error]).to be_present # not checking message content since it uses #{$ERROR_INFO}
      end
    end
  end
  describe '#remove_hyperlink' do
    #NOTE - this method is not currently used, the below context is a start
    #       at proposed tests that may be useful in the future
    context 'current user is participant' do
      before(:each) do
        #allow(AssignmentParticipant).to receive(:find).and_return(participant)
        #stub_current_user(student1, student1.role.name, student1.role)
        #allow(participant).to receive(:team).and_return(team)
        #allow(team).to receive(:hyperlinks).and_return(['google.com'])
      end
      it 'redirects to edit if submissions are allowed' #do
        #params = {id: 1}
        #allow(assignment).to receive(:submission_allowed).and_return(true)
        #response = get :remove_hyperlink, params
        #expect(response).to redirect_to(action: :edit, id: 1)
      #end
      it 'redirects to view if submissions are not allowed' #do
        #params = {id: 1}
        #allow(assignment).to receive(:submission_allowed).and_return(true)
        #response = get :remove_hyperlink, params
        #expect(response).to redirect_to(action: :view, id: 1)
      #end
    end
  end
  describe '#submit_file' do
    context 'current user does not match up with the participant' do
      # this test has problems after rails 5.1 migration, getting 'undefined method 'size' for nil:NilClass' error
      # when 'check_content_size' method is called in submitted_content_controller, doesn't seem to be a problem in
      # other submit_file tests that should call the same method though...
      it 'renders edit template' #do
        #allow(AssignmentParticipant).to receive(:find).and_return(participant)
        #stub_current_user(instructor1, instructor1.role.name, instructor1.role)
        #request_params = { id: 1 }
        #response = get :submit_file, params: request_params
        #expect(response).to redirect_to(action: :edit, id: 1)
      #end
    end
    context 'user that is participant uploads a file' do
      before(:each) do
        allow(AssignmentParticipant).to receive(:find).and_return(participant)
        stub_current_user(student1, student1.role.name, student1.role)
      end
      it 'flashes error for file exceeding size limit' do
        allow(controller).to receive(:check_content_size).and_return(false)
        file = Rack::Test::UploadedFile.new("#{Rails.root}/spec/fixtures/files/the-rspec-book_p2_1.pdf")
        params = {uploaded_file: file, id: 1}
        response = get :submit_file, params: params
        expect(response).to redirect_to(action: :edit, id: 1)
        expect(flash[:error]).to be_present # not checking message content since it uses variable size limit
      end
      it 'flashes error for file of unexpected type' do
        allow(SubmittedContentController).to receive(:check_extension_integrity).and_return(false)
        allow_any_instance_of(Rack::Test::UploadedFile::String).to receive(:read).and_return("")
        allow_any_instance_of(Rack::Test::UploadedFile::String).to receive(:original_filename).and_return("")
        file = Rack::Test::UploadedFile.new("#{Rails.root}/spec/fixtures/files/helloworld.c")
        params = {uploaded_file: file,
                  id: 1}
        response = get :submit_file, params: params
        expect(response).to redirect_to(action: :edit, id: 1)
        expect(flash[:error]).to eq "File extension does not match. "\
                                    "Please upload one of the following: "\
                                    "pdf, png, jpeg, zip, tar, gz, 7z, odt, docx, md, rb, mp4, txt"
      end
      # we could test that file is written and submission record is created, but we could have to
      # make assumptions about how path is formed and user input for path/filename is sanitized.  We don't want
      # this test coupled to the existing implementation
    end
  end
  describe '#folder_action' do
    context 'current user does not match up with the participant' do
      #method just returns in this context, how do we test that?
    end
    context 'current user is participant performing folder action' do
      before(:each) do
        allow(AssignmentParticipant).to receive(:find).and_return(participant)
        stub_current_user(student1, student1.role.name, student1.role)
      end
      it 'redirects to edit' #do
        #params = {id: 1, faction: nil}
        #response = get :folder_action, params
        #expect(response).to redirect_to(action: :edit, id: 1)
      #end
      it 'delete action deletes selected files'
      it 'rename action renames selected file'
      it 'move action moves selected file'
      it 'copy action copies selected file'
      it 'create folder action creates new directory'
    end
  end
  describe '#download' do
    context 'user downloads file' do
      it 'flashes error for nil folder name' do
        params = {folder_name: nil}
        response = get :download, params: params
        expect(flash[:error]).to be_present # not checking message content since it uses exception message
      end
      it 'flashes error for nil file name' do
        params = {name: nil}
        response = get :download, params: params
        expect(flash[:error]).to be_present # not checking message content since it uses exception message
      end
      it 'flashes error if attempt is to download entire folder' do
        params = {folder_name: 'test_directory', name: nil}
        response = get :download, params: params
        expect(flash[:error]).to be_present # not checking message content since it uses exception message
      end
      it 'flashes error if file does not exist' do
        params = {folder_name: 'unlikely_dir_name', name: 'nonexistantfile.no'}
        response = get :download, params: params
        expect(flash[:error]).to be_present #not checking message content since it uses exception message
      end
      it 'calls send for a valid file download' do
        # still figuring this one out...
        #params = {folder_name: 'test_dir', name: 'test.txt'}
        #File.stub(:exist?).and_return(true)
        #response = get :download, params
        #expect(download).to receive(:send_file)
      end
    end
    context 'user that is participant uploads a file' do
      before(:each) do
        allow(AssignmentParticipant).to receive(:find).and_return(participant)
        stub_current_user(student1, student1.role.name, student1.role)
      end
      it 'flashes error for file exceeding size limit' do
        allow(controller).to receive(:check_content_size).and_return(false)
        file = Rack::Test::UploadedFile.new("#{Rails.root}/spec/fixtures/files/the-rspec-book_p2_1.pdf")
        params = {uploaded_file: file,
                  id: 1}
        response = get :submit_file, params: params
        expect(response).to redirect_to(action: :edit, id: 1)
        expect(flash[:error]).to be_present # not checking message content since it uses variable size limit
      end
      it 'flashes error for file of unexpected type' do
        allow(SubmittedContentController).to receive(:check_extension_integrity).and_return(false)
        allow_any_instance_of(Rack::Test::UploadedFile::String).to receive(:read).and_return("")
        allow_any_instance_of(Rack::Test::UploadedFile::String).to receive(:original_filename).and_return("")
        file = Rack::Test::UploadedFile.new("#{Rails.root}/spec/fixtures/files/helloworld.c")
        params = {uploaded_file: file,
                  id: 1}
        response = get :submit_file, params: params
        expect(response).to redirect_to(action: :edit, id: 1)
        expect(flash[:error]).to eq "File extension does not match. "\
                                    "Please upload one of the following: "\
                                    "pdf, png, jpeg, zip, tar, gz, 7z, odt, docx, md, rb, mp4, txt"
      end
      # we could test that file is written and submission record is created, but we could have to
      # make assumptions about how path is formed and user input for path/filename is sanitized.  We don't want
      # this test coupled to the existing implementation
    end
  end
  describe '#folder_action' do
    context 'current user does not match up with the participant' do
      #method just returns in this context, how do we test that?
    end
    context 'current user is participant performing folder action' do
      before(:each) do
        allow(AssignmentParticipant).to receive(:find).and_return(participant)
        stub_current_user(student1, student1.role.name, student1.role)
      end
      it 'redirects to edit' #do
        #params = {id: 1, faction: nil}
        #response = get :folder_action, params
        #expect(response).to redirect_to(action: :edit, id: 1)
      #end
      it 'delete action deletes selected files'
      it 'rename action renames selected file'
      it 'move action moves selected file'
      it 'copy action copies selected file'
      it 'create folder action creates new directory'
    end
  end
  describe '#download' do
    context 'user downloads file' do
      it 'flashes error for nil folder name' do
        params = {folder_name: nil}
        response = get :download, params: params
        expect(flash[:error]).to be_present # not checking message content since it uses exception message
      end
      it 'flashes error for nil file name' do
        params = {name: nil}
        response = get :download, params: params
        expect(flash[:error]).to be_present # not checking message content since it uses exception message
      end
      it 'flashes error if attempt is to download entire folder' do
        params = {folder_name: 'test_directory', name: nil}
        response = get :download, params: params
        expect(flash[:error]).to be_present # not checking message content since it uses exception message
      end
      it 'flashes error if file does not exist' do
        params = {folder_name: 'unlikely_dir_name', name: 'nonexistantfile.no'}
        response = get :download, params: params
        expect(flash[:error]).to be_present #not checking message content since it uses exception message
      end
      it 'calls send for a valid file download' do
        # still figuring this one out...
        #params = {folder_name: 'test_dir', name: 'test.txt'}
        #File.stub(:exist?).and_return(true)
        #response = get :download, params
        #expect(download).to receive(:send_file)
      end
    end
  end

  let(:student1) { build_stubbed(:student, id: 21, role_id: 1) }
  let(:participant) { build(:participant, id: 1, user_id: 21) }
  describe 'student#view' do
    it 'student#view it' do
      allow(AssignmentParticipant).to receive(:find).and_return(participant)
      stub_current_user(student1, student1.role.name, student1.role)
      allow(participant).to receive(:name).and_return('Name')
      params = { id: 21 }
      response = get :view, params: params
      expect(response).to redirect_to(action: :edit, view: true, id: 21)
    end
  end

  let(:instructor1) { build_stubbed(:instructor, id: 21, role_id: 1) }
  let(:participant) { build(:participant, id: 1, user_id: 21) }

  describe 'instructor#view' do
    it 'instructor#view it' do
      allow(AssignmentParticipant).to receive(:find).and_return(participant)
      stub_current_user(instructor1, instructor1.role.name, instructor1.role)
      allow(participant).to receive(:name).and_return('Name')
      params = { id: 21 }
      response = get :view, params: params
      expect(response).to redirect_to(action: :edit, view: true, id: 21)
    end
  end

  let(:superadmin1) { build_stubbed(:superadmin, id: 21, role_id: 1) }
  let(:participant) { build(:participant, id: 1, user_id: 21) }

  describe 'superadmin#view' do
    it 'superadmin#view it' do
      allow(AssignmentParticipant).to receive(:find).and_return(participant)
      stub_current_user(superadmin1, superadmin1.role.name, superadmin1.role)
      allow(participant).to receive(:name).and_return('Name')
      params = { id: 21 }
      response = get :view, params: params
      expect(response).to redirect_to(action: :edit, view: true, id: 21)
    end
  end

  let(:student1) { build_stubbed(:student, id: 21, role_id: 1) }
  let(:participant) { build(:participant, id: 1, user_id: 21) }

  describe 'student#edit' do
    it 'student#edit it' do
      allow(AssignmentParticipant).to receive(:find).and_return(participant)
      allow(Participant).to receive(:find_by).and_return(participant)
      allow(User).to receive(:find).and_return(participant)
      stub_current_user(student1, student1.role.name, student1.role)
      allow(participant).to receive(:name).and_return('Name')
      params = { id: 21 }
      response = get :edit, params: params
      expect(response).to render_template(:edit)
    end
  end

  let(:instructor1) { build_stubbed(:instructor, id: 21, role_id: 1) }
  let(:participant) { build(:participant, id: 1, user_id: 21) }

  describe 'instructor#edit' do
    it 'instructor#edit it' do
      allow(AssignmentParticipant).to receive(:find).and_return(participant)
      allow(Participant).to receive(:find_by).and_return(participant)
      allow(User).to receive(:find).and_return(participant)
      stub_current_user(instructor1, instructor1.role.name, instructor1.role)
      allow(participant).to receive(:name).and_return('Name')
      params = { id: 21 }
      response = get :edit, params: params
      expect(response).to render_template(:edit)
    end
  end

  let(:superadmin1) { build_stubbed(:superadmin, id: 21, role_id: 1) }
  let(:participant) { build(:participant, id: 1, user_id: 21) }

  describe 'superadmin#edit' do
    it 'superadmin#edit it' do
      allow(AssignmentParticipant).to receive(:find).and_return(participant)
      allow(Participant).to receive(:find_by).and_return(participant)
      allow(User).to receive(:find).and_return(participant)
      stub_current_user(superadmin1, superadmin1.role.name, superadmin1.role)
      allow(participant).to receive(:name).and_return('Name')
      params = { id: 21 }
      response = get :edit, params: params
      expect(response).to render_template(:edit)
    end
  end

  ### NEED TO DO check_extension_integrity

  describe '#check_content_size' do
    it "file size 500 should succeed" do
      testfile = instance_double(File, read: 'testing read', size: 500)
      expect(controller.send(:check_content_size, testfile, 1)).to be_truthy
    end
    it "file size 5,000,000 should fail" do
      testfile = instance_double(File, read: 'testing read', size: 5000000)
      expect(controller.send(:check_content_size, testfile, 1)).to be_falsey
    end
  end
  describe '#file_type' do
    it 'type should be png' do
      expect(controller.send(:file_type, 'test.png')).to eql('png')
    end
    it 'type should be txt' do
      expect(controller.send(:file_type, 'test.png.txt')).to eql('txt')
    end
  end
end
