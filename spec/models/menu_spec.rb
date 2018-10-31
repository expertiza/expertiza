describe Menu do
  before :example do
    controller = double("controller", id: 43, name: "controller1")
    temp = double("temp", id: 33, controller: controller, name: "temp", url_to_use: nil)
    allow_any_instance_of(MenuItem).to receive(:controller_action).and_return(temp)
    allow_any_instance_of(MenuItem).to receive(:content_page).and_return(temp)
    items = [test1, test2, test3, test4, test5, test6]
    allow(MenuItem).to receive(:items_for_permissions).with(anything).and_return(items)
  end

  let!(:test1) { create(:menu_item, name: "home1", parent_id: nil, seq: 1) }
  let!(:test2) { create(:menu_item, name: "home2", parent_id: 1, seq: 2) }
  let!(:test3) { create(:menu_item, name: "home3", parent_id: 1, seq: 3) }
  let!(:test4) { create(:menu_item, name: "home4", parent_id: 1, seq: 4) }
  let!(:test5) { create(:menu_item, name: "home5", parent_id: 2, seq: 2) }
  let!(:test6) { create(:menu_item, name: "home6", parent_id: 3, seq: 5) }

  describe Menu::Node do
    describe "#initilize" do
      context "when role is nil" do
        it "initializes with a nil parent" do
          @node = Menu::Node.new
          expect(@node.parent).to be_nil
        end
      end
    end
    describe "#setup" do
      context "when item.action_controller is nil" do
        it "returns /content_page.name" do
          allow_any_instance_of(MenuItem).to receive(:controller_action).and_return(nil)
          node = Menu::Node.new
          expect(node.setup(test1)).to eq("/temp")
        end
      end
      context "when item.action_controller is not nil" do
        it "returns /controller.name/controller_action.name" do
          node = Menu::Node.new
          expect(node.setup(test1)).to eq("/controller1/temp")
        end
      end
    end
    describe "#site_controller" do
      context "when @site_controller is nil" do
        it "updates @site_controller" do
          node = Menu::Node.new
          allow(SiteController).to receive(:find_by).with(anything).and_return("test site_controller")
          expect(node.site_controller).to eq("test site_controller")
        end
      end
      context "when @site_controller already has a value" do
        it "remains the same" do
          node = Menu::Node.new
          allow(SiteController).to receive(:find_by).with(anything).and_return("test site_controller")
          node.site_controller
          allow(SiteController).to receive(:find_by).with(anything).and_return("second controller")
          expect(node.site_controller).to eq("test site_controller")
        end
      end
    end
    describe "#controller_action" do
      context "when @controller_action is nil" do
        it "updates @controller_action" do
          node = Menu::Node.new
          allow(ControllerAction).to receive(:find_by).with(anything).and_return("test controller_action")
          expect(node.controller_action).to eq("test controller_action")
        end
      end
      context "when @controller_action already has a value" do
        it "remains the same" do
          node = Menu::Node.new
          allow(ControllerAction).to receive(:find_by).with(anything).and_return("test controller_action")
          node.controller_action
          allow(ControllerAction).to receive(:find_by).with(anything).and_return("second action")
          expect(node.controller_action).to eq("test controller_action")
        end
      end
    end
    describe "#content_page" do
      it "should update the content_page instance variable" do
        node = Menu::Node.new
        allow(ContentPage).to receive(:find_by).with(anything).and_return("test content page")
        expect(node.content_page).to eq("test content page")
      end
    end
    describe "#add_child" do
      context "when node has no children" do
        it "adds a child" do
          node = Menu::Node.new
          node.add_child(test1)
          expect(node.children).to eq([1])
        end
      end
      context "when node has no children" do
        it "can add multiple children" do
          node = Menu::Node.new
          node.add_child(test1)
          node.add_child(test2)
          node.add_child(test3)
          expect(node.children).to eq([1, 2, 3])
        end
      end
      context "when node has children" do
        it "adds a child" do
          node = Menu::Node.new
          node.children = [1];
          node.add_child(test2)
          expect(node.children).to eq([1, 2])
        end
      end
    end
  end
  describe "#initialize" do
    context "when role is nil" do
      it "creates a new menu" do
        menu = Menu.new
        expect(menu.instance_of? Menu)
      end
    end
    context "when a role is passed as an argument" do
      it "creates a new menu" do
        admin_role = build(:role_of_administrator, id: 3, name: "Administrator", description: '', parent_id: nil, default_page_id: nil)
        menu = Menu.new(admin_role)
        expect(menu.instance_of? Menu)
      end
    end
    context "when menu has items" do
      it "creates a new menu with items" do
        menu = Menu.new
        expect(menu.root.children.length).to eq(1)
      end
    end
    context "when menu has not items" do
      it "creates a new menu without items" do
        allow(MenuItem).to receive(:items_for_permissions).with(anything).and_return([])
        menu = Menu.new
        expect(menu.root.children).to be_nil
      end
    end
  end
  describe "#select" do
    it "returns a node.id based on the given name" do
      menu = Menu.new
      expect(menu.select("home3")).to eq(menu.get_item(3))
    end
  end
  describe "#selected" do
    context "when an item is selected" do
      it "returns the name of the currently selected item" do
        menu = Menu.new
        menu.select("home3")
        expect(menu.selected).to eq(test3.name)
      end
    end
    context "when a nonexistent node is selected" do
      it "returns nil" do
        allow(MenuItem).to receive(:items_for_permissions).with(anything).and_return([])
        menu = Menu.new
        menu.select("DNE")
        expect(menu.selected).to be_nil
      end
    end
  end
  describe "#get_item" do
    context "when menu has no items" do
      it "returns nil" do
        allow(MenuItem).to receive(:items_for_permissions).with(anything).and_return([])
        menu = Menu.new
        expect(menu.get_item(0)).to be_nil
      end
    end
    context "when menu has items" do
      it "returns the correct item" do
        menu = Menu.new
        expect(menu.get_item(2).id).to eq(test2.id)
      end
    end
    context "when a nonexistent id is passed" do
      it "returns nil" do
        menu = Menu.new
        expect(menu.get_item(17)).to be_nil
      end
    end
  end
  describe "#get_menu" do
    context "when a node is selected" do
      it "returns a list of nodes that are the children of the selected node" do
        menu = Menu.new
        expect(menu.get_menu(1)).to eq([2, 3, 4])
      end
    end
    context "when menu has no items" do
      it "returns nil" do
        allow(MenuItem).to receive(:items_for_permissions).with(anything).and_return([])
        menu = Menu.new
        expect(menu.get_menu(0)).to be_nil
      end
    end
    context "when called on a nonexistent node" do
      it "returns nil" do
        menu = Menu.new
        expect(menu.get_menu(17)).to be_nil
      end
    end
  end
  describe "#selected?" do
    context "when id passed is of a selected menu item" do
      it "returns true" do
        menu = Menu.new
        expect(menu.selected?(1)).to be true
      end
    end
    context "when id passed is not of a selected menu item" do
      it "returns false" do
        menu = Menu.new
        expect(menu.selected?(3)).to be false
      end
    end
    context "when passed nil as the id" do
      it "return false" do
        menu = Menu.new
        expect(menu.selected?(nil)).to be false
      end
    end
  end
  describe "#crumbs" do
    context "when root is selected" do
      it "returns a list of nodes based on the root" do
        menu = Menu.new
        expect(menu.crumbs[0]).to eq(menu.get_item(1))
      end
    end
    context "when a node besides root is selected" do
      it "returns a list of nodes based on the selected item" do
        menu = Menu.new
        menu.select("home2")
        expect(menu.crumbs[1]).to eq(menu.get_item(2))
      end
    end
  end
end
