require 'rails_helper'

describe MCPReviewService do
  describe '#send_peer_review' do
    it 'sends the selected canonical response ids for the assignment' do
      mcp_client = instance_double(MCPServerClient)
      service = described_class.new(mcp_client: mcp_client)
      assignment_id = 101
      first_payload = { response_id_of_expertiza: 11 }
      second_payload = { response_id_of_expertiza: 22 }

      allow(Response).to receive(:latest_submitted_review_response_ids_for_assignment)
        .with(assignment_id)
        .and_return([11, 22])
      allow(service).to receive(:find_response).with(11).and_return(first_payload)
      allow(service).to receive(:find_response).with(22).and_return(second_payload)
      allow(mcp_client).to receive(:send_review)

      service.send_peer_review(assignment_id: assignment_id)

      expect(mcp_client).to have_received(:send_review).with(first_payload).once
      expect(mcp_client).to have_received(:send_review).with(second_payload).once
    end
  end
end
