class TeamsParticipant < ApplicationRecord
  belongs_to :user #kept for backward compatibility
  belongs_to :team
  belongs_to :participant
  has_one :team_participant_node, foreign_key: 'node_object_id', dependent: :destroy
  has_paper_trail

  # Returns the name of the participant associated with this TeamsParticipant.
  # Appends '(Mentor)' if the participant is identified as a mentor to indicate in UI
  def name(ip_address = nil)
    name = user.name(ip_address)
    name += ' (Mentor)' if MentorManagement.user_a_mentor?(user)
    name
  end

  # Deletes the associated team participant node, removes the team if it's empty,
  # and then destroys this TeamsParticipant instance.
  def delete_teams_participant_with_dependencies
    delete_associated_team_participant_node
    delete_team_if_no_participants
    destroy_teams_participant_instance
  end

  # Deletes the associated TeamParticipantNode for this TeamsParticipant
  def delete_associated_team_participant_node
    team_participant_node = TeamParticipantNode.find_by(node_object_id: id)
    team_participant_node&.destroy
  end

  # Deletes the associated Team if no participants remain
  def delete_team_if_no_participants
    team = self.team
    team.delete if team.teams_participants.empty?
  end

  # Destroys the TeamsParticipant instance itself
  def destroy_teams_participant_instance
    destroy
  end

  # Removes the entry in the TeamsParticipant table for the given participant and team IDs
  def self.remove_team_participant(user_id, team_id)
    team_participant = TeamsParticipant.find_by(user_id: user_id, team_id: team_id)
    team_participant&.destroy
  end

  # Determines whether a team is empty by checking if it has any members
  def self.team_empty?(team_id)
    team_members = TeamsParticipant.where(team_id: team_id)
    team_members.blank?
  end

  # Adds a member to the team they were invited to and accepted the invite for
  # [E2456]: Method name renamed for better clarity:
  # The original method name `add_member_to_invited_team` was ambiguous.
  # The new name `add_accepted_invitee_to_team` explicitly communicates
  # that the method is about adding an invited user who has accepted the invitation.
  def self.add_accepted_invitee_to_team(inviter_user_id, invited_user_id, assignment_id)
    can_add_member = false
    participants_teams = TeamsParticipant.where(user_id: inviter_user_id) # Fetches all teams the inviter is a participant of
    participants_teams.each do |team|
      assigned_team = AssignmentTeam.find_by(id: team.team_id, parent_id: assignment_id) # Finds the team for given assignment
      can_add_member = assigned_team&.add_member(User.find(invited_user_id), assignment_id) if assigned_team
    end
    can_add_member
  end

  # Finds the team ID for a given assignment and participant
  # [E2456]: Method name renamed to `find_team_id` for better alignment with its purpose:
  # The original name `team_id` was too generic and lacked clear intent. 
  # `find_team_id` indicates that this method retrieves the team ID for a specific assignment and user.
  def self.find_team_id(assignment_id, user_id)
    # team_id variable represents the team_id for this participant in this assignment
    TeamsParticipant.where(user_id: user_id).find do |participant|
      team = Team.find_by(id: participant.team_id) if participant.team_id # Finds the team associated with the participant
      team&.parent_id == assignment_id # Checks if the team's parent ID matches given assignment ID
    end&.team_id  
  end
end
