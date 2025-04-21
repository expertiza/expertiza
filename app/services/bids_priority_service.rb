# Service Object for setting the priority of topic bids
class BidsPriorityService
  # Updates or creates ReviewBid records based on selected topics and removes unselected ones.
  # @param assignment_id [Integer] The ID of the assignment
  # @param participant_id [Integer] The ID of the participant
  # @param selected_topic_ids [Array<Integer>] The topic IDs the user has selected
  # @param removed_topic_ids [Array<Integer>] The topic IDs to be removed
  def self.process_bids(assignment_id, participant_id, selected_topic_ids, removed_topic_ids)
    # Remove unselected bids
    removed_topic_ids.each do |topic_id|
      ReviewBid.where(signuptopic_id: topic_id, participant_id: participant_id).destroy_all
    end

    # Add/update selected bids with new priorities
    selected_topic_ids.each_with_index do |topic_id, index|
      bid = ReviewBid.find_or_initialize_by(signuptopic_id: topic_id, participant_id: participant_id)
      bid.assignment_id = assignment_id
      bid.priority = index + 1
      bid.save!
    end
  end
end