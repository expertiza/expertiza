describe ReviewBiddingAlgorithmService do
  let(:service) { described_class }
  let(:assignment_id) { 1 }
  let(:reviewer_ids) { %w[45672 45673 45674 45675 45676 45677] }
  let(:bidding_data) { generate_bidding_data }
  let(:webservice_url) { 'http://example.com/review_bidding' }

  before do
    allow(Rails.application).to receive(:config_for).with(:webservices).and_return({ 'review_bidding_webservice_url' => webservice_url })
    allow(ReviewBid).to receive(:bidding_data).with(assignment_id, reviewer_ids).and_return(bidding_data)
  end

  describe '#run_bidding_algorithm' do
    context 'when the web service is available' do
      let(:expected_response) { { '45672' => [5139, 5140], '45673' => [5141, 5142] } }

      before do
        allow(RestClient).to receive(:post).and_return(double(body: expected_response.to_json))
      end

      it 'sends the request and returns the matched topics' do
        result = service.run_bidding_algorithm(bidding_data)
        expect(result).to eq(expected_response)
      end
    end

    context 'when the web service is unavailable' do
      before do
        allow(RestClient).to receive(:post).and_raise(StandardError.new('Service down'))
        allow(Rails.logger).to receive(:error)
      end

      it 'logs an error and returns false' do
        result = service.run_bidding_algorithm(bidding_data)
        expect(result).to be false
        expect(Rails.logger).to have_received(:error).with(/Error in run_bidding_algorithm: Service down/)
      end
    end
  end

  describe '#process_bidding' do
    context 'when the web service succeeds' do
      let(:matched_topics) { { '45672' => [5139, 5140], '45673' => [5141, 5142] } }

      before do
        allow(service).to receive(:run_bidding_algorithm).and_return(matched_topics)
      end

      it 'returns the matched topics' do
        result = service.process_bidding(assignment_id, reviewer_ids)
        expect(result).to eq(matched_topics)
      end
    end

    context 'when the web service fails' do
      let(:fallback_matched_topics) { { '45672' => [5139], '45673' => [5140] } }

      before do
        allow(service).to receive(:run_bidding_algorithm).and_return(false)
        allow(ReviewBid).to receive(:fallback_algorithm).with(assignment_id, reviewer_ids).and_return(fallback_matched_topics)
        allow(Rails.logger).to receive(:error)
      end

      it 'logs an error and uses the fallback algorithm' do
        result = service.process_bidding(assignment_id, reviewer_ids)
        expect(result).to eq(fallback_matched_topics)
        expect(Rails.logger).to have_received(:error).with(/Web service unavailable. Using fallback algorithm./)
      end
    end
  end

  def generate_bidding_data
    {
      'tid' => [5139, 5140, 5141, 5142],
      'users' => user_bidding_data,
      'max_accepted_proposals' => 3
    }
  end

  def user_bidding_data
    {
      '45672' => generate_bids([5139, 5140, 5141, 5142], base_time: 'Wed, 19 Mar 2025 20:46:08 EDT -04:00'),
      '45673' => generate_bids([5139, 5140, 5141, 5142], base_time: 'Wed, 19 Mar 2025 20:46:08 EDT -04:00'),
      '45674' => generate_bids([5140, 5139, 5141, 5142], base_time: 'Wed, 19 Mar 2025 20:47:20 EDT -04:00'),
      '45675' => generate_bids([5139, 5140], base_time: 'Wed, 19 Mar 2025 20:47:58 EDT -04:00'),
      '45676' => generate_bids([5139, 5140, 5141], base_time: 'Wed, 19 Mar 2025 20:50:18 EDT -04:00'),
      '45677' => generate_bids([5139, 5140, 5141], base_time: 'Wed, 19 Mar 2025 20:50:18 EDT -04:00')
    }
  end

  def generate_bids(topic_ids, base_time:)
    time = Time.parse(base_time)
    {
      'bids' => topic_ids.each_with_index.map do |tid, index|
        {
          'tid' => tid,
          'priority' => index + 1,
          'timestamp' => (time + (index * 2)).strftime('%a, %d %b %Y %H:%M:%S %Z %:z')
        }
      end,
      'otid' => nil
    }
  end
end
