describe Node do
  ###
  # Please do not share this file with other teams.
  # Use factories to `build` necessary objects.
  # Please avoid duplicated code as much as you can by moving the code to `before(:each)` block or separated methods.
  # RSpec tutorial video (until 9:32): https://youtu.be/dzkVfaKChSU?t=35s
  # RSpec unit tests examples: https://github.com/expertiza/expertiza/blob/3ce553a2d0258ea05bced910abae5d209a7f55d6/spec/models/response_spec.rb
  ###

  let(:node) { Menu::Node.new }

  let(:menu_item) {
    build(:menu_item,
      parent_id: 1,
      name: 'test_name',
      id: 2,
      label: 'test_label'
    )
  }

  let(:content_page) {
    double('ContentPage',
      id: 1,
      name: 'test_content_page_name'
    )
  }

  let(:controller_action) {
    double('ControllerAction',
      id: 99,
      name: 'test_controller_action',
      url_to_use: 'https://test_url.com',
      controller: nil
    )
  }

  let(:controller) {
    double('Controller',
      id: 3,
      name: 'test_controller'
    )
  }

  describe '#setup' do
    it 'sets up attributes: parent_id, name, id, label' do
      allow(menu_item).to receive_message_chain(:content_page, :name)
      node.setup(menu_item)
      expect(node.parent_id).to eq(menu_item.parent_id)
      expect(node.name).to eq(menu_item.name)
      expect(node.id).to eq(menu_item.id)
      expect(node.label).to eq(menu_item.label)
    end

    context 'when menu_item has controller_action' do
      before(:each) do
        allow(menu_item).to receive(:controller_action).and_return(controller_action)
        node.setup(menu_item)
      end

      it 'sets up controller_action_id' do
        expect(node.controller_action_id).to eq(controller_action.id)
      end

      it 'assigns url to controller_action.url_to_use' do
        expect(node.url).to eq(controller_action.url_to_use)
      end

      context 'when controller_action has controller' do
        before(:each) do
          allow(controller_action).to receive(:controller).and_return(controller)
        end

        it 'sets up site_controller_id' do
          node.setup(menu_item)
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
      before(:each) {
        allow(menu_item).to receive(:content_page).and_return(content_page)
        node.setup(menu_item)
      }

      it 'sets up content_page_id' do
        expect(node.content_page_id).to eq(content_page.id)
      end

      it 'sets up url to content_page name' do
        expect(node.url).to eq("/#{content_page.name}")
      end
    end
  end

  describe '#site_controller' do
    before (:example)  do
      allow(menu_item).to receive(:controller_action).and_return(controller_action)
      allow(controller_action).to receive(:controller).and_return(controller)
      node.setup(menu_item)
    end
    it 'sets site_controller instance variable from factory' do
      result = controller_action.id;
      expect(SiteController).to receive(:find_by).with(id: controller.id).and_return(result)
      expect(node.site_controller).to eq(result)
    end
  end

  # it '#site_controller' do
    # expect(node.site_controller).to eq('Fill this in by hand')
  # end

  # it '#controller_action' do
    # expect(node.controller_action).to eq('Fill this in by hand')
  # end

  # it '#content_page' do
  #   expect(node.content_page).to eq('Fill this in by hand')
  # end

  describe '#add_child' do
    let(:child_node) { Menu::Node.new }

    it 'adds one child to node' do
      allow(menu_item).to receive(:content_page).and_return(content_page)
      child_node.setup(menu_item)
      expect(node.add_child(child_node)).to eq(node.children)
    end

    it 'adds multiple children to node' do
      allow(menu_item).to receive(:content_page).and_return(content_page)
      child_node.setup(menu_item)
      expect(node.add_child(child_node)).to eq(node.children)
      expect(node.add_child(child_node)).to eq(node.children)
      expect(node.add_child(child_node)).to eq(node.children)
    end
  end
end

