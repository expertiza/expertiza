require File.dirname(__FILE__) + '/../test_helper'

class StudentTaskTest < ActiveSupport::TestCase
  fixtures :course,:teams,:users


  def setup
    @course = courses(:course1)
    @users = users(:user999)
    @course_team = teams(:team2)
  
  end


  def test_teamed_students
    StudentTask.teamed_students(@user999)
    assert.equal '0',@students_teamed.length
  end

end
