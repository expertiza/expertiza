#require File.dirname(__FILE__) + '/../test_helper'
require 'test_helper'
#require 'join_team_requests_controller'

class JoinTeamRequestsControllerTest < ActionController::TestCase
  fixtures :join_team_requests

  def setup
    @join_team_requests = join_team_requests(:one)
    puts 'join_team:'+@join_team_requests.to_json
  end

  def test_should_get_new
    join_team_requests = JoinTeamRequest.new(:id => 1, :participant_id => 1, :team_id => 5, :comments => 'new Comments', :status => 'P')
    assert join_team_requests.save
  end

  test "should get edit" do
    join_team_requests = JoinTeamRequest.find_by_participant_id(join_team_requests(:one).participant_id)
    join_team_requests.comments = 'Hello'
    join_team_requests.save
    assert_response :success
  end

  test "should destroy join_team_request" do
    assert_difference('JoinTeamRequest.count', -1) do
      delete :destroy, :id => 11
    end
    assert_redirected_to join_team_requests_path
  end
end

