class ReviewBidsController < ApplicationController
  require "net/http"
  #require "uri"
  require "json"

  def action_allowed?
    case params[:action]
    when 'review_bid', 'assign_review_priority'
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
    reviewers = ReviewBid.assignment_reviewers(assignment_id)
    topics = SignUpTopic.where(assignment_id: assignment_id).ids
    bidding_data = ReviewBid.assignment_bidding_data(assignment_id,reviewers)
    matched_topics = reviewer_topic_matching(bidding_data,topics,assignment_id)
    ReviewBid.assign_matched_topics(assignment_id,reviewers,matched_topics)
    redirect_to :back
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


  # display the review topics to bid
  def review_bid
    @participant = AssignmentParticipant.find(params[:id].to_i)
    @assignment = @participant.assignment
    @sign_up_topics = SignUpTopic.where(assignment_id: @assignment.id, private_to: nil)
    team_id = @participant.team.try(:id)
    my_topic = SignedUpTeam.where(team_id: team_id).pluck(:topic_id).first
    @sign_up_topics -= SignUpTopic.where(assignment_id: @assignment.id, id: my_topic)
    @max_team_size = @assignment.max_team_size #this is not being used in the review_bid.html.erb. Remove if not needed
    @no_of_participants = AssignmentParticipant.where(parent_id: @assignment.id).count
    @selected_topics = nil
    @bids = team_id.nil? ? [] : ReviewBid.where(participant_id:@participant,assignment_id:@assignment.id).order(:priority)
    signed_up_topics = []
    @bids.each do |bid|
      sign_up_topic = SignUpTopic.find_by(id: bid.signuptopic_id)
      signed_up_topics << sign_up_topic if sign_up_topic
    end
    signed_up_topics &= @sign_up_topics
    @sign_up_topics -= signed_up_topics
    @bids = signed_up_topics
    @num_of_topics = @sign_up_topics.size
    render 'sign_up_sheet/review_bid'
  end

  def assign_review_priority
    if params[:topic].nil?
      ReviewBid.where(participant_id: params[:participant_id]).destroy_all
    else
      participant = AssignmentParticipant.find_by(id: params[:participant_id])
      assignment_id = SignUpTopic.find(params[:topic].first).assignment.id
      team_id = participant.team.try(:id)
      @bids = ReviewBid.where(participant_id: params[:participant_id])
      signed_up_topics = ReviewBid.where(participant_id: params[:participant_id]).map(&:signuptopic_id)
      signed_up_topics -= params[:topic].map(&:to_i)
      signed_up_topics.each do |topic|
        ReviewBid.where(signuptopic_id: topic, participant_id: params[:participant_id]).destroy_all
      end
      params[:topic].each_with_index do |topic_id, index|
        bid_existence = ReviewBid.where(signuptopic_id: topic_id, participant_id: params[:participant_id])
        if bid_existence.empty?
          ReviewBid.create(priority: index + 1,signuptopic_id: topic_id, participant_id: params[:participant_id],assignment_id: assignment_id)
        else
          ReviewBid.where(signuptopic_id: topic_id, participant_id: params[:participant_id]).update_all(priority: index + 1)
        end
      end
    end
  end
end
