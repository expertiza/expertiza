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
    existing_team_ids = {}
    assignment = Assignment.find_by(id: params[:id])
    course_id = assignment['course_id']
    users_in_teams = []
    topic_ids = SignUpTopic.where(assignment_id: params[:id]).map(&:id)
    user_ids = Participant.where(parent_id: params[:id]).map(&:user_id)
    user_ids.each do |user_id|
      # grab student id and list of bids
      bids = []
      # getting each users history of users whom they had worked with
      teamed_students = StudentTask.teamed_students(User.find(user_id),course_id,false, assignment.id)
      teamed_students[course_id] = [] if teamed_students[course_id].nil?
      history = teamed_students[course_id]
      current_team = StudentTask.teamed_students(User.find(user_id),course_id,false, nil, assignment.id)[course_id]
      if !current_team.nil? and current_team.size >= 1
        users_in_teams << current_team.dup
      end

      topic_ids.each do |topic_id|
        bid_record = Bid.where(user_id: user_id, topic_id: topic_id).first rescue nil
        bids << (bid_record.nil? ? 0 : bid_record.priority ||= 0)
      end
      if bids.uniq != [0]
        priority_info << {pid: user_id, ranks: bids,  history: history}
      end
    end
    users_in_teams.uniq!
    data = {users: priority_info, max_team_size: assignment.max_team_size}
    url = WEBSERVICE_CONFIG["topic_bidding_webservice_url"]
    begin
      response = RestClient.post url, data.to_json, content_type: :json, accept: :json
    rescue => err
      flash[:error] = err.message
    end

    # To only swap team members for teams that have the flag set in the database.
    response_new = {}
    response_new["users"] = JSON.parse(response)["users"]
    teams = JSON.parse(response)["teams"]
    teams_swap_members = []
    teams.each do |user_ids|
      any_member_need_swap = false
      user_ids.each do |user_id|
        team_ids = TeamsUser.where(user_id: user_id).select(:team_id)
        team = Team.where(id: team_ids, parent_id: assignment.id)
        new_members_option = team.first.new_members
        existing_team_ids[user_id] = team.first.id
        #If any one member in a team requires new teammates then we will include that team for swapping based on top trading cycle
        if(new_members_option)
          any_member_need_swap = true
        end
        # If any member is in a pre-built team, we will skip that team when swapping
        if(users_in_teams.include? user_id)
          any_member_need_swap = false
          break
        end
      end
      if(any_member_need_swap)
        teams_swap_members << user_ids
      end
    end
    teams_not_swap_members = teams - teams_swap_members
    response_new["teams"] = teams_swap_members
    response = swapping_team_members_with_history(response_new, assignment.max_team_size)
    if response != false
      teams_swap_members = response["teams"]
      teams = teams_swap_members + teams_not_swap_members

      create_new_teams_for_bidding_response(teams, assignment, existing_team_ids)
      run_intelligent_bid

    end
    if(params[:test_run].nil? || params[:test_run] == false)
      redirect_to controller: 'tree_display', action: 'list'
    end
  end

  def swapping_team_members_with_history(data, max_team_size)
    temp = data.dup
    url = WEBSERVICE_CONFIG['member_swapping_webservice_url']
    (max_team_size-1).times do
      begin
        temp = RestClient.post url, temp.to_json, content_type: :json, accept: :json
        temp = JSON.parse(temp)
      rescue => err
        flash[:error] = err.message
        return false
      end
    end
    return temp
  end

  def create_new_teams_for_bidding_response(teams, assignment, existing_team_ids)
    teams.each do |user_ids|
      new_team = AssignmentTeam.create(name: assignment.name + '_Team' + rand(1000).to_s,
                                       parent_id: assignment.id,
                                       type: 'AssignmentTeam')
      parent = TeamNode.create(parent_id: assignment.id, node_object_id: new_team.id)
      user_ids.each do |user_id|
        team_user = TeamsUser.where(user_id: user_id, team_id: new_team.id).first rescue nil
        team_user = TeamsUser.create(user_id: user_id, team_id: new_team.id) if team_user.nil?
        TeamUserNode.create(parent_id: parent.id, node_object_id: team_user.id)

        #Deleting earlier made team
        old_team_id = existing_team_ids[user_id]
        TeamsUser.destroy_all(team_id: old_team_id, user_id: user_id) unless old_team_id.nil?
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
