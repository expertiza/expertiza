class Team < ApplicationRecord
  validates :name, uniqueness: { scope: :parent_id, message: "is already in use." }
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

  # Get the parent entity type as a string (ex: "Course" for CourseTeam)
  def parent_entity_type
    self.class.name.gsub('Team', '')
  end

  # Fetch the parent entity instance by ID (ex: Course.find(id) for CourseTeam)
  def self.find_parent_entity(id)
    Object.const_get(self.name.gsub('Team', '')).find(id)
  end

  # Get the participants of the given team
  def participants
    users.where(parent_id: parent_id || current_user_id).flat_map(&:participants)
  end
  alias get_participants participants

  # # copies content of one object to the another
  def self.copy_content(source, destination)
    source.each do |each_element|
      each_element.copy(destination.id)
    end
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
  def member_names
    names = []
    users.each do |user|
      names << user.fullname
    end
    names
  end

  # Check if the user exist
  def is_member?(user)
    users.include? user
  end

  # Check if the current team is full?
  def full?
    return false if parent_id.nil? # course team, does not max_team_size

    max_team_members = Assignment.find(parent_id).max_team_size
    curr_team_size = size
    curr_team_size >= max_team_members
  end

  # Add member to the team, changed to hash by E1776
  def add_member(user)
    raise "The user #{user.name} is already a member of the team #{name}" if is_member?(user)

    can_add_member = false
    unless full?
      can_add_member = true
      t_user = TeamsUser.create!(user_id: user.id, team_id: id)
      parent = TeamNode.find_by(node_object_id: id)
      TeamUserNode.create(parent_id: parent.id, node_object_id: t_user.id)

      if CourseParticipant.find_by(parent_id: parent.id, user_id: user.id).nil?
        CourseParticipant.create(parent_id: parent.id, user_id: user.id, permission_granted: user.master_permission_granted)
      end

      ExpertizaLogger.info LoggerMessage.new('Model:Team', user.name, "Added member to the team #{id}")
    end
    can_add_member
  end

  # Returns the number of users in the team
  def size
    users.size
  end

  # Algorithm
  # Start by adding single members to teams that are one member too small.
  # Add two-member teams to teams that two members too small. etc.
  def self.create_random_teams(parent, team_type, min_team_size)
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
    teams.reject! { |team| team.size >= min_team_size }
    # sort teams that still need members by decreasing team size
    teams.sort_by { |team| team.size }.reverse!
    # insert users who are not in any team to teams still need team members
    teams.each do |team|
      # Calculate how many members this team is missing.
      member_num_difference = min_team_size - team.size
      while member_num_difference > 0 && !users.empty?
        # Add the first user from the list to the team.
        team.add_member(users.first)
        # Remove that user from the pool.
        users.shift
        member_num_difference -= 1
      end
      break if users.empty?
    end
    # If all the existing teams are fill to the min_team_size and we still have more users, create teams for them.
    team_from_users(min_team_size, parent, team_type, users) unless users.empty?
  end

  # Creates teams from a list of users based on minimum team size
  # Then assigns the created team to the parent object
  def self.team_from_users(min_team_size, parent, team_type, users)
    num_of_teams = users.length.fdiv(min_team_size).ceil
    next_team_member_index = 0
    (1..num_of_teams).to_a.each do |i|
      team = Object.const_get(team_type + 'Team').create(name: 'Team_' + i.to_s, parent_id: parent.id)
      TeamNode.create(parent_id: parent.id, node_object_id: team.id)
      min_team_size.times do
        break if next_team_member_index >= users.length

        user = users[next_team_member_index]
        team.add_member(user)
        next_team_member_index += 1
      end
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

  # Extract team members from the csv and push to DB,  changed to hash by E1776
  def import_team_members(row_hash)
    row_hash[:teammembers].each_with_index do |teammate, _index|
      user = User.find_by(name: teammate.to_s)
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
      if teamtype == CourseTeam
        name = generate_team_name(Course.find(id).name)
      elsif teamtype == AssignmentTeam || teamtype == MentoredTeam
        name = generate_team_name(Assignment.find(id).name)
      end
    end
    if name
      team = teamtype.create_team_and_node(id)
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
      if teamtype == CourseTeam
        return generate_team_name(Course.find(id).name)
      elsif  teamtype == AssignmentTeam
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
    if teamtype == CourseTeam
      teams = CourseTeam.where(parent_id: parent_id)
    elsif teamtype == AssignmentTeam
      teams = AssignmentTeam.where(parent_id: parent_id)
    end
    teams.each do |team|
      output = []
      output.push(team.name)
      if options[:team_name] == 'false'
        team_members = TeamsUser.where(team_id: team.id)
        team_members.each do |user|
          output.push(user.name)
        end
      end
      csv << output
    end
    csv
  end

  # Create the team with corresponding tree node
  def self.create_team_and_node(parent_id, user_ids = [])

    parent = find_parent_entity parent_id # current_task will be either a course object or an assignment object.
    team_name = Team.generate_team_name(parent.name)
    team = create(name: team_name, parent_id: parent_id)
    # new teamnode will have current_task.id as parent_id and team_id as node_object_id.
    TeamNode.create(parent_id: parent_id, node_object_id: team.id)
    ExpertizaLogger.info LoggerMessage.new('Model:Team', '', "New TeamNode created with teamname #{team_name}")

    # If user IDs are provided, add them to the team.
    user_ids.each do |user_id|
      team_user = TeamsUser.where(user_id: user_id)
                           .find { |tu| tu.team.parent_id == parent_id }
      team_user.destroy if team_user
      team.add_member(User.find(user_id))
    end unless user_ids.empty?

    team
  end

  # REFACTOR END:: class methods import export moved from course_team & assignment_team to here

  def self.find_team_for_user(assignment_id, user_id)
    TeamsUser.joins('INNER JOIN teams ON teams_users.team_id = teams.id')
             .select('teams.id as t_id')
             .where('teams.parent_id = ? and teams_users.user_id = ?', assignment_id, user_id)
  end

  # Whether a team includes a given participant or not
  def has_participant?(participant)
    participants.include?(participant)
  end

  # Get team's full name from legacy codebase that is no longer used
  # def fullname
  #   name
  # end
end
