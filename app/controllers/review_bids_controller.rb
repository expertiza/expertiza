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
      current_user_has_student_privileges? && ((%w[list].include? action_name) ? are_needed_authorizations_present?(params[:id], 'participant', 'reader', 'submitter', 'reviewer') : true)
    else
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

  # computes important topic sets for displaying bids.
  # signup_topics is all the topics students could have signed up for.
  # signed_up_topics is the set of topics students DID sign up for.  [hey, but if the team didn't submit, how can you review it?]
  # assigned_topics is the set of topics that have been assigned to reviewers
  # num_participants counts the number of participants in the assignment

  # computes important topic sets for displaying bids.
  # signup_topics is all the topics students could have signed up for.
  # signed_up_topics is the set of topics students DID sign up for.  [hey, but if the team didn't submit, how can you review it?]
  # assigned_topics is the set of topics that have been assigned to reviewers
  # num_participants counts the number of participants in the assignment
  def show
    @participant = AssignmentParticipant.find(params[:id].to_i)
    @assignment = @participant.assignment
    @selected_topics= nil
    topic_ids_with_team = SignedUpTeam.where.not(team_id: nil).pluck(:topic_id) #Topics which have been selected by teams for submission
    @signup_topics = SignUpTopic.where(assignment_id: @assignment.id, id: topic_ids_with_team) #signup_topics is all the topics students have signed up for.
    #remove own topic from set of topics to bid on 
    my_topic = SignedUpTeam.topic_id(@participant.parent_id, @participant.user_id) 
    @signup_topics -= SignUpTopic.where(assignment_id: @assignment.id, id: my_topic) # remove own topic from set of topics to bid on
    
 
    @num_participants = AssignmentParticipant.where(parent_id: @assignment.id).count  # gotta know # participants to determine if topic's hot
    @assigned_topics= nil
    # Create an instance of ReviewBid
    @bids = ReviewBid.where(participant_id:@participant,assignment_id:@assignment.id)  # Update bids to be the list of sign-up topics on which the participant has bid
    signed_up_topics = []
    @bids.each do |bid|
      signup_topic = SignUpTopic.find_by(id: bid.signuptopic_id)
      signed_up_topics << signup_topic if signup_topic
    end
    signed_up_topics &= @signup_topics #signed_up_topics is the set of topics students DID sign up for.  
    @signup_topics -= signed_up_topics
    @bids = signed_up_topics
    @num_of_topics = @signup_topics.size # count the remaining sign-up topics
    @assigned_review_maps = []   #fetch review maps for the participant in the current assignment
    #assigned_topics=[]
    ReviewResponseMap.where({:reviewed_object_id => @assignment.id, :reviewer_id => @participant.id}).each do |review_map|
      @assigned_review_maps << review_map
    end
    render 'sign_up_sheet/review_bids_show'
  end
  # function that assigns and updates priorities for review bids
  def set_priority
    # Create an instance of ReviewBid
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
    assignment = Assignment.find(assignment_id)
    # list of reviewer id's from a specific assignment
    reviewer_ids = assignment.assignment_participants.ids
    bidding_data = assignment.review_bids.bidding_data(reviewer_ids)
    matched_topics = run_bidding_algorithm(bidding_data)
    assignment.review_bids.assign_review_topics(reviewer_ids, matched_topics)
    assignment.update(can_choose_topic_to_review: false) # turns off bidding for students
    redirect_back fallback_location: root_path
  end
  

  # call webserver for running assigning algorithm
  # passing webserver: student_ids, topic_ids, student_preferences, time_stamps
  # webserver returns:
  # returns matched assignments as json body
  def run_bidding_algorithm(bidding_data)
    
    url = WEBSERVICE_CONFIG["review_bidding_webservice_url"] #won't work unless ENV variables are configured
    url = 'http://app-csc517.herokuapp.com/match_topics' # hard coding for the time being
    begin 
      # Sending POST request to the bidding algorithm 
      response = RestClient.post(url, bidding_data.to_json, content_type: 'application/json', accept: :json)
      matched_topics= JSON.parse(response.body)
      #bidding_data_with_matches = update_bidding_data_with_matches(bidding_data, matched_topics)
      return  matched_topics
    rescue StandardError => e
      puts "Error in assigning reviewers: #{e.message}"
      return nil
    end
  end

  def update_bidding_data_with_matches(bidding_data,matched_topics)
    assignment_id = bidding_data[:assignment_id]
    reviewer_ids = bidding_data[:reviewer_ids]
    unbid_reviewers = reviewer_ids - matched_topics.keys
    if unbid_reviewers.any?
      assignment = Assignment.find(assignment_id)
      unbid_reviewers.each do |reviewer_id|
        random_topics = SignUpTopic.where(assignment_id: assignment_id).sample(assignment.num_reviews_per_student)
        ReviewResponseMap.create_reviews_for_reviewer(reviewer_id, random_topics)
      end
    end
  end
end
