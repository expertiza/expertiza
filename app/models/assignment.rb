###
####
#### We have spent a lot of time on refactoring this file, PLEASE consult with Expertiza development team before putting code in.
###
###

class Assignment < ApplicationRecord
  require 'analytic/assignment_analytic'
  include Scoring
  include AssignmentAnalytic
  include ReviewAssignment
  include QuizAssignment
  include AssignmentHelper
  has_paper_trail
  # When an assignment is created, it needs to
  # be created as an instance of a subclass of the Assignment (model) class;
  # then Rails will "automatically' set the type field to the value that
  # designates an assignment of the appropriate type.
  belongs_to :course
  belongs_to :instructor, class_name: 'User', inverse_of: :assignments
  has_one :assignment_node, foreign_key: 'node_object_id', dependent: :destroy, inverse_of: :assignment
  has_many :participants, class_name: 'AssignmentParticipant', foreign_key: 'parent_id', dependent: :destroy
  has_many :users, through: :participants, inverse_of: :assignment
  has_many :due_dates, class_name: 'AssignmentDueDate', foreign_key: 'parent_id', dependent: :destroy, inverse_of: :assignment
  has_many :teams, class_name: 'AssignmentTeam', foreign_key: 'parent_id', dependent: :destroy, inverse_of: :assignment
  has_many :invitations, class_name: 'Invitation', foreign_key: 'assignment_id', dependent: :destroy # , inverse_of: :assignment
  has_many :assignment_questionnaires, dependent: :destroy
  has_many :questionnaires, through: :assignment_questionnaires
  has_many :sign_up_topics, foreign_key: 'assignment_id', dependent: :destroy, inverse_of: :assignment
  has_many :response_maps, foreign_key: 'reviewed_object_id', dependent: :destroy, inverse_of: :assignment
  has_many :review_mappings, class_name: 'ReviewResponseMap', foreign_key: 'reviewed_object_id', dependent: :destroy, inverse_of: :assignment
  has_many :plagiarism_checker_assignment_submissions, dependent: :destroy
  has_many :assignment_badges, dependent: :destroy
  has_many :badges, through: :assignment_badges
  validates :name, presence: true
  validates :name, uniqueness: { scope: :course_id }
  validate :valid_num_review
  validates :directory_path, presence: true # E2138 Validation for unique submission directory
  validates :directory_path, uniqueness: { scope: :course_id }

  REVIEW_QUESTIONNAIRES = { author_feedback: 0, metareview: 1, review: 2, teammate_review: 3 }.freeze

  #  Review Strategy information.
  RS_AUTO_SELECTED = 'Auto-Selected'.freeze
  RS_INSTRUCTOR_SELECTED = 'Instructor-Selected'.freeze
  REVIEW_STRATEGIES = [RS_AUTO_SELECTED, RS_INSTRUCTOR_SELECTED].freeze
  DEFAULT_MAX_REVIEWERS = 3
  DEFAULT_MAX_OUTSTANDING_REVIEWS = 2

  def user_on_team?(user)
    teams = self.teams
    users = []
    teams.each do |team|
      users << team.users
    end
    users.flatten.include? user
  end

  def self.max_outstanding_reviews
    DEFAULT_MAX_OUTSTANDING_REVIEWS
  end

  def team_assignment?
    max_team_size > 0
  end
  alias team_assignment team_assignment?

  def topics?
    @has_topics ||= sign_up_topics.any?
  end

  def calibrated?
    is_calibrated
  end

  def self.assign_courses_to_assignment(user)
    @courses = Course.where(instructor_id: user.id).order(:name)
  end

  # removes an assignment from course
  def remove_assignment_from_course
    oldpath = begin
                path
              rescue StandardError
                nil
              end
    self.course_id = nil
    save
    newpath = begin
                path
              rescue StandardError
                nil
              end
    FileHelper.update_file_location(oldpath, newpath)
  end

  def teams?
    @has_teams ||= teams.any?
  end

  # remove empty teams (teams with no users) from assignment
  def remove_empty_teams
    empty_teams = teams.reload.select { |team| team.teams_users.empty? }
    teams.delete(empty_teams)
  end

  # checks whether the assignment is getting a valid number of reviews (less than number of reviews allowed)
  def valid_num_review
    self.num_reviews = num_reviews_allowed
    if num_reviews_greater?(num_reviews_required, num_reviews_allowed)
      errors.add(:message, 'Num of reviews required cannot be greater than number of reviews allowed')
    elsif num_reviews_greater?(num_metareviews_required, num_metareviews_allowed)
      errors.add(:message, 'Number of Meta-Reviews required cannot be greater than number of meta-reviews allowed')
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
    response_map_set.reject! { |response_map| response_map.response.empty? }
    raise 'There are no reviews to metareview at this time for this assignment.' if response_map_set.empty?

    # Reject reviews where the meta_reviewer was the reviewer or the contributor
    response_map_set.reject! do |response_map|
      (response_map.reviewee == metareviewer) || (response_map.reviewer == metareviewer)
    end
    raise 'There are no more reviews to metareview for this assignment.' if response_map_set.empty?

    # Metareviewer can only metareview each review once
    response_map_set.reject! { |response_map| response_map.metareviewed_by?(metareviewer) }
    raise 'You have already metareviewed all reviews for this assignment.' if response_map_set.empty?

    # Reduce to the response maps with the least number of metareviews received
    min_metareviews = min_metareview(response_map_set)
    response_map_set.reject! { |response_map| response_map.metareview_response_maps.count > min_metareviews }

    # Reduce the response maps to the reviewers with the least number of metareviews received
    reviewers = reviewer_metareviews_map(response_map_set)
    min_metareviews = reviewers.first[1]
    reviewers.reject! { |reviewer| reviewer[1] == min_metareviews }
    response_map_set.reject! { |response_map| reviewers.member?(response_map.reviewer) }

    # Pick the response map whose most recent meta_reviewer was assigned longest ago
    min_metareviews = min_metareview(response_map_set)
    response_map_set.sort! { |a, b| a.metareview_response_maps.last.id <=> b.metareview_response_maps.last.id } if min_metareviews > 0
    # The first review_map is the best to metareview
    response_map_set.first
  end

  def metareview_mappings
    mappings = []
    review_mappings.each do |map|
      m_map = MetareviewResponseMap.find_by(reviewed_object_id: map.id)
      mappings << m_map unless m_map.nil?
    end
    mappings
  end
  #--------------------metareview assignment end

  def dynamic_reviewer_assignment?
    review_assignment_strategy == RS_AUTO_SELECTED
  end
  alias is_using_dynamic_reviewer_assignment? dynamic_reviewer_assignment?

  def path
    if course_id.nil? && instructor_id.nil?
      raise 'The path cannot be created. The assignment must be associated with either a course or an instructor.'
    end

    path_text = if !course_id.nil? && course_id > 0
                  Rails.root.to_s + '/pg_data/' + FileHelper.clean_path(instructor[:username]) + '/' +
                    FileHelper.clean_path(course.directory_path) + '/'
                else
                  Rails.root.to_s + '/pg_data/' + FileHelper.clean_path(instructor[:username]) + '/'
                end
    path_text += FileHelper.clean_path(directory_path)
    path_text
  end

  # Check whether review, metareview, etc.. is allowed
  # The permissions of TopicDueDate is the same as AssignmentDueDate.
  # Here, column is usually something like 'review_allowed_id'
  def check_condition(column, topic_id = nil)
    next_due_date = DueDate.get_next_due_date(id, topic_id)
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
    check_condition('quiz_allowed_id', topic_id)
  end

  # Determine if the next due date from now allows for reviews
  def can_review(topic_id = nil)
    check_condition('review_allowed_id', topic_id)
  end

  # Determine if the next due date from now allows for metareviews
  def metareview_allowed(topic_id = nil)
    check_condition('review_of_review_allowed_id', topic_id)
  end

  # Deletes all instances created as part of assignment and finally destroys itself.
  def delete(force = nil)
    begin
      maps = ReviewResponseMap.where(reviewed_object_id: id)
      maps.each { |map| map.delete(force) }
    rescue StandardError
      raise "There is at least one review response that exists for #{name}."
    end

    begin
      maps = TeammateReviewResponseMap.where(reviewed_object_id: id)
      maps.each { |map| map.delete(force) }
    rescue StandardError
      raise "There is at least one teammate review response that exists for #{name}."
    end

    # destroy instances of invitations, teams, participants, etc, refactored by Rajan, Jasmine, Sreenidhi 3/30/2020
    # You can now add the instances to be deleted into the list.
    delete_instances = %w[invitations teams participants due_dates assignment_questionnaires]
    delete_instances.each do |instance|
      instance_eval(instance).each(&:destroy)
    end

    # The size of an empty directory is 2
    # Delete the directory if it is empty
    directory = begin
                  Dir.entries(Rails.root + '/pg_data/' + directory_path)
                rescue StandardError
                  nil
                end
    if directory_path.present? && !directory.nil?
      raise 'The assignment directory is not empty.' unless directory.size == 2

      Dir.delete(Rails.root + '/pg_data/' + directory_path)
    end
    destroy
  end

  # Check to see if assignment is a microtask
  def microtask?
    microtask.nil? ? false : microtask
  end

  # Check to see if assignment has badge
  def badge?
    has_badge.nil? ? false : has_badge
  end

  # add a new participant to this assignment
  # manual addition
  # user_name - the user account name of the participant to add
  def add_participant(user_name, can_submit, can_review, can_take_quiz, can_mentor)
    user = User.find_by(username: user_name)
    if user.nil?
      raise "The user account with the username #{user_name} does not exist. Please <a href='" +
            url_for(controller: 'users', action: 'new') + "'>create</a> the user first."
    end
    participant = AssignmentParticipant.find_by(parent_id: id, user_id: user.id)
    raise "The user #{user.username} is already a participant." if participant

    new_part = AssignmentParticipant.create(parent_id: id,
                                            user_id: user.id,
                                            permission_granted: user.master_permission_granted,
                                            can_submit: can_submit,
                                            can_review: can_review,
                                            can_take_quiz: can_take_quiz,
                                            can_mentor: can_mentor)
    new_part.set_handle
  end

  def create_node
    parent = CourseNode.find_by(node_object_id: course_id)
    node = AssignmentNode.create(node_object_id: id)
    node.parent_id = parent.id unless parent.nil?
    node.save
  end

  # if current  stage is submission or review, find the round number
  # otherwise, return 0
  def number_of_current_round(topic_id)
    next_due_date = DueDate.get_next_due_date(id, topic_id)
    return 0 if next_due_date.nil?

    next_due_date.round ||= 0
  end

  # For varying rubric feature
  def current_stage_name(topic_id = nil)
    if staggered_deadline?
      return (topic_id.nil? ? 'Unknown' : current_stage(topic_id))
    end

    due_date = find_current_stage(topic_id)
    unless due_date == 'Finished' || due_date.nil? || due_date.deadline_name.nil?
      return due_date.deadline_name
    end

    current_stage(topic_id)
  end

  # check if this assignment has multiple review phases with different review rubrics
  def varying_rubrics_by_round?
    # E-2084 corrected '>=' to '>' to fix logic
    #This is a hack, we should actually check if we have more than one rubric of a given type eg, review
    AssignmentQuestionnaire.where(assignment_id: id, used_in_round: 2).size >= 1
  end

  def link_for_current_stage(topic_id = nil)
    return nil if staggered_and_no_topic?(topic_id)

    due_date = find_current_stage(topic_id)
    if due_date.nil? || (due_date == 'Finished') || due_date.is_a?(TopicDueDate)
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
    due_dates = AssignmentDueDate.where(parent_id: id)
    rounds = 0
    due_dates.each do |due_date|
      rounds = due_date.round if due_date.round > rounds
    end
    rounds
  end

  def find_current_stage(topic_id = nil)
    next_due_date = DueDate.get_next_due_date(id, topic_id)
    return 'Finished' if next_due_date.nil?

    next_due_date
  end

  # Zhewei: this method is almost the same as 'stage_deadline'
  def current_stage(topic_id = nil)
    return 'Unknown' if staggered_and_no_topic?(topic_id)

    due_date = find_current_stage(topic_id)
    due_date.nil? || due_date == 'Finished' ? 'Finished' : DeadlineType.find(due_date.deadline_type_id).name
  end

  # Find the ID of a review questionnaire for this assignment
  def review_questionnaire_id(round_number = nil, topic_id = nil)
    # If round is not given, try to retrieve current round from the next due date
    if round_number.nil?
      next_due_date = DueDate.get_next_due_date(id)
      round_number = next_due_date.try(:round)
    end
    # Create assignment_form that we can use to retrieve AQ with all the same attributes and questionnaire based on AQ
    assignment_form = AssignmentForm.create_form_object(id)
    assignment_questionnaire = assignment_form.assignment_questionnaire('ReviewQuestionnaire', round_number, topic_id)
    questionnaire = assignment_form.questionnaire(assignment_questionnaire, 'ReviewQuestionnaire')
    return questionnaire.id unless questionnaire.id.nil?

    # If correct questionnaire is not found, find it by type
    AssignmentQuestionnaire.where(assignment_id: id).select do |aq|
      !aq.questionnaire_id.nil? && Questionnaire.find(aq.questionnaire_id).type == 'ReviewQuestionnaire'
      return aq.questionnaire_id
    end
    nil
  end

  def self.export_details(csv, parent_id, detail_options)
    return csv unless detail_options.value?('true')

    @assignment = Assignment.find(parent_id)
    @answers = {} # Contains all answer objects for this assignment
    # Find all unique response types
    @uniq_response_type = ResponseMap.where.not(type: nil).pluck(:type).uniq
    # Find all unique round numbers
    @uniq_rounds = Response.pluck(:round).uniq
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
  # Now you could add your export fields to the hashmap
  EXPORT_DETAIL_FIELDS = { team_id: 'Team ID / Author ID', team_name: 'Reviewee (Team / Student Name)', reviewer: 'Reviewer', question: 'Question / Criterion', question_id: 'Question ID', comment_id: 'Answer / Comment ID', comments: 'Answer / Comment', score: 'Score' }.freeze
  def self.export_details_fields(detail_options)
    fields = []
    EXPORT_DETAIL_FIELDS.each do |key, value|
      fields << value if detail_options[key.to_s] == 'true'
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
    teams_csv << handle_nil(reviewer.username) if detail_options['reviewer'] == 'true'
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
        @associated_answers = Answer.find_by_sql(["SELECT * FROM answers WHERE response_id = #{resp.id}"])
        @associated_answers.each do |answer|
          answers[resp.round][map.type].push(answer)
        end
      end
    end
    answers
  end

  # Checks if there are rounds with no reviews
  def self.check_empty_rounds(answers, round_num, res_type)
    if answers[round_num][res_type].any?
      round_num.nil? ? 'Round Nil - ' + res_type : 'Round ' + round_num.to_s + ' - ' + res_type.to_s
    end
  end

  # This method is used to set the headers for the csv like Assignment Name and Assignment Instructor
  def self.export_headers(parent_id)
    @assignment = Assignment.find(parent_id)
    fields = []
    fields << 'Assignment Name: ' + @assignment.name.to_s
    fields << 'Assignment Instructor: ' + User.find(@assignment.instructor_id).username.to_s
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
    @scores = @assignment.review_grades(@assignment, @questions)
    return csv if @scores[:teams].nil?

    export_data(csv, @scores, options)
  end

  def self.export_data(csv, scores, options)
    @scores = scores
    (0..@scores[:teams].length - 1).each do |index|
      team = @scores[:teams][index.to_s.to_sym]
      first_participant = team[:team].participants[0] unless team[:team].participants[0].nil?
      next if first_participant.nil?
      participants_score = @scores[:participants][first_participant.id.to_s.to_sym]
      teams_csv = []
      teams_csv << team[:team].name
      names_of_participants = ''
      team[:team].participants.each do |p|
        names_of_participants += p.name
        names_of_participants += '; ' unless p == team[:team].participants.last
      end
      teams_csv << names_of_participants
      export_data_fields(options, team, teams_csv, participants_score)
      csv << teams_csv
    end
  end

  def self.export_data_fields(options, team, teams_csv, participants_score)
    if options['team_score'] == 'true'
      if team[:scores]
        teams_csv.push(team[:scores][:max], team[:scores][:min], team[:scores][:avg])
      else
        teams_csv.push('---', '---', '---')
      end
    end
    review_hype_mapping_hash = { review: 'submitted_score',
                                 metareview: 'metareview_score',
                                 feedback: 'author_feedback_score',
                                 teammate: 'teammate_review_score' }
    review_hype_mapping_hash.each do |review_type, score_name|
      export_individual_data_fields(review_type, score_name, teams_csv, participants_score, options)
    end
    teams_csv.push(participants_score[:total_score])
  end

  def self.export_individual_data_fields(review_type, score_name, teams_csv, participants_score, options)
    if participants_score[review_type]
      teams_csv.push(participants_score[review_type][:scores][:max], participants_score[review_type][:scores][:min], participants_score[review_type][:scores][:avg])
    elsif options[score_name]
      teams_csv.push('---', '---', '---')
    end
  end

  # This method was refactored by Rajan, Jasmine, Sreenidhi on 03/31/2020
  # Now you can add groups of fields to the hashmap
  EXPORT_FIELDS = { team_score: ['Team Max', 'Team Min', 'Team Avg'], submitted_score: ['Submitted Max', 'Submitted Min', 'Submitted Avg'], metareview_score: ['Metareview Max', 'Metareview Min', 'Metareview Avg'], author_feedback_score: ['Author Feedback Max, Author Feedback Min, Author Feedback Avg'], teammate_review_score: ['Teammate Review Max', 'Teammate Review Min', 'Teammate Review Avg'] }.freeze
  def self.export_fields(options)
    fields = []
    fields << 'Team Name'
    fields << 'Team Member(s)'
    EXPORT_FIELDS.each do |key, value|
      next unless options[key.to_s] == 'true'

      value.each do |f|
        fields.push(f)
      end
    end
    fields.push('Final Score')
    fields
  end

  def find_due_dates(type)
    due_dates.select { |due_date| due_date.deadline_type_id == DeadlineType.find_by(name: type).id }
  end

  # Method find_review_period is used in answer_helper.rb to get the start and end dates of a round
  def find_review_period(round)
    # If round is nil, it means the same questionnaire is used for every round. Thus, we return all periods.
    # If round is not nil, we return only the period of that round.

    submission_type = DeadlineType.find_by(name: 'submission').id
    review_type = DeadlineType.find_by(name: 'review').id

    due_dates = []
    due_dates += find_due_dates('submission')
    due_dates += find_due_dates('review')
    due_dates.sort_by!(&:id)

    start_dates = []
    end_dates = []

    if round.nil?
      round = 1
      while self.due_dates.exists?(round: round)
        start_dates << due_dates.select { |due_date| due_date.deadline_type_id == submission_type && due_date.round == round }.last
        end_dates << due_dates.select { |due_date| due_date.deadline_type_id == review_type && due_date.round == round }.last
        round += 1
      end
    else
      start_dates << due_dates.select { |due_date| due_date.deadline_type_id == submission_type && due_date.round == round }.last
      end_dates << due_dates.select { |due_date| due_date.deadline_type_id == review_type && due_date.round == round }.last
    end
    [start_dates, end_dates]
  end

  # for program 1 like assignment, if same rubric is used in both rounds,
  # the 'used_in_round' field in 'assignment_questionnaires' will be null,
  # since one field can only store one integer
  # if questionnaire_ids is empty, Expertiza will try to find questionnaire whose type is 'ReviewQuestionnaire'.
  def questionnaire_ids(round)
    questionnaire_ids = if round.nil?
                          AssignmentQuestionnaire.where(assignment_id: id)
                        else
                          AssignmentQuestionnaire.where(assignment_id: id, used_in_round: round)
                        end
    if questionnaire_ids.empty?
      AssignmentQuestionnaire.where(assignment_id: id).find_each do |aq|
        questionnaire_ids << aq if aq.questionnaire.type == 'ReviewQuestionnaire'
      end
    end
    questionnaire_ids
  end

  def pair_programming_enabled?
    self.enable_pair_programming
  end

  private

  # returns true if assignment has staggered deadline and topic_id is nil
  def staggered_and_no_topic?(topic_id)
    staggered_deadline? && topic_id.nil?
  end

  # returns true if reviews required is greater than reviews allowed
  def num_reviews_greater?(reviews_required, reviews_allowed)
    reviews_allowed && reviews_allowed != -1 && reviews_required > reviews_allowed
  end

  def min_metareview(response_map_set)
    response_map_set.sort! { |a, b| a.metareview_response_maps.count <=> b.metareview_response_maps.count }
    min_metareviews = response_map_set.first.metareview_response_maps.count
    min_metareviews
  end

  # returns a map of reviewer to meta_reviews
  def reviewer_metareviews_map(response_map_set)
    reviewers = {}
    response_map_set.each do |response_map|
      reviewer = response_map.reviewer
      reviewers.member?(reviewer) ? reviewers[reviewer] += 1 : reviewers[reviewer] = 1
    end
    reviewers = reviewers.sort_by { |a| a[1] }
  end

  #Method to drop all the SignedUpRecords of all topics for that assignment once the drop_topic deadline passes
  def drop_waitlisted_teams
    # Find all the topics (sign_up_topics) under the current assignment (self).
    topics = SignUpTopic.where(assignment_id: self.id)
  
    # Iterate through each topic to find and drop waitlisted teams.
    topics.each do |topic|
      signed_up_teams = SignedUpTeam.where(topic_id: topic.id, is_waitlisted: true)
      # Remove all of the waitlisted SignedUpTeam entries for this topic.
      signed_up_teams.destroy_all
    end
  end

end

