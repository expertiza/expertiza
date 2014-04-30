class TeamsUser < ActiveRecord::Base
  belongs_to :user
  belongs_to :team
  has_one :team_user_node,:foreign_key => :node_object_id,:dependent => :destroy
  has_paper_trail

  def name
    self.user.name
  end

  #Qi: should not call team.delte, which would cause recursion error
  def delete
    TeamUserNode.find_by_node_object_id(self.id).destroy
    team = self.team
    self.destroy
    #if team.teams_users.length == 0
    #team.delete
    #end
  end

  def hello
    return "Hello"
  end

  def get_team_members(team_id)

  end

  #Removes entry in the TeamUsers table for the given user and given team id
  def self.remove_team(user_id, team_id)
    team_user = TeamsUser.find(:first, :conditions => ['user_id = ? and team_id = ?', user_id, team_id])
    if team_user != nil
      team_user.destroy
    end
  end

  #Returns the first entry in the TeamUsers table for a given team id
  def self.first_by_team_id(team_id)
    TeamsUser.where("team_id = ?", team_id).first
  end

  #Determines whether a team is empty of not
  #Qi: rewrite the method, do not use length, which would cause error
  def self.is_team_empty(team_id)
    #team_members = TeamsUser.first_by_team_id(team_id)
    #return team_members.nil? || team_members.length == 0
    #return team_members.nil?
    TeamsUser.where(team_id: team_id).count == 0
  end

  #Add member to the team they were invited to and accepted the invite for
  def self.add_member_to_invited_team(invitee_user_id, invited_user_id, assignment_id)
    users_teams = TeamsUser.find(:all, :conditions => ['user_id = ?', invitee_user_id])
    for team in users_teams
      new_team = AssignmentTeam.find(:first, :conditions => ['id = ? and parent_id = ?', team.team_id, assignment_id])
      if new_team != nil
        can_add_member = new_team.add_member(User.find(invited_user_id), assignment_id)
      end
    end
    return can_add_member
  end
end
