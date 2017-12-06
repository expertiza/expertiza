class StudentReviewController < ApplicationController
  def action_allowed?
    ['Instructor',
     'Teaching Assistant',
     'Administrator',
     'Super-Administrator',
     'Student'].include? current_role_name and
    ((%w(list).include? action_name) ? are_needed_authorizations_present?(params[:id], "submitter") : true)
  end

  def list
    @participant = AssignmentParticipant.find(params[:id])
    return unless current_user_id?(@participant.user_id)
    @assignment = @participant.assignment
    # Find the current phase that the assignment is in.
    @topic_id = SignedUpTeam.topic_id(@participant.parent_id, @participant.user_id)
    @review_phase = @assignment.get_current_stage(@topic_id)
    # Based on first submission due date, the view is rendered. When current time exceeds this date, peer reviews start displaying
    @first_submission_due_date = AssignmentDueDate.where(parent_id: @assignment.id, deadline_type_id: '1').first.due_at
    # ACS Removed the if condition(and corressponding else) which differentiate assignments as team and individual assignments
    # to treat all assignments as team assignments
    @peer_reviews = []
    # If assignment is calibrated, all reviews performed before calibration due date are assigned to calibration reviews
    if @assignment.is_calibrated?
      @calibration_reviews = []
      calibration_due_date = AssignmentDueDate.where(parent_id: @assignment.id, deadline_type_id: '12').last.due_at
      if Time.now <= calibration_due_date
        @calibration_reviews = ReviewResponseMap.where(reviewer_id: @participant.id)
      else
        # When current time exceeds calibration due date, the reviews are segregated based on the time of creation
        @review_mappings = ReviewResponseMap.where(reviewer_id: @participant.id)
        @review_mappings.each do |review_map|
          if review_map.created_at <= calibration_due_date
            @calibration_reviews << review_map
          else
            @peer_reviews << review_map
          end
        end
      end
      @calibration_reviews = @calibration_reviews.sort_by {|mapping| mapping.id % 5 }
    else
      # If assignment is not calibrated, all reviews are considered as peer erviews
      @peer_reviews = ReviewResponseMap.where(reviewer_id: @participant.id)
    end
    # if it is an calibrated assignment, change the response_map order in a certain way

    @metareview_mappings = MetareviewResponseMap.where(reviewer_id: @participant.id)
    # Calculate the number of reviews that the user has completed so far.
    # Reviews total is the number of peer reviews
    @num_reviews_total = @peer_reviews.size
    # Add the reviews which are requested and not began.
    @num_reviews_completed = 0
    @peer_reviews.each do |map|
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
end
