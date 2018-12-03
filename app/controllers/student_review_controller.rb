class StudentReviewController < ApplicationController

  def action_allowed?
    ['Instructor',
     'Teaching Assistant',
     'Administrator',
     'Super-Administrator',
     'Student'].include? current_role_name and
    ((%w[list].include? action_name) ? are_needed_authorizations_present?(params[:id], "submitter") : true)
  end

  def list
    @participant = AssignmentParticipant.find(params[:id])
    return unless current_user_id?(@participant.user_id)
    @assignment = @participant.assignment
    # Find the current phase that the assignment is in.
    @topic_id = SignedUpTeam.topic_id(@participant.parent_id, @participant.user_id)
    @review_phase = @assignment.get_current_stage(@topic_id)
    # ACS Removed the if condition(and corressponding else) which differentiate assignments as team and individual assignments
    # to treat all assignments as team assignments

    @review_mappings = ReviewResponseMap.where(reviewer_id: @participant.id)
    # if it is an calibrated assignment, change the response_map order in a certain way
    @review_mappings = @review_mappings.sort_by {|mapping| mapping.id % 5 } if @assignment.is_calibrated == true
    @metareview_mappings = MetareviewResponseMap.where(reviewer_id: @participant.id)
    # Calculate the number of reviews that the user has completed so far.

    @num_reviews_total = @review_mappings.size
    # Add the reviews which are requested and not began.
    @num_reviews_completed = 0
    @review_mappings.each do |map|
      @num_reviews_completed += 1 if !map.response.empty? && map.response.last.is_submitted
    end

    @num_reviews_in_progress = @num_reviews_total - @num_reviews_completed
    # Calculate the number of metareviews that the user has completed so far.
    @num_metareviews_total       = @metareview_mappings.size
    @num_metareviews_completed   = 0
    @metareview_mappings.each do |map|
      @num_metareviews_completed += 1 unless map.response.empty?
    end
    @num_metareviews_in_progress = @num_metareviews_total - @num_metareviews_completed
    @topic_id = SignedUpTeam.topic_id(@assignment.id, @participant.user_id)
  end
  # expertiza project: E1856. Allow reviewers to bid on what to review
  def set_priority
    participant = AssignmentParticipant.find_by(id: params[:participant_id])
    if params[:topic].nil?
      # All topics are deselected by current participant
      ReviewBid.where(participant_id: participant.id).destroy_all
    else
      assignment_id = SignUpTopic.find(params[:topic].first).assignment.id
      @bids = ReviewBid.where(participant_id: participant.id)
      signed_up_topics = ReviewBid.where(participant_id: participant.id).map(&:topic_id)
      # Remove topics from bids table if the student moves data from Selection table to Topics table
      # This step is necessary to avoid duplicate priorities in Bids table
      signed_up_topics -= params[:topic].map(&:to_i)
      signed_up_topics.each do |topic|
        ReviewBid.where(topic_id: topic, participant_id: participant.id).destroy_all
      end
      params[:topic].each_with_index do |topic_id, index|
        bid_existence = ReviewBid.where(topic_id: topic_id, participant_id: participant.id)
        if bid_existence.empty?
          ReviewBid.create(topic_id: topic_id, participant_id: participant.id, priority: index + 1)
        else
          ReviewBid.where(topic_id: topic_id, participant_id: participant.id).update_all(priority: index + 1)
        end
      end
    end
    redirect_to action: 'list', assignment_id: params[:assignment_id]
  end
end
