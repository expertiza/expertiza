RSpec.shared_context 'review bidding helpers', shared_context: :metadata do
    TOPIC_IDS = [5139, 5140, 5141, 5142].freeze

    def generate_bidding_data
      { 'tid' => TOPIC_IDS, 'users' => user_bidding_data, 'max_accepted_proposals' => 3 }
    end

    def reviewer_ids
      @reviewer_ids ||= [] # Ensure it's an array
    end

    def user_bidding_data
      reviewer_ids.map { |id| [id, generate_bids(TOPIC_IDS)] }.to_h
    end

    def generate_bids(topic_ids, time = Time.now)
      { 'bids' => topic_ids.map.with_index { |tid, i| format_bid(tid, i, time) }, 'otid' => nil }
    end

    def format_bid(topic_id, index, base_time)
      { 'tid' => topic_id, 'priority' => index + 1, 'timestamp' => (base_time + index * 2).strftime('%a, %d %b %Y %H:%M:%S %Z %:z') }
    end

    def mock_successful_request(response)
      allow(RestClient).to receive(:post).and_return(double(body: response.to_json))
    end

    def mock_failed_request
      allow(RestClient).to receive(:post).and_raise(StandardError, 'Service down')
      allow(Rails.logger).to receive(:error)
    end
end
