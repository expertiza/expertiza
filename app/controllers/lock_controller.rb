# A controller for interacting with locks from view classes
# The reason this was added was to ensure that a lock was released when a user left the page for
# review responses. See app/views/response/response.html.erb
class LockController < ApplicationController
  def action_allowed?
    case params[:action]
    when 'release_lock'
      # Only the current user should be able to release locks
      Lock.find_by(lockable_id: params[:id], lockable_type: params[:type]).user == current_user
    else ['Instructor', 'Teaching Assistant', 'Administrator'].include? current_role_name
    end
  end

  # Release the lock on the resource passed in in the parameters
  # Since lockable objects are polymorphic, the type needs to be passed in as a parameter
  def release_lock
    # Find the id in the table with the given type
    lockable = Object.const_get(params[:type]).find(params[:id])
    Lock.release_lock(lockable)
    # Avoid a big error because of no redirect
    redirect_back fallback_location: root_path
  end
end
