class RoleSwitchController < ApplicationController
  # check to see if the current action is allowed
  def action_allowed?
    # only an instructor is allowed to perform all the actions in
    # this controller
   # return true if session[:user].role.instructor?
    ['Super-Administrator',
     'Administrator',
     'Instructor',
     'Teaching Assistant'].include? current_role_name
  end

  # sets student_view in session object and redirects to
  # student_task/list after updating hidden_menu_items
  def set_student_role
    session[:student_view] = true
    role = Role.student
    session[:menu] = role.cache[:menu]
    # puts session[:original_role]
    # Role.rebuild_cache
    # MenuItemsHelper.update_hidden_menu_items_for_student_view(session)
    redirect_to controller: 'student_task', action: 'list'
  end

  # destroys student_view in session object and redirects to
  # tree_display/list after updating hidden_menu_items
  def revert_to_instructor_role
    session.delete(:student_view)
    role = Role.instructor
    session[:menu] = role.cache[:menu]
    redirect_to controller: 'tree_display', action: 'list'
  end
end
