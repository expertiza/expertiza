require 'will_paginate/array'

class UsersController < ApplicationController
  autocomplete :user, :name
  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify method: :post, only: %i[destroy create update],
         redirect_to: {action: :list}

  def action_allowed?
    case params[:action]
    when 'list_pending_requested'
      ['Super-Administrator',
       'Administrator'].include? current_role_name
    when 'request_new'
      true
    when 'create_requested_user_record'
      true
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
    if current_user_role? == "Student"
      redirect_to(action: AuthHelper.get_home_action(session[:user]), controller: AuthHelper.get_home_controller(session[:user]))
    else
      list
      render action: 'list'
    end
  end

  def auto_complete_for_user_name
    user = session[:user]
    role = Role.find(user.role_id)
    @users = User.where('name LIKE ? and (role_id in (?) or id = ?)', "#{params[:user][:name]}%", role.get_available_roles, user.id)
    render inline: "<%= auto_complete_result @users, 'name' %>", layout: false
  end

  #
  # for anonymized view for demo purposes
  #
  def set_anonymized_view
    anonymized_view_starter_ips = $redis.get('anonymized_view_starter_ips') || ''
    session[:ip] = request.remote_ip
    if anonymized_view_starter_ips.include? session[:ip]
      anonymized_view_starter_ips.delete!(" #{session[:ip]}")
    else
      anonymized_view_starter_ips += " #{session[:ip]}"
    end
    $redis.set('anonymized_view_starter_ips', anonymized_view_starter_ips)
    redirect_to :back
  end

  # for displaying the list of users
  def list
    user = session[:user]
    @users = user.get_user_list
  end

  def list_pending_requested
    @requested_users = RequestedUser.all
    @roles = Role.all
  end

  def show_selection
    @user = User.find_by(name: params[:user][:name])
    if !@user.nil?
      get_role
      if @role.parent_id.nil? || @role.parent_id < session[:user].role_id || @user.id == session[:user].id
        render action: 'show'
      else
        flash[:note] = 'The specified user is not available for editing.'
        redirect_to action: 'list'
      end
    else
      flash[:note] = params[:user][:name] + ' does not exist.'
      redirect_to action: 'list'
    end
  end

  def show
    if params[:id].nil? || ((current_user_role? == "Student") && (session[:user].id != params[:id].to_i))
      redirect_to(action: AuthHelper.get_home_action(session[:user]), controller: AuthHelper.get_home_controller(session[:user]))
    else
      @user = User.find(params[:id])
      get_role
      # obtain number of assignments participated
      @assignment_participant_num = 0
      AssignmentParticipant.where(user_id: @user.id).each {|_participant| @assignment_participant_num += 1 }
      # judge whether this user become reviewer or reviewee
      @maps = ResponseMap.where('reviewee_id = ? or reviewer_id = ?', params[:id], params[:id])
      # count the number of users in DB
      @total_user_num = User.count
    end
  end

  def new
    @user = User.new
    @rolename = Role.find_by(name: params[:role])
    foreign
  end

  def request_new
    flash[:warn] = "If you are a student, please contact your teaching staff to get your Expertiza ID."
    @user = User.new
    @rolename = Role.find_by(name: params[:role])
    roles_for_request_sign_up
  end

  def create
    # if the user name already exists, register the user by email address
    check = User.find_by(name: params[:user][:name])
    params[:user][:name] = params[:user][:email] unless check.nil?
    @user = User.new(user_params)
    @user.institution_id = params[:user][:institution_id]
    # record the person who created this new user
    @user.parent_id = session[:user].id
    # set the user's timezone to its parent's
    @user.timezonepref = User.find(@user.parent_id).timezonepref
    if @user.save
      password = @user.reset_password # the password is reset
      prepared_mail = MailerHelper.send_mail_to_user(@user, "Your Expertiza account and password have been created.", "user_welcome", password)
      prepared_mail.deliver
      flash[:success] = "A new password has been sent to new user's e-mail address."
      # Instructor and Administrator users need to have a default set for their notifications
      # the creation of an AssignmentQuestionnaire object with only the User ID field populated
      # ensures that these users have a default value of 15% for notifications.
      # TAs and Students do not need a default. TAs inherit the default from the instructor,
      # Students do not have any checks for this information.
      AssignmentQuestionnaire.create(user_id: @user.id) if @user.role.name == "Instructor" or @user.role.name == "Administrator"
      undo_link("The user \"#{@user.name}\" has been successfully created. ")
      redirect_to action: 'list'
    else
      foreign
      render action: 'new'
    end
  end

  def create_requested_user_record
    requested_user = RequestedUser.new(requested_user_params)
    if params[:user][:institution_id].empty?
      institution = Institution.find_or_create_by(name: params[:institution][:name])
      requested_user.institution_id = institution.id
    end
    requested_user.status = 'Under Review'
    # The super admin receives a mail about a new user request with the user name
    user_existed = User.find_by(name: requested_user.name) or User.find_by(name: requested_user.email)
    requested_user_saved = requested_user.save
    if !user_existed and requested_user_saved
      super_users = User.joins(:role).where('roles.name = ?', 'Super-Administrator')
      super_users.each do |super_user|
        prepared_mail = MailerHelper.send_mail_to_all_super_users(super_user, requested_user, 'New account Request')
        prepared_mail.deliver
      end
      ExpertizaLogger.info LoggerMessage.new(controller_name, requested_user.name, 'The account you are requesting has been created successfully.', request)
      flash[:success] = "User signup for \"#{requested_user.name}\" has been successfully requested."
      redirect_to '/instructions/home'
      return
    elsif user_existed
      flash[:error] = "The account you are requesting has already existed in Expertiza."
    else
      flash[:error] = requested_user.errors.full_messages.to_sentence
    end
    ExpertizaLogger.error LoggerMessage.new(controller_name, requested_user.name, flash[:error], request)
    redirect_to controller: 'users', action: 'request_new', role: 'Student'
  end

  def create_approved_user
    requested_user = RequestedUser.find_by(id: params[:id])
    requested_user.status = params[:status]
    if requested_user.status.nil?
      flash[:error] = "Please Approve or Reject before submitting"
    elsif requested_user.update_attributes(params[:user])
      flash[:success] = "The user \"#{requested_user.name}\" has been successfully updated."
    end
    if requested_user.status == "Approved"
      new_user = User.new
      new_user.name = requested_user.name
      new_user.role_id = requested_user.role_id
      new_user.institution_id = requested_user.institution_id
      new_user.fullname = requested_user.fullname
      new_user.email = requested_user.email
      new_user.parent_id = session[:user].id
      new_user.timezonepref = User.find_by(id: new_user.parent_id).timezonepref
      if new_user.save
        #password = new_user.reset_password
        # Mail is sent to the user with a new password
        #prepared_mail = MailerHelper.send_mail_to_user(new_user, "Your Expertiza account and password have been created.", "user_welcome", password)
        #prepared_mail.deliver
        flash[:success] = "A new password has been sent to new user's e-mail address."
        undo_link("The user \"#{requested_user.name}\" has been successfully created. ")
      else
        foreign
      end
    elsif requested_user.status == "Rejected"
      # If the user request has been rejected, a flash message is shown and redirected to review page
      if requested_user.update_columns(status: params[:status])
        flash[:success] = "The user \"#{requested_user.name}\" has been Rejected."
        redirect_to action: 'list_pending_requested'
        return
      else
        flash[:error] = "Error processing request."
      end
    end
    redirect_to action: 'list_pending_requested'
  end

  def edit
    @user = User.find(params[:id])
    get_role
    foreign
  end

  def update
    params.permit!
    @user = User.find params[:id]
    # update username, when the user cannot be deleted
    # rename occurs in 'show' page, not in 'edit' page
    # eg. /users/5408?name=5408
    @user.name += '_hidden' if request.original_fullpath == "/users/#{@user.id}?name=#{@user.id}"

    if @user.update_attributes(params[:user])
      flash[:success] = "The user \"#{@user.name}\" has been successfully updated."
      redirect_to @user
    else
      render action: 'edit'
    end
  end

  def destroy
    begin
      @user = User.find(params[:id])
      AssignmentParticipant.where(user_id: @user.id).each(&:delete)
      TeamsUser.where(user_id: @user.id).each(&:delete)
      AssignmentQuestionnaire.where(user_id: @user.id).each(&:destroy)
      # Participant.delete(true)
      @user.destroy
      flash[:note] = "The user \"#{@user.name}\" has been successfully deleted."
    rescue StandardError
      flash[:error] = $ERROR_INFO
    end

    redirect_to action: 'list'
  end

  def keys
    if params[:id].nil? || ((current_user_role? == "Student") && (session[:user].id != params[:id].to_i))
      redirect_to(action: AuthHelper.get_home_action(session[:user]), controller: AuthHelper.get_home_controller(session[:user]))
    else
      @user = User.find(params[:id])
      @private_key = @user.generate_keys
    end
  end

  protected

  def foreign
    role = Role.find(session[:user].role_id)
    @all_roles = Role.where('id in (?) or id = ?', role.get_available_roles, role.id)
  end

  def roles_for_request_sign_up
    roles_can_be_requested_online = ["Instructor", "Teaching Assistant"]
    @all_roles = Role.where(name: roles_can_be_requested_online)
  end

  private

  def user_params
    params.require(:user).permit(:name,
                                 :crypted_password,
                                 :role_id,
                                 :password_salt,
                                 :fullname,
                                 :email,
                                 :parent_id,
                                 :private_by_default,
                                 :mru_directory_path,
                                 :email_on_review,
                                 :email_on_submission,
                                 :email_on_review_of_review,
                                 :is_new_user,
                                 :master_permission_granted,
                                 :handle,
                                 :digital_certificate,
                                 :persistence_token,
                                 :timezonepref,
                                 :public_key,
                                 :copy_of_emails,
                                 :institution_id)
  end

  def requested_user_params
    params.require(:user).permit(:name, :role_id, :fullname, :institution_id, :email)
          .merge(self_introduction: params[:requested_user][:self_introduction])
  end

  def get_role
    if @user && @user.role_id
      @role = Role.find(@user.role_id)
    elsif @user
      @role = Role.new(id: nil, name: '(none)')
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

    # The type of condition for the search depends on what the user has selected from the search_by dropdown
    @search_by = params[:search_by]

    # search for corresponding users
    # users = User.search_users(role, user_id, letter, @search_by)

    # paginate
    users = if paginate_options[@per_page.to_s].nil? # displaying all - no pagination
              User.paginate(page: params[:page], per_page: users.count)
            else # some pagination is active - use the per_page
              User.paginate(page: params[:page], per_page: paginate_options[@per_page.to_s])
            end
    users
  end

  # generate the undo link
  # def undo_link
  #  "<a href = #{url_for(:controller => :versions,:action => :revert,:id => @user.versions.last.id)}>undo</a>"
  # end
end
