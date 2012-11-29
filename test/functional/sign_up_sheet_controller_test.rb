require "test_helper"

class SignUpSheetControllerTest < ActionController::TestCase
  fixtures :users, :roles, :teams, :assignments, :nodes, :system_settings, :content_pages, :permissions, :participants
  fixtures :roles_permissions, :controller_actions, :site_controllers, :menu_items, :bids, :sign_up_topics, :teams_users

  def setup
    @controller = SignUpSheetController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @student1 = users(:student1)
    @student2 = users(:student1)
    @request.session[:user] = @student1

    @team = teams(:lottery_team1)
    @assignment = assignments(:lottery_assignment)
    @topic = sign_up_topics(:LotteryTopic1)
    #go to the topic view
    post :sign_up_topics, {:id => @assignment.id}

  end

  test "should submit bid" do
    post :submit_bid, {:assignment_id => @assignment.id, :id => @topic.id }
    assert_not_nil Bid.find_by_team_id_and_topic_id(@team.id, @topic.id)
    assert_redirected_to :action =>  :signup_topics, :id => @assignment.id

  end

  test "should not submit bid twice" do
    post :submit_bid, {:assignment_id => @assignment.id, :id => @topic.id }
    post :submit_bid, {:assignment_id => @assignment.id, :id => @topic.id }
    assert_equal "Your team has already bid for topic #{SignUpTopic.find(@topic.id).topic_name}", flash[:notice]
    assert_redirected_to :action =>  :signup_topics, :id => @assignment.id

  end

  test "should delete my bid" do
    @bid = bids(:bid1)
    assert_difference('Bid.count', -1) do
      post :delete_bid, {:id => @bid.id, :assignment_id => @assignment.id }
    end
    assert_redirected_to :action =>  :signup_topics, :id => @assignment.id

  end

  test "should delete a team bid" do
    post :submit_bid, {:assignment_id => @assignment.id, :id => @topic.id }
    @request.session[:user] = @student2
    post :sign_up_topics, {:id => @assignment.id}
    @bid = Bid.find_by_team_id_and_topic_id(@team.id, @topic.id)

    assert_difference('Bid.count', -1) do
      post :delete_bid, {:id => @bid.id, :assignment_id => @assignment.id }
    end

    assert_redirected_to :action =>  :signup_topics, :id => @assignment.id

  end

  test "should not have more than 3 bids" do
    @topic2 = sign_up_topics(:LotteryTopic2)
    @topic3 = sign_up_topics(:LotteryTopic3)
    @topic4 = sign_up_topics(:LotteryTopic4)

    post :submit_bid, {:assignment_id => @assignment.id, :id => @topic.id }
    post :submit_bid, {:assignment_id => @assignment.id, :id => @topic2.id }
    post :submit_bid, {:assignment_id => @assignment.id, :id => @topic3.id }
    post :submit_bid, {:assignment_id => @assignment.id, :id => @topic4.id }

    assert_equal "Your team has bid the maximum amount of bids", flash[:notice]
    assert_redirected_to :action =>  :signup_topics, :id => @assignment.id



  end

  test "should not have 3 bids as other teammate" do
    @topic2 = sign_up_topics(:LotteryTopic2)
    @topic3 = sign_up_topics(:LotteryTopic3)
    @topic4 = sign_up_topics(:LotteryTopic4)

    post :submit_bid, {:assignment_id => @assignment.id, :id => @topic.id }
    post :submit_bid, {:assignment_id => @assignment.id, :id => @topic2.id }
    @request.session[:user] = @student2
    post :sign_up_topics, {:id => @assignment.id}
    post :submit_bid, {:assignment_id => @assignment.id, :id => @topic3.id }
    post :submit_bid, {:assignment_id => @assignment.id, :id => @topic4.id }

    assert_equal "Your team has bid the maximum amount of bids", flash[:notice]
    assert_redirected_to :action =>  :signup_topics, :id => @assignment.id
  end
end