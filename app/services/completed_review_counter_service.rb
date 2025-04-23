# Service for counting completed reviews
# This service class counts reviews for the index method of review_bids_controller to reduce bloat of the function.
class CompletedReviewCounterService
  # Runs the review bidding algorithm by sending data to the web service
  # @param reviews [Array] The array of reviews.
  # @return [int] The number of completed reviews.
  def self.count_reviews(reviews)
    num_reviews_completed = 0
    reviews.each do |map|
      if map.response.any? && map.response.last.is_submitted
        num_reviews_completed += 1
      end
    end
    num_reviews_completed
  end
end
