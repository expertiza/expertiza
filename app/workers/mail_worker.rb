class MailWorker < Worker
    attr_accessor :assignment
    attr_accessor :deadline_type
    attr_accessor :deadline_text
    attr_accessor :due_at
  
    # Note the name perform is required for the MailWorker to properly use Sidekiq
    # Performs the delayed mailer funcction for sending the deadline emails using Sidekiq
    def perform(assignment_id, deadline_type, due_at)
      self.assignment = Assignment.find(assignment_id)
      self.deadline_type = deadline_type
      self.deadline_text = deadline_type
      self.due_at = due_at
  
      participant_emails = find_participant_emails
  
      # Can we rename deadline_type(metareview) to "teammate review". If, yes then we do not need this if clause below!
      self.deadline_text = self.deadline_type == "metareview" ? "teammate review" : self.deadline_type
  
      email_reminder(participant_emails, self.deadline_text) unless participant_emails.empty?
    end
  
    private
  
    #Formats and sends the email to the users of the proper team
    def email_reminder(emails, deadline_type)
      subject = "Message regarding #{deadline_type} for assignment #{self.assignment.name}"
      body = "This is a reminder to complete #{deadline_type} for assignment #{self.assignment.name}. \
      Deadline is #{self.due_at}.If you have already done the  #{deadline_type}, Please ignore this mail."
  
      emails.each do |mail|
        Rails.logger.info mail
      end
  
      @mail = Mailer.delayed_message(bcc: emails, subject: subject, body: body)
      @mail.deliver_now
    end
  
    #Finds the emails of the users on an assignment
    def find_participant_emails
      emails = []
      participants = Participant.where(parent_id: self.assignment.id)
      participants.each do |participant|
        emails << participant.user.email unless participant.user.nil?
      end
      emails
    end
  
  end