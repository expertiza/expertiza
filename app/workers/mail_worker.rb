require 'sidekiq'

class MailWorker < Worker
    attr_accessor :assignment, :deadline_type, :deadline_text, :due_at
  
    # Note the name perform is required for the MailWorker to properly use Sidekiq
    # we override this method perform that is defined in worker.rb 
    # Performs the delayed mailer function for sending the deadline emails using Sidekiq
    # we set the deadline_text according to the deadline_type so that 
    # an email message can be constructed and sent to the appropriate participant users
    # if the deadline_type is 'metareview' then we use name 'teammate review' instead for readability
    # if the deadline type is 'drop_outsatnding_reviews' then we dont send a reminder email 
    # and proceed to drop all the reviews that have not been started
    # in all other cases we send the email to the participant users
    def perform(assignment_id, deadline_type, due_at)
      self.assignment = Assignment.find(assignment_id)
      self.deadline_type = deadline_type
      self.due_at = due_at
  
      self.deadline_text = self.deadline_type == 'metareview' ? 'teammate review' : self.deadline_type
  
      if deadline_type != 'drop_outstanding_reviews'
        participant_emails = find_participant_emails
        email_reminder(participant_emails, self.deadline_text) unless participant_emails.empty?
      end
    end
  
    private
  
    # Generates the body of the email text using appropriate variables
    # and sends the email to all the participant users
    def email_reminder(emails, deadline_type)
      subject = "Message regarding #{deadline_type} for assignment #{self.assignment.name}"
      body = "This is a reminder to complete #{deadline_type} for assignment #{self.assignment.name}. \
      Deadline is #{self.due_at}.If you have already done the  #{deadline_type}, Please ignore this mail."
  
      emails.each do |mail|
        Rails.logger.info mail
      end
  
      Mailer.delayed_message(bcc: emails, subject: subject, body: body).deliver_now
    end
  
    # Finds the emails of the users on an assignment
    def find_participant_emails
      emails = []
      participants = Participant.where(parent_id: self.assignment.id)
      participants.each do |participant|
        emails << participant.user.email unless participant.user.nil?
      end
      emails
    end
  
  end