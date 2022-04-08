class SiteControllersController < ApplicationController
  include AuthorizationHelper

  def action_allowed?
    current_user_has_super_admin_privileges?
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify method: :post, only: %i[destroy create update],
         redirect_to: { action: :index }

  def index
    @builtin_site_controllers = SiteController.builtin
    @app_site_controllers = SiteController.application
    classify_controllers
  end

  def list
    redirect_to action: 'index'
  end

  def show
    @site_controller = SiteController.find(params[:id])
    @actions = ControllerAction.where('site_controller_id = ?', params[:id]).order(:name)
  end

  def new
    foreign
    @site_controller = SiteController.new(name: params[:id])
  end

  def new_called
    redirect_to action: 'new'
  end

  def create
    @site_controller = SiteController.new(site_controller_params)
    if @site_controller.save
      flash[:notice] = 'The site controller was successfully created.'
      Role.rebuild_cache
      redirect_to action: 'index'
    else
      foreign
      render action: 'new'
    end
  end

  def edit
    @site_controller = SiteController.find(params[:id])
    foreign
  end

  def update
    @site_controller = SiteController.find(params[:id])
    if @site_controller.update_attributes(site_controller_params)
      flash[:notice] = 'The site controller was successfully updated.'
      Role.rebuild_cache
      redirect_to @site_controller
    else
      foreign
      render action: 'edit'
    end
  end

  def destroy
    SiteController.find(params[:id]).destroy
    Role.rebuild_cache
    redirect_to action: 'index'
  end

  protected

  def foreign
    @permissions = Permission.order(:name)
  end

  # @unknown contains ApplicationController class objects hashed by
  # name, while @app, @builtin and @missing are arrays of
  # SiteController ActiveRecord objects.
  def classify_controllers
    from_classes = SiteController.classes

    from_db = SiteController.order(:name)
    known = {}
    @missing = []
    from_db.each do |dbc|
      if from_classes.key? dbc.name
        known[dbc.name] = dbc
      else
        @missing << dbc
      end
    end

    @unknown = {}
    @app = []
    @builtin = []

    from_classes.keys.sort.each do |name|
      if known.key? name
        if known[name].builtin == 1
          @builtin << known[name]
        else
          @app << known[name]
        end
      else
        @unknown[name] = from_classes[name]
      end
    end

    @has_missing = !@missing.empty? ? true : false
    @has_unknown = !@unknown.keys.empty? ? true : false
    @has_app     = !@app.empty?     ? true : false
    @has_builtin = !@builtin.empty? ? true : false
  end

  # Given a controller name, returns an array of available actions to
  # which that controller will respond.

  def controller_actions(controller_name)
    actions = {}

    if @controller_classes.key? controller_name
      controller = @controller_classes[controller_name]

      controller.public_instance_methods.each do |method|
        actions[method] = true
      end

      controller.hidden_actions.each do |hidden|
        actions.delete hidden
      end
    end

    actions.keys
  end

  private

  def site_controller_params
    params.require(:site_controller).permit(:name, :permission_id, :builtin)
  end
end
