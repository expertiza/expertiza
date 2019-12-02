class LockController < ApplicationController
  def action_allowed?
    case params[:action]
    when 'release_lock'
      Lock.find_by(lockable_id: params[:id], lockable_type: params[:type]).user == current_user
    else ['Instructor', 'Teaching Assistant', 'Administrator'].include? current_role_name
    end
  end
  
  def release_lock
    lockable = Object.const_get(params[:type]).find(params[:id])
    Lock.release_lock(lockable)
    #Avoid a big error because of no redirect
    redirect_to :back
  end
end