require "test_helper"

class MentorMeetingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @team = teams(:one)  # Ensure 'teams.yml' has a fixture named :one
    @meeting = meetings(:one)  # Ensure 'meetings.yml' has a fixture named :one
  end

  test "should get index" do
    get meetings_url
    assert_response :success
    assert_not_nil assigns(:mentor_meetings)
    assert_not_nil assigns(:teams)
    assert_not_nil assigns(:mentored_teams)
  end

  test "should show meeting" do
    get meeting_url(@meeting)
    assert_response :success
  end

  test "should create meeting" do
    assert_difference("Meeting.count" , 1) do
      post meetings_url, params: { meeting: { team_id: @team.id, meeting_date: "2025-04-01" } }
    end
    assert_response :created
    assert_equal "success", JSON.parse(response.body)["status"]
  end

  test "should update meeting" do
    patch meeting_url(@meeting), params: { meeting: { meeting_date: "2025-05-01" } }
    assert_response :success
    assert_equal "success", JSON.parse(response.body)["status"]
  end

  test "should delete meeting" do
    assert_difference("Meeting.count", -1) do
      delete meeting_url(@meeting)
    end
    assert_response :success
  end

  test "should return error for invalid meeting deletion" do
    delete meeting_url(id: -1, team_id: @team.id)
    assert_response :not_found
  end
end
