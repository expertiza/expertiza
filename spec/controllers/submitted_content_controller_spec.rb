describe SubmittedContentController do
  let(:super_admin) { build(:superadmin, id: 1, role_id: 5) }
  let(:instructor1) { build(:instructor, id: 10, role_id: 3, parent_id: 3, name: 'Instructor1') }
  let(:student1) { build(:student, id: 21, role_id: 1) }
  let(:participant) { build(:participant, id: 1, user_id: 21) }
  describe '#submit_file' do
    context 'current user does not match up with the participant' do
      it 'renders edit template' do
        allow(AssignmentParticipant).to receive(:find).and_return(participant)
        stub_current_user(instructor1, instructor1.role.name, instructor1.role)
        params = {id: 1}
        response = get :submit_file, params 
        expect(response).to redirect_to(action: :edit, id: 1)
      end
    end
    context 'user that is participant uploads a file' do
      before(:each) do
        allow(AssignmentParticipant).to receive(:find).and_return(participant)
        stub_current_user(student1, student1.role.name, student1.role)
      end
      it 'flashes error for file exceeding size limit' do
        params = {uploaded_file: Rack::Test::UploadedFile.new("#{Rails.root}/spec/fixtures/files/the-rspec-book_p2_1.pdf"),
                  id: 1}
        response = get :submit_file, params
        expect(response).to redirect_to(action: :edit, id: 1)
        expect(flash[:error]).to be_present # not checking message content since it uses variable size limit
      end
      it 'flashes error for file of unexpected type' do
        params = {uploaded_file: Rack::Test::UploadedFile.new("#{Rails.root}/spec/fixtures/files/helloworld.c"),
                  id: 1}
        response = get :submit_file, params
        expect(response).to redirect_to(action: :edit, id: 1)
        expect(flash[:error]).to eq 'File type error'
      end
      # it 'creates new directory' do
      # it 'writes file to server' do
      # it 'unzips the file if needed' do
      # it 'creates a submission record' do
      # it 'notifies all reviewers assigned to reviewee' do
    end
  end
end