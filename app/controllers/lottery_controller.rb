class LotteryController < ApplicationController
  # Give permission to run the bid to appropriate roles
  def action_allowed?
    ['Instructor',
     'Teaching Assistant',
     'Administrator'].include? current_role_name
  end

  def run_intelligent_assignment
    json_info = []
    #get topics for assignment
    topics = SignUpTopic.where(assignment_id: params[:id])
    topics.each do |t|
      t = t.id
    end
    # students is a list of student ids in an assignment
    students = Participant.where(parent_id: params[:id])
    students.each do |student|
      #grab student id and list of bids
      s = student.id
      bids = Bid.where(team_id: s).sort_by{ |b| [topics.index(b.topic_id)]}
      json_info << {"pid"=>s,"ranks"=>bids.map{|b| b.priority}}
    end
    json_data = {"users"=>json_info,"max_team_size"=>Assignment.find_by_id(params[:id]).max_team_size}
    #send json_data with a get request and get teams
    response = Net::HTTP.post_form(URI("http://peerlogic.csc.ncsu.edu/intelligent_assignment/merge_teams/"), json_data)
    puts "a;ldfja;lfjalk;sfjal;kjfl;kasjfl;asjdfl;ajsdf;lajsdf;lajsdf;lkajs;ldfja;sldfja;lsdjfa;lsdjf;laksdjf"
    puts response.body
    teams = JSON.parse(response.body)["teams"]
    teams.each do |team|
      captain = TeamsUser.where(user_id: team[0]).team_id
      team.each do |student|
        #make the teamid of each student in team the team id of first student
        TeamsUser.where(user_id: student).team_id = captain 
      end
    end
  end

  # This method is called for assignments which have their is_intelligent property set to 1. It runs a stable match algorithm and assigns topics
  # to strongest contenders (team strength, priority of bids)
  def run_intelligent_bid
    unless Assignment.find_by_id(params[:id]).is_intelligent # if the assignment is intelligent then redirect to the tree display list
      flash[:error] = "This action not allowed. The assignment " + Assignment.find_by_id(params[:id]).name + " does not enabled intelligent assignments."
      redirect_to controller: 'tree_display', action: 'list'
      return
    end

    finalTeamTopics = {} # Hashmap (Team,Topic) to store teams which have been assigned topics
    unassignedTeams = Bid.where(topic: SignUpTopic.where(assignment_id: params[:id])).uniq.pluck(:team_id) # Get all unassigned teams,. Will be used for merging
    sign_up_topics = SignUpTopic.includes(bids: [{team: [:users]}]).where("assignment_id = ? and max_choosers > 0", params[:id]) # Getting signuptopics with max_choosers > 0

    # initializing all topics with bidder rankings(team strength, priority)
    topicsBidsArray = [] # Array of [Topic, sortedBids]
    sign_up_topics.each do |topic|
      topicsBidsArray << [topic, topic.bids.sort_by {|b| [(b.team.users.size * -1), b.priority, rand(100)] }] # If strength and priority are equal, then randomize
    end

    # Run stable match
    until topicsBidsArray.empty?
      currentTopic = topicsBidsArray[0][0]
      sortedBids = topicsBidsArray[0][1]
      canRemoveTopic = false
      if sortedBids.nil? || sortedBids.empty? # No more teams have bid for the topic
        canRemoveTopic = true
      else
        currentBestBid = sortedBids[0]
        if !finalTeamTopics.key?(currentBestBid.team.id) # If the current best bid has no other topic, blindly assign the topic
          finalTeamTopics[currentBestBid.team.id] = [currentTopic, sortedBids]
          canRemoveTopic = true
        else
          prevTeamTopic = finalTeamTopics[currentBestBid.team.id][0]
          prevSortedBids = finalTeamTopics[currentBestBid.team.id][1]
          otherBid = currentBestBid.team.bids.where(topic_id: prevTeamTopic.id).first
          if currentBestBid.priority < otherBid.priority # The team prefers the current topic
            finalTeamTopics[currentBestBid.team.id] = [currentTopic, sortedBids]
            prevSortedBids.delete_at(0)
            topicsBidsArray << [prevTeamTopic, prevSortedBids]
            canRemoveTopic = true
          else # remove the bidder from the current topic as team is already assigned to a more preferrable topic
            sortedBids.delete_at(0)
          end
        end
      end
      next unless canRemoveTopic
      if currentTopic.max_choosers == 1
        topicsBidsArray.delete_at(0)
      else
        currentTopic.max_choosers = currentTopic.max_choosers - 1
      end
    end

    finalTeamTopics.keys.each do |team_id|
      SignedUpTeam.create(team_id: team_id, topic_id: finalTeamTopics[team_id][0].id) # Create mappings for all winners
      unassignedTeams.delete(team_id)
    end

    auto_merge_teams unassignedTeams, finalTeamTopics

    # Remove is_intelligent property from assignment so that it can revert to the default signup state
    assignment = Assignment.find(params[:id])
    assignment.update_attribute(:is_intelligent, false)

    flash[:notice] = 'The intelligent assignment was successfully completed for ' + assignment.name + '.'
    redirect_to controller: 'tree_display', action: 'list'
  end

  # This method is called to automerge smaller teams to teams which were assigned topics through intelligent assignment
  def auto_merge_teams(unassignedTeams, _finalTeamTopics)
    assignment = Assignment.find(params[:id])

    # Sort unassigned
    unassignedTeams = Team.where(id: unassignedTeams).sort_by {|t| !t.users.size }
    unassignedTeams.each do |team|
      sortedBids = Bid.where(team_id: team.id).sort_by(&:priority) # Get priority for each unassignmed team
      sortedBids.each do |b|
        # SignedUpTeam.where(:topic=>b.topic_id).first.team_id
        winningTeam = SignedUpTeam.where(topic: b.topic_id).first.team_id
        next unless TeamsUser.where(team_id: winningTeam).size + team.users.size <= assignment.max_team_size # If the team can be merged to a bigger team
        TeamsUser.where(team_id: team.id).update_all(team_id: winningTeam)
        Bid.delete_all(team_id: team.id)
        Team.delete(team.id)
        break
      end
    end
  end
end
