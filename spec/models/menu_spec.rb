describe Node do
  ###
  # Please do not share this file with other teams.
  # Use factories to `build` necessary objects.
  # Please avoid duplicated code as much as you can by moving the code to `before(:each)` block or separated methods.
  # RSpec tutorial video (until 9:32): https://youtu.be/dzkVfaKChSU?t=35s
  # RSpec unit tests examples: https://github.com/expertiza/expertiza/blob/3ce553a2d0258ea05bced910abae5d209a7f55d6/spec/models/response_spec.rb
  ###

  let(:node) { Menu::Node.new }

  describe '#setup' do
    let(:menu_item) {
      build(:menu_item,
        parent_id: 1,
        name: 'test_name',
        id: 2,
        label: 'test_label'
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

    let(:content_page) {
      double('ContentPage',
        id: 1,
        name: 'test_content_page_name'
      )
    }

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

  # it '#site_controller' do
    # expect(node.site_controller).to eq('Fill this in by hand')
  # end

  # it '#controller_action' do
    # expect(node.controller_action).to eq('Fill this in by hand')
  # end

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
