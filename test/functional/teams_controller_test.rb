require 'test_helper'
require 'teams_controller'

class TeamsControllerTest < ActionController::TestCase

              fixtures :users, :roles, :teams, :assignments, :nodes, :system_settings, :content_pages, :permissions, :roles_permissions, :controller_actions, :site_controllers, :menu_items
  set_fixture_class :system_settings => 'SystemSettings'
  set_fixture_class :roles_permissions => 'RolesPermission'

  def setup
    @controller = TeamsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.session[:user] = User.find(users(:superadmin).id )
    roleid = User.find(users(:superadmin).id).role_id
    Role.rebuild_cache
    Role.find(roleid).cache[:credentials]
    @request.session[:credentials] = Role.find(roleid).cache[:credentials]
    @settings = SystemSettings.find(:first)
    AuthController.set_current_role(roleid,@request.session)
    #@request.session[:user] = User.find_by_name("suadmin")
    @testUser = users(:ta1).id
    @testAssignment = assignments(:assignment_project1).id
    @testCourse = courses(:course1).id
    @testTeams = teams(:project1_team1).id
  end

  #no use !!! this method is from teams_controller
  #test "create_teams_view should assign parent" do

    #user = User.find_by_name('student1')
    #session[:user] = user
    #Role.rebuild_cache
    #AuthController.set_current_role(user.role.id, session)
    #sessionVars = session
    #sessionVars[:team_type] = "Assignment"# class
    #sessionVars.save

    #get :create_teams_view, {'id' => nodes(:node23).node_object_id}, sessionVars
    #assert_response :success
    #assert_not_nil assigns(:parent)
  #end

    test "create_teams assignment should be valid" do
	sessionVars = session_for(users(:superadmin))
    	sessionVars[:team_type] = "Assignment"
    
    	post(:create_teams, {'team' => 'my_team', 'size' => '2','id'=> @testAssignment}, sessionVars,nil)
	assert_response :redirect
    end

    test "create_teams course should be valid" do
	sessionVars = session_for(users(:superadmin))
    	sessionVars[:team_type] = "Course"
    
    	post(:create_teams, {'team' => 'my_team', 'size' => '2','id'=> @testCourse}, sessionVars,nil)
	assert_response :redirect
    end

    test "delete_all should delete all team" do
	sessionVars = session_for(users(:instructor1))
	sessionVars[:team_type] = "Assignment"
	#nodeId = nodes(:node23).node_object_id

	get :delete_all,{'id' => @testAssignment},sessionVars
	assert_equal(8,Team.count)
    end

    test "delete_all should redirect to list" do
	sessionVars = session_for(users(:instructor1))
	sessionVars[:team_type] = "Assignment"
	
	post :delete_all, {'id' => @testAssignment},sessionVars,nil
	assert_response :redirect
    end

    test "list_should_receive_assignment" do
	get :list, {'id' => nodes(:node11).node_object_id, 'type' => "Assignment"},session_for(users(:instructor1))
	assert_response :success
	assert_not_nil assigns(:root_node)
	assert_not_nil assigns(:child_nodes)
    end

    test "list_should_receive_course" do
	get :list, {'id' => nodes(:node23).node_object_id, 'type' => "Course"},session_for(users(:instructor1))
	assert_response :success
	assert_not_nil assigns(:root_node)
	assert_not_nil assigns(:child_nodes)
    end

    test "new_should_assign_parent_assignment" do
	sessionVars = session_for(users(:instructor1))
	sessionVars[:team_type] = "Assignment"

	get :new,{'id' => nodes(:node11).node_object_id},sessionVars
	#assert_response :success
	assert_not_nil assigns(:parent)
    end

    test "new_should_assign_parent_course" do
	sessionVars = session_for(users(:instructor1))
	sessionVars[:team_type] = "Course"

	get :new,{'id' => nodes(:node23).node_object_id},sessionVars
	#assert_response :success
	assert_not_nil assigns(:parent)
    end

    test "create_should_increase_number_of_teams_assignment" do
	sessionVars = session_for(users(:instructor1))
	sessionVars[:team_type] = "Assignment"

	assert_difference 'Team.count' do
	  get :create, {'id' => @testAssignment,'team' => {'name' => "Random"}},sessionVars
	end
    end

    test "create should increase number of team nodes assignment" do
	sessionVars = session_for(users(:instructor1))
	sessionVars[:team_type] = "Assignment"

	assert_difference 'TeamNode.count' do
	  post :create, {'id' => nodes(:node11).node_object_id,'team'=>{'name'=>"Random"}},sessionVars
	end
    end

    test "create_should_increase_number_of_teams_course" do
	sessionVars = session_for(users(:instructor1))
	sessionVars[:team_type] = "Course"

	assert_difference 'Team.count' do
	  get :create, {'id' => @testCourse,'team' => {'name' => "Random"}},sessionVars
	end
    end

    test "create should increase number of team nodes course" do
	sessionVars = session_for(users(:instructor1))
	sessionVars[:team_type] = "Course"

	assert_difference 'TeamNode.count' do
	  post :create, {'id' => nodes(:node23).node_object_id,'team'=>{'name'=>"Random"}},sessionVars
	end
    end



    test "create exist team error assignment" do
	sessionVars = session_for(users(:instructor1))
	sessionVars[:team_type] = "Assignment"

	post :create, {'id' => nodes(:node11).node_object_id,'team'=>{'name'=>"ExistTeam1"}},sessionVars
	assert_not_equal $!,flash[:error]
	assert_response :redirect
    end

    test "create should redirect to list assignment" do
	sessionVars = session_for(users(:instructor1))
	sessionVars[:team_type] = "Assignment"
	nodeId = nodes(:node11).node_object_id

	post :create, {'id'=>nodeId, 'team'=>{'name'=>"Random"}},sessionVars
	assert_response :redirect

    end

    test "create exist team error course" do
	sessionVars = session_for(users(:instructor3))
	sessionVars[:team_type] = "Course"

	post :create, {'id' => nodes(:node23).node_object_id,'team'=>{'name'=>"ExistTeam2"}},sessionVars
	assert_not_equal $!,flash[:error]
	assert_response :redirect
    end

    test "create should redirect to list course" do
	sessionVars = session_for(users(:instructor3))
	sessionVars[:team_type] = "Course"
	nodeId = nodes(:node23).node_object_id

	post :create, {'id'=>nodeId, 'team'=>{'name'=>"Random"}},sessionVars
	assert_response :redirect

    end

end
