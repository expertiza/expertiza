class DueDate < ActiveRecord::Base
  validate :due_at_is_valid_datetime
  #  has_paper_trail
  after_save :start_reminder

  def self.default_permission(deadline_type, permission_type)
    DeadlineRight::DEFAULT_PERMISSION[deadline_type][permission_type]
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

  def create_mailer_object
    Mailer.new
  end

  def create_mailworker_object
    MailWorker.new(self.assignment_id, self.deadline_type, self.due_at)
  end

  def start_reminder
    reminder
  end

  def reminder
    if %w[submission review metareview].include? self.deadline_type
      deadline_text = self.deadline_type
      deadline_text = "Team Review" if self.deadline_type == 'metareview'
      email_reminder(create_mailworker_object.find_participant_emails, deadline_text) unless create_mailworker_object.find_participant_emails.empty?
    end
  end

  def email_reminder(emails, deadline_type)
    assignment = Assignment.find(self.assignment_id)
    subject = "Message regarding #{deadline_type} for assignment #{assignment.name}"
    body = "This is a reminder to complete #{deadline_type} for assignment #{assignment.name}. \
    Deadline is #{self.due_at}.If you have already done the  #{deadline_type}, Please ignore this mail."

    emails.each do |mail|
      Rails.logger.info mail
    end
    create_mailer_object.sync_message(Hash[bcc: emails, subject: subject, body: body]).deliver
  end

  def when_to_run_reminder
    hours_before_deadline = self.threshold.hours
    (self.due_at.to_time_in_current_zone - hours_before_deadline).to_datetime
  end

  def when_to_run_start_reminder
    days_before_deadline = 3.days
    (self.due_at - days_before_deadline).to_datetime
  end

  handle_asynchronously :start_reminder, run_at: proc {|i| i.when_to_run_start_reminder }
  handle_asynchronously :reminder, run_at: proc {|i| i.when_to_run_reminder }
end
