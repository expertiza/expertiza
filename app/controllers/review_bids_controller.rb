# TODO 
# Bidding data - 

class ReviewBidsController < ApplicationController
  require "json"
  require "net/http"

  #action allowed function checks the action allowed based on the user working
  def action_allowed?
    case params[:action]
    when 'show', 'review_bid', 'set_priority'
      ['Instructor',
       'Teaching Assistant',
       'Administrator',
       'Super-Administrator',
       'Student'].include? current_role_name and
      ((%w[list].include? action_name) ? are_needed_authorizations_present?(params[:id], "participant" "reader", "submitter", "reviewer") : true)
    else
      ['Instructor',
       'Teaching Assistant',
       'Administrator',
       'Super-Administrator'].include? current_role_name
    end
  end  

  # GET /review_bids
  def index
    @review_bids = ReviewBid.all
  end

  # GET /review_bids/1
  def show
    @participant = AssignmentParticipant.find(params[:id].to_i)
    @assignment = @participant.assignment
    @sign_up_topics = SignUpTopic.where(assignment_id: @assignment.id, private_to: nil)
    team_id = @participant.team.try(:id)
    my_topic = SignedUpTeam.where(team_id: team_id).pluck(:topic_id).first
    @sign_up_topics -= SignUpTopic.where(assignment_id: @assignment.id, id: my_topic)
    @max_team_size = @assignment.num_reviews_allowed 
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
  end
  
  def set_priority
    if params[:topic].nil?
      ReviewBid.where(participant_id: params[:id]).destroy_all
    else
      participant = AssignmentParticipant.find_by(id: params[:id])
      assignment_id = SignUpTopic.find(params[:topic].first).assignment.id
      # team_id = participant.team.try(:id)
      @bids = ReviewBid.where(participant_id: params[:id])
      signed_up_topics = ReviewBid.where(participant_id: params[:id]).map(&:signuptopic_id)
      signed_up_topics -= params[:topic].map(&:to_i)
      signed_up_topics.each do |topic|
        ReviewBid.where(signuptopic_id: topic, participant_id: params[:id]).destroy_all
      end
      params[:topic].each_with_index do |topic_id, index|
        bid_existence = ReviewBid.where(signuptopic_id: topic_id, participant_id: params[:id])
        if bid_existence.empty?
          ReviewBid.create(priority: index + 1,signuptopic_id: topic_id, participant_id: params[:id],assignment_id: assignment_id)
        else
          ReviewBid.where(signuptopic_id: topic_id, participant_id: params[:id]).update_all(priority: index + 1)
        end
      end
    end
    redirect_to action: 'show', assignment_id: params[:assignment_id], id: params[:id]
  end

  # GET /review_bids/new
  def new
    @review_bid = ReviewBid.new
  end

  # GET /review_bids/1/edit
  def edit
  end

  # POST /review_bids
  def create
    # @review_bid = ReviewBid.new(review_bid_params)
    # if @review_bid.save
    #   redirect_to @review_bid, notice: 'Review bid was successfully created.'
    # else
    #   render :new
    # end
  end


  # assign bidding topics to reviewers
  def assign_bidding
    #parameters for running bidding algorithm
      participant = AssignmentParticipant.find(params[:id].to_i)
      assignment_id = participant.assignment
      reviewers = ReviewBid.reviewers(assignment_id) # TODO (maybe finished) create to get list of reviewers
      topics = SignUpTopic.where(assignment_id: assignment_id).ids
      bidding_data = ReviewBid.get_bidding_data(assignment_id,reviewers) # TODO create this function with info we want for WebService
  
    #runs algorithm and assigns reviews
      matched_topics = run_bidding_algorithm(bidding_data,topics,assignment_id) # TODO already started, adjust for our values
      ReviewBid.assign_review_topics(assignment_id,reviewers,matched_topics) # TODO create to assign the return matching reviews to students
      Assignment.find(assignment_id).update(can_choose_topic_to_review: false)  #turns off bidding for students
      redirect_to :back
    end

  # call webserver for running assigning algorthim
  # passing webserver: student_ids, topic_ids, student_preferences, topic_preferences
  # webserver returns: 
  # returns matched assignments as json body
  def run_bidding_algorithm(bidding_data,topics,assignment_id)
    # begin
      num_reviews_allowed = Assignment.where(id:assignment_id).pluck(:num_reviews_allowed).first
      raw_webserver_input_hash = {"users": bidding_data, "tids": topics, "q_S": num_reviews_allowed} #TODO adjust hash values
      uri = URI.parse(WEBSERVICE_CONFIG["review_bidding_webservice_url"])
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Post.new(uri.path, {'Content-Type' => 'application/json'})
      http.use_ssl = true
      request.body = raw_webserver_input_hash.to_json
      response = http.request(request)
      return JSON.parse(response.body)
    rescue StandardError
      return false
    # end
  end

end
