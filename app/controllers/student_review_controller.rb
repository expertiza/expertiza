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
    @review_mappings = @review_mappings.sort_by {|mapping| mapping.id % 5} if @assignment.is_calibrated == true
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
    @num_metareviews_total = @metareview_mappings.size
    @num_metareviews_completed = 0
    @metareview_mappings.each do |map|
      @num_metareviews_completed += 1 unless map.response.empty?
    end
    @num_metareviews_in_progress = @num_metareviews_total - @num_metareviews_completed
    @topic_id = SignedUpTeam.topic_id(@assignment.id, @participant.user_id)
    topic_list
  end

  # the method remove_nullteam_topics remove the topics that are not signed up by any teams
  def remove_nullteam_topics(old_array)
    new_array = []
    for j in (0..(old_array.length - 1)) do
      @signupteam = SignedUpTeam.where(topic_id = old_array[j].id).first
      if (@signupteam != [] and @signupteam.team_id != 0) then
        new_array.insert(-1, old_array[j])
      end
    end
    return new_array
  end

  # this method is used to show a submission list for students to bid when
  # the review strategy is "bidding"
  def topic_list
    # get the participant that's the reviewer for the assignment
    @participant = AssignmentParticipant.find(params[:id])
    my_bids = ReviewBid.get_bids_by_participant(@participant)
    @bids = []
    my_teams = TeamsUser.where(user_id: @participant.user_id).map(&:team_id)
    # if self-review is not allowed
    if !@assignment.is_selfreview_enabled
      my_bids.each do |bid|
        next if my_teams.include?(bid.team_id)
        @bids << bid
      end
    else
      @bids = my_bids
    end
  end

  # set the priority of review
  def set_priority
    @participant = AssignmentParticipant.find(params[:participant_id])
    @assignment = @participant.assignment
    assignment_id = @assignment.id
    bidding_teams = ReviewBid.where(participant_id: @participant.id).map(&:team_id)
    bidding_teams.each do |team|
      ReviewBid.where(team_id: team, participant_id: @participant.id).destroy_all
    end
    # Refresh with new priority
    params[:topic].each_with_index do |team_id, index|
      bid_existence = ReviewBid.where(team_id: team_id, participant_id: @participant.id)
      if bid_existence.empty?
        ReviewBid.create(team_id: team_id, participant_id: @participant.id, priority: index + 1)
      else
        ReviewBid.where(team_id: team_id, participant_id: @participant.id).update_all(priority: index + 1)
      end
    end
    redirect_to action: 'list', assignment_id: assignment_id
  end
end
