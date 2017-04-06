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
      # grab student id and list of bids
      bids = []
      topic_ids.each do |topic_id|
        bid_record = Bid.where(user_id: user_id, topic_id: topic_id).first rescue nil
        bids << (bid_record.nil? ? 0 : bid_record.priority ||= 0)
      end
      priority_info << {pid: user_id, ranks: bids} if bids.uniq != [0]
    end
    assignment = Assignment.find_by(id: params[:id])
    data = {users: priority_info, max_team_size: assignment.max_team_size}
    url = WEBSERVICE_CONFIG["topic_bidding_webservice_url"]
    begin
      response = RestClient.post url, data.to_json, content_type: :json, accept: :json
      # store each summary in a hashmap and use the question as the key
      teams = JSON.parse(response)["teams"]
      create_new_teams_for_bidding_response(teams, assignment)
      run_intelligent_bid
    rescue => err
      flash[:error] = err.message
    end

    redirect_to controller: 'tree_display', action: 'list'
  end

  def create_new_teams_for_bidding_response(teams, assignment)
    original_team_ids = assignment.teams.map(&:id)
    teams.each do |user_ids|
      new_team = AssignmentTeam.create(name: assignment.name + '_Team' + rand(1000).to_s,
                                       parent_id: assignment.id,
                                       type: 'AssignmentTeam')
      parent = TeamNode.create(parent_id: assignment.id, node_object_id: new_team.id)
      user_ids.each do |user_id|
        # remove TeamsUser records on other teams
        original_team_ids.each do |id|
          team_users = TeamsUser.where(user_id: user_id, team_id: id) rescue nil
          next unless team_users
          team_users.each do |team_user|
            team_user.team_user_node.destroy
            team_user.destroy
          end
        end
        team_user = TeamsUser.where(user_id: user_id, team_id: new_team.id).first rescue nil
        team_user = TeamsUser.create(user_id: user_id, team_id: new_team.id) if team_user.nil?
        TeamUserNode.create(parent_id: parent.id, node_object_id: team_user.id)
      end
    end
    # remove empty teams
    assignment.teams.each do |team|
      if team.teams_users.empty?
        TeamNode.where(parent_id: assignment.id, node_object_id: team.id).destroy_all
        team.destroy
      end
    end
  end

  # This method is called for assignments which have their is_intelligent property set to 1. It runs a stable match algorithm and assigns topics
  # to strongest contenders (team strength, priority of bids)
  def run_intelligent_bid
    unless Assignment.find_by(id: params[:id]).is_intelligent # if the assignment is intelligent then redirect to the tree display list
      flash[:error] = "This action not allowed. The assignment " + Assignment.find_by(id: params[:id]).name + " does not enabled intelligent assignments."
      redirect_to controller: 'tree_display', action: 'list'
      return
    end
    # Getting signuptopics with max_choosers > 0
    sign_up_topics = SignUpTopic.where("assignment_id = ? and max_choosers > 0", params[:id])
    unassigned_teams = AssignmentTeam.where(parent_id: params[:id]).reject {|t| !SignedUpTeam.where(team_id: t.id).empty? }
    unassigned_teams.sort! {|t1, t2| TeamsUser.where(team_id: t2.id).size <=> TeamsUser.where(team_id: t1.id).size }
    team_bids = []
    unassigned_teams.each do |team|
      topic_bids = []
      sign_up_topics.each do |topic|
        student_bids = []
        TeamsUser.where(team_id: team.id).each do |s|
          student_bid = Bid.where(user_id: s.user_id, topic_id: topic.id).first rescue nil
          if !student_bid.nil? and !student_bid.priority.nil?
            student_bids << student_bid.priority
          end
        end
        # takes the most frequent priority as the team priority
        freq = student_bids.each_with_object(Hash.new(0)) do |v, h|
          h[v] += 1
        end
        topic_bids << {topic_id: topic.id, priority: student_bids.max_by {|v| freq[v] }} unless freq.empty?
      end
      topic_bids.sort! {|b| b[:priority] }
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

    # auto_merge_teams unassignedTeams, finalTeamTopics

    # Remove is_intelligent property from assignment so that it can revert to the default signup state
    assignment = Assignment.find(params[:id])
    assignment.update_attribute(:is_intelligent, false)
    flash[:notice] = 'The intelligent assignment was successfully completed for ' + assignment.name + '.'
  end

  # This method is called to automerge smaller teams to teams which were assigned topics through intelligent assignment
  def auto_merge_teams(unassigned_teams, _final_team_topics)
    assignment = Assignment.find(params[:id])
    # Sort unassigned
    unassigned_teams = Team.where(id: unassigned_teams).sort_by {|t| !t.users.size }
    unassigned_teams.each do |team|
      sorted_bids = Bid.where(user_id: team.id).sort_by(&:priority) # Get priority for each unassignmed team
      sorted_bids.each do |b|
        # SignedUpTeam.where(:topic=>b.topic_id).first.team_id
        winning_team = SignedUpTeam.where(topic: b.topic_id).first.team_id
        next unless TeamsUser.where(team_id: winning_team).size + team.users.size <= assignment.max_team_size # If the team can be merged to a bigger team
        TeamsUser.where(team_id: team.id).update_all(team_id: winning_team)
        Bid.delete_all(user_id: team.id)
        Team.delete(team.id)
        break
      end
    end
  end
end
