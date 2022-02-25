describe CoursesController do
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
    end
    context 'when current user is instructor' do
      it 'allows all course actions' do
        user = instructor
        stub_current_user(user, user.role.name, user.role)
        expect(controller.send(:action_allowed?)).to be true
      end
    end
  end

  describe '#create' do
    it 'redirects to tree_display#list page after creating a new course' do
      expect { create(:course) }.to change(Course, :count).by(1)
    end
  end

  describe '#edit' do
    context 'when @course is not nil' do
      it 'renders the course#edit page' do
        allow(Course).to receive(:find).with('1').and_return(double('Course', instructor_id: 6))
        user_session = { user: instructor }
        request_params = { id: 1 }
        get :edit, params: request_params, session: user_session
        expect(response).to render_template(:edit)
      end
    end
  end

  describe '#delete' do
    it 'deletes the course and redirects to tree_display#list page' do
      allow(Course).to receive(:find).with('1').and_return(course)
      allow(course).to receive(:destroy).and_return(true)
      request_params = { id: 1 }
      user_session = { user: instructor }
      post :delete, params: request_params, session: user_session
      expect(response).to redirect_to('/tree_display/list')
    end
  end

  describe '#new' do
    it 'sets the private instance variable' do
      request_params = { private: 1 }
      user_session = { user: instructor }
      get :new, params: request_params, session: user_session
      expect(controller.instance_variable_get(:@private)).to eq('1')
    end
  end

  describe '#create' do
    let(:course_double) { double('OODD', instructor_id: 2, path: '/cs', name: 'xyz') }
    before(:each) do
      allow(Course).to receive(:new).and_return(course_double)
      allow(course_double).to receive(:save).and_return(true)
    end

    it 'redirects to the correct url' do
      post :create
      expect(response).to redirect_to root_url
    end
  end

  describe '#update' do
    it 'checks updated is saved' do
      allow(Course).to receive(:find).with('1').and_return(course)
      allow(course).to receive(:destroy).and_return(true)
      request_params = { id: 1 }
      user_session = { instructor_id: 1 }
      post :update, params: request_params, session: user_session
      expect(response).to be_redirect
    end
  end
end
