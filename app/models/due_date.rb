class DueDate < ActiveRecord::Base
  validate :due_at_is_valid_datetime
  #  has_paper_trail
  after_save :start_reminder

  def self.default_permission(deadline_type, permission_type)
    DeadlineRight::DEFAULT_PERMISSION[deadline_type][permission_type]
  end

  def self.current_due_date(due_dates)
    #Get the current due date from list of due dates
    due_dates.each do |due_date|
      if due_date.due_at > Time.now
        current_due_date = due_date
        return current_due_date
      end
    end
    #in case current due date not found
    return nil 
  end

  def self.teammate_review_allowed(student)
    # time when teammate review is allowed
    due_date = current_due_date(student.assignment.due_dates)
    student.assignment.find_current_stage == 'Finished' ||
    due_date &&
    (due_date.teammate_review_allowed_id == 3 ||
    due_date.teammate_review_allowed_id == 2) # late(2) or yes(3)
  end

  def set_flag
    self.flag = true
    self.save
  end

  def due_at_is_valid_datetime
    if due_at.present?
      errors.add(:due_at, 'must be a valid datetime') if (DateTime.strptime(due_at.to_s, '%Y-%m-%d %H:%M:%S') rescue ArgumentError) == ArgumentError
    end
  end

  def self.copy(old_assignment_id, new_assignment_id)
    duedates = where(parent_id: old_assignment_id)
    duedates.each do |orig_due_date|
      new_due_date = orig_due_date.dup
      new_due_date.parent_id = new_assignment_id
      new_due_date.save
    end
  end

  def self.set_duedate(duedate, deadline, assign_id, max_round)
    submit_duedate = DueDate.new(duedate)
    submit_duedate.deadline_type_id = deadline
    submit_duedate.parent_id = assign_id
    submit_duedate.round = max_round
    submit_duedate.save
  end

  def self.deadline_sort(due_dates)
    due_dates.sort do |m1, m2|
      if m1.due_at and m2.due_at
        m1.due_at <=> m2.due_at
      elsif m1.due_at
        -1
      else
        1
      end
    end
  end

  def self.done_in_assignment_round(assignment_id, response)
    # for author feedback, quiz, teammate review and metareview, Expertiza only support one round, so the round # should be 1
    return 0 if ResponseMap.find(response.map_id).type != "ReviewResponseMap"
    due_dates = DueDate.where(parent_id: assignment_id)
    # sorted so that the earliest deadline is at the first
    sorted_deadlines = deadline_sort(due_dates)
    due_dates.reject {|due_date| due_date.deadline_type_id != 1 && due_date.deadline_type_id != 2 }
    round = 1
    sorted_deadlines.each do |due_date|
      break if response.created_at < due_date.due_at
      round += 1 if due_date.deadline_type_id == 2
    end
    round
  end

  def self.get_next_due_date(assignment_id, topic_id = nil)
    if Assignment.find(assignment_id).staggered_deadline?
      next_due_date = TopicDueDate.find_by(['parent_id = ? and due_at >= ?', topic_id, Time.zone.now])
      # if certion TopicDueDate is not exist, we should query next corresponding AssignmentDueDate.
      # eg. Time.now is 08/28/2016
      # One topic uses following deadlines:
      # TopicDueDate      08/01/2016
      # TopicDueDate      08/02/2016
      # TopicDueDate      08/03/2016
      # AssignmentDueDate 09/04/2016
      # In this case, we cannot find due_at later than Time.now in TopicDueDate.
      # So we should find next corrsponding AssignmentDueDate, starting with the 4th one, not the 1st one!
      if next_due_date.nil?
        topic_due_date_size = TopicDueDate.where(parent_id: topic_id).size
        following_assignment_due_dates = AssignmentDueDate.where(parent_id: assignment_id)[topic_due_date_size..-1]
        unless following_assignment_due_dates.nil?
          following_assignment_due_dates.each do |assignment_due_date|
            if assignment_due_date.due_at >= Time.zone.now
              next_due_date = assignment_due_date
              break
            end
          end
        end
      end
    else
      next_due_date = AssignmentDueDate.find_by(['parent_id = ? && due_at >= ?', assignment_id, Time.zone.now])
    end
    next_due_date
  end

  # TODO E2135. Email notification to reviewers and instructors
  def create_mailer_object
    Mailer.new
  end

  def create_mailworker_object
    MailWorker.new(self.parent_id, self.deadline_type, self.due_at)
  end

  # main function to start email reminder
  def start_reminder
    puts when_to_run_reminder
    if self.changed?
      @extra_param = self.parent_id.to_s + "," + self.deadline_type_id.to_s
      # first deleted existed delayed jobs with same parent_id(which is assignment id actually)
      Delayed::Job.where(extra_param: @extra_param).each do |job|
        job.delete
      end
      # add a delayed job to the delayed job queue, the job will run at what when_to_run_reminder return
      run_at_time = when_to_run_reminder
      if run_at_time >= 0.seconds.from_now
        self.delay(run_at: run_at_time, :extra_param => @extra_param).reminder
      end
    end
  end

  def reminder
    deadline_text = self.deadline_type if %w[submission review].include? self.deadline_type
    deadline_text = "Team Review" if self.deadline_type == 'metareview'
    mail_worker = create_mailworker_object
    email_reminder(mail_worker.find_participant_emails, deadline_text) unless mail_worker.find_participant_emails.empty?
  end

  def email_reminder(emails, deadline_type)
    assignment = Assignment.find(self.parent_id)
    subject = "Message regarding #{deadline_type} for assignment #{assignment.name}"
    body = "This is a reminder to complete #{deadline_type} for assignment #{assignment.name}. \
    Deadline is #{self.due_at}.If you have already done the  #{deadline_type}, Please ignore this mail."

    emails.each do |mail|
      Rails.logger.info mail
    end

    Mailer.delayed_message(bcc: emails, subject: subject, body: body).deliver_now

  end

  # after duedate - threshold hours, then we can send the reminder email
  def when_to_run_reminder
    hours_before_deadline = self.threshold.hours
    result = (self.due_at.in_time_zone - hours_before_deadline).to_datetime
    result
  end

  def when_to_run_start_reminder
    days_before_deadline = 3.days
    result = (self.due_at - days_before_deadline).to_datetime
    result
  end

  # run asynchronously by using Delayed_Jobs module, the operation will be serialized into database(in delayed_jobs table)
  # handle_asynchronously :start_reminder, run_at: proc { |i| i.when_to_run_start_reminder }
  # handle_asynchronously :reminder, run_at: proc {|i| i.when_to_run_reminder }, :queue => @queue_name, :extra_param => @extra_param

end
