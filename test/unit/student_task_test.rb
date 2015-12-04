require File.dirname(__FILE__) + '/../test_helper'

require 'student_task'

class StudentTaskTest < ActiveSupport::TestCase
  fixtures :courses,:teams,:users, :participants, :assignments

  test "method_teamed_students" do
    @user = users(:user5403)
    @students_teamed= StudentTask.teamed_students(@user)
    assert_equal 0,@students_teamed.length
  end

end
