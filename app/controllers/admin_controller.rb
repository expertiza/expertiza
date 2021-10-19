class AdminController < ApplicationController
  def action_allowed?
    case params[:action]
    when 'list_instructors'
      current_user.role.name['Administrator']
    when 'remove_instructor'
      current_user.role.name['Administrator'] or current_user.role.name['Super-Administrator']
    else
      current_user.role.name['Super-Administrator']
    end
  end

  def list_super_administrators
    @users = User.where(["role_id = ?", Role.superadministrator.id])
  end

  def show_super_administrator
    @user = User.find(params[:id])
    @role = Role.find(@user.role_id)
  end

  def list_administrators
    @users = User.admins.order(:name).where("parent_id = ?", current_user.id).paginate(page: params[:page], per_page: 50)
  end

  def show_administrator
    @user = User.find(params[:id])
    @role = Role.find(@user.role_id)
  end

  def list_instructors
    @users = User.instructors.order(:name).where("parent_id = ?", current_user.id).paginate(page: params[:page], per_page: 50)
  end

  def show_instructor
    @user = User.find(params[:id])
    @role = Role.find(@user.role_id)
  end

  def remove_administrator
    @parent_id = User.find(params[:id]).parent_id if User.find(params[:id])
    resolve_dependencies(params[:id])
    User.find(params[:id]).destroy
    redirect_to action: 'list_administrators'
  end

  def remove_instructor
    @parent_id = User.find(params[:id]).parent_id if User.find(params[:id])
    resolve_dependencies(params[:id])
    User.find(params[:id]).destroy
    redirect_to action: 'list_instructors'
  end

  private

  def resolve_dependencies(id)
    User.where(parent_id: id).update_all(parent_id: @parent_id)
    Assignment.where(instructor_id: id).update_all(instructor_id: @parent_id)
    AssignmentQuestionnaire.where(user_id: id).update_all(user_id: @parent_id)
    Course.where(instructor_id: id).update_all(instructor_id: @parent_id)
    Bookmark.where(user_id: id).update_all(user_id: @parent_id)
    Questionnaire.where(instructor_id: id).update_all(instructor_id: @parent_id)
  end
end
