require 'spec_helper.rb'
require 'rails_helper.rb' 

describe Node do
  ###
  # Please do not share this file with other teams.
  # Use factories to `build` necessary objects.
  # Please avoid duplicated code as much as you can by moving the code to `before(:each)` block or separated methods.
  # RSpec tutorial video (until 9:32): https://youtu.be/dzkVfaKChSU?t=35s
  # RSpec unit tests examples: https://github.com/expertiza/expertiza/blob/3ce553a2d0258ea05bced910abae5d209a7f55d6/spec/models/response_spec.rb
  ###

  let(:node) do
    Menu::Node.new
  end

  describe '#setup' do
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

  #let(:site_controller) {}
  

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

  #describe '#controller_action' do
  #  context "for controller_action not nil "
  #  it 'sets controller_ action instance variable from factory' do
  #    expect(@controller_action).to be_valid
  #  end
  #end


  # it '#content_page' do
  #   expect(node.content_page).to eq('Fill this in by hand')
  # end

  # it '#add_child' do
    # expect(node.add_child('Missing "child"')).to eq('Fill this in by hand')
  # end
end

describe Menu do
  let(:menu) do
    Menu.new
  end

  # let(:menu1) { double(:menu) }
  # describe '#initialize' do
    # it 'sets parent to nil' do
      # expect(menu1.initialize).parent.to eq(nil)
    # end
  # end

  # it '#select' do
    # expect(menu.select('Missing "name"')).to eq('Fill this in by hand')
  # end

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
