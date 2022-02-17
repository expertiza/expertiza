class ControllerActionsController < ApplicationController
  include AuthorizationHelper

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify method: :post, only: %i[destroy create update],
         redirect_to: { action: :index }

  def action_allowed?
    current_user_has_super_admin_privileges?
  end

  def index
    @controller_actions = ControllerAction.order(:name).paginate(per_page: 50, page: 1)
  end

  def list
    redirect_to action: 'index'
  end

  def show
    @controller_action = ControllerAction.find(params[:id])
    @permission = @controller_action.permission || Permission.new(id: nil, name: '(default)')
  end

  def new
    @controller_action = ControllerAction.new
    foreign
  end

  def new_for
    @controller_action = ControllerAction.new
    @controller_action.site_controller_id = params[:id]
    @site_controller = SiteController.find(params[:id])
    @actions = class_actions(@site_controller.name) if @site_controller
    foreign
    render action: 'new'
  end

  def create
    if params[:controller_action][:specific_name].present?
      params[:controller_action][:name] =
        params[:controller_action][:specific_name]
    end
    @controller_action = ControllerAction.new(controller_action_params)
    if @controller_action.save
      flash[:notice] = 'The controller action was successfully created.'
      Role.rebuild_cache
      redirect_to controller: 'site_controllers', action: 'show',
                  id: @controller_action.site_controller_id
    else
      foreign
      render action: 'new'
    end
  end

  def edit
    @controller_action = ControllerAction.find(params[:id])
    foreign
  end

  def update
    @controller_action = ControllerAction.find(params[:id])
    if @controller_action.update_attributes(controller_action_params)
      flash[:notice] = 'The controller action was successfully updated.'
      Role.rebuild_cache
      redirect_to controller: 'site_controllers', action: 'show',
                  id: @controller_action.site_controller_id
    else
      foreign
      render action: 'edit'
    end
  end

  def destroy
    @controller_action = ControllerAction.find(params[:id])
    @controller_action.destroy
    Role.rebuild_cache
    redirect_to @controller_action.site_controller
  end

  private

  def controller_action_params
    params.require(:controller_action).permit(:id, :site_controller_id, :name, :permission_id, :url_to_use)
  end

  protected

  def foreign
    @controllers = SiteController.order :name

    @permissions = Permission.order :name
    @permissions.unshift Permission.new(id: nil, name: '(default)')
  end

  def class_actions(classname)
    classes = SiteController.classes
    actions = {}

    if classes.key? classname
      controller = classes[classname]

      controller.public_instance_methods(false).each do |method|
        actions[method] = true
      end

      controller.hidden_actions.each do |hidden|
        actions.delete hidden
      end
    end

    action_collection = []
    actions.keys.sort.each do |action|
      action_collection << ControllerAction.new(name: action)
    end

    action_collection
  end
end
