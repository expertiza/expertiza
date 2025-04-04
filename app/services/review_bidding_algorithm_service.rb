# Service for running the review bidding algorithm.
# This class interacts with an external web service to send and receive bidding data
class ReviewBiddingAlgorithmService
  # Runs the review bidding algorithm by sending data to the web service
  # @param bidding_data [Hash] The data required for the bidding algorithm
  # @return [Hash, false] The matched assignments as a JSON object, or false if an error occurs
  def self.run_bidding_algorithm(bidding_data)
    url = Rails.application.config_for(:webservices)['review_bidding_webservice_url']
    Rails.logger.debug "Review Bidding Webservice URL: #{url}"
    send_bidding_request(url, bidding_data) # Ensures result is returned
  end

  # Runs the bidding algorithm with the given assignment_id and reviewer_ids
  def self.process_bidding(assignment_id, reviewer_ids)
    bidding_data = ReviewBid.bidding_data(assignment_id, reviewer_ids)
    matched_topics = run_bidding_algorithm(bidding_data)
    # If the external service fails, use the fallback algorithm
    if matched_topics == false
      Rails.logger.error 'Web service unavailable. Using fallback algorithm.'
      matched_topics = ReviewBid.fallback_algorithm(assignment_id, reviewer_ids)
    end
    matched_topics
  end

  private_class_method def self.send_bidding_request(url, bidding_data)
    response = RestClient.post(url, bidding_data.to_json, content_type: 'application/json', accept: :json)
    JSON.parse(response.body)
  rescue StandardError => e
    Rails.logger.error "Error in run_bidding_algorithm: #{e.message}"
    false
  end
end
