require File.dirname(__FILE__) + '/../test_helper'
require 'test_helper'
require 'course_team'

class CourseTeamTest < ActiveSupport::TestCase
  fixtures :courses,:teams,:users,:participants,:assignments,:nodes,:tree_folders,:teams_users, :roles
  set_fixture_class :system_settings => 'SystemSettings'
  set_fixture_class :roles_permissions => 'RolesPermission'

  def setup
    @course = courses(:course0)
    @new_course_team = CourseTeam.new
    @course_team = teams(:exist_team2)
    @course_team1 = teams(:course0_team1)
  end

  test "test_get_participant_type" do
    assert_equal @new_course_team.get_participant_type, "CourseParticipant"
  end

  test "test_get_parent_model" do
    assert_equal @new_course_team.get_parent_model, "Course"
  end

  test "test_get_node_type" do
    assert_equal @new_course_team.get_node_type, "TeamNode"
  end

  test "test_assignment_id" do
    assert_equal @new_course_team.assignment_id, nil
  end

  test "test_copy" do
    assignment_id = assignments(:Intelligent_assignment).id
    ## this doesn't make any sense, need to change it if I have time
    assert_difference ['TeamUserNode.count', 'TeamsUser.count'],1 do
      assert @course_team.copy(assignment_id)
    end
  end

  ## from the course_team.rb, this functionality belongs to course,
  ## just write a test case in case, maybe this is not useful
  test "test_add_participant" do
    course_id = courses(:course0).id
    user = users(:student1)
    assert_difference ['CourseParticipant.count'],1 do
      assert  @course_team.add_participant(course_id,user)
    end
  end

  test "test_export_participants" do
    output = @course_team.export_participants
    assert_equal output[0], teams_users(:course_teams_user1).name
    assert_equal output[1], " "
  end

  test "test_instance_export_team_name_only_false" do
    team_name_only = "false"
    output = @course_team.export(team_name_only)
    assert_equal output[0], teams(:exist_team2).name
    assert_equal output[1][0], teams_users(:course_teams_user1).name
    assert_equal output[2], @course.name
  end

  test "test_instance_export_team_name_only_true" do
    team_name_only = "true"
    output = @course_team.export(team_name_only)
    assert_equal output[0], teams(:exist_team2).name
    assert_equal output[1], @course.name
  end

  test "test_handle_duplicate_team_nil" do
    output = CourseTeam.handle_duplicate(nil,"NoThisTeam",@course.id, "ignore")
    assert_equal output, "NoThisTeam"
  end

  test "test_handle_duplicate_ignore" do
    handle_dups = "ignore"
    output = CourseTeam.handle_duplicate(@course_team,@course_team.name, @course.id, handle_dups)
    assert_equal output, nil
  end

  test "test_handle_duplicate_rename" do
    handle_dups = "rename"
    output = CourseTeam.handle_duplicate(@course_team,@course_team.name, @course.id, handle_dups)
    assert_not_equal output, @course_team.name
  end

  test "test_import_argument_error_raw" do
    row = ["student1"]
    options = {:has_column_names => "true"} 
    assert_raises ArgumentError do
      CourseTeam.import(row, nil, @course.id, options)
    end
  end

  test "test_import_has_column_names_false" do
    row = ["student1","student2", "student3"]
    options = {:has_column_names => "false", :handle_dups => "ignore"}
    CourseTeam.import(row, nil, @course.id, options)
    course_team = CourseTeam.find_by_parent_id(@course.id)
    assert_not_equal course_team, nil
    assert_equal course_team.has_user(users(:student1)), true
  end

  test "test_import_has_column_names_true" do
    row = ["new_column", "student1","student2", "student3"]
    options = {:has_column_names => "true", :handle_dups => "ignore"}
    CourseTeam.import(row, nil, @course.id, options)
    course_team = CourseTeam.find_by_name("new_column")
    assert_equal course_team.parent_id, @course.id
    assert_equal course_team.has_user(users(:student1)), true
    assert_equal course_team.has_user(users(:student2)), true
    assert_equal course_team.has_user(users(:student3)), true
  end

  test "test_self_export_team_name_true" do
    output = Array.new
    options = {:team_name => "true"}
    CourseTeam.export(output, @course.id, options)
    assert_equal output[0][0], @course_team.name
    assert_equal output[0][1], @course.name
    assert_equal output[1][0], @course_team1.name
    assert_equal output[1][1], @course.name
  end

  test "test_self_export_team_name_false" do
    output = Array.new
    options = {:team_name => "false"}
    CourseTeam.export(output, @course.id, options)
    assert_equal output[0][0], @course_team.name
    assert_equal output[0][1][0], teams_users(:course_teams_user1).name
    assert_equal output[0][1][1], " "
    assert_equal output[0][2], @course.name
    assert_equal output[1][0], @course_team1.name
    assert_equal output[1][1][0], teams_users(:course0_users1).name
    assert_equal output[1][2], @course.name
  end

  test "test_get_export_fields_team_name_false" do
    output = Array.new
    options = {:team_name => "false"}
    output = CourseTeam.get_export_fields(options)
    assert_equal output[0], "Team Name"
    assert_equal output[1], "Team members"
    assert_equal output[2], "Course Name"
  end
 
  test "test_get_export_fields_team_name_true" do
    output = Array.new 
    options = {:team_name => "true"}
    output = CourseTeam.get_export_fields(options)
    assert_equal output[0], "Team Name"
    assert_equal output[1], "Course Name"
  end

  test "test_self_export_all_assignment_team_related_to_course" do
    #this method is deprecated from the course_team.rb
    #should delete it ?
    options = {:team_name => "true"}
    output = Array.new
    CourseTeam.export_all_assignment_team_related_to_course(output, @course.id, options)
    assert_not_nil output
  end

  test "test_self_create_team_and_node" do
    my_team = CourseTeam.create_team_and_node(@course.id)
    my_course_team = CourseTeam.find_by_name(my_team.name)
    my_team_node = TeamNode.find_by_node_object_id(my_team.id)
    assert_not_nil my_course_team
    assert_not_nil my_team_node
  end

end
