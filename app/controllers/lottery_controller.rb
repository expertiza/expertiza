class LotteryController < ApplicationController

  require 'json'
  require 'rest_client'

  # Give permission to run the bid to appropriate roles
  def action_allowed?
    ['Instructor',
     'Teaching Assistant',
     'Administrator'].include? current_role_name
  end

  # This method is to send request to web service and use k-means and students' bidding data to build teams automatically.
  def run_intelligent_assignment
    priority_info = []
    topic_ids = SignUpTopic.where(assignment_id: params[:id]).map(&:id)
    student_ids = Participant.where(parent_id: params[:id]).map(&:user_id)
    student_ids.each do |student_id|
      #grab student id and list of bids
      bids = []
      topic_ids.each do |topic_id|
        bid_record = Bid.where(user_id: student_id, topic_id: topic_id).first rescue nil
        if bid_record.nil?
          bids << 0
        else
          bids << bid_record.priority ||= 0
        end
      end
      priority_info << {pid: student_id, ranks: bids}
    end

    data = {users: priority_info, max_team_size: Assignment.find_by_id(params[:id]).max_team_size}
    url = "http://peerlogic.csc.ncsu.edu/intelligent_assignment/merge_teams"
    begin
      response = RestClient.post url, data.to_json, :content_type => :json, :accept => :json
      # store each summary in a hashmap and use the question as the key
      teams = JSON.parse(response)["teams"]
    rescue => err
      flash[:error] = err.message
    end
# TODO: refactor after get the response bodey structure
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

    sign_up_topics = SignUpTopic.includes(bids: [{team: [:users]}]).where("assignment_id = ? and max_choosers > 0", params[:id]) # Getting signuptopics with max_choosers > 0
    unassignedTeams = Team.where(parent_id: params[:id]).reject {|t| !SignedUpTeam.where(team_id: t.id).empty?}
    unassignedTeams.sort! {|t| TeamsUser.where(team_id: t.id).count*-1}

    team_bids = []
    unassignedTeams.each do |team|
      topic_bids = []
      sign_up_topics.each do |topic|
        student_bids = []
        TeamsUser.where(team_id: team).each do |s|
          if !Bid.where(team_id: s.user_id, topic_id: topic.id).empty?
            student_bids<< Bid.where(team_id: s.user_id, topic_id: topic.id).first.priority
          else
            student_bids << 0
          end
        end
        #takes the most frequent priority as the team priority
        freq = student_bids.inject(Hash.new(0)) { |h,v| h[v] += 1; h}
        topic_bids << {topic_id: topic,priority: student_bids.max_by { |v| freq[v] }}
      end
      topic_bids.sort! {|b| b[:priority]}
      team_bids<<{team_id: team.id,bids: topic_bids}
    end

    team_bids.each do |tb|
      tb[:bids].each do |bid|
        if !SignedUpTeam.exists?(topic_id: bid[:topic_id])
          SignedUpTeam.create(team_id: tb[:team_id], topic_id: bid[:topic_id])
          break
        end
      end
    end

    #auto_merge_teams unassignedTeams, finalTeamTopics

    #Remove is_intelligent property from assignment so that it can revert to the default signup state
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