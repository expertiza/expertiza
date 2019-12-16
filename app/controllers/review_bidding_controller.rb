class ReviewBiddingController < ApplicationController

  require 'rgl/adjacency'
  require 'rgl/dot'
  require 'rgl/topsort'
  require "net/http"
  require "uri"
  require "json"

  def assign
=begin
    Assigns topics to reviewers according to the topics they have bid for.

    This method is supposed to be invoked when an Instructor wants to assign
    topics to the reviewers after the bidding is completed.

    PARAMETERS

    ----------

    params[:id]   :   The id of the assignment for which the
                      Instructor wants to perform review-topic-matching.
=end
    assignment_id = params[:id]
    reviewers = assignment_reviewers(assignment_id)
    topics = SignUpTopic.where(assignment_id: assignment_id).ids
    bidding_data = assignment_bidding_data(assignment_id,reviewers)
    matched_topics = reviewer_topic_matching(bidding_data,topics,assignment_id)
    assign_matched_topics(assignment_id,reviewers,matched_topics)
    redirect_to :back
  end

  def assignment_reviewers(assignment_id)
=begin
    Returns the participant_ids of the reviewers who have a topic assigned to
    them in a given assignment.

    PARAMETERS

    ----------

    assignment_id   :   The id of the assignment whose reviewers are required.
=end
    reviewers = AssignmentParticipant.where(parent_id: assignment_id).ids
    for reviewer in reviewers do
      if(reviewer_self_topic(reviewer,assignment_id)==nil)
        reviewers = reviewers - [reviewer]
      end
    end
    return reviewers
  end

  def assignment_bidding_data(assignment_id,reviewers)
=begin
    Returns a Hash that contains all the necessary bidding data of an
    assignment in the following format:

    {reviewer_1  =>  reviewer_1_bidding_data,
     reviewer_2  =>  reviewer_2_bidding_data,
     .
     .
     reviewer_n  =>  reviewer_n_bidding_data,
    }

    where reviewer_i is the participant_id of a reviewer and
    reviewer_i_bidding_data is the hash containing the bidding data of that
    reviewer.

    PARAMETERS

    ----------

    assignment_id   :   The id of the assignment whose bidding data
                        is required.

    reviewers       :   The list of participant_ids of all the reviewers in the
                        assingment.
=end
    bidding_data = Hash.new
    for reviewer in reviewers do
      bidding_data[reviewer] = reviewer_bidding_data(reviewer,assignment_id)
    end
    return bidding_data
  end

  def reviewer_bidding_data(reviewer,assignment_id)
=begin
    Returns a Hash that contains the necessary bidding data of a particular
    reviewer in the following format:

    {priority  =>  [p1, p2, p3, ..., pm],
     time      =>  [t1, t2, t3, ..., tm],
     tid       =>  [T1, T2, T3, ..., Tm],
     otid      =>  [ST]
    }

    where Ti is the topic_id of a topic, pi is the priority of topic Ti set by
    the reviewer, ti is the time at which the bid for topic Ti was last updated
    and ST is the self_topic of the reviewer.

    PARAMETERS

    ----------

    reviewer    :   The participant_id of the reviewer.

    NOTE: Since a participant_id is associated with a unique assignment, the
          method does not require assignment_id as an argument.
=end
    self_topic = reviewer_self_topic(reviewer,assignment_id)
    bidding_data = {'priority' => [], 'time' => [], 'tid' =>  [], 'otid' => self_topic}
    bids = ReviewBid.where(participant_id: reviewer)
    for bid in bids do
      bidding_data['priority'] << bid.priority
      # bidding_data['time'] << bid.updated_at
      bidding_data['time'] << 1
      bidding_data['tid'] << bid.sign_up_topic_id
    end
    return bidding_data
  end

  def reviewer_self_topic(reviewer,assignment_id)
=begin
    Return the topic_id of the topic on which the reviewer is working in the
    assignment.

    PARAMETERS

    ----------

    reviewer    :   The participant_id of the reviewer.

    NOTE: Since a participant_id is associated with a unique assignment, the
          method does not require assignment_id as an argument.
