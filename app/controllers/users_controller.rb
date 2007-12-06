class UsersController < ApplicationController

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def index
    list
    render :action => 'list'
  end

  def list
    @user_pages, @users = paginate :users, :order => 'name', :per_page => 50
  end

  def show
    @user = User.find(params[:id])
    if @user.role_id
      @role = Role.find(@user.role_id)
    else
      @role = Role.new(:id => nil, :name => '(none)')
    end
  end

def self.yesorno(elt)
    if elt==true
      "yes"
    elsif elt ==false
      "no"
    else
      ""
  end
 end
  def new
    @user = User.new
    foreign
  end

  def create
    check = User.find_by_name(params[:user][:name])
    if check != nil
      params[:user][:name] = params[:user][:email]
    end
    @user = User.new(params[:user])
    @user.parent_id = (session[:user]).id

    if params[:user][:clear_password].length == 0 or
        params[:user][:confirm_password] != params[:user][:clear_password]
      flash[:error] = 'Passwords do not match.!'
      foreign
      render :action => 'new'
    else
      if @user.save
        flash[:notice] = 'User was successfully created.'
        redirect_to :action => 'list'
      else
        foreign
        render :action => 'new'
      end
    end
  end
  
  
  

  def edit
    @user = User.find(params[:id])
    if @user.role_id
      @role = Role.find(@user.role_id)
    end
    foreign
  end

  def update
    @user = User.find(params[:id])
    if params[:user]['clear_password'] == ''
      params[:user].delete('clear_password')
    end

    if params[:user][:clear_password] and
        params[:user][:clear_password].length > 0 and
        params[:user][:confirm_password] != params[:user][:clear_password]
      flash[:error] = 'Password invalid!'
      foreign
      render :action => 'edit'
    else
      if @user.update_attributes(params[:user])
        flash[:notice] = 'User was successfully updated.'
        redirect_to :action => 'show', :id => @user
      else
        foreign
        render :action => 'edit'
      end
    end
  end

  def destroy
    User.find(params[:id]).destroy
    redirect_to :action => 'list'
  end

  protected

  def foreign
    @all_roles = Role.find(:all, :order => 'name')
    
  end
  
end
