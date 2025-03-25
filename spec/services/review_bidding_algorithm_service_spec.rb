describe ReviewBiddingAlgorithmService do
  let(:service) { described_class }
  let(:assignment_id) { 1 }
  let(:reviewer_ids) { %w[45672 45673 45674 45675 45676 45677] }
  let(:bidding_data) { generate_bidding_data }
  let(:webservice_url) { 'http://example.com/review_bidding' }

  before do
    allow(Rails.application).to receive(:config_for).with(:webservices)
      .and_return('review_bidding_webservice_url' => webservice_url)
    allow(ReviewBid).to receive(:bidding_data).with(assignment_id, reviewer_ids)
      .and_return(bidding_data)
  end

  describe '#run_bidding_algorithm' do
    context 'when the web service is available' do
      let(:expected_response) { { '45672' => [5139, 5140], '45673' => [5141, 5142] } }

      before { mock_successful_request(expected_response) }

      it 'sends the request and returns the matched topics' do
        expect(service.run_bidding_algorithm(bidding_data)).to eq(expected_response)
      end
    end

    context 'when the web service is unavailable' do
      before { mock_failed_request }

      it 'logs an error and returns false' do
        expect(service.run_bidding_algorithm(bidding_data)).to be false
        expect(Rails.logger).to have_received(:error)
          .with(/Error in run_bidding_algorithm: Service down/)
      end
    end
  end

  # Helper Methods
  def generate_bidding_data
    {
      'tid' => [5139, 5140, 5141, 5142],
      'users' => user_bidding_data,
      'max_accepted_proposals' => 3
    }
  end

  def user_bidding_data
    reviewer_ids.map { |id| [id, generate_bids([5139, 5140, 5141, 5142], base_time: 'Wed, 19 Mar 2025 20:46:08 EDT -04:00')] }.to_h
  end

  def generate_bids(topic_ids, base_time:)
    time = Time.parse(base_time)
    { 'bids' => topic_ids.each_with_index.map { |tid, index| format_bid(tid, index, time) }, 'otid' => nil }
  end

  def format_bid(topic_id, index, base_time)
    {
      'tid' => topic_id,
      'priority' => index + 1,
      'timestamp' => (base_time + (index * 2)).strftime('%a, %d %b %Y %H:%M:%S %Z %:z')
    }
  end

  def mock_successful_request(response)
    allow(RestClient).to receive(:post).and_return(double(body: response.to_json))
  end

  def mock_failed_request
    allow(RestClient).to receive(:post).and_raise(StandardError.new('Service down'))
    allow(Rails.logger).to receive(:error)
  end
end
