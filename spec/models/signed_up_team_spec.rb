describe SignUpTopic do
  let(:topic_id) { 1 } # Define topic_id with a suitable value
  let(:team_id) { 2 }  # Define team_id with a suitable value
  let(:topic) { build(:topic) }
  let(:team) { create(:assignment_team, id: 1, name: 'team 1', users: [user, user2]) }
  let(:user) { create(:student) }
  let(:user2) { create(:student, username: 'qwertyui', id: 5) }
  
  describe '.drop_signup_record' do
    let(:instructor) { User.create!(username: 'Instructor', fullname: 'FullInstructor', email: 'instructor@example.com', password: 'securepassword', password_confirmation: 'securepassword') }
    let(:assignment) { Assignment.create!(name: 'Test Assignment', instructor_id: instructor.id, directory_path: 'test/path') }
    let(:topic) { SignUpTopic.create!(topic_name: 'Sample Topic', assignment: assignment) }
    let(:team) { Team.create!(name: 'Sample Team') }
  
    context 'when the signup record exists' do
      let!(:signup_record) { SignedUpTeam.create!(topic: topic, team: team) }
  
      it 'deletes the signup record' do
        expect {
          SignedUpTeam.drop_signup_record(topic.id, team.id)
        }.to change { SignedUpTeam.count }.by(-1)
      end
    end
  
    context 'when the signup record does not exist' do
      it 'does not raise an error' do
        expect {
          SignedUpTeam.drop_signup_record(topic.id, team.id) # Assuming there's no signup record for this topic and team
        }.not_to raise_error
      end
    end
  end
  

  describe '.drop_off_waitlists' do
    context 'when waitlisted records exist for the team' do
      before do
        create(:signed_up_team, team_id: team_id, is_waitlisted: true)
        create(:signed_up_team, team_id: team_id, is_waitlisted: true)
      end

      it 'deletes all waitlisted records for the team' do
        puts "Before: Waitlisted SignedUpTeam count: #{SignedUpTeam.where(team_id: team_id, is_waitlisted: true).count}"
        expect {
          SignedUpTeam.drop_off_waitlists(team_id)
        }.to change { SignedUpTeam.where(team_id: team_id, is_waitlisted: true).count }.by(-2)
        puts "After: Waitlisted SignedUpTeam count: #{SignedUpTeam.where(team_id: team_id, is_waitlisted: true).count}"
      end
    end

    context 'when no waitlisted records exist for the team' do
      it 'does not raise an error' do
        puts "Before: Waitlisted SignedUpTeam count: #{SignedUpTeam.where(team_id: team_id, is_waitlisted: true).count}"
        expect {
          SignedUpTeam.drop_off_waitlists(team_id)
        }.not_to raise_error
        puts "After: Waitlisted SignedUpTeam count: #{SignedUpTeam.where(team_id: team_id, is_waitlisted: true).count}"
      end
    end
  end

  describe '.topic_id_by_team_id' do
    let(:team_id_existing) { 1 }
    let(:team_id_non_existing) { 2 }
  
    it 'returns topic_id when team has signed up and not on waitlist' do
      # Create a SignedUpTeam record with team_id_existing and is_waitlisted: false
      signed_up_team = create(:signed_up_team, team_id: team_id_existing, is_waitlisted: false)
      expect(SignedUpTeam.topic_id_by_team_id(team_id_existing)).to eq(signed_up_team.topic_id)
    end
  
    it 'returns nil when team has signed up but is on waitlist' do
      # Create a SignedUpTeam record with team_id_existing and is_waitlisted: true
      create(:signed_up_team, team_id: team_id_existing, is_waitlisted: true)
      expect(SignedUpTeam.topic_id_by_team_id(team_id_existing)).to be_nil
    end
  
    it 'returns nil when team has not signed up' do
      expect(SignedUpTeam.topic_id_by_team_id(team_id_non_existing)).to be_nil
    end
  end
      
end
