class AdminController < ApplicationController

#
#  This code has been copied from pgnew.  It may or may not
#  have any of the functionality we need.  Someone who under-
#  stands it should have a look at it before it is used!
#

  def search_users (role)
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

  def search_instructor
    @results = search_users(Role::INSTRUCTOR)
  end

  def new_instructor
    @user = User.find_by_name(params[:name])
    if(@user==nil)
      @user = User.new
      
      # these values need to be true by default so new users receive e-mail on these events unless they opt not to
      @user.email_on_review = true
      @user.email_on_submission = true
      @user.email_on_review_of_review = true  
    else
      @found = true
    end
    @user.name = params[:name]
    @user.role_id = Role::INSTRUCTOR
  end

  def create_instructor
    if params['save']
      @user = User.find_by_name((params[:user])[:name])
      @user.role_id = Role::INSTRUCTOR
      @user.update_attributes(params[:user])
      redirect_to :action => 'list_instructors'
    else
    
    @user = User.new(params[:user])
    @user.parent_id = (session[:user]).id
    @user.role_id = Role::INSTRUCTOR
    #@user.mru_directory_path = "/"
    
    if params[:user][:clear_password].length == 0 or
        params[:user][:confirm_password] != params[:user][:clear_password]
      flash[:error] = 'Password invalid!'
      render :action => 'new_instructor'
    else
      if @user.save
        flash[:notice] = 'Instructor was successfully created.'
        redirect_to :action => 'list_instructors'
      else
        render :action => 'new_instructor'
      end
    end
    end
  end
  
  def search_users
    @user = User.find_by_name(params[:name])
    #render :action => 'new_instructor'
  end
  
  #def create_instructor # saves newly created instructor to database
  # PgUsersController.create(Role::INSTRUCTOR,:admin_controller,:list_instructors,:new_instructor)
  #end
  
  def list_instructors
   user_id = session[:user].id
   @user_pages, @users = paginate :users, :order => 'name',:conditions => ["parent_id = ? AND role_id = ?", user_id, Role::INSTRUCTOR], :per_page => 50
  end

 # def list_instructors
  #  user_id = session[:user].id
   # @users = User.find(:all,
  #                           :conditions => ["parent_id = ? AND role_id = ?",
 #                            user_id, Role::INSTRUCTOR])
 # end

  def search_administrator
    @results = search_users(Role::ADMINISTRATOR)
  end

  def add_administrator
    @user = User.new
  end

  def save_administrator # saves newly created administrator to database
    PgUsersController.create(Role::ADMINISTRATOR,:admin_controller,:list_administrators,:add_administrator)
  end

  def list_administrators
    
    user_id = session[:user].id
     # @users = User.find(:all,
     #                        :conditions => ["parent_id = ? AND role_id = ?",
     #                        user_id, Role::ADMINISTRATOR])
    @user_pages, @users = paginate :users, :order => 'name',:conditions => ["parent_id = ? AND role_id = ?", user_id, Role::ADMINISTRATOR], :per_page => 50
  end
  
  
  
  def list_users(conditions)
    @user_pages, @users = paginate :users, :order => 'name',:conditions => conditions, :per_page => 50
  end

  def search_super_administrator
    @results = search_users(Role::SUPERADMINISTRATOR)
  end

  def add_super_administrator
    @user = User.new
  end

  def show_instructor
    @user = User.find(params[:id])
    if @user.role_id
      @role = Role.find(@user.role_id)
    else
      @role = Role.new(:id => nil, :name => '(none)')
    end
  end

  def remove_instructor
    User.find(params[:id]).destroy
    redirect_to :action => 'list_instructors'
  end

  def save_super_administrator # saves newly created administrator to database
    PgUsersController.create(Role::SUPERADMINISTRATOR,:admin_controller,:list_super_administrators,:add_super_administrator)
  end

  def list_super_administrators
    user_id = session[:user].id
    @users = User.find(:all,
                             :conditions => ["role_id = ?",
                             Role::SUPERADMINISTRATOR])
  end
end
