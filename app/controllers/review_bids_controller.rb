# frozen_string_literal: true

# The `ReviewBidsController` is responsible for managing the review bidding process
# for assignments. It handles actions related to displaying review options, setting
# review priorities, and managing reviews after the bidding process is complete.
class ReviewBidsController < ApplicationController
  include AuthorizationHelper

  before_action :authorize_participant, only: [:index]

  # Checks the action allowed based on the authenticated user and authorizations
  def action_allowed?
    case params[:action]
    when 'show', 'set_priority', 'index', 'list'
      current_user_has_student_privileges? && current_user_has_review_permissions?
    else
      current_user_has_ta_privileges?
    end
  end

  # Displays the review bid others work page for the current participant
  def index
    @assignment = participant_service.assignment
    unless @assignment.is_a?(Assignment)
      flash[:error] = 'Assignment not found.'
      redirect_back fallback_location: root_path && return
    end

    @review_mappings = review_service.review_mappings
    @num_reviews_completed = review_service.review_counts[:completed]

    render 'sign_up_sheet/review_bids_others_work'
  end

  # Displays the review bidding page for the current participant
  def show
    @participant = AssignmentParticipant.find(params[:id].to_i)
    @assignment = @participant.assignment
    @sign_up_topics = SignUpTopic.where(assignment_id: @assignment.id, private_to: nil)
    my_topic = SignedUpTeam.topic_id(@participant.parent_id, @participant.user_id)
    @sign_up_topics -= SignUpTopic.where(assignment_id: @assignment.id, id: my_topic)
    @num_participants = AssignmentParticipant.where(parent_id: @assignment.id).count
    @selected_topics = nil # this is used to list the topics assigned to review. (ie select == assigned i believe)
    @bids = ReviewBid.where(participant_id: @participant, assignment_id: @assignment.id)
    signed_up_topics = []
    @bids.each do |bid|
      sign_up_topic = SignUpTopic.find_by(id: bid.signuptopic_id)
      signed_up_topics << sign_up_topic if sign_up_topic
    end
    signed_up_topics &= @sign_up_topics
    @sign_up_topics -= signed_up_topics
    @bids = signed_up_topics
    @num_of_topics = @sign_up_topics.size
    @assigned_review_maps = []
    ReviewResponseMap.where(reviewed_object_id: @assignment.id, reviewer_id: @participant.id).each do |review_map|
      @assigned_review_maps << review_map
    end

    # explicitly render view since it's in the sign up sheet views
    render 'sign_up_sheet/review_bids_show'
  end

  # Assigns and updates priorities for review bids
  def set_priority
    participant_id = params[:participant_id].to_i
    selected_topic_ids = params[:topic]&.map(&:to_i) || []
    assignment_id = params[:assignment_id].to_i

    # Redirects with an error message if the user is not authorized to modify bids.
    unless current_user_can_modify_bids?(participant_id)
      flash[:error] = 'You are not authorized to modify these bids.'
      respond_to do |format|
        format.html { redirect_back fallback_location: root_path }
        format.json { render json: { status: 'unauthorized' }, status: :unauthorized }
      end
      return
    end

    # Resets existing review bids if we don't have any selected topic ids
    # If selected topics are available, verifies that assignment is not nil
    # before updating or creating bids based on selected topics
    if selected_topic_ids.empty?
      ReviewBid.where(participant_id: participant_id).destroy_all
    else
      assignment = Assignment.find_by(id: assignment_id)
      if assignment.nil?
        flash[:error] = "Invalid assignment."
        respond_to do |format|
          format.html { redirect_back fallback_location: root_path }
          format.json { render json: { status: 'invalid_assignment' }, status: :unprocessable_entity }
        end
        return
      end

      # Verifies that all selected topic IDs belong to the specified assignment
      unless SignUpTopic.where(id: selected_topic_ids, assignment_id: assignment_id).count == selected_topic_ids.size
        flash[:error] = "One or more selected topics are invalid."
        respond_to do |format|
          format.html { redirect_back fallback_location: root_path }
          format.json { render json: { status: 'invalid_topics' }, status: :unprocessable_entity }
        end
        return
      end

      # Removes outdated bids for the participant, deleting any bids not in the selected_topic_ids.
      ReviewBid.where(participant_id: participant_id).where.not(signuptopic_id: selected_topic_ids).destroy_all

      # Creates or updates review bids for the selected topics with assigned priorities.
      selected_topic_ids.each_with_index do |topic_id, index|
        bid = ReviewBid.find_or_initialize_by(signuptopic_id: topic_id, participant_id: participant_id)
        bid.priority = index + 1
        bid.assignment_id = assignment_id
        bid.save!
      end
    end

    respond_to do |format|
      format.html { redirect_to action: 'show', assignment_id: assignment_id, id: participant_id, notice: 'Review bids updated successfully.' }
      format.json { render json: { status: 'success' }, status: :ok }
    end
  rescue ActiveRecord::RecordInvalid => e
    flash[:error] = "Failed to update priorities: #{e.message}"
    respond_to do |format|
      format.html { redirect_back fallback_location: root_path }
      format.json { render json: { status: 'error', message: e.message }, status: :unprocessable_entity }
    end
  end

  # Assigns bidding topics to reviewers
  def assign_bidding
    assignment = validate_assignment(params[:assignment_id])

    reviewers = validate_reviewers(assignment.id)
    reviewer_ids = reviewers.map(&:id)

    matched_topics = run_bidding_algorithm

    if matched_topics.blank?
      flash[:alert] = 'Topics or assignment is missing'
      redirect_back fallback_location: root_path && return
    end

    leftover_topics = find_leftover_topics(assignment.id, matched_topics)
    assign_leftover_topics(reviewer_ids, matched_topics, leftover_topics)

    ReviewBid.new.assign_review_topics(matched_topics)
    assignment.update!(can_choose_topic_to_review: false)

    flash[:notice] = 'Reviewers were successfully assigned to topics.'
    redirect_back fallback_location: root_path
  rescue ArgumentError => e
    Rails.logger.error "ArgumentError: #{e.message}"
    redirect_back fallback_location: root_path, alert: e.message
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error "ActiveRecord::RecordInvalid: #{e.message}"
    redirect_back fallback_location: root_path, alert: 'Failed to assign reviewers due to database error. Please try again later.'
  rescue ActiveRecord::ActiveRecordError => e
    Rails.logger.error "ActiveRecord::ActiveRecordError: #{e.message}"
    redirect_back fallback_location: root_path, alert: 'Failed to assign reviewers due to database error. Please try again later.'
  rescue StandardError => e
    Rails.logger.error "StandardError: #{e.message}"
    redirect_back fallback_location: root_path, alert: 'Failed to assign reviewers. Please try again later.'
  end

  private

  # Initialize participant service
  def participant_service
    @participant_service ||= ParticipantService.new(params[:id], current_user.id)
  end

  # Initialize review service
  def review_service
    @review_service ||= ReviewService.new(participant_service.participant)
  end

  # Check for necessary authorizations for list action
  def current_user_has_review_permissions?
    return true unless %w[list].include?(action_name)

    are_needed_authorizations_present?(params[:id], 'participant', 'reviewer')
  end

  def authorize_participant
    return if participant_service.valid_participant?

    flash[:error] = 'Invalid participant access.'
    redirect_back fallback_location: root_path
  end

  def current_user_can_modify_bids?(participant_id)
    return true if current_user_has_ta_privileges?

    current_user.assignment_participants.exists?(id: participant_id)
  end

  def find_leftover_topics(assignment_id, matched_topics)
    all_topic_ids = SignUpTopic.where(assignment_id: assignment_id).pluck(:id)
    assigned_topic_ids = matched_topics.map { |match| match[:topic_id] }

    # Calculate leftover topics
    all_topic_ids - assigned_topic_ids
  end

  def assign_leftover_topics(reviewer_ids, matched_topics, leftover_topics)
    return if leftover_topics.blank?

    # Find non-bidders by excluding already matched reviewers
    non_bidders = reviewer_ids - matched_topics.keys

    # Assign leftover topics to non-bidders in a round-robin fashion
    non_bidders.each_with_index do |reviewer_id, index|
      topic_id = leftover_topics[index % leftover_topics.length]
      ReviewBid.create(priority: 1, signuptopic_id: topic_id, participant_id: reviewer_id)
    end
  end

  def validate_assignment(assignment_id)
    assignment = Assignment.find_by(id: assignment_id.to_i)
    raise ArgumentError, 'Invalid assignment. Please check and try again.' unless assignment

    assignment
  end

  def validate_reviewers(assignment_id)
    reviewers = AssignmentParticipant.where(parent_id: assignment_id)
    raise ArgumentError, 'No reviewers available for the assignment.' if reviewers.empty?

    reviewers
  end

  def run_bidding_algorithm
    review_bid = ReviewBid.new
    bidding_data = review_bid.bidding_data
    matched_topics = BiddingAlgorithmService.new(bidding_data).run
    raise ArgumentError, 'Failed to assign reviewers. Please try again later.' unless matched_topics

    matched_topics
  end
end
