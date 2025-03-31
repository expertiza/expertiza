class AssignmentTeam < Team
  require File.dirname(__FILE__) + '/analytic/assignment_team_analytic'
  include AssignmentTeamAnalytic
  include Scoring

  belongs_to :assignment, class_name: 'Assignment', foreign_key: 'parent_id'
  has_many :review_mappings, class_name: 'ReviewResponseMap', foreign_key: 'reviewee_id'
  has_many :review_response_maps, foreign_key: 'reviewee_id'
  has_many :responses, through: :review_response_maps, foreign_key: 'map_id'

  # Returns the ID of the current_user if they are part of the team
  def current_user_id
    return @current_user.id if @current_user && users.include?(@current_user)
    nil
  end

  # Returns the ID of the first user in the team (or nil if empty)
  def first_user_id
    users.first ? users.first.id : nil
  end

  # Stores the current user so that we can check them when returning the user_id
  def store_current_user(current_user)
    @current_user = current_user
  end

  # Get the review response map
  def review_map_type
    'ReviewResponseMap'
  end

  # Use current object (AssignmentTeam) as reviewee and create the ReviewResponseMap record
  def assign_reviewer(reviewer)
    assignment = Assignment.find(parent_id)
    raise 'The assignment cannot be found.' if assignment.nil?

    ReviewResponseMap.create(reviewee_id: id, reviewer_id: reviewer.get_reviewer.id, reviewed_object_id: assignment.id, team_reviewing_enabled: assignment.team_reviewing_enabled)
  end

  # If a team is being treated as a reviewer of an assignment, then they are the reviewer
  def reviewer
    self
  end

  # Evaluates whether any contribution by this team was reviewed by reviewer
  # @param[in] reviewer AssignmentParticipant object
  def reviewed_by?(reviewer)
    ReviewResponseMap.where('reviewee_id = ? && reviewer_id = ? && reviewed_object_id = ?', id, reviewer.get_reviewer.id, assignment.id).count > 0
  end

  # Topic id picked by the team for the assignment
  def topic_id
    SignedUpTeam.find_by(team_id: id, is_waitlisted: 0).try(:topic_id)
  end

  # Whether the team has submitted work or not
  def has_submissions?
    submitted_files.any? || submitted_hyperlinks.present?
  end

  # Get Participants of the team
  def participants
    users = self.users
    participants = []
    users.each do |user|
      participant = AssignmentParticipant.find_by(user_id: user.id, parent_id: parent_id)
      participants << participant unless participant.nil?
    end
    participants
  end
  alias get_participants participants

  # Delete the team
  def delete
    if self[:type] == 'AssignmentTeam'
      sign_up = SignedUpTeam.find_team_participants(parent_id.to_s).select { |p| p.team_id == id }
      sign_up.each(&:destroy)
    end
    super
  end

  # Deletes all review mappings associated with this team
  def destroy
    review_response_maps.each(&:destroy)
    super
  end

  # Return the files residing in the directory of team submissions
  # Main calling method to return the files residing in the directory of team submissions
  def submitted_files(path = self.path)
    files = []
    files = files(path) if directory_num
    files
  end

  # Delegates CSV-based team creation to the Team.import method, using AssignmentTeam as the context.
  def self.import(row, assignment_id, options)
    raise ImportError, "The assignment with the id \"#{assignment_id}\" was not found. <a href='/assignment/new'>Create</a> this assignment?" unless Assignment.find_by(id: assignment_id)

    Team.import(row, assignment_id, options, AssignmentTeam)
  end

  # Delegates team export functionality to the Team.export method using AssignmentTeam as the context.
  def self.export(csv, parent_id, options)
    Team.export(csv, parent_id, options, AssignmentTeam)
  end

  # REFACTOR END:: functionality of import, export handle_duplicate shifted to team.rb

  # Copy the current Assignment team to the CourseTeam
  def copy_to_course(course_id)
    new_team = CourseTeam.create_team_and_node(course_id)
    new_team.name = name
    new_team.save
    copy_members(new_team)
  end

  # Given a user, if they aren't already a participant, make them one
  # Since this method is on a team and team already belongs to an assignment, assignment_id is not needed.
  def add_participant(user)
    existing = AssignmentParticipant.find_by(parent_id: parent_id, user_id: user.id)
    return nil if existing

    AssignmentParticipant.create(
      parent_id: parent_id,
      user_id: user.id,
      permission_granted: user.master_permission_granted
    )
  end

  def hyperlinks
    submitted_hyperlinks.blank? ? [] : YAML.safe_load(submitted_hyperlinks)
  end

  # Manages submission of a hyperlink
  def submit_hyperlink(hyperlink)
    hyperlink.strip!
    raise 'The hyperlink cannot be empty!' if hyperlink.empty?

    hyperlink = 'http://' + hyperlink unless hyperlink.start_with?('http://', 'https://')
    # If not a valid URL, it will throw an exception
    response_code = Net::HTTP.get_response(URI(hyperlink))
    raise "HTTP status code: #{response_code}" if response_code =~ /[45][0-9]{2}/

    hyperlinks = self.hyperlinks
    hyperlinks << hyperlink
    self.submitted_hyperlinks = YAML.dump(hyperlinks)
    save
  end

  # Method manages removal of hyperlink (only here on as-needed basis)
  def remove_hyperlink(hyperlink_to_delete)
    hyperlinks = self.hyperlinks
    hyperlinks.delete(hyperlink_to_delete)
    self.submitted_hyperlinks = YAML.dump(hyperlinks)
    save
  end

  # Recursively gathers all files (not directories) within a given directory and its subdirectories
  # Uses an iterator-based approach as specified.
  def files(directory)
    # Safety check: if the given path is not a valid directory, return an empty array
    return [] unless File.directory?(directory)
    gather_files(directory)
  end

  # Given a participant, find associated AssignmentTeam.
  def self.team(participant)
    # return nil if there is no participant
    return nil if participant.nil?

    # find all TeamUser records for given user
    team = nil
    teams_users = TeamsUser.where(user_id: participant.user_id)
    return nil unless teams_users

    # for each TeamUser record, fetch team & return it only if both team and participant's parent id match
    teams_users.each do |teams_user|
      if teams_user.team_id == nil
        next
      end
      team = Team.find(teams_user.team_id)
      return team if team.parent_id == participant.parent_id
    end
    nil
  end

  # Export the fields
  def self.export_fields(options)
    fields = ['Team Name']
    fields << 'Team members' if options[:team_name] == 'false'
    fields << 'Assignment Name'
    fields
  end

  # Remove a team given the team id
  def self.remove_team_by_id(id)
    old_team = AssignmentTeam.find(id)
    old_team.destroy unless old_team.nil? # nil check ensures safety
  end

  # Get the path of the team directory
  def path
    File.join(assignment.path, directory_num.to_s)
  end

  # Set the directory number for this team
  def set_team_directory_num
    return if directory_num && (directory_num >= 0)

    max_num = AssignmentTeam.where(parent_id: parent_id).order('directory_num desc').first.directory_num
    dir_num = max_num ? max_num + 1 : 0
    update_attributes(directory_num: dir_num)
  end

  # Checks if the AssignmentTeam has received any peer reviews
  def has_been_reviewed?
    ResponseMap.where(reviewee_id: id, reviewed_object_id: parent_id).any?
  end

  # Returns the most recent submission of the team
  def most_recent_submission
    assignment = Assignment.find(parent_id)
    SubmissionRecord.where(team_id: id, assignment_id: assignment.id).order(updated_at: :desc).first
  end

  # E-1973 gets the participant id of the currently logged in user, given their user id
  # this method assumes that the team is the reviewer since it would be called on
  # AssignmentParticipant otherwise
  def get_logged_in_reviewer_id(current_user_id)
    participants.each do |participant|
      return participant.id if participant.user.id == current_user_id
    end
    nil
  end

  # determines if the team contains a participant who is currently logged in
  def current_user_is_reviewer?(current_user_id)
    get_logged_in_reviewer_id(current_user_id) != nil
  end

  # Creates a new team linking a user with a signuptopic
  def link_user_and_topic(user_id, signuptopic)
    t_user = TeamsUser.create(team_id: id, user_id: user_id)
    SignedUpTeam.create(topic_id: signuptopic.id, team_id: id, is_waitlisted: 0)
    parent = TeamNode.create(parent_id: signuptopic.assignment_id, node_object_id: id)
    TeamUserNode.create(parent_id: parent.id, node_object_id: t_user.id)
  end

  private

  # A helper method to files(directory)
  def gather_files(directory)
    # Get a list of all entries (files and subdirectories) in the current directory (excluding '.' and '..')
    # Then iterate over each entry
    (Dir.entries(directory) - ['.', '..']).flat_map do |entry|
      # Construct the full path to the current entry (file or folder)
      path = File.join(directory, entry)

      # If the entry is a subdirectory, recursively gather its files using the same method
      # If it's a file, return it in a single-element array
      # flat_map ensures all nested arrays are flattened into a single array of paths
      File.directory?(path) ? files(path) : [path]
    end
  end
end
