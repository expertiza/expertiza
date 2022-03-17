describe BadgesController do
  let(:super_admin) { build(:superadmin, id: 1, role_id: 5) }
  let(:admin) { build(:admin, id: 3) }
  let(:instructor1) { build(:instructor, id: 10, role_id: 3, parent_id: 3, name: 'Instructor1') }
  let(:student1) { build(:student, id: 21, role_id: 1) }
  let(:ta) { build(:teaching_assistant, id: 6) }
  let(:badge) {build(:badge, id:1, name: 'test', description: 'test desc', image_name: 'test.png')}  

  describe '#action_allowed?' do
      context 'when the role of current user is Super-Admin' do
        it 'allows certain action' do
          stub_current_user(super_admin, super_admin.role.name, super_admin.role)
          expect(controller.send(:action_allowed?)).to be_truthy
        end
      end
      context 'when the role of current user is Instructor' do
        it 'allows certain action' do
          stub_current_user(instructor1, instructor1.role.name, instructor1.role)
          expect(controller.send(:action_allowed?)).to be_truthy
        end
      end
      context 'when the role of current user is Student' do
        it 'refuses certain action' do
          stub_current_user(student1, student1.role.name, student1.role)
          expect(controller.send(:action_allowed?)).to be_falsey
        end
      end
      context 'when the role of current user is Teaching Assisstant' do
        it 'allows certain action' do
          stub_current_user(ta, ta.role.name, ta.role)
          expect(controller.send(:action_allowed?)).to be_truthy
        end
      end
      context 'when the role of current user is Admin' do
        it 'allows certain action' do
          stub_current_user(admin, admin.role.name, admin.role)
          expect(controller.send(:action_allowed?)).to be_truthy
        end
      end
    end
  
  describe '#new' do
    context 'when user wants to create a new form' do
      it 'renders badges#new page' do
        get :new
        expect(get: 'badges/new').to route_to('badges#new')
      end
    end
    context 'when user tries to create a new badge' do
      it 'renders the create new form' do
        allow(Badge).to receive(:new).and_return(badge)
        params = {}
        session = { user: instructor1 }
        get :new, params, session
        expect(response).to render_template('new')
      end
    end
  end

  describe 'redirect_to_assignment' do
    context 'when user action is successful' do
      it 'redirects to assignment page' do
        session[:return_to] ||= 'http://test.host/assignments/844/edit'
        get :redirect_to_assignment
        expect(get: 'badges/redirect_to_assignment').to route_to('badges#redirect_to_assignment')
      end
    end

    context 'when user action is successful to redirect' do
        it 'redirects to assignment page interior' do
          stub_current_user(ta, ta.role.name, ta.role)
          session[:return_to] ||= 'http://test.host/assignments/844/edit'
          get :redirect_to_assignment
          response.should redirect_to("http://test.host/assignments/844/edit")
      end
	  end
  end

  describe '#create' do
    context 'when all the fields are correctly entered' do
        it 'should save the badge successfully' do
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
        post :create, params, session, "file" => @file
        expect(response).to redirect_to 'http://test.host/assignments/844/edit'
      end
    end

    context 'when image_file is empty' do
      it 'should throw an error' do
        @file = nil
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
        post :create, params, session, "file" => @file
        expect(response).to render_template('new')
      end
    end
    
    context 'when badge name is empty' do
      it 'should throw an error' do
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
        post :create, params, session, "file" => @file
        expect(response).to render_template('new')
      end
    end
    
    context 'when badge description is empty' do
		it 'should throw an error' do
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
			post :create, params, session, "file" => @file
			expect(response).to render_template('new')
      end
    end
  end
end
