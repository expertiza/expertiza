describe MentorManagement do
  # using let! so that state is automatically set up before each example group
  # this could also be accomplished with before(:each) and instance methods
  # but the rest of the code base makes use of let a lot, so this is consistent
  # with that, while achieving the same goal as before(:each)
  let!(:assignment) { create(:assignment, id: 999, auto_assign_mentor: true) }
  let!(:ta) { create(:teaching_assistant, id: 999) }
  let!(:student1) { create(:student, id: 998) }
  let!(:student2) { create(:student, id: 997) }
  let!(:mentor) { create(:participant, id: 998, user_id: 999, parent_id: assignment.id, duty: Participant::DUTY_MENTOR) }
  let!(:team) { create(:assignment_team, id: 999) }

  describe '#select_mentor' do
    it 'returns the mentor with the fewest teams they mentor' do
      allow(MentorManagement).to receive(:zip_mentors_with_team_count)
        .with(assignment.id)
        .and_return([mentor.id, 0])
      allow(User).to receive(:where).with(id: mentor.id).and_return([mentor])
      mentor_user = MentorManagement.select_mentor assignment.id
      expect(mentor_user).to eq mentor
    end
  end

  describe '#update_mentor_state' do
    it 'returns early if auto_assign_mentor is false' do
      no_mentor_assignment = FactoryBot.build(:assignment)
      allow(Assignment).to receive(:find).with(no_mentor_assignment.id).and_return(no_mentor_assignment)
      allow(Team).to receive(:find).with(team.id).and_return(team)
      MentorManagement.assign_mentor(no_mentor_assignment.id, team.id)
      expect(Team).to receive(:add_member).exactly(0).times
    end

    it 'returns early if the assignment has a topic' do
      allow(Assignment).to receive(:find).with(assignment.id).and_return(assignment)
      allow(Team).to receive(:find).with(team.id).and_return(team)

      allow(assignment).to receive(:topics?).and_return(true)

      MentorManagement.assign_mentor(assignment.id, team.id)
      expect(Team).to receive(:add_member).exactly(0).times
    end

    it 'returns early if the team has a topic assigned' do
      allow(Assignment).to receive(:find).with(assignment.id).and_return(assignment)
      allow(Team).to receive(:find).with(team.id).and_return(team)

      topic = FactoryBot.build(:topic)
      allow(team).to receive(:topics).and_return(topic)

      MentorManagement.assign_mentor(assignment.id, team.id)
      expect(Team).to receive(:add_member).exactly(0).times
    end

    it 'returns early if capacity is not met' do
      allow(Assignment).to receive(:find).with(assignment.id).and_return(assignment)
      allow(Team).to receive(:find).with(team.id).and_return(team)
      # we've added no one to this team, so we will not meet the capacity criteria
      MentorManagement.assign_mentor(assignment.id, team.id)
      expect(Team).to receive(:add_member).exactly(0).times
    end

    it 'returns early if team already has a mentor' do
      allow(Assignment).to receive(:find).with(assignment.id).and_return(assignment)
      allow(Team).to receive(:find).with(team.id).and_return(team)
      # stub the call to `team.participants` so that `any?` returns `true`
      allow(team).to receive(:participants).and_return([mentor])
      MentorManagement.assign_mentor(assignment.id, team.id)
      expect(Team).to receive(:add_member).exactly(0).times
    end

    it 'assigns a mentor to a team when the team size passes 50% max capacity' do
      allow(Assignment).to receive(:find).with(assignment.id).and_return(assignment)
      allow(Team).to receive(:find).with(team.id).and_return(team)

      # add 2 students to our team
      [student1, student2].each { |student| FactoryBot.create(:team_user, team_id: team.id, user_id: student.id) }

      allow(assignment).to receive(:topics?).and_return(false)
      allow(team).to receive(:topics).and_return(nil)

      allow(MentorManagement).to receive(:select_mentor).with(assignment.id).and_return(ta)
      allow(team).to receive(:add_member).and_return(true)

      # if we've made it this far without failing, then there's nothing
      # left for Mentor Management to test. The only question left to answer
      # is "does Team#add_member work as expected?," and that is tested elsewhere.
      # From The Magic Tricks of Testing Video (Week 9), it is not this class's job
      # to test whether Team works properly.
      MentorManagement.assign_mentor(assignment.id, team.id)
    end
  end

  describe '#user_a_mentor?' do
    it 'should return true if user is a mentor' do
      expect(MentorManagement.user_a_mentor?(student1)).to be false
      expect(MentorManagement.user_a_mentor?(ta)).to be true
    end
  end

  describe '#get_mentors_for_assignment' do
    it 'returns all mentors for the given assignment' do
      allow(Participant).to receive(:where)
        .with(parent_id: assignment.id, duty: Participant::DUTY_MENTOR)
        .and_return([mentor])
      mentor_user = MentorManagement.mentors_for_assignment(assignment.id).first
      expect(mentor_user).to eq mentor
    end
  end

  describe '#zip_mentors_with_team_count' do
    it 'returns sorted tuples of (mentor ID, # of teams they mentor)' do
      team_count = 3
      r = Random.new(42)
      team_ids = team_count.times.map do
        random_id = r.rand(1000..10_000)
        FactoryBot.create(:team, id: random_id)
        random_id
      end
      team_ids.each { |team_id| FactoryBot.create(:team_user, team_id: team_id, user_id: ta.id) }
      expect(MentorManagement.zip_mentors_with_team_count(assignment.id)).to eq [[mentor.user_id, team_count]]
    end
  end
end
