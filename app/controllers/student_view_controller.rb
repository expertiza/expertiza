class StudentViewController < ApplicationController
  include AuthorizationHelper

  def action_allowed?
    current_user_has_instructor_privileges?
  end

	def flip_view
		if(session[:flip_user] == nil || session[:flip_user] == false) then
			session[:flip_user] = true
			redirect_to '/'
		elsif(session[:flip_user] == true) then
			session[:flip_user] = false
			redirect_to '/'
    end
  end
end