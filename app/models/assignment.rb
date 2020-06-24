###
###
### We have spent a lot of time on refactoring this file, PLEASE consult with Expertiza development team before putting code in.
###
###

class Assignment < ActiveRecord::Base
  require 'analytic/assignment_analytic'
  include AssignmentAnalytic
  include ReviewAssignment
  include QuizAssignment
  include OnTheFlyCalc
  has_paper_trail
  # When an assignment is created, it needs to
  # be created as an instance of a subclass of the Assignment (model) class;
  # then Rails will "automatically' set the type field to the value that
  # designates an assignment of the appropriate type.
  belongs_to :course
  belongs_to :instructor, class_name: 'User',inverse_of: :assignments
  has_one :assignment_node, foreign_key: 'node_object_id', dependent: :destroy, inverse_of: :assignment
  has_many :participants, class_name: 'AssignmentParticipant', foreign_key: 'parent_id', dependent: :destroy
  has_many :users, through: :participants, inverse_of: :assignment
  has_many :due_dates, class_name: 'AssignmentDueDate', foreign_key: 'parent_id', dependent: :destroy, inverse_of: :assignment
  has_many :teams, class_name: 'AssignmentTeam', foreign_key: 'parent_id', dependent: :destroy, inverse_of: :assignment
  has_many :invitations, class_name: 'Invitation', foreign_key: 'assignment_id', dependent: :destroy#, inverse_of: :assignment
  has_many :assignment_questionnaires, dependent: :destroy
  has_many :questionnaires, through: :assignment_questionnaires
  has_many :sign_up_topics, foreign_key: 'assignment_id', dependent: :destroy, inverse_of: :assignment
  has_many :response_maps, foreign_key: 'reviewed_object_id', dependent: :destroy, inverse_of: :assignment
  has_many :review_mappings, class_name: 'ReviewResponseMap', foreign_key: 'reviewed_object_id', dependent: :destroy, inverse_of: :assignment
  has_many :plagiarism_checker_assignment_submissions, dependent: :destroy
  has_many :assignment_badges, dependent: :destroy
  has_many :badges, through: :assignment_badges
  validates :name, presence: true
  validates :name, uniqueness: {scope: :course_id}
  validate :valid_num_review

  REVIEW_QUESTIONNAIRES = {author_feedback: 0, metareview: 1, review: 2, teammate_review: 3}.freeze

  #  Review Strategy information.
  RS_AUTO_SELECTED = 'Auto-Selected'.freeze
  RS_INSTRUCTOR_SELECTED = 'Instructor-Selected'.freeze
  REVIEW_STRATEGIES = [RS_AUTO_SELECTED, RS_INSTRUCTOR_SELECTED].freeze
  DEFAULT_MAX_REVIEWERS = 3
  DEFAULT_MAX_OUTSTANDING_REVIEWS = 2

  def self.max_outstanding_reviews
    DEFAULT_MAX_OUTSTANDING_REVIEWS
  end

  def team_assignment?
    true
  end
  alias team_assignment team_assignment?

  def topics?
    @has_topics ||= !sign_up_topics.empty?
  end

  def calibrated?
    self.is_calibrated
  end

  def self.assign_courses_to_assignment(user)
    @courses = Course.where(instructor_id: user.id).order(:name)
  end

  #removes an assignment from course
  def self.remove_assignment_from_course(assignment)
    oldpath = assignment.path rescue nil
    assignment.course_id = nil
    assignment.save
    newpath = assignment.path rescue nil
    FileHelper.update_file_location(oldpath, newpath)
  end

  def teams?
    @has_teams ||= !self.teams.empty?
  end

  #checks whether the assignment is getting a valid number of reviews (less than number of reviews allowed)
  def valid_num_review
    self.num_reviews = self.num_reviews_allowed
    if num_reviews_greater?(self.num_reviews_required, self.num_reviews_allowed)
      self.errors.add(:message, "Num of reviews required cannot be greater than number of reviews allowed")
    elsif num_reviews_greater?(self.num_metareviews_required, self.num_metareviews_allowed)
      self.errors.add(:message, "Number of Meta-Reviews required cannot be greater than number of meta-reviews allowed")
    end
  end

  #--------------------metareview assignment begin
  def assign_metareviewer_dynamically(meta_reviewer)
    # The following method raises an exception if not successful which
    # has to be captured by the caller (in review_mapping_controller)
    response_map = response_map_to_metareview(meta_reviewer)
    response_map.assign_metareviewer(meta_reviewer)
  end

  # Returns a review (response) to metareview if available, otherwise will raise an error
  def response_map_to_metareview(metareviewer)
    response_map_set = Array.new(review_mappings)
    # Reject response maps without responses
    response_map_set.reject! {|response_map| response_map.response.empty? }
    raise 'There are no reviews to metareview at this time for this assignment.' if response_map_set.empty?

    # Reject reviews where the meta_reviewer was the reviewer or the contributor
    response_map_set.reject! do |response_map|
      response_map.reviewee == metareviewer or response_map.reviewer == metareviewer
    end
    raise 'There are no more reviews to metareview for this assignment.' if response_map_set.empty?

    # Metareviewer can only metareview each review once
    response_map_set.reject! {|response_map| response_map.metareviewed_by?(metareviewer) }
    raise 'You have already metareviewed all reviews for this assignment.' if response_map_set.empty?

    # Reduce to the response maps with the least number of metareviews received
    min_metareviews=get_min_metareview(response_map_set)
    response_map_set.reject! {|response_map| response_map.metareview_response_maps.count > min_metareviews }

    # Reduce the response maps to the reviewers with the least number of metareviews received
    reviewers = get_reviewer_metareviews_map(response_map_set)
    min_metareviews = reviewers.first[1]
    reviewers.reject! {|reviewer| reviewer[1] == min_metareviews }
    response_map_set.reject! {|response_map| reviewers.member?(response_map.reviewer) }

    # Pick the response map whose most recent meta_reviewer was assigned longest ago
    min_metareviews=get_min_metareview(response_map_set)
    response_map_set.sort! {|a, b| a.metareview_response_maps.last.id <=> b.metareview_response_maps.last.id } if min_metareviews > 0
    # The first review_map is the best to metareview
    response_map_set.first
  end

  def metareview_mappings
    mappings = []
    self.review_mappings.each do |map|
      m_map = MetareviewResponseMap.find_by(reviewed_object_id: map.id)
      mappings << m_map unless m_map.nil?
    end
    mappings
  end
  #--------------------metareview assignment end

  def dynamic_reviewer_assignment?
    self.review_assignment_strategy == RS_AUTO_SELECTED
  end
  alias is_using_dynamic_reviewer_assignment? dynamic_reviewer_assignment?

  #Computes and returns the scores of assignment for participants and teams
  def scores(questions)
    scores = {:participants => {}, :teams => {}}
    self.participants.each do |participant|
      scores[:participants][participant.id.to_s.to_sym] = participant.scores(questions)
    end
    index = 0
    self.teams.each do |team|
      scores[:teams][index.to_s.to_sym] = {:team => team, :scores => {}}
      if self.varying_rubrics_by_round?
        grades_by_rounds, total_num_of_assessments, total_score = compute_grades_by_rounds(questions, team)
        # merge the grades from multiple rounds
        scores[:teams][index.to_s.to_sym][:scores] = merge_grades_by_rounds(grades_by_rounds, total_num_of_assessments, total_score)
      else
        assessments = ReviewResponseMap.get_assessments_for(team)
        scores[:teams][index.to_s.to_sym][:scores] = Answer.compute_scores(assessments, questions[:review])
      end
      index += 1
    end
    scores
  end

  def path
    if self.course_id.nil? && self.instructor_id.nil?
      raise 'The path cannot be created. The assignment must be associated with either a course or an instructor.'
    end

    path_text = if !self.course_id.nil? && self.course_id > 0
                  Rails.root.to_s + '/pg_data/' + FileHelper.clean_path(self.instructor[:name]) + '/' +
                    FileHelper.clean_path(self.course.directory_path) + '/'
                else
                  Rails.root.to_s + '/pg_data/' + FileHelper.clean_path(self.instructor[:name]) + '/'
                end
    path_text += FileHelper.clean_path(self.directory_path)
  end

  # Check whether review, metareview, etc.. is allowed
  # The permissions of TopicDueDate is the same as AssignmentDueDate.
  # Here, column is usually something like 'review_allowed_id'
  def check_condition(column, topic_id = nil)
    next_due_date = DueDate.get_next_due_date(self.id, topic_id)
    return false if next_due_date.nil?
    right_id = next_due_date.send column
    right = DeadlineRight.find(right_id)
    right && (right.name == 'OK' || right.name == 'Late')
  end

  # Determine if the next due date from now allows for submissions
  def submission_allowed(topic_id = nil)
    check_condition('submission_allowed_id', topic_id)
  end

  # Determine if the next due date from now allows to take the quizzes
  def quiz_allowed(topic_id = nil)
    check_condition("quiz_allowed_id", topic_id)
  end

  # Determine if the next due date from now allows for reviews
  def can_review(topic_id = nil)
    check_condition('review_allowed_id', topic_id)
  end

  # Determine if the next due date from now allows for metareviews
  def metareview_allowed(topic_id = nil)
    check_condition('review_of_review_allowed_id', topic_id)
  end

  #Deletes all instances created as part of assignment and finally destroys itself.
  def delete(force = nil)
    begin
      maps = ReviewResponseMap.where(reviewed_object_id: self.id)
      maps.each {|map| map.delete(force) }
    rescue StandardError
      raise "There is at least one review response that exists for #{self.name}."
    end

    begin
      maps = TeammateReviewResponseMap.where(reviewed_object_id: self.id)
      maps.each {|map| map.delete(force) }
    rescue StandardError
      raise "There is at least one teammate review response that exists for #{self.name}."
    end

    # destroy instances of invitations, teams, particiapnts, etc, refactored by Rajan, Jasmine, Sreenidhi 3/30/2020
    #You can now add the instances to be deleted into the list.
    delete_instances = ['invitations','teams','participants','due_dates','assignment_questionnaires']
    delete_instances.each do |instance|
      self.instance_eval(instance).each(&:destroy)
    end

    # The size of an empty directory is 2
    # Delete the directory if it is empty
    directory = Dir.entries(Rails.root + '/pg_data/' + self.directory_path) rescue nil
    if self.directory_path.present? and !directory.nil?
      raise 'The assignment directory is not empty.' if directory.size != 2
      Dir.delete(Rails.root + '/pg_data/' + self.directory_path)
    end
    self.destroy
  end

  # Check to see if assignment is a microtask
  def microtask?
    self.microtask.nil? ? false : self.microtask
  end

  # Check to see if assignment has badge
  def badge?
    self.has_badge.nil? ? false : self.has_badge
  end

  # add a new participant to this assignment
  # manual addition
  # user_name - the user account name of the participant to add
  def add_participant(user_name, can_submit, can_review, can_take_quiz)
    user = User.find_by(name: user_name)
    if user.nil?
      raise "The user account with the name #{user_name} does not exist. Please <a href='" +
        url_for(controller: 'users', action: 'new') + "'>create</a> the user first."
    end
    participant = AssignmentParticipant.find_by(parent_id: self.id, user_id: user.id)
    raise "The user #{user.name} is already a participant." if participant
    new_part = AssignmentParticipant.create(parent_id: self.id,
                                            user_id: user.id,
                                            permission_granted: user.master_permission_granted,
                                            can_submit: can_submit,
                                            can_review: can_review,
                                            can_take_quiz: can_take_quiz)
    new_part.set_handle
  end

  def create_node
    parent = CourseNode.find_by(node_object_id: self.course_id)
    node = AssignmentNode.create(node_object_id: self.id)
    node.parent_id = parent.id unless parent.nil?
    node.save
  end

  # if current  stage is submission or review, find the round number
  # otherwise, return 0
  def number_of_current_round(topic_id)
    next_due_date = DueDate.get_next_due_date(self.id, topic_id)
    return 0 if next_due_date.nil?
    next_due_date.round ||= 0
  end

  # For varying rubric feature
  def current_stage_name(topic_id = nil)
    if self.staggered_deadline?
      return (topic_id.nil? ? 'Unknown' : get_current_stage(topic_id))
    end

    due_date = find_current_stage(topic_id)
    if due_date != 'Finished' && !due_date.nil? && !due_date.deadline_name.nil?
      return due_date.deadline_name
    end
    get_current_stage(topic_id)
  end

  # check if this assignment has multiple review phases with different review rubrics
  def varying_rubrics_by_round?
    AssignmentQuestionnaire.where(assignment_id: self.id, used_in_round: 2).size >= 1
  end

  def link_for_current_stage(topic_id = nil)
    return nil if staggered_and_no_topic?(topic_id)

    due_date = find_current_stage(topic_id)
    if due_date.nil? or due_date == 'Finished' or due_date.is_a?(TopicDueDate)
      return nil
    end
    due_date.description_url
  end

  def stage_deadline(topic_id = nil)
    return 'Unknown' if staggered_and_no_topic?(topic_id)
    due_date = find_current_stage(topic_id)
    due_date.nil? || due_date == 'Finished' ? due_date : due_date.due_at.to_s
  end

  def num_review_rounds
    due_dates = AssignmentDueDate.where(parent_id: self.id)
    rounds = 0
    due_dates.each do |due_date|
      rounds = due_date.round if due_date.round > rounds
    end
    rounds
  end

  def find_current_stage(topic_id = nil)
    next_due_date = DueDate.get_next_due_date(self.id, topic_id)
    return 'Finished' if next_due_date.nil?
    next_due_date
  end

  # Zhewei: this method is almost the same as 'stage_deadline'
  def get_current_stage(topic_id = nil)
    return 'Unknown' if staggered_and_no_topic?(topic_id)
    due_date = find_current_stage(topic_id)
    due_date.nil? || due_date == 'Finished' ? 'Finished' : DeadlineType.find(due_date.deadline_type_id).name
  end

  def review_questionnaire_id(round = nil)
    # Get the round it's in from the next duedates
    if round.nil?
      next_due_date = DueDate.get_next_due_date(self.id)
      round = next_due_date.try(:round)
    end

    rev_questionnaire_ids = get_questionnaire_ids(round)
    review_questionnaire_id = nil
    rev_questionnaire_ids.each do |rqid|
      next if rqid.questionnaire_id.nil?
      rtype = Questionnaire.find(rqid.questionnaire_id).type
      if rtype == 'ReviewQuestionnaire'
        review_questionnaire_id = rqid.questionnaire_id
        break
      end
    end
    review_questionnaire_id
  end

  def self.export_details(csv, parent_id, detail_options)
    return csv unless detail_options.value?('true')
    @assignment = Assignment.find(parent_id)
    @answers = {} # Contains all answer objects for this assignment
    # Find all unique response types
    @uniq_response_type = ResponseMap.uniq.pluck(:type)
    # Find all unique round numbers
    @uniq_rounds = Response.uniq.pluck(:round)
    # create the nested hash that holds all the answers organized by round # and response type
    @uniq_rounds.each do |round_num|
      @answers[round_num] = {}
      @uniq_response_type.each do |res_type|
        @answers[round_num][res_type] = []
      end
    end
    @answers = generate_answer(@answers, @assignment)
    # Loop through each round and response type and construct a new row to be pushed in CSV
    @uniq_rounds.each do |round_num|
      @uniq_response_type.each do |res_type|
        round_type = check_empty_rounds(@answers, round_num, res_type)
        csv << [round_type, '---', '---', '---', '---', '---', '---', '---'] unless round_type.nil?
        @answers[round_num][res_type].each do |answer|
          csv << csv_row(detail_options, answer)
        end
      end
    end
  end

  # This method was refactored to reduce complexity, additional fields could now be added to the list - Rajan, Jasmine, Sreenidhi
  #Now you could add your export fields to the hashmap
  EXPORT_DETAIL_FIELDS={team_id:'Team ID / Author ID', team_name:'Reviewee (Team / Student Name)',reviewer:'Reviewer',question:'Question / Criterion',question_id:'Question ID',comment_id:'Answer / Comment ID',comments:'Answer / Comment',score:'Score' }.freeze
  def self.export_details_fields(detail_options)
    fields = []
    EXPORT_DETAIL_FIELDS.each do |key, value|
      fields << value if detail_options[key.to_s]=='true'
    end
    fields
  end

  def self.handle_nil(csv_field)
    return ' ' if csv_field.nil?
    csv_field
  end

  # Generates a single row based on the detail_options selected
  def self.csv_row(detail_options, answer)
    teams_csv = []
    @response = Response.find(answer.response_id)
    map = ResponseMap.find(@response.map_id)
    @reviewee = Team.find_by id: map.reviewee_id
    @reviewee = Participant.find(map.reviewee_id).user if @reviewee.nil?
    reviewer = Participant.find(map.reviewer_id).user
    teams_csv << handle_nil(@reviewee.id) if detail_options['team_id'] == 'true'
    teams_csv << handle_nil(@reviewee.name) if detail_options['team_name'] == 'true'
    teams_csv << handle_nil(reviewer.name) if detail_options['reviewer'] == 'true'
    teams_csv << handle_nil(answer.question.txt) if detail_options['question'] == 'true'
    teams_csv << handle_nil(answer.question.id) if detail_options['question_id'] == 'true'
    teams_csv << handle_nil(answer.id) if detail_options['comment_id'] == 'true'
    teams_csv << handle_nil(answer.comments) if detail_options['comments'] == 'true'
    teams_csv << handle_nil(answer.answer) if detail_options['score'] == 'true'
    teams_csv
  end

  # Populate answers will review information
  def self.generate_answer(answers, assignment)
    # get all response maps for this assignment
    @response_maps_for_assignment = ResponseMap.find_by_sql(["SELECT * FROM response_maps WHERE reviewed_object_id = #{assignment.id}"])
    # for each map, get the response & answer associated with it
    @response_maps_for_assignment.each do |map|
      @response_for_this_map = Response.find_by_sql(["SELECT * FROM responses WHERE map_id = #{map.id}"])
      # for this response, get the answer associated with it
      @response_for_this_map.each do |resp|
        @answer = Answer.find_by_sql(["SELECT * FROM answers WHERE response_id = #{resp.id}"])
        @answer.each do |ans|
          answers[resp.round][map.type].push(ans)
        end
      end
    end
    answers
  end

  # Checks if there are rounds with no reviews
  def self.check_empty_rounds(answers, round_num, res_type)
    unless answers[round_num][res_type].empty?
      return round_num.nil? ? "Round Nil - " + res_type : "Round " + round_num.to_s + " - " + res_type.to_s
    end
    nil
  end

  # This method is used to set the headers for the csv like Assignment Name and Assignment Instructor
  def self.export_headers(parent_id)
    @assignment = Assignment.find(parent_id)
    fields = []
    fields << "Assignment Name: " + @assignment.name.to_s
    fields << "Assignment Instructor: " + User.find(@assignment.instructor_id).name.to_s
    fields
  end

  # This method is used for export contents of grade#view.  -Zhewei
  def self.export(csv, parent_id, options)
    @assignment = Assignment.find(parent_id)
    @questions = {}
    questionnaires = @assignment.questionnaires
    questionnaires.each do |questionnaire|
      if @assignment.varying_rubrics_by_round?
        round = AssignmentQuestionnaire.find_by(assignment_id: @assignment.id, questionnaire_id: @questionnaire.id).used_in_round
        questionnaire_symbol = round.nil? ? questionnaire.symbol : (questionnaire.symbol.to_s + round.to_s).to_sym
      else
        questionnaire_symbol = questionnaire.symbol
      end
      @questions[questionnaire_symbol] = questionnaire.questions
    end
    @scores = @assignment.scores(@questions)
    return csv if @scores[:teams].nil?
    export_data(csv, @scores, options)
  end

  def self.export_data(csv, scores, options)
    @scores = scores
    (0..@scores[:teams].length - 1).each do |index|
      team = @scores[:teams][index.to_s.to_sym]
      first_participant = team[:team].participants[0] unless team[:team].participants[0].nil?
      teams_csv = []
      teams_csv << team[:team].name
      names_of_participants = ''
      team[:team].participants.each do |p|
        names_of_participants += p.fullname
        names_of_participants += '; ' unless p == team[:team].participants.last
      end
      teams_csv << names_of_participants
      export_data_fields(options)
      csv << teams_csv
    end
  end

  def self.export_data_fields(options)
    if options['team_score'] == 'true'
      if team[:scores]
        teams_csv.push(team[:scores][:max], team[:scores][:min], team[:scores][:avg])
      else
        teams_csv.push('---', '---', '---')
      end
    end
    review_hype_mapping_hash = {review: 'submitted_score',
                                metareview: 'metareview_score',
                                feedback: 'author_feedback_score',
                                teammate: 'teammate_review_score'}
    review_hype_mapping_hash.each do |review_type, score_name|
      export_individual_data_fields(review_type, score_name)
    end
    teams_csv.push(pscore[:total_score])
  end

  def self.export_individual_data_fields(review_type, score_name)
    if pscore[review_type]
      teams_csv.push(pscore[review_type][:scores][:max], pscore[review_type][:scores][:min], pscore[review_type][:scores][:avg])
    elsif options[score_name]
      teams_csv.push('---', '---', '---')
    end
  end

  # This method was refactored by Rajan, Jasmine, Sreenidhi on 03/31/2020
  #Now you can add groups of fields to the hashmap
  EXPORT_FIELDS={team_score:['Team Max','Team Min','Team Avg'], submitted_score:['Submitted Max','Submitted Min','Submitted Avg'],metareview_score:['Metareview Max','Metareview Min','Metareview Avg'],author_feedback_score:['Author Feedback Max, Author Feedback Min, Author Feedback Avg'],teammate_review_score:['Teammate Review Max', 'Teammate Review Min', 'Teammate Review Avg']}.freeze
  def self.export_fields(options)
    fields = []
    fields << 'Team Name'
    fields << 'Team Member(s)'
    EXPORT_FIELDS.each do |key, value|
      if options[key.to_s]=='true'
        value.each do |f|
          fields.push(f)
        end
      end
    end
    fields.push('Final Score')
    fields
  end

  def find_due_dates(type)
    self.due_dates.select {|due_date| due_date.deadline_type_id == DeadlineType.find_by(name: type).id }
  end

  private
  #Below private methods are extracted and added as part of refactoring project E2009 - Spring 2020
  #This method computes and returns grades by rounds, total_num_of_assessments and total_score
  # when the assignment has varying rubrics by round
  def compute_grades_by_rounds(questions, team)
    grades_by_rounds = {}
    total_score = 0
    total_num_of_assessments = 0 # calculate grades for each rounds
    (1..self.num_review_rounds).each do |i|
      assessments = ReviewResponseMap.get_responses_for_team_round(team, i)
      round_sym = ("review" + i.to_s).to_sym
      grades_by_rounds[round_sym] = Answer.compute_scores(assessments, questions[round_sym])
      total_num_of_assessments += assessments.size
      total_score += grades_by_rounds[round_sym][:avg] * assessments.size.to_f unless grades_by_rounds[round_sym][:avg].nil?
    end
    return grades_by_rounds, total_num_of_assessments, total_score
  end

  # merge the grades from multiple rounds
  def merge_grades_by_rounds(grades_by_rounds, num_of_assessments, total_score)
    team_scores = {:max => 0, :min => 0, :avg => nil}
    if num_of_assessments == 0
      return team_scores
    end

    team_scores[:max] = -999_999_999
    team_scores[:min] = 999_999_999
    team_scores[:avg] = total_score/num_of_assessments
    (1..self.num_review_rounds).each do |i|
      round_sym = ("review" + i.to_s).to_sym
      if !grades_by_rounds[round_sym][:max].nil? && team_scores[:max] < grades_by_rounds[round_sym][:max]
        team_scores[:max] = grades_by_rounds[round_sym][:max]
      end
      if !grades_by_rounds[round_sym][:min].nil? && team_scores[:min] > grades_by_rounds[round_sym][:min]
        team_scores[:min] = grades_by_rounds[round_sym][:min]
      end
    end
    team_scores
  end

  #returns true if assignment has staggered deadline and topic_id is nil
  def staggered_and_no_topic?(topic_id)
    self.staggered_deadline? and topic_id.nil?
  end

  #returns true if reviews required is greater than reviews allowed
  def num_reviews_greater?(reviews_required, reviews_allowed)
    reviews_allowed && reviews_allowed != -1 && reviews_required > reviews_allowed
  end

  # for program 1 like assignment, if same rubric is used in both rounds,
  # the 'used_in_round' field in 'assignment_questionnaires' will be null,
  # since one field can only store one integer
  # if questionnaire_ids is empty, Expertiza will try to find questionnaire whose type is 'ReviewQuestionnaire'.
  def get_questionnaire_ids(round)
    questionnaire_ids = if round.nil?
                          AssignmentQuestionnaire.where(assignment_id: self.id)
                        else
                          AssignmentQuestionnaire.where(assignment_id: self.id, used_in_round: round)
                        end
    if questionnaire_ids.empty?
      AssignmentQuestionnaire.where(assignment_id: self.id).find_each do |aq|
        questionnaire_ids << aq if aq.questionnaire.type == "ReviewQuestionnaire"
      end
    end
    questionnaire_ids
  end

  def get_min_metareview(response_map_set)
    response_map_set.sort! {|a, b| a.metareview_response_maps.count <=> b.metareview_response_maps.count }
    min_metareviews = response_map_set.first.metareview_response_maps.count
  end

  # returns a map of reviewer to meta_reviews
  def get_reviewer_metareviews_map(response_map_set)
    reviewers = {}
    response_map_set.each do |response_map|
      reviewer = response_map.reviewer
      reviewers.member?(reviewer) ? reviewers[reviewer] += 1 : reviewers[reviewer] = 1
    end
    reviewers = reviewers.sort_by {|a| a[1]}
  end
end
