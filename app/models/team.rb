class Team < ActiveRecord::Base
  has_many :teams_users, dependent: :destroy
  has_many :users, through: :teams_users
  has_many :join_team_requests
  has_one :team_node, foreign_key: :node_object_id, dependent: :destroy
  has_many :signed_up_teams
  has_paper_trail

  # Get the participants of the given team
  def participants
    users.where(parent_id: parent_id || current_user_id).flat_map(&:participants)
  end
  alias get_participants participants

  # Get the response review map
  def responses
    participants.flat_map(&:responses)
  end

  # Delete the given team
  def delete
    for teamsuser in TeamsUser.where(["team_id =?", self.id])
      teamsuser.delete
    end
    node = TeamNode.find_by_node_object_id(self.id)
    node.destroy if node
    self.destroy
  end

  # Get the node type of the tree structure
  def get_node_type
    "TeamNode"
  end

  # Get the names of the users
  def get_author_names
    names = []
    users.each do |user|
      names << user.fullname
    end
    names
  end

  # Check if the user exist
  def has_user(user)
    users.include? user
  end

 # Check if the current team is full?
 def full?
  return false if self.parent_id == nil
  max_team_members = Assignment.find(self.parent_id).max_team_size
  curr_team_size = Team.size(self.id)
  (curr_team_size >= max_team_members)
 end

  # Add memeber to the team
  def add_member(user, _assignment_id)
    if has_user(user)
      raise "The user \"" + user.name + "\" is already a member of the team, \"" + self.name + "\""
    end

    if can_add_member = !full?
      t_user = TeamsUser.create(user_id: user.id, team_id: self.id)
      parent = TeamNode.find_by_node_object_id(self.id)
      TeamUserNode.create(parent_id: parent.id, node_object_id: t_user.id)
      add_participant(self.parent_id, user)
    end

    can_add_member
  end

  # Define the size of the team
  def self.size(team_id)
    TeamsUser.where(["team_id = ?", team_id]).count
  end

  # Copy method to copy this team
  def copy_members(new_team)
    members = TeamsUser.where(team_id: self.id)
    members.each do |member|
      t_user = TeamsUser.create(team_id: new_team.id, user_id: member.user_id)
      parent = Object.const_get(self.parent_model).find(self.parent_id)
      TeamUserNode.create(parent_id: parent.id, node_object_id: t_user.id)
    end
  end

  # Check if the team exists
  def self.check_for_existing(parent, name, team_type)
    list = Object.const_get(team_type + 'Team').where(['parent_id = ? and name = ?', parent.id, name])
    if !list.empty?
      raise TeamExistsError, 'The team name, "' + name + '", is already in use.'
    end
  end

  # Algorithm
  # Start by adding single members to teams that are one member too small.
  # Add two-member teams to teams that two members too small. etc.
  def self.randomize_all_by_parent(parent, team_type, min_team_size)
    participants = Participant.where(["parent_id = ? AND type = ?", parent.id, parent.class.to_s + "Participant"])
    participants = participants.sort { rand(3) - 1 }
    users = participants.map {|p| User.find(p.user_id) }.to_a
    # find teams still need team members and users who are not in any team
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
    # sort teams by decreasing team size
    teams.sort_by {|team| Team.size(team.id) }.reverse!
    # insert users who are not in any team to teams still need team members
    if !users.empty? and !teams.empty?
      teams.each do |team|
        curr_team_size = Team.size(team.id)
        member_num_difference = min_team_size - curr_team_size
        for i in (1..member_num_difference).to_a
          team.add_member(users.first, parent.id)
          users.delete(users.first)
          break if users.empty?
        end
        break if users.empty?
      end
    end
    # If all the existing teams are fill to the min_team_size and we still have more users, create teams for them.
    if !users.empty?
      num_of_teams = users.length.fdiv(min_team_size).ceil
      nextTeamMemberIndex = 0
      for i in (1..num_of_teams).to_a
        team = Object.const_get(team_type + 'Team').create(name: "Team" + (rand(100) * rand(0.1)).round(0).to_s, parent_id: parent.id)
        TeamNode.create(parent_id: parent.id, node_object_id: team.id)
        min_team_size.times do
          break if nextTeamMemberIndex >= users.length
          user = users[nextTeamMemberIndex]
          team.add_member(user, parent.id)
          nextTeamMemberIndex += 1
        end
      end
    end
  end

  # Generate the team name
  def self.generate_team_name(teamnameprefix)
    counter = 1
    while true
      teamname = teamnameprefix + "_Team#{counter}"
      return teamname if !Team.find_by_name(teamname)
      counter += 1
    end
  end

  # Extract team members from the csv and push to DB
  def import_team_members(starting_index, row)
    index = starting_index
    while index < row.length
      user = User.find_by_name(row[index].to_s.strip)
      if user.nil?
        raise ImportError, "The user \"" + row[index].to_s.strip + "\" was not found. <a href='/users/new'>Create</a> this user?"
      else
        if TeamsUser.where(["team_id =? and user_id =?", id, user.id]).first.nil?
          add_member(user, nil)
        end
      end
      index += 1
    end
  end

  # REFACTOR BEGIN:: class methods import export moved from course_team & assignment_team to here
  # Import from csv
  def self.import(row, id, options, teamtype)
    raise ArgumentError, "Not enough fields on this line." if (row.length < 2 && options[:has_column_names] == "true") || (row.empty? && options[:has_column_names] != "true")

    if options[:has_column_names] == "true"
      name = row[0].to_s.strip
      team = where(["name =? && parent_id =?", name, id]).first
      team_exists = !team.nil?
      name = handle_duplicate(team, name, id, options[:handle_dups], teamtype)
      index = 1
    else
      if teamtype.is_a?(CourseTeam)
        name = self.generate_team_name(Course.find(id).name)
      elsif teamtype.is_a?(AssignmentTeam)
        name = self.generate_team_name(Assignment.find(id).name)
      end
      index = 0
    end

    if name
      team = Team.create_team_and_node(id, teamtype)
      team.name = name
      team.save
    end

    # insert team members into team unless team was pre-existing & we ignore duplicate teams
    team.import_team_members(index, row) unless (team_exists && options[:handle_dups] == "ignore")
  end

  # Handle existence of the duplicate team
  def self.handle_duplicate(team, name, id, handle_dups, teamtype)
    return name if team.nil? #no duplicate
    if handle_dups == "ignore" # ignore: do not create the new team
      p '>>>setting name to nil ...'
      return nil
    end
    if handle_dups == "rename" # rename: rename new team
      if teamtype.is_a?(CourseTeam)
        return self.generate_team_name(Course.find(id).name)
      elsif teamtype.is_a?(AssignmentTeam)
        return self.generate_team_name(Assignment.find(id).name)
      end
    end
    if handle_dups == "replace" # replace: delete old team
      team.delete
      return name
    else # handle_dups = "insert"
      return nil
    end
  end

  # Export the teams to csv
  def self.export(csv, parent_id, options, teamtype)
    if teamtype.is_a?(CourseTeam)
      teams = CourseTeam.where(["parent_id =?", parent_id])
    elsif teamtype.is_a?(AssignmentTeam)
      teams = AssignmentTeam.where(["parent_id =?", parent_id])
    end
    teams.each do |team|
      output = []
      output.push(team.name)
      if options["team_name"] == "false"
        team_members = TeamsUser.where(['team_id = ?', team.id])
        team_members.each do |user|
          output.push(user.name)
        end
      end
      output.push(teams.name)
      csv << output
    end
  end

  # Create the team with corresponding tree node
  def self.create_team_and_node(id, teamtype = 'AssignmentTeam')
    if teamtype == 'CourseTeam'
      curr_course = Course.find(id)
      team_name = Team.generate_team_name(curr_course.name)
      team = CourseTeam.create(name: team_name, parent_id: id)
      TeamNode.create(parent_id: id, node_object_id: team.id)
    elsif teamtype == 'AssignmentTeam'
      curr_assignment = Assignment.find(id)
      team_name = Team.generate_team_name(curr_assignment.name)
      team = AssignmentTeam.create(name: team_name, parent_id: id)
      TeamNode.create(parent_id: id, node_object_id: team.id)
    end
    team
  end

  # REFACTOR END:: class methods import export moved from course_team & assignment_team to here
end
