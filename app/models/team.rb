class Team < ActiveRecord::Base
  has_many :teams_users, :dependent => :destroy
  has_many :users, :through => :teams_users
  has_many :join_team_requests
  has_one :team_node,:foreign_key => :node_object_id,:dependent => :destroy
  has_many :bids, :dependent => :destroy
  has_paper_trail

  def assignment
    participants.first.assignment
  end

  def participants
    users.where(parent_id: parent_id || current_user_id).flat_map(&:participants)
  end
  alias_method :get_participants, :participants

  def responses
    participants.flat_map(&:responses)
  end

  def delete
    for teamsuser in TeamsUser.where(["team_id =?", self.id])
      teamsuser.delete
    end
    node = TeamNode.find_by_node_object_id(self.id)
    if node
      node.destroy
    end
    self.destroy
  end

  def get_node_type
    "TeamNode"
  end

  def get_author_names
    names = Array.new
    users.each do |user|
      names << user.fullname
    end
    names
  end

  def self.generate_team_name()
    counter = 0
    while (true)
      temp = "Team #{counter}"
      if (!Team.find_by_name(temp))
        return temp
      end
      counter=counter+1
    end
  end

  def has_user(user)
    users.include? user
  end

 def full?
  max_team_members=Assignment.find(self.parent_id).max_team_size
  curr_team_size= Team.size(self.id)
  return (curr_team_size == max_team_members)
 end

  def add_member(user, assignment_id)
    if has_user(user)
      raise "\""+user.name+"\" is already a member of the team, \""+self.name+"\""
    end

    if assignment_id==nil
      can_add_member=true
    else
      max_team_members=Assignment.find(assignment_id).max_team_size
      curr_team_size= Team.size(self.id)
      can_add_member = (curr_team_size < max_team_members)
    end

    if can_add_member
      t_user = TeamsUser.create(:user_id => user.id, :team_id => self.id)
      parent = TeamNode.find_by_node_object_id(self.id)
      TeamUserNode.create(:parent_id => parent.id, :node_object_id => t_user.id)
      add_participant(self.parent_id, user)
    end

    return can_add_member
  end

  def self.size(team_id)
    TeamsUser.where(["team_id = ?", team_id]).count
  end

  def copy_members(new_team)
    members = TeamsUser.where(team_id: self.id)
    members.each{
      | member |
      t_user = TeamsUser.create(:team_id => new_team.id, :user_id => member.user_id)
      parent = Object.const_get(self.parent_model).find(self.parent_id)
      TeamUserNode.create(:parent_id => parent.id, :node_object_id => t_user.id)
    }
  end

  def self.check_for_existing(parent, name, team_type)
    list = Object.const_get(team_type + 'Team').where(['parent_id = ? and name = ?', parent.id, name])
    if list.length > 0
      raise TeamExistsError, 'Team name, "' + name + '", is already in use.'
    end
  end

  #Algorithm
  #Start by adding single members to teams that are one member too small.
  #Add two-member teams to teams that two members too small. etc.
  def self.randomize_all_by_parent(parent, team_type, min_team_size)
    participants = Participant.where(["parent_id = ? AND type = ?", parent.id, parent.class.to_s + "Participant"])
    participants = participants.sort{rand(3) - 1}
    users = participants.map{|p| User.find(p.user_id)}.to_a
    #find teams still need team members and users who are not in any team
    teams = Team.where(parent_id: parent.id, type: parent.class.to_s + "Team").to_a
    teams_num = teams.size
    i = 0
    teams_num.times do
      teams_users = TeamsUser.where(team_id: teams[i].id)
      teams_users.each do |teams_user|
        users.delete(User.find(teams_user.user_id))
      end
      if Team.size(teams.first.id) >= min_team_size
        teams.delete(teams.first)
      else
        i += 1
      end
    end
    #sort teams by decreasing team size
    teams.sort_by{|team| Team.size(team.id)}.reverse!
    #insert users who are not in any team to teams still need team members
    if users.size > 0 and teams.size > 0
      teams.each do |team|
        curr_team_size = Team.size(team.id)
        member_num_difference = min_team_size - curr_team_size
        for i in (1..member_num_difference).to_a
          team.add_member(users.first, parent.id)
          users.delete(users.first)
          break if users.size == 0
        end
        break if users.size == 0
      end
    end
    #If all the existing teams are fill to the min_team_size and we still have more users, create teams for them.
    if users.size > 0
      num_of_teams = users.length.fdiv(min_team_size).ceil
      nextTeamMemberIndex = 0
      for i in (1..num_of_teams).to_a
        team = Object.const_get(team_type + 'Team').create(:name => "Team" + (rand(100) * rand(0.1)).round(0).to_s, :parent_id => parent.id)
        TeamNode.create(:parent_id => parent.id, :node_object_id => team.id)
        min_team_size.times do
          break if nextTeamMemberIndex >= users.length
          user = users[nextTeamMemberIndex]
          team.add_member(user, parent.id)
          nextTeamMemberIndex += 1
        end
      end
    end
  end

  def self.generate_team_name(teamnameprefix)
    counter = 1
    while (true)
      teamname = teamnameprefix + "_Team#{counter}"
      if (!Team.find_by_name(teamname))
        return teamname
      end
      counter=counter+1
    end
  end

  def import_team_members(starting_index, row)
    index = starting_index
    while(index < row.length)
      user = User.find_by_name(row[index].to_s.strip)
      if user.nil?
        raise ImportError, "The user \""+row[index].to_s.strip+"\" was not found. <a href='/users/new'>Create</a> this user?"
      else
        if TeamsUser.where(["team_id =? and user_id =?", id, user.id]).first.nil?
          add_member(user, nil)
        end
      end
      index = index + 1
    end
  end
end
