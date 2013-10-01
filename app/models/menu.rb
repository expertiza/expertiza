class Menu

  class Node
    attr_accessor :parent, :parent_id, :children
    attr_accessor :site_controller_id, :controller_action_id, :content_page_id
    attr_accessor :id, :name, :label, :url

    def initialize()
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

      if item.content_page
        @content_page_id = item.content_page.id
      else
        @content_page_id = nil
      end

      @url = String.new
      if item.controller_action
        if item.controller_action.url_to_use and 
            item.controller_action.url_to_use.length > 0
          @url = item.controller_action.url_to_use
        else
          @url = "/#{item.controller_action.controller.name}/#{item.controller_action.name}"
        end
      else
        @url = "/#{item.content_page.name}"
      end
      
    end

    def site_controller
      if not @site_controller
        if @site_controller_id
          @site_controller = SiteController.find(@site_controller_id)
        end
      end
    end

    def controller_action
      if not @controller_action
        if @controller_action_id
          @controller_action = ControllerAction.find(@controller_action_id)
        end
      end
    end

    def content_page
      if not @content_page
        if @content_page_id
          @content_page = ContentPage.find(@content_page_id)
        end
      end
    end

    def add_child(child)
      @children ||= Array.new
      @children << child.id
    end


  end  # class Node


  attr_accessor :root, :selected

  def initialize(role = nil)
    @root = Node.new
    @by_id = Hash.new
    @by_name = Hash.new
    @selected = Hash.new
    @vector = Array.new
    @crumbs = Array.new

    items = nil

    if role
      if role.cache[:credentials].permission_ids.size > 0
        items = MenuItem.items_for_permissions(role.cache[:credentials].permission_ids)
#         items = MenuItem.find_by_sql(["select * from view_menu_items " +
#                                       "where permission_id in (?) " +
#                                       "order by menu_item_seq", 
#                                       role.cache[:credentials].permission_ids ])
      else  # role has no permissions
        # (items will remain as nil: the only node will be the root)
      end
    else  # No role given: build menu of everything
      items = MenuItem.items_for_permissions
#       items = MenuItem.find_by_sql("select * from view_menu_items " +
#                                    "order by menu_item_seq")
    end

    if items
      if items.size > 0
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
            if @by_id.has_key?(p_id)
              @by_id[p_id].add_child(node)
            end
          else
            @root.add_child(node)
          end
        end
      end  # if items.size > 0
      
      
      if @root.children and @root.children.length > 0
        select(@by_id[@root.children[0]].name) 
      end
    end  # if items
    
  end


  # Selects the menu item for the given name, if it exists in this
  # menu.  If not returns nil.

  def select(name)
    if @by_name.has_key?(name)
      node = @by_name[name]
      @selected = Hash.new
      @vector = Array.new
      @crumbs = Array.new
      
      while node and node.id
        @selected[node.id] = node
        @vector.unshift node
        @crumbs.unshift node.id
        node = @by_id[node.parent_id]
      end
      @vector.unshift @root
      return @by_name[name]
    else
      return nil
    end
  end

  def get_item(item_id)
    return @by_id[item_id]
  end

  # Returns the array of items at the given level.
  def get_menu(level)
    if @vector.length > level
      return @vector[level].children
    else
      return nil
    end
  end


  # Returns the name of the currently-selected item
  # or nil if no item is selected.
  def selected
    if @vector.length > 0
      return @vector[@vector.length - 1].name
    else
      return nil
    end
  end
  
  
  # Returns true if the specified item is selected; false if otherwise.
  def selected?(menu_id)
    @selected.has_key?(menu_id) ? true : false
  end

  def crumbs
    crumbs = Array.new
    for crumb in @crumbs do
      item = get_item(crumb)
      crumbs << item
    end

    return crumbs
  end

end