=end
    user_id = Participant.where(id: reviewer).pluck(:user_id).first
    puts(reviewer.to_s+'\n')
    puts(user_id.to_s+'\n')
    self_topic = ActiveRecord::Base.connection.execute("SELECT ST.topic_id FROM teams T, teams_users TU,signed_up_teams ST where TU.team_id=T.id and T.parent_id="+assignment_id.to_s+" and TU.user_id="+user_id.to_s+" and ST.team_id=TU.team_id;").first
    if self_topic==nil
      return self_topic
    end
    return self_topic.first
  end

  def reviewer_topic_matching(bidding_data,topics,assignment_id)
=begin
    Returns a Hash in which the keys are the participant_ids of the reviewers
    and the values are the lists of topic_ids of topics assigned to the
    corresponding reviewers.

    PARAMETERS

    ----------

    bidding_data    :   A Hash that contains all the necessary bidding data of
                        the assignment.

    Topics          :   The topic_ids of all the topics in the assignment.
=end
    num_reviews_allowed = Assignment.where(id:assignment_id).pluck(:num_reviews_allowed).first
    json_like_bidding_hash = {"users": bidding_data, "tids": topics, "q_S": num_reviews_allowed}
    puts('####################')
    puts(json_like_bidding_hash)
    puts('####################')
    uri = URI.parse(WEBSERVICE_CONFIG["review_bidding_webservice_url"])
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri.path, {'Content-Type' => 'application/json'})
    request.body = json_like_bidding_hash.to_json
    response = http.request(request)
    return JSON.parse(response.body)
  end

  def assign_matched_topics(assignment_id,reviewers,matched_topics)
=begin
    Assign each reviewer the topics with which they were matched.

    PARAMETERS

    ----------

    assignment_id   :   The id of the assignment.

    reviewers       :   The participant_ids of all the reviewers in the
                        assignment.

    matched_topics  :   A Hash in which the keys are the participant_ids of the
                        reviewers and the values are the lists of topic_ids of
                        topics assigned to the corresponding reviewers.
