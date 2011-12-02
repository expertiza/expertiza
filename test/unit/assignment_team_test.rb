require File.dirname(__FILE__) + '/../test_helper'

class AssignmentTeamTest < ActiveSupport::TestCase
  fixtures :courses, :assignments, :teams, :users, :participants

  def test_get_pairing_conflict_is_nil
    team = AssignmentTeam.find_by_name("team_conflict3")
    participant = AssignmentParticipant.find_by_handle("par_conflict_9")
    conflict = team.get_pairing_conflict(participant)
    assert_nil(conflict)
  end

  def test_get_pairing_conflict_is_max
    team = AssignmentTeam.find_by_name("team_conflict3")
    participant = AssignmentParticipant.find_by_handle("par_conflict_8")
    conflict = team.get_pairing_conflict(participant)
    assert_equal(:max_duplicate_pairings, conflict.conflict_type)
  end
end
