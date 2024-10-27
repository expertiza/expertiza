class AccountRequestController < ApplicationController
  include AuthorizationHelper
  autocomplete :user, :name
  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify method: :post, only: %i[destroy create update],
         redirect_to: { action: :list }

  def action_allowed?
    case params[:action]
    when 'list_pending_requested'
      current_user_has_admin_privileges?
    when 'new'
      verify_recaptcha
    when 'create_requested_user_record'
      true
    when 'keys'
      current_user_has_student_privileges?
    else
      current_user_has_ta_privileges?
    end
  end

  # TODO create_approved_user name is misleading. The tests are also wrong for this.
  # Decides whether a new user should be created or not
  def create_approved_user
    # If a user isn't selected before approving or denying, they are given an error message
    if params[:selection].nil?
      flash[:error] = 'Please select at least one user before approving or rejecting'
      redirect_to action: 'list_pending_requested'
      return
    end
    is_approved = (params[:commit] == 'Accept' ? 'Approved' : 'Rejected')
    users = params[:selection]
    users.each do |user|
      requested_user = AccountRequest.find_by(id: user.first)
      requested_user.status = is_approved
      if requested_user.status.nil?
        flash[:error] = 'Please Approve or Reject before submitting'
      elsif requested_user.update_attributes(requested_user_params)
        flash[:success] = "The user \"#{requested_user.username}\" has been successfully updated."
      end
      # If the users request is approved, they are stored as a user in the database
      if requested_user.status == 'Approved'
        user_new(requested_user)
      # If the user's request is denied, their entry is updated in the database and
      # a confirmation message is given saying their request has been denied
      elsif requested_user.status == 'Rejected'
        #  If the user request has been rejected, a flash message is shown and redirected to review page
        if requested_user.update_columns(status: is_approved)
          flash[:success] = "The user \"#{requested_user.username}\" has been Rejected."
          # redirect_to action: 'list_pending_requested'
          # return
        else
          flash[:error] = 'Error processing request.'
        end
      end
    end
    redirect_to action: 'list_pending_requested'
  end

  # Creates a new user if their request is approved
  def user_new(requested_user)
    new_user = User.new
    new_user.username = requested_user.username
    new_user.role_id = requested_user.role_id
    new_user.institution_id = requested_user.institution_id
    new_user.fullname = requested_user.fullname
    new_user.email = requested_user.email
    new_user.parent_id = session[:user].id
    new_user.timezonepref = User.find_by(id: new_user.parent_id).timezonepref
    # If the user is created, it sends the requested user an email with password instructions
    if new_user.save
      password = new_user.reset_password
      # Mail is sent to the user with a new password
      prepared_mail = MailerHelper.send_mail_to_user(new_user, 'Your Expertiza account and password have been created.', 'user_welcome', password)
      prepared_mail.deliver_now
      flash[:success] = "A new password has been sent to new user's e-mail address."
      undo_link("The user \"#{requested_user.username}\" has been successfully created. ")
    else
      foreign
    end
  end

  # If the registered user status is Approved and if the new_user couldn't be saved, foreign function saves the role id in @all_roles variable
  def foreign
    role = Role.find(session[:user].role_id)
    @all_roles = Role.where('id in (?) or id = ?', role.get_available_roles, role.id)
  end

  def new
    flash[:warn] = 'If you are a student, please contact your teaching staff to get your Expertiza ID.'
    @user = User.new
    @rolename = Role.find_by(name: params[:role])
    roles_for_request_sign_up
  end

  def list_pending_requested_finalized
    @requested_users = AccountRequest.where.not(status: 'Under Review').order('updated_at DESC').paginate(page: params[:page], per_page: 10)
    @roles = Role.all
  end

  def list_pending_requested
    @requested_users = AccountRequest.where(status: 'Under Review').order('created_at DESC').paginate(page: params[:page], per_page: 10)
    @roles = Role.all
  end

  # Creates an account request for the user if it is not a duplicate
  def create_requested_user_record
    requested_user = AccountRequest.new(requested_user_params)
    # An object is created with respect to AccountRequest model inorder to populate the users information when account is requested
    (user_exists = User.find_by(username: requested_user.username)) || User.find_by(username: requested_user.email)
    requested_user_saved = save_requested_user(requested_user, params)
    # Stores a boolean value with respect to whether the user data is saved or not
    if !user_exists && requested_user_saved
      notify_supers_new_request(requested_user)
      redirect_to '/instructions/home'
      return
    elsif user_exists
      flash[:error] = 'The account you are requesting already exists in Expertiza.'
      # If the user account already exists, log error to the user
    else
      flash[:error] = requested_user.errors.full_messages.to_sentence
      # If saving in the AccountRequests model has failed
    end
    ExpertizaLogger.error LoggerMessage.new(controller_name, requested_user.username, flash[:error], request)
    redirect_to controller: 'account_request', action: 'new', role: 'Student'
    # if the first if clause fails, redirect back to the account requests page!
  end

  # Verifies the requested user account has the institution, status, and role filled out then saves the object to the database
  def save_requested_user(requested_user, params)
    if params[:user][:institution_id].empty?
      institution = Institution.find_or_create_by(name: params[:institution][:name])
      requested_user.institution_id = institution.id
    end
    # If user enters others and adds a new institution, an institution id will be created with respect to the institution model.
    # This institution_attribute will be added to the AccountRequest model under institution_id attribute!
    requested_user.status = 'Under Review'
    # The status is by default 'Under Review' until the super admin approves or rejects
    # default to instructor role
    if requested_user.role_id.nil?
      requested_user.role_id = Role.where(name: 'Instructor')[0].id
    end
    requested_user.save
  end

  # Notifies all the super admins by email that request for a new account has been created
  def notify_supers_new_request(requested_user)
    super_users = User.joins(:role).where('roles.name = ?', 'Super-Administrator')
    super_users.each do |super_user|
      prepared_mail = MailerHelper.send_mail_to_all_super_users(super_user, requested_user, 'New Account Request: ' + requested_user.fullname)
      prepared_mail.deliver
    end
    # Notifying an email to the administrator regarding the new user request!
    ExpertizaLogger.info LoggerMessage.new(controller_name, requested_user.username, 'The account you are requesting has been created successfully.', request)
    flash[:success] = "User signup for \"#{requested_user.username}\" has been successfully requested."
    # Print out the acknowledgement message to the user and redirect to /instructors/home page when successful
  end

  def roles_for_request_sign_up
    roles_can_be_requested_online = ['Instructor']
    @all_roles = Role.where(name: roles_can_be_requested_online)
  end

  def requested_user_params
    params.require(:user).permit(:username, :role_id, :fullname, :institution_id, :email)
          .merge(self_introduction: params[:requested_user][:self_introduction])
  end
end
