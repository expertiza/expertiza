require 'will_paginate/array'

class UsersController < ApplicationController
  autocomplete :user, :name
  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
    :redirect_to => { :action => :list }


  def action_allowed?
    case params[:action]
    when 'keys'
      current_role_name.eql? 'Student'
    else
      ['Super-Administrator',
       'Administrator',
       'Instructor',
       'Teaching Assistant'].include? current_role_name
    end
  end

  def index
    if (current_user_role? == "Student")
      redirect_to(:action => AuthHelper::get_home_action(session[:user]), :controller => AuthHelper::get_home_controller(session[:user]))
    else
      list
      render :action => 'list'
    end
  end

  def auto_complete_for_user_name
    user = session[:user]
    role = Role.find(user.role_id)
    @users = User.where( ['name LIKE ? and (role_id in (?) or id = ?)', "#{params[:user][:name]}%",role.get_available_roles, user.id])
    render :inline => "<%= auto_complete_result @users, 'name' %>", :layout => false
  end

  #for displaying the list of users
  def list
    user = session[:user]
    role = user.role
    all_users = user.get_user_list
    # Deprecated
    # all_users = User.order('name').where( ['role_id in (?) or id = ?', role.get_available_roles, user.id])

    letter = params[:letter]
    session[:letter] = letter
    if letter == nil
      if all_users.length > 0
        letter = all_users.first.name[0,1].downcase
      end
    end
    @letters = Array.new

    @per_page = 1

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
    @users = paginate_list all_users

    @letters = ('A'..'Z').to_a
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
      if (params[:id].nil?) || ((current_user_role? == "Student") &&  (session[:user].id != params[:id].to_i))
        redirect_to(:action => AuthHelper::get_home_action(session[:user]), :controller => AuthHelper::get_home_controller(session[:user]))
      else
        @user = User.find(params[:id])
        get_role
        #obtain number of assignments participated
        @assignment_participant_num = 0
        AssignmentParticipant.where(user_id: @user.id).each {|participant| @assignment_participant_num += 1 }
        #judge whether this user become reviewer or reviewee
        @maps = ResponseMap.where(['reviewee_id = ? or reviewer_id = ?',params[:id],params[:id]])
        #count the number of users in DB
        @total_user_num = User.count
      end
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

      @user = User.new(user_params)
      # record the person who created this new user
      @user.parent_id = (session[:user]).id
      # set the user's timezone to its parent's
      @user.timezonepref = User.find(@user.parent_id).timezonepref

      if @user.save
        password = @user.reset_password         # the password is reset
        MailerHelper::send_mail_to_user(@user, "Your Expertiza account and password have been created", "user_welcome", password).deliver
        flash[:success] = "A new password has been sent to new user's e-mail address."
        #Instructor and Administrator users need to have a default set for their notifications
        # the creation of an AssignmentQuestionnaire object with only the User ID field populated
        # ensures that these users have a default value of 15% for notifications.
        #TAs and Students do not need a default. TAs inherit the default from the instructor,
        # Students do not have any checks for this information.
        if @user.role.name == "Instructor" or @user.role.name == "Administrator"
          AssignmentQuestionnaire.create(:user_id => @user.id)
        end
        undo_link("User \"#{@user.name}\" has been created successfully. ")
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
    @user = User.find params[:id]

    #update username, when the user cannot be deleted
    #rename occurs in 'show' page, not in 'edit' page
    #eg. /users/5408?name=5408
    if (request.original_fullpath == "/users/#{@user.id}?name=#{@user.id}")
      @user.name += '_hidden'
    end
    if @user.update_attributes(user_params)
      undo_link("User \"#{@user.name}\" has been updated successfully. ")
      redirect_to @user
    else
      foreign
      render :action => 'edit'
    end
  end

  def destroy
    begin
      @user = User.find(params[:id])
      AssignmentParticipant.where(user_id: @user.id).each{|participant| participant.delete}
      TeamsUser.where(user_id: @user.id).each{|teamuser| teamuser.delete}
      AssignmentQuestionnaire.where(user_id: @user.id).each{|aq| aq.destroy}
      Participant.delete(true)
      @user.destroy
      flash[:note] = undo_link("User \"#{@user.name}\" has been deleted successfully. ")
    rescue
      flash[:error] = $!
    end

    redirect_to :action => 'list'
  end

  def keys
    if (params[:id].nil?) || ((current_user_role? == "Student") &&  (session[:user].id != params[:id].to_i))
      redirect_to(:action => AuthHelper::get_home_action(session[:user]), :controller => AuthHelper::get_home_controller(session[:user]))
    else
      @user = User.find(params[:id])
      @private_key = @user.generate_keys
    end
  end

  protected

  def foreign
    role = Role.find((session[:user]).role_id)
    @all_roles = Role.where( ['id in (?) or id = ?',role.get_available_roles,role.id])
  end

  private

  def user_params
    params.require(:user).permit(:name, :crypted_password, :role_id, :password_salt, :fullname, :email, :parent_id, :private_by_default, :mru_directory_path, :email_on_review, :email_on_submission, :email_on_review_of_review, :is_new_user, :master_permission_granted, :handle, :leaderboard_privacy, :digital_certificate, :persistence_token, :timezonepref, :public_key, :copy_of_emails)
  end

  def get_role
    if @user && @user.role_id
      @role = Role.find(@user.role_id)
    elsif @user
      @role = Role.new(:id => nil, :name => '(none)')
    end
  end

  # For filtering the users list with proper search and pagination.
  def paginate_list(users)
    paginate_options = {"1" => 25, "2" => 50, "3" => 100}

    # If the above hash does not have a value for the key,
    # it means that we need to show all the users on the page
    #
    # Just a point to remember, when we use pagination, the
    # 'users' variable should be an object, not an array

    #The type of condition for the search depends on what the user has selected from the search_by dropdown
    @search_by = params[:search_by]

    # search for corresponding users
    # users = User.search_users(role, user_id, letter, @search_by)

    # paginate
    if (paginate_options["#{@per_page}"].nil?) #displaying all - no pagination
      users = users.paginate(:page => params[:page], :per_page => users.count)
    else #some pagination is active - use the per_page
      users = users.page(params[:page]).per_page(paginate_options["#{@per_page}"])
    end
    users
  end

  # generate the undo link
  #def undo_link
  #  "<a href = #{url_for(:controller => :versions,:action => :revert,:id => @user.versions.last.id)}>undo</a>"
  #end
end
