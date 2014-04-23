require File.dirname(__FILE__) + '/../test_helper'

class TeamTest < ActiveSupport::TestCase
  fixtures :users, :roles, :teams, :assignments, :nodes, :courses, :teams_users,
           :system_settings, :content_pages, :permissions, :roles_permissions,
           :controller_actions, :site_controllers, :menu_items,
           :participants
  set_fixture_class :system_settings => 'SystemSettings'
  set_fixture_class :roles_permissions => 'RolesPermission'
  
  test "add_team" do
    team = Team.new
    assert team.save
  end

  test "delete should destroy the team" do
    team = teams(:IntelligentTeam1)
    assert team.delete
    assert team.destroyed?
  end

  test "delete should remove all teams user" do
    team = teams(:IntelligentTeam1)
    team.delete
    for teamsuser in TeamsUser.find(:all, :conditions => ["team_id =?", teams(:IntelligentTeam1).id])
      assert_nil teamsuser
    end
  end

  test "delete should remove all team node" do
    team = teams(:IntelligentTeam1)
    team.delete
    assert_nil Node.find_by_node_object_id(teams(:IntelligentTeam1).id)
  end

  # need to test course team
  # this called the one in AssignmentTeam
  test "get_participants from assignment team" do
    participants = teams(:IntelligentTeam1).get_participants
    assert (participants &
            [participants(:par20), participants(:par21),
             participants(:par22), participants(:par23)]).present?
  end

  test "get_participants from course team" do
    participants = teams(:course0_team1).get_participants
    assert_include participants, participants(:par5)
  end

  test "get_node_type" do
    team = Team.new
    assert_equal team.get_node_type, "TeamNode"
  end

  test "get_author_name" do
    team = Team.new
    team.name = "test name"
    assert_equal team.get_author_name, "test name"
  end

  # first one is overloaded...
  test "generate_team_name" do
    assert_equal Team.generate_team_name("Test"), "Test_Team1"
  end

  test "generate_team_name for existed prefix" do
    team = Team.new("name" => "Test_team1")
    team.save
    assert_equal Team.generate_team_name("Test"), "Test_Team2"
  end

  test "get_possible_team_members" do
    team = teams(:IntelligentTeam1)
    assert_equal [users(:student9)], team.get_possible_team_members(participants(:par20).name)
  end

  test "has_user" do
    team = teams(:IntelligentTeam1)
    assert team.has_user(users(:student9))
  end

  test "do not has_user" do
    team = teams(:IntelligentTeam1)
    assert_false team.has_user(users(:student4))
  end

  test "add member already in team" do
    team = teams(:IntelligentTeam1)
    exception = assert_raises(RuntimeError) {
      team.add_member(users(:student9), assignments(:Intelligent_assignment).id)
    }
    assert_equal( '"student9" is already a member of the team, "IntelligentTeam1"', exception.message )
  end

  # id cannot be nil
  # because runtime error
  # Called id for nil, which would mistakenly be 4 -- if you really wanted the id of nil, use object_id
  # Note: add_participant for course team is deprecated
  test "add member for course should create teams user" do
    team = teams(:course_team1)
    assert team.add_member(users(:student9), assignments(:assignment_project3).id)
    teams_user = TeamsUser.where('user_id = ? and team_id = ?', users(:student9).id, teams(:course_team1).id)
    assert_equal teams_user.count, 1
  end

  test "add member for course should create teams user node" do
    team = teams(:course_team1)
    assert team.add_member(users(:student9), assignments(:assignment_project3).id)
    teams_user = TeamsUser.where('user_id = ? and team_id = ?', users(:student9).id, teams(:course_team1).id)
    parent = TeamNode.find_by_node_object_id(team.id)
    team_user_node = TeamUserNode.where('parent_id = ? AND node_object_id = ?', parent.id, teams_user.first.id)
    assert_equal team_user_node.count, 1
  end

  test "add member to assignment team successfully" do
    team = teams(:single_person_team)
    assert_difference ['TeamUserNode.count', 'TeamsUser.count'], 1 do
      assert team.add_member(users(:student8), assignments(:assignment_project3).id)
    end
  end

  test "add member to full assignment team should fail" do
    team = teams(:single_person_team)
    assert team.add_member(users(:student9), assignments(:assignment_project3).id)
    assert_no_difference ['TeamsUser.count', 'TeamUserNode.count'] do
      assert_false team.add_member(users(:student8), assignments(:assignment_project3).id)
    end
  end

  # I guess this is always one-way for assignment -> course?
  # no assignment size check
  test "copy_members from assignmentTeam" do
    new_team = Team.new
    assert_difference ['TeamUserNode.count', 'TeamsUser.count'], 2 do
      assert teams(:IntelligentTeam1).copy_members(new_team)
    end
  end

  # This will only return nil
  test "check_for_existing for AssignmentTeam" do
    Team.check_for_existing(assignments(:assignment_project3), "abc", "Assignment")
  end

  test "check_for_existing for existed AssignmentTeam should raise error" do
    assert_raises TeamExistsError do
       Team.check_for_existing(assignments(:assignment_project3), "SinglePersonTeam", "Assignment")
    end
  end

  # what if teams = nil?
  test "delete all by parent should delete teams" do
    assert_difference 'Team.count', -3 do
      Team.delete_all_by_parent(assignments(:Intelligent_assignment))
    end
  end

  test "delete all by parent will not fail when no teams found" do
    assert_no_difference 'Team.count' do
      Team.delete_all_by_parent(assignments(:assignment_review0))
    end
  end

  # 4 participants, 3 existed teams => 2 teams
  # will raise error because assignment id not passed.
  #test "randomize_all_by_parent" do
  #  assert_difference 'Team.count', 1 do
  #    Team.randomize_all_by_parent(assignments(:Intelligent_assignment), "Assignment", 2)
  #  end
  #end

  test "import team members for user not existed should raise error" do
    row = ["hi", "student1","student2", "student3"]
    team = Team.new
    exception = assert_raises(ImportError) {
      team.import_team_members(0, row)
    }
    assert_equal(
        "The user \"hi\" was not found. <a href='/users/new'>Create</a> this user?",
        exception.message )
  end
=begin
  # problem: add_member are not adding correct assignment id at line 169
  test "import team members successfully" do
    row = ["hi", "student1","student2", "student3"]
    team = Team.new
    assert_difference 'team.teams_users.count', 3 do
      team.import_team_members(1, row)
    end
  end
=end
end

