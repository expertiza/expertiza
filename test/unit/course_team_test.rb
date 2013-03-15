require File.dirname(__FILE__) + '/../test_helper'

class CourseTeamTest < ActiveSupport::TestCase
  fixtures :courses,:teams,:users,:participants,:assignments,:nodes,:tree_folders,:teams_users, :roles


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

  def test_import_participants
    row = ["instructor1", "student1", "student2"]
    teams(:team2).import_participants(0, row)
    assert_equal teams(:team2).has_user(users(:instructor1)), true
    assert_equal teams(:team2).has_user(users(:student1)), true
    assert_equal teams(:team2).has_user(users(:student2)), true
  end

  def test_export_participants
    output = teams(:team2).export_participants
    assert_equal output[0], teams_users(:teams_users4).name
    assert_equal output[1], " "
  end

  def test_instance_export
    course = courses(:course0)
    team_name_only = "false"
    output = teams(:team2).export(team_name_only)
    assert_equal output[0], teams(:team2).name
    assert_equal output[1][0], users(:student6).name
    assert_equal output[2], course.name
    team_name_only = "true"
    output = teams(:team2).export(team_name_only)
    assert_equal output[0], teams(:team2).name
    assert_equal output[1], course.name
  end

  def test_handle_duplicate
    #no duplicate
    course_id = courses(:course_object_oriented).id
    output = CourseTeam.handle_duplicate("DNE", course_id, "ignore")
    assert_equal output, "DNE"

    course =  courses(:course0)
    course_team = teams(:team2)

    handle_dups = "ignore"
    output = CourseTeam.handle_duplicate(course_team.name, course.id, handle_dups)
    assert_equal output, nil

    handle_dups = "rename"
    output = CourseTeam.handle_duplicate(course_team.name, course.id, handle_dups)
    assert_not_equal output, course_team.name

    handle_dups = "replace"
    output = CourseTeam.handle_duplicate(course_team.name, course.id, handle_dups)
    assert_equal output, course_team.name
    assert_equal Team.find_by_name(course_team.name), nil
  end

  def test_import
      row = ["student1","student2", "student3"]
      options = {:has_column_names => "false", :handle_dups => "ignore"}
      course = courses(:course_object_oriented)
      CourseTeam.import(row, nil, course.id, options)

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
      CourseTeam.import(row, nil, course.id, options)

      course_team = CourseTeam.find_by_name("yay")
      assert_equal course_team.parent_id, course.id

      assert_equal course_team.has_user(student1), true
      assert_equal course_team.has_user(student2), true
      assert_equal course_team.has_user(student3), true
  end

  def test_class_export
    course = courses(:course0)
    course_team0 = teams(:team2)
    course_team1 = teams(:team7)
    team0_student0 = users(:student6)

    output = Array.new
    options = {:team_name => "true"}
    CourseTeam.export(output, course.id, options)
    #assert_equal '',output
    assert_equal output[0][0], course_team0.name
    assert_equal output[0][1], course.name
    assert_equal output[1][0], course_team1.name
    assert_equal output[1][1], course.name

    output = Array.new
    options[:team_name] = "false"
    CourseTeam.export(output, course.id, options)
    assert_equal output[0][0], course_team0.name
    assert_equal output[0][1][0], team0_student0.name
    assert_equal output[0][1][1], " "
    assert_equal output[0][2], course.name
    assert_equal output[1][0], course_team1.name
    assert_equal output[1][1][0], nil
    assert_equal output[1][2], course.name
  end

  ##def test_get_export_fields
  ##   options["team_name"] = "false"
  ##   output = CourseTeam.get_export_fields(options)
  ##   assert_equal output[0], "Team Name"
  ##   assert_equal output[1], "Team members"
  ##   assert_equal output[2], "Assignment Name"
  ##
  ##   options["team_name"] = "true"
  ##   output = CourseTeam.get_export_fields(options)
  ##   assert_equal output[0], "Team Name"
  ##   assert_equal output[1], "Assignment Name"
  ##end
  #
  ##def test_copy
  ##  @assignment_team = @course_team.copy(0)
  ##  assert_kind_of AssignmentTeam, @assignment_team
  ##  assert_equal @assignment_team.users.count, @course_team.users.count
  ##end
  #
  ### test method get_path
  ##def test_add_participant
  ##  assert_equal RAILS_ROOT + '/pg_data/instructor3/csc110/',@course0.get_path
  ##end
end
