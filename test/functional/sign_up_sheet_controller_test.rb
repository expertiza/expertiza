require "test_helper"

class SignUpSheetControllerTest < ActionController::TestCase
  fixtures :users, :roles, :teams, :assignments, :nodes, :system_settings, :content_pages, :permissions, :participants
  fixtures :roles_permissions, :controller_actions, :site_controllers, :menu_items, :bids, :sign_up_topics, :teams_users

  def setup
    @controller = SignUpSheetController.new
    #go to the topic view
    @controller.signup_topics
  end

  test "submit valid bid" do
    student = users(:student1)
    team = teams(:team0)
    assignment = assignments(:assignment0)

    assert @controller.submit_bid, "submit_bid returned true"
    #assert_equal Bid.find_by_team_id_and_topic_id(team.id, topic.id)


  end

  test "submit invalid bid" do

  end

  test "delete bid" do

  end


  # Called after every test method runs. Can be used to tear
  # down fixture information.
  def teardown
    # Do nothing
  end

  # Fake test
  def test_fail

    # To change this template use File | Settings | File Templates.
    fail("Not implemented")
  end
end