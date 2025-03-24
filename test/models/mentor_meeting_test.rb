require 'test_helper'

class MentorMeetingTest < ActiveSupport::TestCase
  setup do
    @team = teams(:one)  # Ensure 'teams.yml' has a fixture named :one
    @meeting = meetings(:one)  # Ensure 'meetings.yml' has a fixture named :one
  end

  # Test for valid meeting creation
  test "should be valid" do
    mentor_meeting = MentorMeeting.new(team_id: teams(:one).id, meeting_date: "2025-04-01")
    assert mentor_meeting.valid?, "Mentor meeting should be valid with valid attributes"
  end

  # Test for presence of team_id
  test "should require a team_id" do
    mentor_meeting = MentorMeeting.new(meeting_date: "2025-04-01")
    assert_not mentor_meeting.valid?, "Mentor meeting should be invalid without a team_id"
    assert mentor_meeting.errors[:team_id].any?, "Team ID should be present"
  end

  # Test for presence of meeting_date
  test "should require a meeting_date" do
    mentor_meeting = MentorMeeting.new(team_id: teams(:one).id)
    assert_not mentor_meeting.valid?, "Mentor meeting should be invalid without a meeting_date"
    assert mentor_meeting.errors[:meeting_date].any?, "Meeting date should be present"
  end

  # Test for valid meeting_date format (you can adjust the format based on your needs)
  test "should have a valid meeting_date format" do
    mentor_meeting = MentorMeeting.new(team_id: teams(:one).id, meeting_date: "invalid_date")
    assert_not mentor_meeting.valid?, "Mentor meeting should be invalid with an incorrect meeting_date format"
    assert mentor_meeting.errors[:meeting_date].any?, "Meeting date should be in the correct format"
  end

  # Test association with Team (assuming your model has this association)
  test "should belong to a team" do
    mentor_meeting = MentorMeeting.new(team_id: teams(:one).id, meeting_date: "2025-04-01")
    assert mentor_meeting.team, "Mentor meeting should belong to a team"
  end

  # Test that the meeting_date cannot be in the past
  test "should not allow past meeting_date" do
    mentor_meeting = MentorMeeting.new(team_id: teams(:one).id, meeting_date: 1.day.ago)
    assert_not mentor_meeting.valid?, "Mentor meeting should not be valid with a past meeting_date"
    assert mentor_meeting.errors[:meeting_date].any?, "Meeting date should not be in the past"
  end

  # Test for the dates_for_teams method
  test "should return dates for multiple teams" do
    team_ids = [teams(:one).id, teams(:two).id]
    mentor_meeting_1 = MentorMeeting.create!(team_id: teams(:one).id, meeting_date: "2025-04-01")
    mentor_meeting_2 = MentorMeeting.create!(team_id: teams(:one).id, meeting_date: "2025-04-15")
    mentor_meeting_3 = MentorMeeting.create!(team_id: teams(:two).id, meeting_date: "2025-05-01")

    dates = MentorMeeting.dates_for_teams(team_ids)

    # Assert that the result contains team IDs as keys and arrays of dates as values
    assert_equal [mentor_meeting_1.meeting_date, mentor_meeting_2.meeting_date], dates[teams(:one).id]
    assert_equal [mentor_meeting_3.meeting_date], dates[teams(:two).id]
  end

  # Test for the dates_for_teams method when no meetings exist
  test "should return empty dates for teams with no meetings" do
    team_ids = [teams(:one).id, teams(:three).id]  # Assuming :three has no meetings
    dates = MentorMeeting.dates_for_teams(team_ids)

    assert_equal [], dates[teams(:one).id]  # Should return an empty array for :one if no meetings exist
    assert_equal [], dates[teams(:three).id]  # Should return an empty array for :three as there are no meetings
  end
end
