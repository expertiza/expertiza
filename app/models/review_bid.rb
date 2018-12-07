class ReviewBid < ActiveRecord::Base
  def self.get_rank(assignment, assignment_teams, participant)
    bids = ReviewBid.where(participant_id: participant.id).order(:priority)
    #if the participant has not selected any team yet, provide a default rank
    if bids.empty?
      teams = assignment_teams.shuffle()
    else
      teams = bids.map(&:team_id)
    end
    teams
  end
end
