class InstructorController < ApplicationController

  # check to see if the current action is allowed
  def action_allowed?
    # only an instructor is allowed to perform all the actions in
    # this controller
    return true if session[:user].role.instructor?
  end

  # sets student_view in session object
  def set_student_view
    session[:student_view] = true
    redirect_back
  end

  # destroys student_view in session object
  def revert_to_instructor_view
    session.delete(:student_view)
    redirect_back
  end

end