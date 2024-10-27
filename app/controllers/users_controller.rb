require 'will_paginate/array'

class UsersController < ApplicationController
  include AuthorizationHelper
  include ConferenceHelper

  autocomplete :user, :name
  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify method: :post, only: %i[destroy create update],
         redirect_to: { action: :list }

  def action_allowed?
    case params[:action]
    when 'list_pending_requested'
      current_user_has_admin_privileges?
    when 'new'
      true
    when 'keys', 'index'
      # These action methods are all written with the clear expectation
      # that a student should be allowed to proceed
      current_user_has_student_privileges?
    when 'show', 'set_anonymized_view'
      # This action method is written with the clear expectation
      # that a student should be allowed to proceed
      # Furthermore, there is an RSPec test that a 'student' with no role id
      # should be allowed to proceed
      user_logged_in?
    else
      current_user_has_ta_privileges?
    end
  end

  def index
    if current_user_is_a? 'Student'
      redirect_to(action: AuthHelper.get_home_action(session[:user]), controller: AuthHelper.get_home_controller(session[:user]))
    else
      list
      render action: 'list'
    end
  end

  def auto_complete_for_user_name
    user = session[:user]
    role = Role.find(user.role_id)
    @users = User.where('username LIKE ? and (role_id in (?) or id = ?)', "#{params[:user][:username]}%", role.get_available_roles, user.id)
    render inline: "<%= auto_complete_result @users, 'username' %>", layout: false
  end

  # for anonymized view for demo purposes
  def set_anonymized_view
    anonymized_view_starter_ips = $redis.get('anonymized_view_starter_ips') || ''
    session[:ip] = request.remote_ip
    if anonymized_view_starter_ips.include? session[:ip]
      anonymized_view_starter_ips.delete!(" #{session[:ip]}")
    else
      anonymized_view_starter_ips += " #{session[:ip]}"
    end
    $redis.set('anonymized_view_starter_ips', anonymized_view_starter_ips)
    redirect_back fallback_location: root_path
  end

  # for displaying the list of users
  def list
    letter = params[:letter]
    search_by = params[:search_by]
    # If search parameters present
    if letter.present? && search_by.present?
      case search_by.to_i
      when 1 # Search by username
        @paginated_users = paginate_list.where('username LIKE ?', "%#{letter}%")
      when 2 # Search by fullname
        @paginated_users = paginate_list.where('fullname LIKE ?', "%#{letter}%")
      when 3 # Search by email
        @paginated_users = paginate_list.where('email LIKE ?', "%#{letter}%")
      else
        @paginated_users = paginate_list
      end
    else # Display all users if no search parameters present
      @paginated_users = paginate_list
    end
  end

  # for displaying users which are being searched for editing purposes after checking whether current user is authorized to do so
  def show_if_authorized
    @user = User.find_by(username: params[:user][:username])
    if @user.nil?
      flash[:note] = params[:user][:username] + ' does not exist.'
      redirect_to action: 'list'
    else
      role
      # check whether current user is authorized to edit the user being searched, call show if true

      if @role.parent_id.nil? || @role.parent_id < session[:user].role_id || @user.id == session[:user].id
        @total_user_num = User.count
        @assignment_participant_num = AssignmentParticipant.where(user_id: @user.id).count
        render action: 'show'
      else
        flash[:note] = 'The specified user is not available for editing.'
        redirect_to action: 'list'
      end
    end
  end

  def show
    if params[:id].nil? || ((current_user_is_a? 'Student') && (!current_user_has_id? params[:id]))
      redirect_to(action: AuthHelper.get_home_action(session[:user]), controller: AuthHelper.get_home_controller(session[:user]))
    else
      @user = User.find(params[:id])
      @role = @user.role
      @assignment_participant_num = AssignmentParticipant.where(user_id: @user.id).count
      @maps = ResponseMap.where('reviewee_id = ? or reviewer_id = ?', params[:id], params[:id])
      @total_user_num = User.count
    end
  end

  def new
    @user = User.new
    @rolename = Role.find_by(name: params[:role])
    foreign
  end

  def create
    # if the user name already exists, register the user by email address
    check = User.find_by(username: params[:user][:username])
    if check
      params[:user][:username] = params[:user][:email]
      flash[:note] = "That username already exists. Username has been set to the user's email address"
    end
    is_user = true
    # Assign all user params for creating user using assign_user_params function
    @user = assign_user_params(is_user)
    if @user.save
      password = @user.reset_password # the password is reset
      prepared_mail = MailerHelper.send_mail_to_user(@user, 'Your Expertiza account and password have been created.', 'user_welcome', password)
      prepared_mail.deliver
      flash[:success] = "A new password has been sent to new user's e-mail address."
      # Instructor and Administrator users need to have a default set for their notifications
      # the creation of an AssignmentQuestionnaire object with only the User ID field populated
      # ensures that these users have a default value of 15% for notifications.
      # TAs and Students do not need a default. TAs inherit the default from the instructor,
      # Students do not have any checks for this information.
      AssignmentQuestionnaire.create(user_id: @user.id) if (@user.role.name == 'Instructor') || (@user.role.name == 'Administrator')
      undo_link("The user \"#{@user.username}\" has been successfully created. ")
      redirect_to action: 'list'
    else
      foreign
      error_message = ''
      @user.errors.each { |_field, error| error_message << error }
      flash[:error] = error_message
      redirect_to action: 'list'
    end
  end

  def edit
    @user = User.find(params[:id])
    role
    foreign
  end

  def update
    # TODO: Remove this permit! and replace it with appropriate strong params after testing.
    # method :- user_params
    params.permit!
    @user = User.find params[:id]
    # update username, when the user cannot be deleted
    # rename occurs in 'show' page, not in 'edit' page
    # eg. /users/5408?name=5408
    @user.username += '_hidden' if request.original_fullpath == "/users/#{@user.id}?username=#{@user.id}"

    if @user.update_attributes(params[:user])
      flash[:success] = "The user \"#{@user.username}\" has been successfully updated."
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
      flash[:note] = "The user \"#{@user.username}\" has been successfully deleted."
    rescue StandardError
      flash[:error] = $ERROR_INFO
    end

    redirect_to action: 'list'
  end

  def keys
    if params[:id].nil? || ((current_user_is_a? 'Student') && (!current_user_has_id? params[:id]))
      redirect_to(action: AuthHelper.get_home_action(session[:user]), controller: AuthHelper.get_home_controller(session[:user]))
    else
      @user = User.find(params[:id])
      @private_key = @user.generate_keys
    end
  end

  protected

  def foreign
    # stores all the roles that are possible
    # when a new user joins or an existing user updates his/her profile they will get to choose
    # from all the roles available
    role = Role.find(session[:user].role_id)
    @all_roles = Role.where('id in (?) or id = ?', role.get_available_roles, role.id)
  end

  private

  # add user etc_icons_on_homepage
  def user_params
    params.require(:user).permit(:username,
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
                                 :institution_id,
                                 :etc_icons_on_homepage)
  end

  # to find the role of a given user object and set the @role accordingly
  def role
    if @user && @user.role_id
      @role = Role.find(@user.role_id)
    elsif @user
      @role = Role.new(id: nil, name: '(none)')
    end
  end

  # For filtering the users list with proper search and pagination.
  def paginate_list
    paginate_options = { '1' => 25, '2' => 50, '3' => 100 }

    # If the above hash does not have a value for the key,
    # it means that we need to show all the users on the page
    #
    # Just a point to remember, when we use pagination, the
    # 'users' variable should be an object, not an array

    # The type of condition for the search depends on what the user has selected from the search_by dropdown
    @search_by = params[:search_by]
    @per_page = 3
    # search for corresponding users
    # users = User.search_users(role, user_id, letter, @search_by)

    # paginate
    users = if paginate_options[@per_page.to_s].nil? # displaying all - no pagination
              User.paginate(page: params[:page], per_page: User.count)
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
