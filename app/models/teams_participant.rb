class TeamsParticipant < ApplicationRecord
  belongs_to :user #kept for backward compatibility
  belongs_to :team
  belongs_to :participant
  has_one :team_participant_node, foreign_key: 'node_object_id', dependent: :destroy
  has_paper_trail

  # Returns the name of the user associated with this TeamsParticipant.
  # Appends '(Mentor)' if the user is identified as a mentor to indicate in UI
  def name(ip_address = nil)
    name = user.name(ip_address)
    name += ' (Mentor)' if MentorManagement.user_a_mentor?(user)
    name
  end

  # Deletes the associated team user node, removes the team if empty, 
  # and then destroys this TeamsParticipant instance
  def delete
    remove_team_participant_node
    remove_team_if_participants_empty
    remove_teams_participant_instance
  end

  def remove_team_participant_node
    team_participant_node = TeamParticipantNode.find_by(node_object_id: id)
    team_participant_node&.destroy
  end

  def remove_team_if_participants_empty
    team = self.team
    team.delete if team.teams_participants.empty?
  end

  def remove_teams_participant_instance
    destroy
  end

  # Removes the entry in the TeamsParticipant table for the given user and team IDs
  def self.remove_team_participant(user_id, team_id)
    team_participant = TeamsParticipant.find_by(user_id: user_id, team_id: team_id)
    team_participant&.destroy
  end

  # Returns the first TeamsParticipant entry for the given team ID
  def self.first_participant_for_team(team_id)
    TeamsParticipant.find_by(team_id: team_id)
  end

  # Determines whether a team is empty by checking if it has any members
  def self.team_empty?(team_id)
    team_members = TeamsParticipant.where(team_id: team_id)
    team_members.blank?
  end

  # Adds a member to the team they were invited to and accepted the invite for
  def self.add_accepted_invitee_to_team(inviter_user_id, invited_user_id, assignment_id)
    can_add_member = false
    participants_teams = TeamsParticipant.where(user_id: inviter_user_id) # Fetches all teams the inviter is a participant of
    participants_teams.each do |team|
      assigned_team = AssignmentTeam.find_by(id: team.team_id, parent_id: assignment_id) # Finds the team for given assignment
      can_add_member = assigned_team&.add_member(User.find(invited_user_id), assignment_id) if assigned_team
    end
    can_add_member
  end

  # Finds the team ID for a given assignment and user
  def self.find_team_id(assignment_id, user_id)
    # team_id variable represents the team_id for this user in this assignment
    TeamsParticipant.where(user_id: user_id).find do |participant|
      team = Team.find_by(id: participant.team_id) if participant.team_id # Finds the team associated with the participant
      team&.parent_id == assignment_id # Checks if the team's parent ID matches given assignment ID
    end&.team_id  
  end
end
