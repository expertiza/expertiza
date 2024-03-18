describe Node do
  let(:node) { Menu::Node.new }
  let(:content_page) { double('ContentPage', id: 1, name: 'name') }
  let(:controller_action) { double('ControllerAction', id: 99, name: 'name', url_to_use: 'url', controller: nil) }
  let(:controller) { double('Controller', id: 3, name: 'name') }
  let(:menu_item) do
    build :menu_item,
          parent_id: 1,
          name: 'name',
          id: 2,
          label: 'label',
          controller_action: controller_action,
          content_page: content_page
  end
  before(:each) { node.setup(menu_item) }

  describe '#setup' do
    it 'sets up attributes: parent_id, name, id, label' do
      expect(node.parent_id).to eq(menu_item.parent_id)
      expect(node.name).to eq(menu_item.name)
      expect(node.id).to eq(menu_item.id)
      expect(node.label).to eq(menu_item.label)
    end

    context 'when menu_item has controller_action' do
      it 'sets up controller_action_id' do
        expect(node.controller_action_id).to eq(controller_action.id)
      end

      it 'assigns url to controller_action.url_to_use' do
        expect(node.url).to eq(controller_action.url_to_use)
      end

      context 'when controller_action has controller' do
        before(:each) do
          allow(controller_action).to receive(:controller).and_return(controller)
          node.setup(menu_item)
        end

        it 'sets up site_controller_id' do
          expect(node.site_controller_id).to eq(controller.id)
        end

        context 'when controller_action has no url_to_use' do
          it 'assembles url from controller_action.controller' do
            allow(controller_action).to receive(:url_to_use)
            node.setup(menu_item)
            expect(node.url).to eq("/#{controller.name}/#{controller_action.name}")
          end
        end
      end
    end

    context 'when menu_item has content_page' do
      before(:each) do
        allow(menu_item).to receive(:controller_action)
        node.setup(menu_item)
      end

      it 'sets up content_page_id' do
        expect(node.content_page_id).to eq(content_page.id)
      end

      it 'sets up url to content_page name' do
        expect(node.url).to eq("/#{content_page.name}")
      end
    end
  end

  describe '#site_controller' do
    before(:each) do
      allow(controller_action).to receive(:controller).and_return(controller)
      node.setup(menu_item)
    end
    it 'sets @site_controller instance variable' do
      result = controller_action.id
      expect(SiteController).to receive(:find_by).with(id: controller.id).and_return(result)
      expect(node.site_controller).to eq(result)
    end
  end

  describe '#controller_action' do
    it 'sets @controller_action instance variable ' do
      result = controller_action.id
      expect(ControllerAction).to receive(:find_by).with(id: controller_action.id).and_return(result)
      expect(node.controller_action).to eq(result)
    end
  end

  describe '#content_page' do
    it 'sets @content_page instance variable ' do
      result = content_page.id
      expect(ContentPage).to receive(:find_by).with(id: content_page.id).and_return(result)
      expect(node.content_page).to eq(result)
    end
  end

  describe '#add_child' do
    let(:child_node) { Menu::Node.new }

    before(:each) do
      child_node.setup(menu_item)
    end

    it 'adds one child to node' do
      expect(node.add_child(child_node)).to eq(node.children)
    end

    it 'adds multiple children to node' do
      expect(node.add_child(child_node)).to eq(node.children)
      expect(node.add_child(child_node)).to eq(node.children)
      expect(node.add_child(child_node)).to eq(node.children)
    end
  end
end

