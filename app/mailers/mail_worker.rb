require 'sidekiq'

class MailWorker
  include Sidekiq::Worker
  # ActionMailer in Rail 4 submits jobs in mailers queue instead of default queue. Rails 5 and onwards
  # ActionMailer will submit mailer jobs to default queue. We need to remove the line below in that case!
  sidekiq_options queue: 'mailers'
  attr_accessor :assignment_id
  attr_accessor :deadline_type
  attr_accessor :due_at

  def perform(assignment_id, deadline_type, due_at)
    self.assignment_id = assignment_id
    self.deadline_type = deadline_type
    self.due_at = due_at

    assignment = Assignment.find(self.assignment_id)
    participant_mails = find_participant_emails

    if %w[drop_one_member_topics drop_outstanding_reviews compare_files_with_simicheck].include?(self.deadline_type)
      drop_one_member_topics if self.deadline_type == "drop_outstanding_reviews" && assignment.team_assignment
      drop_outstanding_reviews if self.deadline_type == "drop_outstanding_reviews"
      perform_simicheck_comparisons(self.assignment_id) if self.deadline_type == "compare_files_with_simicheck"
    else
      # Can we rename deadline_type(metareview) to "teammate review". If, yes then we donot need this if clause below!
      deadlineText = if self.deadline_type == "metareview"
                       "teammate review"
                     else
                       self.deadline_type
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

    @mail = Mailer.delayed_message(bcc: emails, subject: subject, body: body)
    @mail.deliver_now
  end

  def find_participant_emails
    emails = []
    participants = Participant.where(parent_id: self.assignment_id)
    participants.each do |participant|
      emails << participant.user.email unless participant.user.nil?
    end
    emails
  end

  def drop_one_member_topics
    teams = TeamsUser.all.group(:team_id).count(:team_id)
    teams.keys.each do |team_id|
      if teams[team_id] == 1
        topic_to_drop = SignedUpTeam.where(team_id: team_id).first
        topic_to_drop.delete if topic_to_drop # check if the one-person-team has signed up a topic
      end
    end
  end

  def drop_outstanding_reviews
    reviews = ResponseMap.where(reviewed_object_id: self.assignment_id)
    reviews.each do |review|
      review_has_began = Response.where(map_id: review.id)
      if review_has_began.size.zero?
        review_to_drop = ResponseMap.where(id: review.id)
        review_to_drop.first.destroy
      end
    end
  end

  def perform_simicheck_comparisons(assignment_id)
    PlagiarismCheckerHelper.run(assignment_id)
  end
end
