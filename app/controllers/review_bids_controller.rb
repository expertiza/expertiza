class ReviewBidsController < ApplicationController
  require 'json'
  require 'uri'
  require 'net/http'
  require 'rest_client'
  include AuthorizationHelper

  # action allowed function checks the action allowed based on the user working
  def action_allowed?
    case params[:action]
    #The action_name is fetch from list which can be show, set_priority or index
    when 'show', 'set_priority', 'index'
      current_user_has_student_privileges? && ((%w[list].include? action_name) ? are_needed_authorizations_present?(params[:id], 'participant', 'reader', 'submitter', 'reviewer') : true)
    else
       current_user_has_ta_privileges?
    end
  end


  # provides variables for reviewing page located at views/review_bids/others_work.html.erb
  def index
    @participant = AssignmentParticipant.find(params[:id].to_i)
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
  

  def show
    @participant = AssignmentParticipant.find(params[:id].to_i)
    @assignment = @participant.assignment
    topic_ids_with_team = SignedUpTeam.where.not(team_id: nil).pluck(:topic_id) #Topics which have been selected by teams for submission
    @signup_topics = SignUpTopic.where(assignment_id: @assignment.id, id: topic_ids_with_team) #signup_topics is all the topics students have signed up for
    my_topic = SignedUpTeam.topic_id(@participant.parent_id, @participant.user_id) #topic selected by the team 
    @signup_topics -= SignUpTopic.where(assignment_id: @assignment.id, id: my_topic) #remove own topic from set of topics to bid on
    @num_participants = AssignmentParticipant.where(parent_id: @assignment.id).count  #number of participants to determine if topic's hot
    @assigned_topics= nil
    @bids = ReviewBid.where(participant_id:@participant,assignment_id:@assignment.id)  #Update bids to be the list of sign-up topics on which the participant has bid
    signed_up_topics = []
    @bids.each do |bid|
      signup_topic = SignUpTopic.find_by(id: bid.signuptopic_id)
      signed_up_topics << signup_topic if signup_topic
    end
    signed_up_topics &= @signup_topics #signed_up_topics is the set of topics students DID sign up for.  
    @signup_topics -= signed_up_topics
    @bids = signed_up_topics
    @num_of_topics = @signup_topics.size #count the remaining sign-up topics
    @assigned_review_maps = ReviewResponseMap.where({:reviewed_object_id => @assignment.id, :reviewer_id => @participant.id})   #fetch review maps for the participant in the current assignment
    @selected_topics= nil   # this is used to list the topics assigned to review.
    @selected_topics = @assigned_review_maps.map do |review_map|
      SignUpTopic.find_by(id: SignedUpTeam.find_by(team_id: review_map.reviewee_id)&.topic_id)
    end
    render 'sign_up_sheet/review_bids_show'
  end


  # function that assigns and updates priorities for review bids
  def set_priority
    # If all bids are deselected by the user
    if params[:topic].blank?
      ReviewBid.where(participant_id: params[:id]).destroy_all
    else
      assignment_id = SignUpTopic.find(params[:topic].first).assignment.id
      existing_bids = ReviewBid.where(participant_id: params[:id])
      existing_topics = existing_bids.pluck(:signuptopic_id)
      
      # Remove bids for topics no longer selected
      bids_to_remove = existing_topics - params[:topic].map(&:to_i)
      ReviewBid.where(signuptopic_id: bids_to_remove, participant_id: params[:id]).destroy_all
      
      # Update or create bids
      params[:topic].each_with_index do |topic_id, index|
        bid = existing_bids.find { |b| b.signuptopic_id == topic_id.to_i }
        if bid
          bid.update(priority: index + 1)
        else
          ReviewBid.create(priority: index + 1, signuptopic_id: topic_id, participant_id: params[:id], assignment_id: assignment_id)
        end
      end
    end
    redirect_to action: 'show', assignment_id: params[:assignment_id], id: params[:id]
  end

  # Function to assign the students with the topics for review
  def assign_bid_review
    assignment_id = params[:assignment_id].to_i # sets parameters used for running bidding algorithm
    reviewer_ids = AssignmentParticipant.where(parent_id: assignment_id).ids # list of reviewer id's from a specific assignment
    bidding_data = ReviewBid.bidding_data(assignment_id, reviewer_ids) #Retrieving all the existing bids for the assignment
    puts bidding_data
    #Assigning topics to review for each reviewer
    assigned_topics = run_bidding_algorithm(bidding_data, assignment_id)
    puts assigned_topics
    ReviewBid.assign_review_topics(assignment_id, reviewer_ids, assigned_topics)
    # turns off bidding for students 
    Assignment.find(assignment_id).update(can_choose_topic_to_review: false) 
    redirect_back fallback_location: root_path
  end
  

  # call webserver for running assigning algorithm
  # passing webserver: student_ids, topic_ids, student_preferences, time_stamps
  # webserver returns:
  # returns matched assignments as json body
  def run_bidding_algorithm(bidding_data, assignment_id)
    
     #url = WEBSERVICE_CONFIG["review_bidding_webservice_url"] #won't work unless ENV variables are configured
     begin  
      #response = RestClient.post(url, bidding_data.to_json, content_type: 'application/json', accept: :json)
      #matched_topics= JSON.parse(bidding_data)
      
      assigned_topics = Hash.new { |h, k| h[k] = [] } #To store topics assigned to each user
      available_topics = bidding_data['tid'].dup  # Cloning the list of topic IDs to track availability
      num_reviews_required= Assignment.where(id: assignment_id).pluck(:num_reviews_required).first
      
      # Assign topics based on students' bids
      bidding_data['users'].each do |user_id, data|
        # Sort bids by priority and assign each topic
        sorted_bids = data['tid'].zip(data['priority']).sort_by { |_, priority| priority }
        sorted_bids.each do |topic_id, _|
          if available_topics.include?(topic_id) && assigned_topics[user_id].length <= bidding_data['max_accepted_proposals']
            assigned_topics[user_id] << topic_id  # Assign topic to student
          end
        end
      end
      
      # Handling students who didn't get any topics because they didn't bid or their bids were unavailable
      unassigned_users = bidding_data['users'].keys - assigned_topics.keys
      unassigned_users.each do |user_id|
        assigned_count = 0 #To count number of topics assigned to the user
        topics=available_topics
        while assigned_count < num_reviews_required && !available_topics.empty?
          topic_to_assign = topics.sample # randomly assigning topics from available topics
          assigned_topics[user_id] << topic_to_assign unless topic_to_assign.nil?
          assigned_count += 1
          #topics-= topic_to_assign # To avoid duplication of topics assigned
        end
      end
      assigned_topics
    end
    rescue StandardError => e
      puts "Error in assigning reviewers: #{e.message}"
      return nil
    end
  end

