require 'active_support/time_with_zone'
require 'fileutils'

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
    update_assignment(attributes[:assignment])
    update_assignment_questionnaires(attributes[:assignment_questionnaire]) unless @has_errors
    update_due_dates(attributes[:due_date], user) unless @has_errors
    update_assigned_badges(attributes[:badge], attributes[:assignment]) unless @has_errors
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
    validate_assignment_questionnaires_weights(attributes)
    @errors = @assignment.errors
    unless @has_errors
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
  end

  # checks to see if the sum of weights of all rubrics add up to either 0 or 100%
  def validate_assignment_questionnaires_weights(attributes)
    total_weight = 0
    attributes.each do |assignment_questionnaire|
      total_weight += assignment_questionnaire[:questionnaire_weight].to_i
    end
    if total_weight != 0 and total_weight != 100
      @assignment.errors.add(:message, 'Total weight of rubrics should add up to either 0 or 100%')
      @has_errors = true
    end
  end

  # s required by answer tagging
  def update_tag_prompt_deployments(attributes)
    unless attributes.nil?
      attributes.each do |key, value|
        TagPromptDeployment.where(id: value['deleted']).delete_all if value.key?('deleted')
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

  # Adds badges to assignment badges table as part of E1822
  def update_assigned_badges(badge, assignment)
    if assignment and badge
      AssignmentBadge.where(assignment_id: assignment[:id]).map(&:id).each do |assigned_badge_id|
        AssignmentBadge.delete(assigned_badge_id) unless badge[:id].include?(assigned_badge_id)
      end
      badge[:id].each do |badge_id|
        AssignmentBadge.where(badge_id: badge_id[0], assignment_id: assignment[:id]).first_or_create
      end
    end
  end

  # Adds items to delayed_jobs queue for this assignment
  def add_to_delayed_queue
    duedates = AssignmentDueDate.where(parent_id: @assignment.id)
    duedates.each do |due_date|
      deadline_type = DeadlineType.find(due_date.deadline_type_id).name
      diff_btw_time_left_and_threshold, min_left = get_time_diff_btw_due_date_and_now(due_date)
      next unless diff_btw_time_left_and_threshold > 0
      delayed_job_id = add_delayed_job(@assignment, deadline_type, due_date, diff_btw_time_left_and_threshold)
      due_date.update_attribute(:delayed_job_id, delayed_job_id)
      # If the deadline type is review, add a delayed job to drop outstanding review
      add_delayed_job(@assignment, "drop_outstanding_reviews", due_date, min_left) if deadline_type == "review"
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
  def add_delayed_job(_assignment, deadline_type, due_date, min_left)
    delayed_job_id = MailWorker.perform_in(min_left * 60, due_date.parent_id, deadline_type, due_date.due_at)
    delayed_job_id
  end

  # Deletes the job with id equal to "delayed_job_id" from the delayed_jobs queue
  def delete_from_delayed_queue
    queue = Sidekiq::Queue.new("mailers")
    queue.each do |job|
      assignmentId = job.args.first
      job.delete if @assignment.id == assignmentId
    end

    queue = Sidekiq::ScheduledSet.new
    queue.each do |job|
      assignmentId = job.args.first
      job.delete if @assignment.id == assignmentId
    end
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
        enqueue_simicheck_task(due_date, simicheck_delay)
      end
    end
  end

  def enqueue_simicheck_task(due_date, simicheck_delay)
    MailWorker.perform_in(find_min_from_now(Time.parse(due_date.due_at.to_s(:db)) + simicheck_delay.to_i.hours).minutes.from_now * 60, @assignment.id, "compare_files_with_simicheck", due_date.due_at.to_s(:db))
  end

  # Copies the inputted assignment into new one and returns the new assignment id
  def self.copy(assignment_id, user)
    Assignment.record_timestamps = false
    old_assign = Assignment.find(assignment_id)
    new_assign = old_assign.dup
    user.set_instructor(new_assign)
    # Set name of new assignment as 'Copy of <old assignment name>'. If it already exists, set it as 'Copy of <old assignment name> (1)'.
    # Repeated till unique name is found.
    name_counter = 0
    new_name = 'Copy of ' + new_assign.name
    until Assignment.find_by(name: new_name).nil?
      new_name = 'Copy of ' + new_assign.name
      name_counter += 1
      new_name += ' (' + name_counter.to_s + ')'
    end
    new_assign.update_attribute('name', new_name)
    new_assign.update_attribute('created_at', Time.now)
    new_assign.update_attribute('updated_at', Time.now)
    new_assign.update_attribute('directory_path', new_assign.directory_path + '_copy') if new_assign.directory_path.present?
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
    if old_assign.is_calibrated
      @original_values = SubmissionRecord.where(assignment_id: old_assign.id)
      @original_values.each do |catt|
        @new_entry = SubmissionRecord.new
        @new_entry.type = catt.type
        @new_entry.content = catt.content
        @new_entry.operation = catt.operation
        @new_entry.team_id = catt.team_id
        @new_entry.user = catt.user
        @new_entry.assignment_id = new_assign_id
        @new_entry.save
      end
      @original_team_values = Team.where(parent_id: old_assign.id)
      keep_track = []
      @original_team_values.each do |catt|
        @assignment_sample1 = Assignment.find(old_assign.id)
        @instructor_sample1 = Participant.find_by(parent_id: old_assign.id, user_id: @assignment_sample1.instructor_id)
        @map = ReviewResponseMap.find_by(reviewed_object_id: old_assign.id, reviewer_id: @instructor_sample1.id, reviewee_id: catt.id)
        if @map
          @resp = Response.find_by(map_id: @map.id, is_submitted: false)
          if @resp
            keep_track.append(catt.id)
            @new_entry = Team.new
            @new_entry.name = catt.name
            @new_entry.parent_id = new_assign_id
            @new_entry.type = catt.type
            @new_entry.comments_for_advertisement = catt.comments_for_advertisement
            @new_entry.advertise_for_partner = catt.advertise_for_partner
            @new_entry.submitted_hyperlinks = catt.submitted_hyperlinks
            @new_entry.directory_num = catt.directory_num
            @new_entry.grade_for_submission = catt.grade_for_submission
            @new_entry.comment_for_submission = catt.comment_for_submission
            @new_entry.make_public = catt.make_public
            @new_entry.save
          else
            next
          end
        else
          next
        end
      end
      @beta = Team.where(parent_id: new_assign_id)
      a = []
      @beta.each do |catt|
        a.append(catt.id)
      end
      dict = Hash[keep_track.zip a]
      count = 0
      keep_track.each do |catt|
        @charlie = TeamsUser.where(team_id: catt)
        @charlie.each do |matt|
          @delta = TeamsUser.new
          @delta.team_id = a[count]
          @delta.user_id = matt.user_id
          @delta.save
          @gamma = Participant.where(user_id: matt.user_id, parent_id: old_assign.id)
          @gamma.each do |natt|
            @zeta = Participant.new
            @zeta.can_submit = natt.can_submit
            @zeta.can_review = natt.can_review
            @zeta.user_id = matt.user_id
            @zeta.parent_id = new_assign_id
            @zeta.submitted_at = natt.submitted_at
            @zeta.permission_granted = natt.permission_granted
            @zeta.penalty_accumulated = natt.penalty_accumulated
            @zeta.grade = natt.grade
            @zeta.type = natt.type
            @zeta.handle = natt.handle
            @zeta.time_stamp = natt.time_stamp
            @zeta.digital_signature = natt.digital_signature
            @zeta.duty = natt.duty
            @zeta.can_take_quiz = natt.can_take_quiz
            @zeta.save
          end
        end
        @assignment_number1 = Assignment.find_by(id: old_assign.id)
        @assignment_number2 = Assignment.find_by(id: new_assign_id)
        @old_entry = Participant.find_by(parent_id: old_assign.id, user_id: @assignment_number1.instructor_id)
        @updating_participant = Participant.new
        @updating_participant.can_submit = @old_entry.can_submit
        @updating_participant.can_review = @old_entry.can_review
        @updating_participant.user_id = @assignment_number2.instructor_id
        @updating_participant.parent_id = new_assign_id
        @updating_participant.submitted_at = @old_entry.submitted_at
        @updating_participant.permission_granted = @old_entry.permission_granted
        @updating_participant.penalty_accumulated = @old_entry.penalty_accumulated
        @updating_participant.grade = @old_entry.grade
        @updating_participant.type = @old_entry.type
        @updating_participant.handle = @old_entry.handle
        @updating_participant.time_stamp = @old_entry.time_stamp
        @updating_participant.digital_signature = @old_entry.digital_signature
        @updating_participant.duty = @old_entry.duty
        @updating_participant.can_take_quiz = @old_entry.can_take_quiz
        @updating_participant.save
        @getparticipant = Participant.find_by(parent_id: new_assign_id, user_id: @assignment_number1.instructor_id)
        @xenon = ReviewResponseMap.where(reviewed_object_id: old_assign.id)
        @xenon.each do |satt|
          if dict.key?(satt.reviewee_id)
            @iota = ReviewResponseMap.new
            @iota.reviewed_object_id = new_assign_id
            @iota.reviewer_id = @getparticipant.id
            @iota.reviewee_id = dict[satt.reviewee_id]
            @iota.type = satt.type
            @iota.created_at = satt.created_at
            @iota.calibrate_to = satt.calibrate_to
            @iota.save
          else
            next
          end
        end
        @xenon = ReviewResponseMap.where(reviewed_object_id: old_assign.id, reviewee_id: catt)
        @eta =  ReviewResponseMap.where(reviewed_object_id: new_assign_id, reviewee_id: dict[catt])
        list1 = []
        list2 = []
        @xenon.each do |zatt|
          list1.append(zatt.id)
        end
        @eta.each do |zatt|
          list2.append(zatt.id)
        end
        dict1 = Hash[list1.zip list2]
        dict1.each do |item, value|
          @neo = Response.where(map_id: item)
          @neo.each do |zatt|
            @theta = Response.new
            @theta.map_id = value
            @theta.additional_comment = zatt.additional_comment
            @theta.version_num = zatt.version_num
            @theta.round = zatt.round
            @theta.is_submitted = zatt.is_submitted
            @theta.save
          end
        end
        count += 1
      end
    end
    old_directory_name = old_assign.directory_path
    directory_path_name = "pg_data/instructor6/" + old_directory_name
    if File.exist?(directory_path_name)
      directory_name = new_assign.directory_path
      directory = "pg_data/instructor6/" + directory_name
      Dir.mkdir(directory) unless File.exist?(directory)
      my_dir = Dir[directory_path_name + '/*']
      my_dir.each do |filename|
        FileUtils.cp(filename, directory + '/')
      end
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
        questionnaire_weight: aq.questionnaire_weight,
        used_in_round: aq.used_in_round,
        dropdown: aq.dropdown
      )
    end
  end
end