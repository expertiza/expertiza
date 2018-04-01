module TreeDisplayHelper
  # sets hidden_menu_items in session object when an instructor is
  # in student view
  def set_student_view_hidden_menu_items
    # 35 - Survey Deployments, 37 - Manage Instructor Content
    session[:hidden_menu_items] = [35, 37]
  end

  # sets hidden_menu_items in session object when an instructor is
  # in instructor view
  def set_instructor_view_hidden_menu_items
    # 26 - Assignments, 30 - Course Evaluation
    session[:hidden_menu_items] = [26, 30]
  end
end
