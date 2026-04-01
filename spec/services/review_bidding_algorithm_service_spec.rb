require 'rails_helper'

describe ReviewBiddingAlgorithmService do
  include_context 'review bidding helpers'

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
      before { mock_successful_request('45672' => [5139, 5140], '45673' => [5141, 5142]) }
      it { expect(service.run_bidding_algorithm(bidding_data)).to eq('45672' => [5139, 5140], '45673' => [5141, 5142]) }
    end

    context 'when the web service is unavailable' do
      before { mock_failed_request }
      it do
        expect(service.run_bidding_algorithm(bidding_data)).to be false
        expect(Rails.logger).to have_received(:error).with(/Error in run_bidding_algorithm: Service down/)
      end
    end
  end
end
