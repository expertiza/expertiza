require File.dirname(__FILE__) + '/../test_helper'
require 'users_controller'

# Re-raise errors caught by the controller.
class UsersController; def rescue_action(e) raise e end; end

class UsersControllerTest < Test::Unit::TestCase
  fixtures :users
  fixtures :goldberg_system_settings
  
  def setup
    @controller = UsersController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    
    @testUser = users(:test1).id
  end
  
  # 201 edit a user’s profile
  def test_update
    @user = User.find(@testUser)
    post :update, :id => @testUser, :user => { :clear_password => "",
      :name => "test2",
      :fullname => "new test 2",
      :email => "test@test.test"}
    updatedUser = User.find(@testUser)
    assert_equal updatedUser.name, "test2"
    assert_nil User.find(:first, :conditions => "name='#{@user.name}'")
    assert_response :redirect
    assert_equal 'User was successfully updated.', flash[:notice]
    assert_redirected_to :action => 'show', :id => @testUser
  end
  
  # 202 edit a user name to an invalid name (e.g. blank)
  def test_update_with_invalid_name
    @user = User.find(@testUser)
    # It will raise an error while execute render method in controller
    # Because the goldberg variables didn't been initialized  in the test framework
    assert_raise (ActionView::TemplateError){
    post :update, :id => @testUser, :user => { :clear_password => "",
      :name => "" }
     }
    assert !assigns(:user).valid?                                    
    assert_template 'users/edit'
  end
  
  def test_update_with_incorrect_password
    @user = User.find(@testUser)
    # It will raise an error while execute render method in controller
    # Because the goldberg variables didn't been initialized  in the test framework
    assert_raise (ActionView::TemplateError){
    post :update, :id => @testUser, :user => { :clear_password => "test",
      :comfirm_password => "nottest"}
    }
    assert assigns(:user).valid?                                    
    assert_equal 'Password invalid!', flash[:error]
    assert_template 'users/edit'
  end
  # 302 Remove a user whose role is lower than actor’s.
  def test_destroy
    assert_nothing_raised {
      User.find(@testUser)
    }
    
    post :destroy, :id => @testUser
    assert_response :redirect
    assert_redirected_to :action => 'list'
    assert_raise(ActiveRecord::RecordNotFound) {      
      User.find(@testUser)
    }
  end
  # 303 Remove a user whose role is higher than or is the same with actor’s role.
  # handle by goldberg, only super administrator can add/edit/delete users
end
