class LotteryController < ApplicationController

  def action_allowed?
    ['Instructor',
       'Teaching Assistant',
       'Administrator'].include? current_role_name
  end

  def run_intelligent_bid
    #finalUserTopics = Hash.new
    finalTeamTopics = Hash.new #Hashmap (Team,Topic)
    sign_up_topics = SignUpTopic.where(assignment_id: params[:id])
    #initializing all topics with bidder rankings
    topicsBidsArray = Array.new #Hashmap (Topic, sortedBids)

    sign_up_topics.each do |topic|
      topicsBidsArray << [topic, topic.bids.sort_by {|b| [(b.team.users.size * -1), b.priority, rand(100)]} ]#If strength and priority are equal, then randomize
    end


    while (topicsBidsArray.size != 0)
      currentTopic = topicsBidsArray[0][0]
      sortedBids = topicsBidsArray[0][1]
      canRemoveTopic = false
      if(sortedBids.nil? || sortedBids.size == 0)
        canRemoveTopic = true
      else
        currentBestBid = sortedBids[0]
        if(!finalTeamTopics.has_key?(currentBestBid.team.id))
          finalTeamTopics[currentBestBid.team.id]=[currentTopic,sortedBids]
          canRemoveTopic = true
        else
          prevTeamTopic = finalTeamTopics[currentBestBid.team.id][0]
          prevSortedBids = finalTeamTopics[currentBestBid.team.id][1]
          otherBid = currentBestBid.team.bids.where(:topic_id => prevTeamTopic.id).first
          if(currentBestBid.priority < otherBid.priority) #The team prefers the current topic
            finalTeamTopics[currentBestBid.team.id] = [currentTopic,sortedBids]
            prevSortedBids.delete_at(0)
            topicsBidsArray << [prevTeamTopic,prevSortedBids]
            canRemoveTopic = true
          else
            sortedBids.delete_at(0)
          end
        end
      end
      if(canRemoveTopic)
        if(currentTopic.max_choosers == 1)
          topicsBidsArray.delete_at(0) #Unsure if it works
        else
          currentTopic.max_choosers=currentTopic.max_choosers-1
        end
      end
    end

    finalTeamTopics.keys.each do |team_id|
      SignedUpUser.create(:creator_id=>team_id,:topic_id => finalTeamTopics[team_id][0].id)
    end

    assignment = Assignment.find(params[:id])
    assignment.is_intelligent = false
    assignment.save
	

    flash[:notice] = 'Intelligent assignment of successfully completed for ' + assignment.name + '.'
    redirect_to :controller => 'tree_display', :action => 'list'
  end
end


