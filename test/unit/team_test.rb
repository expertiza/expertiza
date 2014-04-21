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

  test "test delete" do
    team = teams(:IntelligentTeam1)
    assert team.delete
    assert team.destroyed?
    for teamsuser in TeamsUser.find(:all, :conditions => ["team_id =?", teams(:IntelligentTeam1).id])
      assert_nil teamsuser
    end
    assert_nil Node.find_by_node_object_id(teams(:IntelligentTeam1).id)
  end

  #need to test course team
  test "get_participants" do
    #team = Team.find_by_id teams(:IntelligentTeam1).id
    participants = teams(:IntelligentTeam1).get_participants
    assert (participants &
            [participants(:par20), participants(:par21),
             participants(:par22), participants(:par23)]).present?
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
  test "add member for course" do
    team = teams(:course_team1)
    assert team.add_member(users(:student9), assignments(:assignment_project3).id)
    teams_user = TeamsUser.where('user_id = ? and team_id = ?', users(:student9).id, teams(:course_team1).id)
    assert_equal teams_user.count, 1
    parent = TeamNode.find_by_node_object_id(team.id)
    team_user_node = TeamUserNode.where('parent_id = ? AND node_object_id = ?', parent.id, teams_user.first.id)
    assert_equal team_user_node.count, 1
  end

  

  # add member for assignment successfully
  # add member to full team should fail
  #assignment_project3 max = 1

  #test "copy_members" do
  #  new_team = Team.new
  #  teams(:IntelligentTeam1).copy_members(new_team)
  #end

end

