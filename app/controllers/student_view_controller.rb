class StudentViewController < ApplicationController
  include AuthorizationHelper

  def action_allowed?
    current_user_has_instructor_privileges?
  end

  def flip_view
    # flips the value of session[:flip_user], allowing an instructor
    # to see the student view, or allows them to switch back, due to
    # check on session[:flip_user] in _navigation.html.erb.

    # if flag is false or uninitialized, set it to true
    if session[:flip_user].nil? || !session[:flip_user]
      session[:flip_user] = true
      redirect_to '/'

      # if flag is true, set to false.
    elsif session[:flip_user]
      session[:flip_user] = false
      redirect_to '/'
    end
  end
end
