class AdminController < ApplicationController
  def action_allowed?
    case params[:action]
    when 'list_instructors'
      current_user.role.name['Administrator']
    else
      current_user.role.name['Super-Administrator']
    end
  end

  def new_instructor
    @user = User.find_or_create_by_name(params[:name])

    # these values need to be true by default so new users receive e-mail on these events unless they opt not to
    if @user.new_record?
      @user.email_on_review = true
      @user.email_on_submission = true
      @user.email_on_review_of_review = true
      @user.role = Role.instructor
    end
  end

  def create_instructor
    if params['save']
      @user = User.find_or_create_by_name params[:user][:name]
      @user.role = Role.instructor
      @user.update_attributes(params[:user])
      redirect_to :action => 'list_instructors'
    else
      @user = User.new(params[:user])
      @user.parent_id = (session[:user]).id
      @user.role_id = Role.instructor.id

      if @user.save
        flash[:notice] = 'Instructor was successfully created.'
        redirect_to :action => 'list_instructors'
      else
        render :action => 'new_instructor'
      end
    end
  end

  def list_instructors
    @users = User.
      instructors.
      order(:name).
      where("parent_id = ?", current_user.id).
      paginate(:page => params[:page], :per_page => 50)
  end

  def add_administrator
    @user = User.new
  end

  def new_administrator
    add_administrator
  end

  def save_administrator # saves newly created administrator to database
    PgUsersController.create(Role.administrator.id, :admin_controller, :list_administrators, :add_administrator)
  end

  def create_administrator
    save_administrator
  end

  def list_administrators
    @users = User.
      admins.
      order(:name).
      where("parent_id = ?", current_user.id).
      paginate(:page => params[:page], :per_page => 50)
  end

  def list_users(conditions)
    @users = User.order(:name).where(conditions).paginate(:page => params[:page], :per_page => 50)
  end

  def new_super_administrator
    @user = User.new
  end

  def list_super_administrators
    @users = User.where(["role_id = ?", Role.superadministrator.id])
  end

  def show_instructor
    @user = User.find(params[:id])
    if @user.role_id
      @role = Role.find(@user.role_id)
    else
      @role = Role.new(:id => nil, :name => '(none)')
    end
  end

  def remove_instructor
    User.find(params[:id]).destroy
    redirect_to :action => 'list_instructors'
  end

  def save_super_administrator
    PgUsersController.create(Role.superadministrator.id, :admin_controller, :list_super_administrators, :new_super_administrator)
  end
end
