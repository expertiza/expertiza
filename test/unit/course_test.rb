require File.dirname(__FILE__) + '/../test_helper'

class CourseTest < Test::Unit::TestCase
  fixtures :courses

  def setup
    @course = Course.find(1)
  end
  
  def test_create
    assert_kind_of Course, @course
    assert_equal 1, @course.id
    assert_equal "Object-Oriented Programming", @course.title
  end
  
  def test_update
    assert_equal "Object-Oriented Programming", @course.title
    @course.title = "Object-Oriented"
    @course.save
    @course.reload
    assert_equal "Object-Oriented", @course.title
  end
  
  def test_destroy
    @course.destroy
    assert_raise(ActiveRecord::RecordNotFound){ Course.find(@course.id) }
  end
  
end
