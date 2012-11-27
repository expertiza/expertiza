class LotteryController < ApplicationController

  # Kick off the lottery selection process.
  # Although this method COULD be put in the AssignmentController,
  # but we want to encapsulate the logic here
  def run_lottery
    # Should get an assignment_id as a parameter

    # Acquire the assignment from the passed parameter
    # TODO: Add error handling if the passed ID is blank
    assignment = Assignment.find(params[:id]) unless params[:id].blank?

    assignment.sign_up_topics.each do |topic|
      choose_winner_for_topic(topic, assignment.team_count) if topic.bids.size > 0
    end

    # hillClimber (assignment)

    # TODO: Alert if we have a situation where # of topics < # of teams, ideally provide the teams that were not assigned topics.
    flash[:notice] = 'Lottery assignment completed successfully.'

    # Turn lottery topic selection off for this assignment now that the lottery has run
    assignment.is_lottery = false
    assignment.save
  end

  def choose_winner_for_topic(topic, max_team_size)
    puts "In random selection method"
    weighted_bids = make_weighted_bid_array(topic)
    winning_bid = weighted_bids.sample
    remaining_bids = topic.bids.to_a - winning_bid.to_a
    fill_team(winning_bid.team, remaining_bids, max_team_size) if winning_bid.team.teams_users.size < max_team_size

    # Since we have a winner, assign this topic to that team
    puts "Selected a winning bid: " +  winning_bid.inspect + "(#{winning_bid.team.name})"
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
          participant = AssignmentParticipant.find_by_user_id_and_parent_id(user_id, assignment_id)

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

          participant = Participant.find_by_user_id_and_parent_id(user_id, assignment_id)
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
end
