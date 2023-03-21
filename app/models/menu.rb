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
      @site_controller_id = item.try(:controller_action).try(:controller).try(:id)
      @controller_action_id = item.try(:controller_action).try(:id)
      @content_page_id = item.try(:content_page).try(:id)
      @url = if item.controller_action
               item.controller_action.url_to_use.presence || "/#{item.controller_action.controller.name}/#{item.controller_action.name}"
             else
               "/#{item.content_page.name}"
             end
    end

    def site_controller
      @site_controller ||= SiteController.find_by(id: @site_controller_id)
    end

    def controller_action
      @controller_action ||= ControllerAction.find_by(id: @controller_action_id)
    end

    def content_page
      @content_page = ContentPage.find_by(id: @content_page_id)
    end

    def add_child(child)
      @children ||= []
      @children << child.id
    end
  end

  # rubocop:disable Lint/DuplicateMethods
  attr_accessor :root, :selected
  # rubocop:enable Lint/DuplicateMethods

  def initialize(role = nil)
    @root = Node.new
    @by_id = {}
    @by_name = {}
    @selected = {}
    @vector = []
    @crumbs = []
    items = MenuItem.items_for_permissions(role.try(:cache)[:credentials].try(:permission_ids))
    # return if items.nil? or items.empty?
    return if items.blank?

    # Build hashes of items by name and id
    items.each do |item|
      node = Node.new
      node.setup(item)
      @by_id[item.id] = node
      @by_name[item.name] = node
    end

    # Then build tree of items
    items.each do |item|
      node = @by_id[item.id]
      p_id = node.parent_id
      if p_id
        @by_id[p_id].try(:add_child, node)
      else
        @root.add_child(node)
      end
    end
    select(@by_id[@root.children[0]].try(:name))
  end

  # Selects the menu item for the given name, if it exists in this menu.  If not returns nil.

  def select(name)
    return unless @by_name.key?(name)

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

  def get_item(item_id)
    @by_id[item_id]
  end

  # Returns the array of items at the given level.
  def get_menu(level)
    @vector[level].try(:children)
  end

  # Returns the name of the currently-selected item or nil if no item is selected.
  # rubocop:disable Lint/DuplicateMethods
  def selected
    @vector.last.try(:name)
  end
  # rubocop:enable Lint/DuplicateMethods

  # Returns true if the specified item is selected; false if otherwise.
  def selected?(menu_id)
    @selected.key?(menu_id)
  end

  def crumbs
    crumbs = []
    @crumbs.each { |crumb| crumbs << get_item(crumb) }
    crumbs
  end
end
