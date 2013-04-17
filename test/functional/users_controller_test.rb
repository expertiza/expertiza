require File.dirname(__FILE__) + '/../test_helper'
require 'users_controller'

# Re-raise errors caught by the controller.
class UsersController; def rescue_action(e) raise e end; end

class UsersControllerTest < ActionController::TestCase
  fixtures :users, :participants, :assignments, :wiki_types, :response_maps
  fixtures :roles
# --------------------------------------------------------------
  set_fixture_class :system_settings => 'SystemSettings'    
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
  
  # 201 edit a user�s profile
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
      :clear_password_confirmation => "nottest"}
#   }
    assert !assigns(:user).valid?                                    
    assert_template 'users/edit'
  end
  # test removing a user
  def test_destroy
    
    user = User.find(users(:student9).id)
    
    numUsers = User.count
    post :destroy,:id => user.id, :force => 1
    assert_response :redirect
    assert_redirected_to :action => 'list'
    assert_equal numUsers-1, User.count
  end
  
  def test_keys
    user = User.find(users(:student1).id)
    assert_nil user.digital_certificate
    post :keys, :id => user.id
    assert_template 'users/keys'
    user = User.find(users(:student1).id)
    assert_not_nil user.digital_certificate
  end

  def test_should_get_data_and_index
    get :list, :letter => 's', :page => 2, :num_users => 1

    assert_response :success
    assert assigns(:users)
    assert_select 'div.pagination', true
  end

  def test_should_not_show_pagination_links_if_all_users_are_shown
    get :list, :letter => 's', :num_users => 4

    assert_response :success
    assert assigns(:users)
    assert_select 'div.pagination', false
  end

  def test_search_by_username
    #search for something that is there
    get :list, :letter => 'tud10', :num_users => 4, :search_by => 1
    assert_response :success
    assert assigns(:users)
    assert_not_equal assigns(:users).size, 0

    #search for something that is not there
    get :list, :letter => 'tgdfgdfsdafa0', :num_users => 4, :search_by => 1
    assert_response :success
    assert assigns(:users)
    assert_equal assigns(:users).size, 0
  end

  def test_search_by_fullname
    #search for something that is there
    get :list, :letter => '9_ful', :num_users => 4, :search_by => 2
    assert_response :success
    assert assigns(:users)
    assert_not_equal assigns(:users).size, 0

    #search for something that is not there
    get :list, :letter => 'sdgfbfvrs', :num_users => 4, :search_by => 2
    assert_response :success
    assert assigns(:users)
    assert_equal assigns(:users).size, 0
  end

  def test_search_by_email
    #search for something that is there
    get :list, :letter => '9@mailinator.com', :num_users => 4, :search_by => 3
    assert_response :success
    assert assigns(:users)
    assert_not_equal assigns(:users).size, 0

    #search for something that is not there
    get :list, :letter => 'fsfgdfvxzcff', :num_users => 4, :search_by => 3
    assert_response :success
    assert assigns(:users)
    assert_equal assigns(:users).size, 0
  end
end
