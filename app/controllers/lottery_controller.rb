class LotteryController < ApplicationController

  # Kick off the lottery selection process.
  # Although this method COULD be put in the AssignmentController,
  # but we want to encapsulate the logic here
  def run_lottery
    # Should get an assignment_id as a parameter

    # Acquire the assignment from the passed parameter
    # TODO: Add error handling if the passed ID is blank
    assignment = Assignment.find(params[:id]) unless params[:id].blank?

    randomSelection(assignment)
    # hillClimber (assignment)

    # TODO: Alert if we have a situation where # of topics < # of teams, ideally provide the teams that were not assigned topics.
    flash[:notice] = 'Lottery assignment completed successfully.'


  end

  def randomSelection (assignment)
    # Iterate over the sign up topics for the assignment
    puts "In random selection method"
    assignment.sign_up_topics.each do |topic|
      # For each topic, we want to grab all of the active bids and randomly determine the winner
      # 1.8.7 doesn't have the rand() methods so we're using the Array sample method (not sure if this works)
      # http://stackoverflow.com/questions/4395095/how-to-generate-a-random-number-between-a-and-b-in-ruby
      winningBid = topic.bids.to_a.sample
      puts "Selected a winning bid: " +  winningBid
      assign_team_topic (winningBid)
      # Clean up (remove chosen team's active bids)
    end
  end

  def assign_team_topic (winningBid)
    # Should complete the topic assignment including team compaction
  end

  def hillClimber (assignment)
    # If we have time, we'll replace the current implementation of a random topic assignment with a hill climbing
    # algorithm
  end
end
