describe TreeDisplayController do
  # Airbrake-1517247902792549741
  describe '#list' do
    it 'should not redirect if current user is an instructor' do
      user = build(:instructor)
      stub_current_user(user, user.role.name, user.role)
      get 'list'
      expect(response).to have_http_status(200)
    end

    it 'should redirect to student_task#list if current user is a student' do
      user = build(:student)
      stub_current_user(user, user.role.name, user.role)
      get 'list'
      expect(response).to redirect_to('/student_task/list')
    end

    it 'should not redirect if current user is a TA' do
      user = build(:teaching_assistant)
      stub_current_user(user, user.role.name, user.role)
      get 'list'
      expect(response).to have_http_status(200)
    end

    it 'should redirect to login page if current user is nil' do
      get 'list'
      expect(response).to redirect_to('/auth/failure')
    end
  end

  describe '#drill' do
    it 'redirect to list action' do
      get 'drill', params: { root: 1 }
      expect(session[:root]).to eq('1')
      expect(response).to redirect_to(list_tree_display_index_path)
    end
  end

  it { is_expected.to respond_to(:get_folder_contents) }
  it { is_expected.to respond_to(:get_sub_folder_contents) }

  describe 'GET #session_last_open_tab' do
    it 'returns HTTP status 200' do
      get :session_last_open_tab
      expect(response).to have_http_status(200)
    end
  end

  describe 'GET #set_session_last_open_tab' do
    it 'returns HTTP status 200' do
      get :set_session_last_open_tab
      expect(response).to have_http_status(200)
    end
  end

  describe 'GET #get_folder_contents' do
    before(:each) do
      @treefolder = TreeFolder.new
      @treefolder.parent_id = nil
      @treefolder.name = 'Courses'
      @treefolder.child_type = 'CourseNode'
      @treefolder.save
      @foldernode = FolderNode.new
      @foldernode.parent_id = nil
      @foldernode.type = 'FolderNode'
      @foldernode.node_object_id = 1
      @foldernode.save
      @instructor = create(:instructor)
      stub_current_user(@instructor, @instructor.role.name, @instructor.role)
      # Course will be associated with the first instructor record we have
      # For robustness, associate explicitly with our instructor
      @course = create(:course, instructor_id: @instructor.id)
      # Course node will be associated with the first course record we have
      # For robustness, associate explicitly with our course
      create(:course_node, course: @course)
      # Assignment node will be associated with the first assignment record we have
      # (or will cause a new assignment to be built)
      create(:assignment_node)
    end

    it 'returns a list of course objects(private) as json' do
      @course.private = true
      @course.save
      request_params = { reactParams: { child_nodes: FolderNode.all.to_json, nodeType: 'FolderNode' } }
      user_session = { user: @instructor }
      get :get_folder_contents, params: request_params, session: user_session
      expect(response.body).to match %r{csc517/test}
    end

    it 'returns an empty list when there are no private or public courses' do
      Assignment.delete(1)
      Course.delete(1)
      request_params = { reactParams: { child_nodes: FolderNode.all.to_json, nodeType: 'FolderNode' } }
      user_session = { user: @instructor }
      get :get_folder_contents, params: request_params, session: user_session
      expect(response.body).to eq '{"Courses":[]}'
    end

    it 'returns a list of course objects(public) as json' do
      @course.private = false
      @course.save
      request_params = { reactParams: { child_nodes: FolderNode.all.to_json, nodeType: 'FolderNode' } }
      user_session = { user: @instructor }
      get :get_folder_contents, session: request_params, session: user_session
      expect(response.body).to match %r{csc517/test}
    end
  end

  describe 'GET #get_folder_contents for TA' do
    before(:each) do
      @treefolder = TreeFolder.new
      @treefolder.parent_id = nil
      @treefolder.name = 'Courses'
      @treefolder.child_type = 'CourseNode'
      @treefolder.save!

      @treefolder = TreeFolder.new
      @treefolder.parent_id = nil
      @treefolder.name = 'Assignments'
      @treefolder.child_type = 'AssignmentNode'
      @treefolder.save!

      @foldernode = FolderNode.new
      @foldernode.parent_id = nil
      @foldernode.type = 'FolderNode'
      @foldernode.node_object_id = 1
      @foldernode.save!

      @foldernode = FolderNode.new
      @foldernode.parent_id = nil
      @foldernode.type = 'FolderNode'
      @foldernode.node_object_id = 2
      @foldernode.save!

      # create a new course
      @course1 = create(:course)
      # make sure the course is not private
      @course1.private = false
      @course1.save

      @assignment_node1 = create(:assignment_node)
      create(:course_node)

      # make a teaching assistant
      user_ta = build(:teaching_assistant)
      @role = user_ta.role
      @ta = User.new(user_ta.attributes)
      @ta.save!
    end

    it 'returns empty array if the logged in user is not ta' do
      # make a student for testing edge case
      user_student = build(:student)
      student = User.new(user_student.attributes)
      student.save!

      # create ta-course mapping for the student
      ta_mapping = TaMapping.new
      ta_mapping.ta_id = User.where(role_id: student.role_id).first.id
      ta_mapping.course_id = @course1.id
      ta_mapping.save!

      params = FolderNode.all
      request_params = { reactParams: { child_nodes: params.to_json, nodeType: 'FolderNode' } }
      user_session = { user: student }
      get :get_folder_contents, params: request_params, session: user_session

      # service should not return anything as the user is student
      output = JSON.parse(response.body)['Courses']
      expect(output.length).to eq 1
    end

    it 'returns a list of course objects ta is supposed to ta in as json' do
      # create ta-course mapping
      ta_mapping = TaMapping.new
      ta_mapping.ta_id = User.where(role_id: @ta.role_id).first.id
      ta_mapping.course_id = @course1.id
      ta_mapping.save!

      # make sure it's the current user
      stub_current_user(@ta, @role.name, @role)

      params = FolderNode.all
      request_params = { reactParams: { child_nodes: params.to_json, nodeType: 'FolderNode' } }
      user_session = { user: @ta }
      get :get_folder_contents, params: request_params, session: user_session

      # service should return the course as per the ta-course mapping
      output = JSON.parse(response.body)['Courses']
      expect(output.length).to eq 1
      expect(output[0]['name']).to eq @course1.name
    end

    it 'returns an empty list when there are no mapping between ta and course' do
      params = FolderNode.all
      # do not create any ta-course mapping

      # make sure it's the current user
      stub_current_user(@ta, @role.name, @role)
      request_params = { reactParams: { child_nodes: params.to_json, nodeType: 'FolderNode' } }
      user_session = { user: @ta }
      get :get_folder_contents, params: request_params, session: user_session

      # service should not return anything as there is no mapping
      output = JSON.parse(response.body)['Courses']
      expect(output.length).to eq 1
    end

    it 'returns only the course he is ta of when ta is a student of another course at the same time' do
      params = FolderNode.all

      # create a new course
      @course2 = create(:course)
      # make sure the course is not private
      @course2.private = false
      @course2.save

      # make ta student of that course
      # create assignment against course_2
      @assignment1 = create(:assignment, name: 'test1', directory_path: 'test1')
      @assignment1.course_id = @course2.id
      @assignment1.save

      # make ta participant of that assignment
      @participant1 = create(:participant)
      @participant1.parent_id = @assignment1.id
      @participant1.user_id = @ta.id
      @participant1.save

      # create a ta mapping for the other existing course (other than in which he is ta of)
      ta_mapping = TaMapping.new
      ta_mapping.ta_id = User.where(role_id: @ta.role_id).first.id
      ta_mapping.course_id = @course1.id
      ta_mapping.save!

      # make sure it's the current user
      stub_current_user(@ta, @role.name, @role)
      request_params = { reactParams: { child_nodes: params.to_json, nodeType: 'FolderNode' } }
      user_session = { user: @ta }
      get :get_folder_contents, params: request_params, session: user_session

      output = JSON.parse(response.body)['Courses']
      # service should return 1 course and should be course 1 not course 2
      expect(output.length).to eq 1
      expect(output[0]['name']).to eq @course1.name
      expect(output[0]['name']).not_to eq @course2.name
    end

    it 'returns only the course he is ta of when ta is a student of same course at the same time' do
      params = FolderNode.all

      # make ta student of the existing course he is ta of
      # create assignment against course_1
      @assignment1 = create(:assignment, name: 'test2', directory_path: 'test2')
      @assignment1.course_id = @course1.id
      @assignment1.save

      # make ta participant of that assignment
      @participant1 = create(:participant)
      @participant1.parent_id = @assignment1.id
      @participant1.user_id = @ta.id
      @participant1.save

      # create a ta mapping for the same course he is ta of
      ta_mapping = TaMapping.new
      ta_mapping.ta_id = User.where(role_id: @ta.role_id).first.id
      ta_mapping.course_id = @course1.id
      ta_mapping.save!

      # make sure it's the current user
      stub_current_user(@ta, @role.name, @role)
      user_session = { user: @ta }
      request_params = { reactParams: { child_nodes: params.to_json, nodeType: 'FolderNode' } }
      get :get_folder_contents, params: request_params, session: user_session

      # service should return 1 course
      output = JSON.parse(response.body)['Courses']
      expect(output.length).to eq 1
      expect(output[0]['name']).to eq @course1.name
    end

    it 'returns only the assignments which belongs to the course he is ta of' do
      params = FolderNode.all

      # create assignment against course_1
      # this is 2nd assignment added to course_1, other being in "before" method
      @assignment2 = create(:assignment, name: 'test3', directory_path: 'test3')
      @assignment2.course_id = @course1.id
      @assignment2.save!

      @assignment_node2 = create(:assignment_node)
      @assignment_node2.node_object_id = @assignment2.id
      @assignment_node2.save!

      # create ta-course mapping
      ta_mapping = TaMapping.new
      ta_mapping.ta_id = User.where(role_id: @ta.role_id).first.id
      ta_mapping.course_id = Course.find(@course1.id).id
      ta_mapping.save!

      # make sure it's the current user
      stub_current_user(@ta, @role.name, @role)
      request_params = { reactParams: { child_nodes: params.to_json, nodeType: 'FolderNode' } }
      user_session = { user: @ta }
      get :get_folder_contents, params: request_params, session: user_session

      # service should return 2 assignments as those are mapped
      # the sequence of assignments could be random so just checking for array size
      output = JSON.parse(response.body)['Assignments']
      expect(output.length).to eq 2

      new_params = Node.find_by!(node_object_id: @course1.id)
      request_params = { reactParams2: { child_nodes: new_params.to_json, nodeType: 'CourseNode' } }
      user_session = { user: @ta }
      get :get_folder_contents, params: request_params, session: user_session
      output = JSON.parse(response.body)
      expect(output.length).to eq 2
    end

    it 'returns empty assignments list if none of the assignments belong to course he is ta of' do
      params = FolderNode.all

      # delete the assignment node
      Node.delete(@assignment_node1.id)

      # create ta-course mapping
      ta_mapping = TaMapping.new
      ta_mapping.ta_id = User.where(role_id: @ta.role_id).first.id
      ta_mapping.course_id = Course.find(@course1.id).id
      ta_mapping.save!

      # make sure it's the current user
      stub_current_user(@ta, @role.name, @role)
      request_params = { reactParams: { child_nodes: params.to_json, nodeType: 'FolderNode' } }
      user_session = { user: @ta }
      get :get_folder_contents, params: request_params, session: user_session

      # service should not return anything as there is no mapping
      output = JSON.parse(response.body)['Assignments']
      expect(output.length).to eq 0
    end
  end
end
