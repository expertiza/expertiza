class ConferenceController < ApplicationController
  include AuthorizationHelper
  include ConferenceHelper

  autocomplete :user, :name
  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify method: :post, only: %i[destroy create update],
         redirect_to: { action: :list }
  def action_allowed?
    case params[:action]

    when 'new'
      is_valid_conference_assignment? || current_user_has_admin_rights
    when 'create'
      params[:assignment_id] = params[:user][:assignment]
      is_valid_conference_assignment?
    else
      current_user_has_admin_rights
    end
  end

  def new
    if current_user && current_user_has_student_privileges?
      @user = current_user
      params[:user] = current_user
      add_conference_user_as_participant && return
    elsif current_user && is_valid_conference_assignment?
      flash[:error] = 'Your current role does not allow you to join this assignment. Please log in as Student and retry to join.'
      redirect_to(get_redirect_url_link) && return
    else
      @user = User.new
      @rolename = Role.find_by(name: params[:role])
      # when a new user joins or an existing user updates his/her profile they will get to choose
      # from all the roles available
      # if user creation call is for conference user then only possible role is Student
      role = Role.find_by_name('Student')
      @all_roles = Role.where('id in (?) or id = ?', role.get_available_roles, role.id)
    end
  end

  def create
    # Check if user needs to be created as author for conference type assignment and add author to assignment
    @recaptcha_succeeded = verify_recaptcha secret_key: '6Lfb_uEZAAAAAPcSk-9fcNh3syzfvfagPeNc8Y_B'
    if @recaptcha_succeeded && add_conference_user
      add_conference_user_as_participant
    else
      url = polymorphic_url :conference, action: 'new', role: 'Student', assignment_id: params[:user][:assignment]
      return redirect_to url
    end
  end

  def add_conference_user
    # check if user is already present with given username in system
    existing_user = User.find_by(name: params[:user][:name])
    # if user exist then add user as participant to assignment else create account and then add as participant
    if existing_user.nil?
      if !User.find_by(email: params[:user][:email]).nil? || (params[:user][:name].nil? || params[:user][:name].empty?)
        flash[:error] = 'A user with username of this email already exists, Please provide a unique email to continue.'
        # redirect_to request.referrer
        return false
      end
      # Create author called from Conference Helper
      create_author
    else
      @user = existing_user
    end
  end
end
