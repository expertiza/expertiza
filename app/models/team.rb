class Team < ActiveRecord::Base
  has_many :teams_users, :dependent => :destroy
  has_many :users, :through => :teams_users
  has_many :join_team_requests
  has_one :team_node, :foreign_key => :node_object_id, :dependent => :destroy
  has_many :bids, :dependent => :destroy
  has_paper_trail

  def get_participants
    Participant.where user_id: users.map(&:id), parent_id: parent_id
  end

  def get_possible_participants(name)
    query = "select users.* from users, participants"
    query = query + " where users.id = participants.user_id"
    query = query + " and participants.type = '"+self.get_participant_type+"'"
    query = query + " and participants.parent_id = #{self.parent_id}"
    query = query + " and users.name like '#{name}%'"
    query = query + " order by users.name"
    User.find_by_sql(query)
  end

  def add_participant(user, assignment_id)
    if has_user(user)
      raise "\""+user.name+"\" is already a member of the team, \""+self.name+"\""
    end

    if assignment_id==nil
      can_add_member=true
    else
      max_team_members=Assignment.find(assignment_id).max_team_size
      curr_team_size= TeamsUser.where(["team_id = ?", self.id])
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

  def copy_participants(new_team)
    members = TeamsUser.where(team_id: self.id)
    members.each {
        |member|
      t_user = TeamsUser.create(:team_id => new_team.id, :user_id => member.user_id)
      parent = Object.const_get(self.get_parent_model).find(self.parent_id)
      TeamUserNode.create(:parent_id => parent.id, :node_object_id => t_user.id)
    }
  end

  def import_participants(starting_index, row)
    index = starting_index
    while index < row.length
      user = User.find_by_name(row[index].to_s.strip)
      if user.nil?
        raise ImportError, "The user \""+row[index].to_s.strip+"\" was not found. <a href='/users/new'>Create</a> this user?"
      else
        if TeamsUser.where(["team_id =? and user_id =?", id, user.id]).first.nil?
          add_participant(user, nil)
        end
      end
      index = index + 1
    end
  end

  def delete
    TeamsUser.where(["team_id =?", self.id]).each { |teams_user|
      teams_user.delete
    }
    node = TeamNode.find_by_node_object_id(self.id)
    if node
      node.destroy
    end
    self.destroy
  end

  def get_node_type
    'TeamNode'
  end

  def get_author_name
    return self.name
  end

  def self.generate_team_name(team_name_prefix)
    counter = 1
    while (true)
      team_name = team_name_prefix + "_Team#{counter}"
      if (!Team.find_by_name(team_name))
        return team_name
      end
      counter=counter+1
    end
  end

  def has_user(user)
    users.include? user
  end

  #TODO: no way in hell this method works
  def self.create_node_object(name, parent_id)
    create(:name => name, :parent_id => parent_id)
    parent = Object.const_get(self.get_parent_model).find(parent_id)
    Object.const_get(self.get_node_type).create(:parent_id => parent.id, :node_object_id => self.id)
  end

  def self.check_for_existing(parent, name, team_type)
    list = Object.const_get(team_type + 'Team').where(['parent_id = ? and name = ?', parent.id, name])
    if list.length > 0
      raise TeamExistsError, 'Team name, "' + name + '", is already in use.'
    end
  end

  def self.delete_all_by_parent(parent)
    teams = Team.where(["parent_id=?", parent.id])

    teams.each { |team|
      team.delete
    }
  end

  def self.randomize_all_by_parent(parent, team_type, team_size)
    participants = Participant.where(["parent_id = ? AND type = ?", parent.id, parent.class.to_s + "Participant"])
    participants = participants.sort { rand(3) - 1 }
    users = participants.map { |p| User.find(p.user_id) }
    #users = users.uniq

    Team.delete_all_by_parent(parent)

    no_of_teams = users.length.fdiv(team_size).ceil
    nextTeamMemberIndex = 0

    (1..no_of_teams).each { |i|
      team = Object.const_get(team_type + 'Team').create(:name => "Team #{i}", :parent_id => parent.id)
      TeamNode.create(:parent_id => parent.id, :node_object_id => team.id)

      team_size.times do
        break if nextTeamMemberIndex >= users.length

        user = users[nextTeamMemberIndex]
        team.add_participant(user)

        nextTeamMemberIndex += 1
      end
    }
  end
end
