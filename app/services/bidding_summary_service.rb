 # Holds methods for the bidding summary service that are called by the LotteryController
 
 class BiddingSummaryService

  def initialize()
  end
 
 # Prepares data for displaying the bidding details for each topic within an assignment.
  # It calculates the number of bids for each priority (1, 2, 3) per topic and also computes
  # the overall percentages of teams that received their first, second, and third choice.
  # This method is responsible for calculating the bidding table data for an assignment.
  def bidding_summary(assignment_id)
    @assignment = Assignment.find(assignment_id)
    @topics = @assignment.sign_up_topics.includes(:bids)
    @topic_data = @topics.map do |topic|
    # Count the total number of bids for the topic.
    total_bids = topic.bids.count
    # Count the number of first, second, and third priority bids.
    first_choice_bids = topic.bids.where(priority: 1).count # TODO: First, second, third Choice Bids etc...
    second_choice_bids = topic.bids.where(priority: 2).count
    third_choice_bids = topic.bids.where(priority: 3).count
    # Extract the team names for the bids.
    bidding_teams = topic.bids.includes(:team).map { |bid| bid.team.try(:name) }

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
      first_choice_bids: first_choice_bids,
      second_choice_bids: second_choice_bids,
      third_choice_bids: third_choice_bids,
      total_bids: total_bids,
      percentage_first: percentage_first,
      bidding_teams: bidding_teams
    }
    end
    
    # Return both assignment and topic_data
    return { assignment: @assignment, topic_data: @topic_data }
  end

  # Computes the count of assigned teams for each priority level (1, 2, 3) across all topics.
  # It checks each team associated with a topic and determines if the team's bid matches
  # one of the priority levels, incrementing the respective count if so.
  def priority_counts(assigned_teams_by_topic, bids_by_topic)
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
  def percentage_match_with_team_priorities(priority_counts, total_teams)
    priority_counts.transform_values { |count| (count.to_f / total_teams * 100).round(2) }
  end

end
