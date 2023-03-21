describe CourseNode do
  let(:course) { build(:course, id: 1, name: 'ECE517') }
  let(:course_node) { build(:course_node, id: 1) }
  let(:user1) { User.new name: 'abc', fullname: 'abc bbc', email: 'abcbbc@gmail.com', password: '123456789', password_confirmation: '123456789' }
  let(:assignment) { build(:assignment, id: 1) }
  before(:each) do
    course_node.node_object_id = 1
    course.private = true
    allow(course).to receive(:survey_distribution_id).and_return(1)
    allow(Course).to receive(:find_by).with(id: 1).and_return(course)
    allow(User).to receive(:find_by).with(id: 1).and_return(user1)
    allow(User).to receive(:find).with(1).and_return(user1)
    allow(user1).to receive(:id).and_return(1)
  end
  describe '#create_course_node' do
    it 'saves a course node with course data' do
      allow(CourseNode).to receive(:get_parent_id).and_return(1)
      expect(CourseNode.create_course_node(course)).to be_truthy
    end
  end
  describe '#table' do
    it 'returns courses' do
      expect(CourseNode.table).to eq('courses')
    end
  end
  describe '#get_course_query_conditions' do
    context 'when show and current user are set and you are not a TA' do
      it 'returns a string of conditions' do
        allow(user1).to receive(:teaching_assistant?).and_return(false)
        expect(CourseNode.get_course_query_conditions(true, 1)).to eq('courses.instructor_id = 1')
      end
    end
    context 'when show and current user are set and you are a TA' do
      it 'returns a string of conditions' do
        allow(user1).to receive(:teaching_assistant?).and_return(true)
        expect(CourseNode.get_course_query_conditions(true, 1)).to eq('courses.id in (?)')
      end
    end
    context 'when show and current user are not set and you are not a TA' do
      it 'returns a string of conditions' do
        allow(user1).to receive(:teaching_assistant?).and_return(false)
        expect(CourseNode.get_course_query_conditions(false, 1)).to eq('(courses.private = 0 or courses.instructor_id = 1)')
      end
    end
  end
  describe '#get_courses_managed_by_users' do
    context 'when you are not a TA' do
      it 'returns the user id' do
        allow(user1).to receive(:teaching_assistant?).and_return(false)
        expect(CourseNode.get_courses_managed_by_user(1)).to eq(1)
      end
    end
  end
  describe '#get_parent_id' do
    context 'when parent is found' do
      it 'returns the id of the parent folder' do
        parent = 'parent'
        allow(parent).to receive(:id).and_return(1)
        allow(TreeFolder).to receive(:find_by).with(name: 'Courses').and_return(course)
        allow(FolderNode).to receive(:find_by).with(node_object_id: 1).and_return(parent)
        expect(CourseNode.get_parent_id).to eq(1)
      end
    end
    context 'when parent is not found' do
      it 'returns nil' do
        parent = false
        allow(TreeFolder).to receive(:find_by).with(name: 'Courses').and_return(course)
        allow(FolderNode).to receive(:find_by).with(node_object_id: 1).and_return(parent)
        expect(CourseNode.get_parent_id).to eq(nil)
      end
    end
  end
  describe '#get_children' do
    it 'returns assignment node' do
      allow(AssignmentNode).to receive(:get).and_return([assignment])
      expect(course_node.get_children).to eq([assignment])
    end
  end
  describe '#get_private' do
    it 'returns whether the course is private' do
      expect(course_node.get_private).to be_truthy
    end
  end
  describe '#get_survey_distribution_id' do
    it 'returns whether the course is private' do
      expect(course_node.get_survey_distribution_id).to eq(1)
    end
  end
end
