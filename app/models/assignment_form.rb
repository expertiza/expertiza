
require 'active_support/time_with_zone'
class AssignmentForm
  attr_accessor :assignment, :assignment_questionnaires, :due_dates, :tag_prompt_deployments
  attr_accessor :errors

  DEFAULT_MAX_TEAM_SIZE = 1

  def initialize(args = {})
    @assignment = Assignment.new(args[:assignment])
    if args[:assignment].nil?
      @assignment.course = Course.find(args[:parent_id]) if args[:parent_id]
      @assignment.instructor = @assignment.course.instructor if @assignment.course
      @assignment.max_team_size = DEFAULT_MAX_TEAM_SIZE
    end
    @assignment.num_review_of_reviews = @assignment.num_metareviews_allowed
    @assignment_questionnaires = Array(args[:assignment_questionnaires])
    @due_dates = Array(args[:due_dates])
  end

  # create a form object for this assignment_id
  def self.create_form_object(assignment_id)
    assignment_form = AssignmentForm.new
    assignment_form.assignment = Assignment.find(assignment_id)
    assignment_form.assignment_questionnaires = AssignmentQuestionnaire.where(assignment_id: assignment_id)
    assignment_form.due_dates = AssignmentDueDate.where(parent_id: assignment_id)
    assignment_form.set_up_assignment_review
    assignment_form.tag_prompt_deployments = TagPromptDeployment.where(assignment_id: assignment_id)
    assignment_form
  end

  def update(attributes, user)
    @has_errors = false
    has_late_policy = false
    if attributes[:assignment][:late_policy_id].to_i > 0
      has_late_policy = true
    else
      attributes[:assignment][:late_policy_id] = nil
    end

    good_teammate_threshold=attributes[:assignment].delete("badge_2_threshold")
    good_reviewer_threshold=attributes[:assignment].delete("badge_1_threshold")

    update_assignment(attributes[:assignment])
    set_badge_threshold_for_assignment(attributes[:assignment][:id],good_reviewer_threshold,good_teammate_threshold)
    update_assignment_questionnaires(attributes[:assignment_questionnaire]) unless @has_errors
    update_due_dates(attributes[:due_date], user) unless @has_errors
    add_simicheck_to_delayed_queue(attributes[:assignment][:simicheck])
    # delete the old queued items and recreate new ones if the assignment has late policy.
    if attributes[:due_date] and !@has_errors and has_late_policy
      delete_from_delayed_queue
      add_to_delayed_queue
    end
    update_tag_prompt_deployments(attributes[:tag_prompt_deployments])
    !@has_errors
  end

  alias update_attributes update

  # Code to update values of assignment
  def update_assignment(attributes)
    unless @assignment.update_attributes(attributes)
      @errors = @assignment.errors.to_s
      @has_errors = true
    end
    @assignment.num_review_of_reviews = @assignment.num_metareviews_allowed
    @assignment.num_reviews = @assignment.num_reviews_allowed
  end

  # code to save assignment questionnaires
  def update_assignment_questionnaires(attributes)
    return false unless attributes
    existing_aqs = AssignmentQuestionnaire.where(assignment_id: @assignment.id)
    existing_aqs.each(&:delete)
    attributes.each do |assignment_questionnaire|
      if assignment_questionnaire[:id].nil? or assignment_questionnaire[:id].blank?
        aq = AssignmentQuestionnaire.new(assignment_questionnaire)
        unless aq.save
          @errors = @assignment.errors.to_s
          @has_errors = true
        end
      else
        aq = AssignmentQuestionnaire.find(assignment_questionnaire[:id])
        unless aq.update_attributes(assignment_questionnaire)
          @errors = @assignment.errors.to_s
          @has_errors = true
        end
      end
    end
  end

  # s required by answer tagging
  def update_tag_prompt_deployments(attributes)
    unless attributes.nil?
      attributes.each do |key, value|
        if value.key?('deleted')
          TagPromptDeployment.where(id: value['deleted']).delete_all
        end
        # assume if tag_prompt is there, then id, question_type, answer_length_threshold must also be there since the inputs are coupled
        next unless value.key?('tag_prompt')
        for i in 0..value['tag_prompt'].count - 1
          tag_dep = nil
          if !(value['id'][i] == "undefined" or value['id'][i] == "null" or value['id'][i].nil?)
            tag_dep = TagPromptDeployment.find(value['id'][i])
            if tag_dep
              tag_dep.update(assignment_id: @assignment.id,
                             questionnaire_id: key,
                             tag_prompt_id: value['tag_prompt'][i],
                             question_type: value['question_type'][i],
                             answer_length_threshold: value['answer_length_threshold'][i])
            end
          else
            tag_dep = TagPromptDeployment.new(assignment_id: @assignment.id,
                                              questionnaire_id: key,
                                              tag_prompt_id: value['tag_prompt'][i],
                                              question_type: value['question_type'][i],
                                              answer_length_threshold: value['answer_length_threshold'][i]).save
          end
        end
      end
    end
  end
  # end required by answer tagging

  # code to save due dates
  def update_due_dates(attributes, user)
    return false unless attributes
    attributes.each do |due_date|
      next if due_date[:due_at].blank?
      # parse the dd and convert it to utc before saving it to db
      # eg. 2015-06-22 12:05:00 -0400
      current_local_time = Time.parse(due_date[:due_at][0..15])
      tz = ActiveSupport::TimeZone[user.timezonepref].tzinfo
      utc_time = tz.local_to_utc(Time.local(current_local_time.year,
                                            current_local_time.month,
                                            current_local_time.day,
                                            current_local_time.strftime('%H').to_i,
                                            current_local_time.strftime('%M').to_i,
                                            current_local_time.strftime('%S').to_i))
      due_date[:due_at] = utc_time
      if due_date[:id].nil? or due_date[:id].blank?
        dd = AssignmentDueDate.new(due_date)
        @has_errors = true unless dd.save
      else
        dd = AssignmentDueDate.find(due_date[:id])
        # get deadline for review
        @has_errors = true unless dd.update_attributes(due_date)
      end
      @errors += @assignment.errors.to_s if @has_errors
    end
  end

  # Adds items to delayed_jobs queue for this assignment
  def add_to_delayed_queue
    duedates = AssignmentDueDate.where(parent_id: @assignment.id)
    duedates.each do |due_date|
      deadline_type = DeadlineType.find(due_date.deadline_type_id).name
      diff_btw_time_left_and_threshold, min_left = get_time_diff_btw_due_date_and_now(due_date)
      next unless diff_btw_time_left_and_threshold > 0
      delayed_job = add_delayed_job(@assignment, deadline_type, due_date, diff_btw_time_left_and_threshold)
      due_date.update_attribute(:delayed_job_id, delayed_job.id)
      # If the deadline type is review, add a delayed job to drop outstanding review
      if deadline_type == "review"
        add_delayed_job(@assignment, "drop_outstanding_reviews", due_date, min_left)
      end
      # If the deadline type is team_formation, add a delayed job to drop one member team
      next unless deadline_type == "team_formation" and @assignment.team_assignment?
      add_delayed_job(@assignment, "drop_one_member_topics", due_date, min_left)
    end
  end

  def get_time_diff_btw_due_date_and_now(due_date)
    due_at = due_date.due_at.to_s(:db)
    Time.parse(due_at)
    due_at = Time.parse(due_at)
    time_left_in_min = find_min_from_now(due_at)
    diff_btw_time_left_and_threshold = time_left_in_min - due_date.threshold * 60
    [diff_btw_time_left_and_threshold, time_left_in_min]
  end

  # add DelayedJob into queue and return it
  def add_delayed_job(assignment, deadline_type, due_date, min_left)
    delayed_job = DelayedJob.enqueue(DelayedMailer.new(assignment.id, deadline_type, due_date.due_at.to_s(:db)),
                                     1, min_left.minutes.from_now)
    change_item_type(delayed_job.id)
    delayed_job
  end

  # Deletes the job with id equal to "delayed_job_id" from the delayed_jobs queue
  def delete_from_delayed_queue
    djobs = Delayed::Job.where(['handler LIKE "%assignment_id: ?%"', @assignment.id])
    for dj in djobs
      dj.delete if !dj.nil? && !dj.id.nil?
    end
  end

  # Change the item_type displayed in the log
  def change_item_type(delayed_job_id)
    log = Version.find_by(item_type: "Delayed::Backend::ActiveRecord::Job", item_id: delayed_job_id)
    log.update_attribute(:item_type, "DelayedMailer") # Change the item type in the log
  end

  def delete(force = nil)
    # delete from delayed_jobs queue related to this assignment
    delete_from_delayed_queue
    @assignment.delete(force)
  end

  # This functions finds the epoch time in seconds of the due_at parameter and finds the difference of it
  # from the current time and returns this difference in minutes
  def find_min_from_now(due_at)
    curr_time = DateTime.now.in_time_zone(zone = 'UTC').to_s(:db)
    curr_time = Time.parse(curr_time)
    time_in_min = ((due_at - curr_time).to_i / 60)
    # time_in_min = 1
    time_in_min
  end

  # Save the assignment
  def save
    @assignment.save
    set_badge_threshold_for_assignment(@assignment.id, nil, nil)
  end

  # create a node for the assignment
  def create_assignment_node
    @assignment.create_node unless @assignment.nil?
  end

  # NOTE: many of these functions actually belongs to other models
  #====setup methods for new and edit method=====#
  def set_up_assignment_review
    set_up_defaults

    submissions = @assignment.find_due_dates('submission')
    reviews = @assignment.find_due_dates('review')
    @assignment.rounds_of_reviews = [@assignment.rounds_of_reviews, submissions.count, reviews.count].max

    @assignment.directory_path = nil if @assignment.directory_path.empty?
  end

  def staggered_deadline
    @assignment.staggered_deadline = false if @assignment.staggered_deadline.nil?
  end

  def availability_flag
    @assignment.availability_flag = false if @assignment.availability_flag.nil?
  end

  def micro_task
    @assignment.microtask = false if @assignment.microtask.nil?
  end

  def reviews_visible_to_all
    @assignment.reviews_visible_to_all = false if @assignment.reviews_visible_to_all.nil?
  end

  def review_assignment_strategy
    @assignment.review_assignment_strategy = '' if @assignment.review_assignment_strategy.nil?
  end

  def require_quiz
    if @assignment.require_quiz.nil?
      @assignment.require_quiz = false
      @assignment.num_quiz_questions = 0
    end
  end

  # NOTE: unfortunately this method is needed due to bad data in db @_@
  def set_up_defaults
    staggered_deadline
    availability_flag
    micro_task
    reviews_visible_to_all
    review_assignment_strategy
    require_quiz
  end

  def add_simicheck_to_delayed_queue(simicheck_delay)
    delete_from_delayed_queue
    if simicheck_delay.to_i >= 0
      duedates = AssignmentDueDate.where(parent_id: @assignment.id)
      duedates.each do |due_date|
        next if DeadlineType.find(due_date.deadline_type_id).name != "submission"
        change_item_type(enqueue_simicheck_task(due_date, simicheck_delay).id)
      end
    end
  end

  def enqueue_simicheck_task(due_date, simicheck_delay)
    DelayedJob.enqueue(DelayedMailer.new(@assignment.id, "compare_files_with_simicheck", due_date.due_at.to_s(:db)),
                       1, find_min_from_now(Time.parse(due_date.due_at.to_s(:db)) + simicheck_delay.to_i.hours).minutes.from_now)
  end

  # Copies the inputted assignment into new one and returns the new assignment id
  def self.copy(assignment_id, user)
    Assignment.record_timestamps = false
    old_assign = Assignment.find(assignment_id)
    new_assign = old_assign.dup
    user.set_instructor(new_assign)
    new_assign.update_attribute('name', 'Copy of ' + new_assign.name)
    new_assign.update_attribute('created_at', Time.now)
    new_assign.update_attribute('updated_at', Time.now)
    if new_assign.directory_path.present?
      new_assign.update_attribute('directory_path', new_assign.directory_path + '_copy')
    end
    new_assign.copy_flag = true
    if new_assign.save
      Assignment.record_timestamps = true
      copy_assignment_questionnaire(old_assign, new_assign, user)
      AssignmentDueDate.copy(old_assign.id, new_assign.id)
      new_assign.create_node
      new_assign_id = new_assign.id
      # also copy topics from old assignment
      topics = SignUpTopic.where(assignment_id: old_assign.id)
      topics.each do |topic|
        SignUpTopic.create(topic_name: topic.topic_name, assignment_id: new_assign_id, max_choosers: topic.max_choosers, category: topic.category, topic_identifier: topic.topic_identifier, micropayment: topic.micropayment)
      end
    else
      new_assign_id = nil
    end
    new_assign_id
  end

  def self.copy_assignment_questionnaire(old_assign, new_assign, user)
    old_assign.assignment_questionnaires.each do |aq|
      AssignmentQuestionnaire.create(
        assignment_id: new_assign.id,
        questionnaire_id: aq.questionnaire_id,
        user_id: user.id,
        notification_limit: aq.notification_limit,
        questionnaire_weight: aq.questionnaire_weight
      )
    end
  end

  def set_badge_threshold_for_assignment(assignment_id, good_reviewer_threshold, good_teammate_threshold)



    if good_reviewer_threshold.nil?
      good_reviewer_threshold=95
    else
      good_reviewer_threshold = good_reviewer_threshold.to_i
    end
    if good_teammate_threshold.nil?
      good_teammate_threshold=95
    else
      good_teammate_threshold = good_teammate_threshold.to_i
    end

    good_reviewer_badge= AssignmentBadge.find_by_assignment_id_and_badge_id(assignment_id, 1)
    good_teammate_badge=AssignmentBadge.find_by_assignment_id_and_badge_id(assignment_id, 2)

    if good_reviewer_badge.nil?
      good_reviewer_badge= AssignmentBadge.create(assignment_id: assignment_id, badge_id: 1, threshold: good_reviewer_threshold)
    else
      good_reviewer_badge.threshold=good_reviewer_threshold
    end
    begin
      good_reviewer_badge.save
    rescue
      flash[:error] = $ERROR_INFO
    end

    Participant.where(:parent_id => assignment_id).each do |participant|
      awardedbadge = AwardedBadge.find_by(participant_id:participant.id, badge_id:good_reviewer_badge.badge_id)
      reviewgrade = ReviewGrade.find_by_participant_id(participant.id).grade_for_reviewer unless ReviewGrade.find_by_participant_id(participant.id).nil?

      if (awardedbadge == nil && reviewgrade && reviewgrade >= good_reviewer_threshold)
        AwardedBadge.create(badge_id: 1, participant_id: participant.id)
      end

      if (awardedbadge != nil && reviewgrade < good_reviewer_threshold)
        AwardedBadge.find_by(badge_id: 1, participant_id: participant.id).delete
      end

    end

    if good_teammate_badge.nil?
      good_teammate_badge = AssignmentBadge.create(assignment_id: assignment_id, badge_id: 2, threshold: good_reviewer_threshold)
    else
      good_teammate_badge.threshold = good_teammate_threshold
    end
    begin
      good_teammate_badge.save
    rescue
      flash[:error] = $ERROR_INFO
    end

    Participant.where(parent_id: assignment_id).each do |participant|

      teammate_review = TeammateReviewResponseMap.find_by(reviewee_id: participant.id)

      teammate_review.update_good_teammate_badge unless teammate_review.nil?

    end
  end

end
