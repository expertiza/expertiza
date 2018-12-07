class ReviewBidsController < LotteryController
  #intelligently assign reviews to participants
  def run_intelligent_assignment
    assignment = Assignment.find_by(id: params[:id])
    teams = Team.where(parent_id: params[:id]).map(&:id)
    participants = AssignmentParticipant.where(parent_id: params[:id])
    participant_ranks = []
    participants.each do |participant|
      ranks = ReviewBid.get_rank(assignment, teams, participant)
      participant_ranks << {pid: participant.id, ranks: ranks}
    end
    #we have the availability of topics and ranks of users' choices towards submission now. 
    data = {
      users: participant_ranks, 
      item_size: assignment.max_reviews_per_submission,
      assign_size: assignment.num_reviews_required,
    }
    url = WEBSERVICE_CONFIG["review_bidding_webservice_url"]
    begin
      response = RestClient.post url, data.to_json, content_type: :json, accept: :json
      bid_result = JSON.parse(response)["info"]
      response_mappings = run_intelligent_bid(assignment, teams, participants, bid_result)
      create_response_mappings(assignment, response_mappings)
    rescue StandardError => err
      flash[:error] = err.message
    end
    #render :json => response_mappings.to_json
    redirect_to controller: 'tree_display', action: 'list'
  end
  # 
  def run_intelligent_bid(assignment, teams, participants, bid_result)
  	team_assigned_count = {}
  	participant_count = {}
  	response_mappings = []
  	participants.each do |participant|
  	  participant_count[participant.id] = 0
  	end
  	teams.each do |team|
  	  team_assigned_count[team] = 0
  	end
  	bid_result.each do |participant_bid|
  	  participant_bid["items"].each do |team_id|
  	  	# make a record for the bidding result from peerlogic
  	  	response_mappings << {pid: participant_bid["pid"], team: team_id}
  	  	# counting how many participants are assigned with this team
  	  	team_assigned_count[team_id] += 1
  	  	# counting how many reviews are assigned to each participant
  	  	participant_count[participant_bid["pid"]] += 1
  	  end
  	end
  	participants.each do |participant|
  	  while participant_count[participant.id] < assignment.num_reviews_required
  	  	team = teams[rand(teams.count)]
  	  	next if team_assigned_count[team] >= assignment.max_reviews_per_submission
  	  	team_assigned_count[team] += 1
  	  	participant_count[participant.id] += 1
  	  	response_mappings << {pid: participant.id, team: team}
  	  end
  	end
  	return response_mappings
  end
  def create_response_mappings(assignment, response_mappings)
  	response_mappings.each do |map|
  	  ReviewResponseMap.create(reviewed_object_id: assignment.id,
  	  	reviewer_id: map[:pid], reviewee_id: map[:team])
  	end
  end
end
