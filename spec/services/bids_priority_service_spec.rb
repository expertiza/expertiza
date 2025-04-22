require 'rails_helper'

describe BidsPriorityService do
  describe '.process_bids' do
    let(:assignment_id) { 1 }
    let(:participant_id) { 42 }
    let(:selected_topic_ids) { [1001, 1002, 1003] }
    let(:removed_topic_ids) { [1004, 1005] }

    context 'when processing bids' do
      before do
        # Stubbing destroy_all for removed topics
        removed_topic_ids.each do |topic_id|
          relation = double("ReviewBid::ActiveRecord_Relation")
          expect(ReviewBid).to receive(:where)
            .with(signuptopic_id: topic_id, participant_id: participant_id)
            .and_return(relation)
          expect(relation).to receive(:destroy_all)
        end

        # Stubbing find_or_initialize_by and save! for selected topics
        selected_topic_ids.each_with_index do |topic_id, index|
          bid = instance_double(ReviewBid)
          expect(ReviewBid).to receive(:find_or_initialize_by)
            .with(signuptopic_id: topic_id, participant_id: participant_id)
            .and_return(bid)

          expect(bid).to receive(:assignment_id=).with(assignment_id)
          expect(bid).to receive(:priority=).with(index + 1)
          expect(bid).to receive(:save!)
        end
      end

      it 'removes unselected bids and creates/updates selected bids with correct priority' do
        described_class.process_bids(
          assignment_id,
          participant_id,
          selected_topic_ids,
          removed_topic_ids
        )
      end
    end

    context 'when no topics are selected or removed' do
      it 'does nothing' do
        expect(ReviewBid).not_to receive(:where)
        expect(ReviewBid).not_to receive(:find_or_initialize_by)

        described_class.process_bids(
          assignment_id,
          participant_id,
          [],
          []
        )
      end
    end
  end
end
