describe CoursesController do
  let(:instructor) { build(:instructor, id: 6) }
  let(:instructor2) { build(:instructor, id:6666)}
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
        session = { user: instructor }
        params = { id: 1 }
        get :edit, params, session
        expect(response).to render_template(:edit)
      end
    end
  end

  describe '#delete' do
    it 'deletes the course and redirects to tree_display#list page' do
      allow(Course).to receive(:find).with('1').and_return(course)
      allow(course).to receive(:destroy).and_return(true)
      params = { id: 1 }
      session = { user: instructor }
      post :delete, params, session
      expect(response).to redirect_to('/tree_display/list')
    end
  end

  describe '#new' do
    it 'sets the private instance variable' do
      params = { private: 1 }
      session = { user: instructor }
      get :new, params, session
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
      params = { id: 1 }
      session = { instructor_id: 1 }
      post :update, params, session
      expect(response).to be_redirect
    end
  end

  describe '#auto_complete_for_user_name' do
    it 'should return a list of users' do
      allow(User).to receive(:find).with(:all, { conditions: [ 'LOWER(login) LIKE ?', '%test%' ], limit: 10 }).and_return([])
      get :auto_complete_for_user_name, user: { login: 'test' }
      expect(response).to be_redirect
    end
  end

  #todo
  describe '#copy' do
    let(:new_course) { double('Course', id: 1, name: 'new_course', directory_path: 'test') }
    # let(:new_course2) { double('Course', id: 1, name: 'new_course2', directory_path: 'test2', instructor_id: 6)}

    context 'when new course id fetches successfully' do
      it 'redirects to the new course' do
        allow(instructor).to receive(:id).and_return(6)
        allow(course).to receive(:dup).and_return(new_course)
        allow(new_course).to receive(:save).and_return(true)
        # allow(new_course).to receive(:instructor_id).and_return(6)
        allow(Course).to receive(:find).with('1').and_return(new_course)

        params = { id: 1 }
        session = { user: instructor }

        get :copy, params, session
        expect(response).to be_redirect
        # expect(response).to redirect_to(edit_course_path(new_course))
      end
    end

    context 'when course is not found' do
      it 'redirects to tree_display#list page' do
        allow(instructor).to receive(:id).and_return(6)
        allow(course).to receive(:copy_course_index_path).and_return(new_course)
        allow(new_course).to receive(:save).and_return(true)
        allow(Course).to receive(:find).with('1').and_return(new_course)
        params = { id: 1 }
        session = { user: instructor }
        get :copy, params, session
        expect(response).to redirect_to('/tree_display/list')
      end
    end
  end

  describe '#view_teaching_assistants' do
    let(:course) { double('Course', instructor_id: 6, path: '/cscs', name: 'abc') }
    let(:ta) { build(:teaching_assistant, id: 8) }
    before(:each) do
      allow(Course).to receive(:find).with('1').and_return(course)
      allow(Ta).to receive(:find_all_by_course_id).with('1').and_return([ta])
    end

    it 'should render the view_teaching_assistants page' do
      allow(Course).to receive(:find).with('1').and_return(course)
      allow(course).to receive(:instructor_id).and_return(1)
      params = { id: 1 }
      session = { instructor_id: 1 }
      get :view_teaching_assistants, params, session
      expect(controller.instance_variable_get(:@ta_mappings)).to eq(nil)
    end
  end

  describe '#add_ta' do
    it 'should add a ta to the course' do
      allow(Course).to receive(:find).with('1').and_return(course)
      allow(course).to receive(:add_ta).and_return(true)
      params = { id: 1 }
      session = { instructor_id: 1 }
      post :add_ta, params, session
      expect(response).to be_redirct
    end
  end

  describe '#remove_ta' do
    it 'should remove a ta from the course' do
      allow(Course).to receive(:find).with('1').and_return(course)
      allow(course).to receive(:remove_ta).and_return(true)
      params = { id: 1 }
      session = { instructor_id: 1 }
      post :remove_ta, params, session
      expect(response).to be_redirct
    end
  end

  describe '#set_course_fields' do
    it 'should set the course fields' do
      allow(Course).to receive(:find).with('1').and_return(course)
      allow(course).to receive(:set_course_fields).and_return(true)
      params = { id: 1 }
      session = { instructor_id: 1 }
      post :set_course_fields, params, session
      expect(response).to redirect_to('/')
    end
  end
end
