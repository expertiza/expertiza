describe Node do
  ###
  # Use factories to `build` necessary objects.
  # Avoid duplicated code as much as you can by moving the code to `before(:each)` block or separated methods.
  # RSpec tutorial video (until 9:32): https://youtu.be/dzkVfaKChSU?t=35s
  # RSpec unit tests examples: https://github.com/expertiza/expertiza/blob/3ce553a2d0258ea05bced910abae5d209a7f55d6/spec/models/response_spec.rb
  ###
  
  # Write your mocked object here!
  let(:menu) { Menu.new }
  let(:node) { Menu::Node.new }
  let(:node2) { Menu::Node.new }
  let(:node3) { Menu::Node.new }
  # let(:sc_test1) {SiteController.create(id:1,  name:"site1")}
  # let(:sc_test2) {SiteController.create(id:2,  name:"site2")}
  let(:sc_test1) {build(:site_controller, id:1,  name:"site1")}
  let(:sc_test2) {build(:site_controller, id:2,  name:"site2")}

  # let(:ca_test1) {ControllerAction.create( id: 1,site_controller_id: 1, name: "action1", permission_id: 1, url_to_use: "/test/")}
  # let(:ca_test2) {ControllerAction.create(id: 2, site_controller_id: 1, name: "action2", permission_id: 1)}
  let(:ca_test1) {build(:controller_action, id: 1, site_controller_id: 1, name: "action1", permission_id: 1, url_to_use: "/test/")}
  let(:ca_test2) {build(:controller_action, id: 2, site_controller_id: 1, name: "action2", permission_id: 1, url_to_use: nil)}
  # let(:cp_test1) {ContentPage.create( id: 1, name:"content1" )}
  # let(:cp_test2) {ContentPage.create( id: 2, name:"content2" )}
  let(:cp_test1) {build(:content_page, id: 1, name:"content1" )}
  let(:cp_test2) {build(:content_page, id: 2, name:"content2" )}
  let(:item1) { build(:menu_item, name: "home1", parent_id: nil,  seq: 1, content_page_id:1) }
  let(:item2) { build(:menu_item, name: "home2", parent_id: 1,    seq: 2, controller_action_id:1, content_page_id: 1) }
  let(:item3) { build(:menu_item, name: "home3", parent_id: 1,    seq: 3, controller_action_id:2, content_page_id: 1) }


  # before(:each) do
  #   allow(ControllerAction).to receive(:find).and_return(review_response_map)
  # end


  describe "#initialize" do
    it "initializes the parent attribute" do
    # Write your test here!
      expect(node.parent).to be_nil
    end  
  end

  describe "#setup" do
    context "when the controller action attribute of the item is nil" do
      it "assigns content page path of the current menu item to the URL variable" do
        # Write your test here!
        # allow(MenuItem).to receive_message_chain(:try, :try).with(:content_page,:id).and_return(cp_test1.id)
        # allow(item1).to receive_message_chain(:content_page, :name).and_return("#{cp_test1.name}")

        item1.content_page = cp_test1
        node.setup(item1)
        expect(node.url).to eq("/#{cp_test1.name}")

        # expect(node.controller_action_id).to eq(1)

      end
    end

    context "when the controller action attribute of the item is not nil" do
      context "when the URL of the controller action is available" do
        it "assigns the URL of controller action to the URL variable" do
          # Write your test here!
          # allow(node2).to receive(:setup).with(test2)
          allow(SiteController).to receive(:find).with(sc_test1.id).and_return(sc_test1)
          ca_test1.controller

          # ca_test1.controller = sc_test1
          item2.controller_action = ca_test1
          item2.content_page = cp_test1
          node2.setup(item2)
          expect(node2.url).to eq("#{ca_test1.url_to_use}")
          end
      end

      context "when the URL of the controller action is unavailable" do
        it "assigns a customized path to the URL variable" do
          # Write your test here!
          # allow(node3).to receive(:setup).with(test3)

          ca_test2.controller = sc_test1
          item3.controller_action = ca_test2
          item3.content_page = cp_test1
          node3.setup(item3)
          expect(node3.url).to eq("/#{sc_test1.name}/#{ca_test2.name}")
          end
      end
    end
  end

  describe "#site_controller" do
    context "when the site_controller variable is nil" do
      it "finds the site controller by id" do
        # Write your test here!
        # test3.controller_action = ca_test2
        # node.setup(test3)
        # expect(node.site_controller).to eq(sc_test1)
        node.site_controller_id = sc_test1.id
        allow(SiteController).to receive(:find_by).with(id: sc_test1.id).and_return(sc_test1)
        expect(node.site_controller).to eq(sc_test1)
      end
    end

    context "when the site_controller variable is not nil" do
      it "returns the site_controller variable" do
        # Write your test here!
        # ca_test2.site_controller = sc_test1
        # test3.controller_action = ca_test2
        # node.setup(test3)
        # expect(node.site_controller).to eq("sc_test1")
        # node.site_controller =
        node.instance_variable_set(:@site_controller, sc_test2)
        expect(node.site_controller).to eq(sc_test2)
      end
    end
  end

  describe "#controller_action" do
    context "when controller_action variable is nil" do
      it "finds the controller action by id"do
        # Write your test here!
        node.controller_action_id = ca_test1.id
        allow(ControllerAction).to receive(:find_by).with(id: ca_test1).and_return(ca_test1)
        expect(node.controller_action).to eq(ca_test1)
      end
    end

    context "when the controller_action variable is not nil" do
      it "returns the controller action variable" do
        # Write your test here!
        node.instance_variable_set(:@controller_action, ca_test2)
        expect(node.controller_action).to eq(ca_test2)
      end
    end
  end

  describe "#content_page" do
    context "when content_page variable is nil" do
      it "finds the content page by id" do
        # Write your test here!
        node.content_page_id = cp_test1
        allow(ContentPage).to receive(:find_by).with(id: cp_test1).and_return(cp_test1)
        expect(node.content_page).to eq(cp_test1)
      end
    end

    context "when the content_page variable is not nil" do
      it "returns the content page variable" do
        # Write your test here!
        node.instance_variable_set(:@content_page, cp_test2)
        expect(node.content_page).to eq(cp_test2)
      end
    end
  end

  describe "#add_child" do
    it "adds a node to @children list and returns the list" do
      # Write your test here!
      # node2.instance_variable_set(:@id, 2)
      node2.id = 2
      node.add_child(node2)
      expect(node.children[0]).to eq(2)
    end
  end
