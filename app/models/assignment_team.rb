class AssignmentTeam < Team

  belongs_to :assignment, :class_name => 'Assignment', :foreign_key => 'parent_id'
  has_many :review_mappings, :class_name => 'ReviewResponseMap', :foreign_key => 'reviewee_id'
  has_many :review_response_maps, foreign_key: :reviewee_id
  has_many :responses, through: :review_response_maps, foreign_key: :map_id

  # START of contributor methods, shared with AssignmentParticipant

  # Whether this team includes a given participant or not
  def includes?(participant)
    participants.include?(participant)
  end

  #Use current object (AssignmentTeam) as reviewee and create the ReviewResponseMap record
  def assign_reviewer(reviewer)
    assignment = Assignment.find(self.parent_id)
    if assignment==nil
      raise "cannot find this assignment"
    end

    ReviewResponseMap.create(:reviewee_id => self.id, :reviewer_id => reviewer.id,
                             :reviewed_object_id => assignment.id)
  end

  # Evaluates whether any contribution by this team was reviewed by reviewer
  # @param[in] reviewer AssignmentParticipant object
  def reviewed_by?(reviewer)
    #ReviewResponseMap.count(conditions: ['reviewee_id = ? && reviewer_id = ? && reviewed_object_id = ?',  self.id, reviewer.id, assignment.id]) > 0
    ReviewResponseMap.where('reviewee_id = ? && reviewer_id = ? && reviewed_object_id = ?', self.id, reviewer.id, assignment.id).count > 0
  end

  # Topic picked by the team
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
    (self.submitted_files.length > 0) or self.submitted_hyperlinks.blank?
  end

  def reviewed_contributor?(contributor)
    ReviewResponseMap.all(conditions: ['reviewee_id = ? && reviewer_id = ? && reviewed_object_id = ?', contributor.id, self.id, assignment.id]).empty? == false
  end

  # END of contributor methods

  def participants
    participants = Array.new
    users.each { |user|
      participants.push(AssignmentParticipant.where(parent_id: parent_id, user_id: user.id).first)
    }
    return participants
  end

  alias_method :get_participants, :participants

  def delete
    if read_attribute(:type) == 'AssignmentTeam'
      sign_up = SignedUpTeam.find_team_participants(parent_id.to_s).select { |p| p.team_id == self.id }
      sign_up.each(&:destroy)
    end
    super
  end

  def destroy
    review_response_maps.each(&:destroy)
    super
  end

  def self.first_member(team_id)
    find(team_id).participants.first
  end

  def files(directory)
    files_list = Dir[directory + "/*"]
    files = Array.new

    files_list.each do |file|
      if File.directory?(file)
        dir_files = files(file)
        dir_files.each { |f| files << f }
      end
      files << file
    end
    files
  end

  def submitted_files
    files = Array.new
    if (self.directory_num)
      files = files(self.path)
    end
    return files
  end

  def review_map_type
    'ReviewResponseMap'
  end

  #REFACTOR BEGIN:: functionality of import,export, handle_duplicate shifted to team.rb

  def self.import(row, assignment_id, options)
    raise ImportError, "The assignment with id \""+id.to_s+"\" was not found. <a href='/assignment/new'>Create</a> this assignment?" if Assignment.find(assignment_id) == nil
    @assignmentteam = prototype
    Team.import(row, assignment_id, options, @assignmentteam)
  end

  def self.export(csv, parent_id, options)
    @assignmentteam = prototype
    Team.export(csv, parent_id, options, @assignmentteam)
  end

  #REFACTOR END:: functionality of import, export handle_duplicate shifted to team.rb


  # def participant_type
  #   "AssignmentParticipant"
  # end

  def parent_model
    "Assignment"
  end

  def fullname
    self.name
  end

  def self.prototype
    AssignmentTeam.new
  end

  def participants
    users = self.users
    participants = Array.new
    users.each do |user|
      participant = AssignmentParticipant.where(user_id: user.id, parent_id: self.parent_id).first
      participants << participant if participant != nil
    end
    participants
  end

  def copy(course_id)
    new_team = CourseTeam.create_team_and_node(course_id, true)
    new_team.name = name
    new_team.save
    #new_team = CourseTeam.create({:name => self.name, :parent_id => course_id})
    copy_members(new_team)
  end

  def add_participant(assignment_id, user)
    AssignmentParticipant.create(parent_id: assignment_id, user_id: user.id, permission_granted: user.master_permission_granted) if AssignmentParticipant.where(parent_id: assignment_id, user_id: user.id).first == nil
  end

  def assignment
    Assignment.find(self.parent_id)
  end

  # return a hash of scores that the team has received for the questions
  def scores(questions)
    scores = Hash.new
    scores[:team] = self # This doesn't appear to be used anywhere
    assignment.questionnaires.each do |questionnaire|
      scores[questionnaire.symbol] = Hash.new
      scores[questionnaire.symbol][:assessments] = ReviewResponseMap.where(reviewee_id: self.id)
      scores[questionnaire.symbol][:scores] = Answer.compute_scores(scores[questionnaire.symbol][:assessments], questions[questionnaire.symbol])
    end
    scores[:total_score] = assignment.compute_total_score(scores)
    scores
  end

  def self.team(participant)
    return nil if participant.nil?
    team = nil
    teams_users = TeamsUser.where(user_id: participant.user_id)
    return nil if !teams_users
    teams_users.each do |teams_user|
      team = Team.find(teams_user.team_id)
      return team if team.parent_id==participant.parent_id
    end
    nil
  end


  def self.export_fields(options)
    fields = Array.new
    fields.push("Team Name")
    fields.push("Team members") if options[:team_name] == "false"
    fields.push("Assignment Name")
  end


  #Remove a team given the team id
  def self.remove_team_by_id(id)
    old_team = AssignmentTeam.find(id)
    if old_team != nil
      old_team.destroy
    end
  end

  def path
    self.assignment.path + "/"+ self.directory_num.to_s
  end

  def set_student_directory_num
    if self.directory_num.nil? || self.directory_num < 0
      max_num = AssignmentTeam.where(parent_id: self.parent_id).order('directory_num desc').first.directory_num
      dir_num = max_num ? max_num + 1 : 0
      self.update_attribute('directory_num', dir_num)
      #ACS Get participants irrespective of the number of participants in the team
      #removed check to see if it is a team assignment
    end
  end

  require File.dirname(__FILE__) + '/analytic/assignment_team_analytic'
  include AssignmentTeamAnalytic
end
