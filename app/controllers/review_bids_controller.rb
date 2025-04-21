class ReviewBidsController < ApplicationController
  require 'json'
  require 'uri'
  require 'net/http'
  require 'rest_client'

  # Constants for role checking
  ALLOWED_ROLES = [
    'Instructor',        # This list is for show, set_priority, and index
    'Teaching Assistant',
    'Administrator',
    'Super-Administrator',
    'Student'
  ]

  PRIVILEGED_ROLES = [
    'Instructor',
    'Teaching Assistant',
    'Administrator',
    'Super-Administrator'
  ]

  # action allowed function checks the action allowed based on the user working
  def action_allowed?
    return false unless ALLOWED_ROLES.include?(current_role_name)

    case params[:action]
    when 'show', 'set_priority', 'index'
      if params[:action] == 'list'
        return are_needed_authorizations_present?(params[:id], 'participant', 'reader', 'submitter', 'reviewer')
      end
      return true
    else
      return PRIVILEGED_ROLES.include?(current_role_name)
    end
  end

  # provides variables for reviewing page located at views/review_bids/others_work.html.erb
  def index
    @participant = AssignmentParticipant.find(params[:id])
    if @participant.nil?
      flash[:error] = "Participant not found"
      return
    end
    if !current_user_id?(@participant.user_id)
      flash[:error] = "Unauthorized to view page."
      return
    end
    @assignment = @participant.assignment
    @review_mappings = ReviewResponseMap.where(reviewer_id: @participant.id)
    @completed_reviews_count = CompletedReviewCounterService.count_reviews(@review_mappings)
    render 'sign_up_sheet/review_bids_others_work'
  end

  # provides variables for review bidding page
  def show
    @participant = AssignmentParticipant.find(params[:id].to_i)
    @assignment = @participant.assignment
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
    participant_id = params[:id].to_i
    selected_topic_ids = params[:topic]&.map(&:to_i) || []

    if selected_topic_ids.empty?
      ReviewBid.where(participant_id: participant_id).destroy_all
      redirect_to action: 'show', id: participant_id and return
    end
    assignment_id = SignUpTopic.find(selected_topic_ids.first).assignment_id
    existing_topic_ids = ReviewBid.where(participant_id: participant_id).pluck(:signuptopic_id)
    removed_topic_ids = existing_topic_ids - selected_topic_ids
    BidsPriorityService.process_bids(assignment_id, participant_id, selected_topic_ids, removed_topic_ids)
    redirect_to action: 'show', assignment_id: assignment_id, id: participant_id
  end

  # refactored bidding assignment using AssignBiddingService
  def assign_bidding
    @participant = AssignmentParticipant.find(params[:id])
    if @participant.nil?
      redirect_back fallback_location: root_path, alert: "Participant not found"
      return
    end
    result = AssignBiddingService.call(@participant)
    unless result.success?
      redirect_back fallback_location: root_path,
                    alert: "Could not assign bids: #{result.error_message}"
      return
    end
    flash[:notice] = 'Bidding assignments updated.'
    redirect_back fallback_location: root_path
  end
end
