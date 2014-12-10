class Assignment < ActiveRecord::Base
  require 'analytic/assignment_analytic'
  include AssignmentAnalytic
  include DynamicReviewMapping
  has_paper_trail
  belongs_to :course
  belongs_to :wiki_type
  # wiki_type needs to be removed. When an assignment is created, it needs to
  # be created as an instance of a subclass of the Assignment (model) class;
  # then Rails will "automatically' set the type field to the value that
  # designates an assignment of the appropriate type.
  has_many :participants, :class_name => 'AssignmentParticipant', :foreign_key => 'parent_id'
  has_many :participant_review_mappings, :class_name => 'ParticipantReviewResponseMap', :through => :participants, :source => :review_mappings
  has_many :users, :through => :participants
  has_many :due_dates, :dependent => :destroy
  has_many :teams, :class_name => 'AssignmentTeam', :foreign_key => 'parent_id'
  has_many :team_review_mappings, :class_name => 'TeamReviewResponseMap', :through => :teams, :source => :review_mappings
  has_many :invitations, :class_name => 'Invitation', :foreign_key => 'assignment_id', :dependent => :destroy
  has_many :assignment_questionnaires,:dependent => :destroy
  has_many :questionnaires, :through => :assignment_questionnaires
  belongs_to :instructor, :class_name => 'User', :foreign_key => 'instructor_id'
  has_many :sign_up_topics, :foreign_key => 'assignment_id', :dependent => :destroy
  has_many :response_maps, :foreign_key => 'reviewed_object_id', :class_name => 'ResponseMap'
  has_one :assignment_node,:foreign_key => :node_object_id,:dependent => :destroy

  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :course_id

  COMPLETE = 'Finished'
  WAITLIST = 'Waitlist open'

  REVIEW_QUESTIONNAIRES = {:author_feedback => 0, :metareview => 1, :review => 2, :teammate_review => 3}
  #  Review Strategy information.
  RS_INSTRUCTOR_SELECTED = 'Instructor-Selected'
  RS_STUDENT_SELECTED = 'Student-Selected'
  RS_AUTO_SELECTED = 'Auto-Selected'
  REVIEW_STRATEGIES = [RS_INSTRUCTOR_SELECTED, RS_STUDENT_SELECTED, RS_AUTO_SELECTED]

  DEFAULT_MAX_REVIEWERS = 3

  def questionnaires_with_questions
    questionnaires.includes(:questions).joins(:questions)
  end

  def team_assignment?
    max_team_size > 1
  end

  def team_assignment
    team_assignment?
  end

  # Returns a set of topics that can be used for taking the quiz.
  # We choose the topics if one of its quiz submissions has been attempted the fewest times so far
  def candidate_topics_for_quiz
    return nil if sign_up_topics.empty?   # This is not a topic assignment
    contributor_set = Array.new(contributors)
    # Reject contributors that have not selected a topic, or have no submissions
    contributor_set.reject! { |contributor| signed_up_topic(contributor).nil? }
    #####contributor_set.reject! { |contributor| !contributor.has_quiz? }
    # Reject contributions of topics whose deadline has passed
    contributor_set.reject! { |contributor| contributor.assignment.get_current_stage(signed_up_topic(contributor).id) == "Complete" or
                              contributor.assignment.get_current_stage(signed_up_topic(contributor).id) == "submission" }

    # Filter the contributors with the least number of reviews
    # (using the fact that each contributor is associated with a topic)
    ###contributor = contributor_set.min_by { |contributor| contributor.quiz_mappings.count }

    ### min_quizzes = contributor.quiz_mappings.count rescue 0
    ###contributor_set.reject! { |contributor| contributor.quiz_mappings.count > min_quizzes + review_topic_threshold }


    candidate_topics = Set.new
    contributor_set.each { |contributor| candidate_topics.add(signed_up_topic(contributor)) }
    candidate_topics
  end


  # Returns a set of topics that can be reviewed.
  # We choose the topics if one of its submissions has received the fewest reviews so far
  def candidate_topics_to_review(reviewer)
    return nil if sign_up_topics.empty? # This is not a topic assignment

    # Initialize contributor set with all teams participating in this assignment
    contributor_set = Array.new(contributors)

 
    # Reject contributors that have not selected a topic, or have no submissions
    contributor_set=reject_by_no_topic_selection_or_no_submission(contributor_set)

    # Reject contributions of topics whose deadline has passed, or which are not reviewable in the current stage
    contributor_set=reject_by_deadline(contributor_set)


    # Filter submission by reviewer him/her self
    contributor_set=reject_own_submission(contributor_set, reviewer)

    # Filter submissions already reviewed by reviewer
    contributor_set=reject_previously_reviewed_submissions(contributor_set, reviewer)

    # Filter the contributors with the least number of reviews
    # (using the fact that each contributor is associated with a topic)
    contributor_set=reject_by_least_reviewed(contributor_set)

    # Add topics for all remaining submissions to a list of available topics for review
    candidate_topics = Set.new
    contributor_set.each { |contributor|
      candidate_topics.add(signed_up_topic(contributor))
    }
    candidate_topics
  end

  def reject_by_least_reviewed(contributor_set)
    contributor = contributor_set.min_by { |contributor| contributor.review_mappings.count }
    min_reviews = contributor.review_mappings.count rescue 0
    contributor_set.reject! { |contributor| contributor.review_mappings.count > min_reviews + review_topic_threshold }
    return contributor_set
  end

  def reject_previously_reviewed_submissions(contributor_set, reviewer)
    contributor_set = contributor_set.reject { |contributor| contributor.reviewed_by?(reviewer) }
    return contributor_set
  end

  def reject_own_submission(contributor_set, reviewer)
    contributor_set.reject! { |contributor| contributor.teams_users.find_by_user_id(reviewer.user_id) }
    return contributor_set
  end

  def reject_by_deadline(contributor_set)
    contributor_set.reject! { |contributor| contributor.assignment.get_current_stage(signed_up_topic(contributor).id) == 'Complete' or
        !contributor.assignment.review_allowed(signed_up_topic(contributor).id) }
    return contributor_set
  end

  def reject_by_no_topic_selection_or_no_submission(contributor_set)
    contributor_set.reject! { |contributor| signed_up_topic(contributor).nil? or !contributor.has_submissions? }
    return contributor_set
  end

  def has_topics?
    @has_topics ||= !sign_up_topics.empty?
  end

  def has_teams?
    @has_teams ||= !self.teams.empty?
  end

  def assign_quiz_dynamically(reviewer, topic)
    contributor = contributor_for_quiz(reviewer, topic)
    unless contributor.nil?
      reviewer.assign_quiz(contributor,reviewer,topic)
    end
  end

  def assign_reviewer_dynamically(reviewer, topic)
    # The following method raises an exception if not successful which
    # has to be captured by the caller (in review_mapping_controller)
    contributor = contributor_to_review(reviewer, topic)
    contributor.assign_reviewer(reviewer)
  end

  # Returns a contributor whose quiz is to be taken if available, otherwise will raise an error
  def contributor_for_quiz(reviewer, topic)
    raise "Please select a topic" if has_topics? and topic.nil?
    raise "This assignment does not have topics" if !has_topics? and topic

    # This condition might happen if the reviewer/quiz taker waited too much time in the
    # select topic page and other students have already selected this topic.
    # Another scenario is someone that deliberately modifies the view.
    if topic
      raise "This topic has too many quizzes taken; please select another one." unless candidate_topics_for_quiz.include?(topic)
    end

    contributor_set = Array.new(contributors)
    work = (topic.nil?) ? 'assignment' : 'topic'

    # 1) Only consider contributors that worked on this topic; 2) remove reviewer/quiz taker as contributor
    # 3) remove contributors that have not submitted work yet
    contributor_set.reject! do |contributor|
      signed_up_topic(contributor) != topic or # both will be nil for assignments with no signup sheet
        contributor.includes?(reviewer) ###or !contributor.has_quiz?
    end
    raise "There are no more submissions to take quiz on for this #{work}." if contributor_set.empty?
    #flash[:error] = "There are no more submissions to take quiz on for this #{work}."
    #redirect_to :controller => 'student_review', :action => 'list', :id => reviewer.id
    #return
    #end
    # Reviewer/quiz taker can take quiz for each submission only once
    contributor_set.reject! { |contributor| quiz_taken_by?(contributor, reviewer) }
    #raise "You have already taken the quiz for all submissions for this #{work}." if contributor_set.empty?

    # Reduce to the contributors with the least number of quizzes taken for their submissions ("responses")
    # min_contributor = contributor_set.min_by { |a| a.quiz_responses.count }
    # min_quizzes = min_contributor.quiz_responses.count
    #contributor_set.reject! { |contributor| contributor.quiz_responses.count > min_quizzes }

    # Pick the contributor whose quiz was taken longest ago
    #if min_quizzes > 0
    # Sort by last quiz mapping id, since it reflects the order in which quizzes were taken
    # This has a round-robin effect
    # Sorting on id assumes that ids are assigned sequentially in the db.
    # .last assumes the database returns rows in the order they were created.
    # Added unit tests to ensure these conditions are both true with the current database.
    # contributor_set.sort! { |a, b| a.quiz_mappings.last.id <=> b.quiz_mappings.last.id }
    #end

    # Choose a contributor at random (.sample) from the remaining contributors.
    # Actually, we SHOULD pick the contributor who was least recently picked.  But sample
    # is much simpler, and probably almost as good, given that even if the contributors are
    # picked in round-robin fashion, the reviews will not be submitted in the same order that
    # they were picked.
    contributor_set.sample
  end

  def quiz_taken_by?(contributor, reviewer)
    quiz_id = QuizQuestionnaire.find_by_instructor_id(contributor.id).id
    return QuizResponseMap.where(['reviewee_id = ? AND reviewer_id = ? AND reviewed_object_id = ?',
                                  contributor.id, reviewer.id, quiz_id]).count > 0
  end

  # Returns a contributor to review if available, otherwise will raise an error
  def contributor_to_review(reviewer, topic)
    raise 'Please select a topic' if has_topics? && topic.nil?
    raise 'This assignment does not have topics' if !has_topics? && topic
    # This condition might happen if the reviewer waited too much time in the
    # select topic page and other students have already selected this topic.
    # Another scenario is someone that deliberately modifies the view.
    raise 'This topic has too many reviews; please select another one.' unless candidate_topics_to_review(reviewer).include?(topic) if topic

    contributor_set = Array.new(contributors)
    work = (topic.nil?) ? 'assignment' : 'topic'

    # 1) Only consider contributors that worked on this topic; 2) remove reviewer as contributor
    # 3) remove contributors that have not submitted work yet
    contributor_set.reject! do |contributor|
      signed_up_topic(contributor) != topic || # both will be nil for assignments with no signup sheet
        contributor.includes?(reviewer) ||
        !contributor.has_submissions?
    end
    raise "There are no more submissions to review on this #{work}." if contributor_set.empty?

    # Reviewer can review each contributor only once
    contributor_set.reject! { |contributor| contributor.reviewed_by?(reviewer) }
    raise "You have already reviewed all submissions for this #{work}." if contributor_set.empty?

    # Reduce to the contributors with the least number of reviews ("responses") received
    min_contributor = contributor_set.min_by { |a| a.responses.count }
    min_reviews = min_contributor.responses.count
    contributor_set.reject! { |contributor| contributor.responses.count > min_reviews }

    # Pick the contributor whose most recent reviewer was assigned longest ago
    contributor_set.sort! { |a, b| a.review_mappings.last.id <=> b.review_mappings.last.id } if min_reviews > 0

    # Choose a contributor at random (.sample) from the remaining contributors.
    # Actually, we SHOULD pick the contributor who was least recently picked.  But sample
    # is much simpler, and probably almost as good, given that even if the contributors are
    # picked in round-robin fashion, the reviews will not be submitted in the same order that
    # they were picked.
    contributor_set.sample
  end

  def contributors
    #ACS Contributors are just teams, so removed check to see if it is a team assignment
    @contributors ||= teams #ACS
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
    response_map_set.reject! { |response_map| !response_map.response }
    raise 'There are no reviews to metareview at this time for this assignment.' if response_map_set.empty?

    # Reject reviews where the meta_reviewer was the reviewer or the contributor
    response_map_set.reject! do |response_map|
      (response_map.reviewee == metareviewer) or (response_map.reviewer.includes?(metareviewer))
    end
    raise 'There are no more reviews to metareview for this assignment.' if response_map_set.empty?

    # Metareviewer can only metareview each review once
    response_map_set.reject! { |response_map| response_map.metareviewed_by?(metareviewer) }
    raise 'You have already metareviewed all reviews for this assignment.' if response_map_set.empty?

    # Reduce to the response maps with the least number of metareviews received
    response_map_set.sort! { |a, b| a.metareview_response_maps.count <=> b.metareview_response_maps.count }
    min_metareviews = response_map_set.first.metareview_response_maps.count
    response_map_set.reject! { |response_map| response_map.metareview_response_maps.count > min_metareviews }

    # Reduce the response maps to the reviewers with the least number of metareviews received
    reviewers = Hash.new # <reviewer, number of metareviews>
    response_map_set.each do |response_map|
      reviewer = response_map.reviewer
      reviewers.member?(reviewer) ? reviewers[reviewer] += 1 : reviewers[reviewer] = 1
    end
    reviewers = reviewers.sort { |a, b| a[1] <=> b[1] }
    min_metareviews = reviewers.first[1]
    reviewers.reject! { |reviewer| reviewer[1] == min_metareviews }
    response_map_set.reject! { |response_map| reviewers.member?(response_map.reviewer) }

    # Pick the response map whose most recent meta_reviewer was assigned longest ago
    response_map_set.sort! { |a, b| a.metareview_response_maps.count <=> b.metareview_response_maps.count }
    min_metareviews = response_map_set.first.metareview_response_maps.count
    response_map_set.sort! { |a, b| a.metareview_response_maps.last.id <=> b.metareview_response_maps.last.id } if min_metareviews > 0
    # The first review_map is the best candidate to metareview
    response_map_set.first
  end

  def dynamic_reviewer_assignment?
    (self.review_assignment_strategy == RS_AUTO_SELECTED || self.review_assignment_strategy == RS_STUDENT_SELECTED) ? true : false
  end
  alias_method :is_using_dynamic_reviewer_assignment?, :dynamic_reviewer_assignment?

  def review_mappings
    #ACS Removed the if condition(and corressponding else) which differentiate assignments as team and individual assignments
    # to treat all assignments as team assignments
    TeamReviewResponseMap.where(reviewed_object_id: self.id)
    end

  def metareview_mappings
    mappings = Array.new
    self.review_mappings.each do |map|
      m_map = MetareviewResponseMap.find_by_reviewed_object_id(map.id)
      mappings << m_map if m_map != nil
    end
    mappings
  end

  def get_scores(questions)
    scores = Hash.new

    scores[:participants] = Hash.new
    self.participants.each do |participant|
      scores[:participants][participant.id.to_s.to_sym] = participant.get_scores(questions)

      # for all quiz questionnaires (quizzes) taken by the participant
      quiz_responses = Array.new
      quiz_response_mappings = QuizResponseMap.where(reviewer_id: participant.id)
      quiz_response_mappings.each do |qmapping|
        if (qmapping.response)
          quiz_responses << qmapping.response
        end
      end

      scores[:participants][participant.id.to_s.to_sym][:quiz] = Hash.new
      scores[:participants][participant.id.to_s.to_sym][:quiz][:assessments] = quiz_responses
      scores[:participants][participant.id.to_s.to_sym][:quiz][:scores] = Score.compute_quiz_scores(scores[:participants][participant.id.to_s.to_sym][:quiz][:assessments])

      scores[:participants][participant.id.to_s.to_sym][:total_score] = compute_total_score(scores[:participants][participant.id.to_s.to_sym])
      scores[:participants][participant.id.to_s.to_sym][:total_score] += participant.compute_quiz_scores(scores[:participants][participant.id.to_s.to_sym])



    end
    #ACS Removed the if condition(and corressponding else) which differentiate assignments as team and individual assignments
    # to treat all assignments as team assignments



    scores[:teams] = Hash.new
    index = 0
    self.teams.each do |team|
      scores[:teams][index.to_s.to_sym] = Hash.new
      scores[:teams][index.to_s.to_sym][:team] = team
      assessments = TeamReviewResponseMap.get_assessments_for(team)
      scores[:teams][index.to_s.to_sym][:scores] = Score.compute_scores(assessments, questions[:review])
      #... = ScoreCache.get_participant_score(team, id, questionnaire.display_type)
      index = index + 1
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
    questionnaire.questions.each do |question| #type identifies the type of questionnaire
      sum_of_weights += question.weight
      num_questions+=1
    end
    max = num_questions * questionnaire.max_question_score * sum_of_weights
    return max, sum_of_weights
  end

  def get_path
    raise 'Path cannot be created. The assignment must be associated with either a course or an instructor.' if self.course_id == nil && self.instructor_id == nil
    raise PathError, 'No path needed' if self.wiki_type_id != 1
    (self.course_id != nil && self.course_id > 0) ?
      path = Course.find(self.course_id).get_path :
      path = Rails.root + '/pg_data/' + FileHelper.clean_path(User.find(self.instructor_id).name) + '/'
    path + FileHelper.clean_path(self.directory_path)
  end

  # Check whether review, metareview, etc.. is allowed
  # If topic_id is set, check for that topic only. Otherwise, check to see if there is any topic which can be reviewed(etc) now
  def check_condition(column, topic_id=nil)
    # the drop topic deadline should not play any role in picking the next due date
    # get the drop_topic_deadline_id to exclude it
    drop_topic_deadline_id = DeadlineType.find_by_name('drop_topic').id
    self.staggered_deadline? ?
      topic_id ?
      next_due_dates = TopicDeadline
      .where( ['topic_id = ? && due_at >= ? && deadline_type_id <> ?', topic_id, Time.now, drop_topic_deadline_id])
      .order('due_at') :
    next_due_dates = TopicDeadline
      .where( ['assignment_id = ? && due_at >= ? && deadline_type_id <> ?', self.id, Time.now, drop_topic_deadline_id])
      .joins( {:topic => :assignment}, :order => 'due_at') :
    next_due_dates = DueDate
      .where( ['assignment_id = ? && due_at >= ? && deadline_type_id <> ?', self.id, Time.now, drop_topic_deadline_id])
      .order('due_at')
    next_due_date = next_due_dates.first

    return false if next_due_date.nil?

    # command pattern - get the attribute with the name in column
    # Here, column is usually something like 'review_allowed_id'

    right_id = next_due_date.send column

    right = DeadlineRight.find(right_id)
    (right && (right.name == 'OK' || right.name == 'Late'))
  end

  # Determine if the next due date from now allows for submissions
  def submission_allowed(topic_id=nil)
    (check_condition('submission_allowed_id', topic_id) )
  end

  # Determine if the next due date from now allows to take the quizzes
  def quiz_allowed(topic_id=nil)
    return check_condition("quiz_allowed_id",topic_id)
  end

  # Determine if the next due date from now allows for reviews
  def review_allowed(topic_id=nil)
    (check_condition('review_allowed_id', topic_id) )
  end

  # Determine if the next due date from now allows for metareviews
  def metareview_allowed(topic_id=nil)
    check_condition('review_of_review_allowed_id', topic_id)
  end

  def get_quiz_deadline
    return (DueDate.where( ['assignment_id = ? and deadline_type_id >= ?', self.id, 7]).due_at)
  end

  def delete(force = nil)
    begin
      maps = ParticipantReviewResponseMap.where(reviewed_object_id: self.id)
      maps.each { |map| map.delete(force) }
    rescue
      raise "At least one review response exists for #{self.name}."
    end

    begin
      maps = TeamReviewResponseMap.where(reviewed_object_id: self.id)
      maps.each { |map| map.delete(force) }
    rescue
      raise "At least one review response exists for #{self.name}."
    end

    begin
      maps = TeammateReviewResponseMap.where(reviewed_object_id: self.id)
      maps.each { |map| map.delete(force) }
    rescue
      raise "At least one teammate review response exists for #{self.name}."
    end

    self.invitations.each { |invite| invite.destroy }
    self.teams.each { |team| team.delete }
    self.participants.each { |participant| participant.delete }
    self.due_dates.each { |date| date.destroy }

    # The size of an empty directory is 2
    # Delete the directory if it is empty
    begin
      directory = Dir.entries(Rails.root + '/pg_data/' + self.directory_path)
    rescue
      # directory is empty
    end

    if !is_wiki_assignment and !self.directory_path.empty? and !directory.nil?
      if directory.size == 2
        Dir.delete(Rails.root + '/pg_data/' + self.directory_path)
      else
        raise 'Assignment directory is not empty'
      end
    end
    self.assignment_questionnaires.each { |aq| aq.destroy }
    self.destroy
  end

  # Generate emails for reviewers when new content is available for review
  #ajbudlon, sept 07, 2007
  def email(author_id)

    # Get all review mappings for this assignment & author
    participant = AssignmentParticipant.find(author_id)
    #ACS Removed the if condition(and corresponding else) which differentiate assignments as team and individual assignments
    # to treat all assignments as team assignments
    author = participant.team

    author.review_mappings.each do |mapping|
      # If the reviewer has requested an e-mail deliver a notification
      # that includes the assignment, and which item has been updated.
      if mapping.reviewer.user.email_on_submission
        user = mapping.reviewer.user
        Mailer.sync_message(
          {:to => user.email,
           :subject => "A new submission is available for #{self.name}",
           :body => {
             :obj_name => self.name,
             :type => 'submission',
             :location => get_review_number(mapping).to_s,
             :first_name => ApplicationHelper::get_user_first_name(user),
             :partial_name => 'update'
           }
        }
        ).deliver
      end
    end
    end

  # Get all review mappings for this assignment & reviewer
  # required to give reviewer location of new submission content
  # link cannot be provided as it might give user ability to access data not
  # available to them.
  #ajbudlon, sept 07, 2007
  def get_review_number(mapping)
    reviewer_mappings = ResponseMap.where(reviewer_id: mapping.reviewer.id)
    review_num = 1
    reviewer_mappings.each do |rm|
      (rm.reviewee.id != mapping.reviewee.id) ? review_num += 1 : break
    end
    review_num
  end

  # It appears that this method is not used at present!
  def is_wiki_assignment
    self.wiki_type_id > 1
  end

  # Check to see if assignment is a microtask
  def is_microtask?
    (self.microtask.nil?) ? false : self.microtask
  end

  # Check to see if assignment is a microtask
  def is_coding_assignment?
    (self.is_coding_assignment?) ? false : self.is_coding_assignment
  end

  def self.is_submission_possible (assignment)
    # Is it possible to upload a file?
    # Check whether the directory text box is nil
    if assignment.directory_path != nil && assignment.wiki_type == 1
      return true
      # Is it possible to submit a URL (or a wiki page)
    elsif assignment.directory_path != nil && /(^$)|(^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$)/ix.match(assignment.directory_path)
      # In this case we have to check if the directory_path starts with http / https.
      return true
      # Is it possible to submit a Google Doc?
      #    removed because google doc not implemented
      #    elsif assignment.wiki_type == 4 #GOOGLE_DOC
      #      return true
      else
        return false
      end
  end

  def is_google_doc
    # This is its own method so that it can be refactored later.
    # Google Document code should never directly check the wiki_type_id
    # and should instead always call is_google_doc.
    self.wiki_type_id == 4
  end

  #add a new participant to this assignment
  #manual addition
  # user_name - the user account name of the participant to add
  def add_participant(user_name)
    user = User.find_by_name(user_name)
    raise "The user account with the name #{user_name} does not exist. Please <a href='" + url_for(:controller => 'users', :action => 'new') + "'>create</a> the user first." if user.nil?
    participant = AssignmentParticipant.where(parent_id: self.id, user_id:  user.id).first
    if participant
      raise "The user #{user.name} is already a participant."
    else
      new_part = AssignmentParticipant.create(:parent_id => self.id, :user_id => user.id, :permission_granted => user.master_permission_granted)
      new_part.set_handle()
    end
  end

  def create_node
    parent = CourseNode.find_by_node_object_id(self.course_id)
    node = AssignmentNode.create(:node_object_id => self.id)
    node.parent_id = parent.id if parent != nil
    node.save
  end

  def get_current_stage(topic_id=nil)
    return 'Unknown' if topic_id.nil? if self.staggered_deadline?
    due_date = find_current_stage(topic_id)
    (due_date == nil || due_date == COMPLETE) ? COMPLETE : DeadlineType.find(due_date.deadline_type_id).name
  end

  def get_stage_deadline(topic_id=nil)
    return 'Unknown' if topic_id.nil? if self.staggered_deadline?
    due_date = find_current_stage(topic_id)
    (due_date == nil || due_date == 'Finished') ? due_date : due_date.due_at.to_s
  end

  def get_review_rounds
    due_dates = DueDate.where(assignment_id: self.id)
    rounds = 0
    0 .. due_dates.length-1.each do |i|
      deadline_type = DeadlineType.find(due_dates[i].deadline_type_id)
      rounds = rounds + 1 if deadline_type.name == 'review'
    end
    rounds
  end

  def find_current_stage(topic_id=nil)
    due_dates = self.staggered_deadline? ?  TopicDeadline.where( ['topic_id = ?', topic_id], :order => 'due_at DESC') : DueDate.where( ['assignment_id = ?', self.id]).order('due_at DESC')
    if due_dates != nil && due_dates.size > 0
      if Time.now > due_dates[0].due_at
        return 'Finished'
      else
        i = 0
        due_dates.each do |due_date|
          return due_date if Time.now < due_date.due_at && (due_dates[i+1] == nil || Time.now > due_dates[i+1].due_at)
          i = i + 1
        end
      end
    end
  end

  def assign_reviewers(mapping_strategy)
    #ACS Always assign reviewers for a team
    #removed check to see if it is a team assignment
    #defined in DynamicReviewMapping module
    assign_reviewers_for_team(mapping_strategy)
  end

  #this is for staggered deadline assignments or assignments with signup sheet
  def assign_reviewers_staggered(num_reviews, num_review_of_reviews)
    #defined in DynamicReviewMapping module
    message = assign_reviewers_automatically(num_reviews, num_review_of_reviews)

  end

  def get_current_due_date
    due_date = self.find_current_stage()
    (due_date == nil || due_date == 'Finished') ? 'Finished' : due_date
  end

  # Returns hash review_scores[reviewer_id][reviewee_id] = score
  def compute_reviews_hash
    review_questionnaire_id = get_review_questionnaire_id()
    @questions = Question.where( ['questionnaire_id = ?', review_questionnaire_id])
    @review_scores = Hash.new
    #ACS Removed the if condition(and corressponding else) which differentiate assignments as team and individual assignments
    # to treat all assignments as team assignments
    @response_type = 'TeamReviewResponseMap'

    @myreviewers = ResponseMap.select('DISTINCT reviewer_id').where(['reviewed_object_id = ? && type = ? ', self.id, @type])

    @response_maps = ResponseMap.where(['reviewed_object_id = ? && type = ?', self.id, @response_type])

    @response_maps.each do |response_map|
      # Check if response is there
      @corresponding_response = Response.where(['map_id = ?', response_map.id])
      @respective_scores = Hash.new
      @respective_scores = @review_scores[response_map.reviewer_id] if @review_scores[response_map.reviewer_id] != nil

      if @corresponding_response != nil
        @this_review_score_raw = Score.get_total_score(response: @corresponding_response, questions: @questions, q_types: Array.new)
        @this_review_score = ((@this_review_score_raw*100).round/100.0) if @this_review_score_raw >= 0.0
      else
        @this_review_score = 0.0
      end
      @respective_scores[response_map.reviewee_id] = @this_review_score
      @review_scores[response_map.reviewer_id] = @respective_scores
    end
    @review_scores
    end

  def get_review_questionnaire_id
    @revqids = []
    @revqids = AssignmentQuestionnaire.where(['assignment_id = ?', self.id])
    @revqids.each do |rqid|
      rtype = Questionnaire.find(rqid.questionnaire_id).type
      @review_questionnaire_id = rqid.questionnaire_id if rtype == 'ReviewQuestionnaire'
    end
    @review_questionnaire_id
  end

  def get_next_due_date
    due_date = self.find_next_stage()
    (due_date == nil || due_date == 'Finished') ? nil : due_date
  end

  def find_next_stage()
    due_dates = DueDate.where( ['assignment_id = ?', self.id]).order('due_at DESC')

    if due_dates != nil and due_dates.size > 0
      if Time.now > due_dates[0].due_at
        return 'Finished'
      else
        i = 0
        for due_date in due_dates
          if Time.now < due_date.due_at and
            (due_dates[i+1] == nil or Time.now > due_dates[i+1].due_at)
            if i > 0
              return due_dates[i-1]
            else
              return nil
            end
          end
          i = i + 1
        end

        return nil
      end
    end
  end

  # Returns the number of reviewers assigned to a particular assignment
  def get_total_reviews_assigned
    self.response_maps.size
  end

  # get_total_reviews_assigned_by_type()
  # Returns the number of reviewers assigned to a particular assignment by the type of review
  # Param: type - String (ParticipantReviewResponseMap, etc.)
  def get_total_reviews_assigned_by_type(type)
    count = 0
    self.response_maps.each { |x| count = count + 1 if x.type == type }
    count
  end

  # Returns the number of reviews completed for a particular assignment
  def get_total_reviews_completed
    # self.responses.size
    response_count = 0
    self.response_maps.each { |response_map| response_count = response_count + 1 unless response_map.response.nil? }
    response_count
  end

  # Returns the number of reviews completed for a particular assignment by type of review
  # Param: type - String (ParticipantReviewResponseMap, etc.)
  def get_total_reviews_completed_by_type(type)
    # self.responses.size
    response_count = 0
    self.response_maps.each {|response_map|response_count = response_count + 1 if !response_map.response.nil? && response_map.type == type}
    response_count
  end

  # Returns the number of reviews completed for a particular assignment by type of review
  # Param: type - String (ParticipantReviewResponseMap, etc.)
  # Param: date - Filter reviews that were not created on this date
  def get_total_reviews_completed_by_type_and_date(type, date)
    # self.responses.size
    response_count = 0
    self.response_maps.each { |response_map| response_count = response_count + 1 if (response_map.response.created_at.to_datetime.to_date <=> date) == 0 if !response_map.response.nil? && response_map.type == type }
    response_count
  end

  # Returns the percentage of reviews completed as an integer (0-100)
  def get_percentage_reviews_completed
    (get_total_reviews_assigned == 0) ? 0 : ((get_total_reviews_completed().to_f / get_total_reviews_assigned.to_f) * 100).to_i
  end

  # Returns the average of all responses for this assignment as an integer (0-100)
  def get_average_score
    return 0 if get_total_reviews_assigned == 0
    sum_of_scores = 0
    self.response_maps.each do |response_map|
      sum_of_scores = sum_of_scores + response_map.response.get_average_score if !response_map.response.nil?
    end
    (sum_of_scores / get_total_reviews_completed).to_i
  end

  def get_score_distribution
    distribution = Array.new(101, 0)

    self.response_maps.each do |response_map|
      if !response_map.response.nil?
        score = response_map.response.get_average_score.to_i
        distribution[score] += 1 if score >= 0 && score <= 100
      end
    end
    distribution
  end

  # Compute total score for this assignment by summing the scores given on all questionnaires.
  # Only scores passed in are included in this sum.
  def compute_total_score(scores)
    total = 0
    self.questionnaires.each { |questionnaire| total += questionnaire.get_weighted_score(self, scores) }
    total
  end

  # Checks whether there are duplicate assignments of the same name by the same instructor.
  # If the assignments are assigned to courses, it's OK to have duplicate names in different
  # courses.
  #
  # changelog: 5/24/2013
  # Author: hliu11
  #   old method only works after the assignment is created
  #   cover corner case where assignment have not yet been created
  def duplicate_name?
    assignments = Assignment.where(name: self.name)
    assignments.select { |x| x.instructor_id == self.instructor_id } unless self.instructor_id.nil?
    assignments.select { |x| x.course_id == self.course_id } unless self.course_id.nil?

    #if the assignment have not yet been created i.e: Assignment.new without save
    self.id.nil ? assignments.count > 0 :  assignments.count > 1
  end

  def signed_up_topic(contributor)
    # The purpose is to return the topic that the contributor has signed up to do for this assignment.
    # Returns a record from the sign_up_topic table that gives the topic_id for which the contributor has signed up
    # Look for the topic_id where the creator_id equals the contributor id (contributor is a team or a participant)

    # If this is an assignment with quiz required
    if (self.require_quiz?)
      signups = SignedUpUser.where(creator_id: contributor.id)
      for signup in signups do
        signuptopic = SignUpTopic.find(signup.topic_id)
        if (signuptopic.assignment_id == self.id)
          contributors_signup_topic = signuptopic
          return contributors_signup_topic
        end
      end
    end

    # Look for the topic_id where the creator_id equals the contributor id (contributor is a team or a participant)
    (!Team.where(name: contributor.name, id:  contributor.id).first.nil?) ?
      contributors_topic = SignedUpUser.find_by_creator_id(contributor.id) :
      contributors_topic = SignedUpUser.find_by_creator_id(contributor.user_id)
    contributors_signup_topic = SignUpTopic.find(contributors_topic.topic_id) if !contributors_topic.nil?
    end

    def self.export(csv, parent_id, options)
      @assignment = Assignment.find(parent_id)
      @questions = Hash.new
      questionnaires = @assignment.questionnaires
      questionnaires.each { |questionnaire| @questions[questionnaire.symbol] = questionnaire.questions }
      @scores = @assignment.get_scores(@questions)

      return csv if @scores[:teams].nil?

      for index in 0 .. @scores[:teams].length - 1
        team = @scores[:teams][index.to_s.to_sym]
        for participant in team[:team].get_participants
          pscore = @scores[:participants][participant.id.to_s.to_sym]
          tcsv = Array.new
          tcsv << 'team'+index.to_s

          team[:scores] ?
            tcsv.push(team[:scores][:max], team[:scores][:avg], team[:scores][:min], participant.fullname) :
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
    end

    def self.get_export_fields(options)
      fields = Array.new
      fields << 'Team Name'
      fields.push('Team Max', 'Team Avg', 'Team Min') if options['team_score'] == 'true'
      fields.push('Submitted Max', 'Submitted Avg', 'Submitted Min') if options['submitted_score']
      fields.push('Metareview Max', 'Metareview Avg', 'Metareview Min') if options['metareview_score']
      fields.push('Author Feedback Max', 'Author Feedback Avg', 'Author Feedback Min') if options['author_feedback_score']
      fields.push('Teammate Review Max', 'Teammate Review Avg', 'Teammate Review Min') if options['teammate_review_score']
      fields.push('Final Score')
      fields
    end

    def find_due_dates(type)
      self.due_dates.select {|due_date| due_date.deadline_type == DeadlineType.find_by_name(type)}
    end

    def clean_up_due_dates
      #delete due_dates without due_at
      self.due_dates.each {|due_date| due_date.delete if due_date.due_at.nil? }

      submissions = self.find_due_dates('submission') + self.find_due_dates('resubmission')
      submissions.sort! { |x, y| x.due_at <=> y.due_at }
      reviews = self.find_due_dates('review') + self.find_due_dates('rereview')
      reviews.sort! { |x, y| x.due_at <=> y.due_at }

      while submissions.count > self.rounds_of_reviews
        submissions.last.delete
      end

      while reviews.count > self.rounds_of_reviews
        reviews.last.delete
      end

      self.require_signup? ? drop_topic_count = 1 : drop_topic_count = 0
      drop_topic = self.find_due_dates('drop_topic')
      drop_topic.sort! { |x, y| y.due_at <=> x.due_at }
      while drop_topic.count > self.drop_topic_count
        drop_topic.last.delete
      end
    end


    #this should be moved to SignUpSheet model after we refactor the SignUpSheet.
    # returns whether ANY topic has a partner ad; used for deciding whether to show the Advertisements column
    def has_partner_ads?(id)
      Team.find_by_sql("select * from teams where parent_id = "+id+" AND advertise_for_partner='1'").size > 0
    end
  end
