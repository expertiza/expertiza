class ReviewBid < ActiveRecord::Base
  attr_accessor :bid_topic_name, :bid_topic_identifier
  def self.get_rank(assignment_teams, participant)
    bids = ReviewBid.where(participant_id: participant.id).order(:priority)
    # if the participant has not selected any team yet, provide a default rank
    if bids.empty?
      return assignment_teams.shuffle
    else
      return bids.map(&:team_id)
    end
  end
  def self.get_bids_by_participant(participant, topics, signed_up_teams)
    bids = ReviewBid.where(participant_id: participant.id).order(:priority)
    team_2_topic = {}
    signed_up_teams.each do |team|
      topics.each do |topic|
        if topic.id == team.topic_id
          team_2_topic[team.team_id] = topic
        end
      end
    end
    # if the participant has not selected any team yet, construct a rank list for views
    if bids.empty?
      bids = []
      signed_up_teams.each do |team|
        bids << ReviewBid.new(team_id: team.team_id, participant_id: participant.id)
      end
    end
    bids.length.times do |index|
      team_id = bids[index].team_id
      bids[index].bid_topic_name = team_2_topic[team_id].topic_name
      bids[index].bid_topic_identifier = team_2_topic[team_id].topic_identifier
    end
    return bids
  end
end
