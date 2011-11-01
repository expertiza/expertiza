# This controller is used for the Admin functionality
# Author: unknown
class InstructorController < ApplicationController
  helper :administrator_instructor

  def search
    @results = search_users(Role::INSTRUCTOR)
  end

  def new
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

  def create
    if params['save']
      @user = User.find_by_name((params[:user])[:name])
      @user.role_id = Role::INSTRUCTOR
      @user.update_attributes(params[:user])
      redirect_to :action => 'list'
    else

      @user = User.new(params[:user])
      @user.parent_id = (session[:user]).id
      @user.role_id = Role::INSTRUCTOR
      #@user.mru_directory_path = "/"

      if @user.save
        flash[:notice] = 'Instructor was successfully created.'
        redirect_to :action => 'list'
      else
        render :action => 'new'
      end
    end
  end


  def list
   user_id = session[:user].id
   @users = User.paginate(:page => params[:page], :order => 'name',:conditions => ["parent_id = ? AND role_id = ?", user_id, Role::INSTRUCTOR], :per_page => 50)
  end

  def show
    @user = User.find(params[:id])
    if @user.role_id
      @role = Role.find(@user.role_id)
    else
      @role = Role.new(:id => nil, :name => '(none)')
    end
  end

  def remove
    User.find(params[:id]).destroy
    redirect_to :action => 'list'
  end

  def edit
    redirect_to :action => 'new', :params => {:name => User.find(params[:id]).name }
  end

end
