class TeamsUser < ActiveRecord::Base
  belongs_to :user
  belongs_to :team
  has_one :team_user_node,:foreign_key => :node_object_id,:dependent => :destroy
  has_paper_trail

  def name
    self.user.name
  end

  def delete
    TeamUserNode.find_by_node_object_id(self.id).destroy
    team = self.team
    self.destroy
    if team.teams_users.length == 0
      team.delete
    end
  end

  def get_team_members(team_id)

  end

  #Removes entry in the TeamUsers table for the given user and given team id
  def self.remove_team(user_id, team_id)
    team_user = TeamsUser.where(['user_id = ? and team_id = ?', user_id, team_id]).first
    if team_user != nil
      team_user.destroy
    end
  end

  #Returns the first entry in the TeamUsers table for a given team id
  def self.first_by_team_id(team_id)
    TeamsUser.where("team_id = ?", team_id).first
  end

  #Determines whether a team is empty of not
  def self.is_team_empty(team_id)
    team_members = TeamsUser.where("team_id = ?", team_id)
    return team_members.nil? || team_members.length == 0
  end

  #Add member to the team they were invited to and accepted the invite for
  def self.add_member_to_invited_team(invitee_user_id, invited_user_id, assignment_id)
    users_teams = TeamsUser.where(['user_id = ?', invitee_user_id])
    for team in users_teams
      new_team = AssignmentTeam.where(['id = ? and parent_id = ?', team.team_id, assignment_id]).first
      if new_team != nil
        can_add_member = new_team.add_member(User.find(invited_user_id), assignment_id)
      end
    end
    return can_add_member
  end

  #2015-5-27 [zhewei]:
  #We just remove the topic_id field from the participants table.
  def self.team_id(assignment_id, user_id)
    #team_id variable represents the team_id for this user in this assignment
    team_id = nil
    teams_users = TeamsUser.where(user_id: user_id)
    teams_users.each do |teams_user|
      team = Team.find(teams_user.team_id)
      if team.parent_id == assignment_id
        team_id = teams_user.team_id
        break
      end
    end
    return team_id
  end
end
