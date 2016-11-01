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
    user_ids = Participant.where(parent_id: params[:id]).map(&:user_id)
    user_ids.each do |user_id|
      #grab student id and list of bids
      bids = []
      topic_ids.each do |topic_id|
        bid_record = Bid.where(user_id: user_id, topic_id: topic_id).first rescue nil
        if bid_record.nil?
          bids << 0
        else
          bids << bid_record.priority ||= 0
        end
      end
      if bids.uniq != [0]
        priority_info << {pid: user_id, ranks: bids}
      end
    end
    assignment = Assignment.find_by_id(params[:id])
    data = {users: priority_info, max_team_size: assignment.max_team_size}
    url = WEBSERVICE_CONFIG["topic_bidding_webservice_url"]
    begin
      response = RestClient.post url, data.to_json, :content_type => :json, :accept => :json
      # store each summary in a hashmap and use the question as the key
      teams = JSON.parse(response)["teams"]
    rescue => err
      flash[:error] = err.message
    end
    teams =  [
 [6817, 6812, 6830, 6876],
 [6878, 6861, 6413, 6856],
 [6871, 6818, 6899, 6912],
 [6853, 6895, 6913, 6814],
 [6845, 6900, 6909],
 [6810, 6891, 6905],
 [6815, 6825, 6916, 6923]]
    create_new_teams_for_bidding_response(teams, assignment)
    run_intelligent_bid

    redirect_to controller: 'tree_display', action: 'list'
  end

  def create_new_teams_for_bidding_response(teams, assignment)
    teams.each_with_index do |user_ids, index|
      new_team = AssignmentTeam.create(name: assignment.name + '_Team' + rand(1000).to_s, 
                                       parent_id: assignment.id, 
                                       type: 'AssignmentTeam')
      parent = TeamNode.create(parent_id: assignment.id, node_object_id: new_team.id)
      user_ids.each do |user_id|
        team_user = TeamsUser.where(user_id: user_id, team_id: new_team.id).first rescue nil
        team_user = TeamsUser.create(user_id: user_id, team_id: new_team.id) if team_user.nil?
        TeamUserNode.create(parent_id: parent.id, node_object_id: team_user.id) 
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
    # Getting signuptopics with max_choosers > 0
    sign_up_topics = SignUpTopic.where("assignment_id = ? and max_choosers > 0", params[:id]) 
    unassignedTeams = AssignmentTeam.where(parent_id: params[:id]).reject {|t| !SignedUpTeam.where(team_id: t.id).empty?}
    unassignedTeams.sort! {|t1, t2| TeamsUser.where(team_id: t2.id).size <=> TeamsUser.where(team_id: t1.id).size}
    team_bids = []
    unassignedTeams.each do |team|
      topic_bids = []
      sign_up_topics.each do |topic|
        student_bids = []
        TeamsUser.where(team_id: team.id).each do |s|
          student_bid = Bid.where(user_id: s.user_id, topic_id: topic.id).first rescue nil
          if !student_bid.nil? and !student_bid.priority.nil?
            student_bids << student_bid.priority
          end
        end
        #takes the most frequent priority as the team priority
        freq = student_bids.inject(Hash.new(0)) { |h,v| h[v] += 1; h}
        topic_bids << {topic_id: topic.id, priority: student_bids.max_by { |v| freq[v] }} unless freq.empty?
      end
      topic_bids.sort! {|b| b[:priority]}
      team_bids << {team_id: team.id, bids: topic_bids}
    end

    team_bids.each do |tb|
      tb[:bids].each do |bid|
        signed_up_team = SignedUpTeam.where(topic_id: bid[:topic_id]).first rescue nil
        if signed_up_team.nil?
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
  end

  # This method is called to automerge smaller teams to teams which were assigned topics through intelligent assignment
  def auto_merge_teams(unassignedTeams, _finalTeamTopics)
    assignment = Assignment.find(params[:id])
    # Sort unassigned
    unassignedTeams = Team.where(id: unassignedTeams).sort_by {|t| !t.users.size }
    unassignedTeams.each do |team|
      sortedBids = Bid.where(user_id: team.id).sort_by(&:priority) # Get priority for each unassignmed team
      sortedBids.each do |b|
        # SignedUpTeam.where(:topic=>b.topic_id).first.team_id
        winningTeam = SignedUpTeam.where(topic: b.topic_id).first.team_id
        next unless TeamsUser.where(team_id: winningTeam).size + team.users.size <= assignment.max_team_size # If the team can be merged to a bigger team
        TeamsUser.where(team_id: team.id).update_all(team_id: winningTeam)
        Bid.delete_all(user_id: team.id)
        Team.delete(team.id)
        break
      end
    end
  end
end
