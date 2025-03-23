# app/services/review_bids_service.rb
class ReviewBiddingAlgorithmService
  # Runs the review bidding algorithm by sending data to the web service
  # @param bidding_data [Hash] The data required for the bidding algorithm
  # @return [Hash, false] The matched assignments as a JSON object, or false if an error occurs
  def self.run_bidding_algorithm(bidding_data)
    config = Rails.application.config_for(:webservices)
    url = config['review_bidding_webservice_url']
    Rails.logger.debug "Review Bidding Webservice URL: #{url}"

    begin
      response = RestClient.post(
        url,
        bidding_data.to_json,
        content_type: 'application/json',
        accept: :json
      )
      Rails.logger.debug "Bidding Data Sent: #{bidding_data.to_json}"
      Rails.logger.debug "Response Body: #{response.body}"
      JSON.parse(response.body)
    rescue StandardError => e
      Rails.logger.error "Error in run_bidding_algorithm: #{e.message}"
      false
    end
  end
end