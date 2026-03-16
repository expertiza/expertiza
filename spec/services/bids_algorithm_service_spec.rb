require 'rails_helper'

describe BidsAlgorithmService do
  include_context 'review bidding helpers'

  let(:service) { described_class }
  let(:assignment_id) { 1 }
  let(:reviewer_ids) { %w[45672 45673] }
  let(:bidding_data) { generate_bidding_data }
  let(:webservice_url) { 'http://example.com/review_bidding' }
  let(:response_data) { { '45672' => [5139, 5140], '45673' => [5141, 5142] } }

  before do
    allow(Rails.application).to receive(:config_for).with(:webservices)
  .and_return('review_bidding_webservice_url' => webservice_url)
    allow(ReviewBid).to receive(:bidding_data).with(assignment_id, reviewer_ids)
                                              .and_return(bidding_data)
  end

  describe '#run_bidding_algorithm' do
    context 'when the web service is available' do
      before do
        allow(RestClient).to receive(:post)
          .with(webservice_url, bidding_data.to_json, content_type: 'application/json', accept: :json, timeout: 10)
  .and_return(double(body: response_data.to_json))
      end

      it 'returns success true and parsed data' do
        result = service.run_bidding_algorithm(bidding_data)
        expect(result).to eq({ success: true, data: response_data, error: nil })
      end
    end

    context 'when the web service is unavailable' do
      before do
        allow(RestClient).to receive(:post).and_raise(RestClient::Exception.new('Service down'))
        allow(Rails.logger).to receive(:error)
      end

      it 'returns success false and logs the error' do
        result = service.run_bidding_algorithm(bidding_data)

        expect(result[:success]).to be false
        expect(result[:data]).to be_nil
        expect(result[:error]).to eq('RestClient::Exception') # Actual .message from the mock
        expect(Rails.logger).to have_received(:error).with(/Error in run_bidding_algorithm: RestClient::Exception/)
      end
    end
  end

  describe '#process_bidding' do
    context 'when web service succeeds' do
      let(:matched_topics) { { '45672' => [5139, 5140], '45673' => [5141, 5142] } }
  
      before do
        allow(service).to receive(:run_bidding_algorithm).with(bidding_data).and_return(matched_topics)
      end
  
      it 'returns the matched topics from the service' do
        result = service.process_bidding(assignment_id, reviewer_ids)
        expect(result).to eq(matched_topics)
      end
    end
  
    context 'when web service fails and fallback is used' do
      let(:fallback_result) { { '45672' => [9999], '45673' => [8888] } }
  
      before do
        allow(service).to receive(:run_bidding_algorithm).with(bidding_data).and_return(false)
        allow(ReviewBid).to receive(:fallback_algorithm)
  .with(assignment_id, reviewer_ids)
  .and_return(fallback_result)
        allow(Rails.logger).to receive(:error)
      end
  
      it 'logs the error and returns fallback matched topics' do
        result = service.process_bidding(assignment_id, reviewer_ids)
        expect(result).to eq(fallback_result)
        expect(Rails.logger).to have_received(:error).with('Web service unavailable. Using fallback algorithm.')
      end
    end
  end
end
