require 'rails_helper'

describe Invitation do
  let(:user2) { build(:student, id: 2) }
  let(:user3) { build(:student, id: 3) }
  let(:assignment) { build(:assignment, id: 1) }
  let(:team) { build(:assignment_team, id: 1, parent_id: 1) }
  let(:team2) { build(:assignment_team, id: 2, parent_id: 1) }
  let(:topic) { build(:topic, id: 1, assignment_id: 1) }
  let(:signed_up_team) { build(:signed_up_team, is_waitlisted: true) }
  let(:invitation) { build(:invitation, id: 1, team_id: 1, from_id: 1, to_id: 2) }
  let(:team_participant) { build(:teams_participant, id: 1, team_id: 1, participant_id: 1) }
  let(:participant2) { build(:participant, id: 2, user: user2) }
  let(:participant3) { build(:participant, id: 3, user: user3) }

  it { should belong_to :to_user }
  it { should belong_to :from_user }

  describe '#is_invited?' do
    context 'an invitation has been sent between user1 and user2' do
      it 'returns false' do
        allow(Invitation).to receive(:where).with('from_id = ? and to_id = ? and assignment_id = ? and reply_status = "W"',
                                                  user2.id, user3.id, assignment.id).and_return([Invitation.new])
        expect(Invitation.is_invited?(user2.id, user3.id, assignment.id)).to eq(false)
      end
    end
    context 'an invitation has not been sent between user1 and user2' do
      it 'returns true' do
        allow(Invitation).to receive(:where).with('from_id = ? and to_id = ? and assignment_id = ? and reply_status = "W"',
                                                  user2.id, user3.id, assignment.id).and_return([])
        expect(Invitation.is_invited?(user2.id, user3.id, assignment.id)).to eq(true)
      end
    end
  end

  describe '#accept_invitation' do
    context 'a user is not on a team and wishes to join a team with open slots' do
      it 'places the user on a team and returns true' do
        team_id = 0
        allow(TeamsUser).to receive(:team_empty?).with(team_id).and_return(false)
        allow(Invitation).to receive(:remove_users_sent_invites_for_assignment).with(user3.id, assignment.id).and_return(true)
        allow(TeamsUser).to receive(:add_member_to_invited_team).with(user2.id, user3.id, assignment.id).and_return(true)
        allow(Invitation).to receive(:update_users_topic_after_invite_accept).with(user2.id, user3.id, assignment.id).and_return(true)
        allow(MentorManagement).to receive(:assign_mentor)
        expect(Invitation.accept_invitation(team_id, user2.id, user3.id, assignment.id)).to eq(true)
      end
    end
    context 'a user is on a team and wishes to join a team with open slots' do
      it 'removes the user from their previous team, places the user on a team, and returns true' do
        team_id = 1
        allow(TeamsUser).to receive(:team_empty?).with(team_id).and_return(true)
        allow(AssignmentTeam).to receive(:find).with(team_id).and_return(team)
        allow(team).to receive(:assignment).and_return(assignment)
        allow(SignedUpTeam).to receive(:release_topics_selected_by_team_for_assignment).with(team_id, assignment.id).and_return(true)
        allow(AssignmentTeam).to receive(:remove_team_by_id).with(team_id).and_return(true)
        allow(Invitation).to receive(:remove_users_sent_invites_for_assignment).with(user3.id, assignment.id).and_return(true)
        allow(TeamsUser).to receive(:add_member_to_invited_team).with(user2.id, user3.id, assignment.id).and_return(true)
        allow(Invitation).to receive(:update_users_topic_after_invite_accept).with(user2.id, user3.id, assignment.id).and_return(true)
        allow(MentorManagement).to receive(:assign_mentor)
        expect(Invitation.accept_invitation(team_id, user2.id, user3.id, assignment.id)).to eq(true)
      end
    end
    context 'a user is on a team and wishes to join a team without slots' do
      it 'removes the user from their previous team, and returns false' do
        team_id = 1
        allow(TeamsUser).to receive(:team_empty?).with(team_id).and_return(true)
        allow(AssignmentTeam).to receive(:find).with(team_id).and_return(team)
        allow(team).to receive(:assignment).and_return(assignment)
        allow(SignedUpTeam).to receive(:release_topics_selected_by_team_for_assignment).with(team_id, assignment.id).and_return(true)
        allow(AssignmentTeam).to receive(:remove_team_by_id).with(team_id).and_return(true)
        allow(Invitation).to receive(:remove_users_sent_invites_for_assignment).with(user3.id, assignment.id).and_return(true)
        allow(TeamsUser).to receive(:add_member_to_invited_team).with(user2.id, user3.id, assignment.id).and_return(false)
        expect(Invitation.accept_invitation(team_id, user2.id, user3.id, assignment.id)).to eq(false)
      end
    end
    context 'a user is not on a team and wishes to join a team without slots' do
      it 'returns false' do
        team_id = 0
        allow(TeamsUser).to receive(:team_empty?).with(team_id).and_return(false)
        allow(Invitation).to receive(:remove_users_sent_invites_for_assignment).with(user3.id, assignment.id).and_return(true)
        allow(TeamsUser).to receive(:add_member_to_invited_team).with(user2.id, user3.id, assignment.id).and_return(false)
        expect(Invitation.accept_invitation(team_id, user2.id, user3.id, assignment.id)).to eq(false)
      end
    end
  end

  describe '#remove_users_sent_invites_for_assignment' do
    it 'deletes the invitations sent for a given assignment' do
      invites = [Invitation.new, Invitation.new]
      allow(Invitation).to receive(:where).with('from_id = ? and assignment_id = ?', user2.id, assignment.id).and_return(invites)
      expect(Invitation.remove_users_sent_invites_for_assignment(user2.id, assignment.id)).to be(invites)
    end
  end

  describe '#update_users_topic_after_invite_accept' do
    context 'the invited user was in another team before accepting their invitation' do
      it 'updates the team participant mapping' do
        allow(TeamsParticipant).to receive(:team_id).with(assignment.id, user2.id).and_return(team.id)
        allow(TeamsParticipant).to receive(:team_id).with(assignment.id, user3.id).and_return(team2.id)
        allow(TeamsParticipant).to receive(:find_by).with(team_id: team2.id, participant_id: participant3.id).and_return(team_participant)
        allow(TeamsParticipant).to receive(:update).with(team_participant.id, team_id: team.id).and_return(true)
        expect(Invitation.update_users_topic_after_invite_accept(user2.id, user3.id, assignment.id)).to be true
      end
    end

    context 'the invited user was never in another team before accepting their invitation' do
      it 'creates a team participant mapping' do
        created_teams_participant = TeamsParticipant.new
        created_teams_participant.team_id = team.id
        created_teams_participant.participant_id = participant3.id
        allow(TeamsParticipant).to receive(:team_id).with(assignment.id, user2.id).and_return(team.id)
        allow(TeamsParticipant).to receive(:team_id).with(assignment.id, user3.id).and_return(nil)
        allow(TeamsParticipant).to receive(:create).with(team_id: team.id, participant_id: participant3.id).and_return(created_teams_participant)
        teams_participant = Invitation.update_users_topic_after_invite_accept(user2.id, user3.id, assignment.id)
        expect(teams_participant.team_id).to eq(team.id)
        expect(teams_participant.participant_id).to eq(participant3.id)
      end
    end
  end

  describe '#remove_waitlists_for_team' do
    it 'removes a currently waitlisted team from the topic waitlist and removes the team from all other waitlists it was on' do
      allow(SignedUpTeam).to receive(:find_by).with(topic_id: topic.id, is_waitlisted: true).and_return(signed_up_team)
      allow(SignUpTopic).to receive(:find).with(topic.id).and_return(topic)
      allow(Waitlist).to receive(:cancel_all_waitlists).with(team.id, topic.assignment_id).and_return([topic])
      expect(Invitation.remove_waitlists_for_team(topic.id, assignment.id)).to eq([topic])
    end
  end

  describe '#accept' do
    it 'accepts the invitation and adds the user to the team' do
      allow(TeamsParticipant).to receive(:create).with(team_id: 1, participant_id: 2).and_return(team_participant)
      expect(invitation.accept).to be true
    end
  end

  describe '#decline' do
    it 'declines the invitation' do
      expect(invitation.decline).to be true
    end
  end

  describe '#from_user' do
    it 'returns the user who sent the invitation' do
      allow(User).to receive(:find).with(1).and_return(build(:user))
      expect(invitation.from_user).to be_a(User)
    end
  end

  describe '#to_user' do
    it 'returns the user who received the invitation' do
      allow(User).to receive(:find).with(2).and_return(build(:user))
      expect(invitation.to_user).to be_a(User)
    end
  end

  describe '#team' do
    it 'returns the team associated with the invitation' do
      allow(Team).to receive(:find).with(1).and_return(build(:team))
      expect(invitation.team).to be_a(Team)
    end
  end

  describe '#valid?' do
    it 'validates the invitation' do
      allow(TeamsParticipant).to receive(:where).with(team_id: 1).and_return([team_participant])
      expect(invitation.valid?).to be true
    end
  end

  describe '#reply_status' do
    it 'returns the reply status of the invitation' do
      expect(invitation.reply_status).to eq('W')
    end
  end

  describe '#reply_status=' do
    it 'sets the reply status of the invitation' do
      invitation.reply_status = 'A'
      expect(invitation.reply_status).to eq('A')
    end
  end
end
