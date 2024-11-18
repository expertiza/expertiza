# frozen_string_literal: true

# The `StudentReviewController` manages the review processes for students within an assignment.
# It handles actions related to listing reviews, managing review phases, and redirecting users
# based on the assignment's review bidding configurations. This controller ensures that students
# have the necessary permissions to access review-related functionalities and facilitates the
# seamless flow of review assignments and bidding.
class StudentReviewController < ApplicationController
  include AuthorizationHelper
  before_action :authorize_participant, only: [list]

  BIDDING_ALGORITHM = 'Bidding' # Constant to prevent hardcoding values

  def action_allowed?
    (current_user_has_student_privileges? &&
        (%w[list].include? action_name) &&
        are_needed_authorizations_present?(params[:id], 'submitter')) ||
      current_user_has_student_privileges?
  end

  def controller_locale
    locale_for_student
  end

  def list
    setup_assignment_and_phase(participant_service)
    get_review_data(participant_service)
    get_metareview_data(participant_service)

    redirect_if_bidding_required
  end

  private

  def participant_service
    @participant_service ||= ParticipantService.new(params[:id], current_user.id)
  end

  # should this be moved to AuthorizationHelper class?
  def authorize_participant
    return head :forbidden unless participant_service.valid_participant?
  end

  def setup_assignment_and_phase(participant_service)
    @assignment = participant_service.assignment
    @topic_id = participant_service.topic_id
    @review_phase = @assignment.current_stage(@topic_id)
  end

  def get_review_data(participant_service)
    review_service = ReviewService.new(participant_service.reviewer)

    @review_mappings = review_service.sorted_review_mappings
    @num_reviews_total = review_service.review_counts[:total]
    @num_reviews_completed = review_service.review_counts[:completed]
    @num_reviews_in_progress = review_service.review_counts[:in_progress]
    @response_ids = review_service.response_ids
  end

  def get_metareview_data(participant_service)
    metareview_service = MetareviewService.new(participant_service)

    @review_mappings = metareview_service.sorted_metareview_mappings
    @num_reviews_total = metareview_service.metareview_counts[:total]
    @num_reviews_completed = metareview_service.metareview_counts[:completed]
    @num_reviews_in_progress = metareview_service.metareview_counts[:in_progress]
  end

  def bidding_required?
    @assignment.review_choosing_algorithm == BIDDING_ALGORITHM || @assignment.bidding_for_reviews_enabled
  end

  def redirect_if_bidding_required
    return unless bidding_required

    redirect_to review_bids_path(assignment_id: params[:assignment_id], id: params[:id]) if bidding_required?
  end
end
