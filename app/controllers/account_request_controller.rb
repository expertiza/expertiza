
class AccountRequestController < ApplicationController
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

  def create_approved_user
    requested_user = AccountRequest.find_by(id: params[:id])
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
        password = new_user.reset_password
        # Mail is sent to the user with a new password
        prepared_mail = MailerHelper.send_mail_to_user(new_user, "Your Expertiza account and password have been created.", "user_welcome", password)
        prepared_mail.deliver
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

  def foreign
    role = Role.find(session[:user].role_id)
    @all_roles = Role.where('id in (?) or id = ?', role.get_available_roles, role.id)
  end

  def request_new
    flash[:warn] = "If you are a student, please contact your teaching staff to get your Expertiza ID."
    @user = User.new
    @rolename = Role.find_by(name: params[:role])
    roles_for_request_sign_up
  end

  def list_pending_requested
    @requested_users = AccountRequest.all
    @roles = Role.all
  end

  def create_requested_user_record
    requested_user = AccountRequest.new(requested_user_params)
    if params[:user][:institution_id].empty?
      institution = Institution.find_or_create_by(name: params[:institution][:name])
      requested_user.institution_id = institution.id
    end
    requested_user.status = 'Under Review'
    # The super admin receives a mail about a new user request with the user name
    user_existed = User.find_by(name: requested_user.name) or User.find_by(name: requested_user.email)
    # default to instructor role
    if requested_user.role_id == nil
      requested_user.role_id = Role.where(:name => "Instructor")[0].id
    end
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
    redirect_to controller: 'account_request', action: 'request_new', role: 'Student'
  end

  def roles_for_request_sign_up
    roles_can_be_requested_online = ["Instructor"]
    @all_roles = Role.where(name: roles_can_be_requested_online)
  end

  def requested_user_params
    params.require(:user).permit(:name, :role_id, :fullname, :institution_id, :email)
        .merge(self_introduction: params[:requested_user][:self_introduction])
  end
end