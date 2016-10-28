class ScheduledTask
  # Keeps info required for delayed job
  # to perform an action at a particular time
  # such as sending a reminder email, or dropping outstanding review
  attr_accessor :assignment_id
  attr_accessor :deadline_type
  attr_accessor :due_at
  @@count = 0
  def initialize(assignment_id, deadline_type, due_at)
    self.assignment_id = assignment_id
    self.deadline_type = deadline_type
    self.due_at = due_at
  end

  def perform
    assignment = Assignment.find(self.assignment_id)
    emails = []
    if !assignment.nil? && !assignment.id.nil?


      deadlineObj = self.deadline_type.new
      emails = deadlineObj.email_list

      email_reminder(emails, self.deadline_type) if emails.size > 0
    end
  end


  def email_reminder(emails, deadlineType)
    assignment = Assignment.find(self.assignment_id)
    subject = "Message regarding #{deadlineType} for assignment #{assignment.name}"
    body = "This is a reminder to complete #{deadlineType} for assignment #{assignment.name}. Deadline is #{self.due_at}.If you have already done the  #{deadlineType}, Please ignore this mail."

    # emails<<"vikas.023@gmail.com"
    # emails<<"vsharma4@ncsu.edu"
    @@count += 1
    Rails.logger.info "$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$"
    Rails.logger.info deadlineType
    Rails.logger.info "Count:" + @@count.to_s

    if @@count % 3 == 0
      assignment = Assignment.find(self.assignment_id)

      if (assignment.instructor.copy_of_emails)
        emails << assignment.instructor.email
      end

      # emails<< "expertiza-support@lists.ncsu.edu"
    end

    emails.each do |mail|
      Rails.logger.info mail
    end

    Mailer.delayed_message(
      bcc: emails,
       subject: subject,
       body: body
).deliver
  end

