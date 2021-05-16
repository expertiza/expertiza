describe CourseTeam do
  let(:course) { build(:course, id: 1, name: 'ECE517') }
  let(:course_team1) { build(:course_team, id: 1) }
  let(:course_team2) { build(:course_team, id: 2) }
  describe '#get_teams' do
    it 'returns the associated teams with the course' do
      allow(CourseTeam).to receive(:where).with(parent_id: 1).and_return([course_team1, course_team2])
      expect(course.get_teams.length).to eq(2)
      expect(course.get_teams).to eq([course_team1, course_team2])
    end
  end
end