class InstructorController < ApplicationController
  # check to see if the current action is allowed
  def action_allowed?
    # only an instructor is allowed to perform all the actions in
    # this controller
    return true if session[:user].role.instructor?
  end

  # sets student_view in session object and redirects to
  # student_task/list after updating hidden_menu_items
  def set_student_view
    session[:student_view] = true
    MenuItemsHelper.update_hidden_menu_items_for_student_view(session)
    redirect_to controller: 'student_task', action: 'list'
  end

  # destroys student_view in session object and redirects to
  # tree_display/list after updating hidden_menu_items
  def revert_to_instructor_view
    session.delete(:student_view)
    MenuItemsHelper.update_hidden_menu_items_for_instructor_view(session)
    redirect_to controller: 'tree_display', action: 'list'
  end
end
