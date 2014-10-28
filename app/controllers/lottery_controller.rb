class LotteryController < ApplicationController

  # Kick off the lottery selection process.
  # Although this method COULD be put in the AssignmentController,
  # but we want to encapsulate the logic here
  def run_lottery
    # Should get an assignment_id as a parameter

    # Acquire the assignment from the passed parameter
    # TODO: Add error handling if the passed ID is blank
    assignment = Assignment.find(params[:id]) unless params[:id].blank?
    max_team_size = assignment.team_count
    allow_multi_topic = false

    if allow_multi_topic
      # Since this is multiple teams per topic, we need to loop on the topics per assignment and then ensure the
      # topic has topic.max_choosers # of teams assigned
      assignment.sign_up_topics.each do |topic|
        if topic.bids.size > 0 #If no bids for the topic, we can skip processing for this topic
          #Step 1, get the teams already assigned to the topic and iterate over each team to see if the team is full
          assigned_teams = get_teams_for_topic(topic)
          assigned_teams.each do |team|
            if current_team.teams_users.size < max_team_size
              fill_team(current_team, topic.bids, max_team_size)
            end
          end
          #Step 2, choose a winner for any remaining teams that have bids
          if topic.bids.size > 0  #Added this check here to make sure that we still have bids for the topic after filling teams
            remaining_slots = topic.max_choosers - assigned_teams.size
            remaining_slots.times do
              choose_winner_for_topic(topic, max_team_size)
            end
          end
        end
      end
      else #Original implementation that works (mostly) this requires only a single team per topic
        assignment.sign_up_topics.each do |topic|
          # Decide if we need to assign a team to a topic - Criteria, no team assigned & # of bids > 0
          current_team = TeamsUser.find_by_user_id(Participant.find_by_topic_id(topic.id).user_id).team
          if topic.bids.size > 0
            if topic.slotAvailable?
              choose_winner_for_topic(topic, max_team_size)
              # If not, check to see if the team is full.  Fill if not, otherwise proceed to the next assignment
            elsif current_team.teams_users.size < max_team_size
              #Assumption here is that if a team has been assigned a topic they no longer have bids
              fill_team(current_team, topic.bids, max_team_size)
            end
          end
        end
      end

    # hillClimber (assignment)

    # TODO: Alert if we have a situation where # of topics < # of teams, ideally provide the teams that were not assigned topics.
    flash[:notice] = 'Lottery assignment completed successfully.'

    # Turn lottery topic selection off for this assignment now that the lottery has run
    assignment.is_lottery = false
    assignment.save
  end

  def get_teams_for_topic(topic)
    # This could perhaps be put in a different controller, in the interest of time I'm keeping it here
    # First, we need to gather all of the Participants for a topic
    # Once we have this, we can pull the teams off of each individual and build an array of teams to return
    teams_to_return = Array.new
    all_participants = Participant.where(topic_id: topic.id)
    all_participants.each do |participant|
      teams_to_return += TeamsUser.find_by_user_id(participant.user_id).team
    end
    #Return only the unique team elements
    teams_to_return.uniq
  end

  def choose_winner_for_topic(topic, max_team_size)
    weighted_bids = make_weighted_bid_array(topic)
    winning_bid = weighted_bids.sample
    remaining_bids = topic.bids.to_a - winning_bid.to_a
    fill_team(winning_bid.team, remaining_bids, max_team_size) if winning_bid.team.teams_users.size < max_team_size

    # Since we have a winner, assign this topic to that team
    assign_team_topic (winning_bid)

    # Find and delete all the bids for this team or this topic
    Bid.delete_all("team_id=#{winning_bid.team.id} OR topic_id=#{winning_bid.topic.id}")

  end

  def fill_team (winning_team, team_bids, max_team_size)
    # Build up an object to hold the remaining teams keyed off of the team size
    remaining_spots = max_team_size - winning_team.teams_users.size

    teams_to_add = Hash.new []
    team_bids.each do |bid|
      key = bid.team.teams_users.size
      teams_to_add[key] += bid.team.to_a if key <= remaining_spots
    end

    # Start iterating through starting at the largest team size that can fit
    # Continue adding teams of that size until we can't fit any more of that size
    # Loop through the keys adding all possible teams
    teams_to_add.keys.sort.reverse.each do |key|
      current_set = teams_to_add[key].to_a
      while (remaining_spots - key >= 0 && current_set.size > 0)
        team = current_set.sample
        merge_teams(winning_team, team)
        current_set -= team.to_a
        remaining_spots -= key
      end
    end
  end

  def merge_teams(team_a, team_b)
    # This method is intended to take team B and merge its members into team A
    team_b.copy_members(team_a)
    team_b.delete
  end

  def make_weighted_bid_array(topic)
    weighted_bids = []
    topic.bids.each do |bid|
      team_size = bid.team.teams_users.size
      team_size.times do
        weighted_bids << bid
      end
    end
    weighted_bids
  end

  def assign_team_topic (bid)
    # Should complete the topic assignment including team compaction

    # We only need to give confirmTopic a single user
    # TODO maybe this should be the signed in user?
    confirmTopic(bid.team.id, bid.topic.id, bid.topic.assignment.id, bid.team.users[0].id)
  end

  # TODO this logic copied from SignUpSheetController
  def otherConfirmedTopicforUser(assignment_id, creator_id)
    # Return other signups for this user
    SignedUpUser.find_user_signup_topics(assignment_id, creator_id)
  end

  # TODO this logic copied from SignUpSheetController
  def slotAvailable?(topic_id)
    SignUpTopic.slotAvailable?(topic_id)
  end

  # TODO this logic copied from SignUpSheetController
  def confirmTopic(creator_id, topic_id, assignment_id, user_id)
    #check whether user has signed up already
    user_signup = otherConfirmedTopicforUser(assignment_id, creator_id)

    sign_up = SignedUpUser.new
    sign_up.topic_id = topic_id
    sign_up.creator_id = creator_id

    result = false
    if user_signup.size == 0

      # Using a DB transaction to ensure atomic inserts
      ActiveRecord::Base.transaction do
        #check whether slots exist (params[:id] = topic_id) or has the user selected another topic
        if slotAvailable?(topic_id)
          sign_up.is_waitlisted = false

          #Update topic_id in participant table with the topic_id
          participant = AssignmentParticipant.where(user_id: user_id, parent_id:  assignment_id).first

          participant.update_topic_id(topic_id)
        else
          sign_up.is_waitlisted = true
        end
        if sign_up.save
          result = true
        end
      end
      else
        #If all the topics choosen by the user are waitlisted,
        for user_signup_topic in user_signup
          if user_signup_topic.is_waitlisted == false
            #TODO flash[:error] = "You have already signed up for a topic."
            return false
          end
        end

        # Using a DB transaction to ensure atomic inserts
        ActiveRecord::Base.transaction do
          #check whether user is clicking on a topic which is not going to place him in the waitlist
          if !slotAvailable?(topic_id)
            sign_up.is_waitlisted = true
            if sign_up.save
              result = true
            end
          else
            #if slot exist, then confirm the topic for the user and delete all the waitlist for this user
            SignUpTopic.cancel_all_waitlists(creator_id, assignment_id)
            sign_up.is_waitlisted = false
            sign_up.save

            participant = Participant.where(user_id: user_id, parent_id:  assignment_id).first
            participant.update_topic_id(topic_id)
            result = true
          end
        end
        end

    result
  end

  def hillClimber (assignment)
    # If we have time, we'll replace the current implementation of a random topic assignment with a hill climbing
    # algorithm
  end

  def run_intelligent_bid
    assignment = Assignment.find(params[:id]) unless params[:id].blank?

    sign_up_topics = SignUpTopic.where(assignment_id: params[:id])

    # TODO - provide a seed IF same results are required everytime with same input
    # our assumption - algorithm is random, running twice on same input may result in different allocations.
    rand_generator = Random.new

    #to keep track of the max slots for a topic
    current_max_slots = Hash.new
    sign_up_topics.each do |topic|
      assignments_for_topic = SignedUpUser.where(topic_id: topic.id, is_waitlisted: 0)
      current_max_slots[topic.id] = topic.max_choosers - assignments_for_topic.size
    end

    stop = false
    ActiveRecord::Base.transaction do
      while (!stop) do
        stop = true
        assignment.sign_up_topics.each do |topic|

          # if there are any requests available for the topic
          if topic.signed_up_users.size != 0
            #get the teams to which topic has been assigned
            assignments_for_topic = SignedUpUser.where(topic_id: topic.id, is_waitlisted: 0)
            #if slots are still available
            if assignments_for_topic.size < topic.max_choosers
              #get the users who have requested the topic
              bids = SignedUpUser.where(topic_id: topic.id, is_waitlisted: 1).order("preference_priority_number")

              if bids.size == 0
              else if bids.size == 1
                #if there's only one team who has chosen the topic and
                # the team does not have any other high priority topics,
                # assign current topic to this user and delete other bids
                alloted = allot_topic_to_user_if_possible(params[:id],bids[0],topic,current_max_slots)
                if(alloted == true)
                  stop = false
                end
              else
                # if there are more then one teams who have chosen the topic, get the highest priority  given to the topic
                highest_priority = SignedUpUser.find_by_sql(['SELECT MIN(preference_priority_number) preference_priority_number FROM signed_up_users WHERE topic_id = ? and preference_priority_number!=0',topic.id ])
                if highest_priority[0].nil?
                  highest_priority[0] = 0
                end
                # get the candidates who have assigned highest priority for the topic
                candidates =  SignedUpUser.where(topic_id: topic.id, is_waitlisted: 1, preference_priority_number: highest_priority[0].preference_priority_number)

                if candidates.size == 1
                  alloted = allot_topic_to_user_if_possible(params[:id],candidates[0],topic,current_max_slots)
                  if(alloted == true)
                    stop = false
                  end
                else
                  # randomly choose from the candidates who have given same highest priority for the topic
                  i = rand_generator.rand(candidates.size)
                  alloted = allot_topic_to_user_if_possible(params[:id],candidates[i],topic,current_max_slots)
                  if(alloted == true)
                    stop = false
                  end
                end
              end
            end

          end
        end
      end #while end
  end
  flash[:notice] = "Please go to the topics section of edit assignment, to check if the assignments were done"
