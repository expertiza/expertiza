describe CourseTeam do
  let(:course) { build(:course, id: 1, name: 'ECE517') }
  let(:course_team1) { build(:course_team, id: 1) }
  let(:course_team2) { build(:course_team, id: 2) }
  let(:instructor) { build(:instructor, id: 6) }
  let(:user1) { User.new name: 'abc', fullname: 'abc bbc', email: 'abcbbc@gmail.com', password: '123456789', password_confirmation: '123456789' }
  describe '#get_teams' do
    it 'returns the associated teams with the course' do
      allow(CourseTeam).to receive(:where).with(parent_id: 1).and_return([course_team1, course_team2])
      expect(course.get_teams.length).to eq(2)
      expect(course.get_teams).to eq([course_team1, course_team2])
    end
  end
  describe '#path' do
    context 'when there is no associated instructor' do
      it 'an error is raised' do
        allow(course).to receive(:instructor_id).and_return(nil)
        expect{course.path}.to raise_error("Path can not be created. The course must be associated with an instructor.")
      end
    end
    context 'when there is no associated instructor' do
      it 'an error is raised' do
        allow(course).to receive(:instructor_id).and_return(6)
        allow(User).to receive(:find).with(6).and_return(user1)
        expect(course.path).to eq('')        
      end
    end
  end
end