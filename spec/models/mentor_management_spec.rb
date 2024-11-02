describe MentorManagement do
  # using let! so that state is automatically set up before each example group
  # this could also be accomplished with before(:each) and instance methods
  # but the rest of the code base makes use of let a lot, so this is consistent
  # with that, while achieving the same goal as before(:each)
  let!(:assignment) { create(:assignment, id: 999, auto_assign_mentor: true) }
  let!(:ta) { create(:teaching_assistant, id: 999) }
  let!(:student1) { create(:student, id: 998) }
  let!(:student2) { create(:student, id: 997) }
  let!(:mentor) { create(:participant, id: 998, user_id: 999, parent_id: assignment.id, can_mentor: true) }
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
                              .with(parent_id: assignment.id, can_mentor: true)
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

  #   E2351 Testing: Mentor Management for Assignments without Topics
  describe "select_mentor" do
    context "when there are mentors available for the assignment" do
      it "returns the mentor with the lowest team count for the given assignment" do
      # Test scenario 1
      # Given an assignment_id
      # When there are multiple mentors with different team counts for the assignment
      # Then it should return the mentor with the lowest team count
   
      # Test scenario 2
      # Given an assignment_id
      # When there are multiple mentors with the same lowest team count for the assignment
      # Then it should return the first mentor in the list
   
      # Test scenario 3
      # Given an assignment_id
      # When there is only one mentor available for the assignment
      # Then it should return that mentor
      end
    end

    context "when there are no mentors available for the assignment" do
      it "returns nil" do
        # Test scenario 4
        # Given an assignment_id
        # When there are no mentors available for the assignment
        # Then it should return nil

        # Create a new assignment
        a = FactoryBot.create(:assignment, id: 997, directory_path: 'OSS_project', auto_assign_mentor: true)
        # Since there are no mentors associated with this assignment, should return nil
        expect(MentorManagement.select_mentor(a.id)).to eq nil
      end
    end
  end
  describe '.assign_mentor' do
    context 'when assignments cannot accept mentors' do
      it 'does not assign a mentor' do
        # test scenario
        # Create an assignment that doesn't auto assign mentors
        a = FactoryBot.create(:assignment, id: 997, directory_path: 'P1', auto_assign_mentor: false)
        # There should be no assigning of mentors
        expect(Team).to receive(:add_member).exactly(0).times
      end
    end

    context 'when the assignment or team already have a topic' do
      it 'does not assign a mentor' do
        # Assignment already has topic
        a = Assignment.find(assignment.id)
        t = Team.find(team.id)

        allow(a).to receive(:topics?).and_return(true)
        MentorManagement.assign_mentor(assignment.id, t.id)
        expect(Team).to receive(:add_member).exactly(0).times

        # Team has topic
        a = Assignment.find(assignment.id)
        t = Team.find(team.id)

        allow(a).to receive(:topics?).and_return(true)
        MentorManagement.assign_mentor(assignment.id, t.id)
        expect(Team).to receive(:add_member).exactly(0).times

        allow(Assignment).to receive(:find).with(assignment.id).and_return(assignment)
        allow(Team).to receive(:find).with(team.id).and_return(team)

        topic = FactoryBot.build(:topic)
        allow(team).to receive(:topics).and_return(topic)

        MentorManagement.assign_mentor(assignment.id, team.id)
        expect(Team).to receive(:add_member).exactly(0).times
      end
    end

    context 'when the team size has not reached > 50% of capacity' do
      it 'does not assign a mentor' do
        # test scenario
        allow(Assignment).to receive(:find).with(assignment.id).and_return(assignment)
        allow(Team).to receive(:find).with(team.id).and_return(team)

        # Add a student to a team (less than half)
        FactoryBot.create(:team_user, team_id: team.id, user_id: student1.id)

        # Make sure assignment and team has no topic assigned
        allow(assignment).to receive(:topics?).and_return(false)
        allow(team).to receive(:topics).and_return(nil)

        allow(MentorManagement).to receive(:select_mentor).with(assignment.id).and_return(ta)
        allow(team).to receive(:add_member).and_return(true)

        # Attempt to assign mentor but shouldn't
        MentorManagement.assign_mentor(assignment.id, team.id)
        expect(Team).to receive(:add_member).exactly(0).times
      end
    end

    context 'when there is already a mentor in place' do
      it 'does not assign a mentor' do
        # test scenario
        allow(Assignment).to receive(:find).with(assignment.id).and_return(assignment)
        allow(Team).to receive(:find).with(team.id).and_return(team)

        # add 2 students to our team
        [student1, student2].each { |student| FactoryBot.create(:team_user, team_id: team.id, user_id: student.id) }

        allow(assignment).to receive(:topics?).and_return(false)
        allow(team).to receive(:topics).and_return(nil)

        allow(MentorManagement).to receive(:select_mentor).with(assignment.id).and_return(ta)
        allow(team).to receive(:add_member).and_return(true)
        # Mentor is assigned to the team
        MentorManagement.assign_mentor(assignment.id, team.id)

        # Attempt to assign mentor again but shouldn't
        MentorManagement.assign_mentor(assignment.id, team.id)
        expect(Team).to receive(:add_member).exactly(0).times
      end
    end

    context 'when all conditions are met' do
      it 'assigns a mentor and notifies the team of the mentor assignment' do
        # test scenario
        allow(Assignment).to receive(:find).with(assignment.id).and_return(assignment)
        allow(Team).to receive(:find).with(team.id).and_return(team)

        # add 2 students to a team
        [student1, student2].each { |student| FactoryBot.create(:team_user, team_id: team.id, user_id: student.id) }
        allow(assignment).to receive(:topics?).and_return(false)
        allow(team).to receive(:topics).and_return(nil)

        allow(MentorManagement).to receive(:select_mentor).with(assignment.id).and_return(ta)
        allow(team).to receive(:add_member).and_return(true)
        # Attempt to send email to mentor and teammates
        MentorManagement.assign_mentor(assignment.id, team.id)

        # expect(MentorManagement).to receive(:notify_team_of_mentor_assignment)
      end
    end
  end
  # This test should be handled by Mailer test file
  # describe '.notify_team_of_mentor_assignment' do
  #   context 'when a mentor is assigned to a team' do
  #     it 'sends an email notification to all team members' do
  #     end
  #
  #     it 'includes the mentor\'s full name and email in the email body' do
  #     end
  #
  #     it 'includes the assignment name in the email body' do
  #     end
  #
  #     it 'includes the current team members\' full names and emails in the email body' do
  #     end
  #
  #     it 'sends the email with the subject "[Expertiza]: New Mentor Assignment"' do
  #     end
  #
  #     it 'delivers the email immediately' do
  #     end
  #   end
  # end
  describe ".user_a_mentor?" do
    context "when the user is a mentor" do
      it "returns true" do
        # Test scenario 1: User is a mentor
        # User with id 1 is a mentor
        user = double("User", id: 1)
        expect(Participant).to receive(:exists?).with(user_id: 1, can_mentor: true).and_return(true)
        expect(described_class.user_a_mentor?(user)).to be true
      end
    end

    context "when the user is not a mentor" do
      it "returns false" do
        # Test scenario 2: User is not a mentor
        # User with id 2 is not a mentor
        user = double("User", id: 2)
        expect(Participant).to receive(:exists?).with(user_id: 2, can_mentor: true).and_return(false)
        expect(described_class.user_a_mentor?(user)).to be false
      end
    end
  end
  describe ".mentors_for_assignment" do
    context "when given a valid assignment_id" do
      it "returns an array of mentors assigned to the assignment" do
        # Test scenario 1
        # Given a valid assignment_id
        # When calling .mentors_for_assignment(assignment_id)
        # Then it should return an array of mentors assigned to the assignment
        allow(Assignment).to receive(:find).with(assignment.id).and_return(assignment)

        mentors = MentorManagement.mentors_for_assignment(assignment.id)
        expect(mentors).to_not be_empty
        expect(mentors.count).to eq 1

        # Test scenario 2
        # Given a valid assignment_id with multiple mentors assigned
        # When calling .mentors_for_assignment(assignment_id)
        # Then it should return an array containing all the mentors assigned to the assignment
        mentor2 = FactoryBot.create(:participant, can_mentor: true)
        mentors = MentorManagement.mentors_for_assignment(assignment.id)
        expect(mentors.count).to eq 2

        # Test scenario 3
        # Given a valid assignment_id with no mentors assigned
        # When calling .mentors_for_assignment(assignment_id)
        # Then it should return an empty array
        a = FactoryBot.create(:assignment, id: 1200, directory_path: 'OSS', auto_assign_mentor: true)
        expect(MentorManagement.mentors_for_assignment(a.id)).to be_empty
      end
    end

    context "when given an invalid assignment_id" do
      it "returns an empty array" do
        # Test scenario 4
        # Given an invalid assignment_id
        # When calling .mentors_for_assignment(assignment_id)
        # Then it should return an empty array
        expect(MentorManagement.mentors_for_assignment(005)).to be_empty
      end
    end
  end
  describe ".zip_mentors_with_team_count" do
    context "when given an assignment_id" do
      it "returns an empty array if mentor_ids is empty" do
        # Test case for when mentor_ids is empty
        a = FactoryBot.create(:assignment, id: 997, directory_path: 'A1', auto_assign_mentor: true)
        expect(MentorManagement.zip_mentors_with_team_count(a.id)).to be_empty
      end

      it "returns an array of mentor_ids sorted by team count" do
        # Test case for when mentor_ids is not empty
        a = FactoryBot.create(:assignment, id: 997, directory_path: 'A2', auto_assign_mentor: true)
        # Create mentors for this assignment
        ta1 = FactoryBot.create(:teaching_assistant, username: 'ta1', id: 1002)
        FactoryBot.create(:participant, id: 1001, user_id: 1002, parent_id: a.id, duty: Participant::DUTY_MENTOR)
        # Assign a mentor to a team
        allow(Team).to receive(:find).with(team.id).and_return(team)
        [student1, student2].each { |student| FactoryBot.create(:team_user, team_id: team.id, user_id: student.id) }
        MentorManagement.assign_mentor(a.id, team.id)
      
        mentors = MentorManagement.zip_mentors_with_team_count(assignment.id)
        expect(mentors).to_not be_empty
        #expect(mentors[0]).to eq [999,1]
	#expect(mentors[1]).to eq [1002,0]  
    end
    end
  end
end

