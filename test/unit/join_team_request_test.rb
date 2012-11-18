require 'test_helper'

class JoinTeamRequestTest < ActiveSupport::TestCase
  fixtures :join_team_requests
  # Replace this with your real tests.

  def setup
    # Do nothing  @course = courses(:course1)
    @join_team_requests = join_team_requests(:one)
  end
  def test_retrieval
    assert_kind_of JoinTeamRequest, @join_team_requests
    assert_equal join_team_requests(:one).participant_id, @join_team_requests.participant_id
    assert_equal join_team_requests(:one).team_id, @join_team_requests.team_id
    assert_equal 'MyText', @join_team_requests.comments
    assert_equal join_team_requests(:one).status, @join_team_requests.status
  end

  def test_update
    assert_equal "MyText", @join_team_requests.comments
    @join_team_requests.comments = "Computer science"
    @join_team_requests.save
    @join_team_requests.reload
    assert_equal "Computer science", @join_team_requests.comments
  end

end

