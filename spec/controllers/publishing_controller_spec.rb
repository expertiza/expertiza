describe PublishingController do
  let(:super_admin) { build(:superadmin, id: 1, role_id: 5) }
  let(:admin) { build(:admin, id: 3) }
  let(:instructor1) { build(:instructor, id: 10, role_id: 3, parent_id: 3, username: 'Instructor1') }
  let(:student1) { build(:student, id: 21, role_id: 1) }
  let(:ta) { build(:teaching_assistant, id: 6) }
  let(:participant) {build(:participant, id: 1)}
  let(:assignment_participant1) { build(:participant, id: 2, user_id: 21)}
  let(:assignment_participant2) { build(:participant, id: 3, user_id: 21)}   
	
  #load student object with id 21
  before(:each) do
    allow(User).to receive(:find).with(21).and_return(student1)
  end

	describe '#action_allowed?' do
    #check if super-admin is able to perform the actions
    it 'allows super_admin to perform certain action' do
      stub_current_user(super_admin, super_admin.role.name, super_admin.role)
      expect(controller.send(:action_allowed?)).to be_truthy
    end

    #check if instructor is able to perform the actions
    it 'allows instructor to perform certain action' do
      stub_current_user(instructor1, instructor1.role.name, instructor1.role)
      expect(controller.send(:action_allowed?)).to be_truthy
    end

    #check if student is able to perform the actions
    it 'allows student to perform certain action' do
      stub_current_user(student1, student1.role.name, student1.role)
      expect(controller.send(:action_allowed?)).to be_truthy
    end

    #check if teaching assistant is able to perform the actions
    it 'allows teaching assistant to perform certain action' do
      stub_current_user(ta, ta.role.name, ta.role)
      expect(controller.send(:action_allowed?)).to be_truthy
    end

    #check if admin is able to perform the actions
    it 'allows admin to perform certain action' do
      stub_current_user(admin, admin.role.name, admin.role)
      expect(controller.send(:action_allowed?)).to be_truthy
    end
  end

  describe 'view' do
    context 'user visits the publishing rights page' do

      #test for verifying all assignment participants are displayed
      it 'displays all the assignment participants' do
          stub_current_user(student1, student1.role.name, student1.role)
          params = { id: 21 }
          get :view, params: params
          expect(assigns(:user)).to eq(student1)
        end
      end
    end

  describe 'set_publish_permission' do
    context 'user matches with participant and user clicks on the grant button next to the assignment' do

      #test user matches with participant and clicks on the grant button and grant route is called
      it 'redirects to the grant page' do
        allow(AssignmentParticipant).to receive(:find).with('1').and_return(assignment_participant1)
        stub_current_user(student1, student1.role.name, student1.role)
        params ={id: 1, allow: 1}
        post :set_publish_permission, params: params
        expect(response).to redirect_to(action: :grant)
      end
    end

    context 'user matches with participant and the assignment is already granted permission' do

      #verify user matches with participant and the assignment is granted permission and view route is called
      it 'redirects to the view page' do
        stub_current_user(student1, student1.role.name, student1.role)
        allow(AssignmentParticipant).to receive(:find).with('1').and_return(assignment_participant1)
        allow(assignment_participant1).to receive(:update_attribute).and_return(true)
        params ={id: 1, allow: '0'}
        post :set_publish_permission, params: params
        expect(response).to redirect_to(action: :view)
      end
    end
  end

  describe 'grant' do
    context 'user clicks on grant option' do

      #verify user clicks on the grant option and display the private key and grant publishing right page
      it 'displays the page where the user can supply their private key and grant publishing rights' do
        allow(AssignmentParticipant).to receive(:find).with('3').and_return(assignment_participant2)
        stub_current_user(student1, student1.role.name, student1.role)
        params ={id: 3}
        get :grant, params: params
        expect(assigns(:user)).to eq(student1)
      end
    end
  end
    
    
  describe 'grant_with_private_key' do

    context 'user visits the grant page without id and enters incorrect RSA private key' do

      #verify user visits the grant page without id and he enters incorrect RSA key, verify flash notice message
      it 'displays notice and redirects to grant' do
        allow(AssignmentParticipant).to receive(:where).with(user_id: 21).and_return([assignment_participant1])
        stub_current_user(student1, student1.role.name, student1.role)
        params = {}
        [assignment_participant1].each do |participant|
          allow(participant).to receive(:verify_digital_signature).with(any_args).and_return(true)
          allow(participant).to receive(:assign_copyright).with(any_args).and_raise('The private key you inputted was invalid.', StandardError)
        end
        post :grant_with_private_key, params: params
        expect(flash[:notice]).to eq('The private key you inputted was invalid.')
        expect(response).to redirect_to(action: :grant)
      end
    end
      
            
    context 'user visits the grant page with id and enters correct RSA private key' do

      #verify user visits grant page with id and correct RSA key is entered, redirect to view page
      it 'verifies to be successful for all past assignments and redirect to view' do
        allow(AssignmentParticipant).to receive(:find).with('2').and_return(assignment_participant1)
        stub_current_user(student1, student1.role.name, student1.role)
        private_key = OpenSSL::PKey::RSA.new 2048
        params = {id: 2, private_key: private_key}
        [assignment_participant1].each do |participant|
          allow(participant).to receive(:verify_digital_signature).with(any_args).and_return(true)
          allow(participant).to receive(:assign_copyright).with(any_args).and_return(true)
        end
        post :grant_with_private_key, params: params
        expect(response).to redirect_to(action: :view)
      end
    end 
      
    context 'user visits the grant page with id and enters incorrect RSA private key' do

      #verify user visits the grant page with id but enters incorrect RSA key, verify flash notice
      it 'displays notice and redirects to grant' do
        allow(AssignmentParticipant).to receive(:find).with('2').and_return(assignment_participant1)
        stub_current_user(student1, student1.role.name, student1.role)
        private_key = OpenSSL::PKey::RSA.new 2048
        params = {id: 2, private_key: private_key}
        [assignment_participant1].each do |participant|
          allow(participant).to receive(:verify_digital_signature).with(any_args).and_return(true)
          allow(participant).to receive(:assign_copyright).with(any_args).and_raise('The private key you inputted was invalid.', StandardError)
        end
        post :grant_with_private_key, params: params
        expect(flash[:notice]).to eq('The private key you inputted was invalid.')
        expect(response).to redirect_to(action: :grant,params:{id:2})
      end
    end          
  end

  describe 'update_publish_permissions' do
    context 'user clicks on the grant publishing rights to all past assignments button' do

      #verify user clicks on grant publishing rights to all assignments and redirect to grant page
      it 'redirects to grant page' do
        allow(AssignmentParticipant).to receive(:find).with('3').and_return(assignment_participant2)
        stub_current_user(student1, student1.role.name, student1.role)
        params ={id: 3, allow: 1}
        post :update_publish_permissions, params: params
        expect(response).to redirect_to(action: :grant)
      end
    end
      
    context 'user clicks on the deny publishing rights to all past assignments button' do

      #verify user clicks on deny publishing rights to all assignments and redirects to view page
      it 'redirects to view page' do
          allow(AssignmentParticipant).to receive(:where).with(user_id: 21).and_return([assignment_participant1])
        stub_current_user(student1, student1.role.name, student1.role)
        params ={id: 3, allow: 0}
        [assignment_participant1].each do |participant|
          allow(participant).to receive(:update_attribute).and_return(true)
          allow(participant).to receive(:save).and_return(true)
        end
        post :update_publish_permissions, params: params
        expect(response).to redirect_to(action: :view)
      end
    end      
  end
end
