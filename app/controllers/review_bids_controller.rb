class ReviewBidsController < ApplicationController
  require "net/http"
  #require "uri"
  require "json"

  def action_allowed?
    ['Student'].include? current_role_name
  end

  def review_bid
    @participant = AssignmentParticipant.find(params[:id].to_i)
    @assignment = @participant.assignment
    @sign_up_topics = SignUpTopic.where(assignment_id: @assignment.id, private_to: nil)
    team_id = @participant.team.try(:id)
    my_topic = SignedUpTeam.where(team_id: team_id).pluck(:topic_id).first
    @sign_up_topics -= SignUpTopic.where(assignment_id: @assignment.id, id: my_topic)
    @max_team_size = @assignment.max_team_size
    @selected_topics = nil
    @bids = team_id.nil? ? [] : ReviewBid.where(participant_id:@participant,assignment_id:@assignment.id).order(:priority)
    signed_up_topics = []
    @bids.each do |bid|
      sign_up_topic = SignUpTopic.find_by(id: bid.sign_up_topic_id)
      signed_up_topics << sign_up_topic if sign_up_topic
    end
    signed_up_topics &= @sign_up_topics
    @sign_up_topics -= signed_up_topics
    @bids = signed_up_topics
    @num_of_topics = @sign_up_topics.size
    render 'sign_up_sheet/review_bid'
  end
end