describe Menu do
  # To test menu, a variety of menu_items must exist.
  # role_admin.yml defines the permissionIds for admin as 5,5,6,3,2
  # we must assign controlleractions and contentpages
  # with permissionIds of those numbers
  # to enable menuitems's items_for_permissions function to succeed.

  let(:permission_ids) { [5, 5, 6, 3, 2] }

  let(:role) do
    role = double('Role')
    permissions = double('Permissions', permission_ids: permission_ids)
    allow(role).to receive_message_chain(:cache, :[]).with(:credentials).and_return(permissions)
    role
  end

  let(:controller_action) { double('ControllerAction', url_to_use: 'https://test_url.com') }

  let(:menu_items) do
    (1..5).collect do |i|
      build :menu_item,
            id: i,
            name: "menu_item#{i}",
            controller_action: controller_action,
            parent_id: [2, 3].include?(i) ? 1 : nil
    end
  end

  (1..5).each do |i|
    let("menu_item#{i}") do
      menu_items[i - 1]
    end
  end

  before(:each) do
    allow(ControllerAction).to receive(:find_by).and_return(controller_action)
    allow(ContentPage).to receive(:find_by)
    allow(MenuItem).to receive(:items_for_permissions).with(permission_ids).and_return(menu_items)
  end

  let(:menu) { Menu.new(role) }

  let(:node) { Menu::Node.new }

  describe '#select' do
    it 'returns when name is not in by_name{}' do
      expect(menu.select('not_in_menu')).to be_nil
    end

    it 'returns when name is in by_name{}' do
      menu.select(menu_item2.name)
      # selected checks the last element in the @vector [], which will be the node passed to select.
      # the selected node's parents will also be in vector, with the root node being first.
      expect(menu.selected).to eq(menu_item2.name)
      # crumbs returns an array of ids which is populated in same way as @vector, so it contains
      # the selected menu_item id as the last element, and each of its parents.
      expect(menu.crumbs.last.id).to eq(menu_item2.id)
      expect(menu.crumbs.first.id).to eq(menu_item1.id)
      # selected? checks the @selected{} collection, which will contain
      # a selected item and its parents.
      expect(menu.selected?(menu_item2.id)).to be true
      expect(menu.selected?(menu_item2.parent_id)).to be true
    end
  end

  describe '#get_item' do
    it 'returns nil when id is not in by_id{}' do
      id_not_in_menu = 1738
      expect(menu.get_item(id_not_in_menu)).to be_nil
    end
    it 'returns an equivalent item' do
      node.setup(menu_item5)
      current_item = menu.get_item(menu_item5.id)
      expect(current_item.content_page_id).to eq(node.content_page_id)
      expect(current_item.controller_action_id).to eq(node.controller_action_id)
      expect(current_item.id).to eq(node.id)
      expect(current_item.label).to eq(node.label)
      expect(current_item.name).to eq(node.name)
      expect(current_item.parent).to eq(node.parent)
      expect(current_item.parent_id).to eq(node.parent_id)
      expect(current_item.site_controller_id).to eq(node.site_controller_id)
      expect(current_item.url).to eq(node.url)
    end
  end

  describe '#get_menu' do
    # [@root, menu_item1, menu_item2]
    before(:each) do
      menu.select(menu_item2.name)
    end

    it 'returns nil for the last level' do
      expect(menu.get_menu(2)).to eq(nil)
    end

    it 'returns children of menu_item1' do
      expect(menu.get_menu(1)).to eq([2, 3])
    end

    it 'returns children of root' do
      expect(menu.get_menu(0)).to eq([1, 4, 5])
    end
  end

  describe '#selected' do
    it 'returns root if nothing is selected previously' do
      # menu_item has seq: 1, so it is the root.
      expect(menu.selected).to eq('menu_item1')
    end
    it 'returns the name of the selected menu_item' do
      menu.select(menu_item2.name)
      expect(menu.selected).to eq('menu_item2')
    end
  end

  describe '#selected?' do
    it 'contains root is nothing is selected previously' do
      expect(menu.selected?(menu_item1.id)).to be true
    end

    it 'contains selected node and its parents' do
      menu.select(menu_item2.name)
      expect(menu.selected?(menu_item2.id)).to be true
      expect(menu.selected?(menu_item1.id)).to be true
    end

    context 'no menu items for provided role' do
      it 'returns false when MenuItem returns nil' do
        allow(MenuItem).to receive(:items_for_permissions)
          .with(permission_ids).and_return(nil)
        menu = Menu.new(role)
        expect(menu.selected?(menu_item1.id)).to eq(false)
      end

      it 'returns false when MenuItem returns empty array' do
        allow(MenuItem).to receive(:items_for_permissions)
          .with(permission_ids).and_return([])
        menu = Menu.new(role)
        expect(menu.selected?(menu_item1.id)).to eq(false)
      end
    end
  end

  describe '#crumbs' do
    context 'top level menu item is selected' do
      before(:each) do
        menu.select(menu_item1.name)
      end

      it 'has one crumb' do
        expect(menu.crumbs.length).to eq(1)
      end

      it 'has crumb with menu id' do
        crumb = menu.crumbs[0]
        expect(crumb.id).to eq(menu_item1.id)
      end
    end

    context 'bottom level menu item is selected' do
      before(:each) do
        menu.select(menu_item2.name)
      end

      it 'has two crumbs' do
        expect(menu.crumbs.length).to eq(2)
      end

      it 'has crumb order from child to parent' do
        actual_crumb_ids = menu.crumbs.map(&:id)
        expected_crumb_ids = [menu_item1.id, menu_item2.id]
        expect(actual_crumb_ids).to eq(expected_crumb_ids)
      end
    end
  end
end
