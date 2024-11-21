# frozen_string_literal: true

# The `StudentReviewController` manages the review processes for students within an assignment.
# It handles actions related to listing reviews, managing review phases, and redirecting users
# based on the assignment's review bidding configurations. This controller ensures that students
# have the necessary permissions to access review-related functionalities and facilitates the
# seamless flow of review assignments and bidding.
class StudentReviewController < ApplicationController
  include ActionAuthorizationConcern
  include AuthorizationHelper
  include ParticipantServiceConcern
  include ReviewServiceConcern

  before_action :authorize_action
  before_action :authorize_participant, only: [list]

  BIDDING_ALGORITHM = 'Bidding'

  # Determines participant locale
  def controller_locale
    locale_for_student
  end

  # Retrieves review and metareview for the student, and if bidding is required, 
  # redirects to review bidding page
  def list
    setup_assignment_and_phase(participant_service)
    review_data(participant_service)
    metareview_data(participant_service)

    redirect_if_bidding_required
  end

  private

  # Gets the assignment and topic ID using the participant service.
  # Gets current review phase based on assignment and topic.
  def setup_assignment_and_phase(participant_service)
    @assignment = participant_service.assignment
    @topic_id = participant_service.topic_id
    @review_phase = @assignment.current_stage(@topic_id)
  end

  # Gets and assigns review data for the current participant
  def review_data
    @review_mappings = review_service.sorted_review_mappings
    @num_reviews_total = review_service.review_counts[:total]
    @num_reviews_completed = review_service.review_counts[:completed]
    @num_reviews_in_progress = review_service.review_counts[:in_progress]
    @response_ids = review_service.response_ids
  end

  # Gets and assigns metareview data for the current participant
  def metareview_data(participant_service)
    metareview_service = MetareviewService.new(participant_service)

    @review_mappings = metareview_service.sorted_metareview_mappings
    @num_reviews_total = metareview_service.metareview_counts[:total]
    @num_reviews_completed = metareview_service.metareview_counts[:completed]
    @num_reviews_in_progress = metareview_service.metareview_counts[:in_progress]
  end

  # Checks if review bidding is required for the assignment
  def bidding_required?
    @assignment.review_choosing_algorithm == BIDDING_ALGORITHM || @assignment.bidding_for_reviews_enabled
  end

  # Redirects the participant to the review bidding page if bidding is required
  def redirect_if_bidding_required
    return unless bidding_required?

    redirect_to review_bids_path(assignment_id: params[:assignment_id], id: params[:id]) if bidding_required?
  end

  def actions_requiring_authorization
    %w[list]
  end

  def actions_allowed_for_students_and_above
    %w[controller_locale list]
  end

  def actions_restricted_to_tas_and_above
    []
  end

  def required_authorizations_for_allowed_actions
    %w[submitter]
  end

  def verify_authorizations
    return false unless current_user_has_student_privileges?
    return false unless are_needed_authorizations_present?(params[:id], *required_authorizations_for_allowed_actions)

    true
  end  
end
