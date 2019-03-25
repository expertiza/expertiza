class AccountRequestsController < ApplicationController
  before_action :set_account_request, only: [:show, :edit, :update, :destroy]

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
  account_request = AccountRequest.find_by(id: params[:id])
  account_request.status = params[:status]
  if account_request.status.nil?
    flash[:error] = "Please Approve or Reject before submitting"
  elsif account_request.update_attributes(params[:user])
    flash[:success] = "The user \"#{account_request.name}\" has been successfully updated."
  end
  if account_request.status == "Approved"
    new_user = User.new
    new_user.name = account_request.name
    new_user.role_id = account_request.role_id
    new_user.institution_id = account_request.institution_id
    new_user.fullname = account_request.fullname
    new_user.email = account_request.email
    new_user.parent_id = session[:user].id
    new_user.timezonepref = User.find_by(id: new_user.parent_id).timezonepref
    if new_user.save
      password = new_user.reset_password
      # Mail is sent to the user with a new password
      prepared_mail = MailerHelper.send_mail_to_user(new_user, "Your Expertiza account and password have been created.", "user_welcome", password)
      prepared_mail.deliver
      flash[:success] = "A new password has been sent to new user's e-mail address."
      undo_link("The user \"#{account_request.name}\" has been successfully created. ")
    else
      foreign
    end
  elsif account_request.status == "Rejected"
    # If the user request has been rejected, a flash message is shown and redirected to review page
    if account_request.update_columns(status: params[:status])
      flash[:success] = "The user \"#{account_request.name}\" has been Rejected."
      redirect_to action: 'list_pending_requested'
      return
    else
      flash[:error] = "Error processing request."
    end
  end
  redirect_to action: 'list_pending_requested'
end

def list_pending_requested
  @account_requests = AccountRequest.all
  @roles = Role.all
end

def request_new
  flash[:warn] = "If you are a student, please contact your teaching staff to get your Expertiza ID."
  @user = User.new
  @rolename = Role.find_by(name: "instructor")
  roles_for_request_sign_up
end

def create_requested_user_record
  account_request = AccountRequest.new(account_request_params)
  if params[:user][:institution_id].empty?
    institution = Institution.find_or_create_by(name: params[:institution][:name])
    account_request.institution_id = institution.id
  end
  account_request.status = 'Under Review'
  # The super admin receives a mail about a new user request with the user name
  user_existed = User.find_by(name: account_request.name) or User.find_by(name: account_request.email)
  account_request_saved = account_request.save
  if !user_existed and account_request_saved
    super_users = User.joins(:role).where('roles.name = ?', 'Super-Administrator')
    super_users.each do |super_user|
      prepared_mail = MailerHelper.send_mail_to_all_super_users(super_user, account_request, 'New account Request')
      prepared_mail.deliver
    end
    ExpertizaLogger.info LoggerMessage.new(controller_name, account_request.name, 'The account you are requesting has been created successfully.', request)
    flash[:success] = "User signup for \"#{account_request.name}\" has been successfully requested."
    redirect_to '/instructions/home'
    return
  elsif user_existed
    flash[:error] = "The account you are requesting has already existed in Expertiza."
  else
    flash[:error] = account_request.errors.full_messages.to_sentence
  end
  ExpertizaLogger.error LoggerMessage.new(controller_name, account_request.name, flash[:error], request)
  redirect_to controller: 'account_requests', action: 'request_new'
end


  def roles_for_request_sign_up
    roles_can_be_requested_online = ["Instructor", "Teaching Assistant"]
    @all_roles = Role.where(name: roles_can_be_requested_online)
  end

  protected

# finds the list of roles that the current user can have
# used to display a dropdown selection of roles for the current user in the views
  def foreign
    # finds what the role of the current user is.
    role = Role.find(session[:user].role_id)

    # this statement finds a list of roles that the current user can have
    # The @all_roles variable is used in the view to present the user a list of options
    # of the roles they may select from.
    @all_roles = Role.where('id in (?) or id = ?', role.get_available_roles, role.id)
  end


  private
  def account_request_params
    params.require(:user).permit(:name, :role_id, :fullname, :institution_id, :email)
        .merge(self_introduction: params[:account_request][:self_introduction])
  end

end
