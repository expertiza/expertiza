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

  describe '#auto_complete_for_user_name' do
    it 'should return a list of users' do
      allow(User).to receive(:find).with(:all, { conditions: [ 'LOWER(login) LIKE ?', '%test%' ], limit: 10 }).and_return([])
      get :auto_complete_for_user_name, params: {user: { login: 'test' }}
      expect(response).to be_redirect
    end
  end

  describe '#copy' do
    let(:ccc) { build(:course)}

    context 'when new course id fetches successfully' do
      it 'redirects to the new course' do
        allow(Course).to receive(:find).with('1').and_return(ccc)
        allow(ccc).to receive(:dup).and_return(ccc)
        allow(ccc).to receive(:save!).and_return(true)
        allow(CourseNode).to receive(:get_parent_id).and_return(1)
        allow(CourseNode).to receive(:create).and_return(true)

        params = { id: 1 }
        session = { user: instructor }
        get :copy, params: params, session: session
        expect(response).to redirect_to('/course/edit')
      end
    end

    # Cannot redirect to root_url when copy course failed
    # context 'when course is not found' do
    #   it 'redirects to tree_display#list page' do
    #     allow(Course).to receive(:find).with('1').and_return(ccc)
    #     allow(ccc).to receive(:dup).and_return(ccc)
    #     allow(ccc).to receive(:save!).and_return(StandardError)
    #     allow(CourseNode).to receive(:get_parent_id).and_return(-1)
    #     allow(CourseNode).to receive(:create).and_return(StandardError)
    #
    #     params = { id: 1 }
    #     session = { user: instructor }
    #     get :copy, params, session
    #     expect(response).to redirect_to root_url
    #     # expect(response).to raise_error
    #   end
    # end
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
      get :view_teaching_assistants, params: params, session: session
      expect(controller.instance_variable_get(:@ta_mappings)).to eq(nil)
    end
  end

  describe '#add_ta' do
    let(:user) { build(:student)}
    let(:course) { build(:course)}

    it 'should add a ta to the course' do
      allow(Course).to receive(:find).with('1').and_return(course)
      allow(User).to receive(:find).with('2').and_return(user)
      allow(TaMapping).to receive(:create).and_return(true)
      allow(Role).to receive(:find_by_name).with('Teaching Assistant').and_return(true)
      allow(user).to receive(:save).and_return(true)

      params = { course_id: 1, user: { username: 'Teaching Assistant' } }
      post :add_ta, params: params
      expect(response).to be_redirect
    end
  end

  describe '#remove_ta' do
    let(:ta) { build(:student)}
    let(:course) { build(:course)}
    let(:ta_mapping) { build(:ta_mapping)}

    it 'should remove a ta from the course' do
      allow(TaMapping).to receive(:find).with('1').and_return(ta_mapping)
      allow(User).to receive(:find).with('1').and_return(ta)
      allow(ta_mapping).to receive(:destroy).and_return(true)
      allow(Course).to receive(:find).with('1').and_return(course)

      params = { id: 1 }
      post :remove_ta, params: params
      expect(response).to be_redirect
    end
  end

  describe '#set_course_fields' do
    it 'should set the course fields' do
      allow(Course).to receive(:find).with('1').and_return(course)
      allow(course).to receive(:set_course_fields).and_return(true)
      params = { id: 1 }
      session = { instructor_id: 1 }
      post :set_course_fields, params: params, session: session
      expect(response).to redirect_to('/')
    end
  end
end
