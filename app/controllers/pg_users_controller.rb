class PgUsersController < UsersController
  # This method creates an entry in the users table.  It is caled from the Add Super-Admin, Add Administrator, Add Instructor, and Add Student functions
  # The parent field identifies the entity in the users table (e.g., an instructor) that created this entry (e.g., a student).
  def self.create(role, controller, success_action, failure_action)
    user = User.new(params[:user])
    user.parent_id = (session[:user]).id
    user.role_id = role

    if user.save
      user_type = Role.find(user.role_id).name
      flash[:notice] = '#{user_type} was successfully created.'
      redirect_to :controller => controller, :action => success_action
    else
      render :controller => controller, :action => failure_action
    end
  end
  
  # user_id - the id (in the users table) of the user to be removed.
  # user_type - a string representing the type of user that is being removed
  def self.remove_user(user_id, user_type)
    if user_id then
      begin
        user = User.find(user_id)
        # Change user rights?
        user.destroy
        flash[:notice] = "The " + user_type + "<tt>#{user.login}</tt> has been removed."
      rescue ActiveRecord::RecordNotFound
        # logging?
        flash[:notice] = "The " + user_type + "to be removed is not in the database."
      end
    end
  end
end
