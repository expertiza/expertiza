class Team < ApplicationRecord
  has_many :teams_users, dependent: :destroy
  has_many :users, through: :teams_users
  has_many :join_team_requests, dependent: :destroy
  has_one :team_node, foreign_key: :node_object_id, dependent: :destroy
  has_many :signed_up_teams, dependent: :destroy
  has_many :bids, dependent: :destroy
  has_paper_trail

  scope :find_team_for_assignment_and_user, lambda { |assignment_id, user_id|
    joins(:teams_users).where('teams.parent_id = ? AND teams_users.user_id = ?', assignment_id, user_id)
  }

  # Allowed types of teams -- ASSIGNMENT teams or COURSE teams
  def self.allowed_types
    # non-interpolated array of single-quoted strings
    %w[Assignment Course]
  end

  # Get the participants of the given team
  def participants
    users.where(parent_id: parent_id || current_user_id).flat_map(&:participants)
  end
  alias get_participants participants

  # copies content of one object to the another
  def self.copy_content(source, destination)
    source.each do |each_element|
      each_element.copy(destination.id)
    end
  end

  # enum method for team clone operations
  def self.team_operation
    { inherit: 'inherit', bequeath: 'bequeath' }.freeze
  end

  # Get the response review map
  def responses
    participants.flat_map(&:responses)
  end

  # Delete the given team
  def delete
    TeamsUser.where(team_id: id).find_each(&:destroy)
    node = TeamNode.find_by(node_object_id: id)
    node.destroy if node
    destroy
  end

  # Get the node type of the tree structure
  def node_type
    'TeamNode'
  end

  # Get the names of the users
  def author_names
    names = []
    users.each do |user|
      names << user.name
    end
    names
  end

  # Check if the user exist
  def user?(user)
    users.include? user
  end

  # Check if the current team is full?
  def full?
    return false if parent_id.nil? # course team, does not max_team_size

    max_team_members = Assignment.find(parent_id).max_team_size
    curr_team_size = Team.size(id)
    curr_team_size >= max_team_members
  end

  # Add member to the team, changed to hash by E1776
  def add_member(user, _assignment_id = nil)
    username = user.respond_to?(:username) ? user.username : user.name
    raise "The user #{username} is already a member of the team #{name}" if user?(user)

    can_add_member = false
    unless full?
      can_add_member = true
      t_user = TeamsUser.create(user_id: user.id, team_id: id)
      parent = TeamNode.find_by(node_object_id: id)
      TeamUserNode.create(parent_id: parent.id, node_object_id: t_user.id)
      add_participant(parent_id, user)
      ExpertizaLogger.info LoggerMessage.new('Model:Team', username, "Added member to the team #{id}")
    end
    can_add_member
  end

  # Define the size of the team
  def self.size(team_id)
    #TeamsUser.where(team_id: team_id).count
    count = 0
    members = TeamsUser.where(team_id: team_id)
    members.each do |member|
      member_name = member.name
      unless member_name.include?(' (Mentor)') 
        count = count + 1
      end
    end
    count
  end

  # Copy method to copy this team
  def copy_members(new_team)
    members = TeamsUser.where(team_id: id)
    members.each do |member|
      t_user = TeamsUser.create(team_id: new_team.id, user_id: member.user_id)
      parent = Object.const_get(parent_model).find(parent_id)
      TeamUserNode.create(parent_id: parent.id, node_object_id: t_user.id)
    end
  end

  # Check if the team exists
  def self.check_for_existing(parent, name, team_type)
    list = Object.const_get(team_type + 'Team').where(parent_id: parent.id, name: name)
    raise TeamExistsError, "The team name #{name} is already in use." unless list.empty?
  end

  # Algorithm
  # Start by adding single members to teams that are one member too small.
  # Add two-member teams to teams that two members too small. etc.
  def self.randomize_all_by_parent(parent, team_type, min_team_size)
    participants = Participant.where(parent_id: parent.id, type: parent.class.to_s + 'Participant', can_mentor: [false, nil])
    participants = participants.sort { rand(-1..1) }
    users = participants.map { |p| User.find(p.user_id) }.to_a
    # find teams still need team members and users who are not in any team
    teams = Team.where(parent_id: parent.id, type: parent.class.to_s + 'Team').to_a
    teams.each do |team|
      TeamsUser.where(team_id: team.id).each do |teams_user|
        users.delete(User.find(teams_user.user_id))
      end
    end
    teams.reject! { |team| Team.size(team.id) >= min_team_size }
    # sort teams that still need members by decreasing team size
    teams.sort_by { |team| Team.size(team.id) }.reverse!
    # insert users who are not in any team to teams still need team members
    assign_single_users_to_teams(min_team_size, parent, teams, users) if !users.empty? && !teams.empty?
    # If all the existing teams are fill to the min_team_size and we still have more users, create teams for them.
    create_team_from_single_users(min_team_size, parent, team_type, users) unless users.empty?
  end

  # Creates teams from a list of users based on minimum team size
  # Then assigns the created team to the parent object
  def self.create_team_from_single_users(min_team_size, parent, team_type, users)
    num_of_teams = users.length.fdiv(min_team_size).ceil
    next_team_member_index = 0
    (1..num_of_teams).to_a.each do |i|
      team = Object.const_get(team_type + 'Team').create(name: 'Team_' + i.to_s, parent_id: parent.id)
      TeamNode.create(parent_id: parent.id, node_object_id: team.id)
      min_team_size.times do
        break if next_team_member_index >= users.length

        user = users[next_team_member_index]
        team.add_member(user, parent.id)
        next_team_member_index += 1
      end
    end
  end

  # Assigns list of users to list of teams based on minimum team size
  def self.assign_single_users_to_teams(min_team_size, parent, teams, users)
    teams.each do |team|
      curr_team_size = Team.size(team.id)
      member_num_difference = min_team_size - curr_team_size
      while member_num_difference > 0
        team.add_member(users.first, parent.id)
        users.delete(users.first)
        member_num_difference -= 1
        break if users.empty?
      end
      break if users.empty?
    end
  end

  # Generate the team name
  def self.generate_team_name(_team_name_prefix = '')
    last_team = Team.where('name LIKE ?', "#{_team_name_prefix} Team_%")
                  .order("CAST(SUBSTRING(name, LENGTH('#{_team_name_prefix} Team_') + 1) AS UNSIGNED) DESC")
                  .first
    counter = last_team ? last_team.name.scan(/\d+/).first.to_i + 1 : 1
    team_name = "#{_team_name_prefix} Team_#{counter}"
    team_name
  end

  # Extract team members from the csv and push to DB,  changed to hash by E1776
  def import_team_members(row_hash)
    row_hash[:teammembers].each_with_index do |teammate, _index|
      user = User.find_by(username: teammate.to_s)
      if user.nil?
        raise ImportError, "The user '#{teammate}' was not found. <a href='/users/new'>Create</a> this user?"
      else
        add_member(user) if TeamsUser.find_by(team_id: id, user_id: user.id).nil?
      end
    end
  end

  #  changed to hash by E1776
  def self.import(row_hash, id, options, teamtype)
    raise ArgumentError, 'Not enough fields on this line.' if row_hash.empty? || (row_hash[:teammembers].empty? && (options[:has_teamname] == 'true_first' || options[:has_teamname] == 'true_last')) || (row_hash[:teammembers].empty? && (options[:has_teamname] == 'true_first' || options[:has_teamname] == 'true_last'))

    if options[:has_teamname] == 'true_first' || options[:has_teamname] == 'true_last'
      name = row_hash[:teamname].to_s
      team = where(['name =? && parent_id =?', name, id]).first
      team_exists = !team.nil?
      name = handle_duplicate(team, name, id, options[:handle_dups], teamtype)
    else
      if teamtype.is_a?(CourseTeam)
        name = generate_team_name(Course.find(id).name)
      elsif teamtype.is_a?(AssignmentTeam)
        name = generate_team_name(Assignment.find(id).name)
      end
    end
    if name
      team = Object.const_get(teamtype.to_s).create_team_and_node(id)
      team.name = name
      team.save
    end

    # insert team members into team unless team was pre-existing & we ignore duplicate teams

    team.import_team_members(row_hash) unless team_exists && options[:handle_dups] == 'ignore'
  end

  # Handle existence of the duplicate team
  def self.handle_duplicate(team, name, id, handle_dups, teamtype)
    return name if team.nil? # no duplicate
    return nil if handle_dups == 'ignore' # ignore: do not create the new team

    if handle_dups == 'rename' # rename: rename new team
      if teamtype.is_a?(CourseTeam)
        return generate_team_name(Course.find(id).name)
      elsif  teamtype.is_a?(AssignmentTeam)
        return generate_team_name(Assignment.find(id).name)
      end
    end
    if handle_dups == 'replace' # replace: delete old team
      team.delete
      return name
    else # handle_dups = "insert"
      return nil
    end
  end

  # Export the teams to csv
  def self.export(csv, parent_id, options, teamtype)
    if teamtype.is_a?(CourseTeam)
      teams = CourseTeam.where(parent_id: parent_id)
    elsif teamtype.is_a?(AssignmentTeam)
      teams = AssignmentTeam.where(parent_id: parent_id)
    end
    teams.each do |team|
      output = []
      output.push(team.name)
      if options[:team_name] == 'false'
        team_members = TeamsUser.where(team_id: team.id)
        team_members.each do |user|
          output.push(user.user.username)
        end
      end
      csv << output
    end
    csv
  end

  # Create the team with corresponding tree node
  def self.create_team_and_node(id)
    parent = parent_model id # current_task will be either a course object or an assignment object.
    team_name = Team.generate_team_name(parent.name)
    team = create(name: team_name, parent_id: id)
    # new teamnode will have current_task.id as parent_id and team_id as node_object_id.
    TeamNode.create(parent_id: id, node_object_id: team.id)
    ExpertizaLogger.info LoggerMessage.new('Model:Team', '', "New TeamNode created with teamname #{team_name}")
    team
  end

  # E1991 : This method allows us to generate
  # team names based on whether anonymized view
  # is set or not. The logic is similar to
  # existing logic of User model.
  def name(ip_address = nil)
    if User.anonymized_view?(ip_address)
      return "Anonymized_Team_#{self[:id]}"
    else
      return self[:name]
    end
  end

  # REFACTOR END:: class methods import export moved from course_team & assignment_team to here

  # Create the team with corresponding tree node and given users
  def self.create_team_with_users(parent_id, user_ids)
    team = create_team_and_node(parent_id)

    user_ids.each do |user_id|
      remove_user_from_previous_team(parent_id, user_id)

      # Create new team_user and team_user node
      team.add_member(User.find(user_id))
    end
    team
  end

  # Removes the specified user from any team of the specified assignment
  def self.remove_user_from_previous_team(parent_id, user_id)
    team_user = TeamsUser.where(user_id: user_id).find { |team_user_obj| team_user_obj.team.parent_id == parent_id }
    begin
      team_user.destroy
    rescue StandardError
      nil
    end
  end

  def self.find_team_users(assignment_id, user_id)
    TeamsUser.joins('INNER JOIN teams ON teams_users.team_id = teams.id')
             .select('teams.id as t_id')
             .where('teams.parent_id = ? and teams_users.user_id = ?', assignment_id, user_id)
  end
end
