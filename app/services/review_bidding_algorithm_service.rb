  # app/services/review_bids_service.rb
  class ReviewBiddingAlgorithmService
  # call webserver for running assigning algorithm
  # passing webserver: student_ids, topic_ids, student_preferences, time_stamps
  # webserver returns:
  # returns matched assignments as json body
  def self.run_bidding_algorithm(bidding_data)
    # Load the URL from the configuration file
    config = Rails.application.config_for(:webservices)
    url = config['review_bidding_webservice_url']
    Rails.logger.debug "URL: #{url}"
    response = RestClient.post url, bidding_data.to_json, content_type: 'application/json', accept: :json
    Rails.logger.debug "bidding_data: #{bidding_data.to_json}"
    Rails.logger.debug "Response body: #{JSON.parse(response.body)}"
    JSON.parse(response.body)
  rescue StandardError
    false
    # end
  end
end