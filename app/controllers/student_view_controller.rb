class StudentViewController < ApplicationController
  def action_allowed?
    case params[:action]
    when 'set'
      true
    when 'revert'
      true
    end
  end

  def set
    session[:student_view] = true
    redirect_back
  end

  def revert
    session.delete(:student_view)
    redirect_back
  end
end
