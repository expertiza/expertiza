class SiteControllersController < ApplicationController

  def action_allowed?
    current_role_name.eql?("Super-Administrator")
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
    :redirect_to => { :action => :index }

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
    @actions = ControllerAction
      .where( ['site_controller_id = ?', params[:id] ], :order => 'name')
  end

  def new
    foreign
    @site_controller = SiteController.new(name: params[:id])
  end

  def new_called
    redirect_to :action => 'new'
  end

  def create
    @site_controller = SiteController.new(params[:site_controller])
    if @site_controller.save
      flash[:notice] = 'SiteController was successfully created.'
      Role.rebuild_cache
      redirect_to :action => 'index'
    else
      foreign
      render :action => 'new'
    end
  end

  def edit
    @site_controller = SiteController.find(params[:id])
    foreign
  end

  def update
    @site_controller = SiteController.find(params[:id])
    if @site_controller.update_attributes(params[:site_controller])
      flash[:notice] = 'SiteController was successfully updated.'
      Role.rebuild_cache
      redirect_to @site_controller
    else
      foreign
      render :action => 'edit'
    end
  end

  def destroy
    SiteController.find(params[:id]).destroy
    Role.rebuild_cache
    redirect_to :action => 'index'
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
    known = Hash.new
    @missing = Array.new
    from_db.each do |dbc|
      if from_classes.has_key? dbc.name
        known[dbc.name] = dbc
      else
        @missing << dbc
      end
    end

    @unknown = Hash.new
    @app = Array.new
    @builtin = Array.new

    from_classes.keys.sort.each do |name|
      if known.has_key? name
        if known[name].builtin == 1
          @builtin << known[name]
        else
          @app << known[name]
        end
      else
        @unknown[name] = from_classes[name]
      end
    end

    @has_missing = (@missing.length > 0) ? true : false
    @has_unknown = (@unknown.keys.length > 0) ? true : false
    @has_app     = (@app.length > 0)     ? true : false
    @has_builtin = (@builtin.length > 0) ? true : false
  end


  # Given a controller name, returns an array of available actions to
  # which that controller will respond.

  def controller_actions(controller_name)

    controllers = controller_classes()
    actions = Hash.new()

    if @controller_classes.has_key? controller_name
      controller = @controller_classes[controller_name]

      for method in controller.public_instance_methods do
        actions[method] = true
      end

      for hidden in controller.hidden_actions do
        actions.delete hidden
      end
    end

    return actions.keys
  end  # def controller_actions

  end  # class
