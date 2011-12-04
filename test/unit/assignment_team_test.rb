require File.dirname(__FILE__) + '/../test_helper'

class AssignmentTeamTest < ActiveSupport::TestCase
  fixtures :courses, :assignments, :teams, :users, :participants, :teams_users

  def setup
    team = teams(:team_conflict_6)
    @assignmentTeam = AssignmentTeam.find_by_name(team.name)
    student1 = users(:student_conflict_1)
    @participant1 = AssignmentParticipant.find_by_user_id(student1.id)
    student2 = users(:student_conflict_2)
    @participant2 = AssignmentParticipant.find_by_user_id(student2.id)
    student3 = users(:student_conflict_3)
    @participant3 = AssignmentParticipant.find_by_user_id(student3.id)
    student4 = users(:student_conflict_4)
    @participant4 = AssignmentParticipant.find_by_user_id(student4.id)
    student5 = users(:student_conflict_5)
    @participant5 = AssignmentParticipant.find_by_user_id(student5.id)
  end

  def test_get_past_teammate_user_ids
    assert_equal(5, @assignmentTeam.get_past_teammate_user_ids(@participant1).length)
  end

  def test_get_max_past_teammates
    assert_equal(3, @assignmentTeam.get_max_past_teammates(@participant1))
  end

  def test_get_pairing_opportunities
    assert_equal(6, @assignmentTeam.get_pairing_opportunities)
  end

  def test_get_pairing_conflict_is_nil
    conflict = @assignmentTeam.get_pairing_conflict(@participant4)
    assert_nil(conflict)
  end

  def test_get_pairing_conflict_is_max
    conflict = @assignmentTeam.get_pairing_conflict(@participant2)
    assert_equal(@participant1, conflict.first_person)
    assert_equal(@participant2, conflict.second_person)
    assert_equal(:max_duplicate_pairings, conflict.type)
    assert_equal(2, conflict.threshold)
  end

  def test_get_pairing_conflict_is_min_1
    conflict = @assignmentTeam.get_pairing_conflict(@participant3)
    assert_equal(@participant1, conflict.first_person)
    assert_equal(@participant3, conflict.second_person)
    assert_equal(:min_unique_pairings, conflict.type)
    assert_equal(5, conflict.threshold)
  end

  def test_get_pairing_conflict_is_min_2
    conflict = @assignmentTeam.get_pairing_conflict(@participant5)
    assert_equal(@participant5, conflict.first_person)
    assert_equal(@participant5, conflict.second_person)
    assert_equal(:min_unique_pairings, conflict.type)
    assert_equal(5, conflict.threshold)
  end
end
