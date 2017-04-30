class AssignmentTeam < Team
  belongs_to :assignment, class_name: 'Assignment', foreign_key: 'parent_id'
  has_many :review_mappings, class_name: 'ReviewResponseMap', foreign_key: 'reviewee_id'
  has_many :review_response_maps, foreign_key: :reviewee_id
  has_many :responses, through: :review_response_maps, foreign_key: :map_id

  # START of contributor methods, shared with AssignmentParticipant

  # Whether this team includes a given participant or not
  def includes?(participant)
    participants.include?(participant)
  end

  # Get the parent of this class=>Assignment
  def parent_model
    "Assignment"
  end

  def self.parent_model (id)
    Assignment.find(id) 
  end

  # Get the name of the class
  def fullname
    self.name
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
    assignment = Assignment.find(self.parent_id)
    raise "The assignment cannot be found." if assignment.nil?

    ReviewResponseMap.create(reviewee_id: self.id, reviewer_id: reviewer.id,
                             reviewed_object_id: assignment.id)
  end

  # Evaluates whether any contribution by this team was reviewed by reviewer
  # @param[in] reviewer AssignmentParticipant object
  def reviewed_by?(reviewer)
    # ReviewResponseMap.count(conditions: ['reviewee_id = ? && reviewer_id = ? && reviewed_object_id = ?',  self.id, reviewer.id, assignment.id]) > 0
    ReviewResponseMap.where('reviewee_id = ? && reviewer_id = ? && reviewed_object_id = ?', self.id, reviewer.id, assignment.id).count > 0
  end

  # Topic picked by the team for the assignment
  # This method needs refactoring: it sounds like it returns a topic object but in fact it returns an id
  def topic
    team_topic = nil
    participants.each do |participant|
      team_topic = SignedUpTeam.topic_id(participant.parent_id, participant.user_id)
      break if team_topic
    end
    team_topic
  end

  # Whether the team has submitted work or not
  def has_submissions?
    !self.submitted_files.empty? or !self.submitted_hyperlinks.blank?
  end

  # Get Participants of the team
  def participants
    users = self.users
    participants = []
    users.each do |user|
      participant = AssignmentParticipant.where(user_id: user.id, parent_id: self.parent_id).first
      participants << participant unless participant.nil?
    end
    participants
  end

  alias get_participants participants

  # Delete the team
  def delete
    if self[:type] == 'AssignmentTeam'
      sign_up = SignedUpTeam.find_team_participants(parent_id.to_s).select {|p| p.team_id == self.id }
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
  def self.get_first_member(team_id)
    find(team_id).participants.first
  end

  # Return the files residing in the directory of team submissions
  def files(directory)
    files_list = Dir[directory + "/*"]
    files = []

    files_list.each do |file|
      if File.directory?(file)
        dir_files = files(file)
        dir_files.each {|f| files << f }
      end
      files << file
    end
    files
  end

  # Main calling method to return the files residing in the directory of team submissions
  def submitted_files(path = self.path)
    files = []
    files = files(path) if self.directory_num
    files
  end

  # REFACTOR BEGIN:: functionality of import,export, handle_duplicate shifted to team.rb
  # Import csv file to form teams directly
  def self.import(row, assignment_id, options)
    raise ImportError, "The assignment with the id \"" + id.to_s + "\" was not found. <a href='/assignment/new'>Create</a> this assignment?" if Assignment.find(assignment_id).nil?
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
    AssignmentParticipant.create(parent_id: assignment_id, user_id: user.id, permission_granted: user.master_permission_granted) if AssignmentParticipant.where(parent_id: assignment_id, user_id: user.id).first.nil?
  end

  # Return the parent Assignment
  def assignment
    Assignment.find(self.parent_id)
  end

  # return a hash of scores that the team has received for the questions
  def scores(questions)
    scores = {}
    scores[:team] = self # This doesn't appear to be used anywhere
    assignment.questionnaires.each do |questionnaire|
      scores[questionnaire.symbol] = {}
      scores[questionnaire.symbol][:assessments] = ReviewResponseMap.where(reviewee_id: self.id)
      scores[questionnaire.symbol][:scores] = Answer.compute_scores(scores[questionnaire.symbol][:assessments], questions[questionnaire.symbol])
    end
    scores[:total_score] = assignment.compute_total_score(scores)
    scores
  end

  def hyperlinks
    self.submitted_hyperlinks.blank? ? [] : YAML.load(self.submitted_hyperlinks)
  end

  # Appends the hyperlink to a list that is stored in YAML format in the DB
  # @exception  If is hyperlink was already there
  #             If it is an invalid URL

  def submit_hyperlink(hyperlink)
    hyperlink.strip!
    raise "The hyperlink cannot be empty!" if hyperlink.empty?
    url = URI.parse(hyperlink)
    # If not a valid URL, it will throw an exception
    Net::HTTP.start(url.host, url.port)
    hyperlinks = self.hyperlinks
    hyperlinks << hyperlink
    self.submitted_hyperlinks = YAML.dump(hyperlinks)
    self.save
  end

  # Note: This method is not used yet. It is here in the case it will be needed.
  # @exception  If the index does not exist in the array

  def remove_hyperlink(hyperlink_to_delete)
    hyperlinks = self.hyperlinks
    hyperlinks.delete(hyperlink_to_delete)
    self.submitted_hyperlinks = YAML.dump(hyperlinks)
    self.save
  end

  # return the team given the participant
  def self.team(participant)
    return nil if participant.nil?
    team = nil
    teams_users = TeamsUser.where(user_id: participant.user_id)
    return nil unless teams_users
    teams_users.each do |teams_user|
      team = Team.find(teams_user.team_id)
      return team if team.parent_id == participant.parent_id
    end
    nil
  end

  # Export the fields
  def self.export_fields(options)
    fields = []
    fields.push("Team Name")
    fields.push("Team members") if options[:team_name] == "false"
    fields.push("Assignment Name")
  end

  # Remove a team given the team id
  def self.remove_team_by_id(id)
    old_team = AssignmentTeam.find(id)
    old_team.destroy unless old_team.nil?
  end

  # Get the path of the team directory
  def path
    self.assignment.path + "/" + self.directory_num.to_s
  end

  # Set the directory num for this team
  def set_student_directory_num
    if self.directory_num.nil? || self.directory_num < 0
      max_num = AssignmentTeam.where(parent_id: self.parent_id).order('directory_num desc').first.directory_num
      dir_num = max_num ? max_num + 1 : 0
      self.update_attribute('directory_num', dir_num)
      # ACS Get participants irrespective of the number of participants in the team
      # removed check to see if it is a team assignment
    end
  end

  def received_any_peer_review?
    !ResponseMap.where(reviewee_id: self.id, reviewed_object_id: self.parent_id).empty?
  end

  require File.dirname(__FILE__) + '/analytic/assignment_team_analytic'
  include AssignmentTeamAnalytic
end
