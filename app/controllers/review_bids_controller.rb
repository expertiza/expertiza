class ReviewBidsController < ApplicationController
  require 'json'
  require 'uri'
  require 'net/http'
  require 'rest_client'
  include AuthorizationHelper

  # action allowed function checks the action allowed based on the user working
  def action_allowed?
    case params[:action]
    when 'show', 'set_priority', 'index'
    #   ['Instructor',
    #    'Teaching Assistant',
    #    'Administrator',
    #    'Super-Administrator',
    #    'Student'].include?(current_role_name) && ((%w[list].include? action_name) ? are_needed_authorizations_present?(params[:id], 'participant', 'reader', 'submitter', 'reviewer') : true)
      # puts "Action_allowed called for all"
      current_user_has_student_privileges? && ((%w[list].include? action_name) ? are_needed_authorizations_present?(params[:id], 'participant', 'reader', 'submitter', 'reviewer') : true)
    else
      # ['Instructor',
      #  'Teaching Assistant',
      #  'Administrator',
      #  'Super-Administrator'].include? current_role_name
      # puts "Action allowed called for ta"
       current_user_has_ta_privileges?
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
 
      @participant = AssignmentParticipant.find(params[:id])
      @assignment = @participant.assignment
      # Directly fetch sign-up topics excluding the participant's own topic
      my_topic_id = SignedUpTeam.topic_id(@participant.parent_id, @participant.user_id)
      @sign_up_topics = @assignment.sign_up_topics.where.not(id: my_topic_id, private_to: nil)
      @num_participants = @assignment.assignment_participants.count
      # reduces the number of queries by fetching bid topics in one query
      bid_topic_ids = @participant.review_bids.pluck(:signuptopic_id)
      @bids = @sign_up_topics.where(id: bid_topic_ids)
      # Filter @sign_up_topics to exclude the topics the participant has bid on
      @sign_up_topics = @sign_up_topics.where.not(id: bid_topic_ids)
      @num_of_topics = @sign_up_topics.count
      # Fetching review maps in a single query
      @assigned_review_maps = ReviewResponseMap.where(reviewed_object_id: @assignment.id, reviewer_id: @participant.id)
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

  # assign bidding topics to reviewers
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

  # call webserver for running assigning algorithm
  # passing webserver: student_ids, topic_ids, student_preferences, time_stamps
  # webserver returns:
  # returns matched assignments as json body
  def run_bidding_algorithm(bidding_data)
    # begin
    url = 'http://app-csc517.herokuapp.com/match_topics' # hard coding for the time being
    response = RestClient.post url, bidding_data.to_json, content_type: 'application/json', accept: :json
    JSON.parse(response.body)
  rescue StandardError
    false
    # end
  end
end
