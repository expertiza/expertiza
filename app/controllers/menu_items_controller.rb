require 'menu'

class MenuItemsController < ApplicationController
  def action_allowed?
    case params[:action]
    when 'link'
      true
    end
  end

  def index
    list
    render action: 'list'
  end

  def list
    # @menu_item_pages, @menu_items = paginate :menu_items, :per_page => 10
    @settings = SystemSettings.first
    @menu = Menu.new
    @items = @menu.get_menu(0)
  end

  def show
    @menu_item = MenuItem.find(params[:id])
  end

  def new
    @menu_item = MenuItem.new
    @menu = Menu.new
    @items = @menu.get_menu(0)
    foreign
    @can_change_parent = false
  end

  def new_for
    @parent_item = MenuItem.find(params[:id])
    @menu_item = MenuItem.new
    @menu_item.parent_id = @parent_item.id
    foreign
    @can_change_parent = false
    render action: 'new'
  end

  def create
    # Flash an error if neither an action nor a page has been selected
    if params[:menu_item][:controller_action_id].blank? &&
       params[:menu_item][:content_page_id].blank?
      flash[:error] = 'You must specify either an action or a page!'
      @menu_item = MenuItem.new(menu_item_params)
      @parent_item = MenuItem.find(params[:menu_item][:parent_id])
      foreign
      @can_change_parent = false
      render action: 'new', id: params[:id]
      return
    end

    @menu_item = MenuItem.new(menu_item_params)
    @menu_item.seq = MenuItem.next_seq(@menu_item.parent_id)

    if @menu_item.save
      flash[:notice] = 'The menu item was successfully created.'
      Role.rebuild_cache
      redirect_to action: 'list'
    else
      foreign
      render action: 'new'
    end
  end

  def edit
    @menu_item = MenuItem.find(params[:id])
    foreign
    @menu = Menu.new
    @items = @menu.get_menu(0)
    @can_change_parent = true
  end

  def update
    # Flash an error if neither an action nor a page has been selected
    if params[:menu_item][:controller_action_id].blank? &&
       params[:menu_item][:content_page_id].blank?
      flash[:error] = 'You must specify either an action or a page!'
      edit
      render action: 'edit'
      return
    end

    @menu_item = MenuItem.find(params[:id])
    # If this has been moved from another parent, need to repack
    # that parent
    if params[:parent_id] != @menu_item.parent_id
      do_repack = true
      repack_for = @menu_item.parent_id
      # Put at the end of new parent's list
      params[:menu_item][:seq] = MenuItem.next_seq(params[:menu_item][:parent_id])
    else
      do_repack = false
    end

    if @menu_item.update_attributes(menu_item_params)
      flash[:notice] = 'The menu item was successfully updated.'
      MenuItem.repack(repack_for) if do_repack
      Role.rebuild_cache
      # redirect_to :action => 'show', :id => @menu_item
      redirect_to action: 'list'
    else
      foreign
      render action: 'edit'
    end
  end

  def move_up
    @menu_item = MenuItem.find(params[:id])
    @above = @menu_item.above

    if @above
      @menu_item.update_attribute :seq, (@menu_item.seq - 1)
      @above.update_attribute :seq, (@above.seq + 1)
      Role.rebuild_cache
    end
    redirect_to action: 'list'
  end

  def move_down
    @menu_item = MenuItem.find(params[:id])
    @below = @menu_item.below

    if @below
      @menu_item.update_attribute :seq, (@menu_item.seq + 1)
      @below.update_attribute :seq, (@below.seq - 1)
      Role.rebuild_cache
    end
    redirect_to action: 'list'
  end

  def destroy
    @menu_item = MenuItem.find(params[:id])
    repack_for = @menu_item.parent_id
    @menu_item.destroy
    MenuItem.repack(repack_for)
    Role.rebuild_cache
    redirect_to action: 'list'
  end

  def link
    str = params[:name]
    node = session[:menu].try(:select, str)
    if node
      redirect_to node.url
    else
      logger.error '(error in menu)'
      redirect_to '/'
    end
  end

  private

  def menu_item_params
    params.require(:menu_item).permit(:id, :parent_id, :name, :label, :seq, :controller_action_id, :content_page_id)
  end

  protected

  def foreign
    @parents = if respond_to?(:id)
                 MenuItem.where('id != ?', id).order(:name)
               else
                 MenuItem.order(:name)
               end

    @parents.unshift MenuItem.new(id: nil, name: '(root)')
    @actions = ControllerAction.order_by_controller_and_action
    @actions.unshift ControllerAction.new(id: nil, name: '(none)')

    @pages = ContentPage.order(:name)
    @pages.unshift ContentPage.new(id: nil, name: '(none)')
  end
end
