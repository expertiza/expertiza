# frozen_string_literal: true

# The `ReviewService` class encapsulates the business logic related to managing
# review mappings for a given participant and their associated assignment.
class ReviewService
  attr_reader :participant, :assignment, :reviewer

  def initialize(participant)
    @participant = participant
    @assignment = participant.assignment
    @reviewer = fetch_reviewer
  end

  def review_mappings
    return ReviewResponseMap.none unless @reviewer

    ReviewResponseMap.where(
      reviewer_id: @reviewer.id,
      team_reviewing_enabled: @assignment.team_reviewing_enabled
    )
  end

  def sorted_review_mappings
    mappings = review_mappings
    mappings = mappings.sort_by { |mapping| mapping.id % 5 } if @assignment.is_calibrated
    mappings
  end

  def review_counts
    total_reviews = sorted_review_mappings.size
    completed_reviews = sorted_review_mappings.count { |map| map.response.present? && map.response.last.is_submitted }
    in_progress_reviews = total_reviews - completed_reviews
    { total: total_reviews, completed: completed_reviews, in_progress: in_progress_reviews }
  end

  def response_ids
    SampleReview.where(assignment_id: @assignment.id).pluck(:response_id)
  end

  private

  def fetch_reviewer
    @participant.get_reviewer
  end
end
