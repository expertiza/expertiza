require "test_helper"

class SignUpSheetControllerTest < ActionController::TestCase
  fixtures :users, :roles, :teams, :assignments, :nodes, :system_settings, :content_pages, :permissions, :participants
  fixtures :roles_permissions, :controller_actions, :site_controllers, :menu_items, :bids, :sign_up_topics, :teams_users

  def setup
    @controller = SignUpSheetController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @student = users(:student1)
    @request.session[:user] = @student

    @team = teams(:team0)
    @assignment = assignments(:assignment0)
    @topic = sign_up_topics(:LotteryTopic1)
    #go to the topic view
    post :sign_up_topics, {:id => @assignment.id}

  end

  test "submit valid bid" do
    puts "Submit bid by current user #{@student.name}"
    puts "on assignment #{@assignment.name}, #{@assignment.id}"
    puts "for topic #{@topic.topic_name}, #{@topic.id}"

    post :submit_bid, {:assignment_id => @assignment.id, :id => @topic.id }
    assert_not_nil Bid.find_by_team_id_and_topic_id(@team.id, @topic.id)
  end

  test "delete my bid" do

  end

  test "delete a teammates bid" do

  end

  test "submit more than 3 bids" do

  end

  test "submit more than 3 bids as other teammate" do

  end
end