=end
    for reviewer in reviewers do
      reviewer_matched_topics = matched_topics[reviewer.to_s]
      for topic in reviewer_matched_topics do
        # puts(topic)
        # puts(topic.class)
        matched_reviewee = SignedUpTeam.where(topic_id: topic).pluck(:team_id).first
        if(matched_reviewee != nil)
          ReviewResponseMap.create({:reviewed_object_id => assignment_id, :reviewer_id => reviewer, :reviewee_id => matched_reviewee, :type => "ReviewResponseMap"})
        end
      end
    end
  end

  def action_allowed?
    case params[:action]
    when 'review_bid', 'set_priority','get_quartiles'
      ['Instructor',
       'Teaching Assistant',
       'Administrator',
       'Super-Administrator',
       'Student'].include? current_role_name and
      ((%w[list].include? action_name) ? are_needed_authorizations_present?(params[:id], "reader", "submitter", "reviewer") : true)
    else
      ['Instructor',
       'Teaching Assistant',
       'Administrator',
       'Super-Administrator'].include? current_role_name
    end
  end

  #This method is responsible for getting the sign-up topics present in the current assignment so that
  # we can display in the topics   # table on the left side.Also, we will make sure that the topics on
  # the left side will not contain the topic the user has worked on.  # Then we retrieve the bids made
  # by the user for reviews from the review_bids model based on the participant id and the assignment
  # in which the participant works on.We make sure that the topics which the user has bid is not
  # displayed in the topics table.
  def review_bid
    @participant = AssignmentParticipant.find(params[:id].to_i)
    @assignment = @participant.assignment
    @sign_up_topics = SignUpTopic.where(assignment_id: @assignment.id, private_to: nil)
    team_id = @participant.team.try(:id)
    my_topic = SignedUpTeam.where(team_id: team_id).pluck(:topic_id).first
    @sign_up_topics -= SignUpTopic.where(assignment_id: @assignment.id, id: my_topic)
    @max_team_size = @assignment.max_team_size
    @selected_topics =nil
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

  def run_intelligent_assignment
    priority_info = []
    assignment = Assignment.find_by(id: params[:id])
    topics = assignment.sign_up_topics
    teams = assignment.teams
    teams.each do |team|
      # Exclude any teams already signed up
      next if SignedUpTeam.where(team_id: team.id, is_waitlisted: 0).any?
      # Grab student id and list of bids
      bids = []
      topics.each do |topic|
        bid_record = Bid.find_by(team_id: team.id, topic_id: topic.id)
        bids << (bid_record.nil? ? 0 : bid_record.priority ||= 0)
      end
      team.users.each {|user| priority_info << {pid: user.id, ranks: bids} if bids.uniq != [0] }
    end
    bidding_data = {users: priority_info, max_team_size: assignment.max_team_size}
    ExpertizaLogger.info LoggerMessage.new(controller_name, session[:user].name, "Bidding data for assignment #{assignment.name}: #{bidding_data}", request)
    url = WEBSERVICE_CONFIG["topic_bidding_webservice_url"]
    begin
      response = RestClient.post url, bidding_data.to_json, content_type: :json, accept: :json
      teams = JSON.parse(response)["teams"]
      ExpertizaLogger.info LoggerMessage.new(controller_name, session[:user].name, "Team formation info for assignment #{assignment.name}: #{teams}", request)
      create_new_teams_for_bidding_response(teams, assignment, priority_info)
      match_new_teams_to_topics(assignment)
    rescue StandardError => e
      flash[:error] = e.message
    end
    redirect_to controller: 'tree_display', action: 'list'
  end

  #This method is hit when we try to drag and drop the topics from the topics ->selections table
  # as well as selections to topics table.Also, if we juggle the topics in the selections table,
  # then also the the tablelist coffee file is invoked.We are making sure that we we move the topics
  # from the selection table to topics table, those records are deleted from the review_bids model.
  # Also, we create records if the bid never existed.
  def set_priority
    if params[:topic].nil?
      ReviewBid.where(participant_id: params[:participant_id]).destroy_all
    else
      participant = AssignmentParticipant.find_by(id: params[:participant_id])
      assignment_id = SignUpTopic.find(params[:topic].first).assignment.id
      team_id = participant.team.try(:id)
      @bids = ReviewBid.where(participant_id: params[:participant_id])
      signed_up_topics = ReviewBid.where(participant_id: params[:participant_id]).map(&:sign_up_topic_id)
      signed_up_topics -= params[:topic].map(&:to_i)
      signed_up_topics.each do |topic|
        ReviewBid.where(sign_up_topic_id: topic, participant_id: params[:participant_id]).destroy_all
      end
      params[:topic].each_with_index do |topic_id, index|
        bid_existence = ReviewBid.where(sign_up_topic_id: topic_id, participant_id: params[:participant_id])
        if bid_existence.empty?
          ReviewBid.create(priority: index + 1,sign_up_topic_id: topic_id, participant_id: params[:participant_id],assignment_id: assignment_id)
        else
          ReviewBid.where(sign_up_topic_id: topic_id, participant_id: params[:participant_id]).update_all(priority: index + 1)
        end
      end
    end
  end

  # Helper Method to check if service has already been run by the instructor
  def check_if_response_maps_present(assignment_id)
    ReviewResponseMap.where(reviewed_object_id: assignment_id).any?
  end 
  helper_method :check_if_response_maps_present

  def get_quartiles(topic_id)
    assignment_id = SignUpTopic.where(id: topic_id).pluck(:assignment_id).first
    num_reviews_allowed = Assignment.where(id: assignment_id).pluck(:num_reviews_allowed).first
    num_participants_in_assignment = AssignmentParticipant.where(parent_id: assignment_id).length
    num_topics_in_assignment = SignUpTopic.where(assignment_id: assignment_id).length
    num_choosers_this_topic = ReviewBid.where(sign_up_topic_id: topic_id).length
    avg_reviews_per_topic = (num_participants_in_assignment*num_reviews_allowed)/num_topics_in_assignment

    if num_choosers_this_topic < avg_reviews_per_topic/2
      return 'rgb(124,252,0)'
    elsif num_choosers_this_topic > avg_reviews_per_topic/2 and num_choosers_this_topic < (3/4)*avg_reviews_per_topic
      return 'rgb(255,255,0)'
    else
      return 'rgb(255,99,71)'
    end
  end
  helper_method :get_quartiles
end
