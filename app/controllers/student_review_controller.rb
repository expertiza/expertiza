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
    # we can assume the id is of the current user and for the participant
    # if the assignment has team reviewers, other controllers take care of getting the team from this object
    @participant = AssignmentParticipant.find(params[:id])
    return unless current_user_id?(@participant.user_id)
    @assignment = @participant.assignment
    # Find the current phase that the assignment is in.
    @topic_id = SignedUpTeam.topic_id(@participant.parent_id, @participant.user_id)
    @review_phase = @assignment.get_current_stage(@topic_id)
    # E-1973 calling get_reviewer on a participant will return either that participant
    # or there team, depending on if reviewers are teams. If the reviewer is not yet on a team, just set review_mappings
    # to an empty list to prevent errors
    if @participant.get_reviewer != nil
      # ACS Removed the if condition(and corressponding else) which differentiate assignments as team and individual assignments
      # to treat all assignments as team assignments
      @review_mappings = ReviewResponseMap.where(reviewer_id: @participant.get_reviewer.id, reviewer_is_team: @assignment.reviewer_is_team)
    else
      @review_mappings = []
    end
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

    @all_assignments = SampleReview.where(:assignment_id => @assignment.id)
    @response_ids = []
    @all_assignments.each do |assignment|
        @response_ids << assignment.response_id
    end
  end
end
