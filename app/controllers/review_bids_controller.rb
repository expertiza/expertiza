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
      current_user_has_student_privileges? && list_authorization_check
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
    if params[:topic].nil?
      ReviewBid.where(participant_id: params[:id]).destroy_all
    else
      assignment_id = SignUpTopic.find(params[:topic].first).assignment.id
      @bids = ReviewBid.where(participant_id: params[:id])
      signed_up_topics = ReviewBid.where(participant_id: params[:id]).map(&:signuptopic_id)
      signed_up_topics -= params[:topic].map(&:to_i)
      signed_up_topics.each do |topic|
        ReviewBid.where(signuptopic_id: topic, participant_id: params[:id]).destroy_all
      end
      params[:topic].each_with_index do |topic_id, index|
        bid_existence = ReviewBid.where(signuptopic_id: topic_id, participant_id: params[:id])
        if bid_existence.empty?
          ReviewBid.create(priority: index + 1, signuptopic_id: topic_id, participant_id: params[:id], assignment_id: assignment_id)
        else
          ReviewBid.where(signuptopic_id: topic_id, participant_id: params[:id]).update_all(priority: index + 1)
        end
      end
    end
    redirect_to action: 'show', assignment_id: params[:assignment_id], id: params[:id]
  end

  # Assigns bidding topics to reviewers
  def assign_bidding
      assignment = validate_assignment(params[:assignment_id])

      reviewers = validate_reviewers(assignment.id)
      reviewer_ids = reviewers.map(&:id)

      matched_topics = run_bidding_algorithm

      if matched_topics.blank?
        flash[:alert] = 'Topic or assignment is missing'
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
  def list_authorization_check
    return true unless %w[list].include?(action_name)

    are_needed_authorizations_present?(params[:id], 'participant', 'reviewer')
  end

  def authorize_participant
    return if participant_service.valid_participant?

    flash[:error] = 'Invalid participant access.'
    redirect_back fallback_location: root_path
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
