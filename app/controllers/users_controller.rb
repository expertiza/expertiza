class UsersController < ApplicationController
  auto_complete_for :user, :name
  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def index
    list
    render :action => 'list'
  end
  
  def self.participants_in(assignment_id)
    users = Array.new
    participants = AssignmentParticipant.find_by_parent_id(assignment_id)    
    participants.each{
      |participant| 
      users << User.find(participant.user_id)
    }
  end

  def auto_complete_for_user_name
    user = session[:user]
    role = Role.find(user.role_id)   
    @users = User.find(:all, :conditions => ['name LIKE ? and (role_id in (?) or id = ?)', "#{params[:user][:name]}%",role.get_available_roles, user.id])
    render :inline => "<%= auto_complete_result @users, 'name' %>", :layout => false
  end
    
  def list
    user = session[:user]
    role = Role.find(user.role_id)
    all_users = User.find(:all, :order => 'name', :conditions => ['role_id in (?) or id = ?', role.get_available_roles, user.id])
    
    letter = params[:letter]
    session[:letter] = letter
    if letter == nil
      letter = all_users.first.name[0,1].downcase
    end 
    logger.info "#{letter}"
    @letters = Array.new

    # Check if the "Show" button for pagination is clicked
    # If yes, set @per_page to the value of the selection dropdown
    # Else, if the request is from one of the letter links on the top
    # set @per_page to 1 (25 names per page).
    # Else, set @per_page to the :num_users param passed in from
    # the will_paginate method from the 'pagination' partial.
    if params[:paginate_show]
      @per_page = params[:num_users]
    elsif params[:from_letter]
      @per_page = 1
    else
      @per_page = params[:num_users]
    end

    # Get the users list to show on current page
    @users = paginate_list(role, user.id, letter)

    all_users.each {
       | userObj |
       first = userObj.name[0,1].downcase
       if not @letters.include?(first)
          @letters << first  
       end
    }
  end

  def show_selection
    @user = User.find_by_name(params[:user][:name])
    if @user != nil
       get_role
       if @role.parent_id == nil || @role.parent_id < (session[:user]).role_id || @user.id == (session[:user]).id
          render :action => 'show'
      else
          flash[:note] = 'The specified user is not available for editing.'      
          redirect_to :action => 'list'
      end
    else
        flash[:note] = params[:user][:name]+' does not exist.'
        redirect_to :action => 'list'
    end
  end
  
  def show
    @user = User.find(params[:id])
    get_role
  end
  
  def new
    @user = User.new
    foreign
  end

  def create
    # if the user name already exists, register the user by email address
    check = User.find_by_name(params[:user][:name])
    if check != nil
      params[:user][:name] = params[:user][:email]
    end
    
    @user = User.new(params[:user])
    # record the person who created this new user
    @user.parent_id = (session[:user]).id
    
    if @user.save
      #Instructor and Administrator users need to have a default set for their notifications
      # the creation of an AssignmentQuestionnaires object with only the User ID field populated
      # ensures that these users have a default value of 15% for notifications.
      #TAs and Students do not need a default. TAs inherit the default from the instructor,
      # Students do not have any checks for this information.
      if @user.role.name == "Instructor" or @user.role.name == "Administrator"
        AssignmentQuestionnaires.create(:user_id => @user.id)
      end
      flash[:notice] = 'User was successfully created.'
      redirect_to :action => 'list'
    else
      foreign
      render :action => 'new'
    end
  end


  def edit
    @user = User.find(params[:id])
    get_role
    foreign
  end

  def update
    @user = User.find(params[:id])   

    if @user.update_attributes(params[:user])
      flash[:notice] = 'User was successfully updated.'
      redirect_to :action => 'show', :id => @user
    else
      foreign
      render :action => 'edit'
    end
  end


  def destroy
    begin
       user = User.find(params[:id])
       AssignmentParticipant.find_all_by_user_id(user.id).each{|participant| participant.delete}
       TeamsUser.find_all_by_user_id(user.id).each{|teamuser| teamuser.delete}
       AssignmentQuestionnaires.find_all_by_user_id(user.id).each{|aq| aq.destroy}           
       user.destroy
    rescue
      flash[:error] = $!
    end
    
    redirect_to :action => 'list'
  end
  
  def keys
    @user = User.find(params[:id])
    @private_key = @user.generate_keys
  end
  
  protected

  def foreign
    role = Role.find((session[:user]).role_id)  
    @all_roles = Role.find(:all, :conditions => ['id in (?) or id = ?',role.get_available_roles,role.id])
  end
 
  private

  def get_role
     if @user && @user.role_id
      @role = Role.find(@user.role_id)
    elsif @user
      @role = Role.new(:id => nil, :name => '(none)')
    end
  end

  def paginate_list(role, user_id, letter)
    paginate_options = {"1" => 25, "2" => 50, "3" => 100}

    # If the above hash does not have a value for the key,
    # it means that we need to show all the users on the page
    #
    # Just a point to remember, when we use pagination, the
    # 'users' variable should be an object, not an array
    if (paginate_options["#{@per_page}"].nil?)
      users = User.paginate(:page => params[:page], :order => 'name', :per_page => User.count(:all), :conditions => ["(role_id in (?) or id = ?) and substring(name,1,1) = ?", role.get_available_roles, user_id, letter])
    else
      users = User.paginate(:page => params[:page], :order => 'name', :per_page => paginate_options["#{@per_page}"], :conditions => ["(role_id in (?) or id = ?) and substring(name,1,1) = ?", role.get_available_roles, user_id, letter])
    end
    users
  end
end
