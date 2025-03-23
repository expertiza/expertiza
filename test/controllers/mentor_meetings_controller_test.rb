require 'test_helper'

class MentorMeetingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @mentor_meeting = mentor_meetings(:one)
  end

  test "should get index" do
    get mentor_meetings_url
    assert_response :success
  end

  test "should get new" do
    get new_mentor_meeting_url
    assert_response :success
  end

  test "should create mentor_meeting" do
    assert_difference('MentorMeeting.count') do
      post mentor_meetings_url, params: { mentor_meeting: { meeting_date: @mentor_meeting.meeting_date, team_id: @mentor_meeting.team_id } }
    end

    assert_redirected_to mentor_meeting_url(MentorMeeting.last)
  end

  test "should show mentor_meeting" do
    get mentor_meeting_url(@mentor_meeting)
    assert_response :success
  end

  test "should get edit" do
    get edit_mentor_meeting_url(@mentor_meeting)
    assert_response :success
  end

  test "should update mentor_meeting" do
    patch mentor_meeting_url(@mentor_meeting), params: { mentor_meeting: { meeting_date: @mentor_meeting.meeting_date, team_id: @mentor_meeting.team_id } }
    assert_redirected_to mentor_meeting_url(@mentor_meeting)
  end

  test "should destroy mentor_meeting" do
    assert_difference('MentorMeeting.count', -1) do
      delete mentor_meeting_url(@mentor_meeting)
    end

    assert_redirected_to mentor_meetings_url
  end
end
