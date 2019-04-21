class ReviewBidsController < LotteryController
  # intelligently assign reviews to participants
  def run_intelligent_assignment
    assignment = Assignment.find_by(id: params[:id])
    teams = Team.where(parent_id: params[:id]).map(&:id)
    participants = AssignmentParticipant.where(parent_id: params[:id])
    participant_ranks = []
    participants.each do |participant|
      ranks = ReviewBid.get_rank_by_participant(participant, teams)
      participant_ranks << {pid: participant.id, ranks: ranks}
    end
    # we have the availability of topics and ranks of users' choices towards submission now.
    # data = {
      users = participant_ranks
      item_size = assignment.max_reviews_per_submission
      user_size = assignment.num_reviews_required
    # }
    # url = WEBSERVICE_CONFIG["review_bidding_webservice_url"]
    begin
      # response = RestClient.post url, data.to_json, content_type: :json, accept: :json
      # bid_result = JSON.parse(response)["info"]
      flash[:notice] = "You have reached the part to call Gale Shapley"
      bid_result = gale_shapley(users, user_size, item_size)
      response_mappings = run_intelligent_bid(assignment, teams, participants, bid_result)
      create_response_mappings(assignment, response_mappings)
    rescue StandardError => err
      flash[:error] = err.message
    end
    # render :json => response_mappings.to_json
    assignment.update_attribute(:review_assignment_strategy, 'Auto-Selected')
    flash[:success] = 'The intelligent review assignment was successfully completed for ' + assignment.name + '.'
    redirect_to controller: 'tree_display', action: 'list'
  end

  # if some participants don't get assigned reviews from peerlogic,
  # randomly assign availables reviews to them
  def run_intelligent_bid(assignment, teams, participants, bid_result)
    team_assigned_count = {}
    participant_count = {}
    response_mappings = []
    participants.each do |participant|
      participant_count[participant.id] = 0
    end
    teams.each do |team|
      team_assigned_count[team] = 0
    end
    bid_result.each do |participant_bid|
      participant_bid["items"].each do |team_id|
        # make a record for the bidding result from peerlogic
        response_mappings << {pid: participant_bid["pid"], team: team_id}
        # counting how many participants are assigned with this team
        team_assigned_count[team_id] += 1
        # counting how many reviews are assigned to each participant
        participant_count[participant_bid["pid"]] += 1
      end
    end
    # if after the bidding, there are some participants who do not have enough available reviews
    # assign them with some random teams
    participants.each do |participant|
      while participant_count[participant.id] < assignment.num_reviews_required
        team = teams[rand(teams.count)]
        next if team_assigned_count[team] >= assignment.max_reviews_per_submission
        team_assigned_count[team] += 1
        participant_count[participant.id] += 1
        response_mappings << {pid: participant.id, team: team}
      end
    end
    response_mappings
  end

  # create response_mapping data with the result from intelligent assignment
  def create_response_mappings(assignment, response_mappings)
    response_mappings.each do |map|
      ReviewResponseMap.create(
        reviewed_object_id: assignment.id,
        reviewer_id: map[:pid],
        reviewee_id: map[:team]
      )
    end
  end


  #E1928: Allow reviewers to bid on what to review
  # This is an implementation of Gale Shapely algorithm that will be used by the instructors to assign the topics
  # for reviews to the students

=begin
The way to call this method
user_ranks = [{"pid":1,"ranks":[1,2,3]},{"pid":2,"ranks":[3,1,2]},{"pid":3,"ranks":[2,3,1]},{"pid":4,"ranks": [2,1,3]},{"pid":5,"ranks": [1,2,3]}]
print gale_shapley(user_ranks, 2, 2)
=end

  # The original gale shapley implementation had the following method signature:
  # def gale_shapley(users, user_size, item_size)
  # However, we have changed it to:
  # def gale_shapley(participant_ranks, user_size, item_size)

  def gale_shapley(users, user_size, item_size)
=begin
    Description
    -----------
    Given the users preference towards items, the available slots of each item and
    maximum number each user can have items, assign items to users according to their preference.
    -----------
    Parameters
    -----------
    users       :   List[dict]
        dict format: {"pid": user_id, "ranks": [item_id]} the most interested items go first.
    user_size   :   int
    item_size   :   int
    -----------
    Return
    List[dict]
=end

    item_ranks = {}
    count_assigned_items = {}
    users_items = {}

    # construct a user priority list for every item
    users.each do |user|
      count = 0
      user['ranks'].each do item
        unless item_ranks.include? item
          item_ranks[item] = []
        end

        unless users_items.include? user["pid"]
        users_items[user["pid"]] = []
        end

      #every item hold a list of priority of users
      item_ranks[item] << {pid: user["pid"], priority: count+=1}

      end
    end

    # sort the item ranks by user's priority so that the algorithm can select the most interested users
    item_ranks.each do |item|
      #randomize the order of users for fairness
      item_ranks[item].shuffle
      item_ranks[item].sort_by{|pid, priority| priority}
      count_assigned_items[item] = 0
    end

    #randomize the order of items for fairness
    items = item_ranks.keys
    items.shuffle

    # start bidding
    while true
      added = 0

      items.each do |item|
        # select the most interested users

        while item_ranks[item]
          user = item_ranks[item].pop(0)

          # if item is assigned to a number of users and this number exceeds its limit:
          # the assignment for this item is finished
          if count_assigned_items[item] >= item_size
              break
          end

          user_id = user["pid"]

          # if user has enough assignment, choose another user with less interest.
          if len(users_items[user_id]) >= user_size
              next
          end

          users_items[user_id] << item
          count_assigned_items[item]+=1
          added = 1
          break

        end
      end

          unless added
              break
          end

    end

    # This is a result that is returned from the gsle shapely algorithm
    # It is an array that returns an array of user IDs and the corressponding assigned topics.
    rst = []
    users_items.each do |item|
      rst << {pid: user, items: users_items[user]}
    end

    return rst
  end
end