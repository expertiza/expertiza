require File.dirname(__FILE__) + '/../test_helper'

class CourseTest < ActiveSupport::TestCase
  fixtures :courses

  def setup
    @course = courses(:course1)
  end
  
  def test_retrieval
    assert_kind_of Course, @course
    assert_equal "CSC111", @course.name
    assert_equal courses(:course1).id, @course.id 
    assert_equal courses(:course1).instructor_id, @course.instructor_id
    assert_equal 'csc111', @course.directory_path
    assert_equal 'CSC111 Programming Class', @course.info
    assert @course.private
  end
 
  def test_update
    assert_equal "CSC111", @course.name
    @course.name = "Object-Oriented"
    @course.save
    @course.reload
    assert_equal "Object-Oriented", @course.name
  end
  
  def test_destroy
    @course.destroy
    assert_raise(ActiveRecord::RecordNotFound){ Course.find(@course.id) }
  end
  
end
