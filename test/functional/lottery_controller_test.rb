require 'test_helper'
require 'lottery_controller'


class LotteryControllerTest < ActionController::TestCase
  fixtures :users, :roles, :teams, :assignments, :nodes, :system_settings, :content_pages, :permissions, :participants
  fixtures :roles_permissions, :controller_actions, :site_controllers, :menu_items, :bids, :sign_up_topics, :teams_users

  def setup
    @controller = LotteryController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @request.session[:user] = User.find(users(:superadmin).id )
    roleid = User.find(users(:superadmin).id).role_id
    Role.rebuild_cache

    Role.find(roleid).cache[:credentials]
    @request.session[:credentials] = Role.find(roleid).cache[:credentials]
    # Work around a bug that causes session[:credentials] to become a YAML Object
    @request.session[:credentials] = nil if @request.session[:credentials].is_a? YAML::Object
    @settings = SystemSettings.find(:first)
    AuthController.set_current_role(roleid,@request.session)

    @testUser = users(:student1).id

  end

  test "assign topic to team" do
    bid = bids(:bid1)
    student = users(:student1)

    # Make sure that no team currently has the topic
    assert_nil Participant.find_by_user_id_and_parent_id(student.id, bid.topic.assignment.id).topic,
                     "the user should not be signed up for the topic"
    # Give the topic to a team
    assert @controller.assign_team_topic(bid), "assign_team_topic returned true"
    # Make sure the team was actually given the topic
    assert_equal Participant.find_by_user_id_and_parent_id(student.id, bid.topic.assignment.id).topic.id,
                     bid.topic.id, "the user should be signed up for the topic"
  end

  test "get teams for topic" do
    topic = sign_up_topics(:LotteryTopic5)
    assert_not_nil topic

    # There should be no teams on the topic right now
    assigned_teams = @controller.get_teams_for_topic(topic)
    assert_equal assigned_teams.length, 0
    # Give the topic to a team
    assert @controller.assign_team_topic(bids(:bid4)), "assign_team_topic returned true"
    # test that the team is found by get_teams
    assigned_teams = @controller.get_teams_for_topic(topic)
    assert_equal assigned_teams[0], teams(:lottery_team2)
    assert_equal assigned_teams.length, 1
    # Give the topic to another team
    assert @controller.assign_team_topic(bids(:bid5)), "assign_team_topic returned true"

    assigned_teams = @controller.get_teams_for_topic(topic)
    assert_equal assigned_teams[0], teams(:lottery_team3)
    assert_equal assigned_teams[1], teams(:lottery_team2)
    assert_equal assigned_teams.length, 2
  end

  test "make weighted bids array" do
    topic = sign_up_topics(:LotteryTopic1)
    bids = [bids(:bid1), bids(:bid2)]

    # Make sure there are two bids for the topic
    assert_equal 2, Bid.find_all_by_topic_id(topic.id).size, "there should be two bids for the topic"

    # Make the weighted array for the topic
    weighted_bid_array = @controller.make_weighted_bid_array(topic)

    # Make sure the weighted array has 3 entries (2 for the first bid and 1 for the second)
    assert_equal 3, weighted_bid_array.size, "the weighted bid array should have three elements"

    # Create a hash for each bid and count the number if times it is in the weighted array
    bid_hash = Hash.new(0)
    weighted_bid_array.each do |bid|
      bid_hash[bid] += 1
    end
    # Make sure the first bid is in the weighted array twice
    assert_equal 2, bid_hash[bids[0]], "the first bid should get two entries"
    # Make sure the second bid is in the weighted array once
    assert_equal 1, bid_hash[bids[1]], "the second bid should get one entry"
  end

  test "choose winner" do
    bid = bids(:bid1)
    team1 = teams(:lottery_team1)
    team1_student = team1.users[0]
    team2 = teams(:lottery_team2)
    team2_student = team2.users[0]
    topic = sign_up_topics(:LotteryTopic1)
    assignment = assignments(:lottery_assignment)

    # Make sure that no team currently has the topic
    assert_nil Participant.find_by_topic_id(topic.id), "there shouldn't be any participants with the topic"
    # Make sure there are two bids for the topic
    assert_equal 2, Bid.find_all_by_topic_id(topic.id).size, "there should be one bid for the topic"

    # Assign the topic to a random team
    @controller.choose_winner_for_topic(topic, assignment.team_count)

    # Make sure that one team was given the topic and the other team wasn't
    winning_team_id = nil
    if Participant.find_by_user_id_and_parent_id(team1_student.id, topic.assignment.id).topic != nil
      winning_team_id = team1.id
      assert_equal topic.id, Participant.find_by_user_id_and_parent_id(team1_student.id, topic.assignment.id).topic.id,
             "the winning team should be signed up for the topic"
      assert_equal nil, Participant.find_by_user_id_and_parent_id(team2_student.id, topic.assignment.id).topic,
             "the losing team should not be signed up for the topic"
    else
      winning_team_id = team2.id
      assert_equal topic.id, Participant.find_by_user_id_and_parent_id(team2_student.id, topic.assignment.id).topic.id,
                   "the winning team should be signed up for the topic"
      assert_equal nil, Participant.find_by_user_id_and_parent_id(team1_student.id, topic.assignment.id).topic,
                   "the losing team should not be signed up for the topic"
    end

    # Make sure all bids were deleted for the winning team and for the topic
    assert_equal 0, Bid.find(:all, :conditions => "team_id=#{winning_team_id} OR topic_id=#{topic.id}").size,
                 "there should be no bids for the topic"
  end

  test "fill team" do
    team2 = teams(:lottery_team2)
    team1 = teams(:lottery_team1)
    team1_size = team1.users.size
    team2_size = team2.users.size

    topic = sign_up_topics(:LotteryTopic5)
    assert_not_nil topic
    assert @controller.assign_team_topic(bids(:bid4)), "assign_team_topic returned true"
    assigned_teams = @controller.get_teams_for_topic(topic)
    assert_equal assigned_teams[0], team2
    assert_equal team2.users.size, team2_size
    assert_equal team1.users.size, team1_size

    @controller.fill_team(team2, [bids(:bid6)], team1_size+team2_size)
    assert_equal 0, team1.users.size,
                   "The second team should no longer have users"

    assert_equal team2.users.size, (team2_size+team1_size),
                   "The users of the second team should have been added to the first team"
    assert_equal team2.users[0], users(:student3)
    assert_equal team2.users[1], users(:student1)
    assert_equal team2.users[2], users(:student2)

  end

  test "merge team A with team B" do
    team1 = teams(:lottery_team1)
    team1_size = team1.users.size
    team2 = teams(:lottery_team2)
    team2_size = team2.users.size

    @controller.merge_teams(team1, team2)

    assert_equal 0, team2.users.size,
                 "The second team should no longer have users"
    assert_equal team1.users.size, (team2_size+team1_size),
                 "The users of the second team should have been added to the first team"
  end

  test "run lottery" do
    session[:return_to] = "/sign_up_sheet/signup_topics"
    post :run_lottery, :id => assignments(:lottery_assignment).id, :referer => "/sign_up_sheet/signup_topics"

    a = 0
    [sign_up_topics(:LotteryTopic1),sign_up_topics(:LotteryTopic2),sign_up_topics(:LotteryTopic5)] .each do |topic|
      assigned_teams = @controller.get_teams_for_topic(topic)
      if assigned_teams.length > 0
       a = a+1
      end
    end

    assert a > 1
    assert_equal bids.size, 0
  end
end
