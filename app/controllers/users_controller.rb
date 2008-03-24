class UsersController < ApplicationController
  auto_complete_for :user, :name
  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def index
    list
    render :action => 'list'
  end
  
  def auto_complete_for_user_name
    @users = User.find(:all, :conditions => ['name LIKE ? and (role_id < ? or id = ?)', "#{params[:user][:name]}%",(session[:user]).role_id, (session[:user]).id])
    render :inline => "<%= auto_complete_result @users, 'name' %>", :layout => false
  end
    
  def list
    all_users = User.find(:all, :order => 'name', :conditions => ['role_id < ? or id = ?',(session[:user]).role_id, (session[:user]).id])
    
    letter = params[:letter]
    if letter == nil
      letter = all_users.first.name[0,1].downcase
    end 
    logger.info "#{letter}"
    @letters = Array.new
    @user_pages, @users = paginate :users, :order => 'name', :per_page => 20,  :conditions => ["(role_id < ? or id = ?) and substring(name,1,1) = ?", (session[:user]).role_id, (session[:user]).id, letter]
    all_users = User.find(:all, :order => 'name', :conditions => ['role_id < ? or id = ?',(session[:user]).role_id, (session[:user]).id])
    all_users.each {
       | user |
       first = user.name[0,1].downcase
       if not @letters.include?(first)
          @letters << first  
       end
    }
  end
  
  def show_selection
    @user = User.find_by_name(params[:user][:name])
    getRole
    if @role.id < (session[:user]).role_id || @user.id == (session[:user]).id
      render :action => 'show'
    else
      flash[:note] = 'The specified user is not available for editing.'      
      redirect_to :action => 'list'
    end
  end
  
  def show
    @user = User.find(params[:id])
    getRole
  end
  
  def getRole
     if @user && @user.role_id
      @role = Role.find(@user.role_id)
    elsif @user
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
    user = User.find(params[:id])
    participant = Participant.find_by_user_id(user.id)
    team_user = TeamsUser.find_by_user_id(user.id)
    if participant 
      participant.destroy()  
    end
    if team_user
      team_user.destroy()
    end
    user.destroy()
    redirect_to :action => 'list'
  end

  protected

  def foreign    
    @all_roles = Role.find(:all, :order => 'name', :conditions => ['id <= ?',(session[:user]).role_id])    
  end
  
end
