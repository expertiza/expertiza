class TeamsParticipant < ApplicationRecord
  # Alias user_id to participant_id for legacy code compatibility
  alias_attribute :user_id, :participant_id

  belongs_to :participant, class_name: 'User', foreign_key: 'participant_id'
  belongs_to :team
  has_one :team_participant_node, foreign_key: 'node_object_id', dependent: :destroy
  has_paper_trail

  # Returns the participant's name, appending " (Mentor)" if applicable.
  def name(ip_address = nil)
    participant_name = participant.name(ip_address)
    participant_name += ' (Mentor)' if MentorManagement.user_a_mentor?(participant)
    participant_name
  end

  # Deletes the participant record and cleans up the related node.
  # Also deletes the team if it no longer has any participants.
  def delete
    team_participant_node&.destroy
    team_obj = team
    destroy
    team_obj.delete if team_obj.teams_participants.empty?
  end

  # Placeholder for team members retrieval logic.
  def get_team_members(team_id)
    # TODO: Implement retrieval of team members for the given team_id.
  end

  # Removes the entry in the TeamsParticipants table for the given participant and team.
  def self.remove_team(participant_id, team_id)
    record = TeamsParticipant.find_by(participant_id: participant_id, team_id: team_id)
    record&.destroy
  end

  # Returns the first participant entry for the given team id.
  def self.first_by_team_id(team_id)
    TeamsParticipant.find_by(team_id: team_id)
  end

  # Determines whether a team has no participants.
  def self.team_empty?(team_id)
    TeamsParticipant.where(team_id: team_id).empty?
  end

  # Renamed method: adds a member to the team they were invited to.
  # Verifies that both the invitee and invited participants exist, fetches team IDs in a batch,
  # and then adds the member using the associated assignment team.
  def self.add_member_to_inviting_team(invitee_participant_id, invited_participant_id, assignment_id)
    invitee = User.find_by(id: invitee_participant_id)
    invited = User.find_by(id: invited_participant_id)
    return false if invitee.nil? || invited.nil?

    team_ids = TeamsParticipant.where(participant_id: invitee.id).pluck(:team_id)
    return false if team_ids.empty?

    new_team = AssignmentTeam.where(id: team_ids, parent_id: assignment_id).first
    return false if new_team.nil?

    new_team.add_member(invited, assignment_id)
  end

  # Returns the team id for a participant in a given assignment.
  def self.team_id(assignment_id, participant_id)
    tp = TeamsParticipant.joins(:team)
                         .where(participant_id: participant_id, teams: { parent_id: assignment_id })
                         .first
    tp&.team_id
  end
end
