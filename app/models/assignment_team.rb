class AssignmentTeam < Team
  require File.dirname(__FILE__) + '/analytic/assignment_team_analytic'
  include AssignmentTeamAnalytic
  include Scoring

  belongs_to :assignment, class_name: 'Assignment', foreign_key: 'parent_id'
  has_many :review_mappings, class_name: 'ReviewResponseMap', foreign_key: 'reviewee_id'
  has_many :review_response_maps, foreign_key: 'reviewee_id'
  has_many :responses, through: :review_response_maps, foreign_key: 'map_id'
  # START of contributor methods, shared with AssignmentParticipant

  # Added for E1973, Team reviews.
  # Some methods prompt a reviewer for a user id. This method just returns the user id of the first user in the team
  # This is a very hacky way to deal with very complex functionality but the reasoning is this:
  # The reason this is being added is to give ReviewAssignment#reject_own_submission a way to reject the submission
  # Of the reviewer. If there are team reviews, there must be team submissions, so any team member's user id will do.
  # Hopefully, this logic applies if there are other situations where reviewer.user_id was called
  # EDIT: A situation was found which differs slightly. If the current user is on the team, we want to
  # return that instead for instances where the code uses the current user.
  def user_id
    @current_user.id if !@current_user.nil? && users.include?(@current_user)
    users.first.id
  end

  # E1973
  # stores the current user so that we can check them when returning the user_id
  def set_current_user(current_user)
    @current_user = current_user
  end

  # Whether this team includes a given participant or not
  def includes?(participant)
    participants.include?(participant)
  end

  # Get the parent of this class=>Assignment
  def parent_model
    'Assignment'
  end

  def self.parent_model(id)
    Assignment.find(id)
  end

  # Get the name of the class
  def fullname
    name
  end

  # Get the review response map
  def review_map_type
    'ReviewResponseMap'
  end

  # Prototype method to implement prototype pattern
  def self.prototype
    AssignmentTeam.new
  end

  # Use current object (AssignmentTeam) as reviewee and create the ReviewResponseMap record
  def assign_reviewer(reviewer)
    assignment = Assignment.find(parent_id)
    raise 'The assignment cannot be found.' if assignment.nil?

    ReviewResponseMap.create(reviewee_id: id, reviewer_id: reviewer.get_reviewer.id, reviewed_object_id: assignment.id, team_reviewing_enabled: assignment.team_reviewing_enabled)
  end

  # E-1973 If a team is being treated as a reviewer of an assignment, then they are the reviewer
  def get_reviewer
    self
  end

  # Evaluates whether any contribution by this team was reviewed by reviewer
  # @param[in] reviewer AssignmentParticipant object
  def reviewed_by?(reviewer)
    ReviewResponseMap.where('reviewee_id = ? && reviewer_id = ? && reviewed_object_id = ?', id, reviewer.get_reviewer.id, assignment.id).count > 0
  end

  # Topic picked by the team for the assignment
  # This method needs refactoring: it sounds like it returns a topic object but in fact it returns an id
  def topic
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

  # Delete Review response map
  def destroy
    review_response_maps.each(&:destroy)
    super
  end

  # Get the first member of the team
  def self.first_member(team_id)
    find_by(id: team_id).try(:participants).try(:first)
  end

  # Return the files residing in the directory of team submissions
  # Main calling method to return the files residing in the directory of team submissions
  def submitted_files(path = self.path)
    files = []
    files = files(path) if directory_num
    files
  end

  # REFACTOR BEGIN:: functionality of import,export, handle_duplicate shifted to team.rb
  # Import csv file to form teams directly
  def self.import(row, assignment_id, options)
    unless Assignment.find_by(id: assignment_id)
      raise ImportError, 'The assignment with the id "' + assignment_id.to_s + "\" was not found. <a href='/assignment/new'>Create</a> this assignment?"
    end

    @assignment_team = prototype
    Team.import(row, assignment_id, options, @assignment_team)
  end

  # Export the existing teams in a csv file
  def self.export(csv, parent_id, options)
    @assignment_team = prototype
    Team.export(csv, parent_id, options, @assignment_team)
  end

  # REFACTOR END:: functionality of import, export handle_duplicate shifted to team.rb

  # Copy the current Assignment team to the CourseTeam
  def copy(course_id)
    new_team = CourseTeam.create_team_and_node(course_id)
    new_team.name = name
    new_team.save
    copy_members(new_team)
  end

  # Add Participants to the current Assignment Team
  def add_participant(assignment_id, user)
    return if AssignmentParticipant.find_by(parent_id: assignment_id, user_id: user.id)

    AssignmentParticipant.create(parent_id: assignment_id, user_id: user.id, permission_granted: user.master_permission_granted)
  end

  def hyperlinks
    submitted_hyperlinks.blank? ? [] : YAML.safe_load(submitted_hyperlinks)
  end

  # Appends the hyperlink to a list that is stored in YAML format in the DB
  # @exception  If is hyperlink was already there
  #             If it is an invalid URL

  def files(directory)
    files_list = Dir[directory + '/*']
    files = []

    files_list.each do |file|
      if File.directory?(file)
        dir_files = files(file)
        dir_files.each { |f| files << f }
      end
      files << file
    end
    files
  end

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

  # Note: This method is not used yet. It is here in the case it will be needed.
  # @exception  If the index does not exist in the array

  def remove_hyperlink(hyperlink_to_delete)
    hyperlinks = self.hyperlinks
    hyperlinks.delete(hyperlink_to_delete)
    self.submitted_hyperlinks = YAML.dump(hyperlinks)
    save
  end

  # return the team given the participant
  def self.team(participant)
    return nil if participant.nil?

    team = nil
    teams_users = TeamsUser.where(user_id: participant.user_id)
    return nil unless teams_users

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
    fields = []
    fields.push('Team Name')
    fields.push('Team members') if options[:team_name] == 'false'
    fields.push('Assignment Name')
  end

  # Remove a team given the team id
  def self.remove_team_by_id(id)
    old_team = AssignmentTeam.find(id)
    old_team.destroy unless old_team.nil?
  end

  # Get the path of the team directory
  def path
    assignment.path + '/' + directory_num.to_s
  end

  # Set the directory num for this team
  def set_student_directory_num
    return if directory_num && (directory_num >= 0)

    max_num = AssignmentTeam.where(parent_id: parent_id).order('directory_num desc').first.directory_num
    dir_num = max_num ? max_num + 1 : 0
    update_attributes(directory_num: dir_num)
  end

  def received_any_peer_review?
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

  # E2121 Refractor create_new_team
  def create_new_team(user_id, signuptopic)
    t_user = TeamsUser.create(team_id: id, user_id: user_id)
    SignedUpTeam.create(topic_id: signuptopic.id, team_id: id, is_waitlisted: 0)
    parent = TeamNode.create(parent_id: signuptopic.assignment_id, node_object_id: id)
    TeamUserNode.create(parent_id: parent.id, node_object_id: t_user.id)
  end
end