describe Menu do
  # To test menu, a variety of menu_items must exist.
  # role_admin.yml defines the permissionIds for admin as 5,5,6,3,2
  # we must assign controlleractions and contentpages with permissionIds of those numbers
  # to enable menuitems's items_for_permissions function to succeed.
  let!(:menu_item1) { create(:menu_item, name: "menu_item1", parent_id: nil,  seq: 1) }
  let!(:menu_item2) { create(:menu_item, name: "menu_item2", parent_id: 1,    seq: 2) }
  let!(:menu_item3) { create(:menu_item, name: "menu_item3", parent_id: 1,    seq: 3) }
  let!(:menu_item4) { create(:menu_item, name: "menu_item4", parent_id: nil,  seq: 2) }
  let!(:menu_item5) { create(:menu_item, name: "menu_item5", parent_id: nil,  seq: 4) }
  (1..7).each do |i|
    let!("controller_action#{i}".to_sym) { ControllerAction.create(site_controller_id: i, name: 'name', permission_id: i) }
    let!("content_page#{i}".to_sym) { ContentPage.create(title: "home page#{i}", name: "home#{i}", content: '', permission_id: i, content_cache: '') }
  end

  let(:menu1) do
    @admin_role = build(:role_of_administrator, id: 3, name: "Administrator", description: '', parent_id: 1, default_page_id: 1)
    menu_item1.update_attributes(controller_action_id: nil, content_page_id: 5)
    menu_item2.update_attributes(controller_action_id: nil, content_page_id: 5)
    menu_item3.update_attributes(controller_action_id: nil, content_page_id: 6)
    menu_item4.update_attributes(controller_action_id: nil, content_page_id: 3)
    menu_item5.update_attributes(controller_action_id: nil, content_page_id: 2)
    Menu.new(@admin_role)
  end

  describe '#select' do
    it 'returns when name is not in by_name{}' do
      expect(menu1.select("not_in_menu")).to be_nil
    end
    it 'returns when name is in by_name{}'do
      menu1.select("menu_item1")
      expect(menu1.crumbs.first.id).to eq(menu_item1.id)
      expect(menu1.selected).to eq("menu_item1")
      expect(menu1.selected?(menu_item1.id)).to be true
    end

  end

  # it '#get_item' do
    # expect(menu.get_item('Missing "item_id"')).to eq('Fill this in by hand')
  # end

  # it '#get_menu' do
    # expect(menu.get_menu('Missing "level"')).to eq('Fill this in by hand')
  # end

  describe '#selected' do
    it 'returns root if nothing is selected previously' do
      # menu_item has seq: 1, so it is the root.
      expect(menu1.selected).to eq("menu_item1")
    end
    it 'returns the name of the selected menu_item' do
      menu1.select("menu_item2")
      expect(menu1.selected).to eq("menu_item2")
    end
  end

  # it '#selected?' do
    # expect(menu.selected?('Missing "menu_id"')).to eq('Fill this in by hand')
  # end

  describe '#crumbs' do
    let(:menu) do
      role = double('Role')
      allow(role).to receive_message_chain(:cache, :[])
      Menu.new(role)
    end

    context 'no menu item is selected' do
      it 'returns empty array' do
        expect(menu.crumbs).to be_empty
      end
    end

    context 'top level menu item is selected' do
      before(:each) do
        menu1.select(menu_item1.name)
      end

      it 'has one crumb' do
        expect(menu1.crumbs.length).to eq(1)
      end

      it 'has crumb with menu id' do
        crumb = menu1.crumbs[0];
        expect(crumb.id).to eq(menu_item1.id)
      end
    end

    context 'bottom level menu item is selected' do
      before(:each) do
        menu1.select(menu_item2.name)
      end

      it 'has two crumbs' do
        expect(menu1.crumbs.length).to eq(2)
      end

      it 'has crumb order from child to parent' do
        actualCrumbIds = menu1.crumbs.collect { |c| c.id }
        expectedCrumbIds = [menu_item1.id, menu_item2.id]
        expect(actualCrumbIds).to eq(expectedCrumbIds)
      end
    end
  end
end
