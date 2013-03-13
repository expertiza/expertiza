require File.dirname(__FILE__) + '/../test_helper'

class CourseTeam < ActiveSupport::TestCase
  fixtures :courses,:teams,:users,:participants,:assignments,:nodes,:tree_folders

  def setup
    @course = courses(:course1)
    @course0 = courses(:course0)

    @course_team = teams(:team2)
    @course_team0 = teams(:team7)
  end

  def test_retrieval
    assert_kind_of CourseTeam, @course_team
    assert_equal "team3", @course_team.name
    assert_equal teams(:team2).id, @course_team.id
    assert_equal teams(:team2).parent_id, @course_team.parent_id
    assert_equal @course_team.get_participant_type, 'CourseParticipant'
    assert_equal @course_team.get_parent_model, 'Course'
    assert_equal @course_team.get_node_type, 'TeamNode'
  end

  def test_copy
    @assignment_team = @course_team.copy(0)
    assert_kind_of AssignmentTeam, @assignment_team
    assert_equal @assignment_team.users.count, @course_team.users.count
  end

  # test method get_path
  def test_add_participant
    assert_equal RAILS_ROOT + '/pg_data/instructor3/csc110/',@course0.get_path
  end

  # test method get_participants
  def test_get_participants
    @participants = @course0.get_participants
    assert_equal 4, @participants.count
  end

  def test_import
      row = ["user1","user2", "user3"]
      options[:has_column_names] == "false"
      options[:handle_dups] == "ignore"
      assignment_id = 0
      CourseTeam.import(row, nil, assignment_id, options)

      participants = CourseTeam.last.participants
      assert_equal participants.count, 3
      assert_equal participants[0], "user1"
      assert_equal participants[1], "user2"
      assert_equal participants[2], "user3"

  end

  def test_export

  end

  def test_get_export_fields
     options["team_name"] = "false"
     output = CourseTeam.get_export_fields(options)
     assert_equal output[0], "Team Name"
     assert_equal output[1], "Team members"
     assert_equal output[2], "Assignment Name"

     options["team_name"] = "true"
     output = CourseTeam.get_export_fields(options)
     assert_equal output[0], "Team Name"
     assert_equal output[1], "Assignment Name"
  end
end
