# app/mailers/mail_worker.rb
require 'sidekiq'

class MailWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'mailers'

  attr_accessor :assignment_id, :deadline_type, :due_at

  def perform(assignment_id, deadline_type, due_at)
    self.assignment_id = assignment_id
    self.deadline_type = deadline_type
    self.due_at = due_at

    assignment = Assignment.find(self.assignment_id)
    participant_mails = find_participant_emails

    if %w[drop_one_member_topics drop_outstanding_reviews compare_files_with_simicheck].include?(self.deadline_type)
      handle_special_cases(assignment)
    else
      deadline_text = self.deadline_type == 'metareview' ? 'teammate review' : self.deadline_type
      AssignmentReminderMailer.reminder_email(assignment, participant_mails, deadline_text, due_at) unless participant_mails.empty?
    end
  end

  private

  def handle_special_cases(assignment)
    drop_one_member_topics if self.deadline_type == 'drop_outstanding_reviews' && assignment.team_assignment
    drop_outstanding_reviews if self.deadline_type == 'drop_outstanding_reviews'
    perform_simicheck_comparisons(self.assignment_id) if self.deadline_type == 'compare_files_with_simicheck'
  end

  def find_participant_emails
    Participant.where(parent_id: assignment_id).map { |p| p.user&.email }.compact
  end

  def drop_one_member_teams
    teams = TeamsUser.all.group(:team_id).count(:team_id)
    teams.keys.each do |team_id|
      if teams[team_id] == 1
        topic_to_drop = SignedUpTeam.find_by(team_id: team_id)
        topic_to_drop&.delete
      end
    end
  end

  def drop_outstanding_reviews
    reviews = ResponseMap.where(reviewed_object_id: assignment_id)
    reviews.each do |review|
      review_to_drop = ResponseMap.find_by(id: review.id) if Response.where(map_id: review.id).empty?
      review_to_drop&.destroy
    end
  end

  def perform_simicheck_comparisons(assignment_id)
    PlagiarismCheckerHelper.run(assignment_id)
  end
end
