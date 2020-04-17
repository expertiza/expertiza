class ReviewBiddingController < ApplicationController
  #controlled is created to help with the bidding for the reviews assinged
  
  require "net/http"
  require "uri"
  require "json"
  #checks based on the roll name
  def action_allowed?
    case params[:action]
    when 'review_bid', 'set_priority','get_quartiles'
      ['Instructor',
       'Teaching Assistant',
       'Administrator',
       'Super-Administrator',
       'Student'].include? current_role_name and
      ((%w[list].include? action_name) ? are_needed_authorizations_present?(params[:id], "reader", "submitter", "reviewer") : true)
    else
      ['Instructor',
       'Teaching Assistant',
       'Administrator',
       'Super-Administrator'].include? current_role_name
    end
  end
  #entry point to the webservice call
  def assign
    assignment_id = params[:id]
    reviewers = assignment_reviewers(assignment_id)
    topics = SignUpTopic.where(assignment_id: assignment_id).ids
    bidding_data = assignment_bidding_data(assignment_id,reviewers)
    matched_topics = reviewer_topic_matching(bidding_data,topics,assignment_id)
    assign_matched_topics(assignment_id,reviewers,matched_topics)
    redirect_to :back
  end

  def assignment_reviewers(assignment_id)
    #assignment id is the paramter to hold assignment id of reviewer.
	#function to get the participant id for all reviews with a topic given to them
    reviewers = AssignmentParticipant.where(parent_id: assignment_id).ids
    for reviewer in reviewers do
      if(reviewer_self_topic(reviewer,assignment_id)==nil)
        reviewers = reviewers - [reviewer]
      end
    end
    return reviewers
  end

  def assignment_bidding_data(assignment_id,reviewers)
	#hash of all the bidding data for an assignment
    bidding_data = Hash.new
    for reviewer in reviewers do
      bidding_data[reviewer] = reviewer_bidding_data(reviewer,assignment_id)
    end
    return bidding_data
  end

  def reviewer_bidding_data(reviewer,assignment_id)
	#has of bidding data for particular reviewers
    self_topic = reviewer_self_topic(reviewer,assignment_id)
    bidding_data = {'priority' => [], 'time' => [], 'tid' =>  [], 'otid' => self_topic}
    bids = ReviewBid.where(participant_id: reviewer)
    for bid in bids do
      bidding_data['priority'] << bid.priority
      # bidding_data['time'] << bid.updated_at
      bidding_data['time'] << 1
      bidding_data['tid'] << bid.sign_up_topic_id
    end
    return bidding_data
  end

  def reviewer_self_topic(reviewer,assignment_id)
	#to return topic id  of the review a reviewer is working on
    user_id = Participant.where(id: reviewer).pluck(:user_id).first
    self_topic = ActiveRecord::Base.connection.execute("SELECT ST.topic_id FROM teams T, teams_users TU,signed_up_teams ST where TU.team_id=T.id and T.parent_id="+assignment_id.to_s+" and TU.user_id="+user_id.to_s+" and ST.team_id=TU.team_id;").first
    if self_topic==nil
      return self_topic
    end
    return self_topic.first
  end

  def reviewer_topic_matching(bidding_data,topics,assignment_id)
	#hash of participant ids
    num_reviews_allowed = Assignment.where(id:assignment_id).pluck(:num_reviews_allowed).first
    json_like_bidding_hash = {"users": bidding_data, "tids": topics, "q_S": num_reviews_allowed}
    uri = URI.parse(WEBSERVICE_CONFIG["review_bidding_webservice_url"])
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri.path, {'Content-Type' => 'application/json'})
    request.body = json_like_bidding_hash.to_json
    response = http.request(request)
    return JSON.parse(response.body)
  end

  def assign_matched_topics(assignment_id,reviewers,matched_topics)
    for reviewer in reviewers do
      reviewer_matched_topics = matched_topics[reviewer.to_s]
      for topic in reviewer_matched_topics do
        # puts(topic)
        # puts(topic.class)
        matched_reviewee = SignedUpTeam.where(topic_id: topic).pluck(:team_id).first
        if(matched_reviewee != nil)
          ReviewResponseMap.create({:reviewed_object_id => assignment_id, :reviewer_id => reviewer, :reviewee_id => matched_reviewee, :type => "ReviewResponseMap"})
        end
      end
    end
  end



  def review_bid
    @participant = AssignmentParticipant.find(params[:id].to_i)
    @assignment = @participant.assignment
    @sign_up_topics = SignUpTopic.where(assignment_id: @assignment.id, private_to: nil)
    team_id = @participant.team.try(:id)
    my_topic = SignedUpTeam.where(team_id: team_id).pluck(:topic_id).first
    @sign_up_topics -= SignUpTopic.where(assignment_id: @assignment.id, id: my_topic)
    @max_team_size = @assignment.max_team_size
    @selected_topics =nil
    @bids = team_id.nil? ? [] : ReviewBid.where(participant_id:@participant,assignment_id:@assignment.id).order(:priority)
    signed_up_topics = []
      @bids.each do |bid|
        sign_up_topic = SignUpTopic.find_by(id: bid.sign_up_topic_id)
        signed_up_topics << sign_up_topic if sign_up_topic
      end
      signed_up_topics &= @sign_up_topics
      @sign_up_topics -= signed_up_topics
      @bids = signed_up_topics
      @num_of_topics = @sign_up_topics.size
      render 'sign_up_sheet/review_bid'
  end

	#drag and drop functionality
  def set_priority
    if params[:topic].nil?
      ReviewBid.where(participant_id: params[:participant_id]).destroy_all
    else
      participant = AssignmentParticipant.find_by(id: params[:participant_id])
      assignment_id = SignUpTopic.find(params[:topic].first).assignment.id
      team_id = participant.team.try(:id)
      @bids = ReviewBid.where(participant_id: params[:participant_id])
      signed_up_topics = ReviewBid.where(participant_id: params[:participant_id]).map(&:sign_up_topic_id)
      signed_up_topics -= params[:topic].map(&:to_i)
      signed_up_topics.each do |topic|
        ReviewBid.where(sign_up_topic_id: topic, participant_id: params[:participant_id]).destroy_all
      end
      params[:topic].each_with_index do |topic_id, index|
        bid_existence = ReviewBid.where(sign_up_topic_id: topic_id, participant_id: params[:participant_id])
        if bid_existence.empty?
          ReviewBid.create(priority: index + 1,sign_up_topic_id: topic_id, participant_id: params[:participant_id],assignment_id: assignment_id)
        else
          ReviewBid.where(sign_up_topic_id: topic_id, participant_id: params[:participant_id]).update_all(priority: index + 1)
        end
      end
    end
  end

  #colour of a particular assignment criterion
  def get_quartiles(topic_id)
    assignment_id = SignUpTopic.where(id: topic_id).pluck(:assignment_id).first
    num_reviews_allowed = Assignment.where(id: assignment_id).pluck(:num_reviews_allowed).first
    num_participants_in_assignment = AssignmentParticipant.where(parent_id: assignment_id).length
    num_topics_in_assignment = SignUpTopic.where(assignment_id: assignment_id).length
    num_choosers_this_topic = ReviewBid.where(sign_up_topic_id: topic_id).length
    avg_reviews_per_topic = (num_participants_in_assignment*num_reviews_allowed)/num_topics_in_assignment

    if num_choosers_this_topic < avg_reviews_per_topic/2
      return 'rgb(124,252,0)'
    elsif num_choosers_this_topic > avg_reviews_per_topic/2 and num_choosers_this_topic < avg_reviews_per_topic
      return 'rgb(255,255,0)'
    else
      return 'rgb(255,99,71)'
    end
  end
  helper_method :get_quartiles
end