class DueDate < ActiveRecord::Base
  validate :due_at_is_valid_datetime
  #  has_paper_trail

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

  ########################################################################################################

  
after_save :start_reminder
  
def start_reminder
  reminder
end


def reminder
 
    assignment = Assignment.find(self.assignment_id)
    participant_mails = find_participant_emails

    if self.deadline_type=='review' || self.deadline_type=='submission' || self.deadline_type=='metareview'

        if self.deadline_type == 'metareview'
            deadlineText="Team Review"
        else
            deadlineText=self.deadline_type
        end
        email_reminder(participant_mails, deadlineText) unless participant_mails.empty?
        
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

    @mail = sync_message(bcc: emails, subject: subject, body: body)
    @mail.deliver_now
  end

 

  def sync_message(defn)
    if Rails.env.development? || Rails.env.test?
        default from: 'expertiza.development@gmail.com'
      else
        default from: 'expertiza-support@lists.ncsu.edu'
      end
    @body = defn[:body]
    @type = defn[:body][:type]
    @obj_name = defn[:body][:obj_name]
    @first_name = defn[:body][:first_name]
    @partial_name = defn[:body][:partial_name]

    defn[:to] = 'expertiza.development@gmail.com' if Rails.env.development? || Rails.env.test?
    mail(subject: defn[:subject],
         # content_type: "text/html",
         to: defn[:to])
  end



def find_participant_emails
    emails = []
    participants = Participant.where(parent_id: self.assignment_id)
    participants.each do |participant|
      emails << participant.user.email unless participant.user.nil?
    end
    emails
  end


  
def when_to_run_reminder
  hours_before_deadline = self.threshold.hours 
  adjusted_datetime = (self.due_at.to_time - hours_before_deadline).to_datetime
end

def when_to_run_start_reminder
  days_before_deadline = 3.days
  adjusted_datetime = (self.due_at - days_before_deadline).to_datetime
end

handle_asynchronously :start_reminder, :run_at => Proc.new { |i| i.when_to_run_start_reminder }
handle_asynchronously :reminder, :run_at => Proc.new { |i| i.when_to_run_reminder }


end



