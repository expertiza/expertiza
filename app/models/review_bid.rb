class ReviewBid < ActiveRecord::Base
  attr_accessor :bid_topic_name, :bid_topic_identifier, :bid_team_name
  # this method is called when the bidding is run, 
  # get the ranking of teams ordered by the participant from the bids
  def self.get_rank_by_participant(participant, assignment_teams)
    bids = ReviewBid.where(participant_id: participant.id).order(:priority)
    # if the participant has not selected any team yet, provide a default rank
    if bids.empty?
      return assignment_teams.shuffle
    else
      return bids.map(&:team_id)
    end
  end
  # get the bidding list of the participant
  def self.get_bids_by_participant(participant)
    assignment = participant.assignment
    assignment_teams = AssignmentTeam.where(parent_id: assignment.id)
    signed_up_teams = []
    topics = SignUpTopic.where(assignment_id: assignment.id)
    topics.each do |topic|
      signed_up_teams = signed_up_teams + SignedUpTeam.where(topic_id: topic.id, is_waitlisted: 0)
    end
    bids = ReviewBid.where(participant_id: participant.id).order(:priority)
    default = false
    # if the participant has not selected any team yet, construct a rank list for views
    if bids.empty?
      default = true
      signed_up_teams.each do |team|
        bids << ReviewBid.new(team_id: team.team_id, participant_id: participant.id)
      end
    end
    bids.each do |bid|
      self.match_bid_with_team_topic(bid, signed_up_teams, assignment_teams, topics) 
    end
    # if getting a default list, sort by topic_identifier
    if default
      bids.order(:bid_topic_identifier)
    end
    return bids
  end
  # for the bid list to show includes topic name, topic identifier and the team name, 
  # this method is used to wrap up all the information for bid item.
  def self.match_bid_with_team_topic(bid, signed_up_teams, assignment_teams, topics)
    signed_up_teams.each do |team|
      topics.each do |topic|
        if bid.team_id == team.team_id && topic.id == team.topic_id 
          bid.bid_topic_name = topic.topic_name
          bid.bid_topic_identifier = topic.topic_identifier
        end
      end
    end
    assignment_teams.each do |assignment_team|
      if bid.team_id == assignment_team.id
        bid.bid_team_name = assignment_team.name
      end
    end
  end
end
