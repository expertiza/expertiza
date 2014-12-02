require 'test_helper'

class LotteryControllerTest < ActionController::TestCase

  fixtures :assignments, :sign_up_topics, :signed_up_users, :teams, :teams_users, :users, :bids

  def setup
    @lotteryController = LotteryController.new
    @signupSheetController = SignUpSheetController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @request.session[:user] = User.find(users(:instructor1).id )

  end

  test "delete_other_bids" do
    assignment_id = assignments(:lottery_assignment).id
    user_id = users(:student1).id
    @lotteryController.delete_other_bids(assignment_id, user_id)
    bid = SignedUpUser.find_by_sql(["SELECT su.* FROM signed_up_users su , sign_up_topics st WHERE su.topic_id = st.id AND st.assignment_id = ? AND su.creator_id = ? AND su.is_waitlisted = 1",assignment_id,user_id] )
    assert_equal bid.size, 0
  end

  test "is_other_topic_of_higher_priority" do
    @controller = LotteryController.new
    assignment_id = assignments(:lottery_assignment).id
    team_id = teams(:lottery_team1).id
    priority = 3
    current_max_slots = Hash.new
    sign_up_topics = SignUpTopic.find(:all, :conditions => ['assignment_id = ?', assignment_id])
    sign_up_topics.each do |topic|
      current_max_slots[topic.id] = 0
    end

    result = @controller.is_other_topic_of_higher_priority(assignment_id, team_id, priority,current_max_slots)
    assert !result
  end

  test "run_intelligent_assignment for topic with bids" do
    assignment = assignments(:Intelligent_assignment)

    SignedUpUser.delete_all(:topic=>SignUpTopic.where(:assignment_id=>assignment.id))
    #Make sure that no topic has any signed up user currently
    assert_equal(SignedUpUser.where(:topic=>SignUpTopic.where(:assignment_id=>assignment.id)).size,0,"Topic still has users assigned")

    get :run_intelligent_bid, :id => assignment.id
    #Assert to see if some of the topics have been assigned teams
    assert_not_equal(SignedUpUser.where(:topic=>SignUpTopic.where(:assignment_id=>assignment.id)).size,0,"Topic bids still left unassigned")
  end

  test "run_intelligent_assignment for topic with no bids" do
    assignment = assignments(:Intelligent_assignment)

    #delete all bids
    Bid.where(:topic=>SignUpTopic.delete_all(:assignment_id=>assignment.id))

    SignedUpUser.delete_all(:topic=>SignUpTopic.where(:assignment_id=>assignment.id))
    #Make sure that no topic has any signed up user currently
    assert_equal(SignedUpUser.where(:topic=>SignUpTopic.where(:assignment_id=>assignment.id)).size,0,"Topic still has users assigned")

    get :run_intelligent_bid, :id => assignment.id
    #Assert to see that no topic has been accidently assigned
    assert_equal(SignedUpUser.where(:topic=>SignUpTopic.where(:assignment_id=>assignment.id)).size,0,"Topic still got assigned with 0 bids")
  end

end