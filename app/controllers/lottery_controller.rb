class LotteryController < ApplicationController
  include LotteryHelper, AuthorizationHelper
  require 'json'
  require 'rest_client'
  # Give permission to run the bid to appropriate roles
  def action_allowed?
    current_user_has_ta_privileges?
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
    bidding_data = { users: users_bidding_info, max_team_size: assignment.max_team_size }
    ExpertizaLogger.info LoggerMessage.new(controller_name, session[:user].name, "Bidding data for assignment #{assignment.name}: #{bidding_data}", request)
    begin
      url = WEBSERVICE_CONFIG['topic_bidding_webservice_url']
      response = RestClient.post url, bidding_data.to_json, content_type: :json, accept: :json
      # Structure of teams variable: [[user_id1, user_id2], [user_id3, user_id4]]
      teams = JSON.parse(response)['teams']
      ExpertizaLogger.info LoggerMessage.new(controller_name, session[:user].name, "Team formation info for assignment #{assignment.name}: #{teams}", request)
      create_new_teams_for_bidding_response(teams, assignment, users_bidding_info)
      assignment.remove_empty_teams
      match_new_teams_to_topics(assignment)
    rescue StandardError => e
      flash[:error] = e.message
    end
    redirect_to controller: 'tree_display', action: 'list'
  end

  # Prepares data for displaying the bidding details for each topic within an assignment.
  # It calculates the number of bids for each priority (1, 2, 3) per topic and also computes
  # the overall percentages of teams that received their first, second, and third choice.
  # This method is responsible for calculating the bidding table data for an assignment.
  def calculate_bidding_summary_based_on_priority
    # Find the assignment by its ID passed in parameters.
    @assignment = Assignment.find(params[:id])
    # Retrieve all sign up topics associated with the assignment and include the bids for each topic.
    @topics = @assignment.sign_up_topics.includes(:bids)
    # Map over each topic to create a structured hash of data needed for the view.
    @topic_data = @topics.map do |topic|
    # Count the total number of bids for the topic.
    total_bids = topic.bids.count
    # Count the number of first, second, and third priority bids.
    first_bids = topic.bids.where(priority: 1).count
    second_bids = topic.bids.where(priority: 2).count
    third_bids = topic.bids.where(priority: 3).count
    # Extract the team names for the bids.
    bidding_teams = topic.bids.includes(:team).map { |bid| bid.team.name }

    # Calculate the percentage of first priority bids.
    percentage_first = if total_bids > 0
                         # If there are any bids, calculate the percentage.
                         (first_bids.to_f / total_bids * 100).round(2)
                       else
                         # If there are no bids, the percentage is 0.
                         0
                       end
    # Return a hash containing all the calculated and retrieved data for the topic.
    {
      id: topic.id,
      name: topic.topic_name,
      first_bids: first_bids,
      second_bids: second_bids,
      third_bids: third_bids,
      total_bids: total_bids,
      percentage_first: percentage_first,
      bidding_teams: bidding_teams
    }
    end
  end

  private

  # Computes the count of assigned teams for each priority level (1, 2, 3) across all topics.
  # It checks each team associated with a topic and determines if the team's bid matches
  # one of the priority levels, incrementing the respective count if so.
  def compute_priority_counts(assigned_teams_by_topic, bids_by_topic)
    priority_counts = { 1 => 0, 2 => 0, 3 => 0 }
    assigned_teams_by_topic.each do |topic_id, teams|
      teams.each do |team|
        bid_info = bids_by_topic[topic_id].find { |bid| bid[:team] == team }
        priority_counts[bid_info[:priority]] += 1 if bid_info
      end
    end
    priority_counts
  end

  # Calculates the percentages of teams that received their first, second, and third choice
  # based on the counts of teams at each priority level.
  def compute_percentages(priority_counts, total_teams)
    priority_counts.transform_values { |count| (count.to_f / total_teams * 100).round(2) }
  end

  # Generate user bidding information hash based on students who haven't signed up yet
  # This associates a list of bids corresponding to sign_up_topics to a user
  # Structure of users_bidding_info variable: [{user_id1, bids_1}, {user_id2, bids_2}]
  def construct_users_bidding_info(sign_up_topics, teams)
    users_bidding_info = []
    # Exclude any teams already signed up
    teams_not_signed_up = teams.reject { |team| SignedUpTeam.where(team_id: team.id, is_waitlisted: 0).any? }
    teams_not_signed_up.each do |team|
      # Grab student id and list of bids
      bids = []
      sign_up_topics.each do |topic|
        bid_record = Bid.find_by(team_id: team.id, topic_id: topic.id)
        bids << (bid_record.try(:priority) || 0)
      end
      team.users.each { |user| users_bidding_info << { pid: user.id, ranks: bids } } unless bids.uniq == [0]
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
        topic_bids << { topic_id: topic.id, priority: bid.priority } if bid
      end
      topic_bids.sort! { |bid| bid[:priority] }
      teams_bidding_info << { team_id: team.id, bids: topic_bids }
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
      new_team = AssignmentTeam.create_team_with_users(assignment.id, user_ids)
      # Select data from `users_bidding_info` variable that only related to team members in current team
      current_team_members_info = users_bidding_info.select { |info| user_ids.include? info[:pid] }.map { |info| info[:ranks] }
      Bid.merge_bids_from_different_users(new_team.id, assignment.sign_up_topics, current_team_members_info)
    end
  end

  # If certain topic has available slot(s),
  # the team with biggest size and most bids get its first-priority topic
  # then break the loop to next team
  def assign_available_slots(teams_bidding_info)
    teams_bidding_info.each do |tb|
      tb[:bids].each do |bid|
        topic_id = bid[:topic_id]
        max_choosers = SignUpTopic.find(topic_id).try(:max_choosers)
        SignedUpTeam.create(team_id: tb[:team_id], topic_id: topic_id) if SignedUpTeam.where(topic_id: topic_id).count < max_choosers
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
      SignedUpTeam.where(team_id: t.id, is_waitlisted: 0).blank? && Bid.where(team_id: t.id).any?
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
