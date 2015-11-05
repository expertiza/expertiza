require File.dirname(__FILE__) + '/../test_helper'

class AssignmentTeamTest < ActiveSupport::TestCase
  fixtures :courses, :teams, :users, :teams_users, :participants, :assignments, :nodes, :roles
  
  def setup
    @course = courses(:course1)
    @course0 = courses(:course0)

    @assignment_team1 = teams(:team1)
    TeamNode.create(parent_id: 1, node_object_id: @assignment_team1.id)
    @assignment_team2 = teams(:team2)
    TeamNode.create(parent_id: 1, node_object_id: @assignment_team2.id)
    @assignment_team3 = teams(:team3)
    TeamNode.create(parent_id: 1, node_object_id: @assignment_team3.id)
  end
  
  def test_import_participants
    row = ["instructor1", "student1", "student2"]
    @assignment_team3.import_team_members(0, row)
    assert_equal @assignment_team3.has_user(users(:instructor1)), true
    assert_equal @assignment_team3.has_user(users(:student1)), true
    assert_equal @assignment_team3.has_user(users(:student2)), true
  end

  def test_import
      row = ["student1", "student2", "student3"]
      options = {has_column_names: "false", handle_dups: "ignore"}
      assignment = assignments(:assignment3)
      AssignmentTeam.import(row, assignment.id, options)

      assignment_team = AssignmentTeam.find_by_parent_id(assignment.id)
      assert_not_equal assignment_team, nil

      student1 = users(:student1)
      student2 = users(:student2)
      student3 = users(:student3)

      assert_equal assignment_team.has_user(student1), true
      assert_equal assignment_team.has_user(student2), true
      assert_equal assignment_team.has_user(student3), true

      row = ["yay", "student1","student2", "student3"]
      options[:has_column_names] = "true"
      AssignmentTeam.import(row, assignment.id, options)

      assignment_team = AssignmentTeam.find_by_name("yay")
      assert_equal assignment_team.parent_id, assignment.id

      assert_equal assignment_team.has_user(student1), true
      assert_equal assignment_team.has_user(student2), true
      assert_equal assignment_team.has_user(student3), true
  end
  
  def test_export
    assignment = assignments(:assignment1)
    team2_student7 = users(:student7)
    @assignment_team2.add_member(team2_student7, 1)

    output = Array.new
    options = {"team_name" => "true"}
    AssignmentTeam.export(output, assignment.id, options)
    assert_equal output[0][0], @assignment_team1.name
    assert_equal output[0][1], assignment.name
    assert_equal output[1][0], @assignment_team2.name
    assert_equal output[1][1], assignment.name

    output = Array.new
    options["team_name"] = "false"
    AssignmentTeam.export(output, assignment.id, options)
    assert_equal output[0][0], @assignment_team1.name
    assert_equal output[0][1], users(:student2).name
    assert_equal output[0][2], users(:student1).name
    assert_equal output[0][3], assignment.name
    assert_equal output[1][0], @assignment_team2.name
    assert_equal output[1][1], users(:student3).name
    assert_equal output[1][2], users(:student7).name
    assert_equal output[1][3], assignment.name
  end

  def test_export_fields
     options = {team_name: "false"}
     output = AssignmentTeam.export_fields(options)
     assert_equal output[0], "Team Name"
     assert_equal output[1], "Team members"
     assert_equal output[2], "Assignment Name"
  
     options[:team_name] = "true"
     output = AssignmentTeam.export_fields(options)
     assert_equal output[0], "Team Name"
     assert_equal output[1], "Assignment Name"
  end
  
end
