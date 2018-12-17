class ReviewBid < ActiveRecord::Base
  attr_accessor :bid_topic_name, :bid_topic_identifier, :bid_team_name
  # get the ranking of participant from the bids for assignment
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
      bids = []
      signed_up_teams.each do |team|
        bids << ReviewBid.new(team_id: team.team_id, participant_id: participant.id)
      end
    end
    assignment_teams = Team.where(parent_id: assignment.id)
    # use a mapping between signed_up_team and topic
    team_2_topic = {}
    team_2_name = {}
    signed_up_teams.each do |team|
      topics.each do |topic|
        if topic.id == team.topic_id
          team_2_topic[team.team_id] = topic
        end
      end
      assignment_teams.each do |assignment_team|
        if assignment_team.id == team.team_id
          team_2_name[team.team_id] = assignment_team.name
        end
      end
    end
    bids.length.times do |index|
      team_id = bids[index].team_id
      bids[index].bid_topic_name = team_2_topic[team_id].topic_name
      bids[index].bid_topic_identifier = team_2_topic[team_id].topic_identifier
      bids[index].bid_team_name = team_2_name[team_id]
    end
    # if this bid list is a default list, then order the bids by the topic indentifier
    if default
      bids.sort_by!(&:bid_topic_identifier)
    end
    return bids
  end
end
