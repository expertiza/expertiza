class TeamsUser < ApplicationRecord
  belongs_to :user
  belongs_to :team
  belongs_to :participant
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
    team_user = TeamsUser.find_by_team_id_and_user_id(team_id, user_id)
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

  # Fetch teams_user from team_id from teams table and user_id from participants table
  def self.find_by_team_id_and_user_id(team_id, user_id)
    if team_id != "0"
      assignment_id = Team.find(team_id).parent_id
      participant_id = Assignment.find(assignment_id).participants.find_by(user_id: user_id).id
      teams_user = TeamsUser.find_by(team_id: team_id, participant_id: participant_id)
    end
    teams_user
  end

  # Fetch all the teams_user s with team_id and assignment_id
  def self.where_user_ids_and_assignment_id(user_ids, assignment_id)
    participant_ids = Assignment.find(assignment_id).participants.where(user_id: user_ids).pluck(:id)
    TeamsUser.where(participant_id: participant_ids)
  end

  # Fetch teams_user s from user_id and assignment_id
  def self.find_in_assignment_by_user_ids(user_ids, assignment_id)
    participant_ids = Assignment.find(assignment_id).participants.where(user_id: user_ids).pluck(:id)
    TeamsUser.where(user_id: user_ids).or(TeamsUser.where(participant_id: participant_ids))
  end

  # Add member to the team they were invited to and accepted the invite for
  def self.add_member_to_invited_team(invitee_user_id, invited_user_id, assignment_id)
    can_add_member = false
    users_teams = TeamsUser.where_user_ids_and_assignment_id([invitee_user_id], assignment_id)
    users_teams.each do |team|
      new_team = AssignmentTeam.where(['id = ? and parent_id = ?', team.team_id, assignment_id]).first
      unless new_team.nil?
        participant = Assignment.find(assignment_id).participants.find_by(user_id: invited_user_id)
        can_add_member = new_team.add_participant_to_team(participant, assignment_id)
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
      # E2283: Fetch only based on participant_id after user_id is removed from teams_users table.
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

  # E2283: Just return 'participant.user' after user_id is removed from teams_users table.
  def user
    if participant
      participant.user
    else
      User.find(self[:user_id])
    end
  end

  def user_id
    user.id
  end
end
