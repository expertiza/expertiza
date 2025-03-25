class Team < ApplicationRecord
  has_many :teams_participants, dependent: :destroy
  has_many :participants, through: :teams_participants
  has_many :users, through: :participants
  has_many :join_team_requests, dependent: :destroy
  has_one :team_node, foreign_key: :node_object_id, dependent: :destroy
  has_many :signed_up_teams, dependent: :destroy
  has_many :bids, dependent: :destroy
  has_paper_trail

  scope :find_team_for_assignment_and_user, lambda { |assignment_id, user_id|
    joins(:teams_participants).joins('INNER JOIN participants ON teams_participants.participant_id = participants.id')
                            .where('teams.parent_id = ? AND participants.user_id = ?', assignment_id, user_id)
  }

  # Allowed types of teams -- ASSIGNMENT teams or COURSE teams
  def self.allowed_types
    # non-interpolated array of single-quoted strings
    %w[Assignment Course]
  end

  # Get the participants of the given team
  def participants
    participants.where(parent_id: parent_id || current_user_id)
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
    TeamsParticipant.where(team_id: id).find_each(&:destroy)
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
      names << user.fullname
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
  def add_member(participant, _assignment_id = nil)
    raise "The participant #{participant.user.name} is already a member of the team #{name}" if user?(participant.user)

    can_add_member = false
    unless full?
      can_add_member = true
      t_participant = TeamsParticipant.create(participant_id: participant.id, team_id: id)
      parent = TeamNode.find_by(node_object_id: id)
      TeamUserNode.create(parent_id: parent.id, node_object_id: t_participant.id)
      add_participant(parent_id, participant.user)
      ExpertizaLogger.info LoggerMessage.new('Model:Team', participant.user.name, "Added member to the team #{id}")
    end
    can_add_member
  end

  # Define the size of the team
  def self.size(team_id)
    count = 0
    members = TeamsParticipant.where(team_id: team_id)
    members.each do |member|
      member_name = member.participant.user.name
      unless member_name.include?(' (Mentor)') 
        count = count + 1
      end
    end
    count
  end

  # Copy method to copy this team
  def copy_members(new_team)
    members = TeamsParticipant.where(team_id: id)
    members.each do |member|
      t_participant = TeamsParticipant.create(team_id: new_team.id, participant_id: member.participant_id)
      parent = Object.const_get(parent_model).find(parent_id)
      TeamUserNode.create(parent_id: parent.id, node_object_id: t_participant.id)
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
      TeamsParticipant.where(team_id: team.id).each do |teams_participant|
        users.delete(teams_participant.participant.user)
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
        participant = Participant.find_by(user_id: user.id, parent_id: parent.id)
        team.add_member(participant, parent.id) if participant
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
        user = users.first
        participant = Participant.find_by(user_id: user.id, parent_id: parent.id)
        team.add_member(participant, parent.id) if participant
        users.delete(user)
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
      user = User.find_by(name: teammate.to_s)
      if user.nil?
        raise ImportError, "The user '#{teammate}' was not found. <a href='/users/new'>Create</a> this user?"
      else
        participant = Participant.find_by(user_id: user.id, parent_id: parent_id)
        add_member(participant) if participant && TeamsParticipant.find_by(team_id: id, participant_id: participant.id).nil?
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
      if (teamtype == CourseTeam)
        name = generate_team_name(Course.find(id).name)
      elsif (teamtype == AssignmentTeam || teamtype == MentoredTeam)
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
    else
      teams = AssignmentTeam.where(parent_id: parent_id)
    end
    teams.each do |team|
      team_members = []
      TeamsParticipant.where(team_id: team.id).each do |teams_participant|
        team_members << teams_participant.participant.user.name
      end
      csv << [team.name, team_members.join(',')]
    end
  end

  # Create a team and its node
  def self.create_team_and_node(id)
    parent = parent_model id # current_task will be either a course object or an assignment object.
    team = create(name: 'Team_' + rand(1000).to_s, parent_id: id)
    TeamNode.create(parent_id: parent.id, node_object_id: team.id)
    team
  end

  # Get the name of the team
  def name(ip_address = nil)
    if User.anonymized_view?(ip_address)
      'Team_' + id.to_s
    else
      self[:name]
    end
  end

  # Create a team with users
  def self.create_team_with_users(parent_id, user_ids)
    team = create_team_and_node(parent_id)
    user_ids.each do |user_id|
      user = User.find(user_id)
      participant = Participant.find_by(user_id: user_id, parent_id: parent_id)
      team.add_member(participant, parent_id) if participant
    end
    team
  end

  # Remove user from previous team
  def self.remove_user_from_previous_team(parent_id, user_id)
    team_participant = TeamsParticipant.joins(:participant)
                                     .where('participants.user_id = ? AND teams.parent_id = ?', user_id, parent_id)
                                     .first
    team_participant&.destroy
  end

  # Find team users
  def self.find_team_users(assignment_id, user_id)
    TeamsParticipant.joins('INNER JOIN teams ON teams_participants.team_id = teams.id')
                    .joins('INNER JOIN participants ON teams_participants.participant_id = participants.id')
                    .where('teams.parent_id = ? AND participants.user_id = ?', assignment_id, user_id)
  end
end
