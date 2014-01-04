require 'test_helper'

class LotteryControllerTest < ActionController::TestCase

  fixtures :assignments, :sign_up_topics, :signed_up_users, :teams, :teams_users, :users

  def setup
    @controller = LotteryController.new
  end

  test "delete_other_bids" do
    assignment_id = assignments(:lottery_assignment).id
    user_id = users(:student1).id
    @controller.delete_other_bids(assignment_id, user_id)
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


end