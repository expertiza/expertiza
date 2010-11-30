require File.dirname(__FILE__) + '/../test_helper'
require 'users_controller'

# Re-raise errors caught by the controller.
class UsersController; def rescue_action(e) raise e end; end

class UsersControllerTest < Test::Unit::TestCase
  fixtures :users
  fixtures :goldberg_system_settings
  fixtures :roles
# --------------------------------------------------------------
  set_fixture_class:system_settings => 'SystemSettings'    
  fixtures :system_settings
  fixtures :content_pages  
  @settings = SystemSettings.find(:first)
  
  def setup
    @controller = UsersController.new  
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @request.session[:user] = User.find(users(:superadmin).id ) 
    roleid = User.find(users(:superadmin).id).role_id 
    Role.rebuild_cache

    Role.find(roleid).cache[:credentials] 
    @request.session[:credentials] = Role.find(roleid).cache[:credentials]
    # Work around a bug that causes session[:credentials] to become a YAML Object
    @request.session[:credentials] = nil if @request.session[:credentials].is_a? YAML::Object
    @settings = SystemSettings.find(:first)    
    AuthController.set_current_role(roleid,@request.session) 
    
    @testUser = users(:student1).id    
  end
  
  # 201 edit a user’s profile
  def test_update
    post :update, :id => @testUser, :user => { :clear_password => "",
      :name => "student1",
      :fullname => "new Student1test",
      :email => "student1test@test.test"}
    updatedUser = User.find_by_name("student1")
    assert_equal updatedUser.email, "student1test@test.test"
#   assert_nil User.find(:first, :conditions => "name='#{@user.name}'")
    assert_response :redirect
    assert_equal 'User was successfully updated.', flash[:notice]
    assert_redirected_to :action => 'show', :id => @testUser
  end
  
  # 202 edit a user name to an invalid name (e.g. blank)
  def test_update_with_invalid_name
    @user = User.find(@testUser)
    # It will raise an error while execute render method in controller
    # Because the goldberg variables didn't been initialized  in the test framework
#   assert_raise (ActionView::TemplateError){
    post :update, :id => @testUser, :user => { :clear_password => "",
          :name => "" }
#         }
    assert !assigns(:user).valid?                                    
    assert_template 'users/edit'
  end
  
  def test_update_with_incorrect_password
    @user = User.find(@testUser)
    # It will raise an error while execute render method in controller
    # Because the goldberg variables didn't been initialized  in the test framework
#   assert_raise (ActionView::TemplateError){
    post :update, :id => @testUser, :user => { :clear_password => "test",
      :confirm_password => "nottest"}
#   }
    assert assigns(:user).valid?                                    
    assert_equal "The passwords you entered don't match", flash[:error]
    assert_template 'users/edit'
  end
  # 302 Remove a user whose role is lower than actor’s.
  # This should work and is legal to do - CSC517 rsjohns3 11/20/2010
  def test_destroy
    assert_nothing_raised {
      User.find(@testUser)
    }
  post :destroy, :id => @testUser
    assert_response :redirect
    assert_redirected_to :action => 'list'
#   assert_raise (ActiveRecord::RecordNotFound) {      
#    User.find(@testUser)
#  }
  end
  # 303 Remove a user whose role is higher than or is the same with actor’s role.
  # handle by goldberg, only super administrator can add/edit/delete users
end
