###
###
### This class needs refactoring
###
###
class Assignment < ActiveRecord::Base
  require 'analytic/assignment_analytic'
  include AssignmentAnalytic
  belongs_to :course
  has_paper_trail

  # When an assignment is created, it needs to
  # be created as an instance of a subclass of the Assignment (model) class;
  # then Rails will "automatically' set the type field to the value that
  # designates an assignment of the appropriate type.
  has_many :participants, :class_name => 'AssignmentParticipant', :foreign_key => 'parent_id'
  has_many :users, :through => :participants
  has_many :due_dates, :dependent => :destroy
  has_many :teams, :class_name => 'AssignmentTeam', :foreign_key => 'parent_id'
  has_many :team_review_mappings, :class_name => 'ReviewResponseMap', :through => :teams, :source => :review_mappings
  has_many :invitations, :class_name => 'Invitation', :foreign_key => 'assignment_id', :dependent => :destroy
  has_many :assignment_questionnaires,:dependent => :destroy
  has_many :questionnaires, :through => :assignment_questionnaires
  belongs_to :instructor, :class_name => 'User', :foreign_key => 'instructor_id'
  has_many :sign_up_topics, :foreign_key => 'assignment_id', :dependent => :destroy
  has_many :response_maps, :foreign_key => 'reviewed_object_id', :class_name => 'ResponseMap'
  has_one :assignment_node,:foreign_key => :node_object_id,:dependent => :destroy
  has_many :review_mappings, :class_name => 'ReviewResponseMap', :foreign_key => 'reviewed_object_id'

  validates_presence_of :name
  validates_uniqueness_of :name, scope: :course_id

  COMPLETE = 'Finished'.freeze
  WAITLIST = 'Waitlist open'.freeze

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
  alias_method :team_assignment,:team_assignment?

  # Returns a set of topics that can be used for taking the quiz.
  # We choose the topics if one of its quiz submissions has been attempted the fewest times so far
  def candidate_topics_for_quiz
    return nil if sign_up_topics.empty? # This is not a topic assignment
    contributor_set = Array.new(contributors)
    # Reject contributors that have not selected a topic, or have no submissions
    contributor_set.reject! {|contributor| signed_up_topic(contributor).nil? }

    # Reject contributions of topics whose deadline has passed
    contributor_set.reject! do |contributor|
      contributor.assignment.get_current_stage(signed_up_topic(contributor).id) == "Complete" or
                            contributor.assignment.get_current_stage(signed_up_topic(contributor).id) == "submission"
    end

    candidate_topics = Set.new
    contributor_set.each {|contributor| candidate_topics.add(signed_up_topic(contributor)) }
    candidate_topics
  end

  # Returns a set of topics that can be reviewed.
  # We choose the topics if one of its submissions has received the fewest reviews so far
  # reviewer, the parameter, is an object of Participant
  def candidate_topics_to_review(reviewer)
    return nil if sign_up_topics.empty? # This is not a topic assignment

    # Initialize contributor set with all teams participating in this assignment
    contributor_set = Array.new(contributors)

    # Reject contributors that have not selected a topic, or have no submissions
    contributor_set = reject_by_no_topic_selection_or_no_submission(contributor_set)

    # Reject contributions of topics whose deadline has passed, or which are not reviewable in the current stage
    contributor_set = reject_by_deadline(contributor_set)

    # Filter submissions already reviewed by reviewer
    contributor_set = reject_previously_reviewed_submissions(contributor_set, reviewer)

    # Filter submission by reviewer him/her self
    contributor_set = reject_own_submission(contributor_set, reviewer)

    # Filter the contributors with the least number of reviews
    # (using the fact that each contributor is associated with a topic)
    contributor_set = reject_by_least_reviewed(contributor_set)

    contributor_set = reject_by_max_reviews_per_submission(contributor_set)

    # if this assignment does not allow reviewer to review other artifacts on the same topic,
    # remove those teams from candidate list.
    unless self.can_review_same_topic?
      contributor_set = reject_by_same_topic(contributor_set, reviewer)
    end

    # Add topics for all remaining submissions to a list of available topics for review
    candidate_topics = Set.new
    contributor_set.each do |contributor|
      candidate_topics.add(signed_up_topic(contributor))
    end
    candidate_topics
  end

  # This method is only for the assignments without topics
  def candidate_assignment_teams_to_review(reviewer)
    # the contributors are AssignmentTeam objects
    contributor_set = Array.new(contributors)

    # Reject contributors that have no submissions
    contributor_set.reject! {|contributor| !contributor.has_submissions? }

    # Filter submissions already reviewed by reviewer
    contributor_set = reject_previously_reviewed_submissions(contributor_set, reviewer)

    # Filter submission by reviewer him/her self
    contributor_set = reject_own_submission(contributor_set, reviewer)

    # Filter the contributors with the least number of reviews
    contributor_set = reject_by_least_reviewed(contributor_set)

    contributor_set = reject_by_max_reviews_per_submission(contributor_set)

    contributor_set
  end

  def reject_by_least_reviewed(contributor_set)
    contributor = contributor_set.min_by {|contributor| contributor.review_mappings.reject {|review_mapping| review_mapping.response.nil? }.count }
    min_reviews = contributor.review_mappings.reject {|review_mapping| review_mapping.response.nil? }.count rescue 0
    contributor_set.reject! {|contributor| contributor.review_mappings.reject {|review_mapping| review_mapping.response.nil? }.count > min_reviews + review_topic_threshold }

    contributor_set
  end

  def reject_by_max_reviews_per_submission(contributor_set)
    contributor_set.reject! {|contributor| contributor.review_mappings.reject {|review_mapping| review_mapping.response.nil? }.count >= max_reviews_per_submission }
    contributor_set
  end

  def reject_by_same_topic(contributor_set, reviewer)
    reviewer_team = AssignmentTeam.team(reviewer)
    # it is possible that this reviewer does not have a team, if so, do nothing
    if reviewer_team
      topic_id = reviewer_team.topic
      # it is also possible that this reviewer has team, but this team has no topic yet, if so, do nothing
      if topic_id
        contributor_set = contributor_set.reject {|contributor| contributor.topic == topic_id }
      end
    end

    contributor_set
  end

  def reject_previously_reviewed_submissions(contributor_set, reviewer)
    contributor_set = contributor_set.reject {|contributor| contributor.reviewed_by?(reviewer) }
    contributor_set
  end

  def reject_own_submission(contributor_set, reviewer)
    contributor_set.reject! {|contributor| contributor.has_user(User.find(reviewer.user_id)) }
    contributor_set
  end

  def reject_by_deadline(contributor_set)
    contributor_set.reject! do |contributor|
      contributor.assignment.get_current_stage(signed_up_topic(contributor).id) == 'Complete' or
      !contributor.assignment.can_review(signed_up_topic(contributor).id)
    end
    contributor_set
  end

  def reject_by_no_topic_selection_or_no_submission(contributor_set)
    contributor_set.reject! {|contributor| signed_up_topic(contributor).nil? or !contributor.has_submissions? }
    contributor_set
  end

  def has_topics?
    @has_topics ||= !sign_up_topics.empty?
  end

  def self.set_courses_to_assignment(user)
    @courses = Course.where(instructor_id: user.id).order(:name)
  end

  def self.remove_assignment_from_course(assignment)
    oldpath = assignment.path rescue nil
    assignment.course_id = nil
    assignment.save
    newpath = assignment.path rescue nil
    FileHelper.update_file_location(oldpath, newpath)
  end

  # assign the reviewer to review the assignment_team's submission. Only used in the assignments that do not have any topic
  # Parameter assignment_team is the candidate assignment team, it cannot be a team w/o submission, or have reviewed by reviewer, or reviewer's own team.
  # (guaranteed by candidate_assignment_teams_to_review method)
  def assign_reviewer_dynamically_no_topic(reviewer, assignment_team)
    if assignment_team.nil?
      raise "There are no more submissions available for that review right now. Try again later."
    end

    assignment_team.assign_reviewer(reviewer)
  end

  def has_teams?
    @has_teams ||= !self.teams.empty?
  end

  def assign_quiz_dynamically(reviewer, topic)
    contributor = contributor_for_quiz(reviewer, topic)
    reviewer.assign_quiz(contributor, reviewer, topic) unless contributor.nil?
  end

  def assign_reviewer_dynamically(reviewer, topic)
    # The following method raises an exception if not successful which
    # has to be captured by the caller (in review_mapping_controller)
    contributor = contributor_to_review(reviewer, topic)
    contributor.assign_reviewer(reviewer)
  end

  # Returns a contributor whose quiz is to be taken if available, otherwise will raise an error
  def contributor_for_quiz(reviewer, topic)
    raise "Please select a topic." if has_topics? and topic.nil?
    raise "This assignment does not have topics." if !has_topics? and topic

    # This condition might happen if the reviewer/quiz taker waited too much time in the
    # select topic page and other students have already selected this topic.
    # Another scenario is someone that deliberately modifies the view.
    if topic
      raise "To many quizes have been taken for this topic; please select another one." unless candidate_topics_for_quiz.include?(topic)
    end

    contributor_set = Array.new(contributors)
    work = topic.nil? ? 'assignment' : 'topic'

    # 1) Only consider contributors that worked on this topic; 2) remove reviewer/quiz taker as contributor
    # 3) remove contributors that have not submitted work yet
    contributor_set.reject! do |contributor|
      signed_up_topic(contributor) != topic or # both will be nil for assignments with no signup sheet
        contributor.includes?(reviewer) # ##or !contributor.has_quiz?
    end
    raise "There are no more submissions to take quiz on for this #{work}." if contributor_set.empty?
    # Reviewer/quiz taker can take quiz for each submission only once
    contributor_set.reject! {|contributor| quiz_taken_by?(contributor, reviewer) }
    # raise "You have already taken the quiz for all submissions for this #{work}." if contributor_set.empty?

    # Choose a contributor at random (.sample) from the remaining contributors.
    # Actually, we SHOULD pick the contributor who was least recently picked.  But sample
    # is much simpler, and probably almost as good, given that even if the contributors are
    # picked in round-robin fashion, the reviews will not be submitted in the same order that
    # they were picked.
    contributor_set.sample
  end

  def quiz_taken_by?(contributor, reviewer)
    quiz_id = QuizQuestionnaire.find_by_instructor_id(contributor.id).id
    QuizResponseMap.where(['reviewee_id = ? AND reviewer_id = ? AND reviewed_object_id = ?',
                           contributor.id, reviewer.id, quiz_id]).count > 0
  end

  # Returns a contributor to review if available, otherwise will raise an error
  def contributor_to_review(reviewer, topic)
    raise 'Please select a topic' if has_topics? && topic.nil?
    raise 'This assignment does not have topics' if !has_topics? && topic
    # This condition might happen if the reviewer waited too much time in the
    # select topic page and other students have already selected this topic.
    # Another scenario is someone that deliberately modifies the view.
    raise 'This topic has too many reviews; please select another one.' if topic && !candidate_topics_to_review(reviewer).include?(topic)

    contributor_set = Array.new(contributors)
    work = topic.nil? ? 'assignment' : 'topic'

    # 1) Only consider contributors that worked on this topic; 2) remove reviewer as contributor
    # 3) remove contributors that have not submitted work yet
    contributor_set.reject! do |contributor|
      signed_up_topic(contributor) != topic || # both will be nil for assignments with no signup sheet
        contributor.includes?(reviewer) ||
        !contributor.has_submissions?
    end

    raise "There are no more submissions to review on this #{work}." if contributor_set.empty?

    # Reviewer can review each contributor only once
    contributor_set.reject! {|contributor| contributor.reviewed_by?(reviewer) }
    raise "You have already reviewed all submissions for this #{work}." if contributor_set.empty?

    # Reduce to the contributors with the least number of reviews ("responses") received
    min_contributor = contributor_set.min_by {|a| a.responses.count }
    min_reviews = min_contributor.responses.count
    contributor_set.reject! {|contributor| contributor.responses.count > min_reviews }

    # Pick the contributor whose most recent reviewer was assigned longest ago
    contributor_set.sort! {|a, b| a.review_mappings.last.id <=> b.review_mappings.last.id } if min_reviews > 0

    # Choose a contributor at random (.sample) from the remaining contributors.
    # Actually, we SHOULD pick the contributor who was least recently picked.  But sample
    # is much simpler, and probably almost as good, given that even if the contributors are
    # picked in round-robin fashion, the reviews will not be submitted in the same order that
    # they were picked.
    contributor_set.sample
  end

  def contributors
    # ACS Contributors are just teams, so removed check to see if it is a team assignment
    @contributors ||= teams # ACS
  end

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
      (response_map.reviewee == metareviewer) or response_map.reviewer.includes?(metareviewer)
    end
    raise 'There are no more reviews to metareview for this assignment.' if response_map_set.empty?

    # Metareviewer can only metareview each review once
    response_map_set.reject! {|response_map| response_map.metareviewed_by?(metareviewer) }
    raise 'You have already metareviewed all reviews for this assignment.' if response_map_set.empty?

    # Reduce to the response maps with the least number of metareviews received
    response_map_set.sort! {|a, b| a.metareview_response_maps.count <=> b.metareview_response_maps.count }
    min_metareviews = response_map_set.first.metareview_response_maps.count
    response_map_set.reject! {|response_map| response_map.metareview_response_maps.count > min_metareviews }

    # Reduce the response maps to the reviewers with the least number of metareviews received
    reviewers = {} # <reviewer, number of metareviews>
    response_map_set.each do |response_map|
      reviewer = response_map.reviewer
      reviewers.member?(reviewer) ? reviewers[reviewer] += 1 : reviewers[reviewer] = 1
    end
    reviewers = reviewers.sort {|a, b| a[1] <=> b[1] }
    min_metareviews = reviewers.first[1]
    reviewers.reject! {|reviewer| reviewer[1] == min_metareviews }
    response_map_set.reject! {|response_map| reviewers.member?(response_map.reviewer) }

    # Pick the response map whose most recent meta_reviewer was assigned longest ago
    response_map_set.sort! {|a, b| a.metareview_response_maps.count <=> b.metareview_response_maps.count }
    min_metareviews = response_map_set.first.metareview_response_maps.count
    response_map_set.sort! {|a, b| a.metareview_response_maps.last.id <=> b.metareview_response_maps.last.id } if min_metareviews > 0
    # The first review_map is the best candidate to metareview
    response_map_set.first
  end

  def dynamic_reviewer_assignment?
    self.review_assignment_strategy == RS_AUTO_SELECTED
  end
  alias is_using_dynamic_reviewer_assignment? dynamic_reviewer_assignment?

  def metareview_mappings
    mappings = []
    self.review_mappings.each do |map|
      m_map = MetareviewResponseMap.find_by_reviewed_object_id(map.id)
      mappings << m_map unless m_map.nil?
    end
    mappings
  end

  def scores(questions)
    scores = {}

    scores[:participants] = {}
    self.participants.each do |participant|
      scores[:participants][participant.id.to_s.to_sym] = participant.scores(questions)
    end

    scores[:teams] = {}
    index = 0
    self.teams.each do |team|
      scores[:teams][index.to_s.to_sym] = {}
      scores[:teams][index.to_s.to_sym][:team] = team

      if self.varying_rubrics_by_round?
        grades_by_rounds = {}

        total_score = 0
        total_num_of_assessments = 0 # calculate grades for each rounds
        for i in 1..self.get_review_rounds
          assessments = ReviewResponseMap.get_assessments_round_for(team, i)
          round_sym = ("review" + i.to_s).to_sym
          grades_by_rounds[round_sym] = Answer.compute_scores(assessments, questions[round_sym])
          total_num_of_assessments += assessments.size
          unless grades_by_rounds[round_sym][:avg].nil?
            total_score += grades_by_rounds[round_sym][:avg] * assessments.size.to_f
          end
        end

        # merge the grades from multiple rounds
        scores[:teams][index.to_s.to_sym][:scores] = {}
        scores[:teams][index.to_s.to_sym][:scores][:max] = -999_999_999
        scores[:teams][index.to_s.to_sym][:scores][:min] = 999_999_999
        scores[:teams][index.to_s.to_sym][:scores][:avg] = 0
        for i in 1..self.get_review_rounds
          round_sym = ("review" + i.to_s).to_sym
          if !grades_by_rounds[round_sym][:max].nil? && scores[:teams][index.to_s.to_sym][:scores][:max] < grades_by_rounds[round_sym][:max]
            scores[:teams][index.to_s.to_sym][:scores][:max] = grades_by_rounds[round_sym][:max]
          end
          if !grades_by_rounds[round_sym][:min].nil? && scores[:teams][index.to_s.to_sym][:scores][:min] > grades_by_rounds[round_sym][:min]
            scores[:teams][index.to_s.to_sym][:scores][:min] = grades_by_rounds[round_sym][:min]
          end
        end

        if total_num_of_assessments != 0
          scores[:teams][index.to_s.to_sym][:scores][:avg] = total_score / total_num_of_assessments
        else
          scores[:teams][index.to_s.to_sym][:scores][:avg] = nil
          scores[:teams][index.to_s.to_sym][:scores][:max] = 0
          scores[:teams][index.to_s.to_sym][:scores][:min] = 0
        end

      else
        assessments = ReviewResponseMap.get_assessments_for(team)
        scores[:teams][index.to_s.to_sym][:scores] = Answer.compute_scores(assessments, questions[:review])
      end

      index += 1
    end
    scores
  end

  def get_contributor(contrib_id)
    AssignmentTeam.find(contrib_id)
  end

  # parameterized by questionnaire
  def get_max_score_possible(questionnaire)
    max = 0
    sum_of_weights = 0
    num_questions = 0
    questionnaire.questions.each do |question| # type identifies the type of questionnaire
      sum_of_weights += question.weight
      num_questions += 1
    end
    max = num_questions * questionnaire.max_question_score * sum_of_weights
    [max, sum_of_weights]
  end

  def path
    raise 'The path cannot be created. The assignment must be associated with either a course or an instructor.' if self.course_id.nil? && self.instructor_id.nil?
    path_text = ""
    (!self.course_id.nil? && self.course_id > 0) ?
      path_text = Rails.root.to_s + '/pg_data/' + FileHelper.clean_path(User.find(self.instructor_id).name) + '/' + FileHelper.clean_path(Course.find(self.course_id).directory_path) + '/' :
      path_text = Rails.root.to_s + '/pg_data/' + FileHelper.clean_path(User.find(self.instructor_id).name) + '/'
    path_text += FileHelper.clean_path(self.directory_path)
    path_text
  end

  # Check whether review, metareview, etc.. is allowed
  # If topic_id is set, check for that topic only. Otherwise, check to see if there is any topic which can be reviewed(etc) now
  def check_condition(column, topic_id = nil)
    # the drop topic deadline should not play any role in picking the next due date
    # get the drop_topic_deadline_id to exclude it
    drop_topic_deadline_id = DeadlineType.find_by_name('drop_topic').id
    if self.staggered_deadline?
      if topic_id
        next_due_dates = TopicDeadline.where(['topic_id = ? && due_at >= ? && deadline_type_id <> ?', topic_id, Time.now, drop_topic_deadline_id]).order('due_at')
      else
        next_due_dates = TopicDeadline.where(['assignment_id = ? && due_at >= ? && deadline_type_id <> ?', self.id, Time.now, drop_topic_deadline_id]).joins({topic: :assignment}, order: 'due_at')
        end
    else
      next_due_dates = DueDate.where(['assignment_id = ? && due_at >= ? && deadline_type_id <> ?', self.id, Time.now, drop_topic_deadline_id]).order('due_at')
      next_due_date = next_due_dates.first
    end
    return false if next_due_date.nil?

    # command pattern - get the attribute with the name in column
    # Here, column is usually something like 'review_allowed_id'

    right_id = next_due_date.send column

    right = DeadlineRight.find(right_id)
    (right && (right.name == 'OK' || right.name == 'Late'))
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

  def delete(force = nil)
    begin
      maps = ReviewResponseMap.where(reviewed_object_id: self.id)
      maps.each {|map| map.delete(force) }
    rescue
      raise "There is at least one review response that exists for #{self.name}."
    end

    begin
      maps = TeammateReviewResponseMap.where(reviewed_object_id: self.id)
      maps.each {|map| map.delete(force) }
    rescue
      raise "There is at least one teammate review response that exists for #{self.name}."
    end

    self.invitations.each(&:destroy)
    self.teams.each(&:delete)
    self.participants.each(&:delete)
    self.due_dates.each(&:destroy)

    # The size of an empty directory is 2
    # Delete the directory if it is empty
    begin
      directory = Dir.entries(Rails.root + '/pg_data/' + self.directory_path)
    rescue
      # directory is empty
    end

    if !(self.directory_path.nil? or self.directory_path.empty?) and !directory.nil?
      if directory.size == 2
        Dir.delete(Rails.root + '/pg_data/' + self.directory_path)
      else
        raise 'The assignment directory is not empty.'
      end
    end
    self.assignment_questionnaires.each(&:destroy)
    self.destroy
  end

  # Check to see if assignment is a microtask
  def is_microtask?
    self.microtask.nil? ? false : self.microtask
  end

  # add a new participant to this assignment
  # manual addition
  # user_name - the user account name of the participant to add
  def add_participant(user_name, can_submit, can_review, can_take_quiz)
    user = User.find_by_name(user_name)
    raise "The user account with the name #{user_name} does not exist. Please <a href='" + url_for(controller: 'users', action: 'new') + "'>create</a> the user first." if user.nil?
    participant = AssignmentParticipant.where(parent_id: self.id, user_id:  user.id).first
    if participant
      raise "The user #{user.name} is already a participant."
    else
      new_part = AssignmentParticipant.create(parent_id: self.id, user_id: user.id, permission_granted: user.master_permission_granted, can_submit: can_submit, can_review: can_review, can_take_quiz: can_take_quiz)
      new_part.set_handle
    end
  end

  def create_node
    parent = CourseNode.find_by_node_object_id(self.course_id)
    node = AssignmentNode.create(node_object_id: self.id)
    node.parent_id = parent.id unless parent.nil?
    node.save
  end

  #if current  stage is submission or review, find the round number
  #otherwise, return 0
  def number_of_current_round(topic_id)
    due_dates = if self.staggered_deadline?
                  TopicDeadline.where(topic_id: topic_id).order('due_at DESC')
                else
                  DueDate.where(assignment_id: self.id).order('due_at DESC')
                end
    due_dates = due_dates.reject {|a| a.deadline_type_id != 1 && a.deadline_type_id != 2 }
    if !due_dates.nil? and !due_dates.empty?
      if Time.now > due_dates[0].due_at
        return 0
      else
        i = 0
        for due_date in due_dates
          if Time.now < due_date.due_at and
              (due_dates[i + 1].nil? or Time.now > due_dates[i + 1].due_at)
            return due_date.round
          end
          i += 1
        end
      end
    end
  end

  # For varying rubric feature
  def current_stage_name(topic_id = nil)
    if self.staggered_deadline?
      if topic_id.nil?
        return 'Unknown'
      else
        return get_current_stage(topic_id)
       end
    end
    due_date = find_current_stage(topic_id)

    unless self.staggered_deadline?
      if due_date != COMPLETE && due_date != 'Finished' && !due_date.nil? && !due_date.deadline_name.nil?
        return due_date.deadline_name
      else
        return get_current_stage(topic_id)
      end
    end
  end

  # check if this assignment has multiple review phases with different review rubrics
  def varying_rubrics_by_round?
    assignment_questionnaires = AssignmentQuestionnaire.where(assignment_id: self.id, used_in_round: 2)

    if assignment_questionnaires.size >= 1
      true
    else
      false
    end
  end

  def link_for_current_stage(topic_id = nil)
    if self.staggered_deadline?
      return nil if topic_id.nil?
    end
    due_date = find_current_stage(topic_id)
    if due_date.nil? or due_date == COMPLETE or due_date.is_a?(TopicDeadline)
      return nil
    else
      return due_date.description_url
    end
  end

  def stage_deadline(topic_id = nil)
    return 'Unknown' if topic_id.nil? and self.staggered_deadline?
    due_date = find_current_stage(topic_id)
    (due_date.nil? || due_date == 'Finished') ? due_date : due_date.due_at.to_s
  end

  def get_review_rounds
    due_dates = DueDate.where(assignment_id: self.id)
    rounds = 0
    due_dates.each do |due_date|
      rounds = due_date.round if due_date.round > rounds
    end
    rounds
  end

  def find_current_stage(topic_id = nil)
    due_dates = self.staggered_deadline? ? TopicDeadline.where(topic_id: topic_id).order(due_at: :desc) : DueDate.where(assignment_id: self.id).order(due_at: :desc)
    if !due_dates.nil? && !due_dates.empty?
      if Time.now > due_dates[0].due_at
        return 'Finished'
      else
        i = 0
        due_dates.each do |due_date|
          return due_date if Time.now < due_date.due_at && (due_dates[i + 1].nil? || Time.now > due_dates[i + 1].due_at)
          i += 1
        end
      end
    end
  end

  def get_current_stage(topic_id=nil)
    return 'Unknown' if topic_id.nil? and self.staggered_deadline?
    due_date = find_current_stage(topic_id)
    (due_date == nil || due_date == COMPLETE) ? COMPLETE : DeadlineType.find(due_date.deadline_type_id).name
  end

  # Returns hash review_scores[reviewer_id][reviewee_id] = score
  def compute_reviews_hash
    @review_scores = {}
    @response_type = 'ReviewResponseMap'
    # @myreviewers = ResponseMap.select('DISTINCT reviewer_id').where(['reviewed_object_id = ? && type = ? ', self.id, @response_type])

    # if this assignment use vary rubric by rounds feature, loade @questions for each round
    if self.varying_rubrics_by_round? # [reviewer_id][round][reviewee_id] = score
      rounds = self.rounds_of_reviews
      for round in 1..rounds
        @response_maps = ResponseMap.where(['reviewed_object_id = ? && type = ?', self.id, @response_type])
        review_questionnaire_id = review_questionnaire_id(round)

        @questions = Question.where(['questionnaire_id = ?', review_questionnaire_id])

        @response_maps.each do |response_map|
          # Check if response is there
          @corresponding_response = Response.where(['map_id = ?', response_map.id])
          unless @corresponding_response.empty?
            @corresponding_response = @corresponding_response.reject {|response| response.round != round }
          end
          @respective_scores = {}
          @respective_scores = @review_scores[response_map.reviewer_id][round] if !@review_scores[response_map.reviewer_id].nil? && !@review_scores[response_map.reviewer_id][round].nil?

          if !@corresponding_response.empty?
            # @corresponding_response is an array, Answer.get_total_score calculate the score for the last one
            @this_review_score_raw = Answer.get_total_score(response: @corresponding_response, questions: @questions)
            if @this_review_score_raw
              @this_review_score = ((@this_review_score_raw * 100) / 100.0).round if @this_review_score_raw >= 0.0
            end
          else
            @this_review_score = -1.0
          end

          @respective_scores[response_map.reviewee_id] = @this_review_score
          @review_scores[response_map.reviewer_id] = {} if @review_scores[response_map.reviewer_id].nil?
          @review_scores[response_map.reviewer_id][round] = {} if @review_scores[response_map.reviewer_id][round].nil?
          @review_scores[response_map.reviewer_id][round] = @respective_scores
        end
      end
    else # [reviewer_id][reviewee_id] = score
      @response_maps = ResponseMap.where(['reviewed_object_id = ? && type = ?', self.id, @response_type])
      review_questionnaire_id = review_questionnaire_id()

      @questions = Question.where(['questionnaire_id = ?', review_questionnaire_id])

      @response_maps.each do |response_map|
        # Check if response is there
        @corresponding_response = Response.where(['map_id = ?', response_map.id])
        @respective_scores = {}
        @respective_scores = @review_scores[response_map.reviewer_id] unless @review_scores[response_map.reviewer_id].nil?

        if !@corresponding_response.empty?
          # @corresponding_response is an array, Answer.get_total_score calculate the score for the last one
          @this_review_score_raw = Answer.get_total_score(response: @corresponding_response, questions: @questions)
          if @this_review_score_raw
            @this_review_score = ((@this_review_score_raw * 100) / 100.0).round if @this_review_score_raw >= 0.0
          end
        else
          @this_review_score = -1.0
        end
        @respective_scores[response_map.reviewee_id] = @this_review_score
        @review_scores[response_map.reviewer_id] = @respective_scores
      end

    end
    @review_scores
  end

  # calculate the avg score and score range for each reviewee(team), only for peer-review
  def compute_avg_and_ranges_hash
    scores = {}
    contributors = self.contributors # assignment_teams
    if self.varying_rubrics_by_round?
      rounds = self.rounds_of_reviews
      for round in 1..rounds
        review_questionnaire_id = review_questionnaire_id(round)
        questions = Question.where(['questionnaire_id = ?', review_questionnaire_id])
        contributors.each do |contributor|
          assessments = ReviewResponseMap.get_assessments_for(contributor)
          assessments = assessments.reject {|assessment| assessment.round != round }
          scores[contributor.id] = {}
          scores[contributor.id][round] = {}
          scores[contributor.id][round] = Answer.compute_scores(assessments, questions)
        end
      end
    else
      review_questionnaire_id = review_questionnaire_id()
      questions = Question.where(['questionnaire_id = ?', review_questionnaire_id])
      contributors.each do |contributor|
        assessments = ReviewResponseMap.get_assessments_for(contributor)
        scores[contributor.id] = {}
        scores[contributor.id] = Answer.compute_scores(assessments, questions)
      end
    end
    scores
  end

  def review_questionnaire_id(round = nil)
    revqids = AssignmentQuestionnaire.where(assignment_id: self.id).where(used_in_round: round)
    review_questionnaire_id = nil
    revqids.each do |rqid|
      next if rqid.questionnaire_id.nil?
      rtype = Questionnaire.find(rqid.questionnaire_id).type
      if rtype == 'ReviewQuestionnaire'
        review_questionnaire_id = rqid.questionnaire_id
        break
      end
    end
    review_questionnaire_id
  end

  # Compute total score for this assignment by summing the scores given on all questionnaires.
  # Only scores passed in are included in this sum.
  def compute_total_score(scores)
    total = 0
    self.questionnaires.each {|questionnaire| total += questionnaire.get_weighted_score(self, scores) }
    total
  end

  def signed_up_topic(contributor)
    # The purpose is to return the topic that the contributor has signed up to do for this assignment.
    # Returns a record from the sign_up_topic table that gives the topic_id for which the contributor has signed up
    # Look for the topic_id where the team_id equals the contributor id (contributor is a team or a participant)

    # If this is an assignment with quiz required
    if self.require_quiz?
      signups = SignedUpTeam.where(team_id: contributor.id)
      for signup in signups do
        signuptopic = SignUpTopic.find(signup.topic_id)
        if signuptopic.assignment_id == self.id
          contributors_signup_topic = signuptopic
          return contributors_signup_topic
        end
      end
    end

    # Look for the topic_id where the team_id equals the contributor id (contributor is a team)
    unless SignedUpTeam.where(team_id: contributor.id, is_waitlisted: 0).empty?
      topic_id = SignedUpTeam.where(team_id: contributor.id, is_waitlisted: 0).first.topic_id
      SignUpTopic.find(topic_id)
    end
  end

  # This method is used for export contents of grade#view.  -Zhewei
  def self.export(csv, parent_id, options)
    @assignment = Assignment.find(parent_id)
    @questions = {}
    questionnaires = @assignment.questionnaires

    questionnaires.each do |questionnaire|
      if @assignment.varying_rubrics_by_round?
        round = AssignmentQuestionnaire.find_by_assignment_id_and_questionnaire_id(@assignment.id, questionnaire.id).used_in_round
        questionnaire_symbol = if round.nil?
                                 questionnaire.symbol
                               else
                                 (questionnaire.symbol.to_s + round.to_s).to_sym
                               end
      else
        questionnaire_symbol = questionnaire.symbol
      end
      @questions[questionnaire_symbol] = questionnaire.questions
    end
    @scores = @assignment.scores(@questions)

    return csv if @scores[:teams].nil?

    for index in 0..@scores[:teams].length - 1
      team = @scores[:teams][index.to_s.to_sym]
      first_participant = team[:team].participants[0] unless team[:team].participants[0].nil?
      pscore = @scores[:participants][first_participant.id.to_s.to_sym]
      tcsv = []
      tcsv << team[:team].name
      names_of_participants = ''
      team[:team].participants.each do |p|
        names_of_participants += p.fullname
        names_of_participants += '; ' unless p == team[:team].participants.last
      end
      tcsv << names_of_participants

      team[:scores] ?
        tcsv.push(team[:scores][:max], team[:scores][:min], team[:scores][:avg]) :
        tcsv.push('---', '---', '---') if options['team_score'] == 'true'

      pscore[:review] ?
        tcsv.push(pscore[:review][:scores][:max], pscore[:review][:scores][:min], pscore[:review][:scores][:avg]) :
        tcsv.push('---', '---', '---') if options['submitted_score']

      pscore[:metareview] ?
        tcsv.push(pscore[:metareview][:scores][:max], pscore[:metareview][:scores][:min], pscore[:metareview][:scores][:avg]) :
        tcsv.push('---', '---', '---') if options['metareview_score']

      pscore[:feedback] ?
        tcsv.push(pscore[:feedback][:scores][:max], pscore[:feedback][:scores][:min], pscore[:feedback][:scores][:avg]) :
        tcsv.push('---', '---', '---') if options['author_feedback_score']

      pscore[:teammate] ?
        tcsv.push(pscore[:teammate][:scores][:max], pscore[:teammate][:scores][:min], pscore[:teammate][:scores][:avg]) :
        tcsv.push('---', '---', '---') if options['teammate_review_score']

      tcsv.push(pscore[:total_score])
      csv << tcsv
    end
  end

  # This method is used for export contents of grade#view.  -Zhewei
  def self.export_fields(options)
    fields = []
    fields << 'Team Name'
    fields << 'Team Member(s)'
    fields.push('Team Max', 'Team Min', 'Team Avg') if options['team_score'] == 'true'
    fields.push('Submitted Max', 'Submitted Min', 'Submitted Avg') if options['submitted_score']
    fields.push('Metareview Max', 'Metareview Min', 'Metareview Avg') if options['metareview_score']
    fields.push('Author Feedback Max', 'Author Feedback Min', 'Author Feedback Avg') if options['author_feedback_score']
    fields.push('Teammate Review Max', 'Teammate Review Min', 'Teammate Review Avg') if options['teammate_review_score']
    fields.push('Final Score')
    fields
  end

  def find_due_dates(type)
    self.due_dates.select {|due_date| due_date.deadline_type == DeadlineType.find_by_name(type) }
  end

  # this should be moved to SignUpSheet model after we refactor the SignUpSheet.
  # returns whether ANY topic has a partner ad; used for deciding whether to show the Advertisements column
  def has_partner_ads?(id)
    # Team.find_by_sql("select * from teams where parent_id = "+id+" AND advertise_for_partner='1'").size > 0
    @team = Team.find_by_sql("select t.* "\
        "from teams t, signed_up_teams s "\
        "where s.topic_id='" + id.to_s + "' and s.team_id = t.id and t.advertise_for_partner = 1")
    @team.reject!(&:full?)
    !@team.empty?
  end

end
