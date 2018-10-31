describe CourseController do
  let(:instructor) { build(:instructor, id: 6) }
  let(:student) { build(:student) }
  let(:course) { double('Course', instructor_id: 6, path: '/cscs', name: 'abc') }
  describe '#action_allowed?' do
    context 'when current user is student' do
      it 'disallows all actions' do
        user = student
        stub_current_user(user, user.role.name, user.role)
        expect(controller.send(:action_allowed?)).to be false
      end

      it 'allows all course actions' do
        user = instructor
        stub_current_user(user, user.role.name, user.role)
        expect(controller.send(:action_allowed?)).to be true
      end
    end
  end

  describe '#create' do
    it 'redirects to tree_display#list page after creating a new course' do
      allow(Course).to receive(:create).with(name: 'CSC999', private: false, institutions_id: 1, directory_path: '/cscs', info: 'hello', instructor_id: 6).and_return(double('Course', instructor_id: 6))
      allow(CourseNode).to receive(:create).with('1').and_return(double('CourseNode', node_object_id: 1, parent_id: 1))
      session = {user: instructor}
      params = {
        course: {
          name: 'CSC999',
          private: false,
          institutions_id: 1,
          directory_path: '/cscs',
          info: 'hello',
          instructor_id: session[:user].id
        }
      }

      post :create, params, session
      expect(flash[:error]).to eq 'error'
      expect(response).to redirect_to('/tree_display/list')
    end
  end

  describe '#edit' do
    context 'when @course is not nil' do
      it 'renders the course#edit page' do
        allow(Course).to receive(:find).with('1').and_return(double('Course', instructor_id: 6))
        session = {user: instructor}
        params = {id: 1}
        get :edit, params, session
        expect(response).to render_template(:edit)
      end
    end
  end

  describe '#delete' do
    it 'deletes the course and redirects to tree_display#list page' do
      allow(Course).to receive(:find).with('1').and_return(course)
      allow(course).to receive(:destroy).and_return(true)
      params = {id: 1}
      session = {user: instructor}
      post :delete, params, session
      expect(response).to redirect_to('/tree_display/list')
    end
  end

  describe '#new' do
    it 'sets the private instance variable' do
      params = {private:  1}
      session = {user: instructor}
      get :new, params, session
      expect(controller.instance_variable_get(:@private)).to eq('1')
    end
  end
end
