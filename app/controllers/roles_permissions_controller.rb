class RolesPermissionsController < ApplicationController

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def index
    list
    render :action => 'list'
  end

  def list
    @roles_permission_pages, @roles_permissions = paginate :roles_permissions, :per_page => 10
  end

  def show
    @roles_permission = RolesPermission.find(params[:id])
  end

  def new
    @roles_permission = RolesPermission.new
  end

  def new_permission_for_role
    @roles_permission = RolesPermission.new
    @roles_permission.role_id = params[:id]
    @role = Role.find(params[:id])
    @permissions = Permission.find_not_for_role(params[:id])
  end

  def create
    @roles_permission = RolesPermission.new(params[:roles_permission])
    if @roles_permission.save
      flash[:notice] = 'RolesPermission was successfully created.'
      redirect_to :controller => 'roles', :action => 'show', 
        :id => @roles_permission.role_id
    else
      render :action => 'new'
    end
  end

  def edit
    @roles_permission = RolesPermission.find(params[:id])
  end

  def update
    @roles_permission = RolesPermission.find(params[:id])
    if @roles_permission.update_attributes(params[:roles_permission])
      flash[:notice] = 'RolesPermission was successfully updated.'
      redirect_to :action => 'show', :id => @roles_permission
    else
      render :action => 'edit'
    end
  end

  def destroy
    rp = RolesPermission.find(params[:id])
    role = rp.role_id
    rp.destroy
    redirect_to :controller => 'roles', :action => 'show', :id => role
  end
end
