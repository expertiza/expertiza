# frozen_string_literal: true

# The `ReviewBidsController` is responsible for managing the review bidding process
# for assignments. It handles actions related to displaying review options, setting
# review priorities, and managing reviews after the bidding process is complete.
class ReviewBidsController < ApplicationController
  include ActionAuthorizationConcern
  include AuthorizationHelper
  include ParticipantServiceConcern
  include ReviewServiceConcern

  before_action :authorize_action
  before_action :authorize_participant, only: [:index]

  # Displays the review bid others work page for the current participant
  def index
    @assignment = participant_service.assignment
    @review_mappings = review_service.review_mappings

    # Get the number of reviews that have been completed
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
    # sets parameters used for running bidding algorithm
    assignment_id = params[:assignment_id].to_i
    # list of reviewer id's from a specific assignment
    reviewer_ids = AssignmentParticipant.where(parent_id: assignment_id).ids
    bidding_data = ReviewBid.bidding_data(assignment_id, reviewer_ids)
    matched_topics = run_bidding_algorithm(bidding_data)
    ReviewBid.assign_review_topics(assignment_id, reviewer_ids, matched_topics)
    Assignment.find(assignment_id).update(can_choose_topic_to_review: false) # turns off bidding for students
    redirect_back fallback_location: root_path
  end

  # Calls web service to run the bid assignment algorithm
  # Sends student IDs, topic IDs, student preferences, and timestamps to the web service
  # The web service returns the matched assignments in the JSON response body
  def run_bidding_algorithm(bidding_data)
    # begin
    url = 'http://app-csc517.herokuapp.com/match_topics' # hard coding for the time being
    response = RestClient.post url, bidding_data.to_json, content_type: 'application/json', accept: :json
    JSON.parse(response.body)
  rescue StandardError
    false
    # end
  end

  private

  def actions_requiring_authorization
    %w[list]
  end

  def actions_allowed_for_students_and_above
    %w[show set_priority index]
  end

  def actions_restricted_to_tas_and_above
    %w[assign_bidding run_bidding_algorithm]
  end

  def required_authorizations_for_allowed_actions
    %w[participant reader submitter reviewer]
  end

  def verify_authorizations
    return false unless current_user_has_student_privileges?
    return false unless are_needed_authorizations_present?(params[:id], *required_authorizations_for_allowed_actions)

    true
  end
end