end

describe Menu do
  # Write your mocked object here!
  let(:menu) { Menu.new }
  let(:node) { Menu::Node.new }

  describe "#initialize" do
    context "when menu items are nil or empty" do
      it "terminates later initialization and returns nil"
      # Write your test here!
    end

    context "when menu items are not nil or empty" do
      context "when the parent id of the node is nil" do
        it "builds hashes of items by name and id and make the node as a child node of root node"
        # Write your test here!
      end

      context "when the parent id of the node is not nil" do
        it "builds hashes of items by name and id and make the node as a child node of its parent node"
        # Write your test here!
      end
    end
  end

  describe "#select" do
    context "when by_name hash does not contain the given node name" do
      it "returns nil"
      # Write your test here!
    end

    context "when by_name hash contains the given node name" do
      it "selects the menu item for the given name"
      # Write your test here!
    end
  end

  describe "#get_item" do
    it "returns menu item by id"
    # Write your test here!
  end

  describe "#get_menu" do
    it "returns the array of child nodes at the given level"
    # Write your test here!
  end

  describe "#selected" do
    it "returns the name of the currently-selected element"
    # Write your test here!
  end

  describe "#selected?" do
    context "when @selected hash contains menu_id" do
      it "returns true"
      # Write your test here!
    end

    context "when @selected hash does not contain menu_id" do
      it "returns false"
      # Write your test here!
    end
  end

  describe "#crumbs" do
    it "returns get a list of menu items based on contents in crumbs array"
    # Write your test here!
  end
end
