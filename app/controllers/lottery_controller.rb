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
    topics = SignUpTopic.where(assignment_id: params[:id]).map{ |t| t.id}
    # students is a list of student ids in an assignment
    students = Participant.where(parent_id: params[:id]).map{ |p| p.user_id}
    students.each do |student|
      #grab student id and list of bids
      bids = Bid.where(team_id: student).map{|b| {priority:b.priority,topic_id:b.topic_id}}.sort_by{ |b| [topics.index(b[:topic_id])]}
      topics.each do |topic|
        if !bids.any? {|b| b[:topic_id] == topic}
          bids.insert(topics.index(topic),{priority:0,topic_id:topic})
        end
      end
      json_info << {"pid"=>student,"ranks"=>bids.map{|b| b[:priority] ||= 0}}
    end
    # req = Net::HTTP::Post.new('/reputation/calculations/reputation_algorithms', initheader = {'Content-Type' => 'application/json', 'charset' => 'utf-8'})
    json_data = {'Content-Type' => 'application/json',"users"=>json_info,"max_team_size"=>Assignment.find_by_id(params[:id]).max_team_size}
    #send json_data with a get request and get teams
    uri = URI.parse("http://peerlogic.csc.ncsu.edu/intelligent_assignment/merge_teams")
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri.request_uri, initheader = {'Content-Type' => 'application/json', 'charset' => 'utf-8'})
binding.pry
    request.body = json_data.to_json()
    response = http.request(request)
    teams = JSON.parse(response.body)["teams"]
    teams.each do |team|
      t = nil
      #find if existing team exists
      team.each do |student|
        TeamsUser.where(user_id: student).each do |user|
          nTeam = Team.where(id: user.team_id, parent_id: params[:id]).first
          if t.nil? and !nTeam.nil?
            t = nTeam
          end
        end
      end
      if t.nil?
        #create the team
        t = AssignmentTeam.create(parent_id: params[:id])
      end
      team.each do |student|
        #make the teamid of each student in team the team id of first student
        if TeamsUser.where(user_id: student, team_id: t.id).first.nil?
          TeamsUser.create(user_id: student, team_id: t.id) 
        end
      end
    end

    redirect_to controller: 'tree_display', action: 'list'
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
    # unassignedTeams = Bid.where(topic: SignUpTopic.where(assignment_id: params[:id])).uniq.pluck(:team_id) # Get all unassigned teams,. Will be used for merging
    unassignedTeams = Team.where(parent_id: params[:id]).reject {|t| !SignedUpTeam.where(team_id: t.id).empty?}
    sign_up_topics = SignUpTopic.includes(bids: [{team: [:users]}]).where("assignment_id = ? and max_choosers > 0", params[:id]) # Getting signuptopics with max_choosers > 0
    topicsBidsArray = []
    sign_up_topics.each do |topic|
      team_bids = []
      unassignedTeams.each do |team|
        student_bids = []
        TeamsUser.where(team_id: team).each do |s|
          puts s.user_id
          puts topic.id
          if !Bid.where(team_id: s.user_id, topic_id: topic.id).empty?
            student_bids<< Bid.where(team_id: s.user_id, topic_id: topic.id).first.priority
          else
            student_bids << 0
          end
        end
        freq = student_bids.inject(Hash.new(0)) { |h,v| h[v] += 1; h}
        team_bids << {team_id: team.id,priority: student_bids.max_by { |v| freq[v] }}
      end
      topicsBidsArray << [topic,team_bids.sort_by {|b| [TeamsUser.where(["team_id = ?", b[:team_id]]).count * -1, b[:priority], rand(100)] }]
    end
    puts topicsBidsArray
    # # initializing all topics with bidder rankings(team strength, priority)
    # topicsBidsArray = [] # Array of [Topic, sortedBids]
    # sign_up_topics.each do |topic|
    #   topicsBidsArray << [topic, topic.bids.sort_by {|b| [(b.team.users.size * -1), b.priority, rand(100)] }] # If strength and priority are equal, then randomize
    # end

    # # Run stable match
    # until topicsBidsArray.empty?
    #   currentTopic = topicsBidsArray[0][0]
    #   sortedBids = topicsBidsArray[0][1]
    #   canRemoveTopic = false
    #   if sortedBids.nil? || sortedBids.empty? # No more teams have bid for the topic
    #     canRemoveTopic = true
    #   else
    #     currentBestBid = sortedBids[0]
    #     if !finalTeamTopics.key?(currentBestBid.team.id) # If the current best bid has no other topic, blindly assign the topic
    #       finalTeamTopics[currentBestBid.team.id] = [currentTopic, sortedBids]
    #       canRemoveTopic = true
    #     else
    #       prevTeamTopic = finalTeamTopics[currentBestBid.team.id][0]
    #       prevSortedBids = finalTeamTopics[currentBestBid.team.id][1]
    #       otherBid = currentBestBid.team.bids.where(topic_id: prevTeamTopic.id).first
    #       if currentBestBid.priority < otherBid.priority # The team prefers the current topic
    #         finalTeamTopics[currentBestBid.team.id] = [currentTopic, sortedBids]
    #         prevSortedBids.delete_at(0)
    #         topicsBidsArray << [prevTeamTopic, prevSortedBids]
    #         canRemoveTopic = true
    #       else # remove the bidder from the current topic as team is already assigned to a more preferrable topic
    #         sortedBids.delete_at(0)
    #       end
    #     end
    #   end
    #   next unless canRemoveTopic
    #   if currentTopic.max_choosers == 1
    #     topicsBidsArray.delete_at(0)
    #   else
    #     currentTopic.max_choosers = currentTopic.max_choosers - 1
    #   end
    # end

    # finalTeamTopics.keys.each do |team_id|
    #   SignedUpTeam.create(team_id: team_id, topic_id: finalTeamTopics[team_id][0].id) # Create mappings for all winners
    #   unassignedTeams.delete(team_id)
    # end

    # auto_merge_teams unassignedTeams, finalTeamTopics

    # # Remove is_intelligent property from assignment so that it can revert to the default signup state
    # assignment = Assignment.find(params[:id])
    # assignment.update_attribute(:is_intelligent, false)

    #flash[:notice] = 'The intelligent assignment was successfully completed for ' + assignment.name + '.'
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
