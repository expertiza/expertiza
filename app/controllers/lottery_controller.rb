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
    assignment = Assignment.find_by(id: params[:id])
    topics = assignment.sign_up_topics
    teams = assignment.teams
    teams.each do |team|
      # grab student id and list of bids
      bids = []
      topics.each do |topic|
        bid_record = Bid.find_by(team_id: team.id, topic_id: topic.id)
        bids << (bid_record.nil? ? 0 : bid_record.priority ||= 0)
      end
      team.users.each {|user| priority_info << {pid: user.id, ranks: bids} if bids.uniq != [0] }
    end
    data = {users: priority_info, max_team_size: assignment.max_team_size}
    url = WEBSERVICE_CONFIG["topic_bidding_webservice_url"]
    begin
      response = RestClient.post url, data.to_json, content_type: :json, accept: :json
      # store each summary in a hashmap and use the question as the key
      teams = JSON.parse(response)["teams"]
      create_new_teams_for_bidding_response(teams, assignment)
      run_intelligent_bid(assignment)
    rescue StandardError => err
      flash[:error] = err.message
    end
    redirect_to controller: 'tree_display', action: 'list'
  end

  def create_new_teams_for_bidding_response(teams, assignment)
    original_team_ids = assignment.teams.map(&:id)
    # JSON.parse(response)["teams"] is assigned to this team variable,
    # the example output is [[user_id1,user_id2],[user_id3,user_id4]]
    teams.each do |user_ids|
      current_team = nil
      parent = nil
      user_ids.each_with_index do |user_id, index|
        original_team_ids.each do |original_team_id|
          team_user = TeamsUser.find_by(user_id: user_id, team_id: original_team_id)
          next unless team_user
          if index.zero?
            # keep the original team of 1st user if exists and ask later students join in this team
            current_team = team_user.team
            parent = TeamNode.find_by(parent_id: assignment.id, node_object_id: current_team.id)
            break if current_team and parent
            current_team = AssignmentTeam.create(name: 'Team_' + rand(10_000).to_s, parent_id: assignment.id)
            parent = TeamNode.create(parent_id: assignment.id, node_object_id: current_team.id)
          end
          team_user.team_user_node.destroy
          team_user.destroy
          # transfer bids from old team to new team
          # if we use this way to do transformation, it is possible (already proved by db records) that
          # some team has multiple 1st priority, multiply 2nd priority, ....
          # these multiple identical priorities come from different previous teams
          # ideally, we need to find a way to merge bids that came from different previous teams
          Bid.where(team_id: original_team_id).update_all(team_id: current_team.id)
        end
        team_user = TeamsUser.find_by(user_id: user_id, team_id: current_team.id)
        unless team_user
          team_user = TeamsUser.create(user_id: user_id, team_id: current_team.id)
          TeamUserNode.create(parent_id: parent.id, node_object_id: team_user.id)
        end
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
  def run_intelligent_bid(assignment)
    # if the assignment is not intelligent then redirect to the tree display list
    unless assignment.is_intelligent
      flash[:error] = "This action is not allowed. The assignment #{assignment.name} does not enable intelligent assignments."
      redirect_to controller: 'tree_display', action: 'list'
      return
    end
    # Getting signuptopics with max_choosers > 0
    sign_up_topics = SignUpTopic.where('assignment_id = ? and max_choosers > 0', params[:id])
    unassigned_teams = AssignmentTeam.where(parent_id: params[:id]).reject {|t| SignedUpTeam.where(team_id: t.id, is_waitlisted: 0).any? }
    # sorting unassigned_teams by team size desc, number of bids in current team asc
    # again, we need to find a way to to merge bids that came from different previous teams
    # then sorting unassigned_teams by number of bids in current team (less is better)
    # and we also need to think about, how to sort teams when they have the same team size and number of bids
    # maybe we can use timestamps in this case
    unassigned_teams.sort! do |t1, t2|
      [TeamsUser.where(team_id: t2.id).size, Bid.where(team_id: t1.id).size] <=>
      [TeamsUser.where(team_id: t1.id).size, Bid.where(team_id: t2.id).size]
    end
    # generate team bidding infomation hash based on newly-created teams
    team_bids = []
    unassigned_teams.each do |team|
      topic_bids = []
      sign_up_topics.each do |topic|
        bid = Bid.find_by(team_id: team.id, topic_id: topic.id)
        topic_bids << {topic_id: topic.id, priority: bid.priority} if bid
      end
      topic_bids.sort! {|b| b[:priority] }
      team_bids << {team_id: team.id, bids: topic_bids}
    end
    # if certain topic has available slot(s), 
    # the team with biggest size get its first-priority topic
    # then break the loop to next team
    team_bids.each do |tb|
      tb[:bids].each do |bid|
        num_of_signed_up_teams = SignedUpTeam.where(topic_id: bid[:topic_id]).count
        max_choosers = SignUpTopic.find_by(id: bid[:topic_id]).try(:max_choosers)
        if num_of_signed_up_teams < max_choosers
          SignedUpTeam.create(team_id: tb[:team_id], topic_id: bid[:topic_id])
          break
        end
      end
    end

    # auto_merge_teams unassignedTeams, finalTeamTopics

    # Remove is_intelligent property from assignment so that it can revert to the default signup state
    assignment = Assignment.find_by(id: params[:id])
    assignment.update_attribute(:is_intelligent, false)
    flash[:success] = 'The intelligent assignment was successfully completed for ' + assignment.name + '.'
  end

  # This method is called to automerge smaller teams to teams which were assigned topics through intelligent assignment
  def auto_merge_teams(unassigned_teams, _final_team_topics)
    assignment = Assignment.find(params[:id])
    # Sort unassigned
    unassigned_teams = Team.where(id: unassigned_teams).sort_by {|t| !t.users.size }
    unassigned_teams.each do |team|
      sorted_bids = Bid.where(user_id: team.id).sort_by(&:priority) # Get priority for each unassignmed team
      sorted_bids.each do |b|
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
