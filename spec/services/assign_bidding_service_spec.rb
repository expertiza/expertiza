require 'rails_helper'

describe AssignBiddingService do
  # === Shared Context ===
  let(:assignment) { instance_double(Assignment, id: 1) }
  let(:reviewer_ids) { [101, 102] }
  let(:valid_topics) { { "101" => [1], "102" => [2] } }
  let(:fallback_topics) { { "101" => [3], "102" => [4] } }
  let(:invalid_topics) { { "101" => [], "102" => [5] } }

  before do
    allow(Assignment).to receive(:find).with(assignment.id).and_return(assignment)
    allow(assignment).to receive(:update!).with(can_choose_topic_to_review: false)

    allow(AssignmentParticipant).to receive(:where).with(parent_id: assignment.id)
      .and_return(double(pluck: reviewer_ids))
  end

  # === Tests ===
  describe '.call_by_assignment' do
    context 'when external service succeeds' do
      before do
        allow(BidsAlgorithmService).to receive(:process_bidding)
          .with(assignment.id, reviewer_ids)
          .and_return(success: true, data: valid_topics)

        allow(ReviewBid).to receive(:assign_review_topics)
      end

      it 'successfully assigns review topics and updates the assignment' do
        result = described_class.call_by_assignment(assignment.id)

        expect(result.success?).to be true
        expect(result.error_message).to be_nil
        expect(ReviewBid).to have_received(:assign_review_topics)
          .with(assignment.id, reviewer_ids, valid_topics)
        expect(assignment).to have_received(:update!).with(can_choose_topic_to_review: false)
      end
    end

    context 'when external service fails and fallback is used' do
      before do
        allow(BidsAlgorithmService).to receive(:process_bidding)
          .with(assignment.id, reviewer_ids)
          .and_return(success: false, error: 'Service Down')

        allow(ReviewBid).to receive(:fallback_algorithm)
          .with(assignment.id, reviewer_ids)
          .and_return(fallback_topics)

        allow(ReviewBid).to receive(:assign_review_topics)
      end

      it 'uses fallback and still succeeds' do
        result = described_class.call_by_assignment(assignment.id)

        expect(result.success?).to be true
        expect(result.error_message).to be_nil
        expect(ReviewBid).to have_received(:assign_review_topics)
          .with(assignment.id, reviewer_ids, fallback_topics)
      end
    end

    context 'when a reviewer has no topics assigned' do
      before do
        allow(BidsAlgorithmService).to receive(:process_bidding)
          .with(assignment.id, reviewer_ids)
          .and_return(success: true, data: invalid_topics)
      end

      it 'fails with an error about invalid topic assignments' do
        result = described_class.call_by_assignment(assignment.id)

        expect(result.success?).to be false
        expect(result.error_message).to match(/Invalid topic assignments/)
      end
    end

    context 'when an unexpected exception occurs' do
      before do
        allow(BidsAlgorithmService).to receive(:process_bidding)
          .and_raise(StandardError.new('Something went wrong'))
      end

      it 'returns a failure result with the error message' do
        result = described_class.call_by_assignment(assignment.id)

        expect(result.success?).to be false
        expect(result.error_message).to eq('Something went wrong')
      end
    end
  end
end
