require File.dirname(__FILE__) + '/../test_helper'

class CourseTest < Test::Unit::TestCase
  fixtures :courses

  def setup
    @course = Course.find(1)
  end
  
  def test_retrieval
    assert_kind_of Course, @course
    assert_equal "My Course", @course.name
    assert_equal 1, @course.id
    assert_equal 1, @course.instructor_id
    assert_equal 'abc123', @course.directory_path
    assert_equal 'This is info', @course.info
    assert @course.private
  end
 
  def test_update
    assert_equal "My Course", @course.name
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
