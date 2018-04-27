class AwardedBadge < ActiveRecord::Base
  belongs_to :badge
  belongs_to :participant

  # Called from response_controller.rb and review_mapping_controller for GoodTeammate and GoodReviewer Badges respectively
  # Also handles score updates (deleting assigned badges if no longer valid)
  def self.award(participant_id, score, assignment_badge_threshold, badge_id)
    assignment_badge_threshold ||= 95
    AwardedBadge.create(participant_id: participant_id, badge_id: badge_id) if score and score >= assignment_badge_threshold
  end

  #Called when badge is assigned manually
  def self.award_manually(participant_id,badge_id)
    AwardedBadge.create()
  end

  # When threshold is created/updated in Assignment edit page
  # Populate/Repopulate AwardedBadges
  def self.award_good_reviewer_badge(assignment_id)
    participants = AssignmentParticipant.where(parent_id: assignment_id)
    badge_id = Badge.get_id_from_name('Good Reviewer')
    AwardedBadge.where(participant_id: participants.ids, badge_id: badge_id).delete_all
    review_grades = ReviewGrade.where(participant_id: participants.ids)
    assignment_badge = AssignmentBadge.find_by(badge_id: badge_id, assignment_id: assignment_id)
    review_grades.each do |review_grade|
      AwardedBadge.award(review_grade.participant_id, review_grade.grade_for_reviewer, assignment_badge.try(:threshold), badge_id)
    end
  end

  def self.award_good_teammate_badge(assignment_id)
    participants = AssignmentParticipant.where(parent_id: assignment_id)
    badge_id = Badge.get_id_from_name('Good Teammate')
    AwardedBadge.where(participant_id: participants.ids, badge_id: badge_id).delete_all
    assignment_badge = AssignmentBadge.find_by(badge_id: badge_id, assignment_id: assignment_id)
    participants.each do |p|
      score = AwardedBadge.get_teammate_review_score(p)
      AwardedBadge.award(p.id, score, assignment_badge.try(:threshold), badge_id)
    end
  end

  def self.get_teammate_review_score(participant)
    score = 0.0
    return score if participant.nil? or participant.team.nil?
    teammate_reviews = participant.teammate_reviews
    return score if teammate_reviews.empty?
    teammate_reviews.each do |teammate_review|
      score += (teammate_review.total_score.to_f / teammate_review.maximum_score.to_f)
    end
    score / teammate_reviews.size * 100
  end
end
