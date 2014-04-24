require 'test_helper'
require 'teams_users_controller'

class TeamsUsersControllerTest < ActionController::TestCase

              fixtures :users, :roles, :teams, :assignments, :nodes, :system_settings, :content_pages, :permissions, :roles_permissions, :controller_actions, :site_controllers, :menu_items, :teams_users, :participants, :menu_items
  set_fixture_class :system_settings => 'SystemSettings'
  set_fixture_class :roles_permissions => 'RolesPermission'

  def setup
    @controller = TeamsUsersController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.session[:user] = User.find(users(:superadmin).id )
    roleid = User.find(users(:superadmin).id).role_id
    Role.rebuild_cache
    Role.find(roleid).cache[:credentials]
    @request.session[:credentials] = Role.find(roleid).cache[:credentials]
    @settings = SystemSettings.find(:first)
    AuthController.set_current_role(roleid,@request.session)
    @testUser = User.find(users(:student1).id)
    @testUser1 = User.find(users(:student11).id)
    @testItem = Assignment.find(assignments(:lottery_assignment).id)
    @testAssignment = assignments(:lottery_assignment).id
    @testCourse = courses(:course_object_oriented).id
    @testTeam1 = teams(:lottery_team1).id
    @testTeam2 = teams(:lottery_team2).id
    @testTeam3 = teams(:assignment_team1).id
    @testTeam4 = teams(:assignment7_team1).id
    @testTeamUser = teams_users(:lottery_teams_users1).id
    @testTeamUser1 = teams_users(:lottery_teams_users2).id
    @testTeamUser2 = teams_users(:lottery_teams_users3).id
  end

    test "auto_complete_for_user_name_should_compleite_for_valid_user" do
        sessionVars = session_for(users(:instructor1))
        sessionVars[:team_type] = "Assignment"
        sessionVars[:team_id] = @testTeam1
        get :auto_complete_for_user_name,{'user' => @testUser, 'name' => "student1"},sessionVars
        assert_response :success
    end


    test "list_should_work_for_valid_team" do
	sessionVars = session_for(users(:instructor1))
        sessionVars[:team_type] = "Assignment"
        get :list, {'id' => @testTeam1}, sessionVars
        assert_response :success 
    end

    test "new_should_find_valid_team" do
        post :new, {'id' => @testTeam1}, session_for(users(:instructor1))
        assert_not_nil assigns(:team)
    end

    test "new_should_not_find_invalid_team" do
        post :new, {'id' => @testTeam3}, session_for(users(:instructor1))
        assert_not_nil assigns(:team)
    end

    test "create_should_not_add_invalid_user_to_team" do
        get :create, {'user' => @testUser1, 'name' => "student11", 'id' => @testTeam1}, session_for(users(:instructor1))
        assert_not_equal $!,flash[:error]
    end

    test "create_should_add_user_to_team" do
        get :create, {'user' => @testUser1, 'name' => "student11", 'id' => @testTeam1}, session_for(users(:instructor1))
        assert_response :redirect
    end

    test "delete_should_remove_user_from_team" do
        assert_difference 'TeamsUser.count', -1 do
            get :delete, {'id' => @testTeamUser}, session_for(users(:instructor1))
        end
    end

    test "delete_should_redirect" do
        get :delete, {'id' => @testTeamUser}, session_for(users(:instructor1))
        assert_response :redirect
    end

    #test "delete_select_should_remove_all_users_in_selected_item" do
        #assert_difference 'TeamsUser.count', -3 do
            #get :delete_selected, {'id' => @testTeam1, 'item' => @testItem}, session_for(users(:instructor1))
        #end
    #end

    #test "delete_select_should_redirect" do
        #get :delete_selected, {'id' => @testTeamUser2, 'item' => [Team.find(@testTeam1),Team.find(@testTeam2)]}, session_for(users(:instructor1))
        #assert_response :redirect
    #end

end
