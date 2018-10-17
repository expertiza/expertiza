module MenuItemsHelper
  # sets hidden_menu_items for the given user if
  # user is an instructor. This method is needed to set
  # the hidden_menu_items during initial login by instructor.
  def self.set_hidden_menu_items(user, session)
    if user.role.instructor?
      MenuItemsHelper.update_hidden_menu_items_for_instructor_view(session)
    else
      session[:hidden_menu_items] = []
    end
  end

  # updates hidden_menu_items in session object when an instructor is
  # in student view
  def self.update_hidden_menu_items_for_student_view(session)
    # 35 - Survey Deployments, 37 - Manage Instructor Content
    session[:hidden_menu_items] = [35, 37]
  end

  # updates hidden_menu_items in session object when an instructor is
  # in instructor view
  def self.update_hidden_menu_items_for_instructor_view(session)
    # 26 - Assignments, 30 - Course Evaluation
    session[:hidden_menu_items] = [26, 30]
  end
end
