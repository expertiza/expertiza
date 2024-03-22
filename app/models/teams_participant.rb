class TeamsParticipant < ApplicationRecord
  belongs_to :user
  belongs_to :participant
  belongs_to :team
  has_one :team_user_node, foreign_key: 'node_object_id', dependent: :destroy
  has_paper_trail
  # attr_accessible :user_id, :team_id # unnecessary protected attributes

  def name(ip_address = nil)
    name = user.name(ip_address)

    # E2115 Mentor Management
    # Indicate that someone is a Mentor in the UI. The view code is
    # often hard to follow, and this is the best place we could find
    # for this to go.
    name += ' (Mentor)' if MentorManagement.user_a_mentor?(user)
    name
  end

  def delete
    TeamUserNode.find_by(node_object_id: id).destroy
    team = self.team
    destroy
    team.delete if team.teams_users.empty?
  end

  def get_team_members(team_id); end

  # Removes entry in the TeamUsers table for the given user and given team id
  def self.remove_team(user_id, team_id)
    team_user = TeamsUser.where('user_id = ? and team_id = ?', user_id, team_id).first
    team_user&.destroy
  end

  # Returns the first entry in the TeamUsers table for a given team id
  def self.first_by_team_id(team_id)
    TeamsUser.where('team_id = ?', team_id).first
  end

  # Determines whether a team is empty of not
  def self.team_empty?(team_id)
    team_members = TeamsUser.where('team_id = ?', team_id)
    team_members.blank?
  end

  # Add member to the team they were invited to and accepted the invite for
  def self.add_member_to_invited_team(invitee_user_id, invited_user_id, assignment_id)
    can_add_member = false
    users_teams = TeamsUser.where(['user_id = ?', invitee_user_id])
    users_teams.each do |team|
      new_team = AssignmentTeam.where(['id = ? and parent_id = ?', team.team_id, assignment_id]).first
      unless new_team.nil?
        can_add_member = new_team.add_member(User.find(invited_user_id), assignment_id)
      end
    end
    can_add_member
  end

  # 2015-5-27 [zhewei]:
  # We just remove the topic_id field from the participants table.
  def self.team_id(assignment_id, user_id)
    # team_id variable represents the team_id for this user in this assignment
    team_id = nil
    unless assignment_id.nil?
      participant_id = Assignment.find(assignment_id).participants.find_by(user_id: user_id).id

      # E2304: Fetch only based on participant_id after user_id is removed from teams_users table.
      teams_users = TeamsUser.where(user_id: user_id).or(TeamsUser.where(participant_id: participant_id))

      teams_users.each do |teams_user|
        team = Team.find(teams_user.team_id)
        if team.parent_id == assignment_id
          team_id = teams_user.team_id
          break
        end
      end
    end
    team_id
  end
  
    # E2404: Returns the User associated with this TeamsUser. Prefers the Participant's User, but falls back to user_id for legacy records.
  def user
    participant&.user || User.find_by(id: self[:user_id])
  end

  # E2404: Provides the ID of the associated User.
  def user_id
    user&.id
  end

  # E2404: Revised method to locate a TeamsUser record by team_id and user_id. It accounts for both legacy and current data models.
  def self.find_by_team_and_user(team_id, user_id)
    # Initial attempt to find by user_id for backward compatibility.
    teams_user = find_by(team_id: team_id, user_id: user_id)

    # If no result and team_id is valid, try finding by participant_id.
    if teams_user.blank? && team_id != "0"
      participant_id = Participant.find_by_user_and_assignment(user_id, Team.find(team_id).parent_id)&.id
      teams_user = find_by(team_id: team_id, participant_id: participant_id) unless participant_id.nil?
    end

    teams_user
  end

  # E2404: Fetches TeamsUser records for an array of user_ids within a specific assignment, considering both user_id and participant_id.
  def self.where_users_and_assignment(user_ids, assignment_id)
    participants = Participant.where(user_id: user_ids, parent_id: assignment_id)
    where(user_id: user_ids).or(where(participant_id: participants.pluck(:id)))
  end

  # Helper method to find a Participant by user_id and assignment_id, encapsulating the query for readability.
  def self.find_by_user_and_assignment(user_id, assignment_id)
    Assignment.find_by(id: assignment_id)&.participants&.find_by(user_id: user_id)
  end


end
