describe BadgesController do
  let(:super_admin) { build(:superadmin, id: 1, role_id: 5) }
  let(:admin) { build(:admin, id: 3) }
  let(:instructor1) { build(:instructor, id: 10, role_id: 3, parent_id: 3, username: 'Instructor1') }
  let(:student1) { build(:student, id: 21, role_id: 1) }
  let(:ta) { build(:teaching_assistant, id: 6) }
  let(:badge) {build(:badge, id:1, name: 'test', description: 'test desc', image_name: 'test.png')}  

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
  
    #check if student is restricted from performing the actions
    it 'refuses student from performing certain action' do
      stub_current_user(student1, student1.role.name, student1.role)
      expect(controller.send(:action_allowed?)).to be_falsey
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
  
  describe '#new' do
    context 'when user wants to create a new badge' do

      #verify new badges url is called
      it 'calls the new#badge page url' do
        get :new
        expect(get: 'badges/new').to route_to('badges#new')
      end

      #verify user is able to enter details in the new badge form
      it 'renders the create new form and allow the user to enter details' do
        allow(Badge).to receive(:new).and_return(badge)
        params = {}
        session = { user: instructor1 }
        get :new, params: params, session: session
        expect(response).to render_template('new')
      end
    end
  end

  describe 'redirect_to_assignment' do
    context 'after user successfully creates a badge' do

      #verify redirect_to_assignment url is called
      it 'calls the redirect_to_assignment url' do
        session[:return_to] ||= 'http://test.host/assignments/844/edit'
        get :redirect_to_assignment
        expect(get: 'badges/redirect_to_assignment').to route_to('badges#redirect_to_assignment')
      end
    
      #verify if it redirects to the assignment page
      it 'redirects to the assignment page' do
        stub_current_user(ta, ta.role.name, ta.role)
        session[:return_to] ||= 'http://test.host/assignments/844/edit'
        get :redirect_to_assignment
        expect(response).to redirect_to "http://test.host/assignments/844/edit"
      end
	  end
  end

  describe '#create' do
    context 'when user enters all the required badge details correctly' do

        #verify badge is saved successfully when all details are entered correctly and redirect to assignments page
        it 'saves the badge successfully' do
        @file = fixture_file_upload('app/assets/images/badges/test.png', 'image/png')
        allow(@file).to receive(:original_filename).and_return("test.png")
        session = { user: instructor1 }
        params = {
          badge:{
            name: 'test',
            description: 'test badge',
            image_name: 'test.png',
          image_file: @file
          }
        }
        session[:return_to] ||= 'http://test.host/assignments/844/edit'
        allow(Badge).to receive(:get_id_from_name).with('test').and_return(badge)
        allow(Badge).to receive(:get_image_name_from_name).with('test').and_return(badge)
        post :create, params: params, session: session
        expect(response).to redirect_to 'http://test.host/assignments/844/edit'
      end
    end

    context 'when user forgets to enter few of the required badge details' do
      
      #verify error thrown when image file is missing and redirect to new template
      it 'throws an error for missing image file' do
        session = { user: instructor1 }
        params = {
          badge:{
            name: 'test',
            description: 'test badge',
            image_name: 'test.png'
          }
        }
        session[:return_to] ||= 'http://test.host/assignments/844/edit'
        allow(Badge).to receive(:get_id_from_name).with('test').and_return(badge)
        allow(Badge).to receive(:get_image_name_from_name).with('test').and_return(badge)
        post :create, params: params, session: session
        expect(response).to render_template('new')
      end
    
      #verify error thrown when badge name is missing and redirect to new template
      it 'throws an error for missing badge name' do
        @file = fixture_file_upload('app/assets/images/badges/test.png', 'image/png')
        allow(@file).to receive(:original_filename).and_return("test.png")
        session = { user: instructor1 }
        params = {
        badge:{
          name: '',
          description: 'test badge',
          image_name: 'test.png',
          image_file: @file
          }
        }
        session[:return_to] ||= 'http://test.host/assignments/844/edit'
        allow(Badge).to receive(:get_id_from_name).with('test').and_return(badge)
        allow(Badge).to receive(:get_image_name_from_name).with('test').and_return(badge)
        post :create, params: params, session: session
        expect(response).to render_template('new')
      end
    
      #verify error thrown when image description is missing and redirect to new template
      it 'throws an error for missing badge description' do
        @file = fixture_file_upload('app/assets/images/badges/test.png', 'image/png')
        allow(@file).to receive(:original_filename).and_return("test.png")
        session = { user: instructor1 }
        params = {
        badge:{
          name: 'test',
          description: '',
          image_name: 'test.png',
          image_file: @file
        }
        }
        session[:return_to] ||= 'http://test.host/assignments/844/edit'
        allow(Badge).to receive(:get_id_from_name).with('test').and_return(badge)
        allow(Badge).to receive(:get_image_name_from_name).with('test').and_return(badge)
        post :create, params: params, session: session
        expect(response).to render_template('new')   
      end
    end
  end
end
