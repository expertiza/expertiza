# This helper contains all functions that are common to the instructor and administrator controller.
# These include searching users and listing all users of the type administrator or instructor.
# This helper is used by both admin_controller.rb and instructor_controller.rb
 module AdministratorInstructorHelper

 # search for instructors and administrators ie based on role
   def self.search_users (role)
    username = request.raw_post || request.query_string
    # show only instructors created by logged in admin
    @users = User.find(:all, :conditions => ["name LIKE ? and role_id = #{role}", (username + "%")])

    @results = Array.new
    for user in @users
      @results << [user.login, user.id]
    end
    render(:layout => false)
    @results
  end


# search for s user based on name
  def self.search_users
    @user = User.find_by_name(params[:name])
    #render :action => 'new'
  end

  #list all the users
  def self.list_users(conditions)
    @users = User.paginate(:page => params[:page], :order => 'name',:conditions => conditions, :per_page => 50)
  end

end
