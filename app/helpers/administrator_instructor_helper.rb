module AdministratorInstructorHelper

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


  def self.search_users
    @user = User.find_by_name(params[:name])
    #render :action => 'new'
  end


  def self.list_users(conditions)
    @users = User.paginate(:page => params[:page], :order => 'name',:conditions => conditions, :per_page => 50)
  end

end
