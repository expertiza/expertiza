class ReviewBidsController < ApplicationController
  require 'json'
  require 'uri'
  require 'net/http'
  require 'rest_client'

  # Constants for role checking
  ALLOWED_ROLES = [
    'Instructor',
    'Teaching Assistant',
    'Administrator',
    'Super-Administrator',
    'Student'
  ].freeze

  PRIVILEGED_ROLES = ALLOWED_ROLES - ['Student'].freeze
  # action allowed function checks the action allowed based on the user working
  before_action :set_participant, only: [:index, :show, :set_priority]
  before_action :set_assignment, only: [:index, :show, :set_priority]
  before_action :authorize_participant, only: [:index, :show, :set_priority]
  skip_before_action :set_participant, :authorize_participant, only: [:assign_bidding]

  def action_allowed?
    return false unless ALLOWED_ROLES.include?(current_role_name)

    case params[:action]
    # If the action is list we need a further check
    when 'list'
      are_needed_authorizations_present?(params[:id], 'participant', 'reader', 'submitter', 'reviewer')
    when 'show', 'set_priority', 'index'
      true
    else
      PRIVILEGED_ROLES.include?(current_role_name)
    end
  end

  # provides variables for reviewing page located at views/review_bids/others_work.html.erb
  def index
    @review_mappings = ReviewResponseMap.where(reviewer_id: @participant.id)
    @completed_reviews_count = CompletedReviewCounterService.count_reviews(@review_mappings)
    render 'sign_up_sheet/review_bids_others_work'
  end

  # provides variables for review bidding page
  def show
    @sign_up_topics = SignUpTopic.where(assignment_id: @assignment.id, private_to: nil)
    my_topic = SignedUpTeam.topic_id(@participant.parent_id, @participant.user_id)
    @sign_up_topics -= SignUpTopic.where(assignment_id: @assignment.id, id: my_topic)
    @num_participants = AssignmentParticipant.where(parent_id: @assignment.id).count
    @selected_topics = nil
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
    @assigned_review_maps = ReviewResponseMap.where(reviewed_object_id: @assignment.id, reviewer_id: @participant.id)
    render 'sign_up_sheet/review_bids_show'
  end

  # function that assigns and updates priorities for review bids
  def set_priority
    selected_topic_ids = Array(params[:topic]).map(&:to_i)
    bids = ReviewBid.where(participant_id: @participant.id)
    assignment_id = @assignment.id

    return delete_all_bids_and_redirect(bids) if selected_topic_ids.empty?

    existing_topic_ids = bids.pluck(:signuptopic_id)
    to_remove_ids = existing_topic_ids - selected_topic_ids
    ReviewResponseMap.where(reviewed_object_id: assignment_id).delete_all
    BidsPriorityService.process_bids(assignment_id, participant_id, selected_topic_ids, removed_topic_ids)
    redirect_to action: 'show', assignment_id: assignment_id, id: participant_id
  end

  def assign_bidding
    unless PRIVILEGED_ROLES.include?(current_role_name)
      redirect_to(root_path, alert: "Unauthorized to perform this action")
      return
    end

    result = AssignBiddingService.call_by_assignment(params[:assignment_id])
    if result.success?
      flash[:notice] = 'Bidding assignments updated.'
    else
      flash[:alert] = "Could not assign bids: #{result.error_message}"
    end
    redirect_back fallback_location: root_path
  end

  private

  def set_participant
    @participant = AssignmentParticipant.find_by(id: params[:id])
    redirect_to(root_path, alert: "Participant not found") unless @participant
  end

  def set_assignment
    @assignment = @participant.assignment
  end

  def authorize_participant
    redirect_to(root_path, alert: "Unauthorized to view page") unless current_user_id?(@participant.user_id)
  end

  def delete_all_bids_and_redirect(bids)
    bids.delete_all
    redirect_to action: :show,
                assignment_id: params[:assignment_id],
                id: params[:id]
  end
end
