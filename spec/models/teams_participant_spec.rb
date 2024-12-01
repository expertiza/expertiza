require 'rails_helper'

describe TeamsParticipant do
  let(:assignment) { build(:assignment, id: 1, name: 'no assgt') }
  let(:participant) { build(:participant, user_id: 1) }
  let(:invited) { build(:participant, user_id: 2) }
  let(:user) { build(:student, id: 1, name: 'John Doe', fullname: 'John Doe', participants: [participant]) }
  let(:user2) { build(:student, id: 2, name: 'Jane Doe', fullname: 'Jane Doe', participants: [invited]) }
  let(:team) { build(:assignment_team, id: 1, name: 'no team', users: [user]) }
  let(:team_participant) { build(:team_participant, id: 1, team: team, user: user, participant: participant) }
  let(:team_participant_node) { instance_double('TeamParticipantNode') }

#   let(:team1) { Team.create!(name: 'Sample Team') }  # Creates a team with the necessary attributes
#   let(:user1) { User.create!(name: 'Sample User') }  # Replace with necessary attributes for user
#   let!(:team_participant1) { TeamsParticipant.create!(team: team, user: user) }  # Associates team_participant with team and user
    
#   let(:team) { create(:assignment_team) }
#   let(:user) { build(:student, id: 1, name: 'no name', fullname: 'no one', participants: [participant]) }
#   let(:participant) { build(:participant, user_id: 1) }
#   let(:team_participant) { build(:team_participant, id: 1, user: user, participant: participant) }
#   let(:team_participant) { create(:team_participant, team: team, participant: participant) }

  describe 'associations' do
    it { should belong_to(:participant) }
    it { should belong_to(:team) }
    it { should have_one(:team_participant_node).dependent(:destroy) }
  end

  describe '#name' do
    it 'returns the participant name' do
      allow(User).to receive(:name).and_return('John Doe')
      expect(team_participant.name).to eq('John Doe')
    end

    context 'when participant is a mentor' do
      it 'appends (Mentor) to the name' do
        allow(User).to receive(:name).and_return('John Doe')
        allow(MentorManagement).to receive(:user_a_mentor?).and_return(true)
        expect(team_participant.name).to eq('John Doe (Mentor)')
      end
    end
  end

  describe '#delete_teams_participant_with_dependencies' do
    it 'calls delete_associated_team_participant_node' do
        expect(team_participant).to receive(:delete_associated_team_participant_node)
        team_participant.delete_teams_participant_with_dependencies
    end

    it 'calls delete_team_if_no_participants' do
        expect(team_participant).to receive(:delete_team_if_no_participants)
        team_participant.delete_teams_participant_with_dependencies
    end

    it 'calls destroy_teams_participant_instance' do
        expect(team_participant).to receive(:destroy_teams_participant_instance)
        team_participant.delete_teams_participant_with_dependencies
    end

    it 'destroys the associated TeamParticipantNode' do
      expect(TeamParticipantNode).to receive(:find_by).with(node_object_id: team_participant.id).and_return(team_participant_node)
      expect(team_participant_node).to receive(:destroy)
      team_participant.delete_associated_team_participant_node
    end

    it 'destroys itself' do
      expect(team_participant).to receive(:destroy)
      team_participant.destroy_teams_participant_instance
    end

    context 'when it is the last participant in the team' do
      it 'deletes the team' do
        allow(team).to receive(:teams_participants).and_return([double]) # Simulate a non-empty participants array
        expect(team).not_to receive(:delete_teams_participant_with_dependencies)
        team_participant.delete_team_if_no_participants
      end
    end
  end

  describe '.remove_participant' do
    before do
      allow(TeamsParticipant).to receive(:find_by).with(user_id: user.id, team_id: team.id).and_return(team_participant)
    end

    context 'when the team participant exists' do
      it 'destroys the team participant' do
        expect(team_participant).to receive(:destroy)
        TeamsParticipant.remove_team_participant(user.id, team.id)
      end
    end

    context 'when the team participant does not exist' do
      before do
        allow(TeamsParticipant).to receive(:find_by).with(user_id: user.id, team_id: team.id).and_return(nil)
      end
  
      it 'does not call destroy' do
        expect(team_participant).not_to receive(:destroy)
        TeamsParticipant.remove_team_participant(user.id, team.id)
      end
    end
  end

  describe '.team_empty?' do
    it 'returns true when the team has no participants' do
      allow(TeamsParticipant).to receive(:where).with(team_id: team.id).and_return([])
      expect(TeamsParticipant.team_empty?(team.id)).to be true
    end

    it 'returns false when the team has participants' do
      allow(TeamsParticipant).to receive(:where).with(team_id: team.id).and_return([team_participant])
      expect(TeamsParticipant.team_empty?(team.id)).to be false
    end
  end

  describe '.add_accepted_invitee_to_team' do

    it 'adds a member to the invited team' do
      allow(TeamsParticipant).to receive(:where).with(user_id: participant.id).and_return([team_participant])
      allow(AssignmentTeam).to receive(:find_by).with(id: team.id, parent_id: assignment.id).and_return(team)
      allow(User).to receive(:find).with(invited.id).and_return(invited)
      allow(team).to receive(:add_member).with(invited, assignment.id).and_return(true)
      expect(TeamsParticipant.add_accepted_invitee_to_team(participant.id, invited.id, assignment.id)).to be true
    end
  end

  describe '.team_id' do
    let(:assignment) { create(:assignment) }

    it 'returns the team id for a participant in an assignment' do
      new_team = create(:assignment_team, parent_id: assignment.id)
      team_participant = create(:team_participant, team: new_team, user: user)
      
      expect(TeamsParticipant.find_team_id(assignment.id, user.id)).to eq(new_team.id)
    end

    it 'returns nil if the participant is not in a team for the assignment' do
      expect(TeamsParticipant.find_team_id(assignment.id, user.id)).to be_nil
    end
  end
end
