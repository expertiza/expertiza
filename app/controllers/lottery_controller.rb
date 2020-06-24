class LotteryController < ApplicationController
  require 'json'
  require 'rest_client'

  # Give permission to run the bid to appropriate roles
  def action_allowed?
    ['Instructor',
     'Teaching Assistant',
     'Administrator'].include? current_role_name
  end

  # This method sends a request to a web service that uses k-means and students' bidding data
  # to build teams automatically.
  # The webservice tries to create teams with sizes close to the max team size
  # allowed by the assignment by potentially combining existing smaller teams
  # that have similar bidding info/priorities associated with the assignment's sign-up topics.
  #
  # rubocop:disable Metrics/AbcSize
  def run_intelligent_assignment
    assignment = Assignment.find(params[:id])
    teams = assignment.teams

    users_bidding_info = construct_users_bidding_info(assignment.sign_up_topics, teams)
    bidding_data = {users: users_bidding_info, max_team_size: assignment.max_team_size}
    ExpertizaLogger.info LoggerMessage.new(controller_name, session[:user].name, "Bidding data for assignment #{assignment.name}: #{bidding_data}", request)

    begin
      url = WEBSERVICE_CONFIG["topic_bidding_webservice_url"]
      response = RestClient.post url, bidding_data.to_json, content_type: :json, accept: :json
      # Structure of teams variable: [[user_id1, user_id2], [user_id3, user_id4]]
      teams = JSON.parse(response)["teams"]
      ExpertizaLogger.info LoggerMessage.new(controller_name, session[:user].name, "Team formation info for assignment #{assignment.name}: #{teams}", request)
      create_new_teams_for_bidding_response(teams, assignment, users_bidding_info)
      remove_empty_teams(assignment)
      match_new_teams_to_topics(assignment)
    rescue StandardError => e
      flash[:error] = e.message
    end

    redirect_to controller: 'tree_display', action: 'list'
  end

  private

  # Generate user bidding information hash based on students who haven't signed up yet
  # This associates a list of bids corresponding to sign_up_topics to a user
  # Structure of users_bidding_info variable: [{user_id1, bids_1}, {user_id2, bids_2}]
  def construct_users_bidding_info(sign_up_topics, teams)
    users_bidding_info = []
    # Exclude any teams already signed up
    teams_not_signed_up = teams.reject {|team| SignedUpTeam.where(team_id: team.id, is_waitlisted: 0).any? }
    teams_not_signed_up.each do |team|
      # Grab student id and list of bids
      bids = []
      sign_up_topics.each do |topic|
        bid_record = Bid.find_by(team_id: team.id, topic_id: topic.id)
        bids << (bid_record.try(:priority) || 0)
      end
      team.users.each {|user| users_bidding_info << {pid: user.id, ranks: bids} } unless bids.uniq == [0]
    end
    users_bidding_info
  end

  # Generate team bidding information hash based on newly-created teams
  # Structure of team_bidding_info variable: [{team_id1, bids_1}, {team_id2, bids_2}]
  def construct_teams_bidding_info(unassigned_teams, sign_up_topics)
    teams_bidding_info = []
    unassigned_teams.each do |team|
      topic_bids = []
      sign_up_topics.each do |topic|
        bid = Bid.find_by(team_id: team.id, topic_id: topic.id)
        topic_bids << {topic_id: topic.id, priority: bid.priority} if bid
      end
      topic_bids.sort! {|bid| bid[:priority] }
      teams_bidding_info << {team_id: team.id, bids: topic_bids}
    end
    teams_bidding_info
  end

  # This method creates new AssignmentTeam objects based on the list of teams
  # received from the webservice
  # It also creates the corresponding TeamNode and TeamsUsers and TeamUserNode
  # for each user in the new team while removing the users from any previous old
  # teams
  def create_new_teams_for_bidding_response(teams, assignment, users_bidding_info)
    teams.each do |user_ids|
      # Create new team and team node
      new_team = AssignmentTeam.create(name: 'Team_' + rand(10_000).to_s, parent_id: assignment.id)
      team_node = TeamNode.create(parent_id: assignment.id, node_object_id: new_team.id)

      user_ids.each do |user_id|
        remove_user_from_previous_team(assignment.id, user_id)

        # Create new team_user and team_user node
        new_team_user = TeamsUser.create(user_id: user_id, team_id: new_team.id)
        TeamUserNode.create(parent_id: team_node.id, node_object_id: new_team_user.id)

        merge_bids_from_different_previous_teams(assignment.sign_up_topics, new_team.id, user_ids, users_bidding_info)
      end
    end
  end

  # Removes the specified user from any team of the specified assignment
  def remove_user_from_previous_team(assignment_id, user_id)
    team_user = TeamsUser.where(user_id: user_id).find {|team_user| team_user.team.parent_id == assignment_id }
    team_user.team_user_node.destroy rescue nil
    team_user.destroy rescue nil
  end

  # Destroy teams which no longer contain any team members
  def remove_empty_teams(assignment)
    assignment.teams.reload.each do |team|
      if team.teams_users.empty?
        TeamNode.where(parent_id: assignment.id, node_object_id: team.id).destroy_all rescue nil
        team.destroy
      end
    end
  end

  # Create new bids for team based on `ranks` variable for each team member
  # Currently, it is possible (already proved by db records) that
  # some teams have multiple 1st priority, multiply 2nd priority.
  # these multiple identical priorities come from different
  # previous teams
  # [Future work]: we need to find a better way to merge bids
  # that came from different previous teams
  def merge_bids_from_different_previous_teams(sign_up_topics, team_id, user_ids, users_bidding_info)
    # Select data from `users_bidding_info` variable that only related to team members in current team and transpose it.
    # For example, below matrix shows 4 topics (key) and corresponding priorities given by 3 team members (value).
    # {
    #   1: [1, 2, 3],
    #   2: [0, 1, 2],
    #   3: [2, 3, 1],
    #   4: [2, 0, 1]
    # }
    bidding_matrix = Hash.new {|hash, key| hash[key] = [] }
    current_team_members_info = users_bidding_info.select {|info| user_ids.include? info[:pid] }
    current_team_members_info.map {|info| info[:ranks] }.each do |bids|
      sign_up_topics.each_with_index do |topic, index|
        bidding_matrix[topic.id] << bids[index]
      end
    end

    # Below is the structure of matrix summary
    # The first value is the number of nonzero item, the second value is the sum of priorities, the third value of the topic_id.
    # [
    #   [3, 6, 1],
    #   [2, 3, 2],
    #   [3, 6, 3],
    #   [2, 3, 4]
    # ]
    bidding_matrix_summary = []
    bidding_matrix.each do |topic_id, value|
      # Exclude topics that no one bidded
      bidding_matrix_summary << [value.count {|i| i != 0 }, value.inject(:+), topic_id] unless value.inject(:+).zero?
    end
    bidding_matrix_summary.sort! {|b1, b2| [b2[0], b1[1]] <=> [b1[0], b2[1]] }
    # Result of sorting first element descendingly and second element ascendingly.
    # We want the topic with most people bidded and lowest sum of priorities at the top.
    # [
    #   [3, 6, 1],
    #   [3, 6, 3],
    #   [2, 3, 2],
    #   [2, 3, 4]
    # ]
    # Therefore the bidding priority of these 4 topics is 1 -> 3 -> 2 -> 4
    bidding_matrix_summary.each_with_index do |b, index|
      Bid.create(topic_id: b[2], team_id: team_id, priority: index + 1)
    end
  end

  # If certain topic has available slot(s),
  # the team with biggest size and most bids get its first-priority topic
  # then break the loop to next team
  def assign_available_slots(teams_bidding_info)
    teams_bidding_info.each do |tb|
      tb[:bids].each do |bid|
        num_of_signed_up_teams = SignedUpTeam.where(topic_id: bid[:topic_id]).count
        max_choosers = SignUpTopic.find(bid[:topic_id]).try(:max_choosers)
        if num_of_signed_up_teams < max_choosers
          SignedUpTeam.create(team_id: tb[:team_id], topic_id: bid[:topic_id])
          break
        end
      end
    end
  end

  # This method is called for assignments which have their is_intelligent property set to 1.
  # It runs a stable match algorithm and assigns topics to strongest contenders (team strength, priority of bids)
  def match_new_teams_to_topics(assignment)
    unless assignment.is_intelligent
      flash[:error] = "This action is not allowed. The assignment #{assignment.name} does not enable intelligent assignments."
      return
    end
    # Getting sign-up topics with max_choosers > 0
    sign_up_topics = SignUpTopic.where('assignment_id = ? AND max_choosers > 0', assignment.id)
    unassigned_teams = assignment.teams.reload.select do |t|
      SignedUpTeam.where(team_id: t.id, is_waitlisted: 0).blank? and Bid.where(team_id: t.id).any?
    end

    # Sorting unassigned_teams by team size desc, number of bids in current team asc
    # again, we need to find a way to to merge bids that came from different previous teams
    # then sorting unassigned_teams by number of bids in current team (less is better)
    # and we also need to think about, how to sort teams when they have the same team size and number of bids
    # maybe we can use timestamps in this case
    unassigned_teams.sort! do |t1, t2|
      [TeamsUser.where(team_id: t2.id).size, Bid.where(team_id: t1.id).size] <=>
          [TeamsUser.where(team_id: t1.id).size, Bid.where(team_id: t2.id).size]
    end

    teams_bidding_info = construct_teams_bidding_info(unassigned_teams, sign_up_topics)
    assign_available_slots(teams_bidding_info)

    # Remove is_intelligent property from assignment so that it can revert to the default sign-up state
    assignment.update_attributes(is_intelligent: false)
    flash[:success] = 'The intelligent assignment was successfully completed for ' + assignment.name + '.'
  end
  # rubocop:enable Metrics/AbcSize
end
