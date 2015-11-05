require File.dirname(__FILE__) + '/../test_helper'

class CourseTeamTest < ActiveSupport::TestCase
  fixtures :courses, :teams, :users, :teams_users, :participants, :assignments, :nodes, :roles


  def setup
    @course1 = courses(:course1)
    @course0 = courses(:course0)

    @course_team6 = teams(:team6)
    TeamNode.create(parent_id: @course0.id, node_object_id: @course_team6.id)
    @course_team7 = teams(:team7)
  end

  def test_retrieval
    assert_kind_of CourseTeam, @course_team6
    assert_equal "team6", @course_team6.name
    assert_equal teams(:team6).id, @course_team6.id
    assert_equal teams(:team6).parent_id, @course_team6.parent_id
    assert_equal @course_team6.participant_type, 'CourseParticipant'
    assert_equal @course_team6.get_node_type, 'TeamNode'
  end

  def test_import_participants
    row = ["instructor1", "student1", "student2"]
    @course_team6.import_team_members(0, row)
    assert_equal @course_team6.has_user(users(:instructor1)), true
    assert_equal @course_team6.has_user(users(:student1)), true
    assert_equal @course_team6.has_user(users(:student2)), true
  end

  def test_instance_export
    team_name_only = "false"
    output = @course_team7.export(team_name_only)
    assert_equal output[0], @course_team7.name
    assert_equal output[1], users(:student4).name
    assert_equal output[2], users(:student7).name
    assert_equal output[3], @course0.name
    team_name_only = "true"
    output = @course_team7.export(team_name_only)
    assert_equal output[0], @course_team7.name
    assert_equal output[1], @course0.name
  end

  def test_handle_duplicate
    #no duplicate
    course_id = courses(:course_object_oriented).id
    output = CourseTeam.handle_duplicate(nil, "DNE", course_id, "ignore")
    assert_equal output, "DNE"

    course_team = teams(:team8)

    handle_dups = "ignore"
    output = CourseTeam.handle_duplicate(course_team, course_team.name, @course0.id, handle_dups)
    assert_equal output, nil

    handle_dups = "rename"
    output = CourseTeam.handle_duplicate(course_team, course_team.name, @course0.id, handle_dups)
    assert_not_equal output, course_team.name

    handle_dups = "replace"
    output = CourseTeam.handle_duplicate(course_team, course_team.name, @course0.id, handle_dups)
    assert_equal output, course_team.name
    assert_equal Team.find_by_name(course_team.name), nil
  end

  def test_import
      row = ["student1", "student2", "student3"]
      options = {has_column_names: "false", handle_dups: "ignore"}
      course = courses(:course_object_oriented)
      CourseTeam.import(row, course.id, options)

      course_team = CourseTeam.find_by_parent_id(course.id)
      assert_not_equal course_team, nil

      student1 = users(:student1)
      student2 = users(:student2)
      student3 = users(:student3)

      assert_equal course_team.has_user(student1), true
      assert_equal course_team.has_user(student2), true
      assert_equal course_team.has_user(student3), true

      row = ["yay", "student1","student2", "student3"]
      options[:has_column_names] = "true"
      CourseTeam.import(row, course.id, options)

      course_team = CourseTeam.find_by_name("yay")
      assert_equal course_team.parent_id, course.id

      assert_equal course_team.has_user(student1), true
      assert_equal course_team.has_user(student2), true
      assert_equal course_team.has_user(student3), true
  end

  def test_class_export
    course_team6 = teams(:team6)
    course_team7 = teams(:team7)
    team6_student7 = users(:student7)
    course_team6.add_member(team6_student7, 1)

    output = Array.new
    options = {team_name: "true"}
    CourseTeam.export(output, @course0.id, options)
    assert_equal output[0][0], course_team6.name
    assert_equal output[0][1], @course0.name
    assert_equal output[1][0], course_team7.name
    assert_equal output[1][1], @course0.name

    output = Array.new
    options[:team_name] = "false"
    CourseTeam.export(output, @course0.id, options)
    assert_equal output[0][0], course_team6.name
    assert_equal output[0][1], team6_student7.name
    assert_equal output[0][2], @course0.name
    assert_equal output[1][0], course_team7.name
    assert_equal output[1][1], users(:student4).name
    assert_equal output[1][2], users(:student7).name
    assert_equal output[1][3], @course0.name
  end

  def test_export_fields
     options = {team_name: "false"}
     output = CourseTeam.export_fields(options)
     assert_equal output[0], "Team Name"
     assert_equal output[1], "Team members"
     assert_equal output[2], "Course Name"
  
     options[:team_name] = "true"
     output = CourseTeam.export_fields(options)
     assert_equal output[0], "Team Name"
     assert_equal output[1], "Course Name"
  end
  
  ##def test_copy
  ##  @assignment_team = @course_team.copy(0)
  ##  assert_kind_of AssignmentTeam, @assignment_team
  ##  assert_equal @assignment_team.users.count, @course_team.users.count
  ##end
  #
  ### test method dir_path
  ##def test_add_participant
  ##  assert_equal Rails.root + '/pg_data/instructor3/csc110/',@course0.dir_path
  ##end
end