end
    redirect_to tree_display_index_path
end

#delete all the waitlist entries for the user
def delete_other_bids(assignment_id, user_id)
  entries =  SignedUpUser.find_by_sql(["SELECT su.* FROM signed_up_users su , sign_up_topics st WHERE su.topic_id = st.id AND st.assignment_id = ? AND su.creator_id = ? AND su.is_waitlisted = 1",assignment_id,user_id] )
  entries.each { |o| o.destroy }
end

# this function checks whether the team has given higher priority to other topics
# and whether slots are available for those topics
def is_other_topic_of_higher_priority(assignment_id, team_id, priority,current_max_slots)
  if priority
    result = SignedUpUser.find_by_sql(["SELECT su.* FROM signed_up_users su, sign_up_topics st WHERE su.topic_id = st.id AND st.assignment_id = ? AND su.creator_id = ? AND preference_priority_number < ? AND preference_priority_number != 0",assignment_id, team_id, priority])
  else
    result = SignedUpUser.find_by_sql(["SELECT su.* FROM signed_up_users su, sign_up_topics st WHERE su.topic_id = st.id AND st.assignment_id = ? AND su.creator_id = ? AND preference_priority_number is not null",assignment_id, team_id])
  end
  result.each do |r|
    if current_max_slots[r.topic_id] > 0
      return true
    end
  end
  false
end

# the team is assigned the topic if he cannot be assigned to other topics
def allot_topic_to_user_if_possible(assignment_id, signed_up_user_entry,topic,current_max_slots)
  high_prio_topics = is_other_topic_of_higher_priority(assignment_id,signed_up_user_entry.creator_id,signed_up_user_entry.preference_priority_number,current_max_slots)
  if(high_prio_topics == false)
    current_max_slots[topic.id] =  current_max_slots[topic.id] -1
    signed_up_user_entry.update_attribute('is_waitlisted',0)
    participant = Participant.where(user_id: Team.find(signed_up_user_entry.creator_id).users[0].id, parent_id:  assignment_id).first
    participant.update_topic_id(topic.id)
    delete_other_bids(assignment_id, signed_up_user_entry.creator_id)
    return true
  end
  return false
end

end

