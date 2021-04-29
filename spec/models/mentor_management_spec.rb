describe MentorManagement do
  # using let! so that state is automatically set up before each example group
  # this could also be accomplished with before(:each) and instance methods
  # but the rest of the code base makes use of let alot, so this is consistent
  # with that, while achieving the same goal as before(:each)
  let!(:assignment) { create(:assignment, id: 999) }
  let!(:ta) { create(:teaching_assistant, id: 999) }
  let!(:student) { create(:student, id: 998) }
  let!(:mentor) { create(:participant, id: 998, user_id: 999, parent_id: assignment.id, duty: Participant::DUTY_MENTOR)}

  describe '#select_mentor' do
    it 'returns the mentor with the fewest teams they mentor' do
      allow(MentorManagement).to receive(:zip_mentors_with_team_count)
                                   .with(assignment.id)
                                   .and_return([mentor.id, 0])
      allow(User).to receive(:where).with(id: mentor.id).and_return([mentor])
      mentor_user = MentorManagement.select_mentor assignment.id
      expect(mentor_user).to eq(mentor)
    end
  end

  describe '#update_mentor_state' do
    it 'assigns a mentor to a team when the team size passes 50% max capacity' do

    end
  end

  describe '#user_a_mentor?' do
    it 'should return true if user is a mentor' do
      expect(MentorManagement.user_a_mentor?(student)).to be false
      expect(MentorManagement.user_a_mentor?(ta)).to be true
    end
  end

  describe '#get_mentors_for_assignment' do
    it 'returns all mentors for the given assignment' do
      allow(Participant).to receive(:where)
                              .with(parent_id: assignment.id, duty: Participant::DUTY_MENTOR)
                              .and_return([mentor])
      mentor_user = MentorManagement.get_mentors_for_assignment(assignment.id).first
      expect(mentor_user).to eq(mentor)
    end
  end

  describe '#zip_mentors_with_team_count' do
    it 'returns an empty map' do
      expect(MentorManagement.zip_mentors_with_team_count(assignment.id)).to eq([])
    end

    it 'returns sorted tuples of (mentor ID, # of teams they mentor)' do
      team_count = 3
      r = Random.new(42)
      team_ids = team_count.times.map {
        random_id = r.rand(1000..10000)
        FactoryBot.create(:team, id: random_id)
        random_id
      }
      team_ids.each { |team_id| FactoryBot.create(:team_user, team_id: team_id, user_id: ta.id) }
      expect(MentorManagement.zip_mentors_with_team_count(assignment.id)).to eq([[mentor.user_id, team_count]])
    end
  end
end
