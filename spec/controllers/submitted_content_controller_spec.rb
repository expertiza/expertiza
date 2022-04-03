describe SubmittedContentController do
  let(:super_admin) { build(:superadmin, id: 1, role_id: 5) }
  let(:instructor1) { build(:instructor, id: 10, role_id: 3, parent_id: 3, name: 'Instructor1') }
  let(:student1) { build(:student, id: 21, role_id: 1) }
  let(:team) { build(:assignment_team, id: 1) }
  let(:participant) { build(:participant, id: 1, user_id: 21) }
  let(:assignment) { build(:assignment, id: 1) }
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
      it 'renders edit template' do
        allow(AssignmentParticipant).to receive(:find).and_return(participant)
        stub_current_user(instructor1, instructor1.role.name, instructor1.role)
        request_params = { id: 1 }
        response = get :submit_file, params: request_params
        expect(response).to redirect_to(action: :edit, id: 1)
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
        allow(SubmittedContentController).to receive(:check_content_type_integrity).and_return(false)
        allow(MimeMagic).to receive(:by_magic).and_return("not valid")
        allow_any_instance_of(Rack::Test::UploadedFile::String).to receive(:read).and_return("")
        file = Rack::Test::UploadedFile.new("#{Rails.root}/spec/fixtures/files/helloworld.c")
        params = {uploaded_file: file,
                  id: 1}
        response = get :submit_file, params: params
        expect(response).to redirect_to(action: :edit, id: 1)
        expect(flash[:error]).to eq 'File type error'
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
end
