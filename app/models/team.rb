class Team < ActiveRecord::Base
  has_many :teams_users, dependent: :destroy
  has_many :users, through: :teams_users
  has_many :join_team_requests, dependent: :destroy
  has_one :team_node, foreign_key: :node_object_id, dependent: :destroy
  has_many :signed_up_teams, dependent: :destroy
  has_many :bids, dependent: :destroy
  has_paper_trail

  scope :find_team_for_assignment_and_user, lambda {|assignment_id, user_id|
    joins(:teams_users).where("teams.parent_id = ? AND teams_users.user_id = ?", assignment_id, user_id)
  }

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
    TeamsUser.where(team_id: self.id).find_each(&:destroy)
    node = TeamNode.find_by(node_object_id: self.id)
    node.destroy if node
    self.destroy
  end

  # Get the node type of the tree structure
  def node_type
    "TeamNode"
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
    return false if self.parent_id.nil? # course team, does not max_team_size
    max_team_members = Assignment.find(self.parent_id).max_team_size
    curr_team_size = Team.size(self.id)
    (curr_team_size >= max_team_members)
  end

  # Add member to the team, changed to hash by E1776
  def add_member(user, _assignment_id = nil)
    raise "The user #{user.name} is already a member of the team #{self.name}" if user?(user)
    can_add_member = false
    unless full?
      can_add_member = true
      t_user = TeamsUser.create(user_id: user.id, team_id: self.id)
      parent = TeamNode.find_by(node_object_id: self.id)
      TeamUserNode.create(parent_id: parent.id, node_object_id: t_user.id)
      add_participant(self.parent_id, user)
      ExpertizaLogger.info LoggerMessage.new('Model:Team', user.name, "Added member to the team #{self.id}")
    end
    can_add_member
  end

  # Define the size of the team,
  def self.size(team_id)
    TeamsUser.where(team_id: team_id).count
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
    list = Object.const_get(team_type + 'Team').where(parent_id: parent.id, name: name)
    raise TeamExistsError, "The team name #{name} is already in use." unless list.empty?
  end

  # Algorithm
  # Start by adding single members to teams that are one member too small.
  # Add two-member teams to teams that two members too small. etc.
  def self.randomize_all_by_parent(parent, team_type, min_team_size)
    participants = Participant.where(parent_id: parent.id, type: parent.class.to_s + "Participant")
    participants = participants.sort { rand(-1..1) }
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
    assign_single_users_to_teams(min_team_size, parent, teams, users) if !users.empty? and !teams.empty?
    # If all the existing teams are fill to the min_team_size and we still have more users, create teams for them.
    create_team_from_single_users(min_team_size, parent, team_type, users) unless users.empty?
  end

  def self.create_team_from_single_users(min_team_size, parent, team_type, users)
    num_of_teams = users.length.fdiv(min_team_size).ceil
    next_team_member_index = 0
    for i in (1..num_of_teams).to_a
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
  def self.generate_team_name(team_name_prefix = '')
    counter = 1
    loop do
      team_name = "Team_#{counter}"
      return team_name unless Team.find_by(name: team_name)
      counter += 1
    end
  end

  # Extract team members from the csv and push to DB,  changed to hash by E1776
  # todo check if the starting_index is necessary
  def import_team_members(starting_index = 0, row_hash)
    starting_index
    index = 0
    row_hash[:teammembers].each do |teammember|
      next if index < starting_index # not sure this will work, hash is not ordered like array
      user = User.find_by(name: teammember.to_s)
      if user.nil?
        raise ImportError, "The user '#{teammember.to_s}' was not found. <a href='/users/new'>Create</a> this user?"
      else
        add_member(user) if TeamsUser.find_by(team_id: id, user_id: user.id).nil?
      end
      index += 1
    end
  end

  #  changed to hash by E1776
  def self.import(row_hash, id, options, teamtype)

    raise ArgumentError, "Not enough fields on this line." if row_hash.empty? || (row_hash[:teammembers].length < 1 && (options[:has_teamname] == "true_first" || options[:has_teamname] == "true_last")) || (row_hash[:teammembers].empty? && (options[:has_teamname] == "true_first" || options[:has_teamname] == "true_last"))
    if options[:has_teamname] == "true_first" || options[:has_teamname] == "true_last"
      name = row_hash[:teamname].to_s
      team = where(["name =? && parent_id =?", name, id]).first
      team_exists = !team.nil?
      name = handle_duplicate(team, name, id, options[:handle_dups], teamtype)
    else
      if teamtype.is_a?(CourseTeam)
        name = self.generate_team_name(Course.find(id).name)
      elsif teamtype.is_a?(AssignmentTeam)
        name = self.generate_team_name(Assignment.find(id).name)
      end
    end
    if name
      team = Object.const_get(teamtype.to_s).create_team_and_node(id)
      team.name = name
      team.save
    end

    # insert team members into team unless team was pre-existing & we ignore duplicate teams

    team.import_team_members(row_hash) unless team_exists && options[:handle_dups] == "ignore"
  end

  # Handle existence of the duplicate team
  def self.handle_duplicate(team, name, id, handle_dups, teamtype)
    return name if team.nil? # no duplicate
    return nil if handle_dups == "ignore" # ignore: do not create the new team
    if handle_dups == "rename" # rename: rename new team
      if teamtype.is_a?(CourseTeam)
        return self.generate_team_name(Course.find(id).name)
      elsif  teamtype.is_a?(AssignmentTeam)
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
      teams = CourseTeam.where(parent_id: parent_id)
    elsif teamtype.is_a?(AssignmentTeam)
      teams = AssignmentTeam.where(parent_id: parent_id)
    end
    teams.each do |team|
      output = []
      output.push(team.name)
      if options[:team_name] == "false"
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
  def self.create_team_and_node(id)
    parent = parent_model id # current_task will be either a course object or an assignment object. # current_task will be either a course object or an assignment object.
    team_name = Team.generate_team_name(parent.name)
    team = self.create(name: team_name, parent_id: id)
    # new teamnode will have current_task.id as parent_id and team_id as node_object_id.
    TeamNode.create(parent_id: id, node_object_id: team.id)
    ExpertizaLogger.info LoggerMessage.new('Model:Team', '', "New TeamNode created with teamname #{team_name}")
    team
  end

  #Create new teams for calibrated assignments with respect to the old team already present
  def self.createnewteam(old_assign, new_assign_id)
    puts "Alpha"
    @original_team_values = Team.where(parent_id: old_assign.id)
    old_team_ids = []
    @original_team_values.each do |catt|
      @prev_assignment = Assignment.find(old_assign.id)
      @prev_instructor = Participant.find_by(parent_id: old_assign.id, user_id: @prev_assignment.instructor_id)
      @map = ReviewResponseMap.find_by(reviewed_object_id: old_assign.id, reviewer_id: @prev_instructor.id, reviewee_id: catt.id)
      if @map
        @resp = Response.find_by(map_id: @map.id, is_submitted: false)
        if @resp
          old_team_ids.append(catt.id)
          @new_team = Team.new
          @new_team.name = catt.name
          @new_team.parent_id = new_assign_id
          @new_team.type = catt.type
          @new_team.comments_for_advertisement = catt.comments_for_advertisement
          @new_team.advertise_for_partner = catt.advertise_for_partner
          @new_team.submitted_hyperlinks = catt.submitted_hyperlinks
          @new_team.directory_num = catt.directory_num
          @new_team.grade_for_submission = catt.grade_for_submission
          @new_team.comment_for_submission = catt.comment_for_submission
          @new_team.make_public = catt.make_public
          @new_team.save
        else
          next
        end
      else
        next
      end
    end
    old_team_ids
  end

  # REFACTOR END:: class methods import export moved from course_team & assignment_team to here
end
