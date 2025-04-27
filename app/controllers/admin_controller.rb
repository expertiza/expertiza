class AdminController < ApplicationController
  include AuthorizationHelper

  def action_allowed?
    case params[:action]
    when 'list_instructors'
      current_user_has_admin_privileges?
    when 'remove_instructor'
      current_user_has_admin_privileges?
    else
      current_user_has_super_admin_privileges?
    end
  end

  def list_super_administrators
    @users = User.where(['role_id = ?', Role.superadministrator.id])
  end

  def show_super_administrator
    @user = User.find(params[:id])
    @role = Role.find(@user.role_id)
  end

  def list_administrators
    @users = User.admins.order(:username).where('parent_id = ?', current_user.id).paginate(page: params[:page], per_page: 50)
  end

  def show_administrator
    @user = User.find(params[:id])
    @role = Role.find(@user.role_id)
  end

  def list_instructors
    @users = User.instructors.order(:username).where('parent_id = ?', current_user.id).paginate(page: params[:page], per_page: 50)
  end

  def show_instructor
    @user = User.find(params[:id])
    @role = Role.find(@user.role_id)
  end
end
