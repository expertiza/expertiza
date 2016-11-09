class Menu
  class Node
    attr_accessor :parent, :parent_id, :children
    attr_accessor :site_controller_id, :controller_action_id, :content_page_id
    attr_accessor :id, :name, :label, :url

    def initialize
      @parent = nil
    end

    def setup(item)
      @parent_id = item.parent_id
      @name = item.name
      @id = item.id
      @label = item.label

      if item.controller_action
        @site_controller_id = item.controller_action.controller.id
        @controller_action_id = item.controller_action.id
      else
        @site_controller_id = nil
        @controller_action_id = nil
      end

      @content_page_id = (item.content_page.id if item.content_page)

      @url = ''
      if item.controller_action
        @url = if item.controller_action.url_to_use and
          !item.controller_action.url_to_use.empty?
                 item.controller_action.url_to_use
               else
                 "/#{item.controller_action.controller.name}/#{item.controller_action.name}"
               end
      else
        @url = "/#{item.content_page.name}"
      end
    end

    def site_controller
      unless @site_controller
        if @site_controller_id
          @site_controller = SiteController.find(@site_controller_id)
        end
      end
    end

    def controller_action
      unless @controller_action
        if @controller_action_id
          @controller_action = ControllerAction.find(@controller_action_id)
        end
      end
    end

    def content_page
      unless @content_page
        @content_page = ContentPage.find(@content_page_id) if @content_page_id
      end
    end

    def add_child(child)
      @children ||= []
      @children << child.id
    end
  end # class Node

  attr_accessor :root, :selected

  def initialize(role = nil)
    @root = Node.new
    @by_id = {}
    @by_name = {}
    @selected = {}
    @vector = []
    @crumbs = []

    items = nil

    if role
      unless role.cache[:credentials].permission_ids.empty?
        items = MenuItem.items_for_permissions(role.cache[:credentials].permission_ids)
      end
    else # No role given: build menu of everything
      items = MenuItem.items_for_permissions
    end

    if items
      unless items.empty?
        # Build hashes of items by name and id
        for item in items do
          # Convert keys to integers (for braindead DB backends)
          #           item.menu_item_id         &&= item.menu_item_id.to_i
          #           item.menu_item_seq        &&= item.menu_item_seq.to_i
          #           item.menu_item_parent_id  &&= item.menu_item_parent_id.to_i
          #           item.site_controller_id   &&= item.site_controller_id.to_i
          #           item.controller_action_id &&= item.controller_action_id.to_i
          #           item.content_page_id      &&= item.content_page_id.to_i
          #           item.permission_id        &&= item.permission_id.to_i

          node = Node.new
          node.setup(item)
          @by_id[item.id] = node
          @by_name[item.name] = node
        end

        # Then build tree of items
        for item in items do
          node = @by_id[item.id]
          p_id = node.parent_id
          if p_id
            @by_id[p_id].add_child(node) if @by_id.key?(p_id)
          else
            @root.add_child(node)
          end
        end
      end # if items.size > 0

      if @root.children and !@root.children.empty?
        select(@by_id[@root.children[0]].name)
      end
    end # if items
  end

  # Selects the menu item for the given name, if it exists in this
  # menu.  If not returns nil.

  def select(name)
    if @by_name.key?(name)
      node = @by_name[name]
      @selected = {}
      @vector = []
      @crumbs = []

      while node && node.id
        @selected[node.id] = node
        @vector.unshift node
        @crumbs.unshift node.id
        node = @by_id[node.parent_id]
      end
      @vector.unshift @root
      return @by_name[name]
    end
  end

  def get_item(item_id)
    @by_id[item_id]
  end

  # Returns the array of items at the given level.
  def get_menu(level)
    @vector[level].children if @vector.length > level
  end

  # Returns the name of the currently-selected item
  # or nil if no item is selected.
  def selected
    @vector[@vector.length - 1].name unless @vector.empty?
  end

  # Returns true if the specified item is selected; false if otherwise.
  def selected?(menu_id)
    @selected.key?(menu_id) ? true : false
  end

  def crumbs
    crumbs = []
    for crumb in @crumbs do
      item = get_item(crumb)
      crumbs << item
    end

    crumbs
  end
  end
