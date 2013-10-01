class RolesController < ApplicationController

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def index
    list
    render :action => 'list'
  end

  def list
    @roles = Role.find(:all,
                       :order => 'name')
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
      redirect_to :action => 'list'
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
    redirect_to :action => 'list'
  end

  protected

  def foreign
    if @role.id
      @other_roles = Role.find(:all,
                             :conditions => ['id not in (?)', @role.id],
                             :order => 'name')
    else
      @other_roles = Role.find(:all,
                               :order => 'name')
    end
    @other_roles ||= Array.new
    @other_roles.unshift Role.new(:id => nil, :name => '(none)')
    @users = User.find(:all,
                       :conditions => ['role_id = ?', @role.id],
                       :order => 'name')
  end
    
end
