# This controller is used for the Admin functionality
# Author: unknown
class AdminController < ApplicationController
  helper :administrator_instructor

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
    @users = User.paginate(:page => params[:page], :order => 'name',:conditions => ["parent_id = ? AND role_id = ?", user_id, Role::ADMINISTRATOR], :per_page => 50)
  end

  def show
    @user = User.find(params[:id])
    if @user.role_id
      @role = Role.find(@user.role_id)
    else
      @role = Role.new(:id => nil, :name => '(none)')
    end
  end

  def search_super_administrator
    @results = search_users(Role::SUPERADMINISTRATOR)
  end

  def add_super_administrator
    @user = User.new
  end

  def save_super_administrator # saves newly created administrator to database
    PgUsersController.create(Role::SUPERADMINISTRATOR,:admin_controller,:list_super_administrators,:add_super_administrator)
  end

  def list_super_administrators
    @users = User.find(:all, :conditions => ["role_id = ?", Role::SUPERADMINISTRATOR])
  end

  def edit
    redirect_to :action => 'new', :params => {:name => User.find(params[:id]).name }
  end

end
