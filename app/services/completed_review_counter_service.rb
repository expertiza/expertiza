# Service for counting completed reviews
# This service class counts reviews for the index method of review_bids_controller to reduce bloat of the function.
class CompletedReviewCounterServic
  # Runs the review bidding algorithm by sending data to the web service
  # @param bidding_data [Hash] The data required for the bidding algorithm
  # @return [Hash, false] The matched assignments as a JSON object, or false if an error occurs
  def self.count_reviews(reviews)
    reviews.each do |map|
      num_reviews_completed += 1 if !map.response.empty? && map.response.last.is_submitted
    num_reviews_completed
    end
  end
end