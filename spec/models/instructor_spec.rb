describe Instructor do
  let(:assignment) { build(:assignment, id: 1, name: 'no assignment') }
  let(:instructor) { build(:instructor, id: 6) }
  let(:participant1) { build(:participant, id: 1) }
  let(:participant2) { build(:participant, id: 2) }
  let(:team) { build(:assignment_team, id: 1, name: 'no team') }
  let(:course) { build(:course) }
  let(:user1) { User.new username: 'abc', name: 'abc bbc', email: 'abcbbc@gmail.com', password: '123456789', password_confirmation: '123456789' }
  let(:user2) { User.new username: 'abc', name: 'abc bbc', email: 'abcbbe@gmail.com', password: '123456789', password_confirmation: '123456789' }
  let(:ta_mapping1) { TaMapping.new }
  let(:ta_mapping2) { TaMapping.new }
  before(:each) do
    allow(ta_mapping1).to receive(:ta_id).and_return(1)
    allow(ta_mapping2).to receive(:ta_id).and_return(2)
  end
  describe '#list all' do
    it 'lists all of some object type associated with the instructor' do
      allow(Assignment).to receive(:where).with('instructor_id = ? OR private = 0', 6).and_return([assignment])
      expect(instructor.list_all(Assignment, instructor.id)).to eq([assignment])
    end
  end
  describe '#list mine' do
    it 'lists all of some object type that are public and associated with the instructor' do
      allow(Assignment).to receive(:where).with('instructor_id = ?', 6).and_return([assignment])
      expect(instructor.list_mine(Assignment, instructor.id)).to eq([assignment])
    end
  end
  describe '#get' do
    it 'gets all objects of a given type' do
      allow(Assignment).to receive(:where).with('id = ? AND (instructor_id = ? OR private = 0)', 1, 6).and_return([assignment])
      expect(instructor.get(Assignment, participant1.id, instructor.id)).to eq(assignment)
    end
  end
  describe '#my_tas' do
    it 'gets all TAs from the Courses associated with the instructor' do
      allow(Course).to receive(:where).and_return([course])
      allow(TaMapping).to receive(:where).and_return([ta_mapping1, ta_mapping2])
      expect(instructor.my_tas).to eq([1, 2])
    end
  end
  describe '#get_user_list' do
    it 'get all users from participants of a given assignments' do
      instructor_role = build(:role_of_instructor, id: 2, name: 'Instructor_role_test', description: '', parent_id: nil, default_page_id: nil)
      allow(Course).to receive(:where).with(instructor_id: 6).and_return([course])
      allow(course).to receive(:get_participants).and_return([participant1])
      allow(Assignment).to receive_message_chain(:includes, :where).and_return([assignment])
      allow(assignment).to receive(:participants).and_return([participant2])
      allow(participant1).to receive(:user).and_return(user1)
      allow(participant2).to receive(:user).and_return(user2)
      allow(instructor).to receive(:role).and_return(instructor_role)
      allow(user1).to receive(:role).and_return(instructor_role)
      allow(user2).to receive(:role).and_return(instructor_role)
      allow(instructor_role).to receive(:has_all_privileges_of?).and_return(true)
      expect(Instructor.get_user_list(instructor)).to eq([user1, user2])
    end
  end
end
