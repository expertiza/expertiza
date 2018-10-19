describe Node do
  let(:node) do
    Menu::Node.new
  end

  let(:item) do
    double('Item',
           parent_id: 1,
           name: 'test_name',
           id: 2,
           label: 'test_label',
           controller_action: nil
    )
  end

  let(:controller_action) do
    double('ControllerAction', id: 99, name: 'test_controller_action', url_to_use: 'https://test_url.com')
  end

  let(:controller) do
    double('Controller', id: 3, name: 'test_controller')
  end

  let(:content_page) do
    double('ContentPage', id: 1, name: 'test_content_page_name')
  end

  let(:child_node) do
    Menu::Node.new
  end

  describe '#initialize' do
    it 'sets parent to nil' do
        expect(node.parent).to eq(nil)
    end
  end

  describe '#setup' do
    it 'sets up basic fields' do
      allow(item).to receive_message_chain(:content_page, :name)
      node.setup(item)
      expect(node.parent_id).to eq(item.parent_id)
      expect(node.name).to eq(item.name)
      expect(node.id).to eq(item.id)
      expect(node.label).to eq(item.label)
    end

    it 'sets up site_controller_id' do
      allow(controller_action).to receive(:controller).and_return(controller)
      allow(item).to receive(:controller_action).and_return(controller_action)
      node.setup(item)
      expect(node.site_controller_id).to eq(item.controller_action.controller.id)
    end

    it 'sets up controller_action_id' do
      allow(item).to receive(:controller_action).and_return(controller_action)
      node.setup(item)
      expect(node.controller_action_id).to eq(item.controller_action.id)
    end

    it 'sets up content_page_id' do
      allow(item).to receive(:content_page).and_return(content_page)
      node.setup(item)
      expect(node.content_page_id).to eq(item.content_page.id)
    end

    it 'sets up url from content_page' do
      allow(item).to receive(:content_page).and_return(content_page)
      node.setup(item)
      expect(node.url).to eq("/#{item.content_page.name}")
    end

    it 'sets up url from controller_action.url_to_use' do
      allow(item).to receive(:controller_action).and_return(controller_action)
      node.setup(item)
      expect(node.url).to eq(item.controller_action.url_to_use)
    end

    it 'sets up url from controller_action.controller' do
      allow(controller_action).to receive(:url_to_use)
      allow(controller_action).to receive(:controller).and_return(controller)
      allow(item).to receive(:controller_action).and_return(controller_action)
      node.setup(item)
      expect(node.url).to eq("/#{controller.name}/#{controller_action.name}")
    end
  end

  describe '#site_controller' do
    before (:example)  do
     @foundid = FactoryBot.build(:site_controller, :id => 2, :name => 'fake1')
    end
    it 'sets site_controller instance variable from factory' do
      site_controller = @foundid
      expect(site_controller == @foundid).to be_truthy
    end
    it 'sets site_controller instance variable to nil' do
      site_controller = nil
      expect(site_controller).to be_nil
    end
    it 'sets site_controller from nil to the find site_cpntroller_id' do
      site_controller = nil
      expect {site_controller = @foundid}.to change{site_controller}.from(nil).to(@foundid)
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
    it 'adds one child to node' do
      allow(item).to receive(:content_page).and_return(content_page)
      child_node.setup(item)
      expect(node.add_child(child_node)).to eq(node.children)
    end

    it 'adds multiple children to node' do
      allow(item).to receive(:content_page).and_return(content_page)
      child_node.setup(item)
      expect(node.add_child(child_node)).to eq(node.children)
      expect(node.add_child(child_node)).to eq(node.children)
      expect(node.add_child(child_node)).to eq(node.children)
    end
  end
end

describe Menu do
  let(:menu1) do
    @admin_role = build(:role_of_administrator, id: 3, name: "Administrator", description: '', parent_id: nil, default_page_id: nil)
    Menu.new(@admin_role)
  end

  describe '#select' do
    it 'returns when name is not in by_name{}' do
      expect(menu1.select("not_in_menu")).to be_nil
    end

  end

  # it '#get_item' do
    # expect(menu.get_item('Missing "item_id"')).to eq('Fill this in by hand')
  # end

  # it '#get_menu' do
    # expect(menu.get_menu('Missing "level"')).to eq('Fill this in by hand')
  # end

  # it '#selected' do
    # expect(menu.selected).to eq('Fill this in by hand')
  # end

  # it '#selected?' do
    # expect(menu.selected?('Missing "menu_id"')).to eq('Fill this in by hand')
  # end

  # it '#crumbs' do
    # expect(menu.crumbs).to eq('Fill this in by hand')
  # end
end
