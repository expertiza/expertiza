class EulaController < ApplicationController
  def display    
  end
  
  def accept
    session[:user].update_attribute('is_new_user',0)
    redirect_to :controller => 'student_task', :action => 'list'
  end
  
  def decline
    flash[:notice] = 'Please accept the license agreement in order to use the system.'
    redirect_to :action => 'display'    
  end
end
