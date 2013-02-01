
class Student < User
  def get_home_action
    "list"
  end
  
  def get_home_controller
    return "student_task"
  end
end