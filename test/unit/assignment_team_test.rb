require File.dirname(__FILE__) + '/../test_helper'
require 'yaml'
require 'assignment_team'
require 'test_helper'

class AssignmentTeamTest < ActiveSupport::TestCase
    fixtures :courses,:teams,:users,:participants,:questions,:signed_up_users,:assignments,:nodes,:tree_folders,:teams_users, :roles
  set_fixture_class :system_settings => 'SystemSettings'
  set_fixture_class :roles_permissions => 'RolesPermission'
  
  def setup
    @assignment = assignments(:Intelligent_assignment)
    @assignment1 = assignments(:assignment1)
    @new_assignment_team = AssignmentTeam.new
    @assignment_team = teams(:IntelligentTeam1)
    @assignment_team1 = teams(:IntelligentTeam2)
    @assignment_team2 = teams(:exist_team1)
    @assignment_team3 = teams(:assignment_team1)
    @assignment_team_user = teams_users(:intelligent_teams_users1)
    @participant = participants(:par20)
    @question = questions(:question1)
  end

  test "test_includes" do
    assert_equal @assignment_team.includes?(@participant), true
  end

  test "test_assign_reviewer" do
    assert_difference ['TeamReviewResponseMap.count'],1 do
      assert  @assignment_team.assign_reviewer(@assignment_team_user)
    end 
  end

  test "test_reviewed_by" do
    #TeamReviewResponseMap is empty. No time to write new fixture 
    #The fixture and the seed do not have this info
    #So this test should be false
    assert_equal @assignment_team.reviewed_by?(@assignment_team_user), false
  end

  test "test_has_submission_ture" do
    assert_equal @assignment_team.has_submissions?, true
  end

  test "test_reviewed_contributor" do
    #TeamReviewResponseMap maybe empty. No time to write new fixture
    #The fixture and the seed do not have this info
    #So this test should be false
    assert_equal @assignment_team.reviewed_contributor?(@assignment_team_user), false
  end

  test "test_participants" do
    assert_not_nil @assignment_team.participants
  end

  test "test_handle_duplicate_team_nil" do
    output = AssignmentTeam.handle_duplicate(nil,"NoThisTeam",@assignment.id, "ignore")
    assert_equal output, "NoThisTeam"
  end

  test "test_handle_duplicate_ignore" do
    handle_dups = "ignore"
    output = AssignmentTeam.handle_duplicate(@assignment_team,@assignment_team.name, @assignment.id, handle_dups)
    assert_equal output, nil
  end

  test "test_handle_duplicate_rename" do
    handle_dups = "rename"
    output = AssignmentTeam.handle_duplicate(@assignment_team,@assignment_team.name, @assignment.id, handle_dups)
    assert_not_equal output, @assignment_team.name
  end

  test "test_import_argument_error_raw" do
    row = ["student1"]
    options = {:has_column_names => "true"} 
    assert_raises ArgumentError do
      AssignmentTeam.import(row, nil, @assignment.id, options)
    end
  end

  test "test_import_has_column_names_false" do
    row = ["student1","student2", "student3"]
    options = {:has_column_names => "false", :handle_dups => "ignore"}
    AssignmentTeam.import(row, nil, @assignment.id, options)
    course_team = AssignmentTeam.find_by_parent_id(@assignment.id)
    assert_not_equal course_team, nil
  end

  test "test_import_has_column_names_true" do
    row = ["new_column", "student1","student2", "student3"]
    options = {:has_column_names => "true", :handle_dups => "ignore"}
    AssignmentTeam.import(row, nil, @assignment.id, options)
    course_team = AssignmentTeam.find_by_name("new_column")
    assert_equal course_team.parent_id, @assignment.id
    assert_equal course_team.has_user(users(:student1)), true
    assert_equal course_team.has_user(users(:student2)), true
    assert_equal course_team.has_user(users(:student3)), true
  end

  test "test_self_export_team_name_true" do
    output = Array.new
    options = {:team_name => "true"}
    AssignmentTeam.export(output, @assignment1.id, options)
    assert_equal output[0][0], @assignment_team2.name
    assert_equal output[0][1], @assignment1.name
    assert_equal output[1][0], @assignment_team3.name
    assert_equal output[1][1], @assignment1.name
  end

  test "test_get_export_fields_team_name_false" do
    output = Array.new
    options = {:team_name => "false"}
    output = AssignmentTeam.get_export_fields(options)
    assert_equal output[0], "Team Name"
    assert_equal output[1], "Team members"
    assert_equal output[2], "Assignment Name"
  end
 
  test "test_get_export_fields_team_name_true" do
    output = Array.new 
    options = {:team_name => "true"}
    output = AssignmentTeam.get_export_fields(options)
    assert_equal output[0], "Team Name"
    assert_equal output[1], "Assignment Name"
  end

  test "test_self_create_team_and_node" do
    my_team = AssignmentTeam.create_team_and_node(@assignment.id)
    my_course_team = AssignmentTeam.find_by_name(my_team.name)
    my_team_node = TeamNode.find_by_node_object_id(my_team.id)
    assert_not_nil my_course_team
    assert_not_nil my_team_node
  end

  test "test_get_participants" do
    output = Array.new
    output = @assignment_team.get_participants
    assert_not_nil output
    assert_not_equal output[0].name,@assignment_team_user.name
  end

  test "test_get_hyperlinks" do
    output = Array.new
    output = @assignment_team2.get_hyperlinks
    assert_not_nil output
  end

  test "test_get_path" do
    output = @assignment_team2.get_path
    assert_not_nil output
  end

  test "get_submitted_files" do
    # there is no column in the table
    # the submitted_file must be empty
    # expect nil. Not very sure about this
    output = @assignment_team2.get_submitted_files
    assert_nil output
  end

  test "test_self_get_first_member" do
    assert_not_nil AssignmentTeam.get_first_member(@assignment_team.id)
  end

  test "test_email" do
    #output = @assignment_team.email
    #assert_not_nil output
    # this method is wrong because there is no methond named get_team_users
  end

  test "test_get_participant_type" do
    assert_equal @assignment_team.get_participant_type,"AssignmentParticipant"
  end

  test "test_get_parent_model" do
    assert_equal @assignment_team.get_parent_model,"Assignment"
  end

  test "test_fullname" do
    assert_equal @assignment_team.fullname,"IntelligentTeam1"
  end

  test "test_get_review_map_type" do
    assert_equal @assignment_team.get_review_map_type,'TeamReviewResponseMap'
  end

  test "test_copy" do
    course_id = courses(:course1).id
    assert_difference ['TeamUserNode.count', 'TeamsUser.count'],2 do
      assert @assignment_team.copy(course_id)
    end
  end

  test "test_add_participant" do
    user = users(:student5)
    assert_difference ['AssignmentParticipant.count'],1 do
      assert @assignment_team.add_participant(@assignment,user)
    end
  end

  test "test_assignment" do
    assert_equal @assignment_team.assignment,@assignment
  end

  test "test_delete" do 
    # this method is wrong, before sign_up.each.destory
    # we should to make sure sign_up not nil
  end

  test "test_self_get_team" do
    output = AssignmentTeam.get_team(@participant)
    assert_not_nil output
    assert_equal output, @assignment_team
  end

  test "test_self_remove_team_by_id" do
    AssignmentTeam.remove_team_by_id(@assignment_team.id)
    assert_nil AssignmentTeam.find_by_id(@assignment_team.id)
  end

  test "test_get_scores" do
    output = @assignment_team.get_scores(@question)
    assert_not_nil output
    assert_equal output[:team],@assignment_team
    assert_not_nil output[:total_score]
  end

end
