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

  # This method removes_nullteam_topics remove the topics that are not signed up by any teams
  def remove_nullteam_topics(old_array)
    new_array = []
    for j in (0..(old_array.length-1)) do
      @signupteam = SignedUpTeam.where(topic_id = old_array[j].id).first
      if (@signupteam != [] and @signupteam.team_id != 0) then
        new_array.insert(-1, old_array[j])
      else
      end
    end
    return new_array
  end

  # this method gives the following global variables: @topics, that are the topics that are unchosen for the reviewer;
  # @selectedtopics, topics that are selected by the reviewer that he wants to review;
  # @unselectedtopics, topics that remains at the left of the view, that are not yet chosen by the reviewer.
  def sign_up_list
    # get the participant that's the reviewer for the assignment
    @participant = AssignmentParticipant.find(params[:id])
    # The assignment that should be reviewed is here
    @assignment = @participant.assignment
    # get the original topics that are under the assignment.
    @rawtopics = SignUpTopic.where(assignment_id: @assignment.id)
    @topics = remove_nullteam_topics(@rawtopics)
    # Here are the selected topics that are sorted by priority
    @reviewbids = @participant.id.nil? ? [] : ReviewBid.where(participant_id: @participant.id).order(:priority)
    # extract topic ids from the @reviewbids
    selected_topicids = []
    for i in (0..(@reviewbids.length-1)) do
      selected_topicids[i] = @reviewbids[i].topic_id
    end

    @selectedtopics= []
    @unselectedtopics = []
    # according to the topic id list, create the topic list of selected topics.
    # those that are not selected from the @topics list are unselected topics
    for j in (0..(@topics.length-1)) do
      if selected_topicids.include?(@topics[j].id) then
        @selectedtopics.insert(-1, @topics[j])
      else
        @unselectedtopics.insert(-1, @topics[j])
      end
    end
  end

  # E1856. Allow reviewers to bid on what to review (Reused as a part of E1928)
  # This method is responsible for setting the priority of the Review Bids and then redirects to the list method of
  # student_review_controller
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
