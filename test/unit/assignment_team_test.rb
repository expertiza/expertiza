require File.dirname(__FILE__) + '/../test_helper'

class AssignmentTeamTest < ActiveSupport::TestCase
  fixtures :courses, :assignments, :teams, :users, :participants, :teams_users

  def test_get_past_teammate_user_ids
    team = teams(:team_conflict_3)
    assignmentTeam = AssignmentTeam.find_by_name(team.name)
    student = users(:student_conflict_1)
    participant = AssignmentParticipant.find_by_user_id(student.id)
    assert_equal(5, assignmentTeam.get_past_teammate_user_ids(participant).length)
  end

  def test_get_max_past_teammates
    team = teams(:team_conflict_3)
    assignmentTeam = AssignmentTeam.find_by_name(team.name)
    student = users(:student_conflict_1)
    participant = AssignmentParticipant.find_by_user_id(student.id)
    assert_equal(3, assignmentTeam.get_max_past_teammates(participant))
  end

  def test_get_pairing_opportunities
    team = teams(:team_conflict_3)
    assignmentTeam = AssignmentTeam.find_by_name(team.name)
    assert_equal(4, assignmentTeam.get_pairing_opportunities)
  end

  def test_get_pairing_conflict_is_nil
    team = teams(:team_conflict_3)
    assignmentTeam = AssignmentTeam.find_by_name(team.name)
    student = users(:student_conflict_3)
    participant = AssignmentParticipant.find_by_user_id(student.id)
    conflict = assignmentTeam.get_pairing_conflict(participant)
    assert_nil(conflict)
  end

  def test_get_pairing_conflict_is_max
    team = teams(:team_conflict_3)
    assignmentTeam = AssignmentTeam.find_by_name(team.name)
    student = users(:student_conflict_2)
    participant = AssignmentParticipant.find_by_user_id(student.id)
    conflict = assignmentTeam.get_pairing_conflict(participant)
    assert_equal(:max_duplicate_pairings, conflict.conflict_type)
  end
end
