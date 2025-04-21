# Service for running the review bidding algorithm.
# This class interacts with an external web service to send and receive bidding data
class BidsAlgorithmService
  # Runs the review bidding algorithm by sending data to the web service
  # @param bidding_data [Hash] The data required for the bidding algorithm
  # @return [Hash, false] The matched assignments as a JSON object, or false if an error occurs
  def self.run_bidding_algorithm(bidding_data)
    url = Rails.application.config_for(:webservices)['review_bidding_webservice_url']
    Rails.logger.debug "Review Bidding Webservice URL: #{url}"
    send_bidding_request(url, bidding_data) # Ensures result is returned
  end

  # Runs the review bidding algorithm by sending data to the web service
  # @param assignment_id [int] The id of the assignment currently being interacted with
  # @param reviewer_ids [Array] A list of reviewer IDs that are associated with the users bidding
  # @return [Hash] The data required for the bidding algorithm
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
    # Send request to the bidding service with a 10s timeout
    response = RestClient.post(url, bidding_data.to_json, content_type: 'application/json', accept: :json, timeout: 10)
    parsed_json = JSON.parse(response.body)
    { success: true, data: parsed_json, error: nil }
  rescue StandardError => e
    Rails.logger.error "Error in run_bidding_algorithm: #{e.message}"
    { success: false, data: nil, error: e.message }
  end
end
