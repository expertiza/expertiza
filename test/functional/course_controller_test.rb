# Tests for Course controller
# Author: ajbudlon
# Date: 7/18/2008

require 'test_helper'
require 'course_controller'

# Re-raise errors caught by the controller.
class CourseController; def rescue_action(e) raise e end; end

class CourseControllerTest < Test::Unit::TestCase
  fixtures :users
  fixtures :courses
  
  def setup
    @controller = CourseController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new   
    @request.session[:user] = users(:superadmin)
    AuthController.set_current_role(users(:superadmin).role_id,@request.session)
  end
  
  # Verify successful response and acceptance of private flag
  def test_new
    post :new, :private => 1
    assert_response :success    
  end
  
  # Verify successful response
  def test_edit
    post :edit, :id => courses(:first).id
    assert_response :success
  end  
  
  # Verify successful creation of course
  # redirect to user's home
  # no errors
  def test_create
    post :create, :course => {:name => 'Built Course', :info => 'Blah', :directory_path => 'abc321'}
    assert !Course.find_by_name('Built Course').nil?    
#    What we really want to test is to see if we got where get_home_controller says we should've gotten, but we are cheating for now
#    assert_redirected_to :controller => AuthHelper::get_home_controller(session[:user]), :action => AuthHelper::get_home_action(session[:user])    
    assert_redirected_to :controller => 'tree_display', :action => 'list'
    assert flash.empty?
  end
 
  # Verify unsuccessful creation of course
  # redirect to new action 
  # has errors  
  def test_create_fail
    post :create, :course => {:info => 'Blah', :directory_path => 'abc321'}
    assert_equal 2, Course.find(:all).length
    assert_redirected_to :action => 'new'
    assert !flash.empty?
  end  

  # Verify successful update of course
  # redirect to user's home 
  def test_update
    post :create, :course => {:name => 'Built Course', :info => 'Blah', :directory_path => 'abc321'}
    assert_equal 'Blah', Course.find_by_name('Built Course').info
    post :update, :id => Course.find_by_name('Built Course').id, :course => {:info => 'Blah Blah'}    
    assert_equal 'Blah Blah', Course.find_by_name('Built Course').info
#    What we really want to test is to see if we got where get_home_controller says we should've gotten, but we are cheating for now
#    assert_redirected_to :controller => AuthHelper::get_home_controller(session[:user]), :action => AuthHelper::get_home_action(session[:user])      
    assert_redirected_to :controller => 'tree_display', :action => 'list'
  end

  # Verify successful copy (new object id) of course
  # redirect to user's home 
  def test_copy
    post :copy, :id => courses(:first).id
    assert_equal 3, Course.find(:all).length
    new_course = Course.find(:all).last
    assert_not_equal courses(:first).id, new_course.id
    assert_redirected_to :action => 'edit'
  end
 
  # Verify successful delete of course
  # redirect to user's home
  # no errors   
  def test_delete
    post :create, :course => {:name => 'Built Course', :info => 'Blah', :directory_path => 'abc321'}
    course = Course.find_by_name('Built Course')
    assert_equal 3, Course.find(:all).length
    post :delete, :id => course.id
    assert_equal 2, Course.find(:all).length
    assert Course.find_by_name('Built Course').nil?
#    What we really want to test is to see if we got where get_home_controller says we should've gotten, but we are cheating for now
#    assert_redirected_to :controller => AuthHelper::get_home_controller(session[:user]), :action => AuthHelper::get_home_action(session[:user])      
    assert_redirected_to :controller => 'tree_display', :action => 'list'
  end
 
  # Verify successful change from public to private
  # redirect to user's home   
  def test_toggle_access
    name = courses(:first).name
    assert Course.find_by_name(name).private
    post :toggle_access, :id => courses(:first).id
    assert !Course.find_by_name(name).private
#    What we really want to test is to see if we got where get_home_controller says we should've gotten, but we are cheating for now
#    assert_redirected_to :controller => AuthHelper::get_home_controller(session[:user]), :action => AuthHelper::get_home_action(session[:user])      
    assert_redirected_to :controller => 'tree_display', :action => 'list'
  end
end