class RoleSwitchController < ApplicationController
  # check to see if the current action is allowed
  def action_allowed?
    ['Super-Administrator',
     'Administrator',
     'Instructor',
     'Teaching Assistant'].include? current_role_name
  end

  # sets student_view in session object and
  # Updates the menu in session
  def set_student_role
    session[:student_view] = true
    role = Role.student
    session[:menu] = role.cache[:menu]
    redirect_to controller: 'student_task', action: 'list'
  end

  # destroys student_view in session object and redirects to
  # tree_display/list after updating the menu
  def revert_to_instructor_role
    session.delete(:student_view)
    role = Role.instructor
    session[:menu] = role.cache[:menu]
    redirect_to controller: 'tree_display', action: 'list'
  end
end
