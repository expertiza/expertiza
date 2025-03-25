class ReviewBidsController < ApplicationController
  require 'json'
  require 'uri'
  require 'net/http'
  require 'rest_client'

  # action allowed function checks the action allowed based on the user working
  def action_allowed?
    case params[:action]
    when 'show', 'set_priority', 'index'
      ['Instructor',
       'Teaching Assistant',
       'Administrator',
       'Super-Administrator',
       'Student'].include?(current_role_name) &&
        ((%w[list].include? action_name) ? are_needed_authorizations_present?(params[:id], 'participant', 'reader', 'submitter', 'reviewer') : true)
    else
      ['Instructor',
       'Teaching Assistant',
       'Administrator',
       'Super-Administrator'].include? current_role_name
    end
  end

  # provides variables for reviewing page located at views/review_bids/others_work.html.erb
  def index
    @participant = AssignmentParticipant.find(params[:id])
    return unless current_user_id?(@participant.user_id)
    @assignment = @participant.assignment
    @review_mappings = ReviewResponseMap.where(reviewer_id: @participant.id)
    # Finding how many reviews have been completed
    @num_reviews_completed = 0
    @review_mappings.each do |map|
      @num_reviews_completed += 1 if !map.response.empty? && map.response.last.is_submitted
    end
    # render view for completing reviews after review bidding has been completed
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

  # function that assigns and updates priorities for review bids
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

  def assign_bidding
    assignment_id = params[:assignment_id].to_i
    reviewer_ids = fetch_reviewer_ids(assignment_id)
    matched_topics = process_bidding(assignment_id, reviewer_ids)
    # Trigger fallback algorithm if process_bidding fails (returns nil or empty hash)
    if matched_topics.nil? || matched_topics.empty?
      Rails.logger.warn "process_bidding failed, triggering fallback algorithm"
      matched_topics = ReviewBid.fallback_algorithm(assignment_id, reviewer_ids)
    end
    ensure_valid_topics(matched_topics, reviewer_ids)
    ReviewBid.assign_review_topics(assignment_id, reviewer_ids, matched_topics)
    Assignment.find(assignment_id).update(can_choose_topic_to_review: false)
    redirect_back fallback_location: root_path
  end

  private

  def fetch_reviewer_ids(assignment_id)
    AssignmentParticipant.where(parent_id: assignment_id).ids
  end

  def process_bidding(assignment_id, reviewer_ids)
    ReviewBiddingAlgorithmService.process_bidding(assignment_id, reviewer_ids)
  end

  def ensure_valid_topics(matched_topics, reviewer_ids)
    matched_topics ||= {}
    reviewer_ids.each { |reviewer_id| matched_topics[reviewer_id.to_s] ||= [] }
    Rails.logger.debug "Final matched topics after fallback: #{matched_topics.inspect}"
  end
end
