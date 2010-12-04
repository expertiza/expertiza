require './' + File.dirname(__FILE__) + '/../test_helper'
require 'course_controller'
require 'auth_controller'

# Re-raise errors caught by the controller.
class CourseController; def rescue_action(e) raise e end; end

class CoursesControllerTest < Test::Unit::TestCase
  fixtures :courses
  fixtures :users
  
  def setup
#    user =User.find(:all, :conditions=>"id=1")
#    session[:user]=user
    @controller = CourseController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.session[:user] = true
#    post :login, :login => { :name => 'admin', :password=>'admin' }
#    assert_equal 1, session[:user].id
  end

  # 601 Add a new course
  def test_add_course_with_valid_title
    number_of_course = Course.count
    user = User.find(:all, :conditions => "id=1")
    post :create_course, :course => { :title => 'Database'}
    assert_equal flash[:notice], 'Course was successfully created.'
    assert_redirected_to :action => 'list_folders'
    assert_equal Course.count, number_of_course+1
    assert Course.find(:all, :conditions => "title = 'Database'")
  end
  
  # 602 Add a new course with invalid title (title='')
  def test_add_course_with_invalid_title
    number_of_course = Course.count
    post :create_course, :course => { :title => ''}
   # assert_template 'course/new'
    assert_equal number_of_course, Course.count
    assert !Course.find(:all, :conditions => "title = ''"), 
    "The blank title course save into database"
  end
  
  # 603 Add a new course with a title that already exists.
  def test_add_course_with_duplicate_title
    number_of_course = Course.count
    assert Course.find(:all, :conditions => "title = 'E-Commerce'")
    post :create_course, :course => { :title => 'E-Commerce'}
    #assert_template 'course/new'
    #assert_equal Course.count, number_of_course
    assert_equal 1, Course.count(:all, :conditions => "title = 'E-Commerce'"), 
                                "Find more than one record in database have the same title"
  end
  
  # 604 Edit the title of a course
  def test_edit_course_with_valid_title
    number_of_course = Course.count
    title = Course.find(1).title
    post :update_course,:id => 1, :course => { :title => 'Database'}
    assert_equal flash[:notice], 'Course was successfully updated.'
    assert_redirected_to :action => 'list_folders', :id =>1
    assert_equal Course.count, number_of_course
    assert Course.find(:all, :conditions => "title = 'Database'");
    assert_nil Course.find(:first, :conditions => "title = '#{title}'");
  end

  # 605 Change the title of a course to an invalid course title (title='')
  def test_edit_course_with_invalid_title
    number_of_course = Course.count
    post :update_course,:id => 1, :course => { :title => ''}
    assert_equal Course.count, number_of_course
    assert Course.find(:all, :conditions => "title = 'E-Commerce'")
    assert !Course.find(:all, :conditions => "title = ''"),
        "The blank title course save into database" 
  end
  
  # 606 Change the title of a course to an existing course title
  def test_edit_course_with_duplicate_title
    number_of_course = Course.count
    post :update_course,:id => 2, :course => { :title => 'Object-Oriented Programming'}
    assert_equal Course.count, number_of_course
    assert_equal 1, Course.count(:all, :conditions => "title = 'Object-Oriented Programming'"),
      "The duplicate title course save into database" 
    #assert !Course.find(:all, :conditions => "title = 'E-Commerce'");
  end
  

  
  # 701 Delete a course
  def test_delete_course
    number_of_course = Course.count
    post :destroy_course,:id => 1
    assert_redirected_to :action => 'list_folders'
    assert_equal number_of_course-1, Course.count
    assert_raise(ActiveRecord::RecordNotFound){ Course.find(1) }
  end
  
end