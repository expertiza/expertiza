class RolesController < ApplicationController

  def action_allowed?
    current_role_name.eql?("Super-Administrator")
  end


  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify method: :post, only: [ :destroy, :create, :update ], redirect_to: Role

  def index
    @roles = Role.order(:name)
  end

  def list
    redirect_to Role
  end

  def show
    @role = Role.find(params[:id])
    @rps = RolesPermission.find_for_role(@role.id)
    @roles = @role.get_parents
    foreign
  end

  def new
    @role = Role.new
    foreign()
  end

  def create
    @role = Role.new(params[:role])
    if @role.save
      Role.rebuild_cache
      flash[:notice] = 'Role was successfully created.'
      redirect_to Role
    else
      foreign
      render :action => 'new'
    end
  end

  def edit
    @role = Role.find(params[:id])
    foreign
  end

  def update
    @role = Role.find(params[:id])
    if @role.update_attributes(params[:role])
      Role.rebuild_cache
      @role = Role.find(params[:id])
      flash[:notice] = 'Role was successfully updated.'
      redirect_to :action => 'show', :id => @role.id
    else
      foreign
      render :action => 'edit'
    end
  end

  def destroy
    Role.find(params[:id]).destroy
    redirect_to Role
  end

  protected

  def foreign
    @other_roles = @role.other_roles

    @users = @role.users
  end
end
