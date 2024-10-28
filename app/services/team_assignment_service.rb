# TeamAssignmentService automates teams creation from user bids and assigns topics to them.
# It uses an external web service to get team information and handles matching teams with topics
# for an assignment.
class TeamAssignmentService
  require 'json'
  require 'rest_client'

  # Initializes the service with an assignment
  def initialize(assignment_id)
    @assignment = Assignment.find(assignment_id)
    @bidding_data = {}
    @teams_response = []
  end

  # The method matches teams by generating bid data, fetching team info from a web service,
  # creating new teams with this data, removing empty teams, and matching them to topics via
  # stable match algorithm
  def assign_teams_to_topics
    prepare_bidding_data
    teams_from_bidding_service
    create_new_teams(@teams_response, @bidding_data[:users])
    @assignment.remove_empty_teams
    assign_topics_to_new_teams(@assignment)
  rescue StandardError => e
    raise e
  end

  private

  # Preparing the bidding data from users
  def prepare_bidding_data
    teams = assignment.teams
    users_bidding_info = construct_users_bidding_info(assignment.sign_up_topics, teams)
    @bidding_data = { users: users_bidding_info, max_team_size: assignment.max_team_size }
  end

  # Generate user bidding information hash based on students who haven't signed up yet
  # This associates a list of bids corresponding to sign_up_topics to a user
  # Structure of users_bidding_info variable: [{user_id1, bids_1}, {user_id2, bids_2}]
  def construct_users_bidding_info(sign_up_topics, teams)
    users_bidding_info = []

    signed_up_team_ids = SignedUpTeam.where(is_waitlisted: 0).pluck(:team_id).to_set

    teams_not_signed_up = teams.reject { |team| signed_up_team_ids.include?(team.id) }

    teams_not_signed_up.each do |team|
      # Retrieve all bids for the team in a single query outside of the loop
      bids = Bid.where(team_id: team.id, topic_id: sign_up_topics.map(&:id))
      bid_lookup = bids.index_by(&:topic_id)

      bid_priorities = []

      sign_up_topics.each do |topic|
        bid_record = bid_lookup[topic.id]
        bid_priorities << (bid_record.try(:priority) || 0)
      end

      unless bid_priorities.uniq == 0
        team.users.each do |user|
          users_bidding_info << { pid: user.id, ranks: bids }
        end
      end
    end
    users_bidding_info
  end

  # Fetches team data by calling an external web service that uses students' bidding data to build teams automatically.
  # The web service tries to create teams close to the assignment's maximum team size by combining smaller teams
  # with similar bidding priorities for the assignment's sign-up topics.
  def teams_from_bidding_service
    url = WEBSERVICE_CONFIG['topic_bidding_webservice_url']
    response = RestClient.post url, bidding_data.to_json, content_type: :json, accept: :json

    # Structure of teams variable: [[user_id1, user_id2], [user_id3, user_id4]]
    @teams_response = JSON.parse(response)['teams']
  rescue RestClient::ExceptionWithResponse => e
    raise StandardError, "Failed to fetch teams from web service: #{e.response}"
  end

  # Creates new teams based on the response from the web service and the users' bidding data.
  def create_new_teams(teams_response, users_bidding_info)
    teams_response.each do |user_ids|
      new_team = AssignmentTeam.create_team_with_users(assignment.id, user_ids)
      # Select data from `users_bidding_info` variable that only related to team members in current team
      current_team_members_info = users_bidding_info.select { |info| user_ids.include? info[:pid] }.map { |info| info[:ranks] }
      Bid.merge_bids_from_different_users(new_team.id, assignment.sign_up_topics, current_team_members_info)
    end
  end

  # Pairs new teams with topics they've chosen based on bids.
  # This method is called for assignments which have their is_intelligent property set to 1.
  # It runs a stable match algorithm and assigns topics to strongest contenders (team strength, priority of bids).
  def assign_topics_to_new_teams(assignment)
    unless assignment.is_intelligent
      raise StandardError, "This action is not allowed. The assignment #{@assignment.name} does not enable intelligent assignments."
    end

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
    assignment.update(is_intelligent: false)
  end

  # Constructs bidding information for teams including their bids on available topics
  def construct_teams_bidding_info(unassigned_teams, sign_up_topics)
    teams_bidding_info = []
    bids = fetch_bids(unassigned_teams, sign_up_topics)    

    unassigned_teams.each do |team|
        team_bids = construct_team_bids(team, bids)
        sorted_bids = sort_bids_by_priority(team, bids)
        teams_bidding_info << { team_id: team.id, bids: sorted_bids }
    end
    teams_bidding_info
  end

   # Fetches all bids associated with the specific unassigned teams and sign-up topics
  def fetch_bids(unassigned_teams, sign_up_topics)
    Bid.where(
      team_id: unassigned_teams.map(&:id),
      topic_id: sign_up_topics.map(&:id)
    )
  end

  # Constructions a list of bids specific to a given team
  def construct_team_bids(team, bids)
    team_specific_bids = bids.select { |bid| bid.team_id == team.id }
    team_specific_bids.map do |bid|
      { topic_id: bid.topic_id, priority: bid.priority }
    end
  end
  
  # Sorts an array of bids in ascending order based on their priority
  def sort_bids_by_priority(bids)
    bids.sort_by { |bid| bid[:priority] }
  end
  
  # Assigns available topic slots to teams based on their bidding information.
  # If a certain topic has available slot(s), the team with biggest size and most bids get its first-priority topic.
  # Then the loop breaks to the next team.
  def assign_available_slots(teams_bidding_info)
    teams_bidding_info.each do |tb|
      tb[:bids].each do |bid|
        topic_id = bid[:topic_id]
        max_choosers = SignUpTopic.find(topic_id).try(:max_choosers)
        SignedUpTeam.create(team_id: tb[:team_id], topic_id: topic_id) if SignedUpTeam.where(topic_id: topic_id).count < max_choosers
      end
    end
  end
end
