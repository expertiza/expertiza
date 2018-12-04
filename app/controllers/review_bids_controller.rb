class ReviewBidsController < LotteryController
  #intelligently assign reviews to participants
  def run_intelligent_assignment
    assignment = Assignment.find_by(id: params[:id])
    slot_size = assignment.max_reviews_per_submission
    participants = AssignmentParticipant.where(parent_id: params[:id])
    topics = SignUpTopic.where(assignment_id: params[:id])
    selected_topics = []
    priority_info = {}
    #insert a record for each participant in the priority_info
    participants.each do |participant|
      priority_info[participant.id] = []
    end
    #for each topic, get the bidding records and available slots
    topics.each do |topic|
      bid_records = ReviewBid.where(topic_id: topic.id)
      signed_up_teams = SignedUpTeam.where(topic: topic.id)
      next if signed_up_teams.empty?
      selected_topics << {topic: topic.id, size: signed_up_teams.size*slot_size}
      next if bid_records.empty?
      bid_records.each do |bid|
      	priority_info[bid.participant_id] << {topic: topic.id, rank: bid.priority}
      end
    end
    users = []
    priority_info.each do |participant, ranks|
      next if ranks.empty?
      users << {pid: participant, ranks: ranks}
    end
    #we have the availability of topics and ranks of users' choices towards topics now. 
    data = {topics: selected_topics, users: users}
    url = WEBSERVICE_CONFIG["review_bidding_webservice_url"]
    begin
      response = RestClient.post url, data.to_json, content_type: :json, accept: :json
      run_intelligent_bid(assignment)
    rescue StandardError => err
      flash[:error] = err.message
    end
    render :json => response
    #redirect_to controller: 'tree_display', action: 'list'
  end

  def run_intelligent_bid(assignment)
  	ReviewResponseMap.create(reviewed_object_id: assignment.id, reviewer_id: 39987, reviewee_id: 30272, calibrate_to: true)
  end
end
