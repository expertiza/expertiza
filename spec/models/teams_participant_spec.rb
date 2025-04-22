# spec/models/teams_participant_spec.rb
require 'rails_helper'

RSpec.describe TeamsParticipant, type: :model do
  let(:assignment)  { create(:assignment) }
  let(:team)        { create(:assignment_team, parent_id: assignment.id) }
  let(:participant) { create(:participant, parent_id: assignment.id) }
  let(:duty)        { create(:duty) }

  subject { build(:teams_participant, team: team, participant: participant, duty: duty) }

  describe 'associations' do
    it { is_expected.to belong_to(:team) }
    it { is_expected.to belong_to(:participant) }
    it { is_expected.to belong_to(:duty).optional }
  end

  describe 'validations' do
    subject { existing }
    let!(:existing) { create(:teams_participant, team: team, participant: participant) }

    it { is_expected.to validate_presence_of(:team_id) }
    it { is_expected.to validate_presence_of(:participant_id) }
    it {
      is_expected.
        to validate_uniqueness_of(:participant_id).
        scoped_to(:team_id).
        with_message("is already a member of this team")
    }
  end

  describe '.team_id' do
    let!(:tp) { create(:teams_participant, team: team, participant: participant) }

    it 'returns the team.id for that user in that assignment' do
      expect(described_class.team_id(assignment.id, participant.user_id)).to eq(team.id)
    end

    it 'returns nil if user_id not on any team for that assignment' do
      expect(described_class.team_id(assignment.id, 999_999)).to be_nil
    end
  end

  describe '.team_empty?' do
    it 'is true when there are no members' do
      expect(described_class.team_empty?(team.id)).to be true
    end

    it 'is false once you add at least one participant' do
      create(:teams_participant, team: team, participant: participant)
      expect(described_class.team_empty?(team.id)).to be false
    end
  end

  describe '.add_member_to_invited_team' do
    let(:inviter)            { create(:user) }
    let(:invited)            { create(:user) }
    let(:inviter_participant){ create(:participant, user: inviter, parent_id: assignment.id) }
    let(:invited_participant){ create(:participant, user: invited, parent_id: assignment.id) }

    before do
      # inviter must already be on the team
      create(:teams_participant, team: team, participant: inviter_participant)
    end

    context 'when both inviter and invited are valid participants and team not full' do
      it 'returns true and creates a new TeamsParticipant' do
        expect {
          result = described_class.add_member_to_invited_team(inviter.id, invited.id, assignment.id)
          expect(result).to be true
        }.to change(described_class, :count).by(1)
      end
    end

    context 'when inviter is not on the team' do
      it 'returns false' do
        TeamsParticipant.destroy_all
        expect(described_class.add_member_to_invited_team(inviter.id, invited.id, assignment.id)).to be false
      end
    end

    context 'when invited user is not a participant in the assignment' do
      it 'returns false' do
        invited_participant.destroy
        expect(described_class.add_member_to_invited_team(inviter.id, invited.id, assignment.id)).to be false
      end
    end

    context 'when the team is full' do
      it 'returns false' do
        allow_any_instance_of(AssignmentTeam).to receive(:full?).and_return(true)
        expect(described_class.add_member_to_invited_team(inviter.id, invited.id, assignment.id)).to be false
      end
    end
  end

  describe '.get_team_members' do
    let(:p1){ create(:participant, parent_id: assignment.id) }
    let(:p2){ create(:participant, parent_id: assignment.id) }

    before do
      create(:teams_participant, team: team, participant: p1)
      create(:teams_participant, team: team, participant: p2)
    end

    it 'returns an array of User objects for that team' do
      members = described_class.get_team_members(team.id)
      expect(members).to match_array [p1.user, p2.user]
    end
  end

  describe '.get_teams_for_user' do
    let(:user)        { create(:user) }
    let(:participant) { create(:participant, user: user, parent_id: assignment.id) }
    let(:t1)          { create(:assignment_team, parent_id: assignment.id) }
    let(:t2)          { create(:assignment_team, parent_id: assignment.id) }

    before do
      create(:teams_participant, team: t1, participant: participant)
      create(:teams_participant, team: t2, participant: participant)
    end

    it 'returns all teams that the user is on' do
      expect(described_class.get_teams_for_user(user.id)).to match_array [t1, t2]
    end

    it 'returns an empty array if the user has no teams' do
      described_class.destroy_all
      expect(described_class.get_teams_for_user(user.id)).to eq []
    end
  end
end
