class InstructorController < ApplicationController

  # check to see if the current action is allowed
  def action_allowed?
    # only an instructor is allowed to perform all the actions in
    # this controller
    return true if session[:user].role.instructor?
  end

  # sets student_view in session object and redirects to
  # student_task/list
  def set_student_view
    session[:student_view] = true
    MenuItemsHelper.set_student_view_hidden_menu_items(session)
    redirect_to controller: 'student_task', action: 'list'
  end

  # destroys student_view in session object and redirects to
  # tree_display/list
  def revert_to_instructor_view
    session.delete(:student_view)
    MenuItemsHelper.set_instructor_view_hidden_menu_items(session)
    redirect_to controller: 'tree_display', action: 'list'
  end

end