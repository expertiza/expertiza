# This controller is used for the Admin functionality
# Author: unknown
class AdminController < ApplicationController

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
    @results = search_users(Role.instructor.id)
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
    @user.role_id = Role.instructor.id
  end

  def create_instructor
    if params['save']
      @user = User.find_by_name((params[:user])[:name])
      @user.role_id = Role.instructor.id
      @user.update_attributes(params[:user])
      redirect_to :action => 'list_instructors'
    else
    
      @user = User.new(params[:user])
      @user.parent_id = (session[:user]).id
      @user.role_id = Role.instructor.id
      #@user.mru_directory_path = "/"
    
      if @user.save
        flash[:notice] = 'Instructor was successfully created.'
        redirect_to :action => 'list_instructors'
      else
        render :action => 'new_instructor'
      end
    end
  end
  
  def search_users
    @user = User.find_by_name(params[:name])
    #render :action => 'new_instructor'
  end
  
  def list_instructors
   user_id = session[:user].id
   @users = User.paginate(:page => params[:page], :order => 'name',:conditions => ["parent_id = ? AND role_id = ?", user_id, Role.instructor.id], :per_page => 50)
  end

  def search_administrator
    @results = search_users(Role.administrator.id)
  end

  def add_administrator
    @user = User.new
  end

  def save_administrator # saves newly created administrator to database
    PgUsersController.create(Role.administrator.id,:admin_controller,:list_administrators,:add_administrator)
  end

  def list_administrators    
    user_id = session[:user].id    
    @users = User.paginate(:page => params[:page], :order => 'name',:conditions => ["parent_id = ? AND role_id = ?", user_id, Role.administrator.id], :per_page => 50)
  end
   
  def list_users(conditions)
    @users = User.paginate(:page => params[:page], :order => 'name',:conditions => conditions, :per_page => 50)
  end

  def search_super_administrator
    @results = search_users(Role.superadministrator.id)
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
    PgUsersController.create(Role.superadministrator.id,:admin_controller,:list_super_administrators,:add_super_administrator)
  end

  def list_super_administrators
    @users = User.find(:all, :conditions => ["role_id = ?", Role.superadministrator.id])
  end
end
