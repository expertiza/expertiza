require 'menu'


class MenuItemsController < ApplicationController

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update, 
                                      :move_up, :move_down ], 
  :redirect_to => { :action => :list }

  def index
    list
    render :action => 'list'
  end

  def list
    # @menu_item_pages, @menu_items = paginate :menu_items, :per_page => 10
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
    render :action => 'new'
  end

  def create
    # Flash an error if neither an action nor a page has been selected
    if (params[:menu_item][:controller_action_id] == nil or
        params[:menu_item][:controller_action_id].length == 0 ) and
        (params[:menu_item][:content_page_id] == nil or
         params[:menu_item][:content_page_id].length == 0 )
      flash[:error] = "You must specify either an Action or a Page!"
      @menu_item = MenuItem.new(params[:menu_item])
      @parent_item = MenuItem.find(params[:menu_item][:parent_id])
      foreign
      @can_change_parent = false
      render :action => 'new', :id => params[:id]
      return
    end

    @menu_item = MenuItem.new(params[:menu_item])
    @menu_item.seq = MenuItem.next_seq(@menu_item.parent_id)
    
    if @menu_item.save
      flash[:notice] = 'MenuItem was successfully created.'
      Role.rebuild_cache
      redirect_to :action => 'list'
    else
      foreign
      render :action => 'new'
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
    if (params[:menu_item][:controller_action_id] == nil or
        params[:menu_item][:controller_action_id].length == 0 ) and
        (params[:menu_item][:content_page_id] == nil or
         params[:menu_item][:content_page_id].length == 0 )
      flash[:error] = "You must specify either an Action or a Page!"
      edit
      render :action => 'edit'
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

    if @menu_item.update_attributes(params[:menu_item])
      flash[:notice] = 'MenuItem was successfully updated.'
      if do_repack
        MenuItem.repack(repack_for)
      end
      Role.rebuild_cache
      # redirect_to :action => 'show', :id => @menu_item
      redirect_to :action => 'list'
    else
      foreign
      render :action => 'edit'
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
    redirect_to :action => 'list'
  end

  def move_down
    @menu_item = MenuItem.find(params[:id])
    @below = @menu_item.below

    if @below
      @menu_item.update_attribute :seq, (@menu_item.seq + 1)
      @below.update_attribute :seq, (@below.seq - 1)
      Role.rebuild_cache
    end
    redirect_to :action => 'list'
  end

  def destroy
    @menu_item = MenuItem.find(params[:id])
    repack_for = @menu_item.parent_id
    @menu_item.destroy
    MenuItem.repack(repack_for)
    Role.rebuild_cache
    redirect_to :action => 'list'
  end

  def link
    str = String.new(params[:name][0])
    for k in 1..params[:name].length-1
      str = String.new(str + "/" + params[:name][k])
    end
    node = session[:menu].select(str)
    if node
      redirect_to node.url
    else
      logger.error "(error in menu)"
      redirect_to "/"
    end
  end

  def noview
    @items = MenuItem.items_for_permissions(session[:credentials].permission_ids)
  end


  protected
  
  def foreign
    if self.id
      @parents = MenuItem.find(:all,
                               :conditions => ['id not in (?)', self.id],
                               :order => 'name')
    else
      @parents = MenuItem.find(:all,
                               :order => 'name')
    end
    @parents.unshift MenuItem.new(:id => nil, :name => '(root)')
    @actions = ControllerAction.find(:all, :order => 'site_controller_id, name')
    @actions.unshift ControllerAction.new(:id => nil, 
                                          :name => '(none)')

    @pages = ContentPage.find(:all, :order => 'name')
    @pages.unshift ContentPage.new(:id => nil, :name => '(none)')
  end

end
