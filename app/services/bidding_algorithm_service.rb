# frozen_string_literal: true

# The `BiddingAlgorithmService` run the bid assignment algorithm
# Sends student IDs, topic IDs, student preferences, and timestamps to the web service
# The web service returns the matched assignments in the JSON response body
class BiddingAlgorithmService
  SERVICE_URL = 'http://app-csc517.herokuapp.com/match_topics'.freeze

  # MOCK_DATA is based on the documentation detailing how the webservice behaves.
  # Reference: https://wiki.expertiza.ncsu.edu/index.php?title=CSC/ECE_517_Fall_2020_-_E2085._Allow_reviewers_to_bid_on_what_to_review#Webservice
  MOCK_DATA = {
    36239 => [3970, 3972, 3975],
    36240 => [3973, 3974, 3972],
    36241 => [3969, 3971, 3972],
    36242 => [3969, 3971, 3973],
    36243 => [3969, 3970, 3971]
  }.freeze

  def initialize(bidding_data)
    @bidding_data = bidding_data
  end

  def run
    return MOCK_DATA if Rails.application.config.use_mock_bidding_algorithm

    perform_request
  rescue RestClient::ExceptionWithResponse, JSON::ParserError
    false
  end

  private

  def perform_request
    response = RestClient.post(
      SERVICE_URL,
      @bidding_data.to_json,
      content_type: :json,
      accept: :json
    )

    validate_response(response)
    JSON.parse(response.body)
  end

  def validate_response(response)
    raise 'Invalid response format' unless response.headers[:content_type] && response.headers[:content_type].include?('application/json')
  end
end
