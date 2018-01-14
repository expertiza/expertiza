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
      @url = if item.controller_action
               item.controller_action.url_to_use.presence || "/#{item.controller_action.controller.name}/#{item.controller_action.name}"
             else
               "/#{item.content_page.name}"
             end
    end

    def site_controller
      unless @site_controller
        @site_controller = SiteController.find(@site_controller_id) if @site_controller_id
      end
    end

    def controller_action
      unless @controller_action
        @controller_action = ControllerAction.find(@controller_action_id) if @controller_action_id
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
      items = MenuItem.items_for_permissions(role.cache[:credentials].permission_ids) unless role.cache[:credentials].permission_ids.nil?
    else # No role given: build menu of everything
      items = MenuItem.items_for_permissions
    end

    if items
      unless items.empty?
        # Build hashes of items by name and id
        for item in items do
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

      select(@by_id[@root.children[0]].name) if @root.children.present?
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
      @by_name[name]
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
