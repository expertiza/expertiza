class EulaController < ApplicationController
  def action_allowed?
    # E1915 TODO: instead, use helper method(s) from app/helpers/authorization_helper.rb
    ['Super-Administrator',
     'Administrator',
     'Instructor',
     'Teaching Assistant',
     'Student'].include? current_role_name
  end

  def display; end

  def accept
    session[:user].update_attribute('is_new_user', 0)
    redirect_to controller: 'student_task', action: 'list'
  end

  def decline
    flash[:notice] = 'Please accept the license agreement in order to use the system.'
    redirect_to action: 'display'
  end
end